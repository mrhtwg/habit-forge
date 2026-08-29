import 'package:get/get.dart';
import 'package:grpc/grpc.dart';
import 'package:habit_forge_app/core/constants/env_constants.dart';
import 'package:habit_forge_app/core/interface/network_interface.dart';
import 'package:habit_forge_app/core/storage/game_logic.dart';
import 'package:habit_forge_app/generated/protos/achievement/v1/achievement.pbgrpc.dart';
import 'package:habit_forge_app/generated/protos/character/v1/character.pbgrpc.dart';
import 'package:habit_forge_app/generated/protos/shop/v1/shop.pbgrpc.dart';
import 'package:habit_forge_app/generated/protos/task/v1/task.pbgrpc.dart';
import 'package:habit_forge_app/generated/protos/user/v1/user.pbgrpc.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

/// gRPC-backed storage (server mode). Talks to the self-hosted Go backend,
/// which owns the game logic (rewards, level-ups, purchases...).
///
/// The JWT from [authToken] is attached to every call via [_AuthInterceptor];
/// the session token is persisted locally (Hive) so a restart keeps the login.
///
/// Note: the backend business logic is not implemented yet (its methods return
/// 501), so gRPC calls currently fail at runtime until `server/internal/biz`
/// is filled in.
class NetworkServerImpl implements NetworkInterface {
  final userPrefs = Rxn<UserPrefs>();
  final character = Rxn<Character>();
  final tasks = <Task>[].obs;
  final ownedItemIds = <String>[].obs;
  final achievements = <Achievement>[].obs;
  final dailyDeal = Rxn<DailyDeal>();

  late final ClientChannel _channel;
  late final UserServiceClient _user;
  late final CharacterServiceClient _character;
  late final TaskServiceClient _task;
  late final ShopServiceClient _shop;
  late final AchievementServiceClient _achievement;

  String? _token;
  bool _loggedIn = false;

  @override
  String get authMethod => 'server';

  @override
  String? get authToken => _token;

  @override
  Future<void> addGems(int amount) async {
    final prefs = userPrefs.value ?? UserPrefs();
    saveUserPrefs(GameLogic.addGems(prefs, amount));
  }

  @override
  Future<void> addGold(int amount) async {
    final prefs = userPrefs.value ?? UserPrefs();
    saveUserPrefs(GameLogic.addGold(prefs, amount));
  }

  @override
  Future<bool> allocateStatPoint(StatType stat) async {
    final reply = await _character.allocateStatPoint(AllocateStatPointRequest(stat: stat));
    character.value = reply.character;
    return true;
  }

  @override
  Future<TaskCompleteResult> completeTask(Task task) async {
    final reply = await _task.completeTask(CompleteTaskRequest(id: task.id));
    tasks.value = [for (final t in tasks) t.id == reply.task.id ? reply.task : t];
    // Sync wallet / character from the backend (the reply carries the rewards).
    await refreshAll();
    return TaskCompleteResult(
      expGained: reply.expReward.toInt(),
      goldGained: reply.goldReward.toInt(),
      newLevel: null, // TODO(server): detect level-up from the synced character.
    );
  }

  // ── Character operations ──
  @override
  Future<(Character, bool)> createCharacter(CharacterClass characterClass) async {
    character.value = Character(characterClass: characterClass);
    _character.updateCharacter(UpdateCharacterRequest(character: character.value)).ignore();
    return (character.value!, true);
  }

  // ── Task operations ──
  @override
  String createTask(Task task) {
    final id = task.id.isEmpty ? const Uuid().v4() : task.id;
    _task.createTask(CreateTaskRequest(task: task..id = id)).ignore();
    return id;
  }

  @override
  void deleteTask(String id) {
    _task.deleteTask(DeleteTaskRequest(id: id)).ignore();
  }

  @override
  void equipItem(String itemId, {String slot = 'weapon'}) {
    final char = character.value;
    if (char == null) return;
    // TODO(server): add an Equip RPC; client-side for now.
    final updated = GameLogic.equip(char, slot, itemId);
    character.value = updated;
    _character.updateCharacter(UpdateCharacterRequest(character: updated)).ignore();
  }

  @override
  Future<NetworkInterface> init() async {
    final (host, port) = _parseEndpoint(EnvConstants.grpcUrl);
    _channel = ClientChannel(
      host,
      port: port,
      options: const ChannelOptions(credentials: ChannelCredentials.insecure()),
    );
    final auth = _AuthInterceptor(() => _token);
    _user = UserServiceClient(_channel, interceptors: [auth]);
    _character = CharacterServiceClient(_channel, interceptors: [auth]);
    _task = TaskServiceClient(_channel, interceptors: [auth]);
    _shop = ShopServiceClient(_channel, interceptors: [auth]);
    _achievement = AchievementServiceClient(_channel, interceptors: [auth]);

    // Restore the persisted session token (if any).
    final box = await Hive.openBox('userBox');
    _token = box.get('serverToken') as String?;
    _loggedIn = _token != null && _token!.isNotEmpty;
    if (_loggedIn) {
      await refreshAll();
    }
    return this;
  }

  Future<Character?> loadCharacter() async {
    final char = await _character.getCharacter(GetCharacterRequest());
    character.value = char.character;
    return character.value;
  }

  @override
  void postponeTask(Task task) => updateTask(GameLogic.postpone(task));

  // ── Economy ──
  @override
  Future<bool> purchaseItem(String itemId, int price, {ShopCurrency currency = ShopCurrency.SHOP_CURRENCY_GOLD}) async {
    try {
      final reply = await _shop.buyItem(BuyItemRequest(itemId: itemId, currency: currency));
      await refreshAll();
      return reply.item.id.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> refreshAll() async {
    if (!_loggedIn) return;
    // TODO(server): the backend business methods are not implemented yet (501);
    // these calls start working once server/internal/biz is filled in.
    final prefs = await _user.getPrefs(GetPrefsRequest());
    userPrefs.value = prefs.prefs;
    // final char = await _character.getCharacter(GetCharacterRequest());
    // character.value = char.character;
    final list = await _task.listTasks(ListTasksRequest());
    tasks.value = list.tasks;
    final owned = await _shop.listOwnedItems(ListOwnedItemsRequest());
    ownedItemIds.value = owned.itemIds;
    final ach = await _achievement.listAchievements(ListAchievementsRequest());
    achievements.value = ach.achievements;
    final deal = await _shop.getDailyDeal(GetDailyDealRequest());
    dailyDeal.value = deal.deal;
  }

  @override
  Future<void> resetAllData() async {
    _token = null;
    _loggedIn = false;
    final box = await Hive.openBox('userBox');
    await box.delete('serverToken');
    userPrefs.value = null;
    character.value = null;
    tasks.clear();
    ownedItemIds.clear();
    achievements.clear();
    dailyDeal.value = null;
  }

  @override
  Future<void> reviveCharacter() async {
    await _character.revive(ReviveRequest());
    final char = await _character.getCharacter(GetCharacterRequest());
    character.value = char.character;
  }

  // ── Auth ──
  @override
  void saveAuthToken(String? token) {
    _token = token;
    Hive.box('userBox').put('serverToken', token);
  }

  @override
  void saveDailyDeal(DailyDeal deal) {
    dailyDeal.value = deal;
    // TODO(server): daily deals are server-owned; a local override is not supported.
  }

  // ── User prefs / deal ──
  @override
  void saveUserPrefs(UserPrefs prefs) {
    userPrefs.value = prefs;
    _user.updatePrefs(UpdatePrefsRequest(prefs: prefs)).ignore();
  }

  @override
  void setLoggedIn(bool value, {String method = ''}) {
    _loggedIn = value;
    if (value) {
      refreshAll();
    }
  }

  @override
  void skipTask(Task task) => updateTask(GameLogic.skip(task));

  @override
  Future<void> takeDamage(int amount) async {
    final char = character.value;
    if (char == null) return;
    // TODO(server): add a dedicated TakeDamage RPC to the contract once the
    // backend owns combat; for now the client computes and pushes the state.
    final updated = GameLogic.takeDamage(char, amount);
    character.value = updated;
    _character.updateCharacter(UpdateCharacterRequest(character: updated)).ignore();
  }

  // ── Achievements ──
  @override
  Future<bool> unlockAchievement(Achievement def) async {
    final reply = await _achievement.unlock(UnlockRequest(id: def.id));
    await refreshAll();
    return reply.achievement.isUnlocked;
  }

  @override
  void updateTask(Task task) {
    _task.updateTask(UpdateTaskRequest(id: task.id, task: task)).ignore();
  }

  /// Parses "host:port" (or "http://host:port") into a (host, port) record.
  (String, int) _parseEndpoint(String url) {
    final cleaned = url.replaceAll(RegExp(r'^https?://'), '');
    final parts = cleaned.split(':');
    final host = parts.first;
    final port = parts.length > 1 ? int.tryParse(parts[1]) ?? 9000 : 9000;
    return (host, port);
  }
}

/// Attaches the current JWT to every outgoing gRPC call.
class _AuthInterceptor extends ClientInterceptor {
  final String? Function() _token;

  _AuthInterceptor(this._token);

  @override
  ResponseFuture<R> interceptUnary<Q, R>(
    ClientMethod<Q, R> method,
    Q request,
    CallOptions options,
    ClientUnaryInvoker<Q, R> invoker,
  ) {
    final token = _token();
    final opts = (token == null || token.isEmpty)
        ? options
        : options.mergedWith(CallOptions(metadata: {'authorization': 'Bearer $token'}));
    return invoker(method, request, opts);
  }
}
