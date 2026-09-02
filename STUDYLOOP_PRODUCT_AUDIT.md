# 1. Executive Summary

**当前阶段：Beta**

StudyLoop 已经不是 Demo。它具备清晰的单一定位、完整免费核心流程、本地持久化、真实计时、可解释的确定性规则、基础历史和按样本门槛生成的洞察。首页在真机上能够直接回答“我现在为什么学不进去”和“下一步做什么”，没有账号、计划配置或付费墙阻断首次价值。

本轮直接修复了阻力建议未真正差异化、手动暂停被生命周期恢复、洞察在并列样本下虚构偏好、实际时长向上取整、重复购买/反思提交、大字体与小屏溢出、隐私文案过度承诺、正式包调试入口、Android 备份和默认 Flutter 图标等问题。

它仍未达到 Production Ready：正式 APK 使用 Android Debug 证书；缺少上架签名材料、公开隐私政策/支持入口；“跳过反思”仍写入默认评分并污染洞察；数据库没有正式迁移策略；真机完整 Golden Path 因 vivo 输入法阻止 ADB 文本注入而未端到端重跑。结论是适合受控 Beta，不适合直接提交商店。

# 2. Product Scorecard

| 维度 | 分数 | 判断 |
|---|---:|---|
| Product Positioning | 92 | 问题与差异化明确 |
| Core Value | 86 | 阻力到最小行动成立 |
| Onboarding | 82 | 零配置直达首页，但价值解释依赖首页理解 |
| Study Start Flow | 85 | 约 3 页、5–7 次点击、1 次输入 |
| Focus Experience | 79 | 轻量、真实计时；系统时钟变化仍有风险 |
| Data Loop | 73 | 主闭环完整；跳过反思会写伪默认值 |
| Insights Value | 70 | 有门槛与证据，但长期维度仍有限 |
| UI/UX | 81 | 真机首页清晰；小屏大字体自动化通过 |
| Privacy | 84 | 学习数据本地、备份关闭、购买边界已澄清 |
| Subscription Design | 83 | 免费核心完整，Pro 聚焦长期洞察 |
| Stability | 78 | analyze 通过、59 项测试通过；长时真机压力未完成 |
| Long-term Value | 72 | 真实历史有积累价值，洞察深度尚不足 |
| Release Readiness | 54 | Debug 签名和政策材料阻断上架 |
| **Overall Product Score** | **78** | **可进入真实用户 Beta** |

# 3. Core Value Assessment

核心价值成立。产品不是 Todo 或普通番茄钟：首页先让用户识别“无从下手、任务太多、手机干扰、精力不足、过度准备”，再把一个任务转成可观察的小行动。阻力现在会确定性改变建议，例如手机干扰会要求把手机放到够不到的位置，精力不足会生成低能量版本，过度准备会要求停止继续准备。

用户 A–E 均有对应路径。严重不适会进入休息建议而非强推计时，不进行医疗诊断。最大的核心质量风险是：短任务输入仍依赖任务类型和模板，极端含糊输入可能生成通用建议；需要用真实大学生任务语料持续验收，而不是引入黑盒 AI。

# 4. Golden Path

真实主流程为：Launch → Home → 选择 Barrier → Write a task → 输入任务/类型/可用时间 → Create start card → Start Focus → Pause/Finish → Reflection → History → Insights。

自动化 Golden Path 已验证实际秒数保存到 History，计时只在运行时累积，提前结束不记为失败，重复 Start/Finish/Save 被阻止。首次价值点出现在开始卡，通常需要 3 个页面、5–7 次点击和一次文本输入。

摩擦点：必须先命名任务；任务类型选择对部分用户略显产品化；Reflection 的跳过语义当前不真实。真机完成了首页、语言切换、阻力选择和输入框聚焦；系统输入法阻止 ADB 注入文字，后续真机链路标记为 NOT TESTED，而非 PASS。

# 5. First-time User Assessment

首次启动直接进入 Home，没有注册、目标设置、课程配置或付费弹窗。标题“现在为什么学不进去？”与五个阻力卡片能在首屏解释产品差异，主 CTA 指向写下一个任务。Welcome 页面不作为正式入口，这是符合低摩擦定位的选择。

首次用户可以很快获得价值，但“为什么不是普通计时器”的说明主要通过交互体现，而不是一句显式价值主张。当前首页信息量适中，不建议增加传统 onboarding 轮播。

# 6. Returning User Assessment

返回用户仍从 Home 快速开始，历史和洞察被放在底部导航，不会把首页演变为 Dashboard。进行中的计时快照会本地恢复，生命周期暂停不会把离开 App 的时间计入实际专注；手动暂停返回后也不会被自动恢复。

7–30 天后，价值从“帮我开始”扩展到“看到真实投入与初步规律”。90 天留存仍取决于洞察能否持续提供可信行动建议，目前深度只够 Beta。

# 7. Product Loop

Barrier → Action → Focus → Reflection → History → Insight 的技术链路完整：Barrier 参与规则生成；Action 进入计时；Focus 保存 actualSeconds；Reflection 保存难度、专注和情绪；History 展示计划与实际；Insight 使用真实 Session 和样本数。

闭环缺陷：跳过 Reflection 仍保存难度 3、专注 3、情绪不变，这不是“无回答”，会污染休息策略和长期洞察。删除单条记录后洞察会重新查询；没有“删除全部数据”入口。

# 8. P0 Issues

| 问题 | 页面/位置 | 复现与影响 | 建议 | 状态 |
|---|---|---|---|---|
| 正式包使用 Debug 证书 | Android release | 构建 APK 后 `apksigner` 显示 `CN=Android Debug`；无法作为可信商店产物发布 | 配置独立 upload keystore、受保护的 `key.properties`，生成并验证 AAB | 未修复，发布阻断 |
| 缺少公开隐私政策与支持信息 | About/商店资料 | 应用内说明了本地边界，但没有可公开审核的政策 URL、支持邮箱/页面 | 发布前补齐政策、数据安全表和支持入口 | 未修复，发布阻断 |

核心 Beta 使用没有发现“无法完成免费流程、计时丢失或崩溃”类 P0。上述两项是公开发布 P0。

# 9. P1 Issues

| 问题 | 页面/位置 | 复现与影响 | 建议 | 状态 |
|---|---|---|---|---|
| 跳过反思写入默认评分 | Reflection/数据库 | 点击 Skip 后仍产生 3/3/unchanged，洞察把未回答当真实回答 | 增加 `reflectionSkipped` 或 nullable 字段并迁移，计算时排除 | 未修复 |
| 数据库缺少升级迁移策略 | Drift schema | schemaVersion 1，枚举按名称反序列化；未来字段/枚举变更可能导致老数据不可读 | 建立版本化 migration 和升级测试 | 未修复 |
| 计时依赖系统墙钟 | Timer | 专注中手动调整系统时间可能造成跳变或停滞 | 运行期使用 monotonic clock，持久化时保存墙钟元数据 | 未修复 |
| 语言不持久化 | 全局 | 切换中文/英文后重启恢复默认语言 | 保存 locale 偏好并尊重系统语言 | 未修复 |
| 实际时长被向上取整 | History/Reflection | 10 秒曾显示 1 分钟，夸大投入 | 秒级/分秒格式展示 | **已修复** |
| 阻力未改变开始建议 | Start card | 相同任务的五种阻力曾给出近似动作 | Barrier 参与确定性规则并补测试 | **已修复** |
| 手动暂停可能被自动恢复 | Focus/lifecycle | 用户主动暂停后切后台再回来可能继续计时 | 区分 user pause 与 lifecycle pause | **已修复** |
| 并列样本虚构“最佳时长” | Insights | 数据不足时错误声称偏好时长 | 回退为真实总 Session/分钟 | **已修复** |

# 10. P2 / P3

## P2

- 五个英文短标签 `Unsure/Busy/Phone/Tired/Prep` 中 `Busy`、`Prep` 语义偏弱；应改为更直接但仍能放入卡片的词。
- Barrier 卡片存在为组件测试保留的近透明完整标签，可能造成辅助技术重复语义；应改用明确 Semantics 并更新测试定位。
- 缺少“删除全部学习数据”；隐私友好产品应提供一次可确认的全量删除。
- 柯基主要承担陪伴，但 completed 状态没有在首页形成稳定的状态延续。
- `rive` 等依赖使 APK 达到 81.4 MB；应审计未使用依赖和原生库体积。
- 没有生产崩溃观测。保持学习内容本地的前提下，可采用不含任务文本的最小化崩溃报告，或明确接受无遥测运维模式。

## P3

- 历史可增加按 Barrier 的轻量筛选，但不应变成任务管理器。
- Insights 可增加更清晰的“为什么”展开层，统一显示范围、样本和计算方法。
- 首次完成后柯基可短暂显示 completed 状态，不引入积分、等级或养成。
- 英文部分长句可继续做母语级润色。

# 11. Feature Review

| Feature | 决策 | 原因 |
|---|---|---|
| Barrier 识别 | KEEP | 产品入口与差异化核心 |
| Minimum Action | KEEP / IMPROVE | 核心价值；继续用真实任务样本校准 |
| Task type / available time | SIMPLIFY | 有助规则，但避免增加决策负担 |
| Focus timer | KEEP | 服务开始行动，不扩展成复杂番茄钟 |
| Pause / finish early | KEEP | 支持真实、非评判使用 |
| Reflection | IMPROVE | 数据有价值，但 Skip 必须是真跳过 |
| History | KEEP | 免费核心，真实投入证据 |
| Basic Insights | KEEP | 免费闭环的一部分 |
| Long-term comparisons | MOVE TO PRO | 合理的长期增强价值 |
| Corgi companion/chat | SIMPLIFY | 保留陪伴和规则建议，避免演变成宠物养成或伪 AI |
| Debug/demo controls | REMOVE from release | 已通过 `kDebugMode` 隔离 |
| Welcome preview | REMOVE from release | 已隔离，正式流程直达 Home |

# 12. Missing Product Pieces

1. Reflection “未回答”数据模型及迁移。
2. 正式数据库迁移与回滚/备份测试。
3. 全量删除学习数据入口。
4. 正式签名、AAB、隐私政策、支持与商店资料。
5. 一轮人工真机完整 Golden/Bad Path，包括输入、杀进程、断网、恢复购买。

# 13. Unnecessary Complexity

- Corgi 独立聊天页比核心启动路径更重，建议限制为 Barrier 解释、休息建议和下一步提示，不继续扩展通用聊天。
- Task type 是规则输入，但对“只想开始”的用户可能形成额外选择；可以提供可靠默认值。
- 未使用或低价值的 Rive/native 依赖应删除，降低包体和构建风险。
- 不应增加通知、签到、积分、排行榜、社交、账号、云同步或生成式 AI。

# 14. Subscription Review

免费用户可以完成 Barrier、Action、Focus、Reflection、完整基础 History 和基础 Insights。Paywall 不在启动或专注前出现，仅在用户主动访问高级长期洞察时出现。购买失败只影响 Pro，不阻塞本地核心流程；Restore 可从设置访问。

RevenueCat Test Store 已用于购买/恢复验证，但 Test Store 不是生产商店配置。正式发布必须切换对应商店产品并复核 entitlement/offering/package。购买和恢复现在有 busy guard，防止重复请求。Pro 边界合理，不破坏免费核心价值。

# 15. Privacy Review

任务、Session、Reflection 和 Insight 源数据保存在 Drift/SQLite 本地；核心流程无需账号或服务器。RevenueCat 仅处理匿名购买身份和 entitlement，不应接收学习内容。应用文案已修正为“学习内容留在设备”，避免把购买通信误说成完全无网络。

Android `allowBackup=false`、`fullBackupContent=false` 已启用。合并清单包含 INTERNET、ACCESS_NETWORK_STATE、BILLING 和应用内部动态接收器权限，没有发现联系人、位置、麦克风或存储广泛权限。缺口是公开隐私政策和应用内全量删除。

# 16. Product Language Review

整体语气温和，不使用失败次数、落后、断签、必须坚持或排行榜。提前结束描述为 Ended early，不判定失败；严重疲惫允许休息。预设中文“想要放弃”已改为“想先停一下”。

中英文核心信息一致。英文 Barrier 的短标签仍可改进，`Busy` 容易被理解为日程忙而非任务过载，`Prep` 略像功能缩写。CTA 大多描述后果，例如 Create my start card、Start focus、Save reflection。

# 17. Long-term Value

- **Day 1：** 把“不想开始”转成一个立即可做的小行动。
- **Day 7：** 看到真实投入、任务类型与初步启动规律，不依赖签到。
- **Day 30：** 从足够样本中观察时间段、时长、专注和情绪关系。
- **Day 90：** 保存 StudyLoop 的理由应是可信的个人学习历史和可行动规律，而不是计时器本身。

当前 Day 1/7 价值强，Day 30 可用，Day 90 仍偏弱。需要提高洞察的解释性和数据质量，而不是增加游戏化留存。

# 18. Competitive Position

普通计时器只回答“计多久”；Todo/Notion 管理“有什么任务”；Forest 用约束和奖励促使专注；ChatGPT 可以临时拆任务但输出不稳定、不可解释且可能上传内容。StudyLoop 的独特答案是：先识别当下启动阻力，用本地确定性规则给出可重复的小行动，再记录真实投入并积累个人规律。

一句话表达：**帮你把“不想开始”变成一个现在就能做的小动作。**

最可能的删除原因：建议重复或过于通用、输入步骤比直接计时慢、洞察长期不变、反思显得多余、用户已有番茄钟、包体较大、跨设备后本地记录丢失。前四项应作为 Beta 访谈重点。

# 19. Release Checklist

| 检查项 | 状态 | 证据/备注 |
|---|---|---|
| Flutter analyze | PASS | 0 issues |
| 自动化测试 | PASS | 59/59 |
| 360×640 + 1.5 text scale | PASS | 核心空状态路径无 overflow |
| Release APK 构建 | PASS | 81.4 MB |
| 正式签名 | FAIL | Android Debug 证书，缺少 `android/key.properties` |
| 真机安装 | PASS | vivo V2458A 覆盖安装成功 |
| 真机首页渲染 | PASS | 中文/英文首页清晰，无明显溢出 |
| 真机输入框唤醒 | PASS | 可聚焦并显示光标 |
| 真机完整 Golden Path | NOT TESTED | vivo 输入法阻止 ADB 文本注入，连接亦不稳定 |
| 自动化 Golden Path | PASS | actualSeconds 写入 History |
| Pause/Resume | PASS | 单元测试覆盖手动与生命周期暂停 |
| 重复 Start/Finish/Save/Purchase | PASS | 幂等与 busy guard 测试 |
| 断网核心流程 | PASS by architecture | 本地规则/DB 不依赖网络；本轮未做真机飞行模式 |
| 系统杀进程恢复 | PASS by automated behavior | 快照恢复测试；本轮未做真机强杀全链路 |
| RevenueCat 故障隔离 | PASS | repository/view-model 测试 |
| Test Store purchase/restore | PASS, historical | 已有真机证据；不是生产商店验收 |
| 学习数据本地优先 | PASS | Drift 本地存储，购买边界已澄清 |
| Android 备份关闭 | PASS | 合并 manifest 已验证 |
| Debug/demo 隔离 | PASS | release 由 `kDebugMode` 隐藏 |
| App icon/name/package/version | WARNING | 图标、StudyLoop、`com.zzy.studyloop`、`1.0.0+1` 存在；版本需按发布计划更新 |
| 隐私政策/支持入口 | FAIL | 未提供公开可审核材料 |
| 数据迁移 | FAIL | 无版本升级验证 |
| 30–50 分钟人工压力测试 | NOT TESTED | 本轮设备连接不稳定 |

# 20. Final Verdict

**READY FOR BETA**

StudyLoop 已形成明确、有用、低压力、本地优先的产品闭环，适合交给一小批真实大学生使用并收集任务拆解质量、反思负担和长期洞察价值反馈。它不是 Production Ready：正式签名、隐私/支持材料、Reflection 跳过数据真实性和数据库迁移必须先解决，并补一轮稳定真机人工验收。

## 最后 10 个问题

1. **解决的问题是否足够明确？** 是。它解决“知道该学但无法开始”，不是泛任务管理。
2. **第一次打开是否能理解产品？** 基本能。首页问题、五个阻力和主 CTA 在首屏形成清晰路径。
3. **Minimum Action 是否真正有价值？** 大多数规则满足具体、小、可观察和立即执行；仍需真实任务语料验证含糊输入和重复感。
4. **从打开到开始学习是否足够短？** 是，约 3 页、5–7 次点击和一次输入，没有账号或复杂配置。
5. **Focus 是否抢走核心定位？** 没有。它是 Action 之后的轻量执行容器，没有音乐、标签、模式或复杂番茄设置。
6. **数据是否形成完整闭环？** 主闭环完整，但跳过 Reflection 写默认值是必须修复的数据真实性缺口。
7. **Insights 是否值得长期记录？** 已具备基础价值和样本门槛，但 30–90 天价值还需更丰富、可解释的行动建议。
8. **Pro 是否破坏免费核心体验？** 没有。即时帮助、专注、反思、历史和基础洞察都免费。
9. **为什么不用普通番茄钟？** 番茄钟只计时；StudyLoop 在计时前识别阻力、缩小任务，并在之后积累真实启动规律。
10. **现在是否应该让真实用户使用？** 应该，以受控 Beta 形式使用；不应在解决发布 P0/P1 前直接上架生产商店。
