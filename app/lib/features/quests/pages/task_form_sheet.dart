import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:habit_forge_app/core/constants/app_constants.dart';
import 'package:habit_forge_app/core/constants/game_constants.dart';
import 'package:habit_forge_app/core/theme/app_colors.dart';
import 'package:habit_forge_app/core/theme/app_theme.dart';
import 'package:habit_forge_app/features/quests/controllers/quests_controller.dart';
import 'package:habit_forge_app/models/task/task_model.dart';
import 'package:intl/intl.dart';

class TaskFormSheet extends StatefulWidget {
  final TaskModel? task;
  const TaskFormSheet({super.key, this.task});

  @override
  State<TaskFormSheet> createState() => _TaskFormSheetState();

  static void show(BuildContext context, {TaskModel? task}) {
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

class _TaskFormSheetState extends State<TaskFormSheet> {
  static const _weekdayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  late TextEditingController _titleCtrl;
  late TextEditingController _descCtrl;
  TaskType _type = TaskType.habit;
  String _difficulty = 'medium';
  List<String> _tags = [];
  DateTime? _dueDate;
  final _tagCtrl = TextEditingController();
  List<int> _repeatDays = [];
  String _priority = '';
  int _hpPenalty = 10;

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<QuestsController>();
    final padding = MediaQuery.of(context).viewInsets;
    final isEdit = widget.task != null;

    return Padding(
      padding: EdgeInsets.only(bottom: padding.bottom),
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
                isEdit ? 'Edit Quest' : 'New Quest',
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
                hintText: "What's your quest?",
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
                hintText: 'Description (optional)',
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
            if (_type == TaskType.daily) ..._buildDailyFields(),
            if (_type == TaskType.todo) ..._buildTodoFields(),
            SizedBox(height: 14.h),
            // Difficulty
            _buildSectionLabel('Difficulty'),
            SizedBox(height: 8.h),
            _difficultySelector(),
            SizedBox(height: 14.h),
            // Tags
            _buildSectionLabel('Tags'),
            SizedBox(height: 8.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: AppConstants.taskTags.map((tag) {
                final selected = _tags.contains(tag);
                return _pill(
                  active: selected,
                  activeBg: AppColors.primary,
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
            SizedBox(height: 16.h),
            // Reward preview
            _buildRewardRow(),
            SizedBox(height: 16.h),
            // Submit
            SizedBox(
              width: double.infinity,
              child: GestureDetector(
                onTap: () {
                  if (_titleCtrl.text.trim().isEmpty) return;
                  final now = DateTime.now();
                  final task = TaskModel(
                    id: widget.task?.id ?? '',
                    title: _titleCtrl.text.trim(),
                    description: _descCtrl.text.trim().isNotEmpty ? _descCtrl.text.trim() : null,
                    type: _type,
                    difficulty: _difficulty,
                    tags: _tags,
                    dueDate: _type == TaskType.todo ? _dueDate : null,
                    repeatDays: _type == TaskType.daily ? _repeatDays : [],
                    priority: _type == TaskType.todo ? _priority : '',
                    hpPenalty: _type == TaskType.daily ? _hpPenalty : 10,
                    createdAt: widget.task?.createdAt ?? now,
                    updatedAt: isEdit ? now : null,
                  );
                  if (isEdit) {
                    ctrl.updateTask(task);
                  } else {
                    ctrl.createTask(task);
                  }
                  Get.back();
                },
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 15.h),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    border: Border.all(color: AppColors.border, width: 2.5),
                    borderRadius: BorderRadius.circular(999),
                    boxShadow: const [BoxShadow(color: AppColors.primaryDark, offset: Offset(0, 4))],
                  ),
                  child: Center(
                    child: Text(
                      isEdit ? 'Save Changes' : 'Create Quest',
                      style: textStyleBold(fontSize: 16.sp, color: Colors.white),
                    ),
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
    _tagCtrl.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.task?.title ?? '');
    _descCtrl = TextEditingController(text: widget.task?.description ?? '');
    _type = widget.task?.type ?? TaskType.habit;
    _difficulty = widget.task?.difficulty ?? 'medium';
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
      _buildSectionLabel('Repeat on'),
      SizedBox(height: 8.h),
      Wrap(
        spacing: 6.w,
        runSpacing: 6.h,
        children: List.generate(7, (i) {
          final selected = _repeatDays.contains(i);
          return _pill(
            active: selected,
            activeBg: AppColors.primary,
            onTap: () => setState(() {
              if (selected) {
                _repeatDays.remove(i);
              } else {
                _repeatDays.add(i);
              }
            }),
            child: Text(
              _weekdayLabels[i],
              style: textStyleBold(
                fontSize: 12.sp,
                color: selected ? Colors.white : AppColors.textSecondary,
              ),
            ),
          );
        }),
      ),
      if (_repeatDays.isEmpty)
        Padding(
          padding: EdgeInsets.only(top: 4.h),
          child: Text(
            'Select at least one day',
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
        Text('Miss penalty: ', style: textStyleRegular(fontSize: 12.sp, color: AppColors.textMuted)),
        Text('-$_hpPenalty HP', style: textStyleBold(fontSize: 12.sp, color: AppColors.coralDark)),
      ],
    );
  }

  // ── Reward preview ──
  Widget _buildRewardRow() {
    final exp = GameConstants.baseExpReward(_difficulty);
    final gold = GameConstants.baseGoldReward(_difficulty);
    return Row(
      children: [
        Text('Reward', style: textStyleBold(fontSize: 13.sp, color: AppColors.textSecondary)),
        const Spacer(),
        _rewardChip(icon: Icons.bolt_rounded, text: '+$exp XP', bg: AppColors.goldLight),
        SizedBox(width: 8.w),
        _rewardChip(icon: Icons.star_rounded, text: '+$gold', bg: AppColors.goldLight),
      ],
    );
  }

  Widget _buildSectionLabel(String text) {
    return Text(text, style: textStyleBold(fontSize: 13.sp, color: AppColors.textSecondary));
  }

  // ── Todo-specific ──
  List<Widget> _buildTodoFields() {
    return [
      SizedBox(height: 14.h),
      _buildSectionLabel('Due Date & Priority'),
      SizedBox(height: 8.h),
      Row(
        children: [
          Expanded(
            flex: 3,
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
                      _dueDate != null ? DateFormat('MMM d, yyyy').format(_dueDate!) : 'Pick date',
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

  Color _diffColor(String d) {
    switch (d) {
      case 'easy':
        return AppColors.green;
      case 'medium':
        return AppColors.warning;
      case 'hard':
        return AppColors.coral;
      default:
        return AppColors.primary;
    }
  }

  // ── Difficulty pills ──
  Widget _difficultySelector() {
    return Row(
      children: ['easy', 'medium', 'hard'].map((d) {
        final active = _difficulty == d;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: _pill(
              active: active,
              activeBg: _diffColor(d),
              onTap: () => setState(() => _difficulty = d),
              child: Text(
                d[0].toUpperCase() + d.substring(1),
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
    final dt = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (dt != null) {
      setState(() => _dueDate = dt);
    }
  }

  // ── Common pill ──
  Widget _pill({
    required bool active,
    required Color activeBg,
    required VoidCallback onTap,
    required Widget child,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: active ? activeBg : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: active ? activeBg : AppColors.border, width: 2),
          boxShadow: active ? [BoxShadow(color: activeBg.withValues(alpha: 0.5), offset: const Offset(0, 3))] : null,
        ),
        child: Center(child: child),
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

  Widget _rewardChip({required IconData icon, required String text, required Color bg}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: AppColors.border, width: 1.5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14.w, color: AppColors.goldDark),
          SizedBox(width: 3.w),
          Text(text, style: textStyleBold(fontSize: 12.sp, color: AppColors.textPrimary)),
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
        children: TaskType.values.map((t) {
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
                  t.str,
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
