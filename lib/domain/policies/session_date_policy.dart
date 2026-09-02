import '../models.dart';

class SessionDatePolicy {
  const SessionDatePolicy();

  DateTime startDate(DateTime startedAt) =>
      DateTime(startedAt.year, startedAt.month, startedAt.day);

  DateTime recentWindowStart(DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    return today.subtract(const Duration(days: 6));
  }

  bool isInRecentWindow(StudyRecord record, DateTime now) =>
      !record.startDate.isBefore(recentWindowStart(now));
}
