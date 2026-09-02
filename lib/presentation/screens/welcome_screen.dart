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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            children: [
              const Spacer(flex: 1),

              // StudyLoop Logo & Brand Title
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: const BoxDecoration(
                      color: StudyLoopColors.primaryLight,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.all_inclusive_rounded,
                      color: StudyLoopColors.primary,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'StudyLoop',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: StudyLoopColors.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Main Headline
              Text(
                strings.welcomeHeadline,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: StudyLoopColors.textPrimary,
                  height: 1.35,
                  letterSpacing: -0.3,
                ),
              ),

              const Spacer(flex: 1),

              // Sitting Welsh Corgi Illustration with Bandana (Pixel-accurate artwork)
              const CorgiPortrait(
                state: DogState.waiting,
                size: CorgiPortraitSize.hero,
              ),

              const Spacer(flex: 2),

              // Primary CTA
              PrimaryButton(
                onPressed: () => context.go('/'),
                label: strings.startJourneyBtn,
              ),
              const SizedBox(height: 12),

              // Language Toggle Pill
              SecondaryButton(
                onPressed: () => ref.read(localeProvider.notifier).toggle(),
                icon: const Icon(
                  Icons.language_rounded,
                  size: 18,
                  color: StudyLoopColors.primary,
                ),
                label: strings.languageBtn,
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
    );
  }
}
