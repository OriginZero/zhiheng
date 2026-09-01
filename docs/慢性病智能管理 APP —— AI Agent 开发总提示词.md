# 慢性病智能管理 APP —— AI Agent 开发总提示词

## 1. 项目定位

你正在参与开发一个面向患者的 **跨平台慢性病长期管理 APP**。

技术栈：

- Flutter
- Dart
- Android
- iOS
- 后续可扩展 Web / Desktop，但当前优先保证 iOS / Android
- 后端 API 与客户端解耦
- UI 风格参考 Apple 最新系统设计语言，采用 **Liquid Glass / 透明玻璃质感**
- 产品重点不是普通的“吃药提醒”，而是：

> **帮助患者长期执行疾病管理计划，持续记录治疗与健康数据，根据医学规则和患者历史数据生成个性化任务、趋势和风险提示，并为未来医疗 AI 提供结构化、高质量的患者数据。**

---

# 2. 核心产品理念

不要把产品理解成：

> Reminder App

而应该理解成：

> **Patient Chronic Care Management System**

核心闭环：

```text
疾病
 ↓
治疗方案
 ↓
管理计划
 ↓
每日任务
 ↓
患者执行
 ↓
产生数据
 ↓
趋势分析
 ↓
医学规则
 ↓
状态判断
 ↓
下一步任务
 ↓
持续管理
```

最终形成：

```text
Plan
 ↓
Action
 ↓
Event
 ↓
Data
 ↓
Analysis
 ↓
Recommendation
 ↓
Next Action
```

整个产品的核心不是提醒，而是这个闭环。

---

# 3. 医疗安全边界

这是医疗相关产品，必须严格区分：

### A. 信息记录

可以做：

- 患者输入
- 治疗记录
- 用药记录
- 血糖记录
- 血压记录
- 症状记录
- 图片记录
- 检验结果
- 医生诊疗方案

### B. 医学规则

可以做：

- 根据已验证的指南 / 专家共识 / 医生制定方案生成提醒
- 判断是否应该记录某项数据
- 判断是否应该复诊
- 判断是否存在需要关注的趋势
- 判断是否遗漏治疗任务

### C. AI

AI 可以：

- 总结患者历史数据
- 解释趋势
- 整理医疗时间线
- 根据可信医学知识生成辅助说明
- 帮助患者理解医生方案
- 辅助生成就医时可以提供给医生的病情摘要

AI 不应该在没有经过医学验证和授权的情况下：

- 自行诊断疾病
- 自行修改处方
- 自行决定药物剂量
- 自行决定光疗剂量
- 自行替代医生
- 将概率预测包装成医学诊断
- 将模型生成内容包装成确定性医学结论

涉及具体治疗方案时，优先遵循：

```text
医生方案
>
经过验证的医学规则
>
医学知识库
>
AI 辅助解释
```

而不是：

```text
LLM 自己决定治疗方案
```

---

# 4. 第一阶段疾病

第一阶段重点支持：

## 白癜风

重点场景：

### 308nm 光疗

需要支持：

- 治疗日期
- 治疗时间
- 治疗设备
- 治疗部位
- 单次剂量
- 剂量单位
- 左右身体部位
- 身体部位细分
- 治疗前照片
- 治疗后照片
- 红斑
- 红斑开始时间
- 红斑持续时间
- 疼痛
- 瘙痒
- 灼热
- 水疱
- 其他不良反应
- 医生备注
- 患者备注

注意：

**不要把具体光疗剂量、治疗频率、疗程周期直接硬编码为医学事实。**

这些内容应该来自：

```text
医生制定方案
+
医学知识库
+
经过验证的 Clinical Rule
```

APP 可以根据已有方案生成：

```text
下一次治疗任务
治疗记录提醒
异常反应提醒
复诊提醒
疗程阶段提醒
```

但不能自行把未经验证的规则包装成治疗指令。

---

# 5. 第二阶段疾病

第二阶段支持：

## 2 型糖尿病

数据模型需要预留：

### 血糖

- 空腹血糖
- 餐前血糖
- 餐后血糖
- 睡前血糖
- 随机血糖
- 血糖单位
- 测量时间
- 与进餐的关系

### CGM

预留：

- CGM 数据导入
- Time in Range
- Time Below Range
- Time Above Range
- 平均葡萄糖
- 血糖波动
- 低血糖事件
- 高血糖事件

### 实验室检查

例如：

- HbA1c
- 空腹血糖
- 肌酐
- eGFR
- 尿白蛋白 / 肌酐比
- 血脂

### 其他

- 药物
- 用药依从性
- 饮食
- 运动
- 体重
- 血压
- 睡眠
- 症状
- 低血糖事件
- 医生随访
- 并发症筛查

数据结构必须允许未来增加新的疾病指标。

---

# 6. 通用疾病模型

不要针对每个疾病单独设计完全独立的数据体系。

核心模型：

```text
Patient
 ├── Disease
 │     └── Diagnosis
 │
 ├── CarePlan
 │     ├── Goal
 │     ├── Treatment
 │     ├── Medication
 │     └── MonitoringPlan
 │
 ├── Event
 │     ├── TreatmentEvent
 │     ├── MedicationEvent
 │     ├── MeasurementEvent
 │     ├── SymptomEvent
 │     ├── LabEvent
 │     ├── PhotoEvent
 │     ├── ExerciseEvent
 │     └── AdverseEvent
 │
 ├── Task
 ├── Reminder
 ├── Appointment
 ├── ClinicalNote
 └── AIAnalysis
```

核心思想：

> **疾病不同，但长期管理的抽象模型尽可能统一。**

---

# 7. Event First 设计

整个系统优先采用 **Event / Timeline** 思想。

例如：

```text
2026-09-01 08:00
MedicationEvent
Metformin 500mg
Taken
```

或者：

```text
2026-09-01 10:00
PhototherapyEvent
308nm
Left Hand
Dose: xxx
```

或者：

```text
2026-09-01
LabEvent
HbA1c
6.8%
```

所有重要患者行为都尽可能形成结构化 Event。

Event 应包含：

```text
id
patientId
diseaseId
eventType
occurredAt
createdAt
source
status
payload
attachments
notes
```

但对于高频、强类型数据，不要为了追求 Event 抽象而牺牲数据库查询效率。

必要时可以采用：

```text
统一 Event
+
疾病专用结构化表
```

混合模式。

---

# 8. 患者状态模型

系统应该能够根据历史事件构建：

```text
Patient State
```

例如：

```text
Current Diseases
Current Treatments
Current Medications
Current Goals
Recent Measurements
Recent Symptoms
Recent Adverse Events
Adherence
Risk Signals
Pending Tasks
Upcoming Appointments
```

不要让 AI 每次直接读取大量原始数据库记录。

应该先生成：

```text
Patient Summary
```

再提供给 AI。

---

# 9. 医疗时间线

必须设计统一的医疗时间线：

```text
诊断
 ↓
治疗开始
 ↓
治疗事件
 ↓
检查
 ↓
症状
 ↓
治疗调整
 ↓
复诊
 ↓
治疗效果
```

时间线必须支持：

- 按疾病过滤
- 按时间过滤
- 按事件类型过滤
- 查看事件详情
- 图片事件
- 检验数据
- 治疗事件
- 用药事件

时间线是患者和医生理解长期疾病变化的重要入口。

---

# 10. 今日任务系统

首页核心不是文章，而是：

# Today

例如：

```text
今日管理

必须完成
✓ 早晨用药
○ 测量空腹血糖
○ 308nm 光疗

建议完成
○ 记录运动
○ 拍摄患处照片

需要关注
⚠ 最近三次数据出现异常趋势

即将到期
○ 复诊
```

Task 来源必须可追踪：

```text
DoctorPlan
ClinicalRule
CarePlan
MedicationSchedule
MonitoringPlan
UserCreated
```

不要让 Task 来源全部变成 AI。

---

# 11. Reminder Engine

提醒系统应该建立在 Task 上。

不要直接：

```text
Reminder → Notification
```

而应该：

```text
CarePlan
 ↓
Task
 ↓
Reminder
 ↓
Notification
```

这样可以支持：

- 一次性任务
- 每日任务
- 每周任务
- 周期任务
- 条件任务
- 延迟任务
- 重复任务
- 依赖任务
- 完成后触发下一任务

例如：

```text
完成光疗
 ↓
等待治疗后反应记录
 ↓
24h 后提醒记录红斑
```

---

# 12. Clinical Rule Engine

医学规则必须和 UI 分离。

不要在 Flutter Widget 中出现：

```dart
if (bloodSugar > xxx) {
   ...
}
```

医学规则必须位于独立业务层。

建议抽象：

```text
ClinicalRule
 ├── id
 ├── disease
 ├── version
 ├── source
 ├── evidenceLevel
 ├── conditions
 ├── actions
 ├── priority
 └── effectiveDate
```

规则必须支持版本管理。

例如：

```text
Rule
v1
 ↓
医学指南更新
 ↓
Rule
v2
```

历史记录不能因为规则升级而改变历史事实。

---

# 13. 医学知识库

建立独立的 Clinical Knowledge Base。

来源包括：

- 临床指南
- 专家共识
- 药品说明书
- 临床路径
- 官方医学机构资料
- 高质量医学文献

每条知识至少记录：

```text
source
title
organization
publicationDate
version
effectiveDate
disease
recommendation
population
evidenceLevel
reference
lastReviewed
```

知识库必须支持版本化。

不要把医学知识散落在：

- Dart
- Flutter Widget
- SQL
- Prompt
- AI Agent Memory

中。

---

# 14. AI Architecture

AI 不是系统的唯一决策中心。

推荐：

```text
Patient Data
      ↓
Patient State
      ↓
Clinical Rules
      ↓
Clinical Summary
      ↓
RAG / Medical Knowledge
      ↓
Medical AI
      ↓
Explanation / Summary / Assistance
```

AI 主要负责：

### 1. Summary

把长期数据总结成人类容易理解的语言。

### 2. Trend Analysis

解释：

- 上升
- 下降
- 波动
- 变化速度
- 异常趋势

### 3. Timeline Summary

自动总结：

> 最近三个月发生了什么。

### 4. Doctor Visit Summary

生成患者就医时可以给医生看的：

```text
疾病
治疗
近期症状
近期指标
异常事件
用药依从性
患者主要问题
```

### 5. Medical Q&A

基于可信医学知识回答患者问题。

所有医学回答尽量：

```text
结论
依据
不确定性
建议
何时应该就医
```

---

# 15. 第三方医疗 AI 数据接口

从第一天开始考虑数据授权。

患者可以授权：

```text
第三方 AI A

允许：
✓ 白癜风数据
✓ 最近180天治疗记录
✓ 治疗照片
✓ 医生方案

禁止：
✗ 糖尿病数据
✗ 身份信息
✗ 其他疾病
```

数据输出采用独立 DTO：

```text
PatientAIContext
DiseaseAIContext
TreatmentAIContext
TimelineAIContext
MeasurementAIContext
```

不要允许第三方 AI 直接访问数据库。

---

# 16. FHIR 兼容性

未来可能与医院、医生平台、医疗 AI 对接。

内部数据模型应参考：

- Patient
- Condition
- Observation
- Medication
- MedicationRequest
- Procedure
- DiagnosticReport
- CarePlan
- Appointment

等 HL7 FHIR 核心资源的设计思想。

第一版不要求完整实现 FHIR。

但是 API 和数据库设计不要与 FHIR 思想严重冲突。

---

# 17. Flutter 技术架构

Flutter 使用：

```text
Presentation
 ↓
Application
 ↓
Domain
 ↓
Data
```

推荐：

```text
lib/
├── app/
├── core/
│   ├── theme/
│   ├── routing/
│   ├── networking/
│   ├── storage/
│   ├── errors/
│   └── utils/
│
├── features/
│   ├── auth/
│   ├── home/
│   ├── patient/
│   ├── disease/
│   ├── care_plan/
│   ├── task/
│   ├── reminder/
│   ├── timeline/
│   ├── measurement/
│   ├── medication/
│   ├── treatment/
│   ├── phototherapy/
│   ├── diabetes/
│   ├── ai/
│   └── settings/
│
└── shared/
```

采用 Feature-based Architecture。

禁止：

```text
一个巨大的 widgets/
一个巨大的 services/
一个巨大的 utils/
```

---

# 18. 状态管理

优先使用成熟、可测试的状态管理方案。

推荐：

```text
Riverpod
```

要求：

- UI 不直接操作 Repository
- UI 不直接请求 HTTP
- UI 不包含业务规则
- State 与 Widget 解耦
- Provider 可测试
- Async 状态明确

---

# 19. Repository Pattern

推荐：

```text
UI
 ↓
Controller / Notifier
 ↓
UseCase
 ↓
Repository
 ↓
Remote / Local DataSource
```

例如：

```text
PhototherapyPage
 ↓
PhototherapyController
 ↓
CreatePhototherapyRecord
 ↓
PhototherapyRepository
 ↓
API / Local Database
```

---

# 20. Offline First

患者管理 APP 不应该完全依赖网络。

至少支持：

```text
本地查看最近数据
本地创建记录
本地创建任务
本地完成任务
网络恢复后同步
```

数据同步必须考虑：

- createdAt
- updatedAt
- version
- syncStatus
- deviceId
- conflict resolution

不要简单使用：

```text
last write wins
```

解决所有冲突。

医疗数据需要保留历史。

---

# 21. UI / UX 总体风格

APP 使用：

# Apple Liquid Glass Inspired

注意：

> **参考 Apple 最新系统的透明玻璃设计语言，但不要机械复制 Apple 官方 UI。**

整体特点：

- translucent
- layered
- depth
- blur
- material
- soft lighting
- rounded geometry
- floating surfaces
- subtle border
- strong typography hierarchy
- calm medical aesthetic

整体感觉：

```text
高级
克制
清晰
现代
医疗
可信
```

不要：

- 过度炫技
- 满屏玻璃
- 过度透明
- 高饱和渐变
- 大量发光
- 大量阴影
- 玻璃套玻璃
- 为了玻璃效果牺牲可读性

---

# 22. Liquid Glass 视觉规则

建立统一 Design System。

### Glass Material

所有玻璃组件必须遵循统一参数体系：

```text
blur
opacity
border
shadow
cornerRadius
highlight
tint
```

不要每个 Widget 自己随便设置。

例如：

```text
GlassSurface
GlassCard
GlassButton
GlassNavigationBar
GlassBottomSheet
GlassDialog
```

统一实现。

---

# 23. 玻璃层级

最多设计 3 个主要视觉层级：

### Level 1

背景：

```text
subtle gradient
soft color field
ambient light
```

### Level 2

主要 Glass Surface：

```text
large translucent surface
```

### Level 3

交互元素：

```text
button
chip
floating control
```

不要出现：

```text
Glass
 └── Glass
      └── Glass
           └── Glass
```

导致视觉混乱。

---

# 24. 医疗 APP 色彩规范

不要采用传统医疗 APP 的：

```text
满屏蓝色
满屏绿色
```

建议使用：

```text
Neutral background
+
低饱和品牌色
+
疾病状态色
```

状态颜色必须语义统一：

```text
Normal
Attention
Warning
Critical
Success
```

颜色不能只靠色彩区分。

必须同时使用：

- icon
- text
- shape
- label

确保可访问性。

---

# 25. Typography

优先使用系统字体：

iOS：

```text
SF Pro
```

Android：

```text
Roboto / system font
```

不要为了视觉效果大量使用特殊字体。

建立统一：

```text
Display
Title
Headline
Body
Label
Caption
```

所有页面遵循同一 Typography Scale。

---

# 26. Spacing System

禁止随意出现：

```text
13px
17px
23px
29px
```

统一采用 spacing scale。

例如：

```text
4
8
12
16
20
24
32
40
48
64
```

所有 UI 尽量使用 Design Token。

---

# 27. Radius System

统一：

```text
Small
Medium
Large
XLarge
Pill
```

不要每个组件单独设置圆角。

---

# 28. 动画

动画应该：

```text
fast
subtle
purposeful
```

适合：

- 页面转场
- Glass 层级变化
- Task 完成
- 数据刷新
- Bottom Sheet
- 卡片展开

禁止：

- 长时间动画
- 过度弹跳
- 无意义粒子
- 大量光效

医疗产品应该优先保证稳定、可信和高效。

---

# 29. Responsive Design

必须支持：

```text
iPhone
Android phone
Small phone
Large phone
Tablet
```

不要：

```dart
if (width == 390)
```

这种硬编码布局。

使用：

```text
LayoutBuilder
MediaQuery
SafeArea
Flexible
Expanded
Sliver
```

等 Flutter 正确布局机制。

---

# 30. Accessibility

必须考虑：

- Dynamic Type
- 字体放大
- VoiceOver
- TalkBack
- 足够点击区域
- 色彩对比度
- 不依赖颜色传达信息
- Reduce Motion

默认交互控件点击区域至少符合移动端可访问性要求。

---

# 31. 首页设计原则

首页不是 Dashboard 大屏。

首页应该回答三个问题：

```text
今天需要做什么？
↓
最近状态怎么样？
↓
有什么需要关注？
```

推荐结构：

```text
Greeting

Today's Tasks

Health Status

Recent Trends

Attention

Upcoming

Quick Actions
```

不要把所有数据都堆在首页。

---

# 32. 疾病首页

例如：

```text
白癜风

当前治疗计划
308nm 光疗

下一次任务
明天 19:00

治疗趋势
过去30天

最近治疗
...

患处变化
照片时间线

需要关注
...
```

糖尿病：

```text
2型糖尿病

今日血糖
...

最近7天趋势
...

HbA1c
...

用药依从性
...

今日任务
...

需要关注
...
```

不同疾病允许有不同的视觉组件。

但是遵循统一 Design System。

---

# 33. 图表设计

图表不是为了“看起来专业”。

每个图表必须回答一个问题。

例如：

```text
最近30天空腹血糖趋势
```

而不是：

```text
Blood Sugar Analytics Dashboard
```

图表应该支持：

- 时间范围
- Tooltip
- 趋势
- 异常点
- 目标范围
- 事件标记

例如：

```text
血糖曲线
      ↑
      │       ●
      │   ●       ●
目标 ─────────────────
      │ ●     ●
      └────────────────→ 时间
          ↑
        用药
```

治疗事件可以叠加在时间轴上。

---

# 34. 图片功能

白癜风照片必须考虑：

- 拍摄引导
- 相同角度
- 相同距离
- 相同光线
- 身体部位
- 拍摄日期
- 左右侧
- 治疗前后

未来支持：

```text
Photo
 ↓
Standardization
 ↓
AI Analysis
 ↓
Lesion Tracking
```

第一版不要声称 AI 可以准确诊断。

---

# 35. Privacy / Security

医疗数据属于高度敏感数据。

必须：

- 最小化收集
- 数据加密
- Token 安全存储
- 本地敏感数据加密
- HTTPS
- 不在日志中输出医疗数据
- 不在 Crash Log 中输出患者隐私
- 不把患者信息直接发送给第三方 AI
- 明确授权范围
- 支持撤销授权
- 数据访问审计

日志禁止：

```text
姓名
手机号
身份证
病历
完整医疗记录
照片 URL
Access Token
```

---

# 36. AI 数据脱敏

第三方 AI 调用前优先生成：

```text
AI Context
```

而不是：

```text
完整 Patient Database
```

例如：

```json
{
  "disease": "type2_diabetes",
  "duration": "4 years",
  "recent_hba1c": 6.8,
  "medications": [...],
  "recent_measurements": [...],
  "recent_events": [...],
  "clinical_summary": "..."
}
```

尽量不发送：

```text
姓名
电话
身份证
家庭住址
真实患者 ID
```

除非业务确实需要并且用户已明确授权。

---

# 37. Error Handling

医疗 APP 不允许简单显示：

```text
Something went wrong.
```

应该区分：

```text
网络错误
数据同步错误
数据格式错误
权限错误
医疗数据验证错误
设备权限错误
AI 服务错误
```

用户看到的是：

```text
发生网络问题，数据暂未同步。
本地记录已经保存，网络恢复后会自动同步。
```

而不是技术异常。

---

# 38. Loading State

所有异步页面必须设计：

```text
Loading
Empty
Error
Success
Partial
Offline
```

禁止只实现：

```text
Success
```

---

# 39. Empty State

Empty State 必须告诉用户：

```text
当前没有数据
为什么没有
下一步可以做什么
```

例如：

```text
还没有治疗记录

完成第一次治疗后，
这里会显示治疗时间线和趋势。

[记录一次治疗]
```

---

# 40. API 设计

客户端不得假设后端数据库结构。

使用：

```text
DTO
Repository
API Client
```

统一：

```text
GET
POST
PUT
PATCH
DELETE
```

错误响应统一。

推荐：

```json
{
  "code": "...",
  "message": "...",
  "data": {}
}
```

---

# 41. Domain Model

Domain Model 不应该直接等于 API DTO。

例如：

```text
PhototherapyDto
```

转换：

```text
Phototherapy
```

UI 使用 Domain Model。

这样未来 API 修改不会导致整个 Flutter UI 大规模修改。

---

# 42. Testing

必须逐步建立：

### Unit Test

测试：

- Domain
- UseCase
- Clinical Rule
- Data transformation

### Widget Test

测试：

- Task
- Form
- Chart
- Disease page

### Integration Test

测试：

```text
登录
 ↓
创建疾病
 ↓
创建治疗计划
 ↓
创建治疗记录
 ↓
生成任务
 ↓
完成任务
 ↓
时间线出现记录
```

医学规则必须有独立测试。

---

# 43. 医学规则测试

每条规则至少需要：

```text
正常情况
边界情况
异常情况
缺失数据
旧版本数据
规则版本升级
```

例如：

```text
Rule V1

Input A
Expected B
```

医学规则不能因为重构代码而产生隐性变化。

---

# 44. 数据版本

医疗数据必须考虑历史不可变性。

原则：

> **历史事实不能因为当前方案变化而被修改。**

例如：

```text
2026-01-01
医生方案 A

2026-05-01
医生修改为方案 B
```

不能让 2026-01-01 的历史记录自动变成方案 B。

---

# 45. 产品开发顺序

不要一次开发所有功能。

按照：

## Phase 1

基础框架：

```text
Flutter
Theme
Routing
State Management
Networking
Local Storage
Authentication
Design System
```

## Phase 2

通用慢病模型：

```text
Patient
Disease
CarePlan
Task
Reminder
Event
Timeline
```

## Phase 3

白癜风：

```text
Disease
Treatment
308nm
Photo
Adverse Reaction
Timeline
Reminder
```

## Phase 4

智能能力：

```text
Patient State
Rule Engine
Trend
Summary
AI
```

## Phase 5

糖尿病：

```text
Blood Glucose
CGM
Medication
HbA1c
Exercise
Diet
Risk
```

## Phase 6

医疗 AI 平台：

```text
AI Context
RAG
Knowledge Base
FHIR
Third-party AI
Consent
Audit
```

---

# 46. AI Agent 开发纪律

你不是一次性生成完整项目。

必须：

```text
分析
 ↓
设计
 ↓
实现
 ↓
测试
 ↓
检查
 ↓
继续
```

每次修改之前：

1. 阅读现有代码
2. 理解现有架构
3. 搜索是否已有实现
4. 尽量复用现有组件
5. 不重复创建类似组件
6. 不随意修改公共接口
7. 修改后运行测试

---

# 47. 禁止 AI Agent 的行为

禁止：

- 为了快速实现而把业务逻辑写进 Widget
- 创建巨型 Widget
- 创建巨型 Service
- 创建 God Class
- 重复实现 API Client
- 重复实现 Theme
- 随意引入第三方依赖
- 为一个简单功能引入大型框架
- 删除已有测试
- 修改已有 API 而不检查调用方
- 使用 TODO 掩盖未完成核心功能
- 用 Mock 数据伪装真实功能
- 把医学规则硬编码在 UI
- 把 LLM 输出当作医学事实
- 在没有依据的情况下编造医学规则

---

# 48. UI 一致性硬约束

所有页面必须使用统一：

```text
AppTheme
ColorTokens
SpacingTokens
RadiusTokens
TypographyTokens
GlassTokens
MotionTokens
```

禁止单独出现：

```dart
Color(...)
TextStyle(...)
BorderRadius.circular(...)
BoxShadow(...)
```

如果该视觉属性属于 Design System，应优先使用 Token。

---

# 49. Glass Component 统一约束

所有玻璃组件必须优先使用：

```text
GlassSurface
GlassCard
GlassButton
GlassNavigation
GlassSheet
GlassDialog
```

不要在业务页面里重复：

```text
BackdropFilter
ImageFilter.blur
Container decoration
gradient
shadow
border
```

业务页面只描述：

```text
GlassCard(
  child: ...
)
```

视觉实现集中在 Design System。

这样未来修改整个 APP 的玻璃效果时，只需要修改 Design System。

---

# 50. Apple 风格的关键约束

目标不是：

> “把所有东西变透明。”

目标是：

> **通过材质、层级、空间、光线和运动建立清晰的信息层级。**

重点：

```text
Material
Depth
Hierarchy
Clarity
Consistency
Motion
```

透明度必须服务于层级，而不是装饰。

如果玻璃效果降低文字可读性：

> **优先可读性，放弃玻璃效果。**

如果动画影响性能：

> **优先性能，减少动画。**

如果视觉效果影响医疗数据理解：

> **优先信息准确性。**

---

# 51. 性能要求

Flutter APP 必须重点关注：

- 首屏启动
- 滚动性能
- 图片加载
- 大量时间线
- 图表
- Blur
- BackdropFilter
- 动画
- 内存
- 网络请求

尤其注意：

```text
BackdropFilter
ImageFilter.blur
```

在大量列表中可能造成明显 GPU / Rendering 压力。

禁止在长列表中无节制创建复杂 Blur Surface。

---

# 52. 图片处理

患者医疗图片不能简单：

```text
Image.network()
```

必须考虑：

- 缓存
- 缩略图
- 原图
- 上传进度
- 失败重试
- 本地临时文件
- 权限
- 隐私
- 删除
- 同步

图片上传应支持：

```text
thumbnail
preview
original
```

根据页面需求选择不同尺寸。

---

# 53. 产品中的 AI 交互

不要设计成一个普通：

```text
ChatGPT clone
```

更推荐：

```text
AI 健康助手
```

入口应该与患者数据结合。

例如：

```text
最近30天发生了什么？

为什么我的血糖最近波动？

帮我整理一下最近的治疗情况。

下次去医院我应该把哪些数据给医生看？
```

AI 回答必须能够引用：

```text
患者数据
医学知识
数据时间范围
```

并明确不确定性。

---

# 54. AI 输出格式

医学 AI 推荐结构：

```text
结论

数据依据

可能原因

需要关注

建议下一步

何时联系医生
```

避免：

```text
绝对化
确定性诊断
无依据的药物建议
```

---

# 55. 产品语言

默认语言：

```text
简体中文
```

但代码、Domain Model、API 字段使用英文。

例如：

```text
治疗记录
→ TreatmentRecord

血糖
→ BloodGlucose

光疗
→ Phototherapy

患处
→ LesionSite
```

不要出现：

```text
bloodSugar2
bloodSugarNew
bloodSugarFinal
```

---

# 56. 代码质量

要求：

- Null Safety
- 强类型
- 小函数
- 小 Widget
- 单一职责
- 明确命名
- 避免隐式状态
- 避免全局变量
- 避免魔法数字
- 避免魔法字符串
- 公共组件必须有文档
- 核心 Domain 必须有测试

---

# 57. 每次开发任务的输出方式

在开始编码之前，先给出：

```text
## Understanding
我理解的需求

## Existing Code
当前相关代码

## Plan
实现计划

## Files
预计修改的文件

## Risks
潜在风险

## Implementation
开始实现
```

实现完成后：

```text
## Changed
修改内容

## Tests
测试结果

## Issues
剩余问题

## Next
下一步
```

不要在没有理解项目结构之前直接大规模修改代码。

---

# 58. 最终产品目标

最终 APP 应该形成：

```text
                Patient
                   │
                   ↓
               Diseases
                   │
                   ↓
               Care Plans
                   │
                   ↓
                 Tasks
                   │
                   ↓
                Events
                   │
                   ↓
             Patient Data
                   │
          ┌────────┴────────┐
          ↓                 ↓
      Rule Engine        AI Layer
          │                 │
          ↓                 ↓
       Patient State     Summary
          │                 │
          └────────┬────────┘
                   ↓
             Next Actions
                   │
                   ↓
                Patient
```

最终目标不是让 AI 替患者看病。

目标是：

> **让患者长期管理疾病的过程变得结构化、连续、可追踪、可理解，并让医生和未来的医疗 AI 能够获得高质量的长期患者数据。**

---

# 59. 当前开发优先级

当前不要实现所有功能。

按照以下顺序：

```text
P0
Flutter 基础架构
Design System
Liquid Glass UI
Navigation
Theme
Local Storage
API Layer

P1
Patient
Disease
CarePlan
Task
Reminder
Event
Timeline

P2
白癜风
308nm 光疗
治疗记录
治疗部位
剂量
治疗反应
照片
疗程

P3
Patient State
Clinical Rule Engine
Trend
Health Summary

P4
Medical AI
RAG
Knowledge Base

P5
糖尿病

P6
FHIR
第三方医疗 AI
医生平台
数据授权
```

**不要提前实现 P4/P5/P6 来破坏 P0/P1/P2 的基础架构。**

---

# 60. 最终判断原则

当产品需求、视觉效果、开发便利性和医疗安全发生冲突时，优先级：

```text
医疗安全
>
数据正确性
>
用户可理解性
>
可维护性
>
可访问性
>
性能
>
视觉效果
>
开发速度
```

当不确定某个医学结论是否正确时：

> **不要猜。**

标记为：

```text
需要医学依据
```

并要求提供：

```text
指南
专家共识
临床研究
药品说明书
官方医学机构资料
```

再将医学结论转化成系统规则。

---

# 61. 核心原则

整个项目始终遵守以下原则：

> **记录事实，不编造事实。**

> **医学规则可追溯。**

> **AI 可以解释，但不能凭空创造医学规则。**

> **患者数据结构化优先于 AI 聊天。**

> **提醒只是结果，不是核心。**

> **疾病模块可扩展。**

> **Design System 统一管理视觉。**

> **Liquid Glass 服务于信息层级，而不是为了玻璃而玻璃。**

> **历史医疗数据不可被当前状态覆盖。**

> **所有第三方 AI 数据访问必须经过明确授权。**

> **先建立可靠的数据和业务模型，再增加 AI。**