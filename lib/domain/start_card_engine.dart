import 'models.dart';

class StartCardEngine {
  const StartCardEngine();

  StartCard generate(SessionDraft draft, {String locale = 'en'}) {
    if (!draft.isValid) {
      throw ArgumentError('A valid ordinary-study draft is required.');
    }
    final level = draft.reductionLevel.clamp(0, 3);
    final isZh = locale.startsWith('zh');
    final actions = isZh ? _actionsZh(draft) : _actionsEn(draft);
    final rationale = isZh
        ? (level == 3 ? '这个最小的行动对今天已经足够了。' : '一个可观察的小行动，比一个宏大的计划更容易开始。')
        : (level == 3
              ? 'This is a useful action on its own. It is enough for today.'
              : 'One observable step is easier to begin than a complete plan.');
    return StartCard(
      action: _adaptToBarrier(actions[level], draft.barrier!, isZh),
      rationale: rationale,
    );
  }

  String _adaptToBarrier(String action, StudyBarrier barrier, bool isZh) {
    if (isZh) {
      return switch (barrier) {
        StudyBarrier.uncertainStart => '把这一步当作唯一的下一步：$action',
        StudyBarrier.overload => '先忽略其他任务，只做这一件事：$action',
        StudyBarrier.phoneDistraction => '先把手机放到够不到的地方，然后：$action',
        StudyBarrier.tiredness => '用低精力版本开始：$action',
        StudyBarrier.perfectionism => '停止继续准备，直接产出一个不完美版本：$action',
      };
    }
    return switch (barrier) {
      StudyBarrier.uncertainStart => 'Use this as your only next step: $action',
      StudyBarrier.overload => 'Ignore the other tasks for now. $action',
      StudyBarrier.phoneDistraction =>
        'Put your phone out of reach, then: $action',
      StudyBarrier.tiredness => 'Use the low-energy version: $action',
      StudyBarrier.perfectionism =>
        'Stop preparing and make one imperfect version: $action',
    };
  }

  List<String> _generic(String a0, String a1, String a2, String a3) => [
    a0,
    a1,
    a2,
    a3,
  ];

  List<String> _actionsEn(SessionDraft draft) {
    final task = draft.taskText.trim();
    switch (draft.taskType!) {
      case TaskType.examRevision:
        switch (draft.examSubtype!) {
          case ExamSubtype.memory:
            return [
              'Choose one small part of $task and recall it without notes.',
              'Name one concept from $task from memory.',
              'Open $task and point to one concept.',
              'Open the material and write one concept name.',
            ];
          case ExamSubtype.calculation:
            return [
              'Choose one representative problem in $task and solve its first step.',
              'Copy one problem and identify the first operation.',
              'Write only the known values from one problem.',
              'Copy the known values and one likely formula.',
            ];
          case ExamSubtype.understanding:
            return [
              'Explain one concept in $task in two sentences.',
              'Write one sentence about one concept.',
              'Name the link that feels unclear.',
              'Write one question about what you do not understand.',
            ];
        }
      case TaskType.homework:
        return _generic(
          'Open $task and complete the first unfinished item.',
          'Write the title of the next unfinished item in $task.',
          'Open $task and mark the first unfinished line.',
          'Write one sentence describing the next homework item.',
        );
      case TaskType.programmingPractice:
        return [
          'Open $task and make one testable change.',
          'Define one tiny input and expected output.',
          'Open the relevant file and write one expected behavior.',
          'Open the project and write one input-output example.',
        ];
      case TaskType.paperWriting:
        return [
          'Write one rough paragraph for $task.',
          'Write one rough sentence and add a source placeholder.',
          'Write one imperfect bullet about the main point.',
          'Write one imperfect sentence describing the point.',
        ];
      case TaskType.reading:
        return _generic(
          'Read 2-3 pages of $task and mark one core idea.',
          'Read one page of $task and underline one sentence.',
          'Open $task and read the first paragraph.',
          'Open $task and write one word from the first heading.',
        );
      case TaskType.memorization:
        return _generic(
          'Recall one item from $task without looking, then check it.',
          'Write one prompt from $task from memory.',
          'Open $task and cover one item, then try to recall it.',
          'Write one term from $task on scrap paper.',
        );
      case TaskType.preview:
        return _generic(
          'Skim the headings of $task and write one question.',
          'Open $task and list three section titles.',
          'Open $task and read only the first heading.',
          'Write one question you hope $task will answer.',
        );
      case TaskType.project:
        return _generic(
          'Define the next visible deliverable for $task and start it.',
          'Write the next project step for $task in one sentence.',
          'Open the $task workspace and name the next file to touch.',
          'Write one next action for $task on scrap paper.',
        );
      case TaskType.other:
        return _generic(
          'Do the first observable step of $task.',
          'Write the next tiny action for $task.',
          'Open $task and point to the first thing to do.',
          'Write one starting word for $task.',
        );
    }
  }

  List<String> _actionsZh(SessionDraft draft) {
    final task = draft.taskText.trim();
    switch (draft.taskType!) {
      case TaskType.examRevision:
        switch (draft.examSubtype!) {
          case ExamSubtype.memory:
            return [
              '选择 $task 的一小部分内容，不看笔记回忆关键概念。',
              '凭记忆说出 $task 中的一个核心概念名称。',
              '打开 $task 资料，用手指出其中的一个概念。',
              '打开资料，在纸上写下一个概念的名称。',
            ];
          case ExamSubtype.calculation:
            return [
              '选择 $task 中一道代表性习题，完成第一步推导。',
              '抄下这道题，并找出解题的第一步运算。',
              '只在草稿纸上写下这道题目的已知条件数值。',
              '抄下已知数值和一个最可能用到的公式。',
            ];
          case ExamSubtype.understanding:
            return [
              '用两句话向自己解释 $task 中的一个概念。',
              '写下一句话描述这个概念的核心含义。',
              '指出当前让你感到最模糊的一个连接点。',
              '写下一个关于你未理解内容的小问题。',
            ];
        }
      case TaskType.homework:
        return _generic(
          '打开 $task，完成第一个未完成的小题。',
          '写下 $task 中下一个未完成项的标题。',
          '打开 $task，标出第一行未完成内容。',
          '用一句话写下作业的下一个小步骤。',
        );
      case TaskType.programmingPractice:
        return [
          '打开 $task 代码工程，完成一次可测试的小改动。',
          '定义一个极小的输入示例与期望的输出结果。',
          '打开相关代码文件，写下一行注释描述期望行为。',
          '打开工程，写下一组输入与输出示例。',
        ];
      case TaskType.paperWriting:
        return [
          '为 $task 撰写一个草稿段落，不必追求完美。',
          '写下一句粗略的话，并留出一个引用文献占位符。',
          '用一条不完美的要点列出核心观点。',
          '写下一句不完美的话来描述这个要点。',
        ];
      case TaskType.reading:
        return _generic(
          '阅读 $task 指定的 2–3 页，并标出一个核心概念。',
          '阅读 $task 的一页，并划出一句关键句。',
          '打开 $task，只读第一段。',
          '打开 $task，从第一个标题里写下 1 个词。',
        );
      case TaskType.memorization:
        return _generic(
          '不看资料回忆 $task 中的 1 项，再核对。',
          '凭记忆写下 $task 中的 1 个提示词。',
          '打开 $task，遮住一项后试着回忆。',
          '在纸上写下 $task 中的 1 个术语。',
        );
      case TaskType.preview:
        return _generic(
          '浏览 $task 的标题，写下 1 个问题。',
          '打开 $task，列出 3 个小节标题。',
          '打开 $task，只看第一个标题。',
          '写下你希望 $task 能回答的 1 个问题。',
        );
      case TaskType.project:
        return _generic(
          '为 $task 确定下一个可见交付物并开始它。',
          '用一句话写下 $task 的下一步。',
          '打开 $task 工作区，指出下一个要动的文件。',
          '在纸上写下 $task 的一个下一步。',
        );
      case TaskType.other:
        return _generic(
          '完成 $task 的第一个可观察小步骤。',
          '写下 $task 的下一个极小动作。',
          '打开 $task，指出第一件要做的事。',
          '为 $task 写下 1 个起步词。',
        );
    }
  }
}
