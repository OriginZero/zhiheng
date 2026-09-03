# 知衡 UI 风格文档

> 设计体系：**Flutter 官方 Design System + Material 3**（Flutter 3.47 / M3 默认）。
> Liquid Glass 自定义风格已整体移除（2026-09-03 v1.10.0 重构），不再作为 UI 基础。
> 本文档是 UI 的唯一权威；Design System 变更后必须同步更新。

---

## 1. 设计原则

1. **官方优先**：能用 Flutter 官方组件/主题解决的，不自定义实现。选型顺序：Flutter 官方文档 → Flutter 官方 Agent Skills（`.agents/skills/`）→ Material 3 / Cupertino → 本项目 Token → 页面需求。
2. 医疗可信优先：克制、清晰、现代、可信；**可读性 > 装饰，信息准确 > 视觉，性能 > 动画**。
3. **禁止用 BackdropFilter / ImageFilter.blur / ShaderMask / Opacity 制造毛玻璃或「高级感」**；页面背景为纯 ColorScheme 表面色，无环境渐变/光斑。
4. 页面禁止定义独立颜色/字体/圆角/间距体系；一律经 `Theme.of(context)` 与下方 Token。
5. 颜色不单独承载信息：状态必须配合图标/文字/形状（医疗可访问性）。

## 2. 主题（`lib/core/theme/app_theme.dart`）

- `AppTheme.light([palette])` / `AppTheme.dark([palette])`：`ColorScheme.fromSeed(seedColor: palette.brand, brightness)` 派生全套 tonal palette（亮/暗两套独立生成）。
- `scaffoldBackgroundColor = colorScheme.surface`；页面 Scaffold 不再自设透明背景。
- 组件主题集中配置：`AppBarTheme`（纯表面色、无 scrolled tint）、`NavigationBarTheme`（M3 官方底部导航，surfaceContainer 底 + secondaryContainer 指示器）、`CardTheme`（surfaceContainerLow 填充卡、12 圆角、零 margin/elevation）、`BottomSheetTheme`（surfaceContainerLow + 顶部 28 圆角 + M3 遮罩，无拖拽把手）、`DialogTheme`（surfaceContainerHigh、28 圆角）、`InputDecorationTheme`（filled：surfaceContainerHighest 底 + Outline 边框 + 12 圆角 + primary 聚焦）、`DividerTheme`、`SnackBarTheme`（floating）、按钮/进度/列表主题。明暗统一经同一份代码。
- `ColorScheme` 是业务颜色唯一来源：`primary/onPrimary`、`onSurface/onSurfaceVariant`、`outline/outlineVariant`、`surface/surfaceContainerLow/High/Highest`、`error/errorContainer`、`secondaryContainer` 等。

## 3. Design Tokens

| Token | 内容 | 位置 |
|---|---|---|
| ColorScheme | M3 语义色（见上），`fromSeed` 派生 | `app_theme.dart` |
| AccentPalette | 5 套强调色 seed：海盐蓝/薰衣草紫/薄荷青/珊瑚暖橙/鼠尾草绿（`brand` = seed） | `tokens/accent_palette.dart` |
| ColorTokens | **仅剩医疗状态色** normal/attention/warning/critical/success（M3 无对应角色，明暗各一套、对比 ≥4.5:1）；过渡期曾承载的角色已随页面迁移收敛 | `tokens/color_tokens.dart` |
| SpacingTokens | 4 的倍数额度：x1=4 … x16=64 | `spacing_tokens.dart` |
| RadiusTokens | small 8 / medium 12 / large 20 / xlarge 28 / pill | `radius_tokens.dart` |
| MotionTokens | 时长 fast 140ms / base 240ms / slow 420ms + 曲线 | `motion_tokens.dart` |
| TextTheme | 官方角色：displayLarge 34/700 … labelMedium 12/500（见 §5） | `app_theme.dart` |

**禁止在业务代码**：`Color(...)`、`TextStyle(...)`、`BorderRadius.circular(...)`、`BoxShadow(...)` 字面量；颜色经 `colorScheme`（状态色经 `extension<ColorTokens>()`），文字经 `textTheme`/`context.*Style`，间距/圆角经 Tokens。

**唯一例外**：照片缩略图/全屏图上的覆盖层（半透明黑遮罩、白色文字/角标、删除按钮）属「图像覆盖语义」，允许 `Colors.black/white` 直写并加注释——图像上叠加白字不是主题语义色能表达的。

## 4. 组件规范（官方 Widget 优先）

| 场景 | 使用 |
|---|---|
| 按钮 | `FilledButton`（主）、`FilledButton.tonalIcon`（次/图标）、`OutlinedButton`、`TextButton`（文字/危险弱操作）、`IconButton`（工具）；全宽用 `SizedBox(width: double.infinity)` 包裹 |
| 卡片/条目 | `Card`（信息卡、分组、模板卡）；列表行条目可用裸 Row/ListTile，不必每行套卡 |
| 输入 | `TextField`（filled 主题）；选择器 `DropdownButtonFormField`、日期/时间用官方 picker 触发按钮 |
| 单选/多选 | `ChoiceChip`、`FilterChip`、`RadioListTile`、`Switch`、`Checkbox`、`SegmentedButton`（按语义） |
| 弹层 | 一律官方 `showModalBottomSheet`（isScrollControlled: 内容超屏时）；**字段滚动区 + 底部主按钮钉底**（SafeArea(top:false) > Padding(bottom: viewInsets) > Column[min] > [Flexible(SingleChildScrollView), 按钮]），保证小屏/键盘下按钮可达 |
| 确认对话框 | `showDialog` + `AlertDialog`（经 `task_sheet.showConfirmDialog` 统一封装） |
| 列表 | `ListView.builder` / `ListView.separated`；长表性能敏感区用 builder，禁止整页 CustomScrollView 堆叠 |
| 空/载/错状态 | 统一 `AsyncStatusView` + `EmptyState`（`shared/widgets/async_status_view.dart`），页面不得手写三分支 |
| 底部导航 | 官方 `NavigationBar`（AppShell 内，3 tab：今日/时间线/我的），禁止自定义导航栏 |
| 页面骨架 | Shell 三 tab 页在 AppShell 壳内（无自身 Scaffold）；独立路由页自带 `Scaffold` + `AppBar` |

弹层完成记录通用外壳：`RecordCompletionSheet`（shared/widgets，标题/说明/备注/保存并完成 + 仅完成 + busy/结果），字段区由各模块提供。

## 5. 排版

系统字体（iOS SF / Android Roboto），不引入字体文件。统一 TextTheme 角色（字号与既有 34/28/22/16/14/12 尺度对齐）：

| 角色 | 字号/字重 | 用途 |
|---|---|---|
| displayLarge | 34 / w700 | 页首问候大标题 |
| headlineMedium | 28 / w700 | 大节标题 |
| headlineSmall | 22 / w600 | 区块标题 |
| titleLarge | 22 / w600 | AppBar / 对话框标题 |
| titleMedium | 16 / w600 | 卡内强调/列表标题 |
| bodyLarge | 16 / w400 | 正文 |
| bodyMedium | 14 / w400 | 次要正文/描述 |
| bodySmall | 12 / w400 | 辅助文字（配 onSurfaceVariant） |
| labelLarge | 14 / w500 | 标签/按钮 |
| labelMedium | 12 / w500 | 小标签 |

业务代码沿用 `context.*Style` 扩展（`typography_tokens.dart`，已映射到上述角色，颜色从 textTheme/colorScheme 派生），或直接 `Theme.of(context).textTheme.*`。**不使用** displaySmall 以上（45/57px）大号角色。

## 6. 色彩用法要点

- 正文：`onSurface`；次级文字/说明：`onSurfaceVariant`；描边/分隔：`outlineVariant`（divider）；图标默认色：`onSurfaceVariant`。
- 选中/主操作：`primary/onPrimary`；选中底（chip/指示器）：`secondaryContainer`（官方语义）或 `primaryContainer`。
- 输入框底：主题自带 `surfaceContainerHighest`；内嵌浅卡：`surfaceContainerLow/High`。
- 医疗状态：正常 `normal`、注意 `attention`、警告 `warning`、严重 `critical`、良好 `success` 走 `extension<ColorTokens>()`；低血糖/不良事件等**警示面**用 `errorContainer/onErrorContainer`（严重用 `error/onError`）。
- 背景层级（亮/暗同构）：surface < surfaceContainerLow < surfaceContainerHigh < surfaceContainerHighest。

## 7. 动效

- 快、克制、有目的；系统/组件默认动画即满足（页面转场、弹层、水波纹、NavigationBar 指示器）。
- 自定义动画时长/曲线一律走 MotionTokens；不做无限动画、不做 Blur/Shader 动画。
- 尊重 `MediaQuery.disableAnimations`（Reduce Motion）与系统无障碍缩放。

## 8. 响应式与可访问性

- 手机/小屏/平板/横竖屏：LayoutBuilder / MediaQuery / SafeArea / Flexible / Expanded / Wrap / Sliver；**禁止固定屏宽高**（`width: 390` 类硬编码）与无意义定宽。允许的定值仅：头像/色板/照片缩略图等**固定内容块**。
- 点击区域 ≥ 48×48（IconButton 默认满足）；`Tooltip`/`Semantics` 标注；可点卡片用 InkWell 保证水波纹与语义；不依赖颜色传信息；文案与布局在字体放大下不溢出（弹层可滚动、正文可换行）。
- 明暗双主题在设置页切换（跟随系统/浅色/深色），配色 5 选 1 即时生效并持久化（`theme_mode`/`accent_palette` 偏好键，勿改）。

## 9. 迁移/收敛状态（v1.10.0）

- Liquid Glass 全移除：`lib/shared/widgets/glass/` 目录、`GlassTokens` 已删除；全库无 BackdropFilter/ImageFilter.blur。
- `ColorTokens`（ThemeExtension）仅为医疗状态色保留；历史角色字段（fill/brand/textPrimary…）已随页面迁移收敛删除——若页面再出现 `extension<ColorTokens>().fill` 之类取用即视为回归（应改 colorScheme 角色）。
- 业务禁引 `glass` 相关命名（`showConfirmDialog` 为唯一历史命名残留，语义=统一确认对话框）。
