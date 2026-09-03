import 'dart:io';

import 'package:fixnum/fixnum.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:habit_forge_app/core/common/utils/sp_utils.dart';
import 'package:habit_forge_app/core/di/injection_container.dart';
import 'package:habit_forge_app/core/network/hive/character_box.dart';
import 'package:habit_forge_app/core/network/hive/game_constants.dart';
import 'package:habit_forge_app/core/network/hive/game_logic.dart';
import 'package:habit_forge_app/core/network/hive/shop_box.dart';
import 'package:habit_forge_app/core/network/hive/task_box.dart';
import 'package:habit_forge_app/core/network/hive/user_box.dart';
import 'package:habit_forge_app/core/network/network_hive_impl.dart';
import 'package:habit_forge_app/core/network/network_registry.dart';
import 'package:habit_forge_app/core/services/user_service.dart';
import 'package:habit_forge_app/generated/protos/character/v1/character.pb.dart';
import 'package:habit_forge_app/generated/protos/shared/v1/shared.pbenum.dart';
import 'package:habit_forge_app/generated/protos/shop/v1/shop.pb.dart';
import 'package:habit_forge_app/generated/protos/task/v1/task.pb.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// End-to-end hive-mode flow test (no UI): login → character → tasks of every
/// type/difficulty → complete / skip / miss → level-up → damage → death →
/// revive → earn gold → shop → equip → achievements → max level (no overflow).
void main() {
  late NetworkHiveImpl api;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});

    configureDependencies();
    Get.put(UserService(), permanent: true);

    await SpUtils.init();
    await UserService.to.init();

    final tmp = await Directory.systemTemp.createTemp('hive_flow');
    Hive.init(tmp.path);
    await CharacterBox.ins.init();
    await TaskBox.ins.init();
    await UserBox.ins.init();
    await ShopBox.ins.init();

    NetworkRegistry.register(NetworkHiveImpl());
    api = NetworkRegistry.ins as NetworkHiveImpl;
  });

  test('login (hive mints a guest token)', () async {
    expect(UserService.to.isLoggedIn(), isFalse);

    final reply = await api.login('guest');
    expect(reply.isSuccess, isTrue);
    expect(reply.data?.token, isNotEmpty);
    expect(UserService.to.isLoggedIn(), isTrue);
    expect(UserService.to.token.value, isNotEmpty);
  });

  test('create character (once)', () async {
    final first = await api.createCharacter(CharacterClass.CHARACTER_CLASS_WARRIOR);
    expect(first.isSuccess, isTrue);
    expect(first.data?.character.level, 1);
    expect(first.data?.character.currentHp, GameConstants.initialHp);
    expect(first.data?.character.currentExp.toInt(), 0);

    // Second create must fail (already exists).
    final second = await api.createCharacter(CharacterClass.CHARACTER_CLASS_MAGE);
    expect(second.isFailure, isTrue);
  });

  test('create tasks of every type & difficulty', () async {
    final today = DateTime.now().weekday; // DateTime.monday=1 .. sunday=7
    final tasks = <Task>[
      Task(title: 'Habit easy', type: TaskType.TASK_TYPE_HABIT, difficulty: TaskDifficulty.TASK_DIFFICULTY_EASY),
      Task(title: 'Habit hard', type: TaskType.TASK_TYPE_HABIT, difficulty: TaskDifficulty.TASK_DIFFICULTY_HARD),
      Task(
        title: 'Daily medium',
        type: TaskType.TASK_TYPE_DAILY,
        difficulty: TaskDifficulty.TASK_DIFFICULTY_MEDIUM,
        repeatDays: [today - 1],
      ),
      Task(
        title: 'Todo hard',
        type: TaskType.TASK_TYPE_TODO,
        difficulty: TaskDifficulty.TASK_DIFFICULTY_HARD,
        dueDate: Int64(DateTime.now().add(const Duration(days: 1)).millisecondsSinceEpoch),
      ),
    ];
    for (final t in tasks) {
      final reply = await api.createTask(t);
      expect(reply.isSuccess, isTrue, reason: 'create ${t.title}');
      expect(reply.data?.task.id, isNotEmpty);
      expect(reply.data?.task.createdAt.toInt(), greaterThan(0));
      expect(reply.data?.task.updatedAt.toInt(), greaterThan(0));
    }

    final list = await api.listTasks();
    expect(list.isSuccess, isTrue);
    expect(list.data!.tasks.length, tasks.length);

    // Type filter works.
    final habits = await api.listTasks(type: TaskType.TASK_TYPE_HABIT);
    expect(habits.data!.tasks.length, 2);
  });

  test('complete tasks: rewards, counters, streak fields', () async {
    final habit = (await api.listTasks(type: TaskType.TASK_TYPE_HABIT)).data!.tasks.first;

    final before = UserBox.ins.getUserPrefs();
    final reply = await api.completeTask(habit.id);
    expect(reply.isSuccess, isTrue);
    expect(reply.data!.task.isCompleted, isTrue);
    expect(reply.data!.task.completedAt.toInt(), greaterThan(0));
    expect(reply.data!.task.streak, greaterThanOrEqualTo(1));
    expect(reply.data!.task.lastStreakDate.toInt(), greaterThan(0));

    // Wallet & counters updated through the storage layer.
    final after = UserBox.ins.getUserPrefs();
    expect(after.currentGold.toInt(), greaterThan(before.currentGold.toInt()));
    expect(after.totalTasksCompleted.toInt(), before.totalTasksCompleted.toInt() + 1);
    expect(after.todayTasksCompleted.toInt(), before.todayTasksCompleted.toInt() + 1);
    if (before.firstTaskDate == Int64(0)) {
      expect(after.firstTaskDate.toInt(), greaterThan(0));
    }

    // Character gained EXP (15 base for easy, streak x1.0 at first completion).
    final char = CharacterBox.ins.getCharacter()!;
    expect(char.currentExp.toInt(), greaterThan(0));

    // Re-completing the same task is rejected.
    final again = await api.completeTask(habit.id);
    expect(again.isFailure, isTrue);

    // Unknown id.
    final missing = await api.completeTask('nope');
    expect(missing.isFailure, isTrue);
  });

  test('skip task: marked skipped + todo due date pushed to tomorrow', () async {
    final todo = (await api.listTasks(type: TaskType.TASK_TYPE_TODO)).data!.tasks.first;
    final originalDue = todo.dueDate.toInt();

    final reply = await api.skipTask(todo.id);
    expect(reply.isSuccess, isTrue);
    expect(reply.data!.task.isSkipped, isTrue);

    final skipped = (await api.listTasks(type: TaskType.TASK_TYPE_TODO)).data!.tasks.first;
    expect(skipped.dueDate.toInt(), greaterThan(originalDue));
    expect(
      DateTime.fromMillisecondsSinceEpoch(skipped.dueDate.toInt()).day,
      DateTime.now().add(const Duration(days: 1)).day,
    );
  });

  test('miss tasks (overdue settlement) → damage → death → revive', () async {
    // Two todos that were due YESTERDAY and never completed, hp penalty 60 each.
    final yesterday = DateTime.now().subtract(const Duration(days: 1)).millisecondsSinceEpoch;
    final ids = <String>[];
    for (var i = 0; i < 2; i++) {
      final reply = await api.createTask(
        Task(
          title: 'missed $i',
          type: TaskType.TASK_TYPE_TODO,
          difficulty: TaskDifficulty.TASK_DIFFICULTY_HARD,
          dueDate: Int64(yesterday),
          hpPenalty: 60,
        ),
      );
      ids.add(reply.data!.task.id);
    }

    // Simulate the next-day startup settlement (same logic as impl.init).
    final damage = TaskBox.ins.collectOverduePenalty();
    expect(damage, greaterThanOrEqualTo(120)); // 2 x 60 hpPenalty, at minimum
    var char = CharacterBox.ins.getCharacter()!;
    expect(char.isDead, isFalse);
    char = GameLogic.takeDamage(char, damage);
    CharacterBox.ins.updateCharacter(char);

    char = CharacterBox.ins.getCharacter()!;
    expect(char.currentHp, 0);
    expect(char.isDead, isTrue);
    expect(char.deathRecoveryUntil.toInt(), greaterThan(DateTime.now().millisecondsSinceEpoch));

    // Dead character cannot complete tasks.
    final habit = (await api.listTasks(type: TaskType.TASK_TYPE_HABIT)).data!.tasks.firstWhere((t) => !t.isCompleted);
    final deadComplete = await api.completeTask(habit.id);
    expect(deadComplete.isFailure, isTrue);

    // Revive before recovery time elapses does nothing.
    await api.reviveCharacter();
    expect(CharacterBox.ins.getCharacter()!.isDead, isTrue);

    // Simulate 30 minutes passing, then revive.
    final recoveryDone = (char.clone()..freeze()).rebuild(
      (c) => c..deathRecoveryUntil = Int64(DateTime.now().subtract(const Duration(minutes: 1)).millisecondsSinceEpoch),
    );
    CharacterBox.ins.updateCharacter(recoveryDone);
    await api.reviveCharacter();
    final revived = CharacterBox.ins.getCharacter()!;
    expect(revived.isDead, isFalse);
    expect(revived.currentHp, GameConstants.deathRecoveryHp);
  });

  test('earn gold → shop purchase → equip & unequip (item effect)', () async {
    // Grind gold: top the wallet up to exactly 600 with a custom-gold task.
    final preGold = (await api.getPrefs()).data!.prefs.currentGold.toInt();
    final goldTask = await api.createTask(
      Task(
        title: 'gold grind',
        type: TaskType.TASK_TYPE_HABIT,
        difficulty: TaskDifficulty.TASK_DIFFICULTY_HARD,
        customGoldReward: 600 - preGold,
      ),
    );
    final done = await api.completeTask(goldTask.data!.task.id);
    expect(done.isSuccess, isTrue);

    final prefs = UserBox.ins.getUserPrefs();
    expect(prefs.currentGold.toInt(), 600);

    // Shop catalog from config.yml.
    final catalog = await api.listShopItems();
    final sword = catalog.data!.items.firstWhere((i) => i.id == 'sword_flame');
    expect(sword.price.toInt(), 500);

    // Purchase succeeds, balance deducted.
    final buy = await api.purchaseItem('sword_flame', ShopCurrency.SHOP_CURRENCY_GOLD);
    expect(buy.isSuccess, isTrue);
    expect(buy.data!.balance.toInt(), prefs.currentGold.toInt() - 500);

    final owned = await api.listOwnedItems();
    expect(owned.data!.itemIds, contains('sword_flame'));

    // The 500-gold deduction must be persisted.
    final balance = (await api.getPrefs()).data!.prefs.currentGold.toInt();
    debugPrint('after sword purchase balance=$balance');
    expect(balance, 100);

    // Buying again fails (already owned); unknown/expensive fail too.
    expect((await api.purchaseItem('sword_flame', ShopCurrency.SHOP_CURRENCY_GOLD)).isFailure, isTrue);
    expect((await api.purchaseItem('nonexistent', ShopCurrency.SHOP_CURRENCY_GOLD)).isFailure, isTrue);
    expect((await api.purchaseItem('cloak_shadow', ShopCurrency.SHOP_CURRENCY_GOLD)).isFailure, isTrue); // 150 > 100

    // Equip owned item: character.equipment maps slot -> item id.
    final equip = await api.equipItem('sword_flame', EquipmentSlot.EQUIPMENT_SLOT_WEAPON);
    expect(equip.isSuccess, isTrue);
    var char = CharacterBox.ins.getCharacter()!;
    expect(char.equipment['weapon'], 'sword_flame');

    // Equipping an unowned item is rejected.
    expect((await api.equipItem('cloak_shadow', EquipmentSlot.EQUIPMENT_SLOT_ACCESSORY)).isFailure, isTrue);

    // Unequip (empty item id).
    final unequip = await api.equipItem('', EquipmentSlot.EQUIPMENT_SLOT_WEAPON);
    expect(unequip.isSuccess, isTrue);
    char = CharacterBox.ins.getCharacter()!;
    expect(char.equipment.containsKey('weapon'), isFalse);
  });

  test('achievements unlock and grant gems', () async {
    final before = await api.listAchievements();
    expect(before.isSuccess, isTrue);
    expect(before.data!.achievements.length, greaterThan(0));

    // Complete tasks until total_tasks >= 1 (first_task already satisfied) and
    // push the character past level 5 (level_5) using a big custom-EXP task.
    final gemsBefore = UserBox.ins.getUserPrefs().currentGems.toInt();
    final leveller = await api.createTask(
      Task(
        title: 'level rush',
        type: TaskType.TASK_TYPE_HABIT,
        difficulty: TaskDifficulty.TASK_DIFFICULTY_HARD,
        customExpReward: 600,
      ),
    );
    await api.completeTask(leveller.data!.task.id);
    final list = await api.listAchievements();
    final byId = {for (final a in list.data!.achievements) a.id: a};
    expect(byId['first_task']!.isUnlocked, isTrue);
    expect(byId['level_5']!.isUnlocked, isTrue);
    expect(byId['level_10']!.isUnlocked, isFalse);

    // Gem reward credited.
    expect(UserBox.ins.getUserPrefs().currentGems.toInt(), greaterThan(gemsBefore));
  });

  test('max level reached without overflow', () async {
    // Push a character to the cap in one giant EXP task.
    final big = await api.createTask(
      Task(
        title: 'to the top',
        type: TaskType.TASK_TYPE_HABIT,
        difficulty: TaskDifficulty.TASK_DIFFICULTY_HARD,
        customExpReward: 500000,
      ),
    );
    final before = CharacterBox.ins.getCharacter()!;
    debugPrint('before big: level=${before.level} exp=${before.currentExp} points=${before.availableStatPoints}');
    final reply = await api.completeTask(big.data!.task.id);
    expect(reply.isSuccess, isTrue);

    final char = CharacterBox.ins.getCharacter()!;
    debugPrint(
      'after big completion: level=${char.level} exp=${char.currentExp} points=${char.availableStatPoints}',
    );
    expect(char.level, GameConstants.maxLevel);
    final capExp = GameConstants.expForLevel(GameConstants.maxLevel);
    expect(char.currentExp.toInt(), capExp); // clamped, not overflowing
    expect(char.maxExp.toInt(), capExp);

    // Further completions keep level & EXP capped.
    final more = await api.createTask(
      Task(
        title: 'still capped',
        type: TaskType.TASK_TYPE_HABIT,
        difficulty: TaskDifficulty.TASK_DIFFICULTY_HARD,
        customExpReward: 500000,
      ),
    );
    await api.completeTask(more.data!.task.id);
    final again = CharacterBox.ins.getCharacter()!;
    expect(again.level, GameConstants.maxLevel);
    expect(again.currentExp.toInt(), capExp);
    final pointsAtCap = again.availableStatPoints.toInt();
    expect(pointsAtCap, greaterThan(0));

    // One more giant completion: level/EXP stay capped, no extra stat points.
    final encore = await api.createTask(
      Task(
        title: 'encore',
        type: TaskType.TASK_TYPE_HABIT,
        difficulty: TaskDifficulty.TASK_DIFFICULTY_HARD,
        customExpReward: 500000,
      ),
    );
    await api.completeTask(encore.data!.task.id);
    final finalChar = CharacterBox.ins.getCharacter()!;
    expect(finalChar.level, GameConstants.maxLevel);
    expect(finalChar.currentExp.toInt(), capExp);
    expect(finalChar.availableStatPoints.toInt(), pointsAtCap);
  });
}
