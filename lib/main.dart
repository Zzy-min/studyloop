import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'bootstrap/app_environment.dart';
import 'data/database/app_database.dart';
import 'data/revenuecat/revenuecat_entitlement_repository.dart';
import 'providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final database = AppDatabase.open();
  final billing = DeferredEntitlementRepository();
  runApp(
    ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(database),
        entitlementRepositoryProvider.overrideWithValue(billing),
      ],
      child: const StudyLoopApp(),
    ),
  );
  unawaited(_configureBilling(billing));
}

Future<void> _configureBilling(DeferredEntitlementRepository billing) async {
  final apiKey = AppEnvironment.revenueCatApiKey.trim();
  if (apiKey.isEmpty) return;
  try {
    final client = PurchasesRevenueCatClient(AppEnvironment.proEntitlementId);
    await client.initialize(apiKey);
    billing.attach(RevenueCatEntitlementRepository(client));
  } catch (_) {
    // Leave billing unknown. The free study loop is already running.
  }
}
