import '../domain/models.dart';

class AppStrings {
  const AppStrings({required this.isChinese});
  final bool isChinese;

  static const zh = AppStrings(isChinese: true);
  static const en = AppStrings(isChinese: false);

  static AppStrings ofLocale(String locale) =>
      locale.startsWith('zh') ? zh : en;

  // App & General
  String get appTitle => isChinese ? 'StudyLoop · 专注起步' : 'StudyLoop';
  String get appSubtitle =>
      isChinese ? '温和陪伴，帮你迈出学习的第一步' : 'A calm companion to help you start';
  String get continueBtn => isChinese ? '继续' : 'Continue';
  String get writeTaskCta => isChinese ? '写下任务' : 'Write a task';
  String get cancel => isChinese ? '取消' : 'Cancel';
  String get delete => isChinese ? '删除' : 'Delete';
  String get save => isChinese ? '保存' : 'Save';
  String get back => isChinese ? '返回' : 'Back';
  String get returnHome => isChinese ? '返回首页' : 'Return home';
  String get notNow => isChinese ? '暂不需要' : 'Not now';
  String get languageToggleTooltip =>
      isChinese ? 'Switch to English' : '切换到简体中文';

  // Companion
  String get companionBadge => isChinese ? '柯基小狗伴侣' : 'Corgi Companion';
  String get companionChatBadge => isChinese ? '💬 和小狗聊聊' : '💬 Chat';
  String get companionChatBadgeQuiet => isChinese ? '聊聊' : 'Chat';
  String get companionChatTitle =>
      isChinese ? '柯基学习伴侣' : 'Corgi Study Companion';
  String get companionChatSubtitle => isChinese
      ? '无压力倾诉 · 极小行动拆解 · 随时为你打气'
      : 'Zero pressure · Tiny action breakdown · Always cheering you on';
  String get companionChatHint => isChinese
      ? '跟柯基说点什么，比如“学不进去”、“想玩手机”...'
      : 'Say something to Corgi, e.g. "stuck", "want to check phone"...';
  String get companionChatSend => isChinese ? '发送' : 'Send';
  String get companionChatAdoptAction =>
      isChinese ? '填入此极小行动' : 'Apply Micro-Action';
  String get companionChatActionApplied =>
      isChinese ? '已填入任务！' : 'Micro-action applied!';
  String get companionChatClose => isChinese ? '关闭' : 'Close';

  // AI Privacy & Thinking
  String get aiPrivacyTitle =>
      isChinese ? 'AI 伴侣隐私提示' : 'AI Companion Privacy Notice';
  String get aiPrivacyNotice => isChinese
      ? '为了生成回复，你发送给柯基的消息会通过网络交给 AI 服务处理。\n你的本地学习记录与数据库不会默认全部上传。'
      : 'To generate responses, messages you send to Corgi are processed via network AI services.\nYour local study records and full database are never uploaded.';
  String get aiPrivacyAccept =>
      isChinese ? '我知道了，开始交流' : 'I understand & Continue';
  String get aiPrivacyCancel => isChinese ? '返回' : 'Go back';
  String get aiThinking => isChinese ? '柯基正在思考...' : 'Corgi is thinking...';
  String get aiMicroActionCta =>
      isChinese ? '让柯基帮我再缩小一点 (AI 拆解)' : 'Ask Corgi to make this smaller (AI)';
  String get aiMicroActionLoading => isChinese
      ? '🐾 柯基正在帮你把任务拆成轻松第 1 步...'
      : '🐾 Corgi is finding an easier first step...';
  String get aiMicroActionSuggestion =>
      isChinese ? '柯基建议的极小切入点' : 'Corgi suggests a tiny first step';
  String get aiMicroActionAdopt =>
      isChinese ? '采用这个极小行动' : 'Use this tiny action';
  String get aiMicroActionAdopted => isChinese
      ? '已采用柯基极小行动，直接点击下方开始起步！'
      : 'Tiny action added. Tap below to get started!';

  // Help & Support
  String get helpAndSupportTitle => isChinese ? '帮助与支持' : 'Help & Support';
  String get faqTitle =>
      isChinese ? '常见问题 (FAQ)' : 'Frequently Asked Questions';
  String get faqItem1Question => isChinese
      ? '我的专注记录会上传到服务器吗？'
      : 'Are my study records uploaded to servers?';
  String get faqItem1Answer => isChinese
      ? '不会。StudyLoop 的核心学习数据（任务、专注时长、复盘等）100% 保存在本地 SQLite 数据库中。无需注册，离线即可使用。'
      : 'No. Core study records (tasks, focus time, reflections) stay 100% on your local device. No registration required, works fully offline.';
  String get faqItem2Question => isChinese
      ? '柯基 AI 伴侣如何处理我的消息？'
      : 'How does Corgi AI Companion handle my messages?';
  String get faqItem2Answer => isChinese
      ? '你主动发送给柯基的聊天内容会通过网络交由 AI 服务处理。我们遵循最小化原则，仅发送当前上下文与本地近期统计概况，绝不上传你的完整数据库。'
      : 'Messages you actively send to Corgi are sent to AI services to generate suggestions. We practice strict data minimization and never upload your full database.';
  String get feedbackTitle => isChinese ? '问题反馈与支持' : 'Feedback & Support';
  String get feedbackContactText => isChinese
      ? '如有任何疑问、异常反馈或改进建议，请在项目仓库提交 Issue 或联系支持通道。\n[SUPPORT CONTACT REQUIRED BEFORE RELEASE: support@studyloop.app]'
      : 'For questions, bug reports, or suggestions, please file an issue or contact our support channel.\n[SUPPORT CONTACT REQUIRED BEFORE RELEASE: support@studyloop.app]';
  String get privacyPolicyTitle => isChinese ? '隐私政策' : 'Privacy Policy';
  String get appVersionLabel => isChinese ? '版本号' : 'App Version';
  String get appVersionValue => 'v1.0.0 (RC-1, Build 1)';

  String dogLabel(DogState state) => switch (state) {
    DogState.waiting =>
      isChinese ? '你的柯基小狗正在安静地陪着你。' : 'Your Corgi is waiting quietly.',
    DogState.prompting =>
      isChinese
          ? '你的柯基小狗可以帮你先写下一个课程名称。'
          : 'Your Corgi can help you name just one course.',
    DogState.focusing =>
      isChinese ? '你的柯基小狗正在你身边安静休息。' : 'Your Corgi is resting beside you.',
    DogState.completed =>
      isChinese ? '你的柯基小狗看起来很欣慰。' : 'Your Corgi looks gently happy.',
    DogState.interrupted =>
      isChinese ? '你的柯基小狗依然陪在你身边。' : 'Your Corgi is still here with you.',
    DogState.resting =>
      isChinese ? '你的柯基小狗正在陪你好好休息。' : 'Your Corgi is resting with you.',
  };

  // Entry Screen (Barriers)
  String get entryTitle =>
      isChinese ? '现在为什么学不进去？' : 'Why can’t you study right now?';
  String get entrySubtitle => isChinese
      ? '选择你此刻的真实状态，没有评判，我们一步一步来。'
      : 'Choose your current state. No judgment, one small step at a time.';

  String barrierLabel(StudyBarrier barrier) => switch (barrier) {
    StudyBarrier.uncertainStart =>
      isChinese ? '我不知道从何开始' : "I don't know where to start",
    StudyBarrier.overload => isChinese ? '要做的事太多了' : 'There is too much to do',
    StudyBarrier.phoneDistraction =>
      isChinese ? '总是忍不住想看手机' : 'I keep reaching for my phone',
    StudyBarrier.tiredness =>
      isChinese ? '太累了，脑子转不动' : 'I am too tired to think clearly',
    StudyBarrier.perfectionism =>
      isChinese ? '一直在做准备，迟迟不开始' : 'I keep preparing instead of starting',
  };

  String barrierDesc(StudyBarrier barrier) => switch (barrier) {
    StudyBarrier.uncertainStart =>
      isChinese
          ? '任务没有头绪，需要一个极小的切入点'
          : 'Unclear where to begin; need a tiny entry point',
    StudyBarrier.overload =>
      isChinese ? '内容堆积如山，感到喘不过气' : 'Too much piled up; feeling overwhelmed',
    StudyBarrier.phoneDistraction =>
      isChinese
          ? '注意力分散，下意识寻找即时反馈'
          : 'Scattered attention; craving immediate stimulation',
    StudyBarrier.tiredness =>
      isChinese ? '精力不足，需要评估疲惫程度' : 'Low energy; need to check fatigue level',
    StudyBarrier.perfectionism =>
      isChinese
          ? '想准备得完全充分才动笔，陷入拖延'
          : 'Over-preparing instead of taking the first real step',
  };

  // Fatigue Question
  String get fatigueQuestion =>
      isChinese ? '此刻的疲惫感觉如何？' : 'How does the tiredness feel?';
  String get fatigueOrdinaryTitle => isChinese ? '普通疲惫' : 'Ordinary tiredness';
  String get fatigueOrdinaryDesc => isChinese
      ? '脑子有点钝，但身体无大碍，可以做最简单的任务'
      : 'A bit sluggish, but able to do a very light action';
  String get fatigueSevereTitle =>
      isChinese ? '头痛或明显身体不适' : 'Headache or clear physical discomfort';
  String get fatigueSevereDesc => isChinese
      ? '身体发出暂停信号，此时休息才是最有效的选择'
      : 'Body needs rest; forcing study now is counterproductive';

  String get historyAndInsights => isChinese ? '历史与规律' : 'History and insights';
  String get settings => isChinese ? '设置' : 'Settings';

  // Task Screen
  String get taskScreenTitle =>
      isChinese ? '写下一个可以推进的小任务' : 'Name one thing to move forward';
  String get taskScreenShortTitle => isChinese ? '写下任务' : 'Name one task';
  String get taskScreenSubtitle =>
      isChinese ? '哪怕只是写下课程或项目名称也可以' : 'A course or project name is enough';
  String get taskFieldLabel =>
      isChinese ? '任务、课程或项目名称' : 'Task, course, or project name';
  String get taskFieldHint =>
      isChinese ? '例如：微积分复习、实验报告、代码重构' : 'Course or project name is enough';
  String get taskTypeLabel => isChinese ? '任务类型' : 'Task type';
  String get revisionTypeLabel => isChinese ? '复习类型' : 'Revision type';
  String get availableTimeLabel => isChinese ? '可用时间' : 'Available time';
  String get createStartCardBtn =>
      isChinese ? '生成我的起步卡片' : 'Create my start card';

  String taskTypeTitle(TaskType type) => switch (type) {
    TaskType.examRevision => isChinese ? '考试复习' : 'Exam Review',
    TaskType.homework => isChinese ? '作业' : 'Homework',
    TaskType.programmingPractice => isChinese ? '编程练习' : 'Coding',
    TaskType.paperWriting => isChinese ? '论文写作' : 'Writing',
    TaskType.reading => isChinese ? '阅读' : 'Reading',
    TaskType.memorization => isChinese ? '背诵记忆' : 'Memorization',
    TaskType.preview => isChinese ? '课程预习' : 'Preview',
    TaskType.project => isChinese ? '项目任务' : 'Project',
    TaskType.other => isChinese ? '其他' : 'Other',
  };

  String examSubtypeTitle(ExamSubtype type) => switch (type) {
    ExamSubtype.memory => isChinese ? '记忆与背诵' : 'Memory',
    ExamSubtype.calculation => isChinese ? '习题与计算' : 'Calculation',
    ExamSubtype.understanding => isChinese ? '理解与概念' : 'Understanding',
  };

  String minutesUnit(int minutes) => isChinese ? '$minutes 分钟' : '$minutes min';

  // Start Card Screen
  String get startCardTitle => isChinese ? '迈出极小的一步' : 'One small start';
  String get startCardFallback =>
      isChinese ? '请返回并创建有效的起步卡片。' : 'Return and create a valid card.';
  String get startCardBadge =>
      isChinese ? '今日微行动' : 'Immediate Starting Action';
  String get whyThisWorks => isChinese ? '为什么这样有效' : 'Why this helps';
  String get makeItSmaller => isChinese ? '还可以更小一点' : 'Make it smaller';
  String get smallestActionReached => isChinese
      ? '这个最小的行动对今天已经足够了。'
      : 'This smallest useful action is enough for today.';
  String get startFocusing => isChinese ? '开始专注' : 'Start focusing';
  String get editTask => isChinese ? '修改任务' : 'Edit task';
  String plannedMinutesText(int minutes) =>
      isChinese ? '计划专注 $minutes 分钟' : '$minutes minutes';
  String reductionStep(int level) => isChinese
      ? '行动拆解：第 ${level + 1} 级 / 共 4 级'
      : 'Action step ${level + 1} of 4';

  // Timer & Focus Screen
  String get timerActionBadge =>
      isChinese ? '🎯 当前极小行动' : '🎯 Immediate Action';
  String get timerFocusing => isChinese ? '正在专注' : 'Focusing';
  String get timerPaused => isChinese ? '已暂停' : 'Paused';
  String get focusTitle => isChinese ? '专注在这一步' : 'Focus on this one step';
  String get noActiveSession =>
      isChinese ? '当前没有进行中的专注会话。' : 'No active session.';
  String focusedSecondsRecorded(int seconds) =>
      isChinese ? '已记录专注 $seconds 秒' : '$seconds focused seconds recorded';
  String get pause => isChinese ? '暂停' : 'Pause';
  String get resume => isChinese ? '继续' : 'Continue';
  String get endEarly => isChinese ? '提前结束' : 'End early';
  String get endEarlyDialogTitle =>
      isChinese ? '保存这次学习？' : 'Save this study session?';
  String get endEarlyDialogContent => isChinese
      ? '我们会如实记录你的实际投入时间。'
      : 'We will record the time you actually spent.';
  String get returnToTimer => isChinese ? '返回计时' : 'Return to timer';
  String get saveFocusedTime => isChinese ? '保存专注时间' : 'Save focused time';

  // Reflection Screen
  String get reflectionTitle => isChinese ? '刚才感觉如何？' : 'How did that feel?';
  String reflectionSummary(int seconds, bool completed) => isChinese
      ? '已专注 ${formatDuration(seconds)} · ${completed ? '顺利完成' : '提前结束'}'
      : '${formatDuration(seconds)} focused · ${completed ? 'Completed' : 'Ended early'}';
  String get actualDifficultyLabel =>
      isChinese ? '实际难度评估' : 'Actual difficulty';
  String get focusLevelLabel => isChinese ? '专注投入程度' : 'Focus';
  String get emotionalChangeLabel => isChinese ? '情绪状态变化' : 'Emotional change';
  String get moodMoreAtEase => isChinese ? '更加轻松' : 'More at ease';
  String get moodUnchanged => isChinese ? '没有变化' : 'No change';
  String get moodWorse => isChinese ? '变差了' : 'Worse';
  String get nextActionLabel =>
      isChinese ? '下一步行动（可选）' : 'Next action (optional)';
  String get nextActionHint =>
      isChinese ? '写下趁热打铁想做的事，或留空' : 'What comes next when you are ready';
  String get saveReflectionBtn => isChinese ? '保存记录' : 'Save reflection';
  String get skipReflectionBtn =>
      isChinese ? '跳过复盘并保存本次学习' : 'Skip reflection and save this session';

  // Rating Pill Descriptors
  String difficultyRating(int level) => switch (level) {
    1 => isChinese ? '很轻松' : 'Very easy',
    2 => isChinese ? '较顺利' : 'Manageable',
    3 => isChinese ? '中等' : 'Moderate',
    4 => isChinese ? '较吃力' : 'Challenging',
    5 => isChinese ? '极吃力' : 'Very hard',
    _ => '',
  };

  String focusRating(int level) => switch (level) {
    1 => isChinese ? '心不在焉' : 'Distracted',
    2 => isChinese ? '偶有走神' : 'Somewhat unfocused',
    3 => isChinese ? '基本投入' : 'Fairly focused',
    4 => isChinese ? '高度专注' : 'Very focused',
    5 => isChinese ? '全神贯注' : 'Deep flow',
    _ => '',
  };

  // Summary Screen
  String get summaryTitle => isChinese ? '真实的起步' : 'A real start';
  String get summaryMessage => isChinese
      ? '你记录下了真实发生的事情。没有评分，没有评判。'
      : 'You recorded what actually happened. No score, no judgment.';
  String get startAnother => isChinese ? '开启下一个专注' : 'Start another';
  String get seeHistory => isChinese ? '查看历史记录' : 'See history';

  // History Screen
  String get historyTitle => isChinese ? '近期记录' : 'Recent history';
  String get historyEmpty => isChinese
      ? '你的第一条真实学习记录将出现在这里。'
      : 'Your first honest study record will appear here.';
  String get beginFirstSession =>
      isChinese ? '开始第一次专注' : 'Begin the first session';
  String get viewPatterns => isChinese ? '查看规律与洞察' : 'View patterns';
  String historySubtitle(int seconds, bool completed, bool synthetic) =>
      isChinese
      ? '${formatDuration(seconds)} · ${completed ? '顺利完成' : '提前结束'}${synthetic ? ' · 示例演示' : ''}'
      : '${formatDuration(seconds)} · ${completed ? 'Completed' : 'Ended early'}${synthetic ? ' · Synthetic demo' : ''}';

  String formatDuration(int seconds) {
    final safeSeconds = seconds.clamp(0, 1 << 31);
    final minutes = safeSeconds ~/ 60;
    final remainingSeconds = safeSeconds % 60;
    if (minutes == 0) {
      return isChinese ? '$remainingSeconds 秒' : '${remainingSeconds}s';
    }
    if (remainingSeconds == 0) {
      return isChinese ? '$minutes 分钟' : '${minutes}m';
    }
    return isChinese
        ? '$minutes 分 $remainingSeconds 秒'
        : '${minutes}m ${remainingSeconds}s';
  }

  String get historyUnavailable =>
      isChinese ? '历史记录不可用' : 'History is unavailable';

  // History Detail
  String get historyDetailTitle => isChinese ? '记录详情' : 'Record Detail';
  String get recordNotFound =>
      isChinese ? '该记录已不存在。' : 'This record no longer exists.';
  String get deleteRecordTitle =>
      isChinese ? '删除此本地记录？' : 'Delete this local record?';
  String get deleteRecordContent => isChinese
      ? '此操作无法撤销，学习规律将重新计算。'
      : 'This cannot be undone and patterns will be recalculated.';
  String get deleteRecordBtn => isChinese ? '删除记录' : 'Delete record';
  String focusedSecondsDetail(int seconds) =>
      isChinese ? '已专注 $seconds 秒' : '$seconds focused seconds';
  String moodDetail(MoodChange mood) =>
      isChinese ? '心情变化：${moodName(mood)}' : 'Mood: ${mood.name}';
  String moodName(MoodChange mood) => switch (mood) {
    MoodChange.moreAtEase => isChinese ? '更加轻松' : 'More at ease',
    MoodChange.unchanged => isChinese ? '无明显变化' : 'No change',
    MoodChange.worse => isChinese ? '感觉变差' : 'Worse',
  };
  String get sessionDateLabel => isChinese ? '记录时间' : 'Session Date';
  String get taskNameLabel => isChinese ? '任务内容' : 'Task Name';
  String get plannedTimeLabel => isChinese ? '计划时长' : 'Planned Duration';
  String get actualFocusLabel => isChinese ? '实际专注' : 'Actual Focus';
  String get completionStatusLabel => isChinese ? '完成状态' : 'Status';
  String get statusCompleted => isChinese ? '顺利完成' : 'Completed';
  String get statusInterrupted => isChinese ? '提前结束' : 'Ended early';
  String get statusSynthetic => isChinese ? '示例演示数据' : 'Synthetic Demo';
  String get noneRecorded => isChinese ? '未填写' : 'None recorded';

  // Insights Screen
  String get insightsTitle => isChinese ? '我的学习洞察' : 'My insights';
  String insightProgress(int current, int total) => isChinese
      ? '已收集 $current / $total 条记录。再记录 ${total - current} 次即可解锁你的首个规律洞察。'
      : '$current of $total records collected. ${total - current} more to unlock your first observation.';
  String get insightKeepRecording => isChinese
      ? '继续记录专注会话，对比真实发生的情况。'
      : 'Keep recording sessions to compare what actually happened.';
  String evidenceCountText(int count) =>
      isChinese ? '依据：最近 7 天的 $count 次会话' : 'Evidence: $count recent sessions.';
  String get longTermPatterns => isChinese ? '长期多维规律' : 'Long-term patterns';
  String get unlockProInsights =>
      isChinese ? '解锁长期多维规律对比' : 'Unlock long-term pattern comparisons';
  String get proStatusCannotVerify =>
      isChinese ? '当前无法验证 Pro 状态' : 'Pro status cannot be verified right now';

  // Paywall Screen
  String get paywallTitle => isChinese ? 'StudyLoop Pro' : 'StudyLoop Pro';
  String get paywallHeadline => isChinese
      ? '核心学习闭环和全部学习记录永久免费。\nPro 解锁 3 个月及以上的长期规律与跨维度对比。'
      : 'The full study loop and all local history stay free. Pro unlocks 3-month and all-time pattern comparisons.';
  String get paywallFeature1 => isChinese
      ? '即时起步、小狗陪伴与计时闭环永久完全免费'
      : 'Immediate starting actions & companion always free';
  String get paywallFeature2 => isChinese
      ? '3 个月与全部范围的长期趋势'
      : 'Long-term trends across 3 months and all records';
  String get paywallFeature3 => isChinese
      ? '任务类型与启动障碍多维交叉对比'
      : 'Cross-comparison across barriers & task types';
  String get continueWithPro =>
      isChinese ? '开通 StudyLoop Pro' : 'Continue with Pro';
  String get restorePurchases => isChinese ? '恢复购买' : 'Restore purchases';
  String get paywallOfflineNotice => isChinese
      ? 'Pro 状态当前无法验证。免费学习功能离线正常使用。'
      : 'Pro status cannot be verified right now. Free study help still works offline.';
  String get paywallTestStoreNotice => isChinese
      ? '此调试版本使用 RevenueCat 测试商店，不会产生真实扣款。'
      : 'This debug build uses RevenueCat Test Store. No real charge is made.';

  // Settings Screen
  String get settingsTitle => isChinese ? '设置' : 'Settings';
  String get languageSection =>
      isChinese ? '界面语言 / Language' : 'Language / 界面语言';
  String get chineseLang => '简体中文';
  String get englishLang => 'English';
  String get seedDemoDataTitle =>
      isChinese ? '写入示例演示数据' : 'Seed clearly labeled synthetic demo data';
  String get clearDemoDataTitle =>
      isChinese ? '清除示例演示数据' : 'Clear synthetic demo data';
  String get restorePurchasesDesc => isChinese
      ? '恢复已购买的 StudyLoop Pro 权益'
      : 'Restore previously purchased StudyLoop Pro entitlement';
  String get aboutTitle => isChinese ? '关于 StudyLoop' : 'About StudyLoop';
  String get aboutDesc => isChinese
      ? 'StudyLoop 是一款面向大学生的温和、本地优先起步伴侣。任务、专注和复盘保存在本机；只有购买与权益状态由 RevenueCat 处理，学习内容不会发送给它。'
      : 'StudyLoop is a calm, local-first study-start companion. Tasks, focus sessions, and reflections stay on this device; RevenueCat handles only purchases and entitlement status, not study content.';

  // Rest Screen
  String get restTitle => isChinese ? '休息也是有效的一步' : 'Rest is a valid next step';

  // Recovery Dialog
  String get recoveryTitle =>
      isChinese ? '发现未完成的学习会话' : 'A study session is waiting';
  String get recoveryContent => isChinese
      ? '离开 StudyLoop 期间的时间未计入专注。'
      : 'Time away from StudyLoop was not counted.';
  String get recoveryContinue => isChinese ? '继续此会话' : 'Continue this session';

  // Redesign: Welcome Screen
  String get welcomeHeadline => isChinese
      ? '从现在开始，\n迈出你的一小步。'
      : 'Starting right now,\ntake your first small step.';
  String get startJourneyBtn =>
      isChinese ? '开始你的学习之旅' : 'Start your study journey';
  String get languageBtn => isChinese ? 'Language / 语言' : 'Language / 语言';
  String get privacyBadgeText =>
      isChinese ? '所有数据保存在本地设备中 · 隐私安心' : 'All study data stays on this device';

  // Redesign: Home Screen (Learning Start)
  String get greetingGoodMorning => isChinese ? '早上好！👋' : 'Good morning! 👋';
  String get greetingGoodAfternoon =>
      isChinese ? '下午好！👋' : 'Good afternoon! 👋';
  String get greetingGoodEvening => isChinese ? '晚上好！👋' : 'Good evening! 👋';
  String get homeQuestion =>
      isChinese ? '今天想解决什么问题？' : 'What would you like to tackle today?';
  String get homeSubtitle => isChinese
      ? '先找出阻力，才能迈出第一步。'
      : 'Identify the barrier first, then take the first step.';

  String barrierShortLabel(StudyBarrier barrier) => switch (barrier) {
    StudyBarrier.uncertainStart => isChinese ? '无从下手' : 'Unsure',
    StudyBarrier.overload => isChinese ? '任务太多' : 'Busy',
    StudyBarrier.phoneDistraction => isChinese ? '手机干扰' : 'Phone',
    StudyBarrier.tiredness => isChinese ? '精力不足' : 'Tired',
    StudyBarrier.perfectionism => isChinese ? '过度准备' : 'Prep',
  };

  String get suggestedActionTitle =>
      isChinese ? '今日建议的最小行动' : 'Suggested Micro-Action Today';
  String get suggestedActionEmptyTitle =>
      isChinese ? '先写下今天要推进的一件事' : 'Name one thing to move forward';
  String get suggestedActionEmptyDesc => isChinese
      ? '写下一个课程、作业或项目名称后，再生成可立即开始的最小行动。'
      : 'Add a course, assignment, or project name to generate a tiny starting action.';

  String get startFocusCTA => isChinese ? '开始专注' : 'Start Focus';
  String get estimatedFocus => isChinese ? '预计专注' : 'Est. Focus';
  String get difficultyEstimate => isChinese ? '难度预估' : 'Difficulty';
  String get difficultyMedium => isChinese ? '中等' : 'Medium';
  String get difficultyEasy => isChinese ? '轻度' : 'Light';
  String get difficultyChallenging => isChinese ? '较难' : 'Challenging';

  String get companionCushionTitle =>
      isChinese ? '柯基伙伴在这里陪着你 🐾' : 'Corgi is here with you';
  String get companionCushionWaiting => isChinese
      ? '准备好就开始吧，我会在这里等你回来。'
      : 'Start whenever you are ready. I will wait here.';
  String companionCushionMessage(DogState state) => switch (state) {
    DogState.waiting => companionCushionWaiting,
    DogState.prompting =>
      isChinese
          ? '先写下一个课程、作业或项目名称，我陪着你。'
          : 'Name one course or project. I will stay with you.',
    DogState.focusing =>
      isChinese
          ? '你在专注，我就安静地待在旁边。'
          : 'I will stay quiet beside you while you focus.',
    DogState.completed =>
      isChinese
          ? '你已经迈出了这一步，这就够了。'
          : 'You already took a real step. That is enough.',
    DogState.interrupted =>
      isChinese
          ? '提前结束也没关系，时间已经记下来了。'
          : 'Ending early is fine. Your time is already saved.',
    DogState.resting =>
      isChinese
          ? '先休息一会儿，学习可以等身体准备好。'
          : 'Rest first. Study can wait until you are ready.',
  };
  String companionStatus(DogState state) => switch (state) {
    DogState.waiting => isChinese ? '等待中' : 'Waiting',
    DogState.prompting => isChinese ? '准备写下' : 'Ready to name',
    DogState.focusing => isChinese ? '陪伴专注' : 'Focusing',
    DogState.completed => isChinese ? '已完成' : 'Done',
    DogState.interrupted => isChinese ? '已保存' : 'Saved',
    DogState.resting => isChinese ? '休息中' : 'Resting',
  };
  String get companionStatusWaiting => companionStatus(DogState.waiting);
  String get settingsTooltip => isChinese ? '设置' : 'Settings';
  String get languageTooltip => isChinese ? '切换语言' : 'Switch language';
  String get closeFocusTooltip =>
      isChinese ? '结束这次专注' : 'End this focus session';

  // Redesign: Bottom Navigation
  String get navHome => isChinese ? '首页' : 'Home';
  String get navRecords => isChinese ? '记录' : 'Records';
  String get navInsights => isChinese ? '洞察' : 'Insights';
  String get navProfile => isChinese ? '我的' : 'Profile';

  // Redesign: Focus Timer Screen
  String get focusingTitle => isChinese ? '专注中' : 'Focusing';
  String get onlyForeground =>
      isChinese ? '仅统计前台时间' : 'Only foreground time counted';
  String get focusTarget => isChinese ? '专注目标' : 'Focus Goal';
  String get edit => isChinese ? '编辑' : 'Edit';
  String get endEarlyFriendlyNotice => isChinese
      ? '提前结束也没关系\n我们会如实记录你的实际投入时间。'
      : 'Ending early is completely fine.\nWe will faithfully record your actual time.';
  String get endAndSaveBtn => isChinese ? '结束并保存' : 'End & Save';

  // Redesign: Insights Screen
  String get insightsSubtitle =>
      isChinese ? '基于你的真实记录生成' : 'Generated from your real study records';
  String get insightsRangeWeek => isChinese ? '周' : 'Week';
  String get insightsRangeMonth => isChinese ? '月' : 'Month';
  String get insightsRange3Months => isChinese ? '3月' : '3 Mos';
  String get insightsRangeAll => isChinese ? '全部' : 'All';
  String get focusDuration => isChinese ? '专注时长' : 'Focus Duration';
  String get hoursUnit => isChinese ? '小时' : 'hrs';
  String get comparedToLastMonth => isChinese ? '较上月' : 'vs last mo';
  String get bestFocusDurationTitle =>
      isChinese ? '最适合你的专注时长' : 'Best Focus Duration';
  String get bestFocusDurationSubtitle =>
      isChinese ? '专注效果最佳' : 'Optimal focus';
  String get bestTimeSlotTitle => isChinese ? '最佳专注时段' : 'Peak Focus Time';
  String get bestTimeSlotSubtitle =>
      isChinese ? '你的高效时段' : 'Your productive window';
  String get taskDistributionTitle => isChinese ? '任务类型分布' : 'Task Breakdown';
  String get insightsNeedMoreRecordsTitle =>
      isChinese ? '还需要一些学习记录' : 'Need more study records';
  String get insightsNeedMoreRecordsDesc => isChinese
      ? '完成几次学习后，这里会逐渐出现属于你的学习规律。'
      : 'Complete a few study sessions to reveal your learning patterns.';
}
