enum InsightRange { week, month, threeMonths, all }

class ChartPoint {
  const ChartPoint({
    required this.date,
    required this.dateLabel,
    required this.value,
    this.isHighlight = false,
  });

  final DateTime date;
  final String dateLabel;
  final double value;
  final bool isHighlight;
}

class FocusDurationInsight {
  const FocusDurationInsight({
    required this.totalHours,
    this.changePercent,
    required this.points,
  });

  final double totalHours;
  final double? changePercent;
  final List<ChartPoint> points;
}

class BestDurationInsight {
  const BestDurationInsight({
    required this.durationLabel,
    required this.description,
  });

  final String durationLabel;
  final String description;
}

class BestTimeInsight {
  const BestTimeInsight({
    required this.timeWindowLabel,
    required this.efficiencyBonus,
    required this.sampleCount,
  });

  final String timeWindowLabel;
  final double efficiencyBonus;
  final int sampleCount;
}

class TaskCategoryDistribution {
  const TaskCategoryDistribution({
    required this.categoryName,
    required this.percentage,
    required this.colorHex,
  });

  final String categoryName;
  final double percentage;
  final int colorHex;
}

class TaskDistributionInsight {
  const TaskDistributionInsight({required this.categories});

  final List<TaskCategoryDistribution> categories;
}

class InsightExplanation {
  const InsightExplanation({
    required this.title,
    required this.description,
    required this.sampleSize,
    required this.ruleDescription,
  });

  final String title;
  final String description;
  final int sampleSize;
  final String ruleDescription;
}

abstract interface class InsightsRepository {
  Future<FocusDurationInsight> getFocusDuration(
    InsightRange range, {
    required bool isChinese,
  });
  Future<BestDurationInsight?> getBestDuration({required bool isChinese});
  Future<BestTimeInsight?> getBestTime({required bool isChinese});
  Future<TaskDistributionInsight> getTaskDistribution(
    InsightRange range, {
    required bool isChinese,
  });
  Future<InsightExplanation> getExplanation({required bool isChinese});
}
