# HabitForge — 动画 & 3D 素材获取指南

> 目标：MVP 用 2D Lottie 动画，v2.0 升级为 3D GLB 模型。
> 所有平台标注免费额度，优先选 Path A。

---

## 第一部分：2D Lottie 动画

### 一、免费 Lottie 库（直接下载）

#### 1.1 LottieFiles — 推荐

[lottiefiles.com](https://lottiefiles.com)

搜索 → 左侧 Filter → **License: Free**。

| 关键词 | 找什么 |
|--------|--------|
| `idle character` | 角色待机呼吸 |
| `celebration` / `confetti` | 庆祝撒花 |
| `coin` / `gold coin` | 金币飞行 |
| `magic glow` / `aura` | 光环特效 |
| `check mark` / `success` | 完成勾选 |

#### 1.2 IconScout

[iconscout.com/free-lottie-animations](https://iconscout.com/free-lottie-animations)

左侧 Filter → **Free**。搜索同上。

#### 1.3 SVG to Lottie（免费转换）

[svgtolottie.com](https://svgtolottie.com)

把你找的 SVG 动画拖进去 → 导出 Lottie JSON。

---

### 二、AI 生成 Lottie（文本 → 动画）

#### 2.1 LottieFiles AI Creator

[lottiefiles.com/ai-image-generator](https://lottiefiles.com/ai-image-generator)

| 额度 | 质量 |
|------|------|
| **每月 5 次免费** | ⭐⭐⭐ |

**提示词模板（中英文均可）：**

```
# Character Idle（角色待机 — P0 必须）
A cute chibi warrior character, super-deformed style, big head small body,
standing idle with gentle bouncy breathing, rounded soft design,
kawaii face, simple clean shapes, dark purple themed, ready pose,
loop animation, 2D flat game style

# Character Victory（升级庆祝 — P0 必须）
The same chibi warrior celebrating victory, jumping up with arms raised,
happy starry eyes, golden sparkles and mini stars burst around,
triumphant cute pose, one-shot animation, kawaii celebration

# Character Hit（受伤 — P1）
The chibi warrior getting hit, stumbling backward comically,
sweat drop on head, dizzy eyes, brief impact flash,
playful hurt expression, one-shot animation, cartoon style

# Character Death（倒地 — P1）
The chibi warrior collapsing dramatically,
knees then falling flat on face, comical defeat pose,
stars circling head, exaggerated fainting pose,
one-shot, cartoon style
``````

#### 2.2 Rive.app

[rive.app](https://rive.app)

| 额度 | 特点 |
|------|------|
| **免费版** 可创建 3 个文件 | 状态机 + 交互触发，比 Lottie 更灵活 |

- 不是"文本生成"，是**可视化编辑** + 运行时
- 可以做 idle→victory→hit 状态切换，一个文件包含所有状态，比 Lottie 更适合游戏角色
- 免费版限制：3 个文件、公开作品
- 导出格式：`.riv`，Flutter 用 `riv` package

#### 2.3 Genmo.ai

[genmo.ai](https://genmo.ai)

| 额度 | 特点 |
|------|------|
| **免费**（每日额度） | 文字/图片 → 视频 → 可转 Lottie |

- 生成的是 MP4/视频，不是直接 Lottie
- 需要额外工具转成 Lottie JSON（如 [lottie-converter](https://lottie-converter.com)）
- 质量依赖 prompt，适合特效类（glow / aura / confetti）

#### 2.4 Jitter.video

[jitter.video](https://jitter.video)

| 额度 | 特点 |
|------|------|
| **免费版** | 在线动效编辑，导出 Lottie |

- 拖拽编辑 UI 动效（加载、按钮、过渡）
- 不适合角色动画
- 适合 MVP 里的 task_complete_glow、coin_fly 这类 UI 动效

---

## 第二部分：3D 模型生成（v2.0 备用）

以下平台可直接 **文本 → 3D GLB 模型**，未来切换回 3D 时参考。

### 一、文本 / 图片 → 3D 模型

#### 1.1 Meshy — 推荐（项目已有）

[meshy.ai](https://meshy.ai)

| 免费额度 | 输出格式 | 质量 |
|---------|---------|------|
| **每周 120 积分（可生成 ~6 个模型）** | GLB / FBX / OBJ | ⭐⭐⭐⭐ |

- **Text to 3D**：输入文字 → 生成 3D 模型（~30 分钟）
- **Image to 3D**：上传参考图 → 生成
- 项目已有资源：`resources/Meshy_AI_Bear_Eared_Schoolgirl_0712114743_texture.glb`（用 Meshy 生成）
- 适合 MVP：生成职业角色（Warrior / Mage / Ranger）

**提示词模板：**
```
A cute chibi warrior character, super-deformed style, big head small body,
round soft edges, holding a tiny sword, kawaii game character,
chibi proportions, cute face, low-poly style, standing ready pose,
less than 6000 triangles
```

#### 1.2 Tripo

[tripo3d.com](https://tripo3d.com)

| 免费额度 | 输出格式 |
|---------|---------|
| **每月 50 积分（注册送 150）** | GLB / OBJ / STL |

- Text to 3D + Image to 3D
- 生成速度 1-3 分钟（比 Meshy 快）
- 质量好，支持 PBR 材质
- 适合快速原型验证

#### 1.3 Luma AI (Genie)

[genie.lumalabs.ai](https://genie.lumalabs.ai)

| 免费额度 | 输出格式 |
|---------|---------|
| **每日免费 10 次** | GLB |

- Text to 3D，速度最快（30 秒-2 分钟）
- 风格偏写实/艺术
- 适合快速出预览

#### 1.4 Spline AI

[spline.design](https://spline.design)

| 免费额度 | 输出格式 |
|---------|---------|
| **免费版**（公开项目 3 个） | GLB / USDZ / OBJ |

- 浏览器内 3D 编辑器 + AI 生成
- 适合做简单道具（武器、装备）
- 交互性强，可直接做旋转/缩放预览

#### 1.5 Hyper3D (Rodin)

[hyper3d.ai](https://hyper3d.ai) — 旧名 Rodin

| 免费额度 | 输出格式 |
|---------|---------|
| **注册赠积分** | GLB / FBX / USD |

- Image to 3D 质量极高
- 适合从概念图生成角色

#### 1.6 Masterpiece Studio

[masterpiecestudio.com](https://masterpiecestudio.com)

| 免费额度 | 输出格式 |
|---------|---------|
| **免费试用** | GLB / FBX / USD |

- Text to 3D + 编辑 + 动画绑定
- 功能最全，学习曲线最大

---

### 二、免费 3D 模型库（直接下载，不生成）

#### 2.1 Quaternius

[quaternius.com](https://quaternius.com)

| 费用 | 格式 | 特点 |
|------|------|------|
| **完全免费 CC0** | GLB / FBX | 低面数 RPG 全套，可直接改 |

- 100+ 免费低面角色、武器、建筑
- 适合 MVP 直接使用
- 已有绑定动画（idle/walk/attack）

#### 2.2 Sketchfab

[sketchfab.com](https://sketchfab.com)

搜索 → Filter → **Free Download**。

- 最大 3D 模型库
- 免费模型量大
- 导出 GLB 即可用

#### 2.3 Poly Pizza

[polypizza.com](https://polypizza.com)

- 全部免费 CC0
- 低面风格
- Tripo 旗下的免费库

---

## 第三部分：MVP 集成步骤

### 2D Lottie（当前）
```bash
# 下载后放入
cp ~/Downloads/animation.json habit-forge-app/assets/animations/character_idle.json

# 代码中使用
CharacterViewer(lottiePath: 'assets/animations/character_idle.json')

# Flutter 自带的热重载立即生效，不需要 hot restart
```

### 3D GLB（v2.0）
```bash
# 下载后放入
cp ~/Downloads/model.glb habit-forge-app/assets/glb/

# 代码中切换
CharacterViewer(lottiePath: null, glbPath: 'assets/glb/model.glb')
# CharacterViewer 支持双模式：Lottie 2D / O3D 3D
```

---

## 第四部分：动画清单（含获取来源）

| 文件 | 用途 | 推荐获取路径 | 难度 |
|------|------|-------------|------|
| `character_idle.json` | 角色待机 | LottieFiles 免费 / Rive 自制 | ⭐ |
| `character_victory.json` | 升级庆祝 | LottieFiles 免费 / AI Creator | ⭐ |
| `character_hit.json` | 受伤 | LottieFiles / AI Creator 生成 | ⭐⭐ |
| `character_death.json` | 倒地 | AI Creator 生成 / Rive 自制 | ⭐⭐ |
| `confetti_burst.json` | 撒花 | LottieFiles 免费（很多） | ⭐ |
| `coin_fly.json` | 金币飞入 | LottieFiles / Jitter 自制 | ⭐⭐ |
| `level_up_aura.json` | 光环扩散 | LottieFiles / AI Creator | ⭐⭐ |
| `task_complete_glow.json` | 完成扫光 | LottieFiles / Jitter 自制 | ⭐ |

**v2.0 3D 模型清单：**
| 模型 | 推荐获取 | 备注 |
|------|---------|------|
| Warrior 角色 | Meshy / Quaternius 免费 | 已有 Meshy GLB |
| Mage 角色 | Quaternius / Tripo | |
| Ranger 角色 | Quaternius / Meshy | |
| 武器皮肤 | Quaternius 免费武器包 | 6 把武器 |
| 防具皮肤 | Quaternius / Spline 自制 | 2 套装 |

---

## 第五部分：Icon 图标素材

应用内所有图标清单（当前使用 emoji 占位，可替换为 SVG/字体图标）：

### 5.1 图标清单

| 使用位置 | 当前 emoji | 建议替代方案 |
|---------|-----------|-------------|
| **BottomNav — Home** | 🏠 | home / house |
| **BottomNav — Quests** | 📜 | clipboard / list |
| **BottomNav — Forge** | ⚒️ | hammer / build |
| **BottomNav — Profile** | 👤 | person / user |
| **Home — Quick Shop** | 🛒 | shopping_cart |
| **Home — Quick Stats** | 📊 | bar_chart |
| **Home — Quick Achieve** | 🏆 | emoji_events / trophy |
| **Forge — Gold** | 🪙 | currency / coin |
| **Equipment — Weapon** | 🗡️ | shield / sword |
| **Equipment — Helmet** | 🎭 | masks / helmet |
| **Equipment — Armor** | 👔 | checkroom / armor |
| **Equipment — Accessory** | 💎 | diamond |
| **Profile — View Character** | 👤 | person |
| **Profile — Achievements** | 🏆 | emoji_events |
| **Profile — Statistics** | 📊 | bar_chart |
| **Profile — Settings** | ⚙️ | settings |
| **Settings — Reset** | 🗑️ | delete / trash |
| **Tasks — Priority P1** | — | flag / priority_high |
| **Tasks — Streak** | 🔥 | local_fire_department |
| **Reward — Level Up** | ✨ | auto_awesome / stars |
| **Reward — Achievement** | 🏆 | emoji_events / trophy |
| **Reward — Task Complete** | ✅ | check_circle |
| **Toast — Dismiss** | × | close |
| **Character Panel — Animate Idle** | — | play_circle |
| **Character Panel — Animate Victory** | — | celebration / stars |
| **Quest Tabs — Empty** | 📜 | assignment / note |

### 5.2 免费图标库（直接下载）

#### Phosphor Icons — 推荐（项目已引入）

[phosphoricons.com](https://phosphoricons.com)

| 费用 | 格式 | 数量 |
|------|------|------|
| **完全免费 MIT** | SVG / Flutter package | 9000+ |

- 项目已依赖 `phosphor_flutter: ^2.1.0`
- 用法：`PhosphorIcon(Phosphor.house(solid: true))`
- **建议方案**：所有图标统一换 Phosphor，替换掉 emoji

**图标映射示例：**
```dart
// 替换前（emoji）
IconData icon = Icons.home;  // 🏠

// 替换后（Phosphor）
PhosphorIcon(Phosphor.house(solid: true))
```

**MVP 推荐图标名对照：**
```
home         → Phosphor.house()
quests       → Phosphor.clipboardText()
forge        → Phosphor.wrench()
profile      → Phosphor.user()
shop         → Phosphor.storefront()
stats        → Phosphor.chartBar()
achievements → Phosphor.trophy()
settings     → Phosphor.gear()
gold         → Phosphor.coin()
equip weapon → Phosphor.sword()
equip armor  → Phosphor.shieldCheck()
delete       → Phosphor.trash()
close        → Phosphor.x()
check        → Phosphor.checkCircle()
fire/streak  → Phosphor.fire()
star/reward  → Phosphor.star()
search       → Phosphor.magnifyingGlass()
```

#### Material Icons（Flutter 内置，零开销）

[fonts.google.com/icons](https://fonts.google.com/icons)

- Flutter 自带，不需要加依赖
- 用法：`Icon(Icons.home)`
- 数量：2000+
- **适合 MVP 快速替换，比 emoji 好看**

#### Lucide

[lucide.dev](https://lucide.dev)

| 费用 | 格式 |
|------|------|
| **完全免费 MIT** | SVG / Flutter package `lucide_icons` |

- 1280+ 图标
- 线条风格，和 phosphor 类似

### 5.3 AI 生成自定义图标

以下平台可文本 → SVG 图标导出：

| 平台 | 免费额度 | 输出 | 适合 |
|------|---------|------|------|
| **Iconify AI** (iconify.ai) | 免费试用 | SVG | 生成 RPG 风格独特图标（剑、盾、法师帽） |
| **Midjourney** (midjourney.com) | 免费 25 次 | 图片 → 手动抠图 | 高质量但工作量大 |
| **DALL·E 3** (ChatGPT Plus) | 付费 | 图片 → 手动抠图 | 同上 |
| **UFO Generator** (u FO generator.net) | 免费 | SVG | 简单几何图标 |
| **Hugging Face SVG** (huggingface.co) | 完全免费 | SVG | 各种开源模型 |

**提示词模板（Iconify AI / Midjourney）：**
```
A simple glyph icon of a knight helmet, line art style, 
single color transparent background, 24x24 grid, 
dark fantasy theme, game UI icon
```

### 5.4 建议替换顺序

```
Phase 1（当前状态）:
  所有图标用 emoji — 功能已可用

Phase 2（上线前 — 推荐）:
  用项目已有的 phosphor_flutter 替换所有 emoji
  约 20 处替换，每处改 1 行
  效果：统一风格、矢量清晰、双色/填充可选

Phase 3（品牌化）:
  Iconify AI 生成 RPG 风格自定义图标集
  替换 phosphor 图标
```

---

## 第六部分：建议执行顺序

```
Phase 1 — 2D Lottie（MVP，当前）:
  Day 1: LottieFiles 下载 character_idle + confetti_burst
  Day 2: AI Creator 生成 victory + hit
  Day 3: 其余用 Flutter 动画降级（coin/aura/glow）

Phase 2 — 2D 完善（上线前）:
  LottieFiles 找齐全部 8 个动画
  或用 Rive 做 1 个包含 idle/victory/hit 的 .riv 文件

Phase 3 — 3D 升级（v2.0）:
  Meshy/Tripo 生成 3 职业 GLB
  Quaternius 下载免费装备
  恢复 O3D 包，CharacterViewer 切回 GLB 渲染
```
