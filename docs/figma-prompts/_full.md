# Design System — Figma AI Prompt

```
Create a dark RPG mobile app design system for iPhone 15 Pro (393x852).

COLORS:
- Page background: #0D0D1A
- Card surface: #1A1A2E
- Elevated surface: #252540
- Borders: #3D3D5C
- Text primary: #FFFFFF
- Text secondary: #B8B8D4
- Text muted: #6B6B8A
- Primary action: #6C5CE7 (purple)
- Gold / Currency: #FFD700
- Green / Success: #00E676
- Red / Damage: #FF5252
- Warning: #FF9800

TYPOGRAPHY (Google Fonts):
- Display: Cinzel Bold 32/28/24
- Headline: Inter SemiBold 20
- Title: Inter SemiBold 18
- Subtitle: Inter Medium 16
- Body: Inter Regular 14
- Caption: Inter Regular 12
- Number: JetBrains Mono Regular 16

SPACING: 8px base. Screen padding 16px.
RADIUS: Cards 12px, Buttons 8px, Chips 20px, Sheet 16px.
SHADOWS: Card 0 4px 12px black 30%, gold glow 0 0 20px rgba(255,215,0,0.4).

Define all colors and text styles as Figma Styles for reuse.
```# Reusable Components — Figma AI Prompt

## Bottom Navigation Bar
```
4-tab nav bar, 64px height, #1A1A2E bg, top border 0.5px #3D3D5C.
Each tab: icon 24px + label 12px stacked.
Active: purple (#6C5CE7). Inactive: gray (#6B6B8A).
Tabs: Home, Quests, Forge, Profile. Label: Inter Medium 10px.
```

## Task Tile
```
Card: #1A1A2E, 72px height, 12px radius, 16px padding.
Left: circle checkbox 24x24 (empty:#6B6B8A border / filled:#00E676+white check).
12px gap → Title column:
  Title: Inter 14px white (completed: strikethrough #6B6B8A)
  Below: difficulty dots ●/●●/●●● colored 10px + 🔥 streak fire (if ≥7d)
Right (non-habit): "+15 EXP" Inter 11px #FFD700
Swipe left: green #00E676 at 30% + ✓ icon
Swipe right: orange #FF9800 at 30% + ← icon
```

## Stat Bar
```
Label row: "HP"(11px,#6B6B8A) + "85/100"(11px,#B8B8D4) spaced apart.
Progress bar: 10px height, full width, pill 20px radius.
  Background: #3D3D5C. Fill: green(#00E676) or red(#FF5252) or gold(#FFD700).
  Animation: 400ms easeOut tween.
```

## Empty State
```
Vertically centered column.
Icon 64px #6B6B8A, 16px gap, message Inter 14px #B8B8D4 centered.
Optional: purple action button below 16px gap.
```

## Shimmer Loading
```
Rounded rectangle (12px radius), gradient sweep #252540 → #3D3D5C → #252540.
1200ms animation loop. Width 100%, height configurable.
```

## Confirmation Dialog
```
AlertDialog: #252540 bg, 12px radius.
Title: Inter SemiBold 18px white.
Message: Inter Regular 14px #B8B8D4.
Cancel: TextButton gray. Confirm: TextButton purple(or red for destructive).
```
# Splash Screen — Figma AI Prompt

```
Full-screen splash, 393x852, dark gradient #0D0D1A → #1A1A2E.
Subtle floating particle effect background.

Center vertically:
- Large glowing purple anvil/hammer icon, 80px, with soft glow
- "HABIT FORGE" title — Cinzel Bold 32px, white, letter-spacing 2px
- "Forge Your Legend" subtitle — Inter Regular 14px, #B8B8D4

Bottom:
- Thin progress bar, 120x4px, purple (#6C5CE7), rounded
- Subtle shimmer animation on the bar

Duration hint: 1.5-2 seconds.
```# Onboarding (4 Steps) — Figma AI Prompt

## Step 1: Welcome
```
Full-screen, 393x852, purple particle background.
- Upper 60%: floating 3D character silhouette with purple glow outline (placeholder)
- "Welcome, Adventurer" — Cinzel Bold 28px, white, centered
- "Turn your goals into an epic quest" — Inter Regular 16px, #B8B8D4, centered
- Bottom: full-width purple button "Get Started" (#6C5CE7, 56px height, 8px radius, white text 16px)
- Below button: "Skip" text link, Inter 14px, #6B6B8A
- 4 dot page indicators, first active purple, rest gray
```

## Step 2: Choose Class
```
Full-screen, 393x852.
- "Choose Your Class" — Inter SemiBold 20px, white, centered
- 3 vertical selection cards, 80px height each:

  1. Warrior: shield icon (40px, purple) + "Warrior" + "Strength & Defense"
  2. Mage: sparkle icon (40px, purple) + "Mage" + "Intelligence & Luck"
  3. Ranger: crosshair icon (40px, purple) + "Ranger" + "Agility & Precision"

  Card: #1A1A2E, 12px radius, 16px padding, row layout with icon + text.
  SELECTED: purple border 2px, #6C5CE7 at 20% background.
  UNSELECTED: #3D3D5C border.

- "Confirm" full-width purple button, "Skip" text link below.
- 4 dots, second active.
```

## Step 3: First Habit
```
Full-screen, 393x852.
- "Create Your First Habit" — Inter SemiBold 20px, white
- 3 suggestion cards (56px height, #1A1A2E, 12px radius):
  "Drink 8 glasses of water" + purple + icon
  "Read for 30 minutes" + purple + icon
  "Morning exercise" + purple + icon
- "I'll add later" text link, #6B6B8A, centered
- 4 dots, third active.
```

## Step 4: Ready
```
Full-screen, 393x852, gold accent glow background.
- Large gold star icon (Icons.auto_awesome) 80px, #FFD700
- "You're Ready!" — Cinzel Bold 28px, white
- "Your legend begins now" — Inter Regular 16px, #B8B8D4
- "Enter the Realm" button — full-width, purple-to-gold gradient, 56px height, gold glow shadow
- 4 dots, all filled (completed).
```
# Home Tab — Figma AI Prompt

```
Home screen, 393x852, 4-tab bottom nav visible.

APP BAR:
- Left: "HABIT FORGE" text — Cinzel Bold 18px, white
- Right: bell icon + gear icon, 24px, #B8B8D4

3D CHARACTER AREA (35% screen height):
- Full-width, shows 3D character with idle animation, auto-rotate
- Touch: drag rotate, pinch zoom, double-tap for fullscreen
- Bottom overlay: level badge "Lv.12 Warrior" + EXP progress bar (6px, purple #6C5CE7)

STATS STRIP (16px padding):
- HP Bar: "HP" label + "85/100" value, green bar (#00E676), 10px height
  When HP < 30% → red (#FF5252) with pulsing glow
- Spacer
- Gold: "🪙 1,250" — JetBrains Mono 16px, #FFD700

"TODAY'S QUESTS" SECTION:
- Header: "Today's Quests" left (Inter SemiBold 16px) + "+ Add" right (purple)

TASK LIST (scrollable):
Each task tile: 72px high, #1A1A2E, 12px radius, 16px padding
- [Circle checkbox empty/green] + 12px gap + Title (Inter 14px, white)
  Completed: strikethrough + #6B6B8A
- Below title: difficulty dots (●/●●/●●● colored) + streak fire icon (if ≥7d)
- Right: "+15 EXP" in #FFD700, 11px
- Swipe left → green reveal + ✓ | Swipe right → orange reveal

EMPTY STATE (no tasks):
- Large check icon 64px, #6B6B8A
- "No quests for today!" — Inter 14px, #B8B8D4
- "Create" purple button

QUICK ACTION ROW:
🛒 Shop | 📊 Stats | 🏆 Achievements (3 compact icon+label items)

HP LOW STATE (<30%): red pulsing border, character hit pose
DEATH STATE: red overlay, "DEAD" badge, recovery countdown timer

BOTTOM NAV: 4 tabs, 64px height, #1A1A2E
Home(active purple) | Quests | Forge | Profile
```
# Quests Tab — Figma AI Prompt

```
Quests screen, 393x852, bottom nav visible.

TYPE TAB BAR (no background):
- 3 segments: "Habits" | "Dailys" | "ToDos"
- Active: purple text + 2px purple underline
- Inactive: #6B6B8A text, no underline

TAG FILTER ROW:
- Horizontal scroll chips, 32px height
- "All" (default active) + "Health" + "Work" + "Learn" + "Personal" + "Fitness"
- Active: #6C5CE7 fill + white text, pill shape 20px radius
- Inactive: #252540 fill + #B8B8D4 text

TASK LIST:
Same task tiles as Home screen (72px, swipe left=complete, right=skip)
Long press → bottom sheet: [Edit icon + "Edit"] [Delete icon + "Delete"]

FAB: Bottom-right, purple #6C5CE7, 56px, white "+" icon

CREATE/EDIT BOTTOM SHEET (#252540, 16px top radius):
- Drag handle pill (40x4px, gray, centered)
- "New Task" (Inter SemiBold 20px)
- Title input: #1A1A2E, 12px radius
- Type pills: Habit | Daily | Todo (purple when selected)
- Difficulty pills: Easy(green) | Medium(orange) | Hard(red)
- Schedule (for Daily): M T W T F S S day chips + time picker
- Tags: chip input (optional expandable)
- Custom Rewards: EXP, Gold, HP penalty (optional expandable)
- "Create" full-width purple button 48px

EMPTY: "No habits yet" + "Create One" button
FILTERED EMPTY: "No quests match this tag"
```
# Character Panel — Figma AI Prompt

```
Full-screen modal, 393x852. No bottom nav.

TOP BAR:
- Back arrow left | "Lv.12 Warrior" center (Inter SemiBold 18px) | spacer right

3D VIEWPORT (60% height):
- Full-width character display, idle animation
- Drag to rotate 360°, pinch zoom
- Bottom-right: [Idle] [Victory] animation toggle pills (#252540 bg)
- Active pill: purple border

STATS CARD (#1A1A2E, 12px radius, 16px padding):
- Header: "Stats" (Inter SemiBold 16px) + stat points badge (gold if available)
- 3x2 stats grid:

  | STR: 18  [+ if points available] | INT: 14 [+] | AGI: 16 [+] |
  | DEF: 12 [+] | VIT: 10 [+] | LUK: 8  [+] |

  Each cell: #252540, 8px radius, label uppercase 3-letter (#B8B8D4 12px)
  value JetBrains Mono 14px white, + button purple (only when points >0)

EQUIPMENT SECTION (compact):
- "Equipment" header
- 4 circles (48x48): Weapon | Helmet | Armor | Accessory
- Empty: dotted border + icon gray
- Equipped: purple border + filled icon
- Tap → item selection bottom sheet

DEATH STATE: red 40% overlay, "Recovering..." countdown, grayed stats
```
# Forge / Shop Tab — Figma AI Prompt

```
Shop screen, 393x852, bottom nav visible.

GOLD HEADER: Right-aligned "🪙 1,250" — JetBrains Mono 16px, #FFD700

CATEGORY TABS:
- "Appearance" | "Equipment"
- Active: purple text + 2px purple bottom border
- Inactive: #6B6B8A text

ITEM GRID (2 columns, 12px gap):
Each card: ~168x220px, #1A1A2E, 12px radius

Upper (60%): #252540 bg, shield icon 48px in rarity color
  - Common: #6B6B8A | Rare: #2196F3 | Epic: #6C5CE7
Lower (40%): item name (Inter 12px, white, 1-line) + price/OWNED
  - Not owned: "🪙 500" gold
  - Owned: "OWNED" gold badge
  - Owned card: gold border 1px #FFD700

ITEM DETAIL BOTTOM SHEET (#252540):
- Drag handle | icon 64px in rarity color
- Name (SemiBold 20px) + description (Regular 14px, #B8B8D4)
- "EPIC" rarity badge in rarity color
- Action button:
  - If owned: "Equip" purple button, full width 48px
  - If not owned: "Buy 🪙 500" gold button with black text

DAILY SPECIAL BANNER:
- "✨ DAILY SPECIAL — 40% OFF" gold text
- Item name + strikethrough price + countdown "23:59:42"
- Gold border, animated sparkle

EMPTY: "No items in this category"
```
# Profile Tab — Figma AI Prompt

```
Profile screen, 393x852, bottom nav visible.

AVATAR CARD (#1A1A2E, 12px radius):
- Row: avatar(64x64, #252540, person icon) + "Lv.12 Warrior"(SemiBold 18px) + "🪙 1,250  💎 45"(Regular 14px, #B8B8D4)

STATS CARD:
- Row: "Tasks: 127" | "Rate: 85%" | "Streak: 23d"
- Each: value white bold 14px, label #B8B8D4 12px

QUICK LINKS (4 cards, 56px height):
- 👤 View Character → Character Panel
- 🏆 Achievements → Achievements wall
- 📊 Statistics → Stats deep-dive
- ⚙️ Settings → Settings view
- Each: icon 24px purple + title 14px white + chevron gray
```

## Achievements Wall

```
Sub-page, 393x852.
App bar: "Achievements" (SemiBold 18px).

2-column grid (12px gap):
Tile: 170x136px, 12px radius.

UNLOCKED: gold border, gold trophy 32px, title white 13px bold, "💎 5" gem badge
LOCKED: #252540 bg, lock icon 32px gray, "???" title gray, semi-transparent
```

## Statistics

```
Sub-page, 393x852.
App bar: "Statistics" (SemiBold 18px).
3 stat cards row: Tasks(purple)/Rate(green)/Streak(gold)
Each: value 24px bold + label 12px #B8B8D4
Task history list: title(14px white) + date(12px gray)
```

## Settings

```
Sub-page, 393x852.
App bar: "Settings" (SemiBold 18px).

"Account" section: card "Local Player" + "Cloud sync coming soon"
"Preferences" section: Sound toggle + Haptic toggle (purple active)
"Data" section: "Reset All Data" (red icon + red text)
  → Confirm dialog: "Reset Game" title + "This will delete all your data" + Cancel/Reset buttons
```
# Reward Popup — Figma AI Prompt

```
Centered dialog overlay, 280px width.

TASK COMPLETION POPUP:
- Card: #252540, 24px radius, 32px padding, gold border 1px #FFD700
- Semi-transparent black background overlay
- Top: green check icon 64px (Icons.check_circle, #00E676)
- "Task Complete!" — Inter SemiBold 20px, white
- Reward row: "+30 EXP" gold 18px + "+10 🪙" gold 18px (side by side)
- Auto-dismiss 2 seconds | Tap to dismiss

LEVEL UP POPUP:
- Same card, gold border with gold radial glow
- Top: gold sparkle icon 64px (Icons.auto_awesome, #FFD700)
- "LEVEL UP!" — Cinzel Bold 24px, #FFD700
- Level number "12" — Cinzel Bold 32px, #FFD700
- "+50 EXP +20 Gold" reward line
- Full-screen golden radial glow behind card
```
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
# Light Theme — Figma AI Prompt

> White theme variant for HabitForge. 1:1 替代暗色主题的颜色值，布局/间距/组件结构完全一致。

## 01 — Design System (Light)

```
LIGHT THEME COLORS — replace all dark theme color values:

Backgrounds:
- Page background: #F5F5FA (very light lavender-gray)
- Card surface: #FFFFFF (pure white)
- Elevated surface: #F0F0F8 (slightly darker for sheets/modals)
- Borders/dividers: #E0E0EB (light purple-gray)

Text:
- Text primary: #1A1A2E (dark navy — high contrast)
- Text secondary: #6B6B8A (muted purple-gray)
- Text muted: #9E9EB8 (light gray-purple)

Brand & Accent:
- Primary action: #6C5CE7 (same vivid purple — brand consistency)
- Primary light: #A78BFA
- Primary dark: #4C3FBF
- Primary bg: #EDE9FE (purple at 10% — for active states, chips)

Semantic (vibrant enough for white bg):
- Gold / Currency: #D4A800 (slightly darker than dark mode gold, better contrast on white)
- Gold bg: #FFF8E1 (gold tint background)
- Green / Success: #00B368 (slightly darker green)
- Green bg: #E8F8F0 (green tint background)
- Red / Damage: #D32F2F (deeper red, better readability)
- Red bg: #FFEBEE (red tint background)
- Warning: #E68A00
- Warning bg: #FFF3E0

Gradients: Light lavender-to-white gradients for hero areas.

Shadows: Card 0 2px 8px rgba(26,26,46,0.08),
           Elevated 0 4px 16px rgba(26,26,46,0.12)

KEY RULE: Keep purple (#6C5CE7) and gold (#FFD700 as accent pop)
unchanged for brand consistency. Only adjust surrounding neutrals
and semantic colors for light-background readability.
```

## 02 — Splash (Light)

```
Full-screen splash, 393x852.
Background: light gradient #F5F5FA → #FFFFFF with subtle floating particles.

Center:
- Glowing purple anvil icon, same 80px
- "HABIT FORGE" — Cinzel Bold 32px, #1A1A2E
- "Forge Your Legend" — Inter Regular 14px, #6B6B8A

Bottom:
- Progress bar 120x4px, purple #6C5CE7
```

## 03 — Onboarding (Light)

### Step 1: Welcome
```
Full-screen, light background (#F5F5FA).
3D character silhouette with purple glow.
"Welcome, Adventurer" — #1A1A2E
"Turn your goals into an epic quest" — #6B6B8A
"Get Started" button — purple #6C5CE7, full width
"Skip" link — #9E9EB8
4 dots — active purple #6C5CE7, inactive #E0E0EB
```

### Step 2: Choose Class
```
3 selection cards: #FFFFFF bg, 12px radius, 2px #E0E0EB border.
SELECTED: purple border 2px #6C5CE7 + #EDE9FE background.
UNSELECTED: #E0E0EB border.
"Warrior" | "Mage" | "Ranger" — title #1A1A2E, subtitle #6B6B8A.
"Confirm" purple button, "Skip" link.
```

### Step 3: First Habit
```
Suggestion cards: #FFFFFF, 12px radius, #E0E0EB border.
Title: #1A1A2E. "+" icon purple.
"I'll add later" link: #9E9EB8.
```

### Step 4: Ready
```
Background: warm gold-white gradient.
Gold sparkle icon #FFD700.
"You're Ready!" — #1A1A2E.
"Your legend begins now" — #6B6B8A.
"Enter the Realm" button — purple #6C5CE7 with gold glow shadow.
```

## 04 — Home (Light)

```
Home screen, light bg #F5F5FA, bottom nav visible.

APP BAR:
- "HABIT FORGE" — Cinzel Bold 18px, #1A1A2E
- Right icons: #6B6B8A

3D CHARACTER AREA (35%):
- White bg (#FFFFFF) for character viewport
- Overlay: "Lv.12 Warrior" + purple EXP bar

STATS STRIP:
- HP bar: green (#00B368) on white bg, "HP" label #6B6B8A
  When <30%: red (#D32F2F)
- Gold: "🪙 1,250" — #D4A800

"TODAY'S QUESTS":
- Header: #1A1A2E. "+ Add" purple.

TASK LIST:
Each tile: #FFFFFF, 12px radius, subtle card shadow.
- Checkbox: empty = #E0E0EB border, filled = #00B368
- Title: #1A1A2E. Completed: strikethrough #9E9EB8
- EXP: "+15 EXP" #D4A800
- Swipe left: green bg #E8F8F0 + ✓ | Swipe right: orange bg #FFF3E0

EMPTY STATE:
- Icon #E0E0EB, message #6B6B8A, button purple.

QUICK ACTION ROW: icons #6B6B8A.

BOTTOM NAV: #FFFFFF bg, 64px, top border #E0E0EB.
Active tab: purple. Inactive: #9E9EB8.
```

## 05 — Quests (Light)

```
Quests screen, light bg #F5F5FA.

TYPE TAB BAR:
- Active: purple text + purple underline
- Inactive: #9E9EB8

TAG FILTER ROW:
- Active chip: #6C5CE7 fill + white text
- Inactive chip: #FFFFFF fill + #6B6B8A text, #E0E0EB border

TASK LIST:
Same white cards as Home (#FFFFFF, shadow).

FAB: purple #6C5CE7, white "+".

CREATE/EDIT BOTTOM SHEET:
Sheet bg: #FFFFFF, 16px top radius.
Drag handle: #E0E0EB.
"New Task" — #1A1A2E.
Input field: #F5F5FA bg, hint #9E9EB8.
Type chips selected: purple. Unselected: #F5F5FA.
Difficulty chips: Easy green #00B368, Medium orange #E68A00, Hard red #D32F2F.
"Create" purple button.

EMPTY: icon + "No habits yet" + purple CTA.
```

## 06 — Character Panel (Light)

```
Full-screen modal, light bg #F5F5FA.

TOP BAR:
- Back arrow + "Lv.12 Warrior" — #1A1A2E

3D VIEWPORT (60%):
- White bg (#FFFFFF), drag rotate, pinch zoom
- Animation toggle pills: #F0F0F8 bg, active purple border

STATS CARD (#FFFFFF, 12px radius, shadow):
- "Stats" header — #1A1A2E
- Stat points badge: gold bg #FFF8E1 + #D4A800 text
- 3x2 grid cells: #F5F5FA bg, 8px radius
  Label uppercase #6B6B8A, value #1A1A2E, + button purple

EQUIPMENT:
- 4 circles (48x48), empty: #F0F0F8 + gray icon, equipped: purple border.

DEATH STATE: red overlay #FFEBEE, "Recovering..." countdown, grayed stats.
```

## 07 — Forge / Shop (Light)

```
Shop screen, light bg #F5F5FA.

GOLD HEADER: "🪙 1,250" #D4A800.

CATEGORY TABS:
- Active: purple #6C5CE7 + underline. Inactive: #9E9EB8.

ITEM GRID (2 columns):
Each card: #FFFFFF, 12px radius, shadow.
Upper (60%): #F5F5FA bg + icon in rarity color.
  Common: #9E9EB8 | Rare: #2196F3 | Epic: #6C5CE7
Lower (40%): name #1A1A2E.
  Not owned: "🪙 500" #D4A800.
  Owned: "OWNED" gold badge + gold border.
  Owned card: gold border 1px #FFD700.

ITEM DETAIL SHEET (#FFFFFF):
Icon, name (#1A1A2E), description (#6B6B8A), "EPIC" rarity badge.
"Equip" purple button | "Buy 🪙 500" gold button.

DAILY SPECIAL: gold border, "✨ DAILY SPECIAL" #D4A800, countdown.
```

## 08 — Profile (Light)

```
Profile screen, light bg #F5F5FA.

AVATAR CARD (#FFFFFF):
Row: avatar(64x64, #F5F5FA, purple icon) + "Lv.12 Warrior"(#1A1A2E) + "🪙 1,250  💎 45"(#6B6B8A)

STATS CARD (#FFFFFF):
"Tasks: 127" | "Rate: 85%" | "Streak: 23d" — values #1A1A2E, labels #6B6B8A.

QUICK LINKS (4 cards, #FFFFFF):
Icon purple + title #1A1A2E + chevron #9E9EB8.

ACHIEVEMENTS:
Unlocked: gold border + gold trophy + title #1A1A2E + "💎 5".
Locked: #F0F0F8 bg + lock icon #9E9EB8 + "???" #9E9EB8.

STATISTICS:
Cards: Tasks(purple accent)/Rate(green accent)/Streak(gold accent).
List: title #1A1A2E, date #9E9EB8.

SETTINGS:
Cards: #FFFFFF.
Text: #1A1A2E. Subtitle: #6B6B8A.
Toggles: purple active.
"Reset All Data": red icon + red text.
Confirm dialog: #FFFFFF bg, title #1A1A2E, message #6B6B8A.
```

## 09 — Reward Popup (Light)

```
TASK COMPLETION POPUP:
Card: #FFFFFF, 24px radius, 32px padding, gold border 1px #FFD700.
Semi-transparent black overlay (50%).
Green check icon 64px #00B368.
"Task Complete!" — Inter SemiBold 20px, #1A1A2E.
"+30 EXP +10 🪙" — #D4A800 18px.

LEVEL UP POPUP:
Same card with gold glow.
Gold sparkle icon #FFD700.
"LEVEL UP!" — Cinzel Bold 24px, #D4A800.
Level number 32px #D4A800.
Full-screen gold radial glow.
```

## 10 — Components (Light)

```
BOTTOM NAV: #FFFFFF bg, 64px. Active purple, inactive #9E9EB8.

TASK TILE: #FFFFFF card, shadow. Checkbox #E0E0EB / #00B368.
Title #1A1A2E. EXP gold.
Swipe left: #E8F8F0. Swipe right: #FFF3E0.

STAT BAR: bg track #E0E0EB.
Fill: green #00B368, red #D32F2F, gold #D4A800.
Label #6B6B8A.

EMPTY STATE: icon #E0E0EB, text #6B6B8A, purple button.

SHIMMER: #F0F0F8 → #E0E0EB → #F0F0F8 sweep.

CONFIRM DIALOG: #FFFFFF bg. Title #1A1A2E, message #6B6B8A.
Cancel: #9E9EB8. Confirm: purple / red.
```
