# HabitForge Light Theme — 完整 Figma AI 提示词（独立版）

> 纯亮色主题，可直接作为独立的 Figma AI 提示词使用。
> 布局/交互/组件结构完全继承暗色版，仅颜色值替换。
> 画布: 393×852 (iPhone 15 Pro)

---

## 01 — Design System

```
LIGHT THEME COLORS:

Backgrounds:
- Page background: #F5F5FA (light lavender-gray)
- Card surface: #FFFFFF (pure white)
- Elevated surface: #F0F0F8 (slightly darker)
- Borders: #E0E0EB

Text:
- Text primary: #1A1A2E (dark navy)
- Text secondary: #6B6B8A
- Text muted: #9E9EB8

Brand:
- Primary action: #6C5CE7 (purple, same as dark)
- Primary light: #A78BFA
- Primary dark: #4C3FBF
- Primary bg: #EDE9FE (purple tint — for active chips)

Semantic:
- Gold / Currency: #D4A800
- Gold bg: #FFF8E1
- Green / Success: #00B368
- Green bg: #E8F8F0
- Red / Damage: #D32F2F
- Red bg: #FFEBEE
- Warning: #E68A00
- Warning bg: #FFF3E0

Shadows: Card 0 2px 8px rgba(26,26,46,0.08)
         Elevated 0 4px 16px rgba(26,26,46,0.12)

Typography: same fonts (Cinzel/Inter/JetBrains Mono), same sizes.
Spacing: same (8px base, 16px padding).
```

## 02 — Splash

```
Full-screen splash, 393x852.
Background: light gradient #F5F5FA → #FFFFFF with subtle floating particles.

Center:
- Glowing purple anvil icon 80px, #6C5CE7 with soft glow
- "HABIT FORGE" — Cinzel Bold 32px, #1A1A2E
- "Forge Your Legend" — Inter Regular 14px, #6B6B8A

Bottom:
- Thin purple progress bar 120x4px, #6C5CE7, rounded
- Shimmer animation
```

## 03 — Onboarding (4 Steps)

### Step 1: Welcome
```
Full-screen, light bg #F5F5FA.
- Upper: 3D character silhouette with purple glow (#6C5CE7)
- "Welcome, Adventurer" — Cinzel Bold 28px, #1A1A2E
- "Turn your goals into an epic quest" — Inter Regular 16px, #6B6B8A
- "Get Started" button: #6C5CE7, full width, 56px height, 8px radius, white text 16px
- "Skip" link: Inter 14px, #9E9EB8
- 4 dot indicators, first active purple, rest #E0E0EB
```

### Step 2: Choose Class
```
Full-screen.
- "Choose Your Class" — Inter SemiBold 20px, #1A1A2E
- 3 vertical cards, 80px height, #FFFFFF bg, 12px radius, 2px #E0E0EB border

  SELECTED: purple border 2px #6C5CE7 + #EDE9FE background
  UNSELECTED: #E0E0EB border

  Each: icon 40px purple + title "Warrior/Mage/Ranger" + subtitle

- "Confirm" purple button, "Skip" link
- 4 dots, second active
```

### Step 3: First Habit
```
- "Create Your First Habit" — Inter SemiBold 20px, #1A1A2E
- 3 suggestion cards: #FFFFFF, 12px radius, #E0E0EB border
  Title #1A1A2E, "+" icon purple #6C5CE7
- "I'll add later" link: Inter 14px, #9E9EB8
- 4 dots, third active
```

### Step 4: Ready
```
- Background: warm gold-to-white gradient
- Gold star icon 80px, #FFD700
- "You're Ready!" — Cinzel Bold 28px, #1A1A2E
- "Your legend begins now" — Inter 16px, #6B6B8A
- "Enter the Realm" button: #6C5CE7 with gold glow shadow
- 4 dots all filled
```

## 04 — Home Tab

```
Home screen, light bg #F5F5FA, 4-tab bottom nav visible.

APP BAR:
- Left: "HABIT FORGE" — Cinzel Bold 18px, #1A1A2E
- Right: bell + gear icons, 24px, #6B6B8A

3D CHARACTER AREA (35% screen height):
- Full-width, white (#FFFFFF) background for 3D viewport
- Character with idle animation, auto-rotate
- Bottom overlay: "Lv.12 Warrior" + EXP bar (#6C5CE7, 6px, rounded)

STATS STRIP (16px padding):
- HP bar: "HP" label + "85/100", green bar (#00B368), 10px height
  When <30%: red (#D32F2F) with pulsing glow
- Gold: "🪙 1,250" — JetBrains Mono 16px, #D4A800

"TODAY'S QUESTS":
- Header: "Today's Quests" left (Inter SemiBold 16px, #1A1A2E) + "+ Add" right (purple #6C5CE7)

TASK LIST (scrollable):
Each tile: #FFFFFF, 12px radius, subtle card shadow, 16px padding
- [Circle checkbox empty: #E0E0EB border / filled: #00B368 fill + white check]
- Title: Inter 14px, #1A1A2E. Completed: strikethrough #9E9EB8
- Below: difficulty dots + streak fire (if ≥7)
- Right: "+15 EXP" #D4A800 11px
- Swipe left: #E8F8F0 + ✓ | Swipe right: #FFF3E0 + ←

EMPTY STATE: check icon #E0E0EB, "No quests" #6B6B8A, purple CTA.

QUICK ACTIONS: 🛒 📊 🏆 — icons #6B6B8A.

BOTTOM NAV: #FFFFFF bg, 64px, top border #E0E0EB.
Home(active purple) | Quests(9E9EB8) | Forge(9E9EB8) | Profile(9E9EB8)
```

## 05 — Quests Tab

```
Quests screen, light bg #F5F5FA, bottom nav visible.

TYPE TABS:
- 3 segments: "Habits" | "Dailys" | "ToDos"
- Active: purple #6C5CE7 + 2px underline
- Inactive: #9E9EB8

TAG FILTER ROW (horizontal scroll, 32px height):
- Active: #6C5CE7 fill + white text, pill shape
- Inactive: #FFFFFF fill + #6B6B8A text, #E0E0EB border

TASK LIST: same white cards as Home.

FAB: purple #6C5CE7, 56px, white "+".

CREATE/EDIT BOTTOM SHEET (#FFFFFF, 16px top radius):
- Drag handle: 40x4px, #E0E0EB
- "New Task" — Inter SemiBold 20px, #1A1A2E
- Title input: #F5F5FA bg, 12px radius, hint #9E9EB8
- Type pills selected: purple. Unselected: #F5F5FA
- Difficulty pills: Easy #00B368, Medium #E68A00, Hard #D32F2F
- "Create" full-width purple button 48px

EMPTY: "No habits yet" + purple button.
```

## 06 — Character Panel

```
Full-screen modal, light bg #F5F5FA. No bottom nav.

TOP BAR:
- Back arrow | "Lv.12 Warrior" center (#1A1A2E, SemiBold 18px)

3D VIEWPORT (60% height):
- White (#FFFFFF) background
- Drag rotate, pinch zoom
- [Idle] [Victory] pills: #F0F0F8 bg, active purple border

STATS CARD (#FFFFFF, 12px radius, shadow, 16px padding):
- "Stats" header (#1A1A2E, SemiBold 16px) + gold badge (#FFF8E1 bg, #D4A800 text)
- 3x2 grid:
  | STR: 18 [+] | INT: 14 [+] | AGI: 16 [+] |
  | DEF: 12 [+] | VIT: 10 [+] | LUK: 8  [+] |
  Each cell: #F5F5FA, 8px radius. Label uppercase #6B6B8A, value #1A1A2E

EQUIPMENT: 4 circles (48x48). Empty: #F0F0F8 + gray icon. Equipped: purple border.

DEATH: red overlay #FFEBEE, "Recovering..." countdown, grayed stats.
```

## 07 — Forge / Shop Tab

```
Shop screen, light bg #F5F5FA, bottom nav visible.

GOLD HEADER: right "🪙 1,250" #D4A800.

CATEGORY TABS: "Appearance" | "Equipment"
- Active: purple #6C5CE7 + underline. Inactive: #9E9EB8.

ITEM GRID (2 columns, 12px gap):
Each card: 168x220px, #FFFFFF, 12px radius, shadow.
Upper (60%): #F5F5FA bg + icon 48px in rarity color.
  Common: #9E9EB8 | Rare: #2196F3 | Epic: #6C5CE7
Lower (40%): name #1A1A2E.
  Not owned: "🪙 500" #D4A800
  Owned: "OWNED" gold badge + gold border (#FFD700)

DETAIL SHEET (#FFFFFF): icon, name (#1A1A2E), desc (#6B6B8A), "EPIC" badge.
"Equip" purple button | "Buy 🪙 500" gold button (#FFD700 with black text).

DAILY SPECIAL: gold border, gold text, countdown timer.
```

## 08 — Profile Tab

```
Profile screen, light bg #F5F5FA, bottom nav visible.

AVATAR CARD (#FFFFFF, 12px radius):
Row: avatar(64x64, #F5F5FA, person icon purple) + "Lv.12 Warrior"(#1A1A2E, SemiBold 18px) + "🪙 1,250  💎 45"(#6B6B8A, 14px)

STATS CARD (#FFFFFF):
Row: "Tasks: 127" | "Rate: 85%" | "Streak: 23d"
Values #1A1A2E bold 14px, labels #6B6B8A 12px.

QUICK LINKS (4 cards, 56px height, #FFFFFF):
👤 View Character | 🏆 Achievements | 📊 Statistics | ⚙️ Settings
Icons purple 24px, title #1A1A2E 14px, chevron #9E9EB8.

ACHIEVEMENTS:
Unlocked: gold border + gold trophy + title #1A1A2E + "💎 5"
Locked: #F0F0F8 bg + lock icon #9E9EB8 + "???" #9E9EB8

STATISTICS:
3 stat cards: Tasks(purple #6C5CE7) / Rate(green #00B368) / Streak(gold #D4A800)
List: title #1A1A2E, date #9E9EB8.

SETTINGS:
Cards #FFFFFF. Title #1A1A2E. Subtitle #6B6B8A.
Toggles purple active.
"Reset All Data" — red icon #D32F2F
Confirm dialog: #FFFFFF bg, title #1A1A2E, message #6B6B8A, Cancel/Reset buttons.
```

## 09 — Reward Popup

```
TASK COMPLETION POPUP:
- Card: #FFFFFF, 24px radius, gold border 1px #FFD700
- Semi-transparent black overlay (50%)
- Green check icon 64px, #00B368
- "Task Complete!" — Inter SemiBold 20px, #1A1A2E
- "+30 EXP +10 🪙" — #D4A800 18px bold
- Auto-dismiss 2s

LEVEL UP POPUP:
- Same card + gold glow
- Gold sparkle icon 64px, #FFD700
- "LEVEL UP!" — Cinzel Bold 24px, #D4A800
- Level number — Cinzel Bold 32px, #D4A800
```

## 10 — Components (Light Theme Variants)

```
BOTTOM NAV: #FFFFFF bg, 64px, top border #E0E0EB.
Active: purple. Inactive: #9E9EB8.

TASK TILE: #FFFFFF card, shadow. Checkbox #E0E0EB / #00B368.
Title #1A1A2E. EXP #D4A800.
Swipe: left #E8F8F0, right #FFF3E0.

STAT BAR: track #E0E0EB. Fill green #00B368, red #D32F2F, gold #D4A800.
Label #6B6B8A.

EMPTY STATE: icon #E0E0EB, text #6B6B8A, purple button.

SHIMMER: #F0F0F8 → #E0E0EB → #F0F0F8 sweep.

CONFIRM DIALOG: #FFFFFF bg. Title #1A1A2E, message #6B6B8A.
Cancel #9E9EB8, Confirm purple or red.
```
