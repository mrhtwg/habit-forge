import 'package:fixnum/fixnum.dart';
import 'package:get/get.dart';
import 'package:grpc/grpc.dart';
import 'package:habit_forge_app/core/constants/env_constants.dart';
import 'package:habit_forge_app/core/network/api_response.dart';
import 'package:habit_forge_app/core/network/grpc/character_api.dart';
import 'package:habit_forge_app/core/network/network_interface.dart';
import 'package:habit_forge_app/core/storage/catalog.dart';
import 'package:habit_forge_app/core/storage/game_logic.dart';
import 'package:habit_forge_app/generated/protos/achievement/v1/achievement.pbgrpc.dart';
import 'package:habit_forge_app/generated/protos/character/v1/character.pbgrpc.dart';
import 'package:habit_forge_app/generated/protos/shop/v1/shop.pbgrpc.dart';
import 'package:habit_forge_app/generated/protos/task/v1/task.pbgrpc.dart';
import 'package:habit_forge_app/generated/protos/user/v1/user.pbgrpc.dart';
import 'package:hive/hive.dart';

/// gRPC-backed storage (server mode). Talks to the self-hosted Go backend,
/// which owns the game logic (rewards, level-ups, purchases...).
///
/// The JWT from [authToken] is attached to every call via [_AuthInterceptor];
/// the session token is persisted locally (Hive) so a restart keeps the login.
///
/// Note: the backend business logic is not implemented yet (its methods return
/// 501), so gRPC calls currently fail at runtime until `server/internal/biz`
/// is filled in. Every call degrades to an [ApiResponse.failure] instead of
/// crashing the UI.
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
  List<Achievement> get achievementDefs => GameCatalog.achievementDefs;

  @override
  String get authMethod => 'server';

  @override
  String? get authToken => _token;

  @override
  List<ShopItem> get shopItems => GameCatalog.shopItems;

  @override
  Future<bool> allocateStatPoint(StatType stat) async {
    final reply = await _character.allocateStatPoint(AllocateStatPointRequest(stat: stat));
    character.value = reply.character;
    return true;
  }

  @override
  Future<TaskCompleteResult> completeTask(String id) async {
    final reply = await _task.completeTask(CompleteTaskRequest(id: id));
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
  Future<ApiResponse<GetCharacterReply>> createCharacter(CharacterClass characterClass) async {
    try {
      await _character.createCharacter(CreateCharacterRequest(characterClass: characterClass));
      final reply = await _character.getCharacter(GetCharacterRequest());
      return ApiResponse.success(reply, 'Character created');
    } on Exception catch (e) {
      return ApiResponse.fromException(e);
    }
  }

  // ── Task operations ──

  @override
  Future<ApiResponse<Task>> createTask(CreateTaskParams params) async {
    if (params.title.trim().isEmpty) {
      return ApiResponse.failure(code: 400, message: 'Title is required');
    }
    final task = Task(
      title: params.title.trim(),
      description: params.description?.trim().isNotEmpty == true ? params.description!.trim() : null,
      type: params.type,
      difficulty: params.difficulty,
      tags: params.tags,
      dueDate: params.dueDate ?? Int64.ZERO,
      repeatDays: params.repeatDays,
      priority: params.priority,
      hpPenalty: params.hpPenalty,
    );
    try {
      final reply = await _task.createTask(CreateTaskRequest(task: task));
      return ApiResponse.success(reply.task, 'Task created');
    } on Exception catch (e) {
      return ApiResponse.fromException(e);
    }
  }

  @override
  Future<void> deleteTask(String id) async {
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

  Future<ApiResponse<GetCharacterReply>> getCharacter() async {
    return await CharacterApi().getCharacter();
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

    _loggedIn = _token != null && _token!.isNotEmpty;
    if (_loggedIn) {
      await refreshAll();
    }
    return this;
  }

  @override
  Future<void> postponeTask(String id) async {
    final task = _findTask(id);
    if (task == null) return;
    await updateTask(
      id,
      CreateTaskParams(
        title: task.title,
        description: task.description,
        type: task.type,
        difficulty: task.difficulty,
        tags: task.tags,
        dueDate: task.dueDate == Int64.ZERO ? null : task.dueDate,
        repeatDays: task.repeatDays,
        priority: task.priority,
        hpPenalty: task.hpPenalty,
      ),
    );
  }

  // ── Economy ──

  @override
  Future<ApiResponse<BuyItemReply>> purchaseItem(
    String itemId, {
    ShopCurrency currency = ShopCurrency.SHOP_CURRENCY_GOLD,
  }) async {
    try {
      final reply = await _shop.buyItem(BuyItemRequest(itemId: itemId, currency: currency));
      await refreshAll();
      return ApiResponse.success(reply, 'Purchase successful');
    } on Exception catch (e) {
      return ApiResponse.fromException(e);
    }
  }

  @override
  Future<void> refreshAll() async {
    if (!_loggedIn) return;
    // TODO(server): the backend business methods are not implemented yet (501);
    // these calls start working once server/internal/biz is filled in.
    final prefs = await _user.getPrefs(GetPrefsRequest());
    userPrefs.value = prefs.prefs;
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
  Future<DailyDeal> refreshDailyDeal() async {
    try {
      final reply = await _shop.getDailyDeal(GetDailyDealRequest());
      if (reply.hasDeal()) {
        dailyDeal.value = reply.deal;
        return reply.deal;
      }
    } on Exception {
      // Backend not available yet — fall back to a local deal.
    }
    final saved = dailyDeal.value;
    if (saved != null && DateTime(saved.expiresAt.toInt()).isAfter(DateTime.now())) {
      return saved;
    }
    final now = DateTime.now();
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);
    final expiresAt = now.isAfter(endOfDay)
        ? DateTime(now.year, now.month, now.day, 23, 59, 59).add(const Duration(days: 1))
        : endOfDay;
    final deal = DailyDeal(
      itemId: 'staff_arcane',
      discountPercent: 40,
      expiresAt: Int64(expiresAt.millisecondsSinceEpoch),
    );
    dailyDeal.value = deal;
    return deal;
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
  void setLoggedIn(bool value, {String method = ''}) {
    _loggedIn = value;
    if (value) {
      refreshAll();
    }
  }

  @override
  Future<void> skipTask(String id) async {
    final task = _findTask(id);
    if (task == null) return;
    final updated = GameLogic.skip(task);
    _task.updateTask(UpdateTaskRequest(id: id, task: updated)).ignore();
  }

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

  @override
  Future<ApiResponse<Task>> updateTask(String id, CreateTaskParams params) async {
    final current = _findTask(id);
    if (current == null) {
      return ApiResponse.failure(code: 404, message: 'Task not found');
    }
    final updated = params.applyTo(current);
    try {
      final reply = await _task.updateTask(UpdateTaskRequest(id: id, task: updated));
      return ApiResponse.success(reply.task, 'Task updated');
    } on Exception catch (e) {
      return ApiResponse.fromException(e);
    }
  }

  Task? _findTask(String id) {
    for (final t in tasks) {
      if (t.id == id) return t;
    }
    return null;
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
