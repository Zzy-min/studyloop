import 'models.dart';

class CorgiChatMessage {
  const CorgiChatMessage({
    required this.id,
    required this.isUser,
    required this.text,
    required this.timestamp,
    this.suggestedAction,
    this.actionType,
    this.templateId,
  });

  final String id;
  final bool isUser;
  final String text;
  final DateTime timestamp;
  final String? suggestedAction;
  final String? actionType;
  final String? templateId;
}

class CompanionContext {
  const CompanionContext({
    this.currentBarrier,
    this.taskType,
    this.currentTaskTitle,
    this.companionState = DogState.waiting,
    this.currentSessionDuration,
    this.lastSessionDuration,
    this.lastDifficulty,
    this.lastFocus,
    this.lastMood,
    this.recentSessionCount = 0,
    this.lastEndedEarly = false,
  });

  final StudyBarrier? currentBarrier;
  final TaskType? taskType;
  final String? currentTaskTitle;
  final DogState companionState;
  final Duration? currentSessionDuration;
  final Duration? lastSessionDuration;
  final int? lastDifficulty;
  final int? lastFocus;
  final MoodChange? lastMood;
  final int recentSessionCount;
  final bool lastEndedEarly;
}

enum CompanionIntent {
  pet,
  phone,
  lowEnergy,
  resistance,
  noStartingPoint,
  overwhelmed,
  breakdown,
  encourage,
  coding,
  writing,
  exam,
  completed,
  safety,
  unknown,
}

class CompanionReply {
  const CompanionReply({
    required this.templateId,
    required this.text,
    this.suggestedAction,
    this.actionType,
  });

  final String templateId;
  final String text;
  final String? suggestedAction;
  final String? actionType;
}

class RecentReplyCache {
  RecentReplyCache({this.limit = 5});
  final int limit;
  final List<String> _ids = [];

  List<String> get ids => List.unmodifiable(_ids);

  void remember(String id) {
    _ids.add(id);
    if (_ids.length > limit) {
      _ids.removeAt(0);
    }
  }

  bool recentlyUsed(String id) => _ids.contains(id);
}

class CompanionResponseEngine {
  const CompanionResponseEngine();

  static final _safetyPatterns = [
    '自杀',
    '不想活',
    '结束生命',
    '伤害自己',
    '割腕',
    '跳楼',
    'kill myself',
    'suicide',
    'self-harm',
    'hurt myself',
    'end my life',
  ];

  CompanionIntent classify(String userText) {
    final query = userText.trim().toLowerCase();
    if (_safetyPatterns.any(query.contains)) return CompanionIntent.safety;
    if (_hasAny(query, ['摸', '抱', '可爱', '乖', 'pet', 'corgi', 'cute', 'hug'])) {
      return CompanionIntent.pet;
    }
    if (_hasAny(query, [
      '手机',
      '短视频',
      '刷',
      '分心',
      'phone',
      'distract',
      'scroll',
      'social',
    ])) {
      return CompanionIntent.phone;
    }
    if (_hasAny(query, [
      '累',
      '困',
      '痛',
      '难受',
      'tired',
      'exhaust',
      'sleep',
      'headache',
    ])) {
      return CompanionIntent.lowEnergy;
    }
    if (_hasAny(query, ['不想学', '放弃', 'quit', 'give up', 'don\'t want'])) {
      return CompanionIntent.resistance;
    }
    if (_hasAny(query, ['完成了', '做完了', 'done', 'finished', 'completed'])) {
      return CompanionIntent.completed;
    }
    if (_hasAny(query, [
      '拆',
      '更小',
      '简单',
      '步骤',
      '卡片',
      'smaller',
      'break',
      'step',
      'action',
    ])) {
      return CompanionIntent.breakdown;
    }
    if (_hasAny(query, ['太多', '好多', 'overload', 'overwhelm', 'too many'])) {
      return CompanionIntent.overwhelmed;
    }
    if (_hasAny(query, [
      '不知道',
      '从哪',
      '无从',
      '迷茫',
      '不会开始',
      "don't know",
      'where to start',
      'stuck',
    ])) {
      return CompanionIntent.noStartingPoint;
    }
    if (_hasAny(query, ['打气', '鼓励', '加油', '夸', 'boost', 'encourage'])) {
      return CompanionIntent.encourage;
    }
    if (_hasAny(query, [
      '代码',
      '编程',
      'bug',
      '开发',
      'code',
      'coding',
      'program',
    ])) {
      return CompanionIntent.coding;
    }
    if (_hasAny(query, ['论文', '写作', '文献', 'paper', 'writing', 'essay'])) {
      return CompanionIntent.writing;
    }
    if (_hasAny(query, ['数学', '复习', '背', '考试', 'exam', 'revise', 'memor'])) {
      return CompanionIntent.exam;
    }
    if (_hasAny(query, [
      '难',
      '不会',
      '怕',
      '焦虑',
      'hard',
      'difficult',
      'scared',
      'anxious',
    ])) {
      return CompanionIntent.noStartingPoint;
    }
    return CompanionIntent.unknown;
  }

  bool isSafety(String userText) =>
      classify(userText) == CompanionIntent.safety;

  CompanionReply reply({
    required String userText,
    required String locale,
    required CompanionContext context,
    required RecentReplyCache cache,
  }) {
    final isZh = locale.startsWith('zh');
    final intent = classify(userText);
    final candidates = _candidates(intent, isZh, context, userText);
    final chosen = candidates.firstWhere(
      (reply) => !cache.recentlyUsed(reply.templateId),
      orElse: () => candidates.first,
    );
    cache.remember(chosen.templateId);
    return chosen;
  }

  List<CompanionReply> _candidates(
    CompanionIntent intent,
    bool isZh,
    CompanionContext context,
    String userText,
  ) {
    if (intent == CompanionIntent.safety) {
      return [
        CompanionReply(
          templateId: 'safety-1',
          text: isZh
              ? '现在更重要的是先照顾好自己。可以先停止学习并找一个你信任的人陪你。如果情况紧急，请联系当地紧急援助。'
              : 'The most important thing now is to take care of yourself. Pause studying and stay with someone you trust. If it is urgent, contact local emergency help.',
        ),
      ];
    }

    if (context.companionState == DogState.focusing &&
        intent != CompanionIntent.pet &&
        intent != CompanionIntent.lowEnergy) {
      return [
        CompanionReply(
          templateId: 'focus-1',
          text: isZh
              ? '我在这儿，你继续做这一小步就好。'
              : 'I am here. Keep going with this small step.',
        ),
        CompanionReply(
          templateId: 'focus-2',
          text: isZh
              ? '先把眼前这一步做完，聊天可以等一会儿。'
              : 'Finish this tiny step first. Chat can wait.',
        ),
        CompanionReply(
          templateId: 'focus-3',
          text: isZh
              ? '我安静待着。你继续就好。'
              : 'I will stay quiet. You can keep going.',
        ),
      ];
    }

    final task = (context.currentTaskTitle?.trim().isNotEmpty ?? false)
        ? context.currentTaskTitle!.trim()
        : (isZh ? '学习任务' : 'Study task');

    switch (intent) {
      case CompanionIntent.pet:
        return [
          CompanionReply(
            templateId: 'pet-1',
            text: isZh
                ? '（柯基开心地摇起毛茸茸的小短尾巴，用暖呼呼的脑袋蹭了蹭你的手心）汪呜~ 接收到了你的抚摸！柯基充满能量了，现在把这份温暖也传递给你！不管今天学多学少，你已经做得很棒了！'
                : '(The Corgi wags its fluffy tail happily and snuggles its warm snout into your hand) Woof woof! Corgi feels energized and sends all the cozy warmth right back to you! You are doing great today!',
          ),
          CompanionReply(
            templateId: 'pet-2',
            text: isZh
                ? '汪呜，摸摸收到了。我们还是轻轻地开始就好，不用一下子做完所有事。'
                : 'Woof, pets received. We can start gently. Nothing has to be finished all at once.',
          ),
        ];
      case CompanionIntent.phone:
        return [
          CompanionReply(
            templateId: 'phone-1',
            text: isZh
                ? '手机的设计就是为了吸引人类注意力的，分心并不是你的自制力差！我们顺应人性：不需要逼自己学很久，把手机扣在桌子另一角，我们只开一个 5 分钟的微型专注，完成后想玩再玩，好不好？'
                : 'Phones are engineered to be addictive—getting distracted does not mean you lack willpower! Let’s place the phone face down 1 meter away, and just do a 5-minute tiny interval together!',
            suggestedAction: isZh
                ? '扣上手机，完成 5 分钟微型专注'
                : 'Place phone away and start a 5-minute mini focus',
            actionType: 'set_task',
          ),
          CompanionReply(
            templateId: 'phone-2',
            text: isZh
                ? '可以先给自己一个很短的无干扰区间，比如只做 10 分钟。手机先放到够不到的地方就好。'
                : 'Give yourself a short undisturbed window, even 10 minutes. Put the phone out of reach first.',
            suggestedAction: isZh
                ? '手机放到够不到的地方，只开始 10 分钟'
                : 'Put the phone out of reach and start 10 minutes',
            actionType: 'set_task',
          ),
        ];
      case CompanionIntent.lowEnergy:
      case CompanionIntent.resistance:
        return [
          CompanionReply(
            templateId: 'energy-1',
            text: isZh
                ? '柯基听到了你的疲惫。大脑在发出超载信号时，硬撑往往效率极低。如果身体很不适，请理直气壮地去休息片刻；如果只想完成最底线的推进，我们做个只要 2 分钟的极简浏览即可。'
                : 'Corgi feels your fatigue. When your brain is overloaded, forcing it rarely works. If unwell, rest guilt-free; if just sluggish, let’s do a very gentle 2-minute skim.',
            suggestedAction: isZh
                ? '闭眼休息 5 分钟，或仅浏览 1 页目录'
                : 'Rest with eyes closed for 5 minutes, or skim 1 page',
            actionType: 'rest',
          ),
          CompanionReply(
            templateId: 'energy-2',
            text: isZh
                ? '今天可以做得小一点。如果真的很累，休息也是合理的选择。'
                : 'Today can stay small. If you are truly tired, rest is a valid choice.',
            suggestedAction: isZh
                ? '先休息 5 分钟，再决定要不要开始'
                : 'Rest for 5 minutes, then decide whether to start',
            actionType: 'rest',
          ),
        ];
      case CompanionIntent.overwhelmed:
        return [
          CompanionReply(
            templateId: 'overload-1',
            text: isZh
                ? '先不管其他任务，我们只选现在最值得开始的一个。'
                : 'Leave the other tasks aside. Pick only the one worth starting now.',
            suggestedAction: isZh
                ? '只写下当前最值得开始的一个任务名'
                : 'Write only the one task worth starting now',
            actionType: 'set_task',
          ),
          CompanionReply(
            templateId: 'overload-2',
            text: isZh
                ? '事情多的时候，列表本身就会让人停住。先圈出一件，其他先放在旁边。'
                : 'A long list can freeze you. Circle one item and leave the rest beside it.',
            suggestedAction: isZh
                ? '从清单里圈出 1 件事'
                : 'Circle one item from the list',
            actionType: 'set_task',
          ),
        ];
      case CompanionIntent.noStartingPoint:
        return [
          CompanionReply(
            templateId: 'start-1',
            text: isZh
                ? '我们先别想整章内容，挑一个能在几分钟里完成的小动作就好。'
                : 'Do not think about the whole chapter. Pick one action that can finish in a few minutes.',
            suggestedAction: isZh
                ? '只打开资料，读第一段'
                : 'Open the material and read the first paragraph',
            actionType: 'set_task',
          ),
          CompanionReply(
            templateId: 'start-2',
            text: isZh
                ? '感到困难是因为你在挑战新的知识边界，这恰恰是大脑在生长的证明！不要试图一次性攻克全部。先把大怪兽切成小土豆：只做 1 道最简单的基础题，或者只读懂 1 个定义。柯基陪你一起看！'
                : 'Difficulty means you are expanding your knowledge frontier! Don’t try to conquer the whole mountain. Let’s understand just one definition or one single equation. Corgi is right beside you!',
            suggestedAction: isZh
                ? '只读懂 1 个核心概念定义并用自己的话说出来'
                : 'Understand just 1 key definition',
            actionType: 'set_task',
          ),
        ];
      case CompanionIntent.breakdown:
        return [
          CompanionReply(
            templateId: 'break-1',
            text: isZh
                ? '收到！柯基帮你把【$task】拆到没有任何启动阻力：\n第一步：只在草稿纸上写下 1 个核心词或打开对应文件；\n第二步：不看任何复杂部分，只浏览第一小节。\n迈出这一步，阻力就会消失大半！'
                : 'Got it! Corgi breaks down [$task] to zero friction:\nStep 1: Open the document or draft paper.\nStep 2: Read just the very first sentence.\nOnce started, the friction vanishes!',
            suggestedAction: isZh
                ? '打开【$task】相关文件，只读第一小节'
                : 'Open [$task] and read just the first sentence',
            actionType: 'set_task',
          ),
        ];
      case CompanionIntent.encourage:
        return [
          CompanionReply(
            templateId: 'boost-1',
            text: isZh
                ? '汪汪！柯基给你摇旗呐喊！你现在愿意打开 StudyLoop、思考怎么开始，这本身就已经打败了 90% 的拖延时刻！相信微小的力量，今天你一定能迈出坚实的一步！冲呀！🐾'
                : 'Woof! Opening StudyLoop and thinking about a start already counts. Keep the next step tiny.',
          ),
          CompanionReply(
            templateId: 'boost-2',
            text: isZh
                ? context.recentSessionCount >= 3
                      ? '你最近已经开始过几次了。继续用短时间启动就很好。'
                      : '愿意开始，就已经足够被看见。下一步越小越好。'
                : context.recentSessionCount >= 3
                ? 'You have started a few times recently. Short starts can keep working.'
                : 'Wanting to start already counts. Keep the next step small.',
          ),
        ];
      case CompanionIntent.coding:
        return [
          CompanionReply(
            templateId: 'code-1',
            text: isZh
                ? '写代码最怕面对庞大的工程。柯基建议的起步动作：只在控制台打印一条 Hello World，或者只写一个极小的单元测试断言。只要代码跑起来一次，思路就会打开！'
                : 'Huge projects freeze people. Open the file and make one tiny testable change.',
            suggestedAction: isZh
                ? '打开代码编辑器，写一个打印语句或最小测试'
                : 'Open the editor and write one tiny test',
            actionType: 'set_task',
          ),
        ];
      case CompanionIntent.writing:
        return [
          CompanionReply(
            templateId: 'write-1',
            text: isZh
                ? '写论文面对白纸最折磨人了！记住：不要一上来就写正文。先随便列 3 个甚至都不通顺的要点词，把大脑里的想法倒在纸上即可！'
                : 'Do not start with a perfect paragraph. Dump three rough bullets first.',
            suggestedAction: isZh
                ? '在文档里敲下 3 个相关的要点词草稿'
                : 'Write 3 rough bullets',
            actionType: 'set_task',
          ),
        ];
      case CompanionIntent.exam:
        return [
          CompanionReply(
            templateId: 'exam-1',
            text: isZh
                ? '复习迎考，最有效的是先找手感。不要从最难的大题开始，先翻看前天做对的 1 道例题，唤醒记忆与信心！'
                : 'Start with one familiar example, not the hardest problem.',
            suggestedAction: isZh
                ? '翻看并抄写 1 道典型例题的解题第一步'
                : 'Copy the first step of one familiar problem',
            actionType: 'set_task',
          ),
        ];
      case CompanionIntent.completed:
        final minutes = context.lastSessionDuration?.inMinutes;
        final early = context.lastEndedEarly;
        return [
          CompanionReply(
            templateId: 'done-1',
            text: isZh
                ? (early && minutes != null
                      ? '你实际做了 $minutes 分钟，这 $minutes 分钟会被好好记下来。'
                      : '这段投入会被好好记下来。不必要求自己一次做完。')
                : (early && minutes != null
                      ? 'You actually did $minutes minutes, and those $minutes minutes will be saved.'
                      : 'This focused time will be saved. It does not have to be a full session.'),
          ),
        ];
      case CompanionIntent.unknown:
      case CompanionIntent.safety:
        final fallback = isZh
            ? '我可能没完全理解。你可以告诉我，是不知道从哪里开始、任务太多，还是今天有点累？'
            : 'I may not have understood fully. Is it hard to start, too many tasks, or are you tired today?';
        return [
          CompanionReply(
            templateId: 'unknown-1',
            text: isZh
                ? '汪！柯基听到了你的心声：“$userText”。学习的过程中有起伏情绪非常正常，你并不孤单。试试深吸一口气，把肩膀放松下来，我们先做一件花不到 2 分钟的小事，好吗？'
                : 'Woof! Corgi heard you: "$userText". Ups and downs in studying are completely natural. Take a deep breath, relax your shoulders, and let’s take one tiny 2-minute step together!',
            suggestedAction: isZh
                ? '深呼吸放松肩膀，只看手头资料 2 分钟'
                : 'Relax shoulders and review 1 diagram for 2 minutes',
            actionType: 'set_task',
          ),
          CompanionReply(templateId: 'unknown-2', text: fallback),
        ];
    }
  }

  bool _hasAny(String query, List<String> keys) =>
      keys.any((key) => query.contains(key));
}

class CorgiChatEngine {
  const CorgiChatEngine();

  static final RecentReplyCache _sharedCache = RecentReplyCache();
  static const CompanionResponseEngine _engine = CompanionResponseEngine();

  List<CorgiChatMessage> getInitialGreeting({
    required String locale,
    StudyBarrier? barrier,
    String? taskText,
    CompanionContext? context,
  }) {
    final isZh = locale.startsWith('zh');
    final now = DateTime.now();
    final resolvedBarrier = context?.currentBarrier ?? barrier;
    String greetingText;
    String? suggestedAction;

    if (isZh) {
      greetingText = switch (resolvedBarrier) {
        StudyBarrier.overload =>
          '汪！要做的事情太多感到不知所措了吗？别担心，柯基陪着你。宏大的计划容易让人瘫痪，我们只要挑出最最微小的一个动作，比如“打开工程”或“列一个关键词”，迈出第一步就成功了大半！',
        StudyBarrier.uncertainStart =>
          '汪呜~ 不知道从哪里下手是完全正常的！哪怕是大科学家也会遇到这种时刻。告诉我你今天想做哪个科目或项目？柯基帮你拆解成一口就能吞下的小行动！',
        StudyBarrier.phoneDistraction =>
          '手机里好玩的东西太多了对不对？柯基悄悄告诉你一个秘诀：把手机屏幕朝下放到一米外，先和柯基专注 5 分钟，不用管之后的事，就这 5 分钟！',
        StudyBarrier.tiredness =>
          '感觉身体沉沉的、脑子转不动吗？柯基的毛茸茸肚皮借你靠一靠。如果真的很不舒服，一定要去休息；如果只是轻微提不起劲，我们做 5 分钟最简单的阅读好不好？',
        StudyBarrier.perfectionism =>
          '汪！你是不是想准备得十全十美再开始？其实粗糙的开始远胜过完美的拖延。今天允许自己做出一份“草稿级别的烂作业”，只要启动就算赢！',
        null => '汪！我是你的学习陪伴柯基。感到学不进去、压力大或者拖延时，随时可以和我说说。柯基永远在你身边，绝不评判你，我们一步一步来！',
      };
      suggestedAction = switch (resolvedBarrier) {
        StudyBarrier.overload => '打开当前资料或工程，只看前 3 行',
        StudyBarrier.uncertainStart => '只准备好草稿纸和笔，写下题目标题',
        StudyBarrier.phoneDistraction => '手机扣放在一米外，只看一眼要学的内容',
        StudyBarrier.tiredness => '深呼吸 3 次，只读 1 个段落',
        StudyBarrier.perfectionism => '先快速写出 3 句粗糙的想法草稿',
        null => null,
      };
    } else {
      greetingText = switch (resolvedBarrier) {
        StudyBarrier.overload =>
          'Woof! Overwhelmed by too many tasks? Corgi is right here with you. Big plans paralyze us—let’s just pick one tiny micro-step, like opening the file, and momentum will follow!',
        StudyBarrier.uncertainStart =>
          'Woof~ It’s completely normal not knowing where to start. Tell me what subject you are facing, and Corgi will help you break it into an effortless micro-action!',
        StudyBarrier.phoneDistraction =>
          'The phone keeps calling for attention? Try this Corgi trick: place the phone screen-down 1 meter away, and let’s focus together for just 5 minutes!',
        StudyBarrier.tiredness =>
          'Feeling drained? Lean on Corgi’s soft fur. If you have a headache, definitely take a real rest; if just low on energy, let’s do a very gentle 5-minute warm-up.',
        StudyBarrier.perfectionism =>
          'Woof! Aiming for perfection often causes paralysis. A messy start is ten times better than perfect procrastination. Give yourself permission to make a rough first draft!',
        null =>
          'Woof! I am your study companion Corgi. Whenever you feel stuck or stressed, chat with me anytime. I am always by your side without any judgment!',
      };
      suggestedAction = switch (resolvedBarrier) {
        StudyBarrier.overload =>
          'Open the project and read just the first 3 lines',
        StudyBarrier.uncertainStart =>
          'Write down just the title or first question on scrap paper',
        StudyBarrier.phoneDistraction =>
          'Place phone away and look at 1 diagram',
        StudyBarrier.tiredness => 'Take 3 deep breaths and skim 1 paragraph',
        StudyBarrier.perfectionism => 'Draft 3 quick unpolished bullet points',
        null => null,
      };
    }

    return [
      CorgiChatMessage(
        id: 'initial-greeting',
        isUser: false,
        text: greetingText,
        timestamp: now,
        suggestedAction: suggestedAction,
        actionType: suggestedAction != null ? 'set_task' : null,
        templateId: 'greeting-${resolvedBarrier?.name ?? 'none'}',
      ),
    ];
  }

  List<String> getPresetPrompts(String locale) {
    final isZh = locale.startsWith('zh');
    if (isZh) {
      return [
        '🐾 摸摸柯基小狗',
        '🎯 帮我把任务拆更小',
        '📱 总是忍不住想玩手机',
        '☕ 学得很累，想先停一下',
        '💭 觉得好难，不知道怎么开始',
        '✨ 给我一句打气的话',
      ];
    }
    return [
      '🐾 Pet the Corgi',
      '🎯 Make task even smaller',
      '📱 Can’t stop checking phone',
      '☕ Feeling exhausted / want to quit',
      '💭 Too hard, don’t know where to start',
      '✨ Give me a boost of courage',
    ];
  }

  CorgiChatMessage respond({
    required String userText,
    required String locale,
    StudyBarrier? barrier,
    String? currentTask,
    CompanionContext? context,
  }) {
    final now = DateTime.now();
    final resolved =
        context ??
        CompanionContext(
          currentBarrier: barrier,
          currentTaskTitle: currentTask,
        );
    final reply = _engine.reply(
      userText: userText,
      locale: locale,
      context: resolved,
      cache: _sharedCache,
    );
    return CorgiChatMessage(
      id: 'corgi-reply-${now.millisecondsSinceEpoch}',
      isUser: false,
      text: reply.text,
      timestamp: now,
      suggestedAction: reply.suggestedAction,
      actionType: reply.actionType,
      templateId: reply.templateId,
    );
  }
}
