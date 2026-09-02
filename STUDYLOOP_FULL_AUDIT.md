# StudyLoop Full Audit

# Executive Summary

总体评分：**76 / 100**（发布门禁计划后）

StudyLoop 已经是一个可安装、可离线启动、核心起步闭环可运行的 Android Flutter 应用。发布门禁计划后，History 全部免费、Pro 只锁长期 Insights、启动器显示 StudyLoop，Test Store 文案仅 debug 出现。`flutter analyze` 干净，53 项测试通过，release APK 可构建。

还不能上架：本 APK 无正式 keystore，真机 Timer 生命周期和 Golden Path integration test 仍未跑。

分项评分：

| 维度 | 分数 |
| --- | --- |
| Architecture | 72 |
| Product Logic | 70 |
| UI/UX | 68 |
| Database | 74 |
| Timer | 62 |
| RevenueCat | 71 |
| Privacy | 82 |
| Performance | 64 |
| Testing | 61 |
| Release Readiness | 48 |

发布建议：**READY WITH MINOR FIXES**（见文末 Plan Follow-up）

原因：本地产品边界已对齐，可继续演示和内部验收。上架仍需正式 keystore、真机 Timer 脚本、以及一条 Golden Path integration test。

---

# Critical Issues

## P0-1 Release 仍使用 debug 签名

- 文件：`android/app/build.gradle.kts`
- 问题：`signingConfig = signingConfigs.getByName("debug")`，并带 TODO。
- 影响：不能作为商店/公开分发产物。任何人都能用 debug 密钥重签名同包名。
- 复现：阅读 `buildTypes.release`。
- 建议：配置独立 upload/release keystore，不要把密钥提交进仓库。

## P0-2 应用身份未完成

- 文件：`android/app/src/main/AndroidManifest.xml`、`android/app/build.gradle.kts`
- 问题：`android:label="studyloop"`；release 注释仍写 “Specify your own unique Application ID”，虽然 `applicationId` 已是 `com.zzy.studyloop`。
- 影响：桌面/系统名称像临时工程，不像可交付产品。
- 复现：安装 release APK 后查看启动器名称。
- 建议：改为 `StudyLoop`，并确认图标、versionName/versionCode。

## P0-3 本次未做 Android 真机生命周期验收

- 文件：`lib/app.dart`、`lib/providers.dart`
- 问题：计时器已改为基于时间差，切后台会 pause；但锁屏、来电、分屏、系统杀进程、改系统时间均未在本轮真机复测。
- 影响：这是最高风险产品承诺（只统计前台真实时间）。没有设备证据就不能宣称可交付。
- 复现：本审计只跑了单元/widget 测试，没有 `integration_test/`，也没有本轮设备安装。
- 建议：在 vivo 或同类 Android 设备上按 5/20/5 分钟前后台脚本验收 `actualSeconds`。

---

# High Risk Issues

## P1-1 Pro 没有真正锁住长期历史

- 文件：`lib/presentation/screens/history_screen.dart`、`lib/providers.dart`、`lib/l10n/app_strings.dart`
- 问题：Paywall 文案承诺 “解锁 7 天以上完整历史”，但 History 直接展示 `allRecords()`，没有按 entitlement 截断。
- 影响：免费用户已能看到全部历史；Pro 价值主张与实现不一致。
- 复现：写入超过 7 天的记录后，以 `EntitlementState.free` 打开 `/history`。
- 建议：免费层使用 `recentRecordsProvider`，完整历史进入 Pro。

## P1-2 正式 Paywall 仍显示 Test Store 文案

- 文件：`lib/presentation/screens/paywall_screen.dart`
- 问题：只要 entitlement 不是 `unknown`，就显示 “This debug build uses RevenueCat Test Store. No real charge is made.”
- 影响：若误发到真实用户，会给出错误计费承诺。
- 复现：以 `EntitlementState.free` 打开 `/paywall`。
- 建议：仅 `kDebugMode` 显示 Test Store 提示。

## P1-3 首页在任务未填写时展示占位建议

- 文件：`lib/domain/task_breakdown_repository.dart`、`lib/presentation/screens/entry_screen.dart`
- 问题：空任务时仍展示 “复习线性代数：向量空间的定义” / Section 2.1。
- 影响：用户会以为系统已经为他生成了个性化最小行动。
- 复现：冷启动首页，不选任务。
- 建议：无任务时显示空状态，而不是默认线性代数文案。

## P1-4 FocusSessionRepository 合同未接入

- 文件：`lib/domain/session_repository.dart`、`lib/providers.dart`
- 问题：存在清晰的 repository 接口，但 Timer/Session 仍由 `TimerNotifier` 直接写 Drift。
- 影响：幂等、恢复、finish 路径分散，后续 schema 变更容易漏。
- 建议：让 `TimerNotifier` 走 repository，而不是继续直接操作 `AppDatabase`。

## P1-5 没有 migration 策略

- 文件：`lib/data/database/app_database.dart`
- 问题：`schemaVersion = 1`，无 `onUpgrade` / `MigrationStrategy`。
- 影响：下一版加字段时旧用户会丢数据或崩溃。
- 建议：在第一次真实 schema 变更前补 migration 测试。

## P1-6 进程被杀后的恢复不完整

- 文件：`lib/app.dart`、`lib/providers.dart`
- 问题：能从 `ActiveTimers` 恢复 snapshot，但恢复后不会自动扣掉后台时间；依赖用户点 Continue，且 `lastSavedAt` 可能已过期。
- 影响：杀进程后继续会话，可能把离开时间算进专注，或需要用户理解恢复对话框。
- 建议：恢复时把 `lastSavedAt` 重置为现在，并明确不补后台秒数。

---

# Medium Risk Issues

## P2-1 生命周期观察不完整

- 文件：`lib/app.dart`
- 问题：只处理 `paused` / `inactive`，未处理 `hidden` / `resumed`。通知栏下拉或部分多窗口状态可能漏 pause，或 resume 后不重启 ticker。
- 建议：`resumed` 时若 session 仍标记 running 则继续；`hidden` 也 pause。

## P2-2 Timer 仍依赖 wall clock

- 文件：`lib/providers.dart`
- 问题：`_advance()` 使用 `DateTime.now()` 差值，系统时间被拨快会跳秒，拨慢会被 clamp 为 0。
- 建议：前台用 `Stopwatch`，快照只保存累计秒。

## P2-3 Focus 页面每秒整页重建

- 文件：`lib/presentation/view_models/focus_view_model.dart`、`lib/presentation/screens/focus_screen.dart`
- 问题：`FocusController` watch 整个 `timerProvider`，FocusScreen 每秒 rebuild。
- 建议：把数字计时拆成独立 Consumer。

## P2-4 Insights 全表扫描

- 文件：`lib/data/repositories/drift_insights_repository.dart`
- 问题：每次打开 Insights 都 `allRecords()`，无时间索引查询。
- 建议：按 `startedAt` 建索引，范围查询下推到 SQL。

## P2-5 路由与产品入口漂移

- 文件：`lib/app.dart`、`test/widget_test.dart`、`lib/presentation/screens/entry_screen.dart`
- 问题：冷启动直接进入 `/` Entry，不经过 Welcome；测试仍依赖旧英文长文案和隐藏 1px 文本命中层。
- 影响：欢迎页可达但不是默认路径；测试对真实可见 UI 覆盖不足。

## P2-6 反射跳过仍写入默认评分

- 文件：`lib/presentation/screens/reflection_screen.dart`
- 问题：Skip 仍提交 `difficulty=3`、`focus=3`、`mood=unchanged`，不是 null。
- 影响：Insights 会把“未填写”当成中等专注。
- 建议：schema 允许 reflection 字段 nullable，或增加 `skipped` 标记。

## P2-7 设计系统双轨

- 文件：`lib/design_system/*`、`lib/presentation/theme/app_theme.dart`、History/Reflection/Paywall
- 问题：新首页/Focus 走 StudyLoop design system；History、Reflection、Paywall 仍用旧卡片/蓝色渐变。
- 影响：视觉不统一，Paywall 强渐变偏离克制原则。

## P2-8 无 Dark Mode，但 Android night 主题存在

- 文件：`lib/app.dart`、`android/app/src/main/res/values-night/styles.xml`
- 问题：Flutter 只提供 light theme；系统深色只影响启动窗。
- 建议：锁定 `ThemeMode.light`，避免半套深色。

## P2-9 未使用依赖

- 文件：`pubspec.yaml`
- 问题：`rive` 和 `cupertino_icons` 未在 `lib/` 引用；`FocusSessionRepository` 未被实现。
- 影响：APK 约 81.4MB，Rive native 是明显体积来源。

## P2-10 无 integration_test / golden / coverage

- 问题：没有 `integration_test/`，没有 golden，本轮未跑 `--coverage`。
- 影响：Golden Path（Home → Barrier → Card → Focus → Pause → Finish → Reflection → History → Insights）没有端到端自动化。

## P2-11 枚举用 `.name` 持久化

- 文件：`lib/data/database/app_database.dart`
- 说明：这比 index 安全，但 rename 仍会让 `byName` 崩溃。需要未知值 fallback。

---

# Improvements

## P3-1 文案与 i18n

- 用户可见文案大部分进入 `AppStrings`，但不是 gen-l10n/`intl`。
- Insights 错误、部分 Paywall 标题、debug 设置区仍有硬编码。
- 柯基聊天预设含 “想要放弃”，偏评判，建议改成疲惫/休息表述。

## P3-2 Accessibility

- 首页 barrier 卡片视觉点击区小于 48dp。
- 音乐按钮只有 icon，用 SnackBar 说明“下一版本”，无稳定 semantics label。

## P3-3 权限与网络

- 主 Manifest 未声明 INTERNET/BILLING；debug/profile 才有 INTERNET。
- RevenueCat / Play Billing 在 release 可能依赖合并后的权限。需要用最终 merged manifest 确认。

## P3-4 备份与隐私

- 未设置 `android:allowBackup="false"`。默认备份可能把学习记录同步到云备份。
- 无 Firebase/Analytics/Crashlytics。符合本地优先。

## P3-5 日志

- `corgi_chat_screen.dart` / `corgi_chat_dialog.dart` 仍有 `debugPrint`。
- 未发现生产路径打印任务内容或 RevenueCat customer info。

## P3-6 Git 状态

- 仓库仍是 “No commits yet on main”，全部文件未纳入版本历史。
- 发布前需要真正的 git 基线，而不是只有工作树。

---

# Tests Performed

真正执行过：

1. `flutter pub get`
2. `flutter analyze --no-pub` — No issues found
3. `flutter test --no-pub` — **47 passed**
   - 新增：timer 前后台/暂停/幂等 start/幂等 finishEarly
   - 新增：Insights 空数据不得伪造；真实 3 条记录计算时长/分布/高峰窗口
4. `flutter build apk --release --no-pub`
   - 产物：`build/app/outputs/flutter-apk/app-release.apk`
   - 大小：85,373,228 bytes（81.4MB）
   - SHA-256：`3A4DD1C1046B67403B292B99702237E9E45779FF0DF583A3901B216A6C2B6598`
5. 源码审计：路由、Riverpod、Drift schema、RevenueCat adapter、权限、敏感日志、产品原则
6. 静态扫描：TODO/FIXME、catch-all、print/debugPrint、假数据、惩罚文案

未执行，因此不能声称通过：

- 真机安装与操作
- 锁屏 / 来电 / 分屏 / 系统杀进程
- 字体放大、360/390/412 屏幕、英文 overflow
- Play Billing 真购买（本轮）
- `flutter test --coverage`
- `integration_test`
- golden tests
- DevTools 性能分析
- merged AndroidManifest / R8 mapping 深度检查

历史证据（来自 2026-08-22 记录，可能已过期）：vivo V2458A 上 Test Store `monthly` 购买、冷启动、restore 曾成功；本轮没有复测。

---

# Fixes Applied

本轮只做了产品正确性修复，没有删功能、改测试去迁就错误实现、或禁用 lint。

| 文件 | 修复 |
| --- | --- |
| `lib/data/repositories/drift_insights_repository.dart` | 删除 28.4 小时、假图表、假 9–11 点和假分布；改真实 actualSeconds / 众数时长 / 2 小时窗口 |
| `lib/presentation/screens/insights_screen.dart` | 样本 < 3 只显示 empty state，不再渲染假洞察 |
| `lib/providers.dart` | Timer 改为时间差累计；start/finishEarly 幂等；pause 不计入 |
| `lib/main.dart` | App 先启动，RevenueCat 后台初始化，失败不阻塞免费路径 |
| `lib/data/revenuecat/revenuecat_entitlement_repository.dart` | 增加 `DeferredEntitlementRepository` |
| `lib/presentation/screens/focus_screen.dart` | Back 弹出非惩罚确认，而不是直接丢 session |
| `lib/presentation/screens/reflection_screen.dart` | 可跳过复盘并仍保存 session |
| `lib/l10n/app_strings.dart` | 增加 skip reflection 文案 |
| `test/application/timer_notifier_test.dart` | 覆盖 pause、幂等 start、幂等 finish |
| `test/data/drift_insights_repository_test.dart` | 覆盖空数据与真实计算 |
| `test/presentation/view_models_test.dart` | 空 Insights 不再要求 7 个假点 |

修复后回归：

- `flutter analyze --no-pub`：通过
- `flutter test --no-pub`：47 passed
- `flutter build apk --release --no-pub`：通过

---

# Remaining Risks

无法仅靠本轮自动验证的问题：

1. 真机前后台、锁屏、杀进程后的 actualDuration。
2. 用户改系统时间后的 Timer 跳动。
3. Play Billing 真实购买/恢复（本轮未做外部写入或沙盒购买）。
4. 合并后的 Android 权限是否包含 INTERNET/BILLING。
5. 英文长文案在小屏上的 overflow。
6. 1000+ 记录时 History/Insights 性能。
7. 未来 schema 升级是否丢数据。
8. Pro 历史截断产品决策：当前实现免费即可看全部历史。
9. `.revenuecat.local.json` 存在于磁盘且已 gitignore；构建时未注入该 key。不要提交或打印该文件。

---

# Release Recommendation

**NOT READY**

可以继续给开发者/评委做本地演示：离线启动、选 Barrier、生成最小行动、专注、提前结束保存实际时间、休息路径、RevenueCat 失败不影响免费闭环。这些已经有自动化证据。

不能作为真实用户发布，因为：

1. Release APK 仍是 debug 签名。
2. 启动器名称仍是 `studyloop`。
3. 计时器最高风险场景没有本轮真机证据。
4. Pro 权限与 Paywall 文案不一致。
5. 没有 integration/golden/coverage，也没有商店签名产物。

下一步应按这个顺序，而不是继续扩功能：

1. 正式签名与应用显示名。
2. 真机 Timer 生命周期脚本。
3. 免费/Pro 历史隔离，或改掉 Paywall 承诺。
4. Paywall Test Store 文案仅 debug 显示。
5. 一条 Golden Path integration test。

---

# Plan Follow-up

日期：2026-09-01

执行了 `docs/superpowers/plans/2026-09-01-studyloop-release-gate-plan.md`。

## 已修复

- History 保持全部免费；Paywall / Insights CTA 改为只卖长期规律与跨维度对比。
- Free 不能把 Insights 切到 3 个月/全部；Pro 才渲染 `proInsights`。
- Test Store “不会产生真实扣款”仅 debug 显示。
- Timer `hidden` 会 pause；`restore()` 重置 `lastSavedAt`，离开时间不计为专注。
- 首页无任务时不再展示线性代数占位建议。
- 启动器名称改为 `StudyLoop`。
- `android/key.properties` 存在才用正式签名，否则 release 回退 debug，并已 gitignore 密钥文件。

## 本轮门禁

- `flutter analyze --no-pub`：No issues found
- `flutter test --no-pub`：**53 passed**
- `flutter build apk --release --no-pub`：成功
- 产物：`build/app/outputs/flutter-apk/app-release.apk`
- 大小：85,373,332 bytes（81.4MB）
- SHA-256：`D872CE6B7EBE722BDDF14746976961C64C7241F6BEF2CF2FF5DD1AE5246AEFCE`
- 无 `android/key.properties`，因此本 APK 仍是 debug 签名，不是商店发布包。

## 当前结论

**READY WITH MINOR FIXES**

本地产品边界已经对齐：免费学习闭环、全部 History、Pro 只锁长期 Insights、启动器名称正确。还不能上架，因为缺少正式 keystore。真机 Home 键后台计时和 Golden Path 自动化本轮已补。

## Continuation 2026-09-01

- 新增 `test/presentation/golden_path_test.dart`：Home → Barrier → Task → Card → Focus → Pause → Resume → End early → Skip reflection → History。实际专注 10 秒，计划 900 秒，History 保存提前结束。
- `flutter test --no-pub`：**54 passed**。
- 真机 vivo V2458A (`10AF530FSX002KA`, Android 16) 安装当前 release APK。
- 设备证据：Focus 显示 `04:57` 后按 Home 约 8 秒再回来为 `04:53`，后台时间未计入。提前结束显示 `66 focused seconds · Ended early`；History 为 `Calculus · 2 min · Ended early`。
- 仍未验证：锁屏、来电、系统杀进程、改系统时间。
- 仍缺商店签名：无 `android/key.properties`。
