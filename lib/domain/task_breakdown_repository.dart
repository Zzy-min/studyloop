import 'models.dart';

class MinimumActionItem {
  const MinimumActionItem({
    required this.id,
    required this.title,
    required this.description,
    required this.estimatedMinutes,
    required this.difficultyLabel,
    required this.canStart,
  });

  final String id;
  final String title;
  final String description;
  final int estimatedMinutes;
  final String difficultyLabel;
  final bool canStart;
}

abstract interface class TaskBreakdownRepository {
  MinimumActionItem getSuggestedAction({
    required StudyBarrier? barrier,
    required String taskText,
    required TaskType? taskType,
    required StartCard? card,
    required int plannedSeconds,
    required bool isChinese,
  });
}

class DeterministicTaskBreakdownRepository implements TaskBreakdownRepository {
  const DeterministicTaskBreakdownRepository();

  @override
  MinimumActionItem getSuggestedAction({
    required StudyBarrier? barrier,
    required String taskText,
    required TaskType? taskType,
    required StartCard? card,
    required int plannedSeconds,
    required bool isChinese,
  }) {
    final hasTask = taskText.trim().isNotEmpty;
    final title = hasTask
        ? taskText.trim()
        : (isChinese ? '先写下今天要推进的一件事' : 'Name one thing to move forward');
    final description = !hasTask
        ? (isChinese
              ? '写下一个课程、作业或项目名称后，再生成可立即开始的最小行动。'
              : 'Add a course, assignment, or project name to generate a tiny starting action.')
        : (card?.action ??
              (isChinese
                  ? '打开任务，写下第一个可观察的小步骤。'
                  : 'Open the task and write the first observable step.'));

    final estimatedMinutes = (plannedSeconds / 60).round();
    final difficultyLabel = isChinese ? '中等' : 'Medium';

    return MinimumActionItem(
      id: 'suggested_${barrier?.name ?? "default"}',
      title: title,
      description: description,
      estimatedMinutes: estimatedMinutes > 0 ? estimatedMinutes : 15,
      difficultyLabel: difficultyLabel,
      canStart: barrier != null && hasTask,
    );
  }
}
