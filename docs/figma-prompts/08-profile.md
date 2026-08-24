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
