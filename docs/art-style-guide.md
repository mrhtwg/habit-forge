# HabitForge Art Style Guide

## Overview

HabitForge uses a **bright cartoon adventure** style with a **modern mobile-native** feel. The visual language is warm, friendly, and app-store friendly: cream backgrounds, white cards, playful violet and gold accents, and chibi-like heroic characters.

The goal is to make every task feel like a small step in a cheerful adventure, while keeping the UI clear, approachable, and fun to use every day.

---

## Design Pillars

1. **Bright cartoon atmosphere** — warm cream backgrounds, sunny gold rewards, and friendly violet magic.
2. **Chibi hero identity** — cute, compact characters with strong silhouettes.
3. **Modern native UI** — clean white cards, playful ink outlines, rounded corners, and readable hierarchy.
4. **Reward-driven feedback** — cheerful gold effects, level-up celebrations, and satisfying micro-animations.
5. **Mobile-first clarity** — designed for 393×852 screens with comfortable touch targets.

---

## Color Palette

| Token | Color | Usage |
|---|---|---|
| Background | `#FFF6E7` | Warm cream app background |
| Surface | `#FFFFFF` | Cards, sheets, input backgrounds |
| Elevated | `#FFEFD6` | Deep cream elevated surfaces |
| Border | `#3A2A4E` | Deep purple ink outlines and borders |
| Text Primary | `#3A2A4E` | Main text and ink |
| Text Secondary | `#6E5B8A` | Body and secondary text |
| Text Muted | `#8A7CAE` | Placeholder and disabled text |
| Primary | `#9B6BFF` | Main actions, active states, violet magic |
| Primary Light | `#B455FF` | Highlights and gradients |
| Primary Dark | `#7B4FE0` | Pressed / deeper violet |
| Gold | `#FFC93D` | Currency, rewards, sunny accents |
| Gold Dark | `#F5A60C` | Gold press / deeper reward tone |
| Green | `#44C86F` | Positive feedback, completion |
| Green Dark | `#2EA758` | Deeper success tone |
| Red / Coral | `#FF6B6B` | HP loss, danger |
| Coral Dark | `#E84C56` | Danger press / stronger warning |
| Pink | `#F1A6B7` | Soft decorative accents |
| Sky | `#9ED9FF` | Sky and light decorative areas |
| Sky Light | `#DBF1FF` | Soft sky fills |
| Violet Light | `#E9DEFF` | Soft violet fills |
| Green Light | `#E8FFEE` | Soft success fills |
| Gold Light | `#FFF1C4` | Soft gold fills |
| Red Light | `#FFECEC` | Soft danger fills |

---

## Typography

The app uses a rounded, playful type system that fits the bright cartoon style.

| Role | Font | Style |
|---|---|---|
| Display / Titles | Baloo2 | Bold / ExtraBold, rounded and game-like |
| Body / UI | Nunito | Regular / Medium, clean and friendly |
| Accent / Handwritten notes | Caveat | Regular / SemiBold, used for special quotes and flair |

Use the type scale consistently:

- Display: 28–32
- Headline: 20–24
- Body: 14–16
- Label / Caption: 10–12

---

## Character Design

### Class Silhouettes

Each class must be readable at a glance, even at small avatar sizes:

| Class | Silhouette | Key Features |
|---|---|---|
| Warrior | ▧ Rectangular | Helmet, sturdy armor, large sword / shield |
| Mage | ▩ A-shape | Wide robe, oversized hood / hat, tall glowing staff |
| Ranger | ▰ Diamond | Hood and scarf, light armor, longbow |

### Character Rules

- **Chibi proportion:** approximately 1:1 head-to-body ratio, 2-head-tall characters.
- **Gender-neutral:** characters are identified by equipment and silhouette, not by gender.
- **Friendly cartoon look:** rounded shapes, soft colors, expressive but simple faces when visible.
- **Anime-inspired:** bold outlines, clean cel shading, bright and cheerful colors.
- **Consistent palette:** violet primary, sunny gold accents, and deep purple ink outlines.
- **Readable at 50px:** each class must be recognizable as a tiny icon.

---

## UI Style

### Layout

- Design base: **393×852** portrait.
- Spacing scale: 4 / 8 / 16 / 24 / 32 / 48 / 64.
- Cards are white on a warm cream background with deep purple ink borders.

### Radius

| Level | Radius |
|---|---|
| Buttons | 8px |
| Cards | 12px |
| Sheets / Dialogs | 16–24px |
| Pills / Avatars | Full / 9999px |

### Icons

- Use **Phosphor Icons** line style.
- Common sizes: 16 / 24 / 32 / 48 / 64.
- Icons should be simple, friendly, and not compete with the character art.

### Borders & Shadows

- Deep purple ink borders give the UI a hand-drawn storybook feel.
- Shadows are light and subtle; elevation should feel soft, not heavy.
- Gold and violet glows are reserved for rewards, level-ups, and special items.

---

## Motion & Feedback

Motion is an important part of the HabitForge experience.

| Moment | Feeling |
|---|---|
| Task completed | Cheerful reward popup, gold / EXP feedback |
| Level up | Bright golden celebration, character joy |
| HP damage | Gentle red flash, HP bar shrink |
| Death | Character down state, recovery countdown |
| Purchase | Gold flies out, item enters inventory |
| Tab switch | Fade and subtle upward motion |

Animation principles:

- Keep regular UI transitions fast: 200–400ms.
- Reserve longer animations for level-ups and rare rewards.
- Respect reduced-motion preferences where possible.

---

## Asset Guidelines

- Character idle animations use **PNG frame sequences** for crispness and reliable playback.
- SVGA is used for selected effects where appropriate.
- All visual assets should match the bright cartoon palette: cream, white, violet, gold, and soft pastel accents.
- Avoid dark, gritty, or realistic textures; keep the style bright and cohesive.

---

## Do / Don't

**Do**

- Keep characters cute, compact, and readable.
- Use violet for magic and primary actions.
- Use sunny gold for rewards and currency.
- Keep backgrounds warm and light, with white cards and clear contrast.

**Don't**

- Don't use dark navy or heavy black backgrounds as the main theme.
- Don't mix realistic 3D renders with the cartoon style.
- Don't overload screens with particle effects.
- Don't rely on color alone for important feedback; use icons and text as well.
