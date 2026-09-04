---
name: flutter-theme-color-system
description: 为本 Flutter 项目建立/改造完整 Material 3 主题与配色系统（Light/Dark/System、ColorScheme、ThemeExtension 语义色、组件主题、硬编码清理与验收）。Use when designing or auditing theme/colors/tokens/components styling.
metadata:
  last_modified: 2026-09-04
---
# Flutter Theme & Color System Design

## 目标

为本 Flutter 项目建立一套完整、现代、可维护的主题与配色系统。

核心要求：

- 同时支持 Light Mode / Dark Mode
- 遵循 Flutter 官方 Material 3 设计体系
- 配色具有较高审美质量，而不是简单使用默认 Material 蓝色
- 提供多套可选主色方向
- 主色、辅助色、背景色、表面色、状态色必须形成完整色彩体系
- Light / Dark 必须分别设计，禁止简单反色
- UI 中禁止散落硬编码颜色
- 所有业务语义颜色必须进入统一 Theme 系统
- 支持系统自动切换 Light / Dark
- 支持未来更换品牌色而无需修改业务 UI
- 不引入不必要的第三方主题库

---

## 一、设计原则

### 1. Flutter 官方优先

主题系统必须优先使用：

- `ThemeData`
- `ColorScheme`
- `TextTheme`
- Material 3
- `ThemeExtension`

优先参考 Flutter 官方设计规范。

不要自行建立一套与 Flutter ThemeData 平行的主题体系。

### 2. 颜色必须语义化

禁止在业务 Widget 中直接出现：

```dart
Colors.blue
Colors.red
Colors.green
Colors.grey
Color(0xFF...)
```

除非该颜色属于明确的视觉常量或特殊插画。

推荐：

```dart
Theme.of(context).colorScheme.primary
```

或者：

```dart
final colors = Theme.of(context).extension<AppColors>()!;
```

例如：

```dart
colors.success
colors.warning
colors.info
colors.neutral
colors.medicalPositive
colors.medicalAttention
```

---

## 二、配色方向

设计主题时从下面方向中选择一个作为主视觉方向。不要机械使用示例颜色，需根据项目整体 UI、Logo、已有资源、页面截图和产品定位综合判断。

- **Palette A — Ocean Blue**：专业/医疗/科技/安全/长期使用舒适。适合健康管理、医疗、数据管理、AI、专业工具。方向：Primary Blue/Azure，Secondary Cyan/Teal，Tertiary Indigo。
- **Palette B — Teal Health**：健康/自然/清爽/温和，比传统医疗蓝更现代。适合慢病管理、健康管理、运动、饮食。方向：Primary Teal，Secondary Cyan，Tertiary Green。
- **Palette C — Indigo Intelligence**：AI/数据/科技/高级/数字化。适合 AI 健康助手、数据分析、智能管理。方向：Primary Indigo，Secondary Blue，Tertiary Violet。注意不要让 Purple/Violet 占据大量页面面积。
- **Palette D — Emerald Clinical**：健康/稳定/安全/生命感。方向：Primary Emerald/Green，Secondary Teal，Tertiary Blue。
- **Palette E — Blue + Violet**：现代/科技/高级/数字产品。方向：Primary Blue，Secondary Violet，Tertiary Cyan。
- **Palette F — Warm Neutral + Accent**：高级/温和/极简/长时间阅读舒适。基础 Background Warm Neutral、Surface Warm Gray、Primary Blue/Teal/Indigo、Accent 按产品选择。适合长期健康记录、日记、医疗记录。

---

## 三、颜色数量要求

最终主题不能只有 Primary/Secondary/Background/Error，必须建立完整颜色层级，至少包含 Material ColorScheme：

```text
primary / onPrimary / primaryContainer / onPrimaryContainer
secondary / onSecondary / secondaryContainer / onSecondaryContainer
tertiary / onTertiary / tertiaryContainer / onTertiaryContainer
error / onError / errorContainer / onErrorContainer
surface / onSurface
surfaceContainerLowest / surfaceContainerLow / surfaceContainer / surfaceContainerHigh / surfaceContainerHighest
onSurfaceVariant
outline / outlineVariant
inverseSurface / onInverseSurface / inversePrimary
scrim / shadow
```

具体字段以当前 Flutter SDK 为准，不要为兼容旧版本盲目复制旧 ColorScheme API。

---

## 四、业务语义颜色

使用 `ThemeExtension` 扩展业务颜色。至少设计：success / onSuccess / successContainer、warning / onWarning / warningContainer、info / onInfo / infoContainer、neutral / onNeutral / neutralContainer。健康管理项目额外考虑 healthGood / healthNormal / healthAttention / healthWarning / healthCritical、measurementNormal / measurementAbnormal、recordComplete / recordIncomplete、trendPositive / trendNegative / trendStable。

注意：这些颜色不能只依靠颜色表达含义，必须同时配合 Icon / Text / Label / Shape / Status indicator（例如「红色 ≠ 唯一的异常表达方式」）。

---

## 五、Light Mode 设计要求

Light Mode 不允许简单「背景 = White / Card = White」，必须建立 Surface 层级：Background ↓ Surface ↓ Surface Container ↓ Surface Container High ↓ Elevated Surface。不同层级通过色调/明度/边框/阴影/少量 elevation 建立层次。不要大量使用阴影，不要让整个页面充满 Card。

## 六、Dark Mode 设计要求

Dark Mode 必须单独设计。禁止 `darkColor = lightColor.invert()`，禁止简单 White → Black。推荐：Background → 深色中性/轻微色调；Surface → 稍亮；Surface Container → 更亮一级；Primary → 调整为适合深色背景的色调。必须保证内容层级清晰、Primary 不刺眼、大面积纯黑谨慎、不使用大面积纯白文字、边框不会过亮、状态色不产生视觉污染。使用多个 Dark Surface Tier：surface / surfaceContainerLowest / surfaceContainerLow / surfaceContainer / surfaceContainerHigh / surfaceContainerHighest。

---

## 七、主色生成规则

没有明确品牌色时优先 `ColorScheme.fromSeed(...)`，但**禁止认为 fromSeed 结果无需人工调整**，必须人工检查 Primary/Secondary/Tertiary/Surface/Container/Error/Outline/Dark Mode/Accessibility。自动生成效果不佳时改用显式 `ColorScheme.light(...)` / `ColorScheme.dark(...)`。

## 八、配色可选项

先从六个方向中选择，然后输出：

```text
Chosen Palette:
Primary / Secondary / Tertiary / Neutral / Success / Warning / Error / Info
```

并说明：为什么选择这个方案、为什么适合当前项目、Light Mode 视觉特点、Dark Mode 视觉特点。若项目已有品牌色，优先围绕品牌色重新生成体系。

---

## 九、Theme Architecture

推荐结构：

```text
lib/
└── core/
    └── theme/
        ├── app_theme.dart
        ├── app_colors.dart
        ├── app_typography.dart
        ├── app_spacing.dart
        ├── app_radius.dart
        └── extensions/
            └── app_colors_extension.dart
```

最终至少存在 `ThemeData lightTheme` / `ThemeData darkTheme`，并配置 `MaterialApp(theme: lightTheme, darkTheme: darkTheme, themeMode: ThemeMode.system)`；使用 `MaterialApp.router` 时按当前架构配置。

> 本项目落点映射（命名差异不构成另建体系）：`app_theme.dart` 已有；`app_colors.dart` ≈ `tokens/color_tokens.dart` + `tokens/accent_palette.dart`；`app_typography.dart` ≈ `tokens/typography_tokens.dart`；`app_spacing.dart` ≈ `tokens/spacing_tokens.dart`；`app_radius.dart` ≈ `tokens/radius_tokens.dart`；`extensions/app_colors_extension.dart` ≈ `tokens/color_tokens.dart`（ThemeExtension，医疗状态色）。

## 十、组件主题

不只改 ColorScheme，需检查并统一：AppBar / NavigationBar / NavigationRail / BottomSheet / Dialog / Card / 各类 Button / IconButton / FloatingActionButton / Input(TextField) / Checkbox / Radio / Switch / Slider / Chip / Badge / ListTile / Divider / ProgressIndicator / DatePicker / TimePicker / Tooltip。组件视觉属性必须优先来自 ColorScheme / TextTheme / ThemeData / ComponentTheme。

## 十一、硬编码颜色约束

业务 UI 原则上禁止 `Colors.blue / red / green / grey / black / white / Color(0xFF...)`，特别禁止 `Container(color: Color(0xFF123456))`，应改为 `Theme.of(context).colorScheme.primaryContainer` 或 `extension<AppColors>()`。

## 十二、禁止过度复杂的颜色系统

不要创建 `blue50…blue900` 原始色阶让业务自选；优先 semantic color 而非 raw color scale。错误 `Color(0xFF42A5F5)`，正确 `colorScheme.primary` / `appColors.warning`。

## 十三、主题切换

默认 System，同时支持 Light / Dark / System。项目已有设置页时应提供「跟随系统 / 浅色 / 深色」。不要在 UI 中自己判断 `MediaQuery.of(context).platformBrightness` 到处切颜色，统一由 ThemeMode / ThemeData / ColorScheme / ThemeExtension 管理。

## 十四、可访问性

所有颜色组合考虑文本对比度、Disabled / Focus / Hover / Pressed / Error 状态、Dark Mode、大字体、色觉差异。禁止仅通过红/绿区分状态：健康数据「正常」= 绿色 + 正常 Icon + 「正常」；「异常」= 红色 + Warning Icon + 「异常」。

## 十五、视觉约束

整体保持 Clean / Modern / Calm / Professional / Readable / Accessible / Consistent。避免大面积渐变、过度玻璃效果、过度阴影、过多彩色 Card、每页不同主色、彩虹式 Dashboard、过度圆角、过度动画、高饱和度背景、纯黑+纯白极端组合。

## 十六、颜色比例

推荐 70% Neutral/Surface、20% Primary/Secondary、10% Accent/Status。不要让 Primary/Success/Warning/Error/Info 同时大面积出现，状态色只用于表达状态。

## 十七、AI 修改现有项目时的规则

修改主题前：①检查当前 Flutter SDK 版本 ②检查现有 ThemeData ③检查已有 ColorScheme ④搜索项目硬编码颜色 ⑤检查已有 ThemeExtension ⑥检查页面截图与现有 UI ⑦检查是否已有品牌色。然后：分析 → 提出配色方案 → 选择 Palette → 建立 ColorScheme → Light Theme → Dark Theme → ThemeExtension → Component Themes → 替换硬编码颜色 → 检查所有页面 → 检查 Light/Dark → `flutter analyze` → `flutter test`。

## 十八、不要破坏业务逻辑

本技能只负责 Theme / Color / Typography / Spacing / Radius / Component Styling / Visual Consistency / Accessibility。禁止因为修改主题而修改 API / Database / Repository / Model / Business Logic / State Management / Routing / Authentication / Data Structure——除非视觉系统确实要求修改 UI 层接口。

## 十九、最终验收标准

Theme：Material 3 / Light Theme / Dark Theme / System Theme / ColorScheme / ThemeExtension / Component Themes。
Color：Primary / Secondary / Tertiary / Surface hierarchy / Error / Success / Warning / Info / Health semantic colors。
Code：删除业务 UI 中不必要的硬编码颜色、不创建重复 Theme 系统、不在 Widget 内自行判断 Light/Dark、不复制大量 raw color palette。
UI：Light/Dark 完整检查、主要页面视觉一致、Button/Card/Input/Navigation/Dialog-Sheet/状态色一致。
Quality：`flutter analyze`、`flutter test`；可运行时 `flutter run` 检查 Light/Dark/System/Large Text/Empty/Error/Loading 状态。

## 二十、最终输出

按以下格式报告，并确保主题修改覆盖整个项目而非只改首页：

```text
Theme Design
Selected Palette: …
Primary: …  Secondary: …  Tertiary: …
Light Mode: Background/Surface/Primary/Secondary …
Dark Mode: Background/Surface/Primary/Secondary …
Semantic: Success/Warning/Error/Info …
Architecture: ThemeData / ColorScheme / ThemeExtension …
Modified: - xxx …
Validation: flutter analyze: PASS/FAIL, flutter test: PASS/FAIL
```
