# 知衡 UI 风格文档

> 设计语言：Apple Liquid Glass 启发（§21），**参考但不机械复制**。
> 本文档是 UI 的唯一权威；Design System 变更后必须同步更新。

---

## 1. 设计原则（§21、§50）

1. 目标：通过材质、层级、空间、光线和运动建立**清晰的信息层级**，不是「把所有东西变透明」。
2. 医疗可信优先：高级、克制、清晰、现代、可信。
3. **可读性 > 玻璃效果；信息准确性 > 视觉效果；性能 > 动画**（§50）。
4. 禁止：过度炫技、满屏玻璃、过度透明、高饱和渐变、大量发光/阴影、玻璃套玻璃。

## 2. 视觉层级（§23，最多 3 层）

| 层级 | 用途 | 实现 |
|---|---|---|
| Level 1 | 背景 | `GlassBackground`：柔和渐变 + 环境光斑（随强调色变化） |
| Level 2 | 主玻璃表面 | `GlassSurface` / `GlassCard`（半透明 + 高光） |
| Level 3 | 交互元素 | `GlassButton` / Chip / 底部导航 |

**禁止 Glass 嵌套 Glass**（如 GlassCard 内再套 GlassSurface）。

## 3. Glass 组件（§22、§49）

所有玻璃效果**唯一实现**在 `lib/shared/widgets/glass/`：

| 组件 | 用途 | 要点 |
|---|---|---|
| GlassSurface | 玻璃基础层 | 唯一允许 BackdropFilter 的地方；`staticSurface` 变体无 blur（长列表性能，§51） |
| GlassCard | 内容卡片 | 业务页面默认容器，默认静态（无 blur） |
| GlassButton | 按钮 | primary（品牌色）/ glass（玻璃质感）/ plain（文字） |
| GlassNavigation | 底部导航 | 悬浮胶囊形态，3 个入口；浅色模式需发丝描边（GlassTokens.navigationBorderLight）勾勒轮廓，仅靠白玻璃明度差在米白背景下不可辨 |
| GlassSheet | 底部弹层 | 拖拽指示条 + 圆角顶 |
| GlassDialog | 对话框 | 渐入 + 缩放过渡 |
| GlassBackground | 页面背景 | Level 1 渐变 + 环境光斑 |

**业务页面禁止**：直接写 BackdropFilter、ImageFilter.blur、Container decoration 渐变/阴影/边框（视觉集中在 Design System）。

## 4. Design Tokens（§48，禁止裸值）

| Token | 内容 | 位置 |
|---|---|---|
| ColorTokens | 中性背景 + 次级填充面（fill/fillStrong）+ 语义状态色（normal/attention/warning/critical/success 固定含义） | `core/theme/tokens/color_tokens.dart` |
| AccentPalette | 5 套强调色（海盐蓝/薰衣草紫/薄荷青/珊瑚暖橙/鼠尾草绿），亮暗各一档 | `accent_palette.dart` |
| SpacingTokens | 4 的倍数额度：x1=4 … x16=64 | `spacing_tokens.dart` |
| RadiusTokens | small/medium/large/xlarge/pill | `radius_tokens.dart` |
| TypographyTokens | display/title/headline/body/label/caption + context 扩展样式 | `typography_tokens.dart` |
| GlassTokens | blur/opacity/border/highlight/shadow 参数 | `glass_tokens.dart` |
| MotionTokens | 时长（fast 140ms/base 240ms/slow 420ms）+ 曲线 | `motion_tokens.dart` |

**禁止在业务代码**：`Color(...)`、`TextStyle(...)`、`BorderRadius.circular(...)`、`BoxShadow(...)`。颜色经 `Theme.of(context).extension<ColorTokens>()!`（`colors.brand` 等）；文字经 `context.bodyStyle` 等扩展；间距/圆角经 Tokens。

**填充面 vs 描边色（v1.8.1 硬规则）**：`divider` 是半透明**描边/分隔线**色（亮色黑低透、暗色白低透），对它 `withValues(alpha:)` 会覆盖原透明度得到 50% 实黑/实白，导致浅色模式黑底、深色模式白底的明暗反转。需要**填充面**（输入框底色、未选中 Chip、内嵌卡片、日期按钮）一律用 `colors.fill`（需要分层时 `colors.fillStrong`）；`divider` 只用于 Border/分隔线。

## 5. 色彩规范（§24）

1. 中性背景 + 低饱和品牌色 + 语义状态色；不用满屏蓝/绿。
2. 状态色语义固定且全局一致：normal/attention/warning/critical/success。
3. **颜色不能只靠色彩区分**：必须同时使用 icon / text / shape / label（可访问性）。

## 6. 排版（§25）

- 系统字体（iOS SF Pro / Android Roboto），不引入特殊字体。
- 统一 Scale：Display 34 / Title 28 / Headline 22 / Body 16 / Label 14 / Caption 12。

## 7. 动效（§28）

- 快、克制、有目的；时长走 MotionTokens。
- 适合：页面转场、Glass 层级变化、任务完成、数据刷新、Bottom Sheet、卡片展开。
- 禁止：长时间动画、过度弹跳、无意义粒子、大量光效。

## 8. 响应式与可访问性（§29、§30）

- LayoutBuilder / MediaQuery / SafeArea / Flexible / Expanded / Sliver；禁止宽度硬编码。
- 点击区域 ≥ 48×48（底部导航、任务勾选等）；支持 Dynamic Type / 字体放大；VoiceOver / TalkBack 语义（Semantics 标注）；不依赖颜色传信息；考虑 Reduce Motion。
- 主题明暗 + 强调色组合满足对比度（暗色模式自动用品牌高亮色）。

## 9. 页面风格约定

1. 页面背景统一 `GlassBackground`；内容容器统一 `GlassCard`。
2. 空状态必须说明：没有数据 → 为什么 → 下一步（`EmptyState`，§39）。
3. 异步状态统一 `AsyncStatusView`（Loading/Empty/Error，§38）。
4. 底部弹层统一 GlassSheet 风格（顶部圆角 + 拖拽条 + 键盘避让）。
