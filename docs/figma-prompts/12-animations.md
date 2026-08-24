# 动效系统 — Figma AI Prompt（双主题通用）

> 所有动效的缓动曲线、时长、触发条件。暗色/亮色主题使用完全相同的动效参数。

---

## 01 — 系统动效参数

```
EASING CURVES:
- Standard: cubic-bezier(0.2, 0.0, 0, 1.0) — Material Emphasized
- Bounce: cubic-bezier(0.68, -0.55, 0.265, 1.55) —奖励弹窗、✓ 弹入
- Spring: spring(damping: 0.7, stiffness: 150) — 图标弹性效果
- Linear: linear — 进度条填充
- Fade: ease-out 300ms — 淡入淡出

DURATIONS:
- Micro: 150ms — 按钮按下、开关切换
- Fast: 250ms — Tab 切换、页面 push/pop
- Normal: 300ms — 弹窗出现、底部表单滑入
- Emphasis: 400ms — 任务完成动效、HP 变化
- Transition: 600ms — 页面转场
- Celebration: 2000ms — 升级全屏动画

SCREEN SHAKE:
- HP damage: 400ms, amplitude 4px, decay ease-out
- Level up screen shake: 600ms, amplitude 8px, decay
```

## 02 — Splash 动效

```
ELEMENTS:
- Logo icon: fade-in 400ms + elastic scale-up (0.8 → 1.0, bounce curve 400ms)
- "HABIT FORGE" text: fade-in + slide-up 10px, 500ms, staggered 100ms after icon
- Subtitle: fade-in 400ms, staggered 200ms after title
- Progress bar: shimmer sweep, 1200ms loop, left-to-right gradient
- Particle background: slow float animation, 4000ms loop, random offsets
```

## 03 — Onboarding 动效（4步）

```
STEP TRANSITIONS:
- Page change: slide horizontal 300ms, fade 200ms
- Content elements: staggered fade-in + slide-up 8px, 400ms each
  Stagger delay: 80ms between elements

WELCOME STEP:
- 3D Character (placeholder): fade-in 600ms, subtle float bob (translateY 0→-4px, 2000ms loop)

CLASS STEP:
- Cards: staggered slide-in from bottom, 400ms each, 100ms stagger
- Selected card: border color transition 200ms, scale 1.0→1.02 on tap

HABIT STEP:
- Suggestion cards: staggered fade-in + slide-right 300ms, 80ms stagger

READY STEP:
- Gold star: scale 0→1.2→1.0 (bounce 600ms)
- Background gold glow: opacity 0→0.3 fade 800ms
- Button: pulse glow animation, 1500ms loop
```

## 04 — Home 动效

```
3D CHARACTER AREA (改为2D):
- 2D character: idle breath animation (scale 1.0→1.02, 3000ms loop, ease-in-out)
- Level badge: smooth EXP bar fill 400ms when value changes
- Double-tap to fullscreen: scale-up transition 300ms

STATS STRIP:
- HP bar: animated fill 400ms ease-out when value changes
  Damage: red flash overlay + screen shake 400ms + bar shrink animation
  Healing: green glow + bar expand 400ms
- Gold counter: number increment animation 300ms (scroll digits or fade new value)

TODAY'S QUESTS:
- Task tile appear: slide-up + fade 300ms
- Task complete (swipe):
  1. Green glow trail follows finger (150ms)
  2. Checkmark icon bounces in (300ms, bounce curve)
  3. Card shrinks scale 1.0→0.95→1.0 while fading out (400ms)
  4. If all tasks done: confetti particle burst (600ms)
- Task skip (swipe):
  1. Gray overlay follows finger (150ms)
  2. Card reduces opacity to 0.5 (300ms)
  3. Slide left slightly (200ms)

PULL TO REFRESH:
- Pull indicator: character stretch animation based on pull distance
- Refresh complete: bounce back 300ms

QUICK ACTION BUTTONS:
- Tap: scale 1.0→0.92→1.0 (spring 200ms)
```

## 05 — Quests 动效

```
TYPE TAB SWITCH:
- Content cross-fade: old list fade out 200ms, new list fade in 250ms
- Tab underline: slide transition 200ms

TAG FILTER:
- Active chip: background color transition 200ms
- Chip selection: slight scale bump 1.0→1.05→1.0 (200ms)

TASK LIST:
- Long press: card lifts (shadow expands, scale 1.0→1.02, 150ms)
- Edit/Delete bottom sheet: slide-up 300ms, background dim fade 200ms
- Task created: new card slides in from bottom, 300ms
- Task deleted: card slides out to left + fade, 250ms

FAB:
- Tap: rotate icon 45° (if opening create form), spring 300ms
- Enter: scale 0→1.0 (spring 400ms)

CREATE/EDIT FORM:
- Bottom sheet: slide up 300ms, ease-out
- Form fields: staggered fade-in 200ms each, 50ms stagger
- Type/difficulty pills: selection color transition 150ms
- Save button: loading spinner state transition 200ms
- Success: brief green check overlay, sheet slides down 250ms
```

## 06 — Character Panel 动效（2D版）

```
PANEL ENTRY:
- Scale-in from 0.95 + fade-in, 300ms
- Background overlay fade 200ms (dark overlay at 60%)

2D CHARACTER VIEWPORT:
- Character: idle breath animation (scale 1.0→1.02, 3000ms loop)
- Stats appear: numbered counters count up from 0 to value, 600ms each
- Animation toggle [Idle/Victory]: Victory = jump + spin, 800ms

STATS ALLOCATION:
- Allocate tap: +1 counter increments with number pop (scale 1.0→1.3→1.0, 300ms)
- Stat points badge: number decrement with brief red flash (200ms)
- If points reach 0: badge fades out 300ms

DEATH STATE:
- Overlay fade-in: red tint 0→40%, 500ms
- Countdown: smooth timer text update, 1000ms intervals
- Recovery complete: overlay fade-out 500ms, stats re-enable
```

## 07 — Forge / Shop 动效

```
GRID ENTRY:
- Item cards: staggered scale-in from 0.9, 300ms each, 60ms stagger
- Same on category switch

CATEGORY TAB:
- Tab underline slide 200ms
- Grid cross-fade: old grid fade out 200ms, new grid fade in 250ms

ITEM CARD TAP:
- Card slight scale-down 0.97 on touch-down, release scale back 1.0 (150ms)
- Detail sheet: slide-up 300ms

PURCHASE:
- Gold deduction: coin icon flies from item to gold header (400ms, arc trajectory)
- Gold counter: decrement animation 300ms
- Item card: success glow flash (gold border appears, 300ms)
- "Owned" badge: fade-in + scale-in 300ms

EQUIP:
- Item: slide from sheet/location to character equipment slot (500ms)
- Equipment slot: slot glow activation (purple border fade-in 300ms)
- If slot had previous item: old item slides out to inventory (300ms)

DAILY DEAL:
- Countdown: timer ticks smoothly, 1000ms intervals
- Expired: card fades out + new deal slides in, 400ms
```

## 08 — Profile 动效

```
PROFILE CARD:
- Avatar card: subtle breath animation on avatar icon (scale 1.0→1.03, 3000ms loop)
- Stats: counters animate on appear (count up from 0, 500ms)

ACHIEVEMENT UNLOCK:
- Just-unlocked tile: gold border fade-in + glow pulse (1000ms)
- Gem reward: 💎 icon flies to gem counter (500ms arc)
- Background: subtle sparkle particle burst (600ms)
- Locked → unlocked: grayscale to full color transition (500ms)

STATISTICS:
- Chart bars (if bar chart): animate height from 0 to value (600ms, ease-out)
- Stat cards: value count-up, 500ms
- Time period switch: data cross-fade 300ms

SETTINGS:
- Toggle switch: smooth thumb slide 200ms
- Reset confirm dialog: scale-in 300ms
- Data reset: brief loading spinner (if async), then fade to splash 400ms
```

## 09 — Reward & Toast 动效

```
REWARD POPUP (task complete):
- Entry: scale 0.5→1.05→1.0 (bounce 500ms)
- Background overlay: fade-in 200ms
- Check icon: scale 0→1.2→1.0 with rotation (spring 400ms)
- EXP/Gold numbers: count-up animation from 0, 400ms
  Each number digit scrolls or fades to new value
- Gold icon: coin spin animation 600ms
- Auto-dismiss: scale 1.0→0.8 + fade 200ms after 2s hold

LEVEL UP SEQUENCE (2000ms total):
  0ms: Full-screen gold radial gradient expands from center (500ms)
  500ms: Screen shake (600ms, 8px amplitude, decay)
  600ms: Character victory animation (jump + spin, 800ms) — use Lottie
  700ms: "LEVEL UP!" text slides up from bottom (bounce 400ms)
  900ms: Level number counts up quickly (300ms)
  1100ms: Stat points badge appears (scale bounce 300ms)
  1400ms: Gold/EXP reward numbers count up (400ms)
  2000ms: Auto-dismiss or tap to dismiss

TOAST (top notification):
- Entry: slide-down from -64px to 0px, 300ms
- Hold: 2500ms
- Exit: slide-up to -64px + fade, 250ms
- Types: success (green), warning (orange), error (red), info (purple)

HP DAMAGE FLASH:
- Screen edges flash red 200ms, immediate
- HP bar shakes horizontally (4px amplitude, 200ms, 3 oscillations)
- Character flash white (100ms)
- Red border pulses 3 times (500ms each pulse)
- Total: 400ms

HP DEATH:
- Red overlay fades in 0→50%, 800ms
- Character collapse animation (800ms)
- Recovery countdown appears (slide-up 300ms)
```

## 10 — Navigation & Page Transitions

```
TAB SWITCH (bottom nav):
- Content: fade 200ms + slight slide-up (4px), ease-out
- Tab icon: selected icon scale 1.0→1.1→1.0 (spring 300ms)
- Tab label: color transition 200ms

PAGE PUSH (GetX cupertino transition):
- New page: slide-in from right, 300ms, ease
- Previous page: slide-out to left, 300ms, fade 0.8
- Shadow on pushed page left edge

PAGE POP:
- Current page: slide-out to right, 250ms
- Previous page: slide-in from left, 250ms

MODAL (fullscreen, e.g. Character Panel):
- Entry: scale 0.95 + fade-in, 300ms
- Exit: scale 0.95 + fade-out, 250ms

BOTTOM SHEET:
- Entry: slide-up 300ms, ease-out
- Background dim: fade 200ms
- Drag handle: visual feedback on drag
- Dismiss: slide-down 250ms
```

## 11 — Lottie 动画规格（2D 替代 3D）

```
MVP 使用 Lottie 动画代替 O3D GLB 模型。
所有动画使用 Lottie JSON 格式，打包在 assets/animations/ 下。

必备动画清单：

1. character_idle.json
   - 角色待机呼吸动画
   - 循环播放
   - 时长: 3000ms
   - 动作: 轻微上下浮动 + 呼吸 (scale 1.0↔1.02)

2. character_victory.json
   - 角色升级庆祝动画
   - 播放一次
   - 时长: 800ms
   - 动作: 跳起 + 旋转 + 落地pose

3. character_hit.json
   - 角色受伤动画
   - 播放一次
   - 时长: 400ms
   - 动作: 闪白 + 后仰 + 恢复

4. character_death.json
   - 角色倒地动画
   - 播放一次
   - 时长: 800ms
   - 动作: 缓慢倒下 + 定格

5. confetti_burst.json
   - 任务全部完成时撒花
   - 播放一次
   - 时长: 600ms

6. coin_fly.json
   - 金币从物品飞向余额
   - 播放一次
   - 时长: 400ms
   - 弧形轨迹

7. level_up_aura.json
   - 升级金色光晕
   - 播放一次
   - 时长: 500ms
   - 从中心扩散

8. task_complete_glow.json
   - 任务完成绿色光晕
   - 播放一次
   - 时长: 300ms
   - 从左到右划过卡片

动画文件放置路径: assets/animations/
```
