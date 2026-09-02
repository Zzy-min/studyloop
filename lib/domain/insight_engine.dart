import 'models.dart';
import 'policies/session_date_policy.dart';

class InsightEngine {
  const InsightEngine({this.datePolicy = const SessionDatePolicy()});

  final SessionDatePolicy datePolicy;

  Insight? freeInsight(
    List<StudyRecord> records,
    DateTime now, {
    String locale = 'en',
  }) {
    final recent = records
        .where((record) => datePolicy.isInRecentWindow(record, now))
        .toList();
    if (recent.length < 3) return null;
    final isZh = locale.startsWith('zh');
    return _strongestSingleDimension(recent, isZh) ??
        _durationFallback(recent, isZh);
  }

  List<Insight> proInsights(List<StudyRecord> records, {String locale = 'en'}) {
    if (records.length < 3) return const [];
    final isZh = locale.startsWith('zh');
    final completed = records
        .where((r) => r.outcome == SessionOutcome.completed)
        .length;
    final reflections = records.where((r) => r.moodChange != null).toList();
    final eased = reflections
        .where((r) => r.moodChange == MoodChange.moreAtEase)
        .length;
    final byType = <TaskType, int>{};
    final byBarrier = <StudyBarrier, int>{};
    for (final record in records) {
      byType.update(record.taskType, (value) => value + 1, ifAbsent: () => 1);
      byBarrier.update(record.barrier, (value) => value + 1, ifAbsent: () => 1);
    }
    final type = _top(byType);
    final barrier = _top(byBarrier);
    return [
      Insight(
        isZh
            ? '${records.length} 次专注会话中有 $completed 次顺利到达预定终点。'
            : '$completed of ${records.length} sessions reached the planned end.',
        records.length,
      ),
      if (reflections.isNotEmpty)
        Insight(
          isZh
              ? '${reflections.length} 次复盘中有 $eased 次在专注后感到更加轻松。'
              : '$eased of ${reflections.length} reflections felt more at ease afterward.',
          reflections.length,
        ),
      if (type != null)
        Insight(
          isZh
              ? '记录最多的任务类型是${_labelType(type.key, true)}（占 ${type.value} / ${records.length} 次）。'
              : 'Most recorded task type is ${_labelType(type.key, false)} (${type.value} of ${records.length}).',
          type.value,
        ),
      if (barrier != null)
        Insight(
          isZh
              ? '记录最多的起步障碍是「${_labelBarrier(barrier.key, true)}」（占 ${barrier.value} / ${records.length} 次）。'
              : 'Most recorded start barrier is ${_labelBarrier(barrier.key, false)} (${barrier.value} of ${records.length}).',
          barrier.value,
        ),
    ];
  }

  Insight? _strongestSingleDimension(List<StudyRecord> recent, bool isZh) {
    final durationGroups = <int, List<StudyRecord>>{};
    final barrierGroups = <StudyBarrier, List<StudyRecord>>{};
    for (final record in recent) {
      durationGroups.putIfAbsent(record.plannedSeconds, () => []).add(record);
      barrierGroups.putIfAbsent(record.barrier, () => []).add(record);
    }
    Insight? best;
    var bestScore = -1;
    for (final entry in durationGroups.entries) {
      if (entry.value.length < 2) continue;
      final completed = entry.value
          .where((r) => r.outcome == SessionOutcome.completed)
          .length;
      final eased = entry.value
          .where((r) => r.moodChange == MoodChange.moreAtEase)
          .length;
      final minutes = (entry.key / 60).round();
      final score = _score(completed, eased, entry.value.length);
      final candidate = Insight(
        isZh
            ? '在过去7天中，$minutes 分钟的专注计划在 ${entry.value.length} 次中有 $completed 次顺利完成。'
            : 'In the last 7 days, $minutes-minute plans reached the planned end in $completed of ${entry.value.length} sessions.',
        entry.value.length,
      );
      if (score > bestScore ||
          (score == bestScore && minutes < _minutesFrom(best))) {
        best = candidate;
        bestScore = score;
      }
    }
    for (final entry in barrierGroups.entries) {
      if (entry.value.length < 2) continue;
      final completed = entry.value
          .where((r) => r.outcome == SessionOutcome.completed)
          .length;
      final eased = entry.value
          .where((r) => r.moodChange == MoodChange.moreAtEase)
          .length;
      final score = _score(completed, eased, entry.value.length);
      final candidate = Insight(
        isZh
            ? '在过去7天中，以「${_labelBarrier(entry.key, true)}」起步的会话在 ${entry.value.length} 次中有 $completed 次顺利完成。'
            : 'In the last 7 days, sessions that started from ${_labelBarrier(entry.key, false)} reached the planned end in $completed of ${entry.value.length} sessions.',
        entry.value.length,
      );
      if (score > bestScore) {
        best = candidate;
        bestScore = score;
      }
    }
    return best;
  }

  Insight _durationFallback(List<StudyRecord> recent, bool isZh) {
    final minutes =
        (recent.fold<int>(0, (sum, record) => sum + record.actualSeconds) / 60)
            .round();
    return Insight(
      isZh
          ? '过去 7 天记录了 ${recent.length} 次真实专注，共 $minutes 分钟。'
          : 'You recorded ${recent.length} honest focus sessions in the last 7 days, totaling $minutes minutes.',
      recent.length,
    );
  }

  MapEntry<T, int>? _top<T>(Map<T, int> counts) {
    if (counts.isEmpty) return null;
    final entries = counts.entries.toList()
      ..sort(
        (a, b) => b.value != a.value
            ? b.value.compareTo(a.value)
            : a.key.toString().compareTo(b.key.toString()),
      );
    return entries.first;
  }

  int _score(int completed, int eased, int count) =>
      completed * 10 + eased * 3 + count;

  int _minutesFrom(Insight? insight) {
    if (insight == null) return 999;
    final match = RegExp(r'(\d+)(-minute|\s*分钟)').firstMatch(insight.text);
    return int.tryParse(match?.group(1) ?? '999') ?? 999;
  }

  String _labelType(TaskType type, bool isZh) => isZh
      ? switch (type) {
          TaskType.examRevision => '考试复习',
          TaskType.homework => '作业',
          TaskType.programmingPractice => '编程练习',
          TaskType.paperWriting => '论文写作',
          TaskType.reading => '阅读',
          TaskType.memorization => '背诵记忆',
          TaskType.preview => '课程预习',
          TaskType.project => '项目任务',
          TaskType.other => '其他',
        }
      : switch (type) {
          TaskType.examRevision => 'exam review',
          TaskType.homework => 'homework',
          TaskType.programmingPractice => 'coding',
          TaskType.paperWriting => 'writing',
          TaskType.reading => 'reading',
          TaskType.memorization => 'memorization',
          TaskType.preview => 'preview',
          TaskType.project => 'project',
          TaskType.other => 'other',
        };

  String _labelBarrier(StudyBarrier barrier, bool isZh) => isZh
      ? switch (barrier) {
          StudyBarrier.uncertainStart => '不知道从何开始',
          StudyBarrier.overload => '要做的事太多',
          StudyBarrier.phoneDistraction => '忍不住看手机',
          StudyBarrier.tiredness => '普通疲惫',
          StudyBarrier.perfectionism => '过度准备',
        }
      : switch (barrier) {
          StudyBarrier.uncertainStart => 'not knowing where to start',
          StudyBarrier.overload => 'feeling overloaded',
          StudyBarrier.phoneDistraction => 'phone distraction',
          StudyBarrier.tiredness => 'ordinary tiredness',
          StudyBarrier.perfectionism => 'over-preparing',
        };
}
