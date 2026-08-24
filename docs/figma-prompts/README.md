# HabitForge Figma Prompts

## 快速生成（推荐 — 仅需 1 次 Figma AI 调用）

直接用 `_one-shot.md`。一次性包含：
- 双主题 Design System（暗色 + 亮色）
- 所有组件（BottomNav、TaskTile、StatBar、EmptyState...）
- 所有 9 屏（Splash、Onboarding×4、Home、Quests、Character、Forge、Profile+subpages、Reward）
- 动效规格标注 + 交付规范

**使用**: 复制 `_one-shot.md` 全部内容 → Figma → Generate UI with AI → 粘贴 → 生成。

> 如果 AI 一次没出全所有屏，调整提示词开头加入 "Generate all 9 screens" 重试。限制额度的话，一次机会就够了。

## 逐屏精调（不限额度时）

12 个分文件，每屏一个。适合需要逐屏调细节的场景。

| 文件 | 内容 |
|------|------|
| [01-design-system.md](01-design-system.md) | 颜色 Token、字体层级、间距 |
| [02-splash.md](02-splash.md) ~ [09-reward-popup.md](09-reward-popup.md) | 逐屏提示词 |
| [10-components.md](10-components.md) | 通用组件 |
| [11-light-theme.md](11-light-theme.md) | 亮色变体颜色值 |
| [12-animations.md](12-animations.md) | 动效系统 + Lottie 规格 |

## 文件列表

| 文件 | 内容 | 优先级 |
|------|------|--------|
| [01-design-system.md](01-design-system.md) | 颜色 Token、字体层级、间距系统、阴影 — 先建 Styles | ⭐ 必须先做 |
| [02-splash.md](02-splash.md) | Splash 启动页 | P0 |
| [03-onboarding.md](03-onboarding.md) | 4 步引导（欢迎/选职业/首习惯/就绪） | P0 |
| [04-home.md](04-home.md) | Home Tab — 3D角色、HP/EXP条、今日任务列表 | P0 |
| [05-quests.md](05-quests.md) | Quests Tab — 任务 CRUD、滑动手势、筛选、创建表单 | P0 |
| [06-character-panel.md](06-character-panel.md) | 角色面板 — 全屏 3D、6 维属性、装备槽 | P0 |
| [07-forge-shop.md](07-forge-shop.md) | Forge Tab — 商店网格、购买/装备、每日特惠 | P1 |
| [08-profile.md](08-profile.md) | Profile Tab — 成就墙、统计、设置 | P1 |
| [09-reward-popup.md](09-reward-popup.md) | 奖励弹窗 + 升级动画 | P0 |
| [10-components.md](10-components.md) | 通用组件（BottomNav、TaskTile、StatBar、EmptyState...） | ⭐ 先建组件库 |
| [11-light-theme.md](11-light-theme.md) | 亮色主题变体（颜色值替换） | 暗色做完后追加 |
| [12-animations.md](12-animations.md) | 动效系统 + Lottie 规格（双主题通用） | 设计做完后追加 |

## 推荐生成顺序

```
Design System (01) → Components (10) → Splash (02) → Onboarding (03)
→ Home (04) → Quests (05) → Character (06) → Forge (07) → Profile (08) → Reward (09)
```

## 关键规格

- 画布: 393 × 852 (iPhone 15 Pro)
- 使用 Auto Layout，间距 8px 倍数
- 所有颜色定义为 Color Styles
- 所有文本定义为 Text Styles
- 通用组件定义为 Components with Variants
