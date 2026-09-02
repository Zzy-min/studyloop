import '../models.dart';

class RestPolicy {
  const RestPolicy();

  bool isSevereDiscomfort(SessionDraft draft) => draft.isSevere;

  bool recommendsRestAfter(List<StudyRecord> chronological) {
    if (chronological.length < 2) return false;
    final previous = chronological[chronological.length - 2];
    final latest = chronological[chronological.length - 1];
    final repeatedLowFocus =
        previous.focus != null &&
        latest.focus != null &&
        previous.focus! <= 2 &&
        latest.focus! <= 2;
    final repeatedWorseMood =
        previous.moodChange != null &&
        latest.moodChange != null &&
        previous.moodChange == MoodChange.worse &&
        latest.moodChange == MoodChange.worse;
    return repeatedLowFocus || repeatedWorseMood;
  }

  String restCopy({String locale = 'en'}) => locale.startsWith('zh')
      ? '身体明显不适或连续两次低专注度是暂停的合理信号。'
            'StudyLoop 不做医学诊断。先好好休息，感觉合适时再回来。'
      : 'Clear physical discomfort or two hard sessions in a row are a reason to pause. '
            'StudyLoop is not making a diagnosis. Rest, then return only when it feels appropriate.';
}
