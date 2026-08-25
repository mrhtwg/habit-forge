import 'package:get/get.dart';

/// Translation keys for the app (see en_us.dart / zh_cn.dart).
/// Usage: `LanKey.done.tr`, `LanKey.priorityLabel.trParams({'value': x})`.
enum LanKey {
  done, // 'Done'
  skip, // 'Skip'
  postpone, // 'Postpone'
  cancel, // 'Cancel'
  delete, // 'Delete'
  deleteTask, // 'Delete Task'
  habit, // 'Habit'
  daily, // 'Daily'
  todo, // 'Todo'
  habitBadge, // 'HABIT'
  dailyBadge, // 'DAILY'
  todoBadge, // 'TODO'
  confirm, // 'Confirm'
  difficultyEasy, // 'difficulty_easy'
  difficultyMedium, // 'difficulty_medium'
  difficultyHard, // 'difficulty_hard'
  forge, // 'Forge'
  owned, // 'OWNED'
  appearance, // 'Appearance'
  equipment, // 'Equipment'
  equip, // 'Equip'
  buy, // 'Buy'
  common, // 'common'
  rare, // 'rare'
  epic, // 'epic'
  legendary, // 'legendary'
  viewCharacter, // 'View Character'
  achievements, // 'Achievements'
  statistics, // 'Statistics'
  settings, // 'Settings'
  adventurer, // 'Adventurer'
  rate, // 'Rate'
  streak, // 'Streak'
  tasks, // 'Tasks'
  firstBlood, // 'First Blood'
  completeYourFirstTask, // 'Complete your first task'
  hotStreak, // 'Hot Streak'
  sevenDayStreak, // '7-day streak'
  unstoppable, // 'Unstoppable'
  thirtyDayStreak, // '30-day streak'
  growingStrong, // 'Growing Strong'
  reachLevel5, // 'Reach level 5'
  doubleDigits, // 'Double Digits'
  reachLevel10, // 'Reach level 10'
  gettingThingsDone, // 'Getting Things Done'
  complete50Tasks, // 'Complete 50 tasks'
  taskMaster, // 'Task Master'
  complete100Tasks, // 'Complete 100 tasks'
  shopaholic, // 'Shopaholic'
  buyFirstShopItem, // 'Buy first shop item'
  backFromTheDead, // 'Back from the Dead'
  dieAndRecover, // 'Die and recover'
  addQuest, // '+ Add'
  goodMorningAdventurer, // 'Good morning, adventurer!'
  aFreshDayAwaits, // 'A fresh day awaits'
  noQuestsToday, // 'No quests for today!'
  dayClearAddFirstQuest, // 'Your day is clear. Add your first quest to start earning XP and gold.'
  createQuest, // 'Create Quest'
  home, // 'Home'
  quests, // 'Quests'
  profile, // 'Profile'
  noQuestsHereYet, // 'No quests here yet'
  tapToForgeQuest, // 'Tap + to forge your first quest.'
  all, // 'All'
  todoFilter, // 'ToDo'
  postponeToTomorrow, // 'Postpone to tomorrow'
  mon, // 'Mon'
  tue, // 'Tue'
  wed, // 'Wed'
  thu, // 'Thu'
  fri, // 'Fri'
  sat, // 'Sat'
  sun, // 'Sun'
  editQuest, // 'Edit Quest'
  newQuest, // 'New Quest'
  descriptionOptional, // 'Description (optional)'
  difficulty, // 'Difficulty'
  tags, // 'Tags'
  saveChanges, // 'Save Changes'
  repeatOn, // 'Repeat on'
  selectAtLeastOneDay, // 'Select at least one day'
  missPenalty, // 'Miss penalty: '
  reward, // 'Reward'
  dueDateAndPriority, // 'Due Date & Priority'
  pickDate, // 'Pick date'
  xp, // 'XP'
  hp, // 'HP'
  attributes, // 'Attributes'
  statStr, // 'STR'
  statInt, // 'INT'
  statAgi, // 'AGI'
  statDef, // 'DEF'
  statVit, // 'VIT'
  statLuk, // 'LUK'
  noItemsForSlot, // 'No items for this slot. Visit the Forge!'
  noneUnequip, // 'None (unequip)'
  weapon, // 'Weapon'
  helmet, // 'Helmet'
  armor, // 'Armor'
  trinket, // 'Trinket'
  tasksDONE, // 'TASKS DONE'
  completion, // 'COMPLETION'
  daySTREAK, // 'DAY STREAK'
  bestYet, // '🔥 best yet'
  totalXP, // 'TOTAL XP'
  questsCompleted, // 'Quests completed'
  last7Days, // 'last 7 days'
  streaks, // 'Streaks'
  noStreaksYet, // 'No streaks yet — keep going!'
  week, // 'Week'
  month, // 'Month'
  achievementUnlocked, // 'Achievement unlocked!'
  questComplete, // 'Quest complete!'
  newAchievement, // 'New achievement'
  niceWork, // 'Nice work!'
  continueLabel, // 'Continue'
  yourHeroReached, // 'Your hero reached'
  awesome, // 'Awesome!'
  next, // 'Next'
  getStarted, // 'Get Started'
  enterTheRealm, // 'Enter the Realm'
  chooseYourHero, // 'Choose your hero'
  classesGrowDifferently, // 'Each class grows a little differently'
  warrior, // 'Warrior'
  braveAndTough, // 'Brave and tough. Big HP, bigger heart.'
  mage, // 'Mage'
  cleverAndCurious, // 'Clever and curious. Master of streaks.'
  ranger, // 'Ranger'
  swiftAndSteady, // 'Swift and steady. Built for daily streaks.'
  forgeFirstHabit, // 'Forge your first habit'
  smallQuestsBigRewards, // 'Small quests lead to big rewards'
  drink8GlassesOfWater, // 'Drink 8 glasses of water'
  readFor30Minutes, // 'Read for 30 minutes'
  morningExercise, // 'Morning exercise'
  completeQuestsEarnXpAndGold, // 'Complete quests, earn XP and gold, and watch your hero grow every day.'
  yourHeroClass, // 'Your hero class'
  noHabitYet, // 'No habit yet'
  yourFirstHabit, // 'Your first habit'
  yourLifeIsNaGrandAdventure, // 'Your life is\\na grand adventure'
  finishTasksEarnXpAndGold, // 'Finish real tasks, earn XP and gold, and watch your hero grow stronger every day.'
  yourHabitsYourLegend, // 'Your Habits. Your Legend.'
  continueWithGoogle, // 'Continue with Google'
  continueWithEmail, // 'Continue with Email'
  byContinuingYouAgreeToOurTermsOfServiceNandPrivacyPolicy, // 'By continuing, you agree to our Terms of Service\\nand Privacy Policy.'
  createAccount, // 'Create Account'
  signIn, // 'Sign In'
  startYourAdventure, // 'Start your adventure'
  welcomeBackAdventurer, // 'Welcome back, adventurer'
  email, // 'Email'
  enterYourEmail, // 'Enter your email'
  pleaseEnterYourEmail, // 'Please enter your email'
  invalidEmailAddress, // 'Invalid email address'
  password, // 'Password'
  enterYourPassword, // 'Enter your password'
  pleaseEnterYourPassword, // 'Please enter your password'
  passwordMinLength, // 'Password must be at least 8 characters'
  confirmPassword, // 'Confirm Password'
  reEnterYourPassword, // 'Re-enter your password'
  pleaseConfirmYourPassword, // 'Please confirm your password'
  passwordsDoNotMatch, // 'Passwords do not match'
  alreadyHaveAccount, // 'Already have an account?'
  signUp, // 'Sign Up'
  appleLoginFailed, // 'Apple Login Failed'
  loginFailed, // 'Login Failed'
  googleLoginFailed, // 'Google Login Failed'
  registrationFailed, // 'Registration Failed'
  account, // 'Account'
  signedIn, // 'Signed in'
  guest, // 'Guest'
  signOut, // 'Sign Out'
  signOutConfirm, // 'Are you sure you want to sign out?'
  preferences, // 'Preferences'
  sound, // 'Sound'
  haptic, // 'Haptic'
  language, // 'Language'
  followSystem, // 'Follow System'
  data, // 'Data'
  resetAllData, // 'Reset All Data'
  resetGame, // 'Reset Game'
  resetAllConfirm, // 'This will delete all your data. Are you sure?'
  reset, // 'Reset'
  priorityLabel, // 'priority_label'
  deleteConfirm, // 'delete_confirm'
  forgeOff, // 'forge_off'
  notEnoughGold, // 'not_enough_gold'
  needMoreGold, // 'need_more_gold'
  profileLevelClass, // 'profile_level_class'
  questsReadyCount, // 'quests_ready_count'
  levelLabel, // 'level_label'
  questCountToday, // 'quest_count_today'
  levelClassLabel, // 'level_class_label'
  pointsRemaining, // 'points_remaining'
  selectSlot, // 'select_slot'
  levelHeroLabel, // 'level_hero_label'
  xpGained, // 'xp_gained'
  gemsGained, // 'gems_gained'
  goldGained, // 'gold_gained'
  levelValue, // 'level_value'
  chooseClass, // 'choose_class'
  stepOf, // 'step_of'
  // Double-quoted keys (missed by the generator) added manually:
  todaysQuests, // "Today's Quests"
  whatsYourQuest, // "What's your quest?"
  youreAllSetAdventurer, // "You're all set,\nadventurer!"
  lifeIsGrandAdventure, // 'Your life is\na grand adventure'
  termsAndPrivacy, // 'By continuing, you agree to our Terms of Service\nand Privacy Policy.'
  noAccountYet, // "Don't have an account?"
  ;

  /// Resolves this key for the active locale (GetX translations).
  String get tr => name.tr;

  /// Resolves this key with named parameters (e.g. {n}, {value}).
  String trParams([Map<String, String> params = const {}]) => name.trParams(params);

  // ── Dynamic lookups for data-driven values ──
  /// Achievement description key by definition id.
  static LanKey achievementDescription(String id) => switch (id) {
        'first_task' => completeYourFirstTask,
        'streak_7' => sevenDayStreak,
        'streak_30' => thirtyDayStreak,
        'level_5' => reachLevel5,
        'level_10' => reachLevel10,
        'tasks_50' => complete50Tasks,
        'tasks_100' => complete100Tasks,
        'first_purchase' => buyFirstShopItem,
        _ => dieAndRecover,
      };

  /// Achievement title key by definition id.
  static LanKey achievementTitle(String id) => switch (id) {
        'first_task' => firstBlood,
        'streak_7' => hotStreak,
        'streak_30' => unstoppable,
        'level_5' => growingStrong,
        'level_10' => doubleDigits,
        'tasks_50' => gettingThingsDone,
        'tasks_100' => taskMaster,
        'first_purchase' => shopaholic,
        _ => backFromTheDead,
      };

  /// Character class label by raw name (warrior | mage | ranger).
  static LanKey characterClass(String name) => switch (name) {
        'warrior' => warrior,
        'mage' => mage,
        _ => ranger,
      };

  /// Difficulty label by raw value (easy | medium | hard).
  static LanKey difficultyFor(String value) => switch (value) {
        'easy' => difficultyEasy,
        'medium' => difficultyMedium,
        _ => difficultyHard,
      };

  /// Task type label by raw name (habit | daily | todo).
  static LanKey taskType(String type) => switch (type) {
        'habit' => habit,
        'daily' => daily,
        _ => todo,
      };
}
