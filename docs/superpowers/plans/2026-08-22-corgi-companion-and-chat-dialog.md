# Plan: Authentic Corgi Companion & Interactive Chat Dialog

## Phase 1: High-Fidelity Corgi Vector Assets
1. Generate assets/dog_svg/waiting.svg (Alert, smiling Corgi).
2. Generate assets/dog_svg/prompting.svg (Curious, head-tilted Corgi).
3. Generate assets/dog_svg/focusing.svg (Peaceful, companion sphinx Corgi).
4. Generate assets/dog_svg/completed.svg (Celebratory happy Corgi with tongue out).
5. Generate assets/dog_svg/interrupted.svg (Empathetic, comforting Corgi).
6. Generate assets/dog_svg/resting.svg (Curled up sleeping Corgi).

## Phase 2: Domain Engine & Localization
1. Create lib/domain/corgi_chat_engine.dart with CorgiChatMessage and response matching.
2. Update lib/l10n/app_strings.dart with chat copy, hints, and preset prompt chips.

## Phase 3: Presentation & Interaction
1. Create lib/presentation/widgets/corgi_chat_dialog.dart.
2. Update lib/presentation/widgets/companion_card.dart to be tappable and show chat badge.
3. Clean up lib/presentation/screens/task_screen.dart and reflection_screen.dart keyboard evoking.

## Phase 4: Automated Verification
1. Create test/domain/corgi_chat_engine_test.dart.
2. Create test/presentation/corgi_chat_dialog_test.dart.
3. Run flutter analyze and flutter test.

## Phase 5: Physical Device Verification
1. Build debug APK and install on Vivo device.
2. Verify Corgi appearance across all screens.
3. Verify chat dialog evoking and interactions on real device.
4. Verify text input keyboard popup.
