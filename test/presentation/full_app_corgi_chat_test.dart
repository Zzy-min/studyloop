import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studyloop/app.dart';
import 'package:studyloop/data/database/app_database.dart';
import 'package:studyloop/presentation/screens/corgi_chat_screen.dart';
import 'package:studyloop/providers.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.memory();
  });

  tearDown(() async {
    await db.close();
  });

  testWidgets('full app navigation to /chat renders all chat UI elements', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          localeProvider.overrideWith(() => LocaleNotifier('zh')),
        ],
        child: const StudyLoopApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify EntryScreen is rendered with DogCompanion
    expect(find.byType(DogCompanion), findsOneWidget);

    // Tap DogCompanion
    await tester.tap(find.byType(DogCompanion));
    await tester.pumpAndSettle();

    // Verify CorgiChatScreen is rendered
    expect(find.byType(CorgiChatScreen), findsOneWidget);
    expect(find.text('柯基学习伴侣'), findsOneWidget);
    expect(find.textContaining('汪！我是你的学习陪伴柯基'), findsOneWidget);
    expect(find.text('🐾 摸摸柯基小狗'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);

    // Send a message
    await tester.tap(find.text('🐾 摸摸柯基小狗'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();

    expect(find.textContaining('柯基开心地摇起'), findsOneWidget);
  });
}
