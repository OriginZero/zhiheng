# AGENTS.md

## 项目基本信息

**APP 名称：知衡**

**项目名称：zhiheng**

**定位：长期慢性病管理 APP**

这是一个基于 **Flutter + Dart** 开发的跨平台患者慢性病管理 APP。

当前阶段：

- 无后端
- 纯 Flutter 客户端
- 本地存储
- 优先完成 MVP
- 后续再扩展后端、医疗 AI、医生端和数据同步

核心目标：

> 帮助患者长期记录疾病、治疗、用药、检查和症状，并根据既定管理计划生成任务、提醒和趋势信息。

---

## 当前重点

第一阶段优先实现：

1. 患者档案
2. 疾病管理
3. 治疗计划
4. 今日任务
5. 提醒
6. 医疗时间线
7. 数据记录
8. 白癜风
9. 308nm 光疗记录
10. 治疗部位、剂量、时间及治疗后反应
11. 图片记录
12. 基础趋势分析

暂不实现：

- 后端 API
- 云端账号体系
- 医院系统
- FHIR
- 医生端
- 第三方医疗 AI
- 云端数据同步

架构需要为未来扩展预留空间，但当前不要提前实现复杂基础设施。

---

## Flutter 架构

采用 Feature-based Architecture：

```text
lib/
├── app/
├── core/
│   ├── theme/
│   ├── routing/
│   ├── storage/
│   └── utils/
├── features/
│   ├── home/
│   ├── patient/
│   ├── disease/
│   ├── care_plan/
│   ├── task/
│   ├── timeline/
│   ├── treatment/
│   ├── phototherapy/
│   └── settings/
└── shared/
```

推荐使用 **Riverpod** 进行状态管理。

业务逻辑不要直接写在 Widget 中。

推荐：

```text
UI
 ↓
Controller / Notifier
 ↓
UseCase / Domain
 ↓
Local Repository
 ↓
Local Storage
```

---

## 核心数据模型

围绕以下模型设计：

```text
Patient
Disease
Diagnosis
CarePlan
Treatment
Medication
Task
Reminder
Event
Measurement
Symptom
Photo
Appointment
```

重要患者行为尽量形成结构化 Event，并支持医疗时间线。

疾病模块必须可扩展。

当前重点疾病：

- 白癜风
- 2 型糖尿病

---

## 医疗安全

这是患者健康管理产品。

禁止：

- 编造医学结论
- 无依据制定治疗方案
- 自行修改药物剂量
- 自行决定 308nm 光疗剂量
- 将 AI / 算法输出包装成医学诊断

医学规则应有明确来源：

- 临床指南
- 专家共识
- 药品说明书
- 官方医学机构资料
- 医生制定的治疗方案

当前版本主要进行：

> **记录、提醒、展示和趋势整理。**

---

## UI / Design System

视觉风格采用 **Apple Liquid Glass / 透明玻璃质感**。

要求：

- 建立统一 Design System
- 统一颜色、字体、间距、圆角、Blur、透明度
- Glass 效果集中封装
- 业务页面不要重复实现玻璃效果
- 保持统一视觉层级
- 避免过度透明、模糊和动画
- 优先保证可读性和性能

推荐统一组件：

```text
GlassSurface
GlassCard
GlassButton
GlassNavigation
GlassSheet
GlassDialog
```

不要为了视觉效果牺牲医疗信息的清晰度。

---

## 开发规则

修改代码前：

1. 阅读现有代码
2. 理解当前架构
3. 搜索是否已有组件
4. 优先复用
5. 保持现有设计语言

禁止：

- 巨型 Widget
- God Class
- 重复实现相同功能
- 在 Widget 中处理复杂业务逻辑
- 随意增加依赖
- 大量魔法数字
- 使用 Mock 数据伪装真实功能
- 为未来后端需求提前引入复杂架构

完成修改后：

- 检查编译
- 运行相关测试
- 检查 UI 一致性
- 检查是否破坏已有功能

---

## 数据隐私

患者数据属于敏感数据。

必须：

- 最小化收集
- 安全存储
- 不在普通日志中输出患者信息
- 医疗照片注意本地访问权限
- 不在 Debug 日志中输出完整医疗数据

---

## 开发优先级

```text
基础架构
→ Design System
→ Patient / Disease / CarePlan
→ Task / Reminder / Event / Timeline
→ 白癜风 / 308nm 光疗
→ Patient State / Clinical Rules
→ 医疗 AI
→ 糖尿病
→ FHIR / 第三方医疗 AI
```

不要在基础架构尚未稳定时提前实现复杂 AI 功能。

---

## 核心原则

> **先把本地 MVP 做完整，再扩展后端。**

> **数据结构化优先于 AI。**

> **提醒是结果，不是核心。**

> **医学规则必须有依据。**

> **AI 可以解释，但不能凭空创造医学规则。**

> **Liquid Glass 服务于信息层级，而不是为了玻璃而玻璃。**

> **不确定的医学问题不要猜。**

**产品名称始终使用「知衡」，项目标识使用 `zhiheng`。**