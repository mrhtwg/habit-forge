# HabitForge APP — 一次性完整设计提示词

> 目标: 一次 Figma AI 调用生成全部屏幕 + 双主题 + 组件 + 弹窗 + Toast + 状态变体。
> 画布: iPhone 15 Pro (393×852)，使用 Auto Layout，8px 基准间距。
> 风格: 暗黑 RPG × 现代移动端，霓虹紫品牌色。

---

## 一、设计系统（两个主题）

### 暗色主题
```
COLOR STYLES:
- scaffold: #0D0D1A, surface: #1A1A2E, elevated: #252540, border: #3D3D5C
- textPrimary: #FFFFFF, textSecondary: #B8B8D4, textMuted: #6B6B8A
- primary: #6C5CE7, primaryLight: #A78BFA, primaryDark: #4C3FBF
- gold: #FFD700, green: #00E676, red: #FF5252
- success: #4CAF50, warning: #FF9800, error: #F44336, info: #2196F3
```

### 亮色主题（Variant）
```
COLOR STYLES:
- scaffold: #F5F5FA, surface: #FFFFFF, elevated: #F0F0F8, border: #E0E0EB
- textPrimary: #1A1A2E, textSecondary: #6B6B8A, textMuted: #9E9EB8
- primary: #6C5CE7（不变）, primaryBg: #EDE9FE
- gold: #D4A800, green: #00B368, red: #D32F2F
- successGreenBg: #E8F8F0, warningBg: #FFF3E0, redBg: #FFEBEE, goldBg: #FFF8E1
```

### 字体 SYSTEM
```
TEXT STYLES:
- displayLarge: Cinzel Bold 32px, displayMedium: Cinzel Bold 28px, displaySmall: Cinzel Bold 24px
- headline: Inter SemiBold 20px, title: Inter SemiBold 18px, subtitle: Inter Medium 16px
- body: Inter Regular 14px, caption: Inter Regular 12px, label: Inter Medium 10px
- number: JetBrains Mono Regular 16px
```

### 间距 & 阴影
```
Spacing: 4/8/16/24/32/48/64. Card radius 12, button radius 8, chip radius 20, sheet radius 16, dialog radius 24.
Shadow dark: card 0 4px 12px rgba(0,0,0,0.3), elevated 0 8px 32px rgba(0,0,0,0.4).
Shadow light: card 0 2px 8px rgba(26,26,46,0.08), elevated 0 4px 16px rgba(26,26,46,0.12).
Glow: gold 0 0 20px rgba(255,215,0,0.4), green 0 0 20px rgba(0,230,118,0.3), red 0 0 20px rgba(255,82,82,0.4), purple 0 0 20px rgba(108,92,231,0.3).
```

---

## 二、组件库（Components — 每个做 Dark/Light 两个 Variant）

### BottomNav
```
4 tabs: Home | Quests | Forge | Profile. 64px height. Top border 0.5px.
Dark: bg #1A1A2E, border #3D3D5C, active #6C5CE7, inactive #6B6B8A.
Light: bg #FFFFFF, border #E0E0EB, active #6C5CE7, inactive #9E9EB8.
Icon 24px + label 10px Inter Medium stacked.
```

### TaskTile（2 variants: 普通任务 / 正负向习惯）
```
=== Variant 1 — 普通任务 (Daily/Todo) ===
72px height, 16px padding, 12px radius. Dark: bg #1A1A2E. Light: bg #FFFFFF + shadow.
Left: circle checkbox 24x24 (empty gray 2px border / filled green #00E676 + white check).
12px gap → title column: title Inter Regular 14px (completed: strikethrough + muted color).
Below title: difficulty dots (● easy green / ●● medium orange / ●●● hard red) + 🔥 streak 7d+ gold 11px.
Right: "+15 EXP" gold Inter 11px.
Swipe left reveal: green #00E676@30% + white ✓ icon. Swipe right reveal: orange #FF9800@30% + ← icon.

=== Variant 2 — 正负向习惯 (Habit) ===
Same card layout. No completion checkbox. Instead:
Left side: two circular buttons stacked vertically.
  [+]: green #00E676 outline circle 28px with white + (positive = gain EXP+gold)
  [−]: red #FF5252 outline circle 28px with white − (negative = lose HP)
  Both buttons always visible. Each tap triggers its own action.
Center: habit title + 🔥streak. Title NOT strikethrough (habits never "complete").
Right: current EXP value if last action was positive.
Swipe behaviors disabled for habit variant.
```

### StatBar
```
Column layout. Label row: "HP" 11px muted + "85/100" 11px secondary spaced apart.
Progress bar: 10px height, pill shape 20px radius.
Track: dark #3D3D5C / light #E0E0EB. Fill: green HP #00E676, gold EXP #FFD700, red damage #FF5252.
```

### EmptyState
```
Vertically centered. Icon 64px muted color. 16px gap. Message Inter Regular 14px secondary centered.
Optional: purple action button (#6C5CE7) below.
```

### ConfirmDialog
```
AlertDialog: 12px radius. Dark bg #252540 / Light bg #FFFFFF. Gold border 1px for reward dialogs.
Title: Inter SemiBold 18px. Message: Inter Regular 14px.
Cancel: TextButton muted. Confirm: TextButton purple (or red for destructive actions like Reset).
```

### Shimmer
```
Rounded rectangle 12px radius. Gradient sweep: dark #252540→#3D3D5C→#252540 / light #F0F0F8→#E0E0EB→#F0F0F8.
1200ms animation loop. Configurable width/height.
```

---

## 三、屏幕清单（Generate all frames below）

### 1. Splash（1 Frame）
```
Full screen, dark gradient bg #0D0D1A→#1A1A2E with subtle floating particles.
Center: purple bolt icon 80px with soft glow + "HABIT FORGE" Cinzel Bold 32px white tracking 2px + "Forge Your Legend" Inter Regular 14px #B8B8D4.
Bottom: thin purple loading bar 120x4px rounded with shimmer animation.
Hide status bar. Duration hint 1.5-2s.
```

### 2. Onboarding（4 Frames）

**Frame 1 — Welcome:**
```
Purple particle bg. Upper area: 3D character placeholder (center person icon 80px purple glow).
"Welcome, Adventurer" Cinzel Bold 28px white. "Turn your goals into an epic quest" Inter 16px #B8B8D4.
"Get Started" full-width purple button #6C5CE7 56px height 8px radius white Inter SemiBold 16px.
"Skip" text link Inter 14px #6B6B8A. 4 dot indicators, first active purple rest #3D3D5C.
```

**Frame 2 — Choose Class:**
```
"Choose Your Class" Inter SemiBold 20px white centered.
3 vertical selection cards 80px height, 12px radius, 16px padding, row layout (icon 40px purple + title + subtitle).
SELECTED: purple border 2px + #6C5CE7@20% bg. UNSELECTED: #3D3D5C border.
Card 1: shield + "Warrior" + "Strength & Defense". Card 2: sparkle + "Mage" + "Intelligence & Luck". Card 3: crosshair + "Ranger" + "Agility & Precision".
"Confirm" purple full-width button. "Skip" link. 4 dots 2nd active.
```

**Frame 3 — First Habit:**
```
"Create Your First Habit" Inter SemiBold 20px white.
3 suggestion cards 56px height, #1A1A2E bg, 12px radius: "Drink 8 glasses of water" + purple + icon | "Read for 30 minutes" + purple + icon | "Morning exercise" + purple + icon.
"I'll add later" link #6B6B8A centered. 4 dots 3rd active.
```

**Frame 4 — Ready:**
```
Gold accent glow bg. Gold star icon 80px #FFD700. "You're Ready!" Cinzel Bold 28px white. "Your legend begins now" Inter 16px #B8B8D4.
"Enter the Realm" purple-to-gold gradient button full-width with gold glow shadow. 4 dots all filled.
```

### 3. Home Tab（1 Frame + 5 overlays）
```
App bar: "HABIT FORGE" Cinzel Bold 18px left + bell icon + gear icon 24px #B8B8D4 right.
Character area 35% height: Lottie animation placeholder (person icon 80px). Bottom overlay: level badge "Lv.12 Warrior" + EXP bar purple 6px rounded.
Stats strip 16px padding: HP StatBar green (#FF5252 when <30%) + "🪙 1,250" JetBrains Mono 16px gold.
"Today's Quests" header + "+ Add" purple right.
Task list: 3-4 TaskTile items scrollable.
Quick actions row: 🛒 📊 🏆 3 compact icon+label #B8B8D4.
Bottom nav: Home active purple.

Variant — Empty: check icon 64px + "No quests for today!" + "Create" button.
Variant — Dead: red overlay 40%, "DEAD" badge, character death pose, recovery countdown "30:00" timer, stats grayed out, task interaction blocked.
Variant — Low HP (<30%): red pulsing border on HP area, character hit pose.
```

### 4. Quests Tab（1 Frame + 1 bottom sheet + 1 menu）
```
Type tabs: "Habits" | "Dailys" | "ToDos" equal width, active purple underline 2px + purple text, inactive gray text.
Tag filter row: horizontal scroll chips 32px height. "All"+"Health"+"Work"+"Learn"+"Personal". Active purple pill #6C5CE7 white text. Inactive #252540 bg #B8B8D4 text pill 20px radius.
Task list with TaskTile items. Long press menu: Edit/Delete bottom sheet.
FAB: purple #6C5CE7 56px white + icon, positioned bottom-right above nav.

Variant — Empty: "No habits yet" + "Create One" purple button.
Variant — Filtered Empty: "No quests match this tag".

Bottom Sheet — Create/Edit Task:
Sheet bg #252540, 16px top radius, centered drag handle 40x4px gray.
"New Task" / "Edit Task" Inter SemiBold 20px white.
Title input: #1A1A2E bg, 12px radius, placeholder "What do you want to do?".
Type pills: Habit | Daily | Todo. Selected purple fill. Unselected dark.
Difficulty pills: Easy green #00E676 | Medium orange #FF9800 | Hard red #FF5252. Selected color fill.
Priority (shown for Todo): P1(High) red | P2(Medium) orange | P3(Low) gray. Selected pill fill.
Due date (shown for Todo): date picker row with calendar icon + "Jul 20, 2026" text. Optional, can be empty.
Schedule (shown for Daily): day chips M/T/W/T/F/S/S. Selected purple, unselected dark.
Tags (optional expandable): chip input.
Custom Rewards (optional expandable): EXP input, Gold input, HP penalty input.
"Create" full-width purple button 48px height.

Long Press Menu (bottom sheet):
"Edit" icon + text. "Delete" icon + red text.
Tap Delete → opens ConfirmDialog "Delete this task?" with Cancel + Delete(red).
```

### 5. Character Panel（1 Frame, fullscreen modal + 2 variants）
```
Top bar: back arrow 24px white left + "Lv.12 Warrior" Inter SemiBold 18px white center + spacer.
2D character viewport 60% height: Lottie animation placeholder (person icon), animation toggle pills [Idle][Victory] bottom-right (#252540 bg, active purple border).
NOTE: Character animation is FIXED regardless of equipped items. Equipment only changes slot icons below.

Stats card (#1A1A2E, 12px radius, 16px padding): "Stats" header + gold points badge (if >0). 3x2 grid cells (#252540, 8px radius):
  STR: 18 [🡅] | INT: 14 [🡅] | AGI: 16 [🡅]
  DEF: 12 [🡅] | VIT: 10 [🡅] | LUK: 8  [🡅]
  Label uppercase 3-letter #B8B8D4 12px. Value JetBrains Mono 14px white. + button purple (only if points available).
Equipment: "Equipment" header. 4 slots 48x48 in a row: Weapon | Helmet | Armor | Accessory. 
  EMPTY: dotted border #6B6B8A + gray item icon. 
  EQUIPPED: solid purple border + item icon colored. Slot background glows subtle purple.
  Tap slot with owned items → bottom sheet selector: list of owned items for that slot type + "None" option to unequip.
  Item selected from sheet → slot icon updates immediately, character animation UNCHANGED (MVP constraint).
Unequip: long press equipped slot → tooltip "Unequip?" → tap confirm → slot returns to empty state.
```

Variant — Dead: red 40% overlay, "Recovering..." countdown, stats grayed, no interaction.
Variant — Level Up: gold glow background, victory animation playing, stat points badge glowing.
```

### 6. Forge / Shop Tab（1 Frame + 1 detail sheet + 1 banner）
```
Gold header: "🪙 1,250" JetBrains Mono 16px gold, right aligned.
Category tabs: "Appearance" | "Equipment". Active purple underline.
2-column grid 12px gap, 16px padding. Each card ~168x220px, #1A1A2E, 12px radius.
  Upper (60%): #252540 bg, shield icon 48px in rarity color (common #6B6B8A / rare #2196F3 / epic #6C5CE7).
  Lower (40%): item name Inter 12px white 1-line + price "🪙 500" gold / "OWNED" gold badge.
  Owned card: gold border 1px #FFD700.

Daily Special Banner: horizontal card above grid. Gold border. "✨ DAILY SPECIAL — 40% OFF" gold text. Item name + strikethrough original price + countdown timer "23:59:42" JetBrains Mono 12px. Animated sparkle accent.

Item Detail Sheet: drag handle, item icon 64px rarity color, name Inter SemiBold 20px, desc Inter 14px #B8B8D4, "EPIC" rarity badge in rarity color. "Equip" purple button full-width 48px (if owned) / "Buy 🪙 500" gold button black text (if not owned).
Insufficient gold variant: Buy button shows "🪙 Need 200 more" in disabled red (#FF5252) state. Triggers Toast "Not enough gold! Complete more tasks." See Toast section.

Variant — Empty: "No items in this category" icon + message.
```

### 7. Profile Tab + 3 Subpages（4 Frames total）

**Frame 1 — Profile:**
```
Avatar card: 64x64 icon #252540 bg + "Lv.12 Warrior" Inter SemiBold 18px + "🪙 1,250  💎 45" Inter 14px #B8B8D4.
Gem icon 💎 in gold #FFD700, count in JetBrains Mono 14px white (gems earned from achievement unlocks only).
Stats card: "Tasks: 127" | "Rate: 85%" | "Streak: 23d" — values #FFFFFF bold 14px, labels #B8B8D4 12px.
Quick links (4 cards 56px): 👤 View Character | 🏆 Achievements | 📊 Statistics | ⚙️ Settings — icon 24px purple, title 14px white, chevron #6B6B8A.
```

**Frame 2 — Achievements:**
```
App bar "Achievements" Inter SemiBold 18px.
2-column grid 12px gap. Tile 170x136px, 12px radius.
UNLOCKED: gold border, gold trophy icon 32px, title white 13px bold, "💎 5" gem badge.
LOCKED: #252540 bg, lock icon 32px #6B6B8A, "???" title #6B6B8A, semi-transparent.

9 achievement tiles: First Blood, Hot Streak(7d), Unstoppable(30d), Growing Strong(lvl5), Double Digits(lvl10), Getting Things Done(50 tasks), Task Master(100 tasks), Shopaholic(1st purchase), Back from the Dead(die+recover).
```

**Frame 3 — Statistics:**
```
App bar "Statistics". Time dimension toggle: [Week] [Month] [All] pills, active purple underline.
Overview row: "Tasks 127" + "Rate 85% ↑12%" + "Best Streak 23d" — each card value bold 24px white + label 12px #B8B8D4. ↑12% in green (#00E676) indicating week-over-week change.
Bar chart: 7 bars (week) or 30 bars (month) showing daily completed count. Bars #6C5CE7 purple gradient fill. Y-axis labels #6B6B8A 10px. Active/hovered bar highlighted gold.
Streak leaderboard: top 5 tasks by streak. Each row: task name + 🔥 + streak count.
Completed task list: title Inter 14px white + date Inter 12px #6B6B8A, filtered by time dimension.
```

**Frame 4 — Settings:**
```
"Account" card: "Local Player" + "Cloud sync coming soon".
"Preferences" card: Sound toggle SwitchListTile purple + Haptic toggle SwitchListTile purple.
"Data" card: "Reset All Data" red icon + red text. Tap opens ConfirmDialog.
```

### 8. Reward Popup（1 Frame, centered overlay dialog）
```
Card: width 280px, #252540 bg, 24px radius, 32px padding, gold border 1px #FFD700. Semi-transparent black overlay behind.

Task Complete variant: green check icon 64px #00E676. "Task Complete!" Inter SemiBold 20px white. "+30 EXP +10 🪙" gold 18px bold side by side. Auto-dismiss 2s.
Interaction behind popup blocked (barrierDismissible, bottom layer frozen).

Level Up variant: gold sparkle icon 64px #FFD700. "LEVEL UP!" Cinzel Bold 24px gold. Level number "12" Cinzel Bold 32px gold. "+50 EXP +20 Gold" reward line. Full-screen gold radial glow behind.

Achievement Unlock variant: gold trophy 64px #FFD700. Achievement name + "💎 5 Reward!". Gem icon flies from popup to gem counter on profile (arc animation 500ms). Subtle gold border pulse.
Full-screen unlock celebration: gold sparkle background burst (400ms) behind popup. Interaction behind popup blocked until auto-dismiss 2s or tap to close.
```

### 9. Toast（1 Frame, top slide-down overlay）
```
Top bar slide-down from -64px to 0, width full, 56px height, rounded bottom corners 8px.

4 variants:
- SUCCESS: green #00E676 bg + white check icon + white message.
- WARNING: orange #FF9800 bg + white warning icon + white message.
- ERROR: red #FF5252 bg + white error icon + white message.
- INFO: purple #6C5CE7 bg + white info icon + white message.

Icon 20px left + message Inter Regular 14px middle + dismiss X button right (optional).
Auto-dismiss 2.5s, slide-up exit animation 250ms.
```

---

## 四、交互连线（Figma Prototype）

```
Connect frames with these interactions:

Splash → Onboarding Step 1 (after 2s delay, Smart Animate 300ms)
Onboarding Step 1 → Step 2 (tap "Get Started", Smart Animate slide left 300ms)
Step 2 → Step 3 (tap "Confirm", Smart Animate slide left 300ms)
Step 3 → Step 4 (tap suggestion or "I'll add later", Smart Animate slide left 300ms)
Step 4 → Home Tab (tap "Enter the Realm", Smart Animate fade 300ms)
Any step → Home Tab (tap "Skip", Smart Animate fade 200ms)

Home → Quests/Forge/Profile (tap bottom nav tab, Smart Animate cross-fade 250ms)
Home → Character Panel (double-tap character area, Smart Animate scale 300ms)
Home → Reward Popup (overlay appear after task complete, Smart Animate scale bounce 500ms)
Home → HP Damage Flash (overlay, 400ms duration, auto-dismiss)
Home → Toast (overlay, slide down 300ms, auto-dismiss 2.5s)

Quests → Create/Edit Sheet (tap FAB, Smart Animate slide up 300ms)
Quests → Long Press Menu (long press task tile, Smart Animate slide up 250ms)
Quests → Reward Popup (after swipe complete, same as Home)

Character Panel → Back (tap back arrow, Smart Animate scale fade 250ms)

Forge → Item Detail Sheet (tap item card, Smart Animate slide up 300ms)

Profile → Achievements/Statistics/Settings (tap quick link, Smart Animate slide right 300ms)
Settings → ConfirmDialog (tap "Reset All Data", overlay scale 300ms)
```

---

## 五、动效规格（标注在 Frame 注释中）

```
FRAME NAME FORMAT: "01_Splash [fade-in 400ms, particles 4000ms loop]"

System parameters:
- Standard ease: cubic-bezier(0.2, 0.0, 0, 1.0)
- Bounce: cubic-bezier(0.68, -0.55, 0.265, 1.55)
- Linear for progress bars
- Fade ease-out 300ms for overlays

Key animation specs:
- Tab switch: cross-fade 250ms
- Page push: slide right 300ms ease
- Bottom sheet: slide up 300ms ease-out
- Task complete: green glow trail 150ms → check bounce 300ms → card shrink fade 400ms
- Task skip: gray overlay 150ms → opacity 0.5 300ms → slide left 200ms
- Reward popup: scale 0.5→1.05→1.0 bounce 500ms, auto-dismiss after 2000ms hold
- Level up sequence: gold glow expand 500ms → screen shake 600ms → "LEVEL UP!" slide-up bounce 400ms → level count 300ms → stat badge appear 300ms → total 2000ms
- HP damage: edges flash red 200ms + HP bar shake 4px 3 oscillations 400ms
- Death: red overlay fade-in 800ms, character collapse, recovery countdown slide-up 300ms
- Purchase: gold coin fly arc 400ms, item card success glow 300ms, "Owned" badge scale-in 300ms
- Achievement unlock: gold border glow pulse 1000ms, 💎 fly to counter 500ms arc
- Toast: slide-down 300ms, hold 2500ms, slide-up 250ms
- Shimmer: gradient sweep left-right 1200ms loop
- Page dots: slide transition 200ms

Lottie animation files to create (assets/animations/):
- character_idle.json (loop, 3000ms, breath float)
- character_victory.json (once, 800ms, jump+spin)
- character_hit.json (once, 400ms, flash+recoil)
- character_death.json (once, 800ms, collapse)
- confetti_burst.json (once, 600ms)
- coin_fly.json (once, 400ms, arc)
- level_up_aura.json (once, 500ms, center expand)
- task_complete_glow.json (once, 300ms, left-to-right sweep)
```

---

## 六、交付规范

```
1. 所有颜色定义为 Figma Color Styles（暗色组 + 亮色组各一套）
2. 所有文本定义为 Figma Text Styles（12 种）
3. 组件库的每个 element 定义为 Component（BottomNav / TaskTile / StatBar / EmptyState / ConfirmDialog / Shimmer / Toast）
4. 每个 Component 做 2 个 Variant: Dark / Light，只换颜色 Style
5. 屏幕 Frame 使用 Auto Layout，间距 8px 倍数
6. Reward Popup、Toast、HP Damage Flash、ConfirmDialog 定义为 Overlay Component
7. 每个 Frame / Overlay 标注 Lottie 占位区域 (eg. "Lottie: character_idle.json")
8. 导出: 切图使用 SVG，标注需标明颜色值、字号、间距
9. Reference: 固定底部导航、浮动按钮、IndexedStack 页面切换
```
