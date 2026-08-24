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
