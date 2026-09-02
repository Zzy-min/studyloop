import '../../domain/insights_repository.dart';
import '../../domain/models.dart';
import '../database/app_database.dart';

class DriftInsightsRepository implements InsightsRepository {
  const DriftInsightsRepository({
    required AppDatabase database,
    required this.clock,
  }) : _db = database;

  final AppDatabase _db;
  final DateTime Function() clock;

  Duration? _span(InsightRange range) => switch (range) {
    InsightRange.week => const Duration(days: 7),
    InsightRange.month => const Duration(days: 30),
    InsightRange.threeMonths => const Duration(days: 90),
    InsightRange.all => null,
  };

  List<StudyRecord> _inRange(
    List<StudyRecord> records,
    InsightRange range,
    DateTime now, {
    DateTime? exclusiveEnd,
  }) {
    final span = _span(range);
    if (span == null) {
      if (exclusiveEnd == null) return records;
      return records
          .where((record) => record.startedAt.isBefore(exclusiveEnd))
          .toList();
    }
    final cutoff = now.subtract(span);
    return records.where((record) {
      final afterStart = !record.startedAt.isBefore(cutoff);
      final beforeEnd =
          exclusiveEnd == null || record.startedAt.isBefore(exclusiveEnd);
      return afterStart && beforeEnd;
    }).toList();
  }

  @override
  Future<FocusDurationInsight> getFocusDuration(
    InsightRange range, {
    required bool isChinese,
  }) async {
    final records = await _db.allRecords();
    final now = clock();
    final filtered = _inRange(records, range, now);
    final totalSeconds = filtered.fold<int>(
      0,
      (sum, record) => sum + record.actualSeconds,
    );
    final totalHours = double.parse((totalSeconds / 3600).toStringAsFixed(1));

    final previous = switch (range) {
      InsightRange.week => _inRange(
        records,
        InsightRange.week,
        now.subtract(const Duration(days: 7)),
        exclusiveEnd: now.subtract(const Duration(days: 7)),
      ),
      InsightRange.month => _inRange(
        records,
        InsightRange.month,
        now.subtract(const Duration(days: 30)),
        exclusiveEnd: now.subtract(const Duration(days: 30)),
      ),
      InsightRange.threeMonths => _inRange(
        records,
        InsightRange.threeMonths,
        now.subtract(const Duration(days: 90)),
        exclusiveEnd: now.subtract(const Duration(days: 90)),
      ),
      InsightRange.all => const <StudyRecord>[],
    };
    final previousSeconds = previous.fold<int>(
      0,
      (sum, record) => sum + record.actualSeconds,
    );
    double? changePercent;
    if (previous.isNotEmpty && previousSeconds > 0) {
      changePercent = double.parse(
        (((totalSeconds - previousSeconds) / previousSeconds) * 100)
            .toStringAsFixed(0),
      );
    }

    final byDay = <DateTime, int>{};
    for (final record in filtered) {
      final day = DateTime(
        record.startedAt.year,
        record.startedAt.month,
        record.startedAt.day,
      );
      byDay.update(
        day,
        (value) => value + record.actualSeconds,
        ifAbsent: () => record.actualSeconds,
      );
    }
    final days = byDay.keys.toList()..sort();
    final maxSeconds = byDay.values.fold<int>(
      0,
      (max, value) => value > max ? value : max,
    );
    final points = [
      for (final day in days)
        ChartPoint(
          date: day,
          dateLabel: '${day.month}/${day.day}',
          value: maxSeconds == 0 ? 0 : byDay[day]! / maxSeconds,
          isHighlight: byDay[day] == maxSeconds,
        ),
    ];

    return FocusDurationInsight(
      totalHours: totalHours,
      changePercent: changePercent,
      points: points,
    );
  }

  @override
  Future<BestDurationInsight?> getBestDuration({
    required bool isChinese,
  }) async {
    final records = await _db.allRecords();
    if (records.length < 3) return null;
    final focused = records
        .where((record) => record.focus != null && record.focus! >= 4)
        .toList();
    final source = focused.length >= 2 ? focused : records;
    final counts = <int, int>{};
    for (final record in source) {
      final minutes = (record.plannedSeconds / 60).round();
      counts.update(minutes, (value) => value + 1, ifAbsent: () => 1);
    }
    if (counts.isEmpty) return null;
    final best = counts.entries.toList()
      ..sort(
        (a, b) => b.value != a.value
            ? b.value.compareTo(a.value)
            : a.key.compareTo(b.key),
      );
    final minutes = best.first.key;
    return BestDurationInsight(
      durationLabel: isChinese ? '$minutes 分钟' : '$minutes min',
      description: isChinese
          ? '来自实际前台专注记录的众数计划时长'
          : 'Most common planned length in your records',
    );
  }

  @override
  Future<BestTimeInsight?> getBestTime({required bool isChinese}) async {
    final records = await _db.allRecords();
    if (records.length < 3) return null;
    final buckets = <int, List<StudyRecord>>{};
    for (final record in records) {
      final hour = record.startedAt.hour;
      final bucket = hour.isEven ? hour : hour - 1;
      buckets.putIfAbsent(bucket, () => []).add(record);
    }
    MapEntry<int, List<StudyRecord>>? best;
    for (final entry in buckets.entries) {
      if (best == null) {
        best = entry;
        continue;
      }
      final ratedCurrent = entry.value.where((r) => r.focus != null).toList();
      final currentAvg = ratedCurrent.isEmpty
          ? 3.0
          : ratedCurrent.fold<int>(0, (sum, record) => sum + record.focus!) /
                ratedCurrent.length;

      final ratedBest = best.value.where((r) => r.focus != null).toList();
      final bestAvg = ratedBest.isEmpty
          ? 3.0
          : ratedBest.fold<int>(0, (sum, record) => sum + record.focus!) /
                ratedBest.length;

      if (entry.value.length > best.value.length ||
          (entry.value.length == best.value.length && currentAvg > bestAvg)) {
        best = entry;
      }
    }
    if (best == null) return null;
    final startHour = best.key;
    final endHour = startHour + 2;
    final label = isChinese
        ? '${startHour.toString().padLeft(2, '0')}:00 - ${endHour.toString().padLeft(2, '0')}:00'
        : '${startHour.toString().padLeft(2, '0')}:00 - ${endHour.toString().padLeft(2, '0')}:00';
    return BestTimeInsight(
      timeWindowLabel: label,
      efficiencyBonus: 0,
      sampleCount: best.value.length,
    );
  }

  @override
  Future<TaskDistributionInsight> getTaskDistribution(
    InsightRange range, {
    required bool isChinese,
  }) async {
    final records = _inRange(await _db.allRecords(), range, clock());
    final examCount = records
        .where((record) => record.taskType == TaskType.examRevision)
        .length;
    final codeCount = records
        .where((record) => record.taskType == TaskType.programmingPractice)
        .length;
    final paperCount = records
        .where((record) => record.taskType == TaskType.paperWriting)
        .length;
    final otherCount = records.length - examCount - codeCount - paperCount;
    final total = records.length;

    double pct(int count) => total == 0 ? 0 : count / total;

    return TaskDistributionInsight(
      categories: [
        TaskCategoryDistribution(
          categoryName: isChinese ? '考试复习' : 'Exam Revision',
          percentage: pct(examCount),
          colorHex: 0xFF5FAF68,
        ),
        TaskCategoryDistribution(
          categoryName: isChinese ? '编程练习' : 'Programming',
          percentage: pct(codeCount),
          colorHex: 0xFF64B5F6,
        ),
        TaskCategoryDistribution(
          categoryName: isChinese ? '论文写作' : 'Paper Writing',
          percentage: pct(paperCount),
          colorHex: 0xFFFFB74D,
        ),
        TaskCategoryDistribution(
          categoryName: isChinese ? '其他' : 'Other',
          percentage: pct(otherCount < 0 ? 0 : otherCount),
          colorHex: 0xFFBA68C8,
        ),
      ],
    );
  }

  @override
  Future<InsightExplanation> getExplanation({required bool isChinese}) async {
    final records = await _db.allRecords();
    return InsightExplanation(
      title: isChinese ? '本地规律是如何计算的？' : 'How are these patterns calculated?',
      description: isChinese
          ? 'StudyLoop 只使用本机真实学习记录。样本不足 3 次时不会给出规律结论。'
          : 'StudyLoop uses only on-device study records. Patterns stay hidden until at least 3 sessions exist.',
      sampleSize: records.length,
      ruleDescription: isChinese
          ? '· 专注时长：选定范围内 actualSeconds 之和\n· 最佳时长：高专注记录的计划时长众数\n· 高效时段：开始时间最多的 2 小时窗口\n· 任务分布：各 TaskType 次数占比'
          : '· Focus duration: sum of actualSeconds in the selected range\n· Best duration: mode of planned length among higher-focus records\n· Peak window: 2-hour start-time bucket with the most sessions\n· Task mix: share of each task type',
    );
  }
}
