# StudyLoop AI Workflow Integration Implementation Plan

> **Goal**: 严格按照「AI 是工作流增强层，而非独立工作流」的架构约束，将 DeepSeek-V3 / 本地降级引擎全面融入 StudyLoop 的 5 大核心场景（Home 阻力拆解、Task 极小行动生成、Focus 陪伴与减压、Reflection 情绪复盘、Insights 规律解读）。

---

## 阶段一：领域与协议层 (Domain & Models)
- [ ] 升级 `lib/domain/ai_companion_repository.dart`：
  - 新增 `CompanionSurface` (`home`, `taskBreakdown`, `focus`, `reflection`, `insights`)
  - 新增 `CompanionIntent` (`support`, `proposeAction`, `explainInsight`, `clarifyBarrier`)
  - 新增 `AIRequestStatus` (`idle`, `sending`, `success`, `failed`, `fallback`)
  - 增强 `AICompanionContext`（支持各表面特异化上下文：`surface`, `deterministicInsightText`, `actualDurationMinutes`）
  - 增强 `AICompanionReply`（支持 `CompanionIntent`, `requiresUserConfirmation`, `suggestedBarrier`, `suggestedTaskType`）
  - 引入 `AIContextSanitizer`（字符截断、去除敏感私密字段、确保无 DB/RevenueCat 泄漏）
  - 引入 `companion_prompt_v1`（版本化系统 Prompt，包含角色、约束、禁止权限、输出 Schema）

## 阶段二：仓库与网关层 (Data & Repository)
- [ ] 增强 `lib/data/repositories/hybrid_ai_companion_repository.dart`：
  - 针对 5 种不同 `surface`，构造针对性的 Prompt 与最小化上下文；
  - 严格输出校验：`suggestedMinutes` 钳制到 5..60 分钟，未知 Enum 映射回 null；
  - 完善本地回退引擎：无 Key 或断网时，`CorgiChatEngine` 根据当前 `surface` 返回贴合业务的确定性建议。

## 阶段三：控制器层 (AICompanionController & Providers)
- [ ] 完善统一控制器 `AICompanionController`（单并发锁，防止频繁连击；状态同步）：
  - 提供 `proposeMicroAction(String taskText)` -> 返回 `ProposedAction`
  - 提供 `clarifyBarrier(String userExpression)` -> 识别阻力并提出极小行动
  - 提供 `companionDuringFocus(Duration elapsed)` -> 给出克制温暖短句
  - 提供 `reflectOnSession(String userThought, int actualMinutes)` -> 辅助复盘
  - 提供 `explainInsight(String insightSummary)` -> 自然语言解释规律

## 阶段四：UI 场景融合 (5 Surfaces Integration)
- [ ] **Surface 1: Home 首页柯基卡片**
  - 在首页柯基卡片新增快速表达入口与「AI 极小切入点建议」；
  - 用户确认后一键填入任务并开启 Focus。
- [ ] **Surface 2: TaskScreen 任务编辑**
  - 在任务输入框旁/下方新增「让柯基帮我再缩小一点」；
  - 点击后异步调用 AI 建议微行动（带 Loading 骨架），生成后展示确认卡片，点击「采用」自动更新输入框与时长。
- [ ] **Surface 3: FocusScreen 专注中**
  - 新增轻量级「陪我一下」底部弹窗（极简、克制 1~2 句话，提供「安心保存去休息」与「继续坚持」，不强控 Timer）。
- [ ] **Surface 4: ReflectionScreen 反思页**
  - 新增「和柯基聊聊感受」，提供自然回应；用户跳过时绝对不产生假评分。
- [ ] **Surface 5: InsightsScreen 洞察页**
  - 在核心洞察卡片新增「让柯基解释这个规律」折叠/弹窗，提供实用行动指南。

## 阶段五：自动化测试与审计报告
- [ ] 编写全面的单元与集成测试（覆盖 5 种 Surface、Sanitizer、安全注入拦截、Schema 容错、Fallback）。
- [ ] 执行 `flutter analyze` 与 `flutter test`，确保 100% 通过。
- [ ] 编译 Release APK 并推送到 Vivo 物理真机进行鲜活人工验收。
- [ ] 输出交付审计报告：`STUDYLOOP_AI_INTEGRATION_AUDIT.md`。
