import 'package:flutter_test/flutter_test.dart';
import 'package:studyloop/data/repositories/hybrid_ai_companion_repository.dart';
import 'package:studyloop/domain/ai_companion_repository.dart';
import 'package:studyloop/domain/models.dart';

void main() {
  group('AI Companion Architecture & Hybrid Repository Tests', () {
    test('Minimal Context serialization omits raw session dumps', () {
      const summary = RecentLearningSummary(
        sessionCount7Days: 5,
        completedCount7Days: 4,
        avgActualMinutes: 18,
        primaryTaskType: TaskType.programmingPractice,
        primaryBarrier: StudyBarrier.uncertainStart,
      );

      const context = AICompanionContext(
        barrier: StudyBarrier.uncertainStart,
        taskType: TaskType.programmingPractice,
        currentTask: 'Build File Manager UI',
        state: DogState.waiting,
        currentFocusDuration: Duration(minutes: 5),
        recentSummary: summary,
      );

      final json = context.toJson();

      // Assert privacy minimization
      expect(json['barrier'], equals('uncertainStart'));
      expect(json['taskType'], equals('programmingPractice'));
      expect(json['currentTask'], equals('Build File Manager UI'));
      expect(json['state'], equals('waiting'));
      expect(json['currentFocusSeconds'], equals(300));
      expect(json.containsKey('rawRecords'), isFalse);
      expect(json.containsKey('databaseDump'), isFalse);

      final summaryJson = json['recentSummary'] as Map<String, dynamic>;
      expect(summaryJson['sessionCount7Days'], equals(5));
      expect(summaryJson['completedCount7Days'], equals(4));
      expect(summaryJson['avgActualMinutes'], equals(18));
      expect(summaryJson['primaryTaskType'], equals('programmingPractice'));
    });

    test(
      'Pre-request Safety Check redirects self-harm or severe illness to compassionate rest',
      () async {
        final repo = HybridAICompanionRepository();
        const context = AICompanionContext(
          barrier: StudyBarrier.tiredness,
          taskType: TaskType.reading,
        );

        // Chinese self-harm trigger
        final replyZh = await repo.sendMessage(
          userMessage: '我学不下去，活着没意思，想死',
          context: context,
          locale: 'zh',
        );

        expect(replyZh.isLocalFallback, isTrue);
        expect(replyZh.text, contains('停下所有任务'));
        expect(replyZh.text, contains('照顾自己'));
        expect(replyZh.suggestedAction?.actionType, equals('rest'));

        // English trigger
        final replyEn = await repo.sendMessage(
          userMessage: 'I feel like I want to kill myself',
          context: context,
          locale: 'en',
        );

        expect(replyEn.isLocalFallback, isTrue);
        expect(replyEn.text, contains('prioritize your well-being'));
        expect(replyEn.suggestedAction?.actionType, equals('rest'));
      },
    );

    test(
      'Local Fallback works seamlessly when gateway is not configured',
      () async {
        final repo = HybridAICompanionRepository(gatewayUrl: '');
        const context = AICompanionContext(
          barrier: StudyBarrier.phoneDistraction,
          taskType: TaskType.homework,
          currentTask: 'Math Homework',
        );

        final reply = await repo.sendMessage(
          userMessage: '手机一直在响，很难集中注意力',
          context: context,
          locale: 'zh',
        );

        expect(reply.text.isNotEmpty, isTrue);
        expect(reply.isLocalFallback, isTrue);
        expect(reply.suggestedAction, isNotNull);
      },
    );

    test('Local Fallback gracefully handles empty input', () async {
      final repo = HybridAICompanionRepository(gatewayUrl: '');
      const context = AICompanionContext();

      final reply = await repo.sendMessage(
        userMessage: '   ',
        context: context,
        locale: 'zh',
      );

      expect(reply.text, contains('柯基在这里呢'));
    });

    test('ProposedAction correctly serializes duration and type', () {
      const action = ProposedAction(
        title: '把手机放到另一个房间',
        description: '远离即时视线',
        suggestedDuration: Duration(minutes: 15),
        actionType: 'microAction',
      );

      final json = action.toJson();
      expect(json['title'], equals('把手机放到另一个房间'));
      expect(json['suggestedMinutes'], equals(15));
      expect(json['actionType'], equals('microAction'));
    });

    test('unreachable gateway falls back to the local engine', () async {
      final repo = HybridAICompanionRepository(
        gatewayUrl: 'https://127.0.0.1:65530/unreachable',
      );
      const context = AICompanionContext(
        barrier: StudyBarrier.phoneDistraction,
        currentTask: 'Finish Lab Report',
      );

      final reply = await repo.sendMessage(
        userMessage: '手机老是吸引我',
        context: context,
        locale: 'zh',
      );

      // Should degrade gracefully without crashing or throwing
      expect(reply.isLocalFallback, isTrue);
      expect(reply.text.isNotEmpty, isTrue);
      expect(reply.suggestedAction, isNotNull);
    });

    test('safety interception happens before any gateway request', () async {
      final repo = HybridAICompanionRepository(
        gatewayUrl: 'https://127.0.0.1:65530/unreachable',
      );
      const context = AICompanionContext();

      final reply = await repo.sendMessage(
        userMessage: '活着好累，想自杀',
        context: context,
        locale: 'zh',
      );

      // Must intercept without making network call
      expect(reply.isLocalFallback, isTrue);
      expect(reply.text, contains('停下所有任务'));
      expect(reply.suggestedAction?.actionType, equals('rest'));
    });
  });
}
