# Reusable Components — Figma AI Prompt

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
