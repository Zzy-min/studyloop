import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../design_system/design_system.dart';
import '../../domain/entitlement_repository.dart';
import '../../domain/models.dart';
import '../../providers.dart';
import '../theme/app_theme.dart';
import '../view_models/paywall_view_model.dart';
import '../widgets/page_frame.dart';

class PaywallScreen extends ConsumerWidget {
  const PaywallScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entitlement = ref.watch(entitlementProvider);
    final paywallState = ref.watch(paywallControllerProvider);
    final paywallCtrl = ref.read(paywallControllerProvider.notifier);
    final origin = ref.watch(paywallOriginProvider);
    final strings = ref.watch(stringsProvider);

    return PageFrame(
      title: strings.paywallTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: AppTheme.primaryDark,
              borderRadius: BorderRadius.circular(24),
              boxShadow: StudyLoopShadows.subtle,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.workspace_premium_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'StudyLoop Pro',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  strings.paywallHeadline,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Value items
          _FeatureCheckItem(text: strings.paywallFeature1),
          const SizedBox(height: 8),
          _FeatureCheckItem(text: strings.paywallFeature2),
          const SizedBox(height: 8),
          _FeatureCheckItem(text: strings.paywallFeature3),
          const SizedBox(height: 24),

          if (paywallState.statusMessage.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xfffef2f2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xfffecdd3)),
              ),
              child: Text(
                paywallState.statusMessage,
                style: const TextStyle(color: Color(0xffb91c1c), fontSize: 13),
              ),
            ),
            const SizedBox(height: 16),
          ],

          FilledButton(
            onPressed: paywallState.isBusy
                ? null
                : () async {
                    final result = await paywallCtrl.purchase();
                    if (!context.mounted) return;
                    if (result is PurchaseCancelled) {
                      context.go(origin);
                      return;
                    }
                    if (result is PurchaseActivated) context.go(origin);
                  },
            child: paywallState.isBusy
                ? const SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(strings.continueWithPro),
          ),
          const SizedBox(height: 6),
          TextButton(
            onPressed: paywallState.isBusy
                ? null
                : () async {
                    await paywallCtrl.restore();
                    if (context.mounted &&
                        ref.read(entitlementProvider) == EntitlementState.pro) {
                      context.go(origin);
                    }
                  },
            child: Text(strings.restorePurchases),
          ),
          TextButton(
            onPressed: paywallState.isBusy ? null : () => context.go(origin),
            child: Text(strings.notNow),
          ),
          const SizedBox(height: 12),
          if (entitlement == EntitlementState.unknown || kDebugMode)
            Text(
              entitlement == EntitlementState.unknown
                  ? strings.paywallOfflineNotice
                  : strings.paywallTestStoreNotice,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppTheme.textTertiary,
                fontSize: 12,
                height: 1.35,
              ),
            ),
        ],
      ),
    );
  }
}

class _FeatureCheckItem extends StatelessWidget {
  const _FeatureCheckItem({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.cardBorderColor),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle_rounded,
            color: AppTheme.sageGreen,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
