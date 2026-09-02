import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entitlement_repository.dart';
import '../../domain/models.dart';
import '../../providers.dart';

class PaywallViewState {
  const PaywallViewState({
    required this.isPro,
    required this.isBusy,
    required this.statusMessage,
    required this.isChinese,
  });

  final bool isPro;
  final bool isBusy;
  final String statusMessage;
  final bool isChinese;
}

class PaywallController extends Notifier<PaywallViewState> {
  bool _isBusy = false;

  @override
  PaywallViewState build() {
    final entitlement = ref.watch(entitlementProvider);
    final strings = ref.watch(stringsProvider);
    final notifier = ref.watch(entitlementProvider.notifier);

    return PaywallViewState(
      isPro: entitlement == EntitlementState.pro,
      isBusy: _isBusy,
      statusMessage: notifier.message,
      isChinese: strings.isChinese,
    );
  }

  Future<PurchaseResult?> purchase() async {
    if (_isBusy) return null;
    _setBusy(true);
    try {
      return await ref.read(entitlementProvider.notifier).purchase();
    } finally {
      _setBusy(false);
    }
  }

  Future<PurchaseResult?> restore() async {
    if (_isBusy) return null;
    _setBusy(true);
    try {
      return await ref.read(entitlementProvider.notifier).restore();
    } finally {
      _setBusy(false);
    }
  }

  void _setBusy(bool value) {
    _isBusy = value;
    state = PaywallViewState(
      isPro: state.isPro,
      isBusy: value,
      statusMessage: state.statusMessage,
      isChinese: state.isChinese,
    );
  }
}

final paywallControllerProvider =
    NotifierProvider<PaywallController, PaywallViewState>(
      PaywallController.new,
    );
