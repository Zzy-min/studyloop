import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:studyloop/data/revenuecat/revenuecat_entitlement_repository.dart';
import 'package:studyloop/domain/entitlement_repository.dart';
import 'package:studyloop/domain/models.dart';

void main() {
  late FakeRevenueCatClient client;
  late RevenueCatEntitlementRepository repository;

  setUp(() {
    client = FakeRevenueCatClient();
    repository = RevenueCatEntitlementRepository(client);
  });

  tearDown(() => client.dispose());

  test('maps verified entitlement state and updates', () async {
    client.isPro = false;
    expect(await repository.refresh(), EntitlementState.free);

    expectLater(repository.changes, emits(EntitlementState.pro));
    client.emit(true);
  });

  test('maps an activated purchase', () async {
    client.purchaseOutcome = RevenueCatPurchaseOutcome.activated;

    expect(await repository.purchase(), isA<PurchaseActivated>());
  });

  test('maps a cancelled purchase without treating it as a failure', () async {
    client.purchaseOutcome = RevenueCatPurchaseOutcome.cancelled;

    expect(await repository.purchase(), isA<PurchaseCancelled>());
  });

  test('maps purchase errors to a stable user-facing failure', () async {
    client.purchaseError = StateError('private SDK detail');

    final result = await repository.purchase();
    expect(result, isA<PurchaseFailed>());
    expect(
      (result as PurchaseFailed).message,
      'Purchase could not be completed. Please try again.',
    );
  });

  test('maps restore results', () async {
    client.restoreActivated = false;
    expect(await repository.restore(), isA<NothingToRestore>());

    client.restoreActivated = true;
    expect(await repository.restore(), isA<PurchaseActivated>());
  });

  test('maps restore errors to a stable user-facing failure', () async {
    client.restoreError = StateError('private SDK detail');

    final result = await repository.restore();
    expect(result, isA<PurchaseFailed>());
    expect(
      (result as PurchaseFailed).message,
      'Purchases could not be restored. Please try again.',
    );
  });
}

class FakeRevenueCatClient implements RevenueCatClient {
  bool isPro = false;
  RevenueCatPurchaseOutcome purchaseOutcome =
      RevenueCatPurchaseOutcome.cancelled;
  bool restoreActivated = false;
  Object? purchaseError;
  Object? restoreError;
  final _changes = StreamController<bool>.broadcast();

  @override
  Stream<bool> get changes => _changes.stream;

  @override
  Future<bool> refresh() async => isPro;

  @override
  Future<RevenueCatPurchaseOutcome> purchase() async {
    if (purchaseError case final error?) throw error;
    return purchaseOutcome;
  }

  @override
  Future<bool> restore() async {
    if (restoreError case final error?) throw error;
    return restoreActivated;
  }

  void emit(bool value) => _changes.add(value);

  Future<void> dispose() => _changes.close();
}
