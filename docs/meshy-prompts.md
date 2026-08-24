# HabitForge · Meshy.ai 角色生成提示词（3 职业 × Q 版）

> 用途：在 [meshy.ai](https://meshy.ai) 生成 3D 角色模型（GLB），用于角色视口。
> 风格：**半头身 Q 版（1:1 头身比）、全覆盖装备、中性角色、暗黑奇幻**。
>
> 关键原则：不表现性别。每个职业靠 silhouette 和装备轮廓区分，非面部/体型。

---

## 关键技巧：用 Image to 3D 代替 Text to 3D

Meshy 的 **Text to 3D** 对 Q 版理解很差，总是偏向写实比例。**推荐 Image to 3D：**

```
操作步骤：
1. 用豆包生成角色正面图（确保全装备覆盖、面部遮挡）
2. 打开 meshy.ai → Image to 3D
3. 右上角 Mode 选 "Stylized"
4. 上传豆包生成的图片
5. Art Style 选 "Anime / Cartoon"
6. 点击生成
```

推荐参考图搜索关键词（Google Images / Pinterest）：
- `"full plate helmet knight chibi"` — 全闭面甲骑士
- `"hooded mage conceal face"` — 遮面法师
- `"scarf hood archer"` — 围巾兜帽弓箭手

选角色剪影清晰、装备全覆盖、面部不可见的。

---

## 核心前缀（所有角色共用）

```
Chibi style 3D character, 2-head proportion, big round head same size as body,
fully armored with no exposed skin, no face visible, neutral silhouette,
thick outlines, cel-shaded cartoon render, dark fantasy theme,
purple and gold color scheme, solid white background, front view,
3D game asset, cute collectible figure style
```

---

## 三大职业提示词

### 1 · Warrior — 剪影 ▧ 矩形

全闭面甲 + 厚板甲 + 宽大垫肩，身体轮廓呈矩形。

```
Chibi warrior 3D figure, 2-head proportion, massive round head,
full plate armor with enclosed helmet, no face visible,
visor slit only, oversized shoulder pauldrons creating wide rectangular silhouette,
holding a large sword and shield, bulky armored body,
dark purple and gold armor, thick outlines, cel-shaded,
Pop Mart collectible figure style, white background, front view
```

### 2 · Mage — 剪影 ▩ A 字梯形

尖顶宽檐帽/深兜帽遮住大半脸 + 阔袖长袍拖地，身体呈 A 字形。

```
Chibi mage 3D figure, 2-head proportion, massive round head,
oversized pointed wide-brim hat covering most of face, face in shadow,
long flowing wizard robe completely hiding body shape,
wide sleeves, robe drapes to floor hiding feet,
holding a tall magical staff taller than body,
dark purple robe with gold trim, thick outlines, cel-shaded,
Pop Mart collectible figure style, white background, front view
```

### 3 · Ranger — 剪影 ▰ 菱形

深兜帽 + 围巾遮住口鼻 + 贴身披风，身体呈窄菱形。

```
Chibi ranger 3D figure, 2-head proportion, massive round head,
deep hood covering eyes, scarf wrapped around lower face,
close-fitting leather armor, short cloak creating narrow silhouette,
carrying a longbow taller than body, quiver on hip,
dark green and gold armor, thick outlines, cel-shaded,
Pop Mart collectible figure style, white background, front view
```

---

## 备选方案

| 方案 | 说明 |
|------|------|
| Tripo | tripo3d.com，每月 50 积分免费，对 Q 版效果更好 |
| Blender 微调 | AI 模型导入 Blender → 头部放大 1.5x，身体压扁 0.6x → 导出 GLB |

---

## Negative Prompt

```
no realistic proportions, no long legs, no slender body,
no exposed skin, no visible gender features,
no face detail, no eyes visible, no realistic armor texture,
no photo-real, no horror, no scary, no background,
no watermark, no extra objects
```

## Meshy 设置

| 项 | 建议 |
|---|---|
| 模式 | **Image to 3D > Stylized**（不要选 Realistic） |
| 纹理 | PBR 1K |
| 导出 | GLB |
