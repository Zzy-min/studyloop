import 'models.dart';

enum CompanionSurface {
  home,
  taskBreakdown,
  focus,
  reflection,
  insights,
}

enum AICompanionIntent {
  support,
  proposeAction,
  explainInsight,
  clarifyBarrier,
}

enum AIRequestStatus {
  idle,
  sending,
  success,
  failed,
  fallback,
}

class RecentLearningSummary {
  const RecentLearningSummary({
    required this.sessionCount7Days,
    required this.completedCount7Days,
    required this.avgActualMinutes,
    this.primaryTaskType,
    this.primaryBarrier,
  });

  final int sessionCount7Days;
  final int completedCount7Days;
  final int avgActualMinutes;
  final TaskType? primaryTaskType;
  final StudyBarrier? primaryBarrier;

  Map<String, dynamic> toJson() => {
    'sessionCount7Days': sessionCount7Days,
    'completedCount7Days': completedCount7Days,
    'avgActualMinutes': avgActualMinutes,
    if (primaryTaskType != null) 'primaryTaskType': primaryTaskType!.name,
    if (primaryBarrier != null) 'primaryBarrier': primaryBarrier!.name,
  };
}

class ProposedAction {
  const ProposedAction({
    required this.title,
    required this.description,
    this.suggestedDuration = const Duration(minutes: 10),
    this.actionType = 'microAction',
  });

  final String title;
  final String description;
  final Duration suggestedDuration;
  final String actionType;

  Map<String, dynamic> toJson() => {
    'title': title,
    'description': description,
    'suggestedMinutes': suggestedDuration.inMinutes,
    'actionType': actionType,
  };

  factory ProposedAction.fromJson(Map<String, dynamic> json) {
    final rawMinutes = json['suggestedMinutes'];
    int minutes = 10;
    if (rawMinutes is num) {
      minutes = rawMinutes.toInt().clamp(5, 60);
    }
    return ProposedAction(
      title: json['title'] as String? ?? '极小切入点',
      description: json['description'] as String? ?? '只做 10 分钟，随时可以停下。',
      suggestedDuration: Duration(minutes: minutes),
      actionType: json['actionType'] as String? ?? 'microAction',
    );
  }
}

class AICompanionContext {
  const AICompanionContext({
    this.surface = CompanionSurface.home,
    this.barrier,
    this.taskType,
    this.currentTask,
    this.state = DogState.waiting,
    this.isFocusing = false,
    this.currentFocusDuration,
    this.recentSummary,
    this.deterministicInsightText,
    this.actualDurationMinutes,
  });

  final CompanionSurface surface;
  final StudyBarrier? barrier;
  final TaskType? taskType;
  final String? currentTask;
  final DogState state;
  final bool isFocusing;
  final Duration? currentFocusDuration;
  final RecentLearningSummary? recentSummary;
  final String? deterministicInsightText;
  final int? actualDurationMinutes;

  Map<String, dynamic> toJson() => {
    'surface': surface.name,
    if (barrier != null) 'barrier': barrier!.name,
    if (taskType != null) 'taskType': taskType!.name,
    if (currentTask != null && currentTask!.isNotEmpty)
      'currentTask': currentTask,
    'state': state.name,
    'isFocusing': isFocusing,
    if (currentFocusDuration != null)
      'currentFocusSeconds': currentFocusDuration!.inSeconds,
    if (recentSummary != null) 'recentSummary': recentSummary!.toJson(),
    if (deterministicInsightText != null)
      'deterministicInsight': deterministicInsightText,
    if (actualDurationMinutes != null)
      'actualDurationMinutes': actualDurationMinutes,
  };
}

class AICompanionRequest {
  const AICompanionRequest({
    required this.userMessage,
    required this.context,
    required this.locale,
  });

  final String userMessage;
  final AICompanionContext context;
  final String locale;
}

class AICompanionReply {
  const AICompanionReply({
    required this.text,
    this.intent = AICompanionIntent.support,
    this.detectedBarrier,
    this.suggestedTaskType,
    this.suggestedAction,
    this.requiresUserConfirmation = false,
    this.isLocalFallback = false,
    this.latencyMs = 0,
  });

  final String text;
  final AICompanionIntent intent;
  final StudyBarrier? detectedBarrier;
  final TaskType? suggestedTaskType;
  final ProposedAction? suggestedAction;
  final bool requiresUserConfirmation;
  final bool isLocalFallback;
  final int latencyMs;
}

/// Sanitizer strictly limiting context to minimal study data and stripping PII.
class AIContextSanitizer {
  static const int maxUserMessageLength = 300;
  static const int maxTaskTitleLength = 80;

  static AICompanionRequest sanitize(AICompanionRequest request) {
    String cleanMsg = request.userMessage.trim();
    if (cleanMsg.length > maxUserMessageLength) {
      cleanMsg = cleanMsg.substring(0, maxUserMessageLength);
    }

    String? cleanTask = request.context.currentTask?.trim();
    if (cleanTask != null && cleanTask.length > maxTaskTitleLength) {
      cleanTask = cleanTask.substring(0, maxTaskTitleLength);
    }

    final cleanContext = AICompanionContext(
      surface: request.context.surface,
      barrier: request.context.barrier,
      taskType: request.context.taskType,
      currentTask: cleanTask,
      state: request.context.state,
      isFocusing: request.context.isFocusing,
      currentFocusDuration: request.context.currentFocusDuration,
      recentSummary: request.context.recentSummary,
      deterministicInsightText: request.context.deterministicInsightText,
      actualDurationMinutes: request.context.actualDurationMinutes,
    );

    return AICompanionRequest(
      userMessage: cleanMsg,
      context: cleanContext,
      locale: request.locale,
    );
  }
}

abstract interface class AICompanionRepository {
  Future<AICompanionReply> sendMessage({
    required String userMessage,
    required AICompanionContext context,
    required String locale,
  });
}
