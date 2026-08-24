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
