import 'package:flutter_test/flutter_test.dart';
import 'package:studyloop/domain/corgi_chat_engine.dart';
import 'package:studyloop/domain/models.dart';

void main() {
  const engine = CorgiChatEngine();
  const responder = CompanionResponseEngine();

  group('CorgiChatEngine Tests', () {
    test('provides barrier-specific Chinese greetings', () {
      final overloadGreeting = engine.getInitialGreeting(
        locale: 'zh',
        barrier: StudyBarrier.overload,
      );
      expect(overloadGreeting.isNotEmpty, isTrue);
      expect(overloadGreeting.first.text, contains('要做的事情太多'));
      expect(overloadGreeting.first.suggestedAction, isNotNull);

      final phoneGreeting = engine.getInitialGreeting(
        locale: 'zh',
        barrier: StudyBarrier.phoneDistraction,
      );
      expect(phoneGreeting.first.text, contains('手机'));
    });

    test('provides English greetings and preset prompts', () {
      final enGreeting = engine.getInitialGreeting(
        locale: 'en',
        barrier: StudyBarrier.uncertainStart,
      );
      expect(enGreeting.first.text, contains('Woof'));

      final zhPrompts = engine.getPresetPrompts('zh');
      expect(zhPrompts.length, greaterThanOrEqualTo(5));
      expect(zhPrompts.first, contains('摸摸柯基'));

      final enPrompts = engine.getPresetPrompts('en');
      expect(enPrompts.first, contains('Pet the Corgi'));
    });

    test('responds compassionately to user queries with suggestions', () {
      final petReply = engine.respond(userText: '好可爱的小狗，摸摸你', locale: 'zh');
      expect(petReply.text, contains('柯基开心地摇起'));

      final phoneReply = engine.respond(userText: '我总是想刷短视频玩手机', locale: 'zh');
      expect(phoneReply.suggestedAction, isNotNull);
      expect(phoneReply.actionType, equals('set_task'));

      final tiredReply = engine.respond(userText: '我头好痛太累了', locale: 'zh');
      expect(tiredReply.actionType, equals('rest'));

      final codeReply = engine.respond(userText: '代码写不出来，好难', locale: 'zh');
      expect(codeReply.suggestedAction, isNotNull);
    });
  });

  group('Companion context and safety', () {
    test(
      'classifies five barriers, focus, history, early end, unknown, and safety',
      () {
        expect(responder.classify('要做的事情太多了'), CompanionIntent.overwhelmed);
        expect(responder.classify('我不知道从哪开始'), CompanionIntent.noStartingPoint);
        expect(responder.classify('总想玩手机'), CompanionIntent.phone);
        expect(responder.classify('太累了'), CompanionIntent.lowEnergy);
        expect(responder.classify('帮我拆更小'), CompanionIntent.breakdown);
        expect(responder.classify('我完成了'), CompanionIntent.completed);
        expect(responder.classify('asdfgh'), CompanionIntent.unknown);
        expect(responder.classify('我不想活了'), CompanionIntent.safety);
      },
    );

    test('focusing state keeps replies short', () {
      final cache = RecentReplyCache();
      final reply = responder.reply(
        userText: '帮我拆更小',
        locale: 'zh',
        context: const CompanionContext(companionState: DogState.focusing),
        cache: cache,
      );
      expect(reply.text.length, lessThan(40));
      expect(reply.text, contains('这一小步'));
    });

    test('early finish mentions saved minutes instead of failure', () {
      final cache = RecentReplyCache();
      final reply = responder.reply(
        userText: '我完成了',
        locale: 'zh',
        context: const CompanionContext(
          lastSessionDuration: Duration(minutes: 8),
          lastEndedEarly: true,
        ),
        cache: cache,
      );
      expect(reply.text, contains('8 分钟'));
      expect(reply.text.toLowerCase(), isNot(contains('失败')));
    });

    test('unknown input uses a safe fallback', () {
      final cache = RecentReplyCache();
      final reply = responder.reply(
        userText: 'qwerty',
        locale: 'zh',
        context: const CompanionContext(),
        cache: cache,
      );
      expect(reply.text, isNotEmpty);
    });

    test('safety input does not encourage studying', () {
      final reply = engine.respond(userText: '我想自杀', locale: 'zh');
      expect(reply.text, contains('照顾好自己'));
      expect(reply.suggestedAction, isNull);
      expect(reply.actionType, isNull);
    });

    test('recent template ids are not immediately repeated', () {
      final cache = RecentReplyCache();
      final first = responder.reply(
        userText: '摸摸',
        locale: 'zh',
        context: const CompanionContext(),
        cache: cache,
      );
      final second = responder.reply(
        userText: '摸摸',
        locale: 'zh',
        context: const CompanionContext(),
        cache: cache,
      );
      expect(first.templateId, isNot(equals(second.templateId)));
    });
  });
}
