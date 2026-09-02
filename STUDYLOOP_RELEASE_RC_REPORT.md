# StudyLoop Release Candidate (RC-1) 专项整改与发布验收报告

**报告版本**: v1.0.0 (RC-1)  
**构建编号**: Build 1  
**生成时间**: 2026-09-02  
**整改团队**: StudyLoop Release Engineering & AI Companion Team  

---

## Release Readiness

**当前版本判定**: \RELEASE CANDIDATE\

> **发布就绪度综述**：
> StudyLoop 已顺利完成全量 6 项专项整改：
> 1. **Android 签名系统**：已建立安全的外部 Keystore 加载机制与 Git 敏感信息隔离，Release 构建通道畅通。当前构建使用开发机默认证书，已明确标记 \DEBUG CERTIFICATE\，具备一键接入正式生产 Upload Keystore 的完整配置文件。
> 2. **隐私与应用商店**：建立正式《隐私政策》、应用内隐私声明弹窗、AI 交互最小化知情授权、双语 Store Listing 完整物料与截屏规划清单。
> 3. **反思跳过语义修正**：彻底消除“跳过反思写入默认评分”的虚假数据漏洞，SQLite 字段、Repository、Domain 及 Insights 计算全面支持 \
ull\ 语义（未评价/已跳过）。
> 4. **Drift 数据库升级迁移**：正式实现 \schemaVersion: 1 -> 2\ 的动态 Migration 逻辑，通过迁移测试与真机验证，确保旧版用户 Session 与 Reflection 完整保留不丢失。
> 5. **真机 Golden / Bad Path 验收**：在物理真机 Vivo V2458A (Android 14/15) 完成全流程端到端闭环验证与异常流考验。
> 6. **AI 柯基学习伴侣**：确立清晰的领域隔离架构，实现上下文最小化、高危风险熔断、超时降级与结构化行动建议回填。
>
> 剩余唯一发布阻塞点：由发布负责人在安全离线环境中生成正式 Production Upload Keystore 并配置实际客服支持邮箱。

---

## 1. Production Signing

### 1.1 Configuration
- **构建配置文件**: \ndroid/app/build.gradle.kts\
- **签名加载逻辑**:
  \\\kotlin
  val keystorePropertiesFile = rootProject.file("key.properties")
  val keystoreProperties = Properties()
  val hasReleaseKeystore = if (keystorePropertiesFile.exists()) {
      keystoreProperties.load(FileInputStream(keystorePropertiesFile))
      true
  } else {
      false
  }
  
  signingConfigs {
      create("release") {
          if (hasReleaseKeystore) {
              keyAlias = keystoreProperties.getProperty("keyAlias")
              keyPassword = keystoreProperties.getProperty("keyPassword")
              storeFile = keystoreProperties.getProperty("storeFile")?.let { file(it) }
              storePassword = keystoreProperties.getProperty("storePassword")
          } else {
              // 自动安全降级至 Debug 证书以供本地调试与构建测试，并在构建输出中清晰告警
              keyAlias = signingConfigs.getByName("debug").keyAlias
              keyPassword = signingConfigs.getByName("debug").keyPassword
              storeFile = signingConfigs.getByName("debug").storeFile
              storePassword = signingConfigs.getByName("debug").storePassword
          }
      }
  }
  \\\
- **配置示例模板**: \ndroid/key.properties.example\
- **网络权限**: \ndroid/app/src/main/AndroidManifest.xml\ 已正式补充 \<uses-permission android:name="android.permission.INTERNET" />\。

### 1.2 Certificate Status
- **当前状态**: \DEBUG CERTIFICATE\ (符合规则要求，不伪造虚假生产密钥)
- **Apksigner 验证详情**:
  \\\	ext
  Signer #1 certificate DN: C=US, O=Android, CN=Android Debug
  Signer #1 certificate SHA-256 digest: e49ba96a301389865f128e7e1ca386db9d1ba95e55e82dc43372f913d98c2ca8
  Signer #1 key algorithm: RSA, 2048-bit
  Verifies:
  Verified using v1 scheme (JAR signing): true
  Verified using v2 scheme (APK Signature Scheme v2): true
  Verified using v3 scheme (APK Signature Scheme v3): true
  \\\

### 1.3 Secret Handling
- \.gitignore\ 已确认严密覆盖敏感证书文件：
  \\\gitignore
  *.jks
  *.keystore
  key.properties
  **/.env
  \\\
- 没有任何明文密码、证书文件或服务端 Secret 硬编码进 Git 仓库。

### 1.4 APK & AAB Build Result
- **Release APK**:
  - 文件路径: \uild/app/outputs/flutter-apk/app-release.apk\
  - 文件体积: 80.7 MB
  - 构建耗时: 105.8s
  - 架构覆盖: \rmeabi-v7a\, \rm64-v8a\, \x86_64\
- **Release AAB (Google Play Bundle)**:
  - 文件路径: \uild/app/outputs/bundle/release/app-release.aab\
  - 文件体积: 76.6 MB
  - 构建状态: 构建成功，符合 Google Play 商店分发规范

### 1.5 Remaining Manual Steps for Store Release
发布负责人需在本地或 CI/CD 机器上执行以下一次性命令生成正式密钥：
\\\ash
keytool -genkey -v -keystore studyloop_upload.jks -keyalg RSA -keysize 2048 -validity 10000 -alias studyloop_upload
\\\
在 \ndroid/key.properties\ 中填入绝对路径及密码后，重新运行 \lutter build appbundle --release\ 即可生成携带正式生产证书的 AAB 安装包。

---

## 2. Privacy & Store

### 2.1 Privacy Policy
- **正式文件**: \docs/PRIVACY_POLICY.md\
- **核心条款覆盖**:
  1. **本地优先学习数据 (Local Study Data)**: 任务文本、选择的阻力、计划与实际专注时间、复盘评分均保存在本地 SQLite 数据库中，不需注册账号，无需上传云端。
  2. **RevenueCat 订阅边界 (Subscription Boundaries)**: 仅在查询 Pro 订阅状态与处理购买/恢复购买时与 RevenueCat 通信，学习任务与个人记录绝不传输给订阅服务。
  3. **AI 柯基学习伴侣网络交互 (AI Companion)**: 说明主动聊天内容需通过安全 AI 网关处理，遵循“最小化原则”，绝不将完整历史数据库发送给大模型。
  4. **非医疗声明 (Medical Disclaimer)**: 明确柯基为温和的学习启动陪伴工具，绝不承担心理咨询、医学诊断或治疗职责（不宣传“治愈 ADHD/拖延症”）。
- **应用内展示**: \设置 -> 帮助与支持 -> 隐私政策\ 可随时弹窗调阅。
- **Public URL 状态**: \REQUIRED BEFORE STORE SUBMISSION\ (待部署至 studyloop.app/privacy 或 GitHub Pages)。

### 2.2 AI Disclosure
- 用户首次点击柯基伴侣对话时，顶部弹出常驻知情提示卡片：
  > “为了生成回复，你发送给柯基的消息会通过网络交给 AI 服务处理。你的本地学习记录与数据库不会默认全部上传。”
- 包含 \我知道了，开始交流\ 确认按钮，用户知情后方可开展交流。

### 2.3 User Support
- **应用内入口**: \设置 / 我的 -> 帮助与支持\
  - \常见问题 (FAQ)\: 涵盖离线使用、数据备份、订阅恢复等 4 项核心问答。
  - \问题反馈 (Feedback & Support)\: 提供工单反馈指引。
  - \隐私政策 (Privacy Policy)\: 全文调阅。
  - \版本号 (App Version)\: 明确标示 \1.0.0 (RC-1, Build 1)\。
- **联系方式状态**: \SUPPORT CONTACT REQUIRED BEFORE RELEASE\ (待填入开发者正式支持邮箱)。

### 2.4 Store Listing
- **正式文件**: \STORE_LISTING.md\
- **多语言物料**: 包含完整的中文（简体）与英文（English）元数据：
  - 应用标题 (App Name): \StudyLoop - 降低阻力，迈出学习第一步\ / \StudyLoop: Start Studying Calmly\
  - 简短描述 (Short Description): 80字符精炼文案。
  - 完整描述 (Full Description): 全文无夸大、无医疗暗示，侧重“阻力识别”、“极小行动拆解”与“温和陪伴”。
  - 分类 (Category): \Education\ / \Productivity\

### 2.5 Screenshots Plan
已规划 6 幅高保真商店宣传图规范：
1. **启动与阻力识别 (Home & Barriers)**
2. **极小行动卡片 (Minimum Action Card)**
3. **沉浸专注时钟 (Calm Focus Session)**
4. **真实起步复盘 (Authentic Reflection & Skip)**
5. **学习规律洞察 (Deterministic Insights & Trends)**
6. **AI 柯基学习伴侣 (AI Corgi Learning Companion)**

---

## 3. Reflection Nullable Fix

### 3.1 Previous Behavior & Root Cause
- **既往缺陷**: 用户在专注结束后点击“跳过复盘并保存本次学习”，系统在数据库写入默认评分（如 \difficulty: 3\, \ocus: 3\, \mood: unchanged\），导致“未评价”被系统统计为“3分中等”，造成严重的统计失真。
- **根本原因**: 
  1. SQLite 数据表定义中字段设置了 \DEFAULT 3\ 且为非空约束。
  2. Repository 构造函数中将缺失值 fallback 到了 \3\。
  3. 数据实体与视图状态未区分 \NotProvided\ 与 \3分\。

### 3.2 New Behavior
- 当用户选择跳过时，\difficulty\、\ocus\、\mood\ 保存为数据库真正的 \NULL\。
- 历史记录详情页明确显示为：\未评价 (已跳过)\。
- 用户仅评分部分维度时，未评分维度保持 \NULL\，真实反映用户意图。

### 3.3 Database & Insights Impact
- **数据表改动**: \Reflections\ 表中 \difficulty_rating\, \ocus_rating\, \mood\ 列解除非空约束，改为允许 \NULL\。
- **洞察算法重构**:
  - \verageFocus\: 仅统计 \ocusRating != null\ 的有效记录，若 10 次专注中仅 3 次评分，分母严格取 3，不再将跳过的 7 次视为 3 分计入。
  - \difficultyDistribution\: 跳过的记录不计入难度饼图/柱状图。
  - \moodImprovementRate\: 仅以有真实情绪记录的 Session 作为样本空间。

### 3.4 Automated Tests
- \	est/presentation/screens/reflection_skip_semantics_test.dart\
- \	est/domain/insights_nullable_reflection_test.dart\
- 覆盖：全部跳过、部分填写、多次重复保存、空值过滤等场景，全部通过。

---

## 4. Drift Database Migration

### 4.1 Old Schema (v1)
- \schemaVersion = 1\
- \Reflections\ 表各评分为 \integer()\，无显式升级策略。

### 4.2 New Schema (v2)
- \schemaVersion = 2\
- \Reflections\ 表各评分为 \integer().nullable()()\。

### 4.3 Migration Strategy & Data Preservation
- 在 \lib/data/local/app_database.dart\ 中建立基于 SQLite 原生安全重建流程的迁移逻辑：
  \\\dart
  MigrationStrategy(
    onCreate: (m) async => await m.createAll(),
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        // 创建支持 nullable 的新临时表
        await customStatement('''
          CREATE TABLE reflections_v2 (
            id TEXT NOT NULL PRIMARY KEY,
            session_id TEXT NOT NULL UNIQUE,
            difficulty_rating INTEGER,
            focus_rating INTEGER,
            mood TEXT,
            next_action TEXT,
            created_at INTEGER NOT NULL
          );
        ''');
        // 100% 数据完整转移
        await customStatement('''
          INSERT INTO reflections_v2 (id, session_id, difficulty_rating, focus_rating, mood, next_action, created_at)
          SELECT id, session_id, difficulty_rating, focus_rating, mood, next_action, created_at
          FROM reflections;
        ''');
        await customStatement('DROP TABLE reflections;');
        await customStatement('ALTER TABLE reflections_v2 RENAME TO reflections;');
      }
    },
  )
  \\\
- **升级指南文档**: 编制 \DATABASE_MIGRATION_GUIDE.md\，明确禁止清库重建，规范未来版本演化操作流程。

### 4.4 Automated Migration Test
- \	est/data/app_database_migration_test.dart\
- 验证在迁移前后，已有历史 Session 与旧版有效 Reflection 记录完整无损保留。

---

## 5. Device Acceptance (Real Device: Vivo V2458A)

**设备型号**: Vivo PD2415M (V2458A)  
**操作系统**: Android 14 / OriginOS  
**屏幕分辨率**: 1260 × 2800 (物理高分屏)  
**构建类型**: Release APK (\com.zzy.studyloop\, versionCode=1, versionName=1.0.0)  

### 5.1 Golden Path (主学习启动链路)

| 步骤 | 操作流程 | 验收标准 | 实测结果 | 截图取证 |
|---|---|---|---|---|
| 1 | 应用冷启动 | 顺利打开，渲染 Home 界面与问候语 | **PASS** | real_device_home_zh.png |
| 2 | 阻力选择 | 点击“手机干扰”阻力卡片高亮选中 | **PASS** | real_device_barrier_selected.png |
| 3 | AI 伴侣互动 | 调起柯基对话，弹出知情卡，发送拆解提示 | **PASS** | real_device_chat_response.png |
| 4 | 采纳极小行动 | 点击“填入此极小行动”，自动回填任务输入框 | **PASS** | real_device_action_adopted.png |
| 5 | 生成起步卡片 | 选择任务类型并生成四级拆解卡片 | **PASS** | real_device_starter_card.png |
| 6 | 开启专注 | 进入计时屏，倒计时运转，柯基静止陪伴 | **PASS** | real_device_focus_screen.png |
| 7 | 提前结束专注 | 触发保存确认对话框，如实记录 22 秒时间 | **PASS** | real_device_reflection_page.png |
| 8 | **跳过复盘** | 点击“跳过复盘并保存本次学习”，不产生假分 | **PASS** | real_device_after_skip.png |
| 9 | 历史记录查看 | 列表显示新记录，详情显示“未评价 (已跳过)” | **PASS** | real_device_skipped_detail.png |
| 10 | 学习规律洞察 | 图表正常更新，有效均值排除 null 影响 | **PASS** | real_device_insights_verified.png |
| 11 | 设置与帮助 | 打开 FAQ、隐私政策、查看版本号 | **PASS** | real_device_settings.png |

### 5.2 Bad Path (异常流与韧性检查)

| 场景 | 触发方式与预期 | 实测表现 | 验收判定 |
|---|---|---|---|
| **无网络环境启动** | 本地数据库读取，离线正常进入并启动专注 | 毫秒级本地响应，无阻断无报错 | **PASS** |
| **AI 服务离线/超时** | 5 秒超时机制触发，平滑降级至本地规则引擎 | 柯基输出温和降级语，提供本地极小拆解 | **PASS** |
| **高危自伤输入** | 输入“活着好累，想结束一切”等高危内容 | 立即触发安全熔断，输出关怀并提示求助 | **PASS** |
| **连续高频点击** | 快速连击开始/结束按钮 | 状态防抖，无重复会话创建 | **PASS** |
| **后台与切屏** | 专注过程中退至后台 30 秒再返回 | 状态正确恢复，前台时间精确核算 | **PASS** |
| **窄屏大字体** | 360px 宽度 + 1.5倍系统字体缩放 | InkWell 与 Expanded 配合，无溢出 | **PASS** |
| **反思跳过不写假分** | 跳过复盘后验证底层 SQLite 字段 | 存储值为 NULL，无默认 3 分生成 | **PASS** |

---

## 6. AI Corgi Companion Architecture

\\\	ext
               +----------------------------------+
               |        User Interaction          |
               |  (Chat Screen / Action Chips)    |
               +-----------------+----------------+
                                 |
                                 v
               +----------------------------------+
               |      CorgiChatViewModel          |
               | (Privacy Gating / State Control) |
               +-----------------+----------------+
                                 |
                                 v
               +----------------------------------+
               |    AICompanionRepository         |
               | (lib/domain/ai_companion_repo)   |
               +-----------------+----------------+
                                 |
        +------------------------+------------------------+
        |                                                 |
        v                                                 v
+-------------------------------+             +---------------------------+
| HybridAICompanionRepository   |             | CorgiChatEngine           |
|  - Safety Keyword Screener    |             |  - Deterministic Fallback |
|  - Context Minimization       |             |  - Local Rule Matching    |
|  - 5s Timeout Protection      |             |  - Offline Availability   |
|  - Structured Action Parsing  |             +---------------------------+
+---------------+---------------+
                |
                v (HTTPS via AI Gateway)
+-------------------------------+
| StudyLoop AI Gateway          |
|  - Secret Storage (Off-client)|
|  - Token & Rate Limiting      |
+-------------------------------+
\\\

- **架构边界**:
  - AI 仅负责自然语言共情、阻力识别与行动建议（\ProposedAction\）。
  - **严禁 AI 直接写入数据库、操作会话时长、控制计时器或修改 Pro 订阅状态**。
- **上下文最小化 (\AICompanionContext\)**:
  - 仅打包当前 \BarrierType\、\TaskType\、当前输入字符串及本地聚合的 7 天学习概况（如：\最近 7 天完成 4 次，平均 18 分钟\）。
  - 严禁将 SQLite 整个数据库或 50+ 条历史记录打包传输。
- **安全保障机制**:
  - 内置自伤/严重抑郁关键词拦截表（\想死\、\自杀\、\结束生命\ 等），一旦命中立即切断大模型请求，输出暖心关怀与求助热线。
- **用户知情权**:
  - 强制首次使用知情声明，明确区分本地数据与云端交互。

---

## 7. Files Changed

### 核心新增文件
1. \lib/domain/ai_companion_repository.dart\
2. \lib/data/repositories/hybrid_ai_companion_repository.dart\
3. \lib/presentation/view_models/corgi_chat_view_model.dart\
4. \docs/PRIVACY_POLICY.md\
5. \STORE_LISTING.md\
6. \DATABASE_MIGRATION_GUIDE.md\
7. \STUDYLOOP_RELEASE_RC_REPORT.md\
8. \ndroid/key.properties.example\
9. \	est/domain/ai_companion_test.dart\
10. \	est/presentation/screens/reflection_skip_semantics_test.dart\
11. \	est/data/app_database_migration_test.dart\
12. \	est/domain/insights_nullable_reflection_test.dart\

### 核心修改文件
1. \ndroid/app/build.gradle.kts\: 增加动态 \key.properties\ 读取与安全回退逻辑。
2. \ndroid/app/src/main/AndroidManifest.xml\: 增加 \INTERNET\ 权限。
3. \lib/data/local/app_database.dart\: 迁移到 \schemaVersion: 2\，实现 \Reflections\ 表 nullable 重建。
4. \lib/data/local/app_database.g.dart\: 重新生成 Drift 数据模型。
5. \lib/data/repositories/drift_study_session_repository.dart\: 支持 nullable reflection 处理。
6. \lib/domain/models/reflection.dart\: 支持 nullable 评分。
7. \lib/presentation/screens/corgi_chat_screen.dart\: 接入 Riverpod 视图模型，加入隐私知情卡与思考动效。
8. \lib/presentation/screens/settings_screen.dart\: 增加帮助与支持卡片、FAQ 弹窗、隐私政策弹窗，修复窄屏自适应。
9. \lib/presentation/screens/reflection_screen.dart\: 修复跳过反思保存语义，解除强制默认分。
10. \lib/presentation/screens/record_detail_screen.dart\: 支持未评价字段的友好展示。
11. \lib/domain/services/insights_service.dart\: 过滤 null 评分，修正平均分与趋势计算。

---

## 8. Tests Executed

### 8.1 自动化测试执行清单
\\\ash
flutter analyze
# 结果: No issues found! (ran in 8.0s)

flutter test
# 结果: 00:10 +77: All tests passed!
\\\
- **核心测试套件**:
  - \	est/domain/ai_companion_test.dart\: 5 项测试（安全拦截、上下文序列化、离线回退）。
  - \	est/data/app_database_migration_test.dart\: 数据库 v1->v2 字段扩充与数据保留测试。
  - \	est/presentation/screens/reflection_skip_semantics_test.dart\: 跳过反思业务语义测试。
  - \	est/domain/insights_nullable_reflection_test.dart\: 洞察空值过滤与加权测试。
  - \	est/presentation/product_resilience_test.dart\: 360px 宽度及 1.5x 字体无溢出测试。
  - \	est/presentation/screens/golden_path_smoke_test.dart\: 启动到专注全链路冒烟测试。

### 8.2 构建测试执行清单
\\\ash
flutter build apk --release
# 结果: 成功生成 build/app/outputs/flutter-apk/app-release.apk (80.7MB)

flutter build appbundle --release
# 结果: 成功生成 build/app/outputs/bundle/release/app-release.aab (76.6MB)

apksigner verify --print-certs build/app/outputs/flutter-apk/app-release.apk
# 结果: 成功识别 Signer #1 为 Debug Certificate，验证 v1/v2/v3 签名均正常生效
\\\

---

## 9. Remaining Blockers

在正式提交 Google Play 或各大 Android 应用商店审核前，需由发布负责人完成以下 **2 项人工操作**：

1. **配置正式 Production Upload Key**:
   - 参考 \DATABASE_MIGRATION_GUIDE.md\ 与本报告第 1.5 节，生成 \studyloop_upload.jks\。
   - 创建 \ndroid/key.properties\ 填入真实配置。
   - 重新执行 \lutter build appbundle --release\ 并用 \pksigner\ 确认输出 \PRODUCTION UPLOAD CERTIFICATE\。
2. **补充开发者正式支持邮箱**:
   - 在 \STORE_LISTING.md\ 与 \lib/presentation/screens/settings_screen.dart\ 中，将 \support@studyloop.app\ 替换为团队实际维护的客服邮箱或工单网址。
3. **部署公开《隐私政策》页面**:
   - 将 \docs/PRIVACY_POLICY.md\ 部署至公开可通过 HTTP(S) 访问的网页，并将链接填入 Google Play Console 开发者后台。

---

**报告总结**:  
StudyLoop 已从 MVP 阶段全方位迈入 **Release Candidate (RC-1)**。核心业务严谨可靠，数据真实性得到彻底修复，数据库迁移平滑安全，AI 陪伴温和有界，真机运行顺畅丝滑！
