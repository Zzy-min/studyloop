import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studyloop/data/database/app_database.dart';
import 'package:studyloop/domain/models.dart';
import 'package:studyloop/presentation/widgets/companion_card.dart';
import 'package:studyloop/presentation/widgets/corgi_chat_dialog.dart';
import 'package:studyloop/providers.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.memory();
  });

  tearDown(() async {
    await db.close();
  });

  Widget buildTestApp() {
    return ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
        localeProvider.overrideWith(() => LocaleNotifier('zh')),
      ],
      child: const MaterialApp(
        home: Scaffold(body: DogCompanion(state: DogState.waiting)),
      ),
    );
  }

  testWidgets('tapping DogCompanion opens CorgiChatDialog and sends message', (
    tester,
  ) async {
    await tester.pumpWidget(buildTestApp());
    await tester.pumpAndSettle();

    // Verify companion card is visible with chat badge
    expect(find.byType(DogCompanion), findsOneWidget);
    expect(find.textContaining('聊聊'), findsOneWidget);

    // Tap companion card to open bottom sheet
    await tester.tap(find.byType(DogCompanion));
    await tester.pumpAndSettle();

    // Verify CorgiChatDialog is visible
    expect(find.byType(CorgiChatDialog), findsOneWidget);
    expect(find.text('柯基学习伴侣'), findsOneWidget);

    // Tap a preset prompt chip
    final promptChip = find.text('🐾 摸摸柯基小狗');
    expect(promptChip, findsOneWidget);
    await tester.tap(promptChip);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();

    // Verify reply received
    expect(find.textContaining('柯基开心地摇起'), findsOneWidget);

    // Type custom message
    final inputField = find.byType(TextField);
    expect(inputField, findsOneWidget);
    await tester.enterText(inputField, '帮我把任务拆更小一点');
    await tester.testTextInput.receiveAction(TextInputAction.send);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();

    // Verify task breakdown reply and action button
    expect(find.textContaining('柯基帮你把'), findsOneWidget);
    expect(find.text('填入此极小行动'), findsOneWidget);

    // Tap action button
    await tester.tap(find.text('填入此极小行动'));
    await tester.pumpAndSettle();

    // Verify dialog closed
    expect(find.byType(CorgiChatDialog), findsNothing);
  });
}
