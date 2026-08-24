# HabitForge Figma AI 生成提示词

> 用于 Figma "Generate with AI" / 或交付设计师的完整提示词集
> 风格：暗黑 RPG × 现代移动端、霓虹紫主题、手机屏幕 393×852 (iPhone 15 Pro)

---

## 一、设计系统（Design System）提示词

### 色彩系统

```
Create a dark RPG mobile app color system with these exact values:

Backgrounds:
- Page background: #0D0D1A (very dark navy)
- Card surface: #1A1A2E (dark navy)
- Elevated surface: #252540 (slightly lighter)
- Borders/dividers: #3D3D5C (muted purple-gray)

Text:
- Primary text: #FFFFFF (white)
- Secondary text: #B8B8D4 (light lavender)
- Muted text: #6B6B8A (muted purple-gray)

Brand & Accent:
- Primary action: #6C5CE7 (vivid purple) — buttons, active tab, links
- Primary light: #A78BFA
- Primary dark: #4C3FBF

Semantic:
- Gold / Currency: #FFD700 — EXP, coins, rewards, level up
- Green / Success: #00E676 — HP full, task complete, positive
- Red / Damage: #FF5252 — HP loss, death, negative actions
- Warning: #FF9800 — low HP warning, skip state
- Error: #F44336 — critical errors
- Info: #2196F3 — info badges, rarity indicator

Gradients: Use subtle purple-to-blue gradients for hero areas.

Apply full-bleed dark backgrounds, neon-like accent glows for interactive elements.
```

### 字体系统

```
Typography for a dark RPG habit app. Use Google Fonts:

Display / Headings:
- Font: "Cinzel" (serif, fantasy feel) — use ONLY for level numbers and major headings
- Weight: Bold (700)
- Sizes: Title hero 32px, level display 28px, section headers 24px

Body / Labels:
- Font: "Inter" (clean sans-serif) — all body text, labels, list items
- Weights: SemiBold 600, Medium 500, Regular 400
- Sizes: Headline 20px, title 18px, subtitle 16px, body 14px, caption 12px, label 10px

Numbers / Stats:
- Font: "JetBrains Mono" (monospace) — HP numbers, gold amounts, stat values
- Weight: Regular 400
- Size: 16px for stat readouts

Text styles hierarchy:
- Display Large: Cinzel Bold 32, White
- Display Medium: Cinzel Bold 28, White  
- Display Small: Cinzel Bold 24, White
- Headline: Inter SemiBold 20, White
- Title: Inter SemiBold 18, White
- Subtitle: Inter Medium 16, #B8B8D4
- Body: Inter Regular 14, White
- Caption: Inter Regular 12, #B8B8D4
- Label: Inter Medium 10, #6B6B8A
- Number: JetBrains Mono Regular 16, White
```

### 间距与布局

```
Spacing system: 8px base unit
- xs: 4px, sm: 8px, md: 16px, lg: 24px, xl: 32px, xxl: 48px, xxxl: 64px

Layout:
- Screen padding: 16px horizontal
- Card padding: 16px
- Card gap: 12px
- Bottom nav height: 64px
- Task tile height: 72px
- Icon sizes: 24px (default), 32px (large), 48px (action), 64px (hero)

Border radius:
- Cards: 12px
- Buttons: 8px  
- Chips: 20px (full pill)
- Text inputs: 12px
- Bottom sheet: 16px (top corners only)

Shadows:
- Card: 0 4px 12px rgba(0,0,0,0.3)
- Elevated: 0 8px 32px rgba(0,0,0,0.4)
- Gold glow: 0 0 20px rgba(255,215,0,0.4)
- Green glow: 0 0 20px rgba(0,230,118,0.3)
- Red glow: 0 0 20px rgba(255,82,82,0.4)
- Purple glow: 0 0 20px rgba(108,92,231,0.3)
```

---

## 二、Splash 启动页

```
Mobile screen 393x852, dark theme.

Create a splash/loading screen:

- Background: Full-bleed dark gradient (#0D0D1A → #1A1A2E) with subtle floating
  particle effect or twinkling stars in background
- Center: Large app icon — a glowing purple anvil/hammer icon (⚒️) or a stylized
  "F" rune, neon purple with soft glow
- Below icon: "HABIT FORGE" text in Cinzel Bold, 32px, white, small letter-spacing
- Below title: "Forge Your Legend" subtitle in Inter Regular 14px, #B8B8D4
- Bottom area: thin horizontal progress bar, 120px wide, purple (#6C5CE7),
  with subtle shimmer/glow animation
- Duration: show for ~1.5-2 seconds

No navigation elements. No status bar. Clean dark canvas.
```

---

## 三、Onboarding 新手引导（4步）

### Step 1: Welcome

```
Full-screen onboarding welcome step. 393x852.

- Background: dark gradient with subtle purple particles
- Upper 60%: centered 3D character preview area — placeholder for GLB model, 
  show a floating character silhouette with purple glow outline
- "Welcome, Adventurer" in Cinzel Bold 28px, white
- Subtitle: "Turn your goals into an epic quest" in Inter Regular 16px, #B8B8D4
- Bottom area (40%):
  - Large purple button (#6C5CE7): "Get Started" — full width, 56px height, 
    rounded 8px, white text Inter SemiBold 16px
  - Below button: "Skip" text link, Inter Regular 14px, #6B6B8A
- Bottom: Page indicator dots — 4 dots, first one active (#6C5CE7), 
  others inactive (#3D3D5C)
```

### Step 2: Choose Class

```
Full-screen class selection step. 393x852.

- Top: "Choose Your Class" in Inter SemiBold 20px, white, centered
- Middle: 3 vertical class cards, each 80px height:
  
  Card 1 — Warrior (⚔️):
  - Left: shield icon (Icons.shield) 40px, purple
  - Right: "Warrior" text Inter SemiBold 16px + "Strength & Defense" caption 12px
  - Background: when selected → #6C5CE7 at 20% opacity, purple border 2px
  - Default: #1A1A2E surface, #3D3D5C border
  
  Card 2 — Mage (🔮):
  - Same layout, icon Icons.auto_awesome, "Mage" title, "Intelligence & Luck" caption
  - Selection: same active state
  
  Card 3 — Ranger (🏹):
  - Same layout, icon Icons.gps_fixed, "Ranger" title, "Agility & Precision" caption
  - Selection: same active state
  
- Bottom:
  - "Confirm" button — full width purple (#6C5CE7), 56px height
  - "Skip" text link
  - Page indicator: 4 dots, second active
```

### Step 3: Create First Habit

```
Full-screen habit creation step. 393x852.

- Top: "Create Your First Habit" in Inter SemiBold 20px, white
- Middle: 3 suggestion cards, 56px height each:
  - "Drink 8 glasses of water" [Add button + icon on right]
  - "Read for 30 minutes" [Add button + icon on right]
  - "Morning exercise" [Add button + icon on right]
  
  Each card: #1A1A2E surface, 12px radius, text Inter Regular 14px white,
  trailing "+" icon in purple (#6C5CE7)
  
- Below suggestions: "I'll add later" text link, Inter Regular 14px, #6B6B8A, centered
- Bottom: Page indicator, third dot active
```

### Step 4: Ready

```
Final onboarding screen. 393x852.

- Background: slightly brighter gradient, gold accent glow
- Center: large gold star/sparkle icon (Icons.auto_awesome) 80px, gold (#FFD700)
- "You're Ready!" in Cinzel Bold 28px, white
- "Your legend begins now" in Inter Regular 16px, #B8B8D4
  
- Bottom:
  - "Enter the Realm" button — full width, gold/gradient background 
    (purple → gold gradient?), 56px height, white text, slight glow shadow
  - Page indicator: all 4 dots filled (completed state)
```

---

## 四、Home（主页）Tab 1

```
Home dashboard screen. 393x852. 4-tab bottom navigation visible.

=== UPPER SECTION (35% of screen) ===

App bar:
- Left: "HABIT FORGE" text logo, Cinzel Bold 18px, white
- Right: bell notification icon + settings gear icon, both 24px, #B8B8D4

3D Character area (35% screen height):
- Full-width container showing 3D character model (placeholder area)
- Character has slow idle animation, auto-rotate
- Can drag to rotate, pinch to zoom, double-tap to go fullscreen
- Overlay at bottom: level badge "Lv.X" + class name "Warrior"
  + thin EXP progress bar (purple, 6px height, rounded)

=== MIDDLE STATS STRIP ===

Row layout, 16px horizontal padding:
- Left (flex): HP StatBar — shows "HP" label, current HP / max HP (100)
  + green LinearProgressIndicator bar, 10px height, rounded
  When HP < 30%: bar turns red (#FF5252) with red pulsing glow
- Right: Gold amount — 🪙 icon + number "1,250" in JetBrains Mono 16px, gold

=== "Today's Quests" SECTION ===

Section header: "Today's Quests" in Inter SemiBold 16px, white
Right side: "+ Add" text button in purple

Task list (scrollable):
Each task tile = 72px height, #1A1A2E surface, 12px radius, 16px padding

Task row layout:
- [Circle checkbox 24x24 — empty (gray border) or filled (green + check icon)]
- 12px gap
- Task title: Inter Regular 14px, white
  If completed: strikethrough, #6B6B8A
- Spacer
- EXP tag: "+15 EXP" in gold, 11px
  
On each task:
- Difficulty dots: ● (easy, green), ●● (medium, orange), ●●● (hard, red)
  shown below title in 10px
- Streak: if ≥7, show 🔥 fire icon + "15d" in gold, 11px

Swipe left to complete: green background (#00E676 at 30% opacity) with ✓ icon
Swipe right to skip: warning background (#FF9800 at 30% opacity) with ← icon

=== EMPTY STATE ===

When no tasks: centered empty state
- Large circle check icon 64px, #6B6B8A
- "No quests for today!" in Inter Regular 14px, #B8B8D4, centered
- "Create your first quest" subtitle
- "Create" button — purple (#6C5CE7)

=== QUICK ACTION ROW ===

Compact row of 3 icon buttons before bottom nav:
- 🛒 Shop | 📊 Stats | 🏆 Achievements
- Each: icon 24px + label 10px, in #B8B8D4

=== BOTTOM NAV ===

4-tab bottom bar, #1A1A2E background, 64px height, top border #3D3D5C 0.5px

Tab 1: Home (🏠) — active = purple (#6C5CE7), inactive = #6B6B8A
Tab 2: Quests (📋)
Tab 3: Forge (🔨)  
Tab 4: Profile (👤)

=== HP LOW / DEATH STATE ===

When HP < 30%: red pulsing border on HP area, character shows hit animation
When HP = 0 (dead): red overlay "DEAD" badge, recovery countdown "30:00",
character shows collapsed pose, task interaction blocked
```

---

## 五、Quests（任务）Tab 2

```
Quests screen. 393x852. Bottom nav visible.

=== TOP TAB BAR ===

3-segment control without background:
- "Habits" | "Dailys" | "ToDos" (note: plan uses "Dailies" but UX-wise "Dailys" is cleaner)
- Selected: purple text (#6C5CE7) + 2px purple bottom border
- Unselected: gray text (#6B6B8A) + no bottom border
- Equal width segments, 12px vertical padding

=== TAG FILTER ROW ===

Horizontal scrollable chips:
- "All" chip (always first, default active)
- "Health" | "Work" | "Learn" | "Personal" | "Fitness" ...
- Active chip: purple background (#6C5CE7) + white text
- Inactive chip: #252540 background + #B8B8D4 text, 20px radius pill shape
- Height: 32px

=== TASK LIST ===

Same task tile component as Home screen.
Add long-press behavior: bottom sheet menu with "Edit" and "Delete" options.

Swipe behaviors:
- Left swipe: complete — green reveal, returns false (state managed by controller)
- Right swipe: skip — warning orange reveal, returns false
- Long press: bottom sheet with Edit icon and Delete icon

=== FAB ===

Floating action button: purple (#6C5CE7), 56px, "+" icon white, 
positioned bottom-right above bottom nav (16px offset)

=== CREATE/EDIT TASK BOTTOM SHEET ===

Bottom sheet, 16px top radius, background #252540:

Header:
- Drag handle (thin pill, 40x4px, #6B6B8A, centered)
- "New Task" or "Edit Task" in Inter SemiBold 20px, white

Form fields:
1. Title input: full-width text field, #1A1A2E background, 12px radius,
   placeholder "What do you want to do?", white text
   
2. Type selector: 3 equal pills — "Habit" | "Daily" | "Todo"
   Selected: purple fill, white text. Unselected: dark fill, gray text.
   
3. Difficulty selector: 3 pills — "Easy" (green) | "Medium" (orange) | "Hard" (red)
   Selected color fill, unselected dark.
   
4. Schedule (show when Daily selected):
   - 7 day-of-week chips: "M" "T" "W" "T" "F" "S" "S"
   - Active: purple fill, white text. Inactive: dark fill.
   - Optional time picker row

5. Tags (optional expandable section):
   - Chip input with suggested tags

6. Custom Rewards (optional expandable):
   - EXP amount input, Gold amount input, HP penalty input

Bottom: "Create" or "Save" button — full width purple, 48px height

=== EMPTY STATES ===

No tasks for type: "No habits yet" + "Create One" CTA button
Filtered empty: "No quests match this tag"
```

---

## 六、Character Panel（角色面板）

```
Full-screen character panel. Entered from double-tap on Home 3D or Profile.
393x852. Modal layout, no bottom nav.

=== TOP BAR ===

- Left: back arrow icon 24px, white
- Center: "Lv.12 Warrior" in Inter SemiBold 18px, white
- Right: 48px spacing for balance

=== 3D VIEWPORT (60% height) ===

Full-width character display area:
- Full 3D model, can rotate 360° with finger drag, pinch zoom
- Idle animation playing by default
- Two animation toggle buttons overlay bottom-right:
  [Idle] [Victory] — small pill buttons, #252540 bg, white text
  Active state has purple border

=== STATS SECTION ===

Card: #1A1A2E surface, 12px radius, 16px padding

Header row: "Stats" in Inter SemiBold 16px + stat points badge
If available stat points > 0: gold badge "X pts" with gold background at 20% opacity

Stats grid: 3 columns × 2 rows, compact layout:

| STR: 18 🡅 | INT: 14 🡅 | AGI: 16 🡅 |
| DEF: 12 🡅 | VIT: 10 🡅 | LUK: 8  🡅 |

Each cell: #252540 background, 8px radius, padding 8px
Stat name in uppercase 3-letter format (STR/INT/AGI/DEF/VIT/LUK), #B8B8D4 12px
Value in JetBrains Mono 14px, white
+ (🡅) button visible only when stat points available, purple

=== EQUIPMENT SECTION (compact) ===

"Equipment" header in Inter SemiBold 14px
4 slot circles 48x48 in a row: Weapon | Helmet | Armor | Accessory
Empty: #252540 circle with dotted border, slot icon in #6B6B8A
Equipped: icon + purple border
Tap opens item selection bottom sheet

=== DEATH STATE ===

When dead: 
- Red overlay at 40% opacity over entire panel
- "Recovering..." countdown text
- Stats grayed out, no interaction
- Death animation on character
```

---

## 七、Forge（商店）Tab 3

```
Shop screen. 393x852. Bottom nav visible.

=== GOLD BALANCE HEADER ===

Right-aligned row below app bar:
- 🪙 icon 20px, gold
- "1,250" in JetBrains Mono 16px, gold

=== CATEGORY TABS ===

2-segment: "Appearance" | "Equipment"
- Active: purple text + purple bottom underline 2px
- Inactive: gray text + no underline
- Equal width, 12px vertical padding

=== ITEM GRID ===

2-column grid, 12px gap, padding 16px:

Each item card: 168×220px approx, #1A1A2E surface, 12px radius

Upper area (60% height):
- #252540 background with rounded top corners
- Center: shield icon 48px in rarity color
  Common (#6B6B8A), Rare (#2196F3), Epic (#6C5CE7)

Lower area (40% height):
- Item name: Inter Regular 12px, white, max 1 line ellipsis  
- If owned: "OWNED" label in gold, 10px bold
- If not owned: "🪙 500" in gold, 12px

Owned item has gold border (#FFD700, 1px) on card

Item card variants:
- Common: no glow, gray icon
- Rare: blue icon, subtle blue border
- Epic: purple icon, purple glow border

=== ITEM DETAIL BOTTOM SHEET ===

Bottom sheet with 16px top radius:

- Centered drag handle
- Item icon 64px in rarity color
- Item name in Inter SemiBold 20px
- Description in Inter Regular 14px, #B8B8D4
- Rarity badge: "EPIC" in uppercase, 12px bold, rarity color
- Action button:
  If owned: "Equip" — purple button, full width, 48px height
  If not owned: "Buy 🪙 500" — gold button with black text, full width

=== DAILY SPECIAL BANNER ===

Horizontal card above grid:
- "✨ DAILY SPECIAL — 40% OFF" in gold
- Item name + price with strikethrough original price
- Countdown timer: "23:59:42" in JetBrains Mono 12px
- Golden border, animated sparkle accent

=== EMPTY STATE ===

"No items in this category" — icon + message
```

---

## 八、Profile / 我的 Tab 4

```
Profile screen. 393x852. Bottom nav visible.

=== AVATAR CARD ===

Card: #1A1A2E surface, 12px radius, 16px padding
Row layout:
- Left: avatar placeholder 64×64, #252540 background, person icon purple, 12px radius
- 16px gap
- Right: 
  "Lv.12 Warrior" in Inter SemiBold 18px, white
  Second row: "🪙 1,250  💎 45" in Inter Regular 14px, #B8B8D4

=== STATS OVERVIEW CARD ===

Card: same styling as avatar
Row: "Total Tasks: 127" | "Rate: 85%" | "Streak: 23d"
Each stat: label in #B8B8D4 12px, value in white bold 14px
Evenly distributed across row

=== QUICK LINKS ===

4 card-style list items, each with leading icon + title + chevron:

1. 👤 View Character → leads to Character Panel
2. 🏆 Achievements → leads to Achievements wall
3. 📊 Statistics → leads to Statistics deep-dive
4. ⚙️ Settings → leads to Settings view

Each: #1A1A2E card, 56px height, icon 24px in purple,
title in Inter Regular 14px white, chevron in #6B6B8A
```

### Achievements Wall

```
Sub-page. 393x852. App bar: "Achievements" in Inter SemiBold 18px.

2-column grid, 12px gap:

Each achievement tile: 170×136px, 12px radius

Unlocked:
- Gold border (#FFD700, 1px)
- Gold trophy icon 32px
- Title in white 13px bold
- 💎 5 gem reward badge
- Purple shimmer accent

Locked:
- Darker background (#252540)
- Lock icon 32px in #6B6B8A
- "???" title in gray
- No border
- Semi-transparent feel

Achievements list (9 items):
- First Blood, Hot Streak (7d), Unstoppable (30d)
- Growing Strong (lvl 5), Double Digits (lvl 10)
- Getting Things Done (50 tasks), Task Master (100 tasks)
- Shopaholic (first purchase)
- Back from the Dead (die and recover)
```

### Statistics

```
Sub-page. 393x852. App bar: "Statistics" in Inter SemiBold 18px.

Top: 3 stat cards in a row:
- "Tasks" card + count + purple accent
- "Rate" card + percentage + green accent  
- "Streak" card + days + gold accent

Each card: #1A1A2E, 12px radius, 16px padding, centered:
Value in 24px bold white, label in 12px #B8B8D4

Task history list (scrollable):
- Each completed task: title + completion date
- Title in Inter Regular 14px white, date in Inter Regular 12px #6B6B8A
```

### Settings

```
Sub-page. 393x852. App bar: "Settings" in Inter SemiBold 18px.

SECTION: "Account"
Card with one row: "Local Player" + subtitle "Cloud sync coming soon"

SECTION: "Preferences"
Card with switches:
- "Sound" toggle — SwitchListTile, purple active color
- "Haptic" toggle — SwitchListTile, purple active color

SECTION: "Data"
Card with red row:
- "Reset All Data" — leading red delete icon, red text
- Tap opens confirmation dialog

Confirm dialog:
- Title "Reset Game" in white
- Message "This will delete all your data. Are you sure?"
- "Cancel" button + "Reset" button (red)
```

---

## 九、Reward Popup（奖励弹窗）

```
Overlay dialog. Centered card, 280px width.

For task completion:
- Card: #252540 background, 24px radius, 32px padding
- Gold border (#FFD700, 1px) with subtle gold glow
- Top: green check circle icon 64px (Icons.check_circle) in #00E676
- Below: "Task Complete!" in Inter SemiBold 20px, white
- Center: "+30 EXP" in gold 18px bold + "+10 🪙" in gold 18px bold
  side by side
- Background: semi-transparent black overlay
- Auto-dismiss after 2 seconds, or tap to dismiss

For level up:
- Same card layout but:
- Icon: sparkle/star (Icons.auto_awesome) 64px in gold (#FFD700)
- Text: "LEVEL UP!" in Cinzel Bold 24px, gold
- Level number "12" in Cinzel Bold 32px, gold
- "🪙 +50 EXP +20" reward line
- Full-screen golden radial glow behind card
```

---

## 十、通用组件库提示词

### Bottom Navigation Bar

```
4-tab bottom nav bar:
- Height: 64px
- Background: #1A1A2E
- Top border: 0.5px #3D3D5C
- Each tab: icon 24px + label 12px stacked vertically
- Active tab: icon + label in purple (#6C5CE7)
- Inactive: icon + label in gray (#6B6B8A)
- Tabs: Home, Quests, Forge, Profile
- Label text: Inter Medium 10px
```

### Task Tile Component

```
Task card component reusable across Home and Quests:

Card: #1A1A2E background, 72px height, 12px radius, 16px horizontal padding

Left: Circle checkbox 24×24
- Unchecked: 2px solid #6B6B8A border, transparent center
- Checked: #00E676 fill, white check icon

12px gap to title column

Title column:
- Task title: Inter Regular 14px, white
  When completed: strikethrough line-through, color #6B6B8A
- Below title: difficulty dots in 10px, color based on level
  Easy: ● green, Medium: ●● orange, Hard: ●●● red
  If streak ≥7: show 🔥 fire icon 14px + "15d" in gold 11px

Right side (for non-habit tasks):
EXP indicator: "+15 EXP" in Inter 11px, gold (#FFD700)

Swipe actions:
- Left swipe reveal: green (#00E676 at 30%) with white check icon
- Right swipe reveal: orange (#FF9800 at 30%) with gray skip icon
```

### StatBar Component

```
Horizontal stat bar, full width:

Layout:
- Label + current/max value in row:
  Label: Inter 11px, #6B6B8A
  Value: "$current/$max" Inter 11px, #B8B8D4
- 4px gap
- Progress bar: LinearProgressIndicator, 10px or 16px height
  Background: #3D3D5C
  Fill: animated, color changes based on type
  - HP: green (#00E676) when >30%, red (#FF5252) when ≤30%
  - EXP: gold (#FFD700)
  Radius: full (20px pill)
  Animation: TweenAnimationBuilder 400ms easeOut
```

### Empty State Component

```
Centered empty state layout:

- Icon: 64px, #6B6B8A (Material Icons based on context)
- 16px gap
- Message: Inter Regular 14px, #B8B8D4, centered, max 2 lines
- 16px gap (if action button)
- Action button: Purple (#6C5CE7), full width or min width
  Only shown when actionLabel and onAction provided
```

### Shimmer Loading Placeholder

```
Shimmer skeleton component:

- Rectangle with 12px radius
- Gradient: #252540 → #3D3D5C → #252540
- Animated gradient sweep left to right, repeat 1200ms cycle
- Used for task list loading, character area loading
- Width 100% by default, configurable height (16px default)
```

### Confirmation Dialog

```
AlertDialog for destructive actions:

- Background: #252540
- 12px radius
- Title: Inter SemiBold 18px, white
- Content: Inter Regular 14px, #B8B8D4
- Actions row:
  Cancel button: TextButton, #6B8A
  Confirm button: TextButton, color varies (purple for normal, red for destructive)
```

---

## Figma AI 生成建议

1. **批量生成顺序**: 先 Design System → 通用组件 → Splash → Onboarding → Home → Quests → Character → Forge → Profile → Reward Popup
2. **使用 Auto Layout**: 所有卡片/列表使用垂直 + 水平 Auto Layout，间距统一 8px 倍数
3. **组件复用**: Task Tile、StatBar、EmptyState、Shimmer、ConfirmDialog 定义为 Components / Variants
4. **颜色 Style**: 所有颜色定义为 Figma Color Styles，方便全局替换
5. **Text Style**: 所有文字样式定义为 Figma Text Styles（上文字体层级）
6. **主题变体**: 先做暗色主题（MVP），后续可扩展亮色
7. **导出规格**: 图标使用 Phosphor Icons 或 Material Icons 均可，导出为 SVG
