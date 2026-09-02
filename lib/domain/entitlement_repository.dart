import 'dart:async';

import 'models.dart';

sealed class PurchaseResult {
  const PurchaseResult();
}

class PurchaseActivated extends PurchaseResult {
  const PurchaseActivated();
}

class PurchaseCancelled extends PurchaseResult {
  const PurchaseCancelled();
}

class PurchaseFailed extends PurchaseResult {
  const PurchaseFailed(this.message);
  final String message;
}

class NothingToRestore extends PurchaseResult {
  const NothingToRestore();
}

abstract interface class EntitlementRepository {
  Future<EntitlementState> refresh();
  Future<PurchaseResult> purchase();
  Future<PurchaseResult> restore();
  Stream<EntitlementState> get changes;
}

class FakeEntitlementRepository implements EntitlementRepository {
  FakeEntitlementRepository({
    this.state = EntitlementState.unknown,
    this.purchaseResult = const PurchaseCancelled(),
    this.restoreResult = const NothingToRestore(),
  });

  EntitlementState state;
  PurchaseResult purchaseResult;
  PurchaseResult restoreResult;
  final _controller = StreamController<EntitlementState>.broadcast();

  @override
  Stream<EntitlementState> get changes => _controller.stream;

  @override
  Future<EntitlementState> refresh() async => state;

  @override
  Future<PurchaseResult> purchase() async {
    final result = purchaseResult;
    if (result is PurchaseActivated) {
      state = EntitlementState.pro;
      _controller.add(state);
    } else if (result is PurchaseCancelled) {
      // Keep current verified state; cancellation is not an error.
    }
    return result;
  }

  @override
  Future<PurchaseResult> restore() async {
    final result = restoreResult;
    if (result is PurchaseActivated) {
      state = EntitlementState.pro;
      _controller.add(state);
    }
    return result;
  }

  void emit(EntitlementState next) {
    state = next;
    _controller.add(next);
  }

  Future<void> dispose() => _controller.close();
}
