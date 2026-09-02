import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../../bootstrap/app_environment.dart';
import '../../domain/ai_companion_repository.dart';
import '../../domain/corgi_chat_engine.dart';
import '../../domain/models.dart';
import 'ai_gateway_session_repository.dart';

class HybridAICompanionRepository implements AICompanionRepository {
  HybridAICompanionRepository({
    String? gatewayUrl,
    HttpClient? httpClient,
    CorgiChatEngine? fallbackEngine,
    AiGatewaySessionProvider? sessionProvider,
  }) : _gatewayUrl = gatewayUrl ?? AppEnvironment.aiGatewayBaseUrl,
       _client =
           httpClient ??
           (HttpClient()..connectionTimeout = const Duration(seconds: 10)),
       _fallbackEngine = fallbackEngine ?? const CorgiChatEngine(),
       _sessionProvider = sessionProvider ?? PlatformAiGatewaySessionProvider();

  final String _gatewayUrl;
  final HttpClient _client;
  final CorgiChatEngine _fallbackEngine;
  final AiGatewaySessionProvider _sessionProvider;

  static final List<String> _safetyPatterns = [
    '不想活',
    '想死',
    '自杀',
    '自残',
    '活着没意思',
    '自伤',
    '心脏剧痛',
    '呼吸困难',
    '昏厥',
    'suicide',
    'kill myself',
    'end my life',
    'self harm',
    'severe pain',
  ];

  bool _isSafetyTriggered(String input) {
    final lower = input.toLowerCase();
    for (final pattern in _safetyPatterns) {
      if (lower.contains(pattern)) return true;
    }
    return false;
  }

  @override
  Future<AICompanionReply> sendMessage({
    required String userMessage,
    required AICompanionContext context,
    required String locale,
  }) async {
    // 0. Sanitize request and enforce privacy constraints
    final sanitized = AIContextSanitizer.sanitize(
      AICompanionRequest(
        userMessage: userMessage,
        context: context,
        locale: locale,
      ),
    );
    final cleanMsg = sanitized.userMessage;
    final cleanCtx = sanitized.context;
    final cleanLocale = sanitized.locale;

    if (cleanMsg.isEmpty && cleanCtx.surface == CompanionSurface.home) {
      return AICompanionReply(
        text: cleanLocale.startsWith('zh')
            ? '柯基在这里呢。有什么想和我聊聊的吗？'
            : 'I am here with you. What is on your mind?',
        isLocalFallback: true,
      );
    }

    // 1. Pre-request Safety Check
    if (_isSafetyTriggered(cleanMsg)) {
      final isZh = cleanLocale.startsWith('zh');
      return AICompanionReply(
        text: isZh
            ? '柯基察觉到了你现在的状态。请先停下所有任务，深呼吸，好好照顾自己。学习完全可以稍后再说。如果感到极度难受或有危险，请及时联系亲友或专业求助热线。'
            : 'I hear you. Please pause, take a deep breath, and prioritize your well-being right now. Studying can wait. If you are experiencing distress or crisis, please reach out to someone you trust or a crisis helpline.',
        intent: AICompanionIntent.support,
        suggestedAction: ProposedAction(
          title: isZh ? '停下并闭目休息' : 'Pause and rest quietly',
          description: isZh
              ? '身体与情绪永远排在第一位。'
              : 'Health and safety always come first.',
          actionType: 'rest',
        ),
        requiresUserConfirmation: false,
        isLocalFallback: true,
      );
    }

    final stopwatch = Stopwatch()..start();

    // A mobile app may call a gateway, never a model provider with a secret.
    if (_gatewayUrl.trim().isNotEmpty) {
      try {
        final gatewayReply = await _callGateway(
          userMessage: cleanMsg,
          context: cleanCtx,
          locale: cleanLocale,
          stopwatch: stopwatch,
        );
        if (gatewayReply != null) {
          return gatewayReply;
        }
      } catch (_) {
        // Fallback to local engine
      }
    }

    // Graceful degradation to the local deterministic engine.
    return _localFallback(
      userMessage: cleanMsg,
      context: cleanCtx,
      locale: cleanLocale,
      isGatewayUnavailable: _gatewayUrl.isNotEmpty,
    );
  }

  Future<AICompanionReply?> _callGateway({
    required String userMessage,
    required AICompanionContext context,
    required String locale,
    required Stopwatch stopwatch,
  }) async {
    final accessToken = await _sessionProvider.acquire(_gatewayUrl);
    if (accessToken == null) return null;

    final uri = Uri.parse(_gatewayUrl).resolve('/v1/companion');
    final request = await _client
        .postUrl(uri)
        .timeout(const Duration(seconds: 5));
    request.headers.set(
      HttpHeaders.contentTypeHeader,
      'application/json; charset=utf-8',
    );
    request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $accessToken');

    final payload = jsonEncode({
      'message': userMessage,
      'context': context.toJson(),
      'locale': locale,
    });
    request.write(payload);

    final response = await request.close().timeout(const Duration(seconds: 5));
    stopwatch.stop();

    if (response.statusCode == 200) {
      final responseBody = await response.transform(utf8.decoder).join();
      return _parseContentJson(responseBody, stopwatch.elapsedMilliseconds);
    }
    return null;
  }

  AICompanionReply? _parseContentJson(String raw, int latencyMs) {
    var cleaned = raw.trim();
    if (cleaned.startsWith('```json')) {
      cleaned = cleaned.substring(7);
    }
    if (cleaned.startsWith('```')) {
      cleaned = cleaned.substring(3);
    }
    if (cleaned.endsWith('```')) {
      cleaned = cleaned.substring(0, cleaned.length - 3);
    }
    cleaned = cleaned.trim();

    try {
      final json = jsonDecode(cleaned) as Map<String, dynamic>;
      final replyText = json['reply'] as String? ?? '';
      if (replyText.isEmpty) return null;

      final barrierName =
          json['suggestedBarrier'] as String? ??
          json['detectedBarrier'] as String?;
      StudyBarrier? detectedBarrier;
      if (barrierName != null) {
        try {
          detectedBarrier = StudyBarrier.values.byName(barrierName);
        } catch (_) {}
      }

      final taskTypeName = json['suggestedTaskType'] as String?;
      TaskType? suggestedTaskType;
      if (taskTypeName != null) {
        try {
          suggestedTaskType = TaskType.values.byName(taskTypeName);
        } catch (_) {}
      }

      ProposedAction? suggestedAction;
      if (json['proposedAction'] is Map<String, dynamic>) {
        final actionMap = json['proposedAction'] as Map<String, dynamic>;
        suggestedAction = ProposedAction.fromJson(actionMap);
      } else if (json['suggestedAction'] is Map<String, dynamic>) {
        final actionMap = json['suggestedAction'] as Map<String, dynamic>;
        suggestedAction = ProposedAction.fromJson(actionMap);
      }

      final intentStr = json['intent'] as String? ?? 'support';
      final intent = switch (intentStr) {
        'propose_action' || 'proposeAction' => AICompanionIntent.proposeAction,
        'explain_insight' ||
        'explainInsight' => AICompanionIntent.explainInsight,
        'clarify_barrier' ||
        'clarifyBarrier' => AICompanionIntent.clarifyBarrier,
        _ => AICompanionIntent.support,
      };

      final bool requiresUserConfirmation =
          json['requiresUserConfirmation'] as bool? ??
          (suggestedAction != null);

      return AICompanionReply(
        text: replyText,
        intent: intent,
        detectedBarrier: detectedBarrier,
        suggestedTaskType: suggestedTaskType,
        suggestedAction: suggestedAction,
        requiresUserConfirmation: requiresUserConfirmation,
        isLocalFallback: false,
        latencyMs: latencyMs,
      );
    } catch (_) {}
    return null;
  }

  AICompanionReply _localFallback({
    required String userMessage,
    required AICompanionContext context,
    required String locale,
    required bool isGatewayUnavailable,
  }) {
    final isZh = locale.startsWith('zh');

    // Surface-specific local intelligent fallbacks
    switch (context.surface) {
      case CompanionSurface.taskBreakdown:
        final task = context.currentTask?.trim() ?? userMessage.trim();
        final microTitle = task.isNotEmpty
            ? (isZh ? '先快速浏览或写下「$task」的第1点' : 'Skim the 1st key point of $task')
            : (isZh ? '打开相关课本或资料并看目录' : 'Open materials and read the TOC');
        return AICompanionReply(
          text: isZh
              ? '汪！把任务缩小才能轻松迈步。先不要去想全部完成，只做这最简单的 10 分钟试一下？'
              : 'Woof! Shrinking the task makes starting frictionless. Try doing just this 10-minute tiny step?',
          intent: AICompanionIntent.proposeAction,
          detectedBarrier: context.barrier ?? StudyBarrier.uncertainStart,
          suggestedAction: ProposedAction(
            title: microTitle,
            description: isZh
                ? '只做 10 分钟，时间一到随时可以停下。'
                : 'Only 10 minutes, pause whenever you wish.',
            suggestedDuration: const Duration(minutes: 10),
          ),
          requiresUserConfirmation: true,
          isLocalFallback: true,
        );

      case CompanionSurface.focus:
        return AICompanionReply(
          text: isZh
              ? '汪！柯基正安静趴在旁边陪你。如果真的感觉做不下去了，可以随时点击结束并保存现在的成果去休息哦。'
              : 'Woof! I am lying beside you quietly. If you genuinely feel overwhelmed, you can save your time and rest.',
          intent: AICompanionIntent.support,
          requiresUserConfirmation: false,
          isLocalFallback: true,
        );

      case CompanionSurface.reflection:
        return AICompanionReply(
          text: isZh
              ? '汪！完成了刚才的专注，非常棒！每一次主动开始，都是战胜拖延的宝贵证明。'
              : 'Woof! Great job finishing this focus session. Every start is proof of progress.',
          intent: AICompanionIntent.support,
          requiresUserConfirmation: false,
          isLocalFallback: true,
        );

      case CompanionSurface.insights:
        final insight =
            context.deterministicInsightText ??
            (isZh ? '保持短时多次的启动习惯' : 'Keep short, frequent study starts');
        return AICompanionReply(
          text: isZh
              ? '柯基解读规律：$insight。数据显示只要你跨过最开始的几分钟，后续就容易渐入佳境！'
              : 'Corgi says: $insight. Once you take the first step, focus naturally follows!',
          intent: AICompanionIntent.explainInsight,
          requiresUserConfirmation: false,
          isLocalFallback: true,
        );

      case CompanionSurface.home:
        final legacyContext = CompanionContext(
          currentBarrier: context.barrier,
          taskType: context.taskType,
          currentTaskTitle: context.currentTask,
          companionState: context.state,
          currentSessionDuration: context.currentFocusDuration,
        );

        final reply = _fallbackEngine.respond(
          userText: userMessage,
          locale: locale,
          barrier: context.barrier,
          currentTask: context.currentTask ?? '',
          context: legacyContext,
        );

        ProposedAction? action;
        if (reply.suggestedAction != null) {
          action = ProposedAction(
            title: reply.suggestedAction!,
            description: '',
            actionType: reply.actionType ?? 'microAction',
          );
        }

        return AICompanionReply(
          text: reply.text,
          intent: action != null
              ? AICompanionIntent.proposeAction
              : AICompanionIntent.support,
          detectedBarrier: context.barrier,
          suggestedAction: action,
          requiresUserConfirmation: action != null,
          isLocalFallback: true,
        );
    }
  }
}
