import 'package:flutter_test/flutter_test.dart';
import 'package:studyloop/data/repositories/hybrid_ai_companion_repository.dart';
import 'package:studyloop/domain/ai_companion_repository.dart';
import 'package:studyloop/domain/companion_prompts.dart';
import 'package:studyloop/domain/models.dart';

void main() {
  group('AI Workflow Integration & Context Sanitizer Tests', () {
    test(
      'AIContextSanitizer truncates overly long user messages and task titles',
      () {
        final longMsg = 'A' * 500;
        final longTask = 'B' * 200;

        final request = AICompanionRequest(
          userMessage: longMsg,
          context: AICompanionContext(
            surface: CompanionSurface.taskBreakdown,
            currentTask: longTask,
          ),
          locale: 'zh',
        );

        final sanitized = AIContextSanitizer.sanitize(request);

        expect(
          sanitized.userMessage.length,
          equals(AIContextSanitizer.maxUserMessageLength),
        );
        expect(
          sanitized.context.currentTask!.length,
          equals(AIContextSanitizer.maxTaskTitleLength),
        );
        expect(
          sanitized.context.surface,
          equals(CompanionSurface.taskBreakdown),
        );
      },
    );

    test(
      'CompanionPrompts builds surface-specific system prompts correctly',
      () {
        for (final surface in CompanionSurface.values) {
          final promptZh = CompanionPrompts.buildSystemPrompt(
            surface: surface,
            locale: 'zh',
          );
          expect(promptZh, contains('柯基学习伴侣'));
          expect(promptZh, contains('Strict Prohibitions'));

          final promptEn = CompanionPrompts.buildSystemPrompt(
            surface: surface,
            locale: 'en',
          );
          expect(promptEn, contains('Corgi Study Companion'));
        }
      },
    );

    test('ProposedAction clamps durations between 5 and 60 minutes', () {
      final jsonTooSmall = {
        'title': '超短测试',
        'description': '小于5分钟',
        'suggestedMinutes': 1,
      };
      final actionSmall = ProposedAction.fromJson(jsonTooSmall);
      expect(actionSmall.suggestedDuration.inMinutes, equals(5));

      final jsonTooLarge = {
        'title': '超长测试',
        'description': '大于60分钟',
        'suggestedMinutes': 120,
      };
      final actionLarge = ProposedAction.fromJson(jsonTooLarge);
      expect(actionLarge.suggestedDuration.inMinutes, equals(60));
    });

    test(
      'Surface 2 (TaskBreakdown) local fallback produces actionable micro action',
      () async {
        final repo = HybridAICompanionRepository();
        const context = AICompanionContext(
          surface: CompanionSurface.taskBreakdown,
          currentTask: '复习整本线性代数与特征值',
          barrier: StudyBarrier.uncertainStart,
        );

        final reply = await repo.sendMessage(
          userMessage: '复习整本线性代数与特征值',
          context: context,
          locale: 'zh',
        );

        expect(reply.isLocalFallback, isTrue);
        expect(reply.intent, equals(AICompanionIntent.proposeAction));
        expect(reply.suggestedAction, isNotNull);
        expect(reply.suggestedAction!.title, contains('复习整本线性代数与特征值'));
        expect(
          reply.suggestedAction!.suggestedDuration.inMinutes,
          inInclusiveRange(5, 15),
        );
        expect(reply.requiresUserConfirmation, isTrue);
      },
    );

    test(
      'Surface 3 (Focus) local fallback gives gentle, concise accompaniment',
      () async {
        final repo = HybridAICompanionRepository();
        const context = AICompanionContext(
          surface: CompanionSurface.focus,
          isFocusing: true,
          currentFocusDuration: Duration(minutes: 12),
        );

        final reply = await repo.sendMessage(
          userMessage: '有点不想做了',
          context: context,
          locale: 'zh',
        );

        expect(reply.isLocalFallback, isTrue);
        expect(reply.intent, equals(AICompanionIntent.support));
        expect(reply.text, contains('陪你'));
        expect(reply.requiresUserConfirmation, isFalse);
      },
    );

    test(
      'Surface 4 (Reflection) local fallback validates effort without faking ratings',
      () async {
        final repo = HybridAICompanionRepository();
        const context = AICompanionContext(
          surface: CompanionSurface.reflection,
          actualDurationMinutes: 18,
        );

        final reply = await repo.sendMessage(
          userMessage: '刚开始挺难，后面渐入佳境',
          context: context,
          locale: 'zh',
        );

        expect(reply.isLocalFallback, isTrue);
        expect(reply.intent, equals(AICompanionIntent.support));
        expect(reply.text, contains('完成了刚才的专注'));
        expect(reply.requiresUserConfirmation, isFalse);
      },
    );

    test(
      'Surface 5 (Insights) local fallback explains deterministic metrics',
      () async {
        final repo = HybridAICompanionRepository();
        const context = AICompanionContext(
          surface: CompanionSurface.insights,
          deterministicInsightText: '上午时段专注效率最高，平均达成率 92%',
        );

        final reply = await repo.sendMessage(
          userMessage: '上午时段专注效率最高，平均达成率 92%',
          context: context,
          locale: 'zh',
        );

        expect(reply.isLocalFallback, isTrue);
        expect(reply.intent, equals(AICompanionIntent.explainInsight));
        expect(reply.text, contains('上午时段专注效率最高'));
      },
    );

    test(
      'Crisis safety pattern halts study push and advises rest & safety',
      () async {
        final repo = HybridAICompanionRepository();
        const context = AICompanionContext(surface: CompanionSurface.home);

        final reply = await repo.sendMessage(
          userMessage: '我真不想活了，压力太大了',
          context: context,
          locale: 'zh',
        );

        expect(reply.isLocalFallback, isTrue);
        expect(reply.text, contains('深呼吸，好好照顾自己'));
        expect(reply.suggestedAction?.actionType, equals('rest'));
      },
    );
  });
}
