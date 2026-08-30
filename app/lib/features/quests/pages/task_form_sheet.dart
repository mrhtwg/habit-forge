import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:habit_forge_app/core/constants/app_constants.dart';
import 'package:habit_forge_app/core/constants/game_constants.dart';
import 'package:habit_forge_app/core/extensions/task_extensions.dart';
import 'package:habit_forge_app/core/i18n/lan_key.dart';
import 'package:habit_forge_app/core/network/network_interface.dart';
import 'package:habit_forge_app/core/theme/app_colors.dart';
import 'package:habit_forge_app/core/theme/app_theme.dart';
import 'package:habit_forge_app/features/quests/controllers/quests_controller.dart';
import 'package:habit_forge_app/generated/protos/shared/v1/shared.pbenum.dart';
import 'package:habit_forge_app/generated/protos/task/v1/task.pb.dart';
import 'package:habit_forge_app/widgets/pressable_button.dart';
import 'package:habit_forge_app/widgets/reward_chip.dart';
import 'package:habit_forge_app/widgets/toast_widget.dart';
import 'package:intl/intl.dart';

class TaskFormSheet extends StatefulWidget {
  final Task? task;
  const TaskFormSheet({super.key, this.task});

  @override
  State<TaskFormSheet> createState() => _TaskFormSheetState();

  static void show(BuildContext context, {Task? task}) {
    Get.bottomSheet(
      TaskFormSheet(task: task),
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
    );
  }
}

/// Theme-matched date picker: a month grid styled like the rest of the app
/// (cream field, ink borders, rounded chips) instead of the default Material
/// calendar. Pops with the picked [DateTime], or null if dismissed.
class _DatePickerSheet extends StatefulWidget {
  final DateTime? initial;

  const _DatePickerSheet({this.initial});

  @override
  State<_DatePickerSheet> createState() => _DatePickerSheetState();
}

class _DatePickerSheetState extends State<_DatePickerSheet> {
  static final _weekdayLabels = [
    LanKey.mon.tr,
    LanKey.tue.tr,
    LanKey.wed.tr,
    LanKey.thu.tr,
    LanKey.fri.tr,
    LanKey.sat.tr,
    LanKey.sun.tr,
  ];

  late final DateTime _today;
  late final DateTime _maxDate;
  late DateTime _month; // first day of the month currently shown
  DateTime? _selected;

  @override
  Widget build(BuildContext context) {
    final daysInMonth = DateTime(_month.year, _month.month + 1, 0).day;
    final leadingBlanks = DateTime(_month.year, _month.month, 1).weekday - 1; // Monday = 0

    final cells = <Widget>[
      for (var i = 0; i < leadingBlanks; i++) const SizedBox.shrink(),
      for (var day = 1; day <= daysInMonth; day++) _dayCell(DateTime(_month.year, _month.month, day)),
    ];

    return SingleChildScrollView(
      padding: EdgeInsets.all(20.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 44.w,
              height: 5.h,
              decoration: BoxDecoration(
                color: AppColors.textMuted,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
          SizedBox(height: 14.h),
          Text(
            LanKey.pickDate.tr,
            style: textStyleBlack(fontSize: 20.sp, color: AppColors.textPrimary),
          ),
          SizedBox(height: 12.h),
          // Month navigation
          Row(
            children: [
              _navButton(icon: Icons.chevron_left_rounded, onTap: () => _changeMonth(-1)),
              Expanded(
                child: Text(
                  DateFormat('MMMM yyyy').format(_month),
                  textAlign: TextAlign.center,
                  style: textStyleBold(fontSize: 15.sp, color: AppColors.textPrimary),
                ),
              ),
              _navButton(icon: Icons.chevron_right_rounded, onTap: () => _changeMonth(1)),
            ],
          ),
          SizedBox(height: 10.h),
          // Weekday header
          Row(
            children: List.generate(7, (i) {
              return Expanded(
                child: Center(
                  child: Text(
                    _weekdayLabels[i],
                    style: textStyleBold(fontSize: 11.sp, color: AppColors.textMuted),
                  ),
                ),
              );
            }),
          ),
          SizedBox(height: 6.h),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 7,
            mainAxisSpacing: 6.h,
            crossAxisSpacing: 4.w,
            children: cells,
          ),
          SizedBox(height: 16.h),
          // Confirm
          SizedBox(
            width: double.infinity,
            child: GestureDetector(
              onTap: () => Navigator.pop(context, _selected),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 14.h),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  border: Border.all(color: AppColors.border, width: 2.5),
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: const [BoxShadow(color: AppColors.primaryDark, offset: Offset(0, 4))],
                ),
                child: Center(
                  child: Text(
                    LanKey.done.tr,
                    style: textStyleBold(fontSize: 16.sp, color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 8.h),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _today = DateUtils.dateOnly(DateTime.now());
    _maxDate = _today.add(const Duration(days: 365));
    final initial = widget.initial == null ? null : DateUtils.dateOnly(widget.initial!);
    _selected = initial;
    _month = DateTime(initial?.year ?? _today.year, initial?.month ?? _today.month);
  }

  void _changeMonth(int delta) {
    setState(() => _month = DateTime(_month.year, _month.month + delta));
  }

  Widget _dayCell(DateTime date) {
    final selectable = _isSelectable(date);
    final isSelected = _selected != null && date == _selected;
    final isToday = date == _today;

    return GestureDetector(
      onTap: selectable ? () => Navigator.pop(context, date) : null,
      child: Center(
        child: Container(
          width: 38.w,
          height: 38.w,
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary
                : isToday
                    ? AppColors.primaryLight.withValues(alpha: 0.15)
                    : Colors.transparent,
            shape: BoxShape.circle,
            border: Border.all(
              color: isSelected
                  ? AppColors.primaryDark
                  : isToday
                      ? AppColors.primary
                      : Colors.transparent,
              width: 2,
            ),
            boxShadow: isSelected
                ? [BoxShadow(color: AppColors.primaryDark.withValues(alpha: 0.4), offset: const Offset(0, 3))]
                : null,
          ),
          child: Center(
            child: Text(
              '${date.day}',
              style: textStyleBold(
                fontSize: 13.sp,
                color: !selectable && !isSelected
                    ? AppColors.textMuted
                    : isSelected
                        ? Colors.white
                        : AppColors.textPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  bool _isSelectable(DateTime date) => !date.isBefore(_today) && !date.isAfter(_maxDate);

  Widget _navButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: const Color(0xFFF3E7CE),
          border: Border.all(color: AppColors.border, width: 2),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Icon(icon, size: 18.w, color: AppColors.textPrimary),
      ),
    );
  }
}

class _TaskFormSheetState extends State<TaskFormSheet> {
  static final _weekdayLabels = [
    LanKey.mon.tr,
    LanKey.tue.tr,
    LanKey.wed.tr,
    LanKey.thu.tr,
    LanKey.fri.tr,
    LanKey.sat.tr,
    LanKey.sun.tr,
  ];
  late TextEditingController _titleCtrl;
  late TextEditingController _descCtrl;
  TaskType _type = TaskType.TASK_TYPE_HABIT;
  TaskDifficulty _difficulty = TaskDifficulty.TASK_DIFFICULTY_MEDIUM;
  List<String> _tags = [];
  bool _tagsExpanded = false;
  Int64? _dueDate;
  List<int> _repeatDays = [];
  String _priority = '';
  int _hpPenalty = 10;

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<QuestsController>();
    final padding = MediaQuery.of(context).viewInsets;
    final isEdit = widget.task != null;

    return Padding(
      padding: EdgeInsets.only(bottom: padding.top),
      child: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 44.w,
                height: 5.h,
                decoration: BoxDecoration(
                  color: AppColors.textMuted,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            SizedBox(height: 14.h),
            Center(
              child: Text(
                isEdit ? LanKey.editQuest.tr : LanKey.newQuest.tr,
                style: textStyleBlack(fontSize: 22.sp, color: AppColors.textPrimary),
              ),
            ),
            SizedBox(height: 16.h),
            // Type pills
            _typeSelector(),
            SizedBox(height: 14.h),
            // Title
            TextField(
              controller: _titleCtrl,
              style: textStyleRegular(fontSize: 15.sp),
              decoration: InputDecoration(
                hintText: LanKey.whatsYourQuest.tr,
                hintStyle: textStyleRegular(fontSize: 14.sp, color: AppColors.textMuted),
                prefixIcon: Icon(Icons.checklist_rounded, size: 20, color: AppColors.textSecondary),
                filled: true,
                fillColor: const Color(0xFFFBF5EA),
                contentPadding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 14.w),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppColors.border, width: 2),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppColors.border, width: 2),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppColors.primary, width: 2),
                ),
              ),
            ),
            SizedBox(height: 12.h),
            // Description
            TextField(
              controller: _descCtrl,
              style: textStyleRegular(fontSize: 14.sp),
              decoration: InputDecoration(
                hintText: LanKey.descriptionOptional.tr,
                hintStyle: textStyleRegular(fontSize: 13.sp, color: AppColors.textMuted),
                filled: true,
                fillColor: const Color(0xFFFBF5EA),
                contentPadding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 14.w),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.border, width: 1.5),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.border, width: 1.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.primary, width: 2),
                ),
              ),
            ),
            // Type-specific fields
            if (_type == TaskType.TASK_TYPE_DAILY) ..._buildDailyFields(),
            if (_type == TaskType.TASK_TYPE_TODO) ..._buildTodoFields(),
            SizedBox(height: 14.h),
            // Difficulty
            _buildSectionLabel(LanKey.difficulty.tr),
            SizedBox(height: 8.h),
            _difficultySelector(),
            SizedBox(height: 14.h),
            // Tags
            _buildSectionLabel(LanKey.tags.tr),
            SizedBox(height: 8.h),
            _buildTagField(),
            // Animated expand/collapse: the options fade in/out while the
            // height eases, matching the rotating chevron in the field.
            ClipRect(
              child: AnimatedSize(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOutCubic,
                alignment: Alignment.topCenter,
                child: _tagsExpanded
                    ? Padding(
                        padding: EdgeInsets.only(top: 8.h),
                        child: _buildTagOptions(),
                      )
                    : const SizedBox(width: double.infinity),
              ),
            ),
            SizedBox(height: 16.h),
            // Reward preview
            _buildRewardRow(),
            SizedBox(height: 16.h),
            // Submit
            SizedBox(
              width: double.infinity,
              child: PressableButton(
                borderWidth: 2.5,
                padding: EdgeInsets.symmetric(vertical: 15.h),
                onTap: () {
                  if (_titleCtrl.text.trim().isEmpty) {
                    Toast.warning(LanKey.titleRequired.tr);
                    return;
                  }

                  // Only the caller-known fields travel to the storage layer;
                  // ids, timestamps and rewards are owned by the implementation.
                  final params = CreateTaskParams(
                    title: _titleCtrl.text.trim(),
                    description: _descCtrl.text.trim().isNotEmpty ? _descCtrl.text.trim() : null,
                    type: _type,
                    difficulty: _difficulty,
                    tags: _tags,
                    dueDate: _type == TaskType.TASK_TYPE_TODO ? _dueDate : null,
                    repeatDays: _type == TaskType.TASK_TYPE_DAILY ? _repeatDays : [],
                    priority: _type == TaskType.TASK_TYPE_TODO ? _priority : '',
                    hpPenalty: _type == TaskType.TASK_TYPE_DAILY ? _hpPenalty : 10,
                  );
                  if (isEdit) {
                    ctrl.updateTask(widget.task!.id, params);
                  } else {
                    ctrl.createTask(params);
                  }
                  Get.back();
                },
                child: Center(
                  child: Text(
                    isEdit ? LanKey.saveChanges.tr : LanKey.createQuest.tr,
                    style: textStyleBold(fontSize: 16.sp, color: Colors.white),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.task?.title ?? '');
    _descCtrl = TextEditingController(text: widget.task?.description ?? '');
    _type = widget.task?.type ?? TaskType.TASK_TYPE_HABIT;
    _difficulty = widget.task?.difficulty ?? TaskDifficulty.TASK_DIFFICULTY_MEDIUM;
    _tags = widget.task?.tags ?? [];
    _dueDate = widget.task?.dueDate;
    _repeatDays = List.from(widget.task?.repeatDays ?? []);
    _priority = widget.task?.priority ?? '';
    _hpPenalty = widget.task?.hpPenalty ?? 10;
  }

  // ── Daily-specific ──
  List<Widget> _buildDailyFields() {
    return [
      SizedBox(height: 14.h),
      _buildSectionLabel(LanKey.repeatOn.tr),
      SizedBox(height: 8.h),
      _buildRepeatDayRow(),
      if (_repeatDays.isEmpty)
        Padding(
          padding: EdgeInsets.only(top: 4.h),
          child: Text(
            LanKey.selectAtLeastOneDay.tr,
            style: textStyleRegular(fontSize: 11.sp, color: AppColors.warning.withValues(alpha: 0.7)),
          ),
        ),
      SizedBox(height: 12.h),
      _buildHpPenaltyRow(),
    ];
  }

  Widget _buildHpPenaltyRow() {
    return Row(
      children: [
        Icon(Icons.favorite_border_rounded, size: 16.w, color: AppColors.coral),
        SizedBox(width: 6.w),
        Text(LanKey.missPenalty.tr, style: textStyleRegular(fontSize: 12.sp, color: AppColors.textMuted)),
        Text('-$_hpPenalty HP', style: textStyleBold(fontSize: 12.sp, color: AppColors.coralDark)),
      ],
    );
  }

  // Compact single-row day picker: 7 equal segments, no wrapping.
  Widget _buildRepeatDayRow() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF3E7CE),
        border: Border.all(color: AppColors.border, width: 2),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        children: List.generate(7, (i) {
          final selected = _repeatDays.contains(i);
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() {
                if (selected) {
                  _repeatDays.remove(i);
                } else {
                  _repeatDays.add(i);
                }
              }),
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 2.w),
                padding: EdgeInsets.symmetric(vertical: 9.h),
                decoration: BoxDecoration(
                  color: selected ? AppColors.green : Colors.transparent,
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: selected
                      ? [BoxShadow(color: AppColors.greenDark.withValues(alpha: 0.4), offset: const Offset(0, 3))]
                      : null,
                ),
                child: Text(
                  _weekdayLabels[i],
                  textAlign: TextAlign.center,
                  style: textStyleBold(
                    fontSize: 11.sp,
                    color: selected ? Colors.white : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ── Reward preview ──
  Widget _buildRewardRow() {
    final exp = GameConstants.baseExpReward(_difficulty);
    final gold = GameConstants.baseGoldReward(_difficulty);
    return Row(
      children: [
        Text(LanKey.reward.tr, style: textStyleBold(fontSize: 13.sp, color: AppColors.textSecondary)),
        const Spacer(),
        RewardChip(
          sysMaterial: SysMaterial.SYSMATERIAL_EXP,
          value: exp,
        ),
        SizedBox(width: 8.w),
        RewardChip(
          sysMaterial: SysMaterial.SYSMATERIAL_GOLD,
          value: gold,
        ),
      ],
    );
  }

  Widget _buildSectionLabel(String text) {
    return Text(text, style: textStyleBold(fontSize: 13.sp, color: AppColors.textSecondary));
  }

  // ── Tags ──
  // Single field row: selected tags render as removable chips inside; tapping
  // expands an inline multi-select below so the sheet itself stays compact.
  Widget _buildTagField() {
    return GestureDetector(
      onTap: () => setState(() => _tagsExpanded = !_tagsExpanded),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: const Color(0xFFFBF5EA),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _tags.isNotEmpty ? AppColors.green : AppColors.border,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.sell_rounded, size: 16.w, color: AppColors.textSecondary),
            SizedBox(width: 8.w),
            Expanded(
              child: _tags.isEmpty
                  ? Text(
                      LanKey.addTags.tr,
                      style: textStyleRegular(fontSize: 13.sp, color: AppColors.textMuted),
                    )
                  : Wrap(
                      spacing: 6.w,
                      runSpacing: 6.h,
                      children: _tags.map(_selectedTagChip).toList(),
                    ),
            ),
            if (_tags.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(right: 6.w),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: AppColors.green,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '${_tags.length}',
                    style: textStyleBold(fontSize: 11.sp, color: Colors.white),
                  ),
                ),
              ),
            AnimatedRotation(
              turns: _tagsExpanded ? 0.5 : 0,
              duration: const Duration(milliseconds: 200),
              child: Icon(Icons.expand_more_rounded, size: 22.w, color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }

  // Inline tag multi-select, revealed below the field when expanded.
  // Compact capsules flow in a Wrap: tags are short (<= 10 letters), so the
  // pills shrink-wrap their text and wrap naturally into a staggered layout.
  Widget _buildTagOptions() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: const Color(0xFFFBF5EA),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 1.5),
      ),
      child: Wrap(
        spacing: 6.w,
        runSpacing: 6.h,
        children: AppConstants.taskTags.map((tag) {
          final selected = _tags.contains(tag);
          return _pill(
            active: selected,
            activeBg: AppColors.green,
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
            onTap: () => setState(() {
              if (selected) {
                _tags.remove(tag);
              } else {
                _tags.add(tag);
              }
            }),
            child: Text(
              '# $tag',
              style: textStyleBold(
                fontSize: 12.sp,
                color: selected ? Colors.white : AppColors.textSecondary,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Todo-specific ──
  List<Widget> _buildTodoFields() {
    return [
      SizedBox(height: 14.h),
      _buildSectionLabel(LanKey.dueDateAndPriority.tr),
      SizedBox(height: 8.h),
      Row(
        children: [
          Expanded(
            flex: 2,
            child: GestureDetector(
              onTap: _pickDate,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFFBF5EA),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: _dueDate != null ? AppColors.primary : AppColors.border,
                    width: 2,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today_rounded, size: 15.w, color: AppColors.textSecondary),
                    SizedBox(width: 8.w),
                    Text(
                      _dueDate != null
                          ? DateFormat('MMM d, yyyy').format((DateTime.fromMillisecondsSinceEpoch(_dueDate!.toInt())))
                          : LanKey.pickDate.tr,
                      style: textStyleRegular(
                        fontSize: 12.sp,
                        color: _dueDate != null ? AppColors.textPrimary : AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            flex: 2,
            child: Row(
              children: ['P1', 'P2', 'P3'].map((p) {
                final selected = _priority == p;
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 3.w),
                    child: _pill(
                      active: selected,
                      activeBg: _priorityColor(p),
                      onTap: () => setState(() => _priority = selected ? '' : p),
                      child: Text(
                        p,
                        textAlign: TextAlign.center,
                        style: textStyleBold(
                          fontSize: 11.sp,
                          color: selected ? Colors.white : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
      SizedBox(height: 12.h),
      _buildHpPenaltyRow(),
    ];
  }

  Color _diffColor(TaskDifficulty d) {
    switch (d) {
      case TaskDifficulty.TASK_DIFFICULTY_EASY:
        return AppColors.green;
      case TaskDifficulty.TASK_DIFFICULTY_MEDIUM:
        return AppColors.warning;
      case TaskDifficulty.TASK_DIFFICULTY_HARD:
        return AppColors.coral;
      default:
        return AppColors.primary;
    }
  }

  // ── Difficulty pills ──
  Widget _difficultySelector() {
    return Row(
      children:
          TaskDifficulty.values.where((td) => td.value != TaskDifficulty.TASK_DIFFICULTY_UNSPECIFIED.value).map((d) {
        final active = _difficulty == d;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: _pill(
              active: active,
              activeBg: _diffColor(d),
              onTap: () => setState(() => _difficulty = d),
              child: Text(
                d.difficultyName,
                textAlign: TextAlign.center,
                style: textStyleBold(
                  fontSize: 13.sp,
                  color: active ? Colors.white : AppColors.textSecondary,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Future<void> _pickDate() async {
    final dt = await showModalBottomSheet<DateTime>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      builder: (_) => _DatePickerSheet(
        initial: _dueDate != null ? DateTime(_dueDate!.toInt()) : null,
      ),
    );
    if (dt != null) {
      setState(() => _dueDate = Int64(dt.millisecondsSinceEpoch));
    }
  }

  // ── Common pill ──
  Widget _pill({
    required bool active,
    required Color activeBg,
    required VoidCallback onTap,
    required Widget child,
    EdgeInsetsGeometry padding = const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: active ? activeBg : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: active ? activeBg : AppColors.border, width: 2),
          boxShadow: active ? [BoxShadow(color: activeBg.withValues(alpha: 0.5), offset: const Offset(0, 3))] : null,
        ),
        // No Center wrapper: in a Wrap the pill must shrink-wrap its child
        // (Center would expand to fill the remaining width -> one tag per row).
        child: child,
      ),
    );
  }

  Color _priorityColor(String p) {
    switch (p) {
      case 'P1':
        return AppColors.coral;
      case 'P2':
        return AppColors.warning;
      case 'P3':
        return AppColors.info;
      default:
        return AppColors.textMuted;
    }
  }

  Widget _selectedTagChip(String tag) {
    return Container(
      padding: EdgeInsets.only(left: 10.w, right: 4.w),
      decoration: BoxDecoration(
        color: AppColors.green,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('# $tag', style: textStyleBold(fontSize: 11.sp, color: Colors.white)),
          GestureDetector(
            onTap: () => setState(() => _tags.remove(tag)),
            child: Padding(
              padding: EdgeInsets.all(4.w),
              child: Icon(Icons.close_rounded, size: 13.w, color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }

  // ── Type pills ──
  Widget _typeSelector() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF3E7CE),
        border: Border.all(color: AppColors.border, width: 2),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        children: TaskType.values.where((task) => task.value != TaskType.TASK_TYPE_UNSPECIFIED.value).map((t) {
          final active = _type == t;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _type = t),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 9.h),
                decoration: BoxDecoration(
                  color: active ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  t.taskName,
                  textAlign: TextAlign.center,
                  style: textStyleBold(
                    fontSize: 13.sp,
                    color: active ? Colors.white : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
