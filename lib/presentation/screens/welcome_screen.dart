import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../design_system/design_system.dart';
import '../../domain/models.dart';
import '../../providers.dart';

class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(stringsProvider);

    return Scaffold(
      backgroundColor: StudyLoopColors.background,
      body: AmbientBackground(
        hero: true,
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28.0,
                      vertical: 24.0,
                    ),
                    child: Column(
                      children: [
                        const Spacer(flex: 1),

                        // StudyLoop Logo & Brand Title
                        Column(
                          children: [
                            Container(
                              width: 92,
                              height: 68,
                              alignment: Alignment.center,
                              child: const Icon(
                                Icons.all_inclusive_rounded,
                                color: StudyLoopColors.primary,
                                size: 82,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'StudyLoop',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w800,
                                color: StudyLoopColors.textPrimary,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),

                        // Main Headline
                        Text(
                          strings.welcomeHeadline,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: StudyLoopColors.primary,
                            height: 1.35,
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Reuse the existing companion artwork across the journey.
                        const CorgiPortrait(
                          state: DogState.waiting,
                          size: CorgiPortraitSize.hero,
                        ),

                        const Spacer(flex: 1),
                        const SizedBox(height: 24),

                        // Primary CTA
                        PrimaryButton(
                          onPressed: () => context.go('/'),
                          label: strings.startJourneyBtn,
                        ),
                        const SizedBox(height: 20),

                        // Local Privacy Guarantee Badge
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.shield_outlined,
                              size: 15,
                              color: StudyLoopColors.primary,
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                strings.privacyBadgeText,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: StudyLoopColors.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
