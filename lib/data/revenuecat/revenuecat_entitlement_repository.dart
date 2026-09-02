import 'dart:async';

import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart' hide PurchaseResult;

import '../../domain/entitlement_repository.dart';
import '../../domain/models.dart';

enum RevenueCatPurchaseOutcome { activated, cancelled }

abstract interface class RevenueCatClient {
  Future<bool> refresh();
  Future<RevenueCatPurchaseOutcome> purchase();
  Future<bool> restore();
  Stream<bool> get changes;
}

class RevenueCatEntitlementRepository implements EntitlementRepository {
  RevenueCatEntitlementRepository(this._client);

  final RevenueCatClient _client;

  @override
  Stream<EntitlementState> get changes => _client.changes.map(
    (active) => active ? EntitlementState.pro : EntitlementState.free,
  );

  @override
  Future<EntitlementState> refresh() async =>
      await _client.refresh() ? EntitlementState.pro : EntitlementState.free;

  @override
  Future<PurchaseResult> purchase() async {
    try {
      return switch (await _client.purchase()) {
        RevenueCatPurchaseOutcome.activated => const PurchaseActivated(),
        RevenueCatPurchaseOutcome.cancelled => const PurchaseCancelled(),
      };
    } catch (_) {
      return const PurchaseFailed(
        'Purchase could not be completed. Please try again.',
      );
    }
  }

  @override
  Future<PurchaseResult> restore() async {
    try {
      return await _client.restore()
          ? const PurchaseActivated()
          : const NothingToRestore();
    } catch (_) {
      return const PurchaseFailed(
        'Purchases could not be restored. Please try again.',
      );
    }
  }
}

class PurchasesRevenueCatClient implements RevenueCatClient {
  PurchasesRevenueCatClient(this._entitlementId);

  final String _entitlementId;
  final _changes = StreamController<bool>.broadcast();
  CustomerInfoUpdateListener? _listener;

  Future<void> initialize(String apiKey) async {
    await Purchases.configure(PurchasesConfiguration(apiKey));
    _listener = (customerInfo) => _changes.add(_isActive(customerInfo));
    Purchases.addCustomerInfoUpdateListener(_listener!);
  }

  bool _isActive(CustomerInfo customerInfo) =>
      customerInfo.entitlements.active.containsKey(_entitlementId);

  @override
  Stream<bool> get changes => _changes.stream;

  @override
  Future<bool> refresh() async => _isActive(await Purchases.getCustomerInfo());

  @override
  Future<RevenueCatPurchaseOutcome> purchase() async {
    final offering = (await Purchases.getOfferings()).current;
    final package =
        offering?.monthly ??
        (offering != null && offering.availablePackages.isNotEmpty
            ? offering.availablePackages.first
            : null);
    if (package == null) {
      throw StateError('No package is available in the current offering.');
    }

    try {
      final result = await Purchases.purchase(PurchaseParams.package(package));
      if (!_isActive(result.customerInfo)) {
        throw StateError(
          'The purchase did not activate the configured entitlement.',
        );
      }
      return RevenueCatPurchaseOutcome.activated;
    } on PlatformException catch (error) {
      if (PurchasesErrorHelper.getErrorCode(error) ==
          PurchasesErrorCode.purchaseCancelledError) {
        return RevenueCatPurchaseOutcome.cancelled;
      }
      rethrow;
    }
  }

  @override
  Future<bool> restore() async => _isActive(await Purchases.restorePurchases());

  Future<void> dispose() async {
    final listener = _listener;
    if (listener != null) Purchases.removeCustomerInfoUpdateListener(listener);
    await _changes.close();
  }
}

class DeferredEntitlementRepository implements EntitlementRepository {
  DeferredEntitlementRepository([EntitlementRepository? inner])
    : _inner =
          inner ?? FakeEntitlementRepository(state: EntitlementState.unknown);

  EntitlementRepository _inner;
  final _controller = StreamController<EntitlementState>.broadcast();
  StreamSubscription<EntitlementState>? _sub;

  void attach(EntitlementRepository repository) {
    _sub?.cancel();
    _inner = repository;
    _sub = repository.changes.listen(_controller.add);
  }

  @override
  Stream<EntitlementState> get changes => _controller.stream;

  @override
  Future<EntitlementState> refresh() => _inner.refresh();

  @override
  Future<PurchaseResult> purchase() => _inner.purchase();

  @override
  Future<PurchaseResult> restore() => _inner.restore();
}
