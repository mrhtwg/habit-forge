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
