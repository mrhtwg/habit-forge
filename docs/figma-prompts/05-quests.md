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
