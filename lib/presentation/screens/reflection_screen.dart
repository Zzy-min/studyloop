import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/ime_helper.dart';

import '../../domain/models.dart';
import '../../providers.dart';
import '../theme/app_theme.dart';
import '../view_models/ai_companion_controller.dart';
import '../widgets/page_frame.dart';
import '../widgets/rating_pill.dart';

class ReflectionScreen extends ConsumerStatefulWidget {
  const ReflectionScreen({super.key});

  @override
  ConsumerState<ReflectionScreen> createState() => _ReflectionScreenState();
}

class _ReflectionScreenState extends ConsumerState<ReflectionScreen> {
  int difficulty = 3;
  int focus = 3;
  MoodChange mood = MoodChange.unchanged;
  bool _isSaving = false;
  String? _corgiFeedback;
  bool _isReflectingWithCorgi = false;
  late final TextEditingController nextActionController;

  @override
  void initState() {
    super.initState();
    nextActionController = TextEditingController();
  }

  @override
  void dispose() {
    nextActionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final timer = ref.watch(timerProvider);
    final strings = ref.watch(stringsProvider);
    final snapshot = timer.snapshot;

    if (snapshot == null) {
      return PageFrame(
        title: strings.reflectionTitle,
        child: Column(
          children: [
            Text(strings.noActiveSession),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => context.go('/'),
              child: Text(strings.returnHome),
            ),
          ],
        ),
      );
    }

    final isCompleted = timer.outcome == SessionOutcome.completed;

    return PageFrame(
      title: strings.reflectionTitle,
      subtitle: strings.reflectionSummary(
        snapshot.accumulatedSeconds,
        isCompleted,
      ),
      dogState: isCompleted ? DogState.completed : DogState.interrupted,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Difficulty
          Text(
            strings.actualDifficultyLabel,
            style: const TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          RatingPillGroup(
            value: difficulty,
            isDifficulty: true,
            onChanged: (v) => setState(() => difficulty = v),
          ),
          const SizedBox(height: 20),

          // Focus Level
          Text(
            strings.focusLevelLabel,
            style: const TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          RatingPillGroup(
            value: focus,
            isDifficulty: false,
            onChanged: (v) => setState(() => focus = v),
          ),
          const SizedBox(height: 20),

          // Mood Change
          Text(
            strings.emotionalChangeLabel,
            style: const TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _MoodChip(
                label: strings.moodMoreAtEase,
                icon: Icons.sentiment_very_satisfied_rounded,
                isSelected: mood == MoodChange.moreAtEase,
                onTap: () => setState(() => mood = MoodChange.moreAtEase),
              ),
              const SizedBox(width: 8),
              _MoodChip(
                label: strings.moodUnchanged,
                icon: Icons.sentiment_neutral_rounded,
                isSelected: mood == MoodChange.unchanged,
                onTap: () => setState(() => mood = MoodChange.unchanged),
              ),
              const SizedBox(width: 8),
              _MoodChip(
                label: strings.moodWorse,
                icon: Icons.sentiment_dissatisfied_rounded,
                isSelected: mood == MoodChange.worse,
                onTap: () => setState(() => mood = MoodChange.worse),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Next Action
          Text(
            strings.nextActionLabel,
            style: const TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: nextActionController,
            keyboardType: TextInputType.text,
            enableInteractiveSelection: true,
            onTap: () {
              ImeHelper.showSoftInput();
            },
            decoration: InputDecoration(
              hintText: strings.nextActionHint,
              prefixIcon: const Icon(
                Icons.bolt_rounded,
                color: AppTheme.primaryColor,
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildCorgiReflectionCard(context, snapshot.accumulatedSeconds),
          const SizedBox(height: 20),

          FilledButton(
            onPressed: _isSaving
                ? null
                : () => _saveReflection(
                    difficulty: difficulty,
                    focus: focus,
                    mood: mood,
                    nextAction: nextActionController.text.trim(),
                  ),
            child: _isSaving
                ? const SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(strings.saveReflectionBtn),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: _isSaving
                ? null
                : () => _saveReflection(
                    difficulty: null,
                    focus: null,
                    mood: null,
                    nextAction: '',
                  ),
            child: Text(strings.skipReflectionBtn),
          ),
        ],
      ),
    );
  }

  Widget _buildCorgiReflectionCard(BuildContext context, int accumulatedSeconds) {
    final actualMinutes = accumulatedSeconds ~/ 60;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFBBF7D0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.pets_rounded,
                size: 16,
                color: Color(0xFF16A34A),
              ),
              const SizedBox(width: 6),
              const Expanded(
                child: Text(
                  '柯基陪伴复盘 (AI 温暖复盘)',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF15803D),
                  ),
                ),
              ),
              if (_corgiFeedback == null && !_isReflectingWithCorgi)
                InkWell(
                  onTap: () async {
                    setState(() => _isReflectingWithCorgi = true);
                    final reply = await ref
                        .read(aiCompanionControllerProvider.notifier)
                        .reflectWithCorgi(
                          nextActionController.text.trim(),
                          actualMinutes,
                        );
                    if (mounted) {
                      setState(() {
                        _isReflectingWithCorgi = false;
                        _corgiFeedback = reply;
                      });
                    }
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF16A34A),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.auto_awesome_rounded,
                          size: 12,
                          color: Colors.white,
                        ),
                        SizedBox(width: 4),
                        Text(
                          '让柯基说说',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          if (_isReflectingWithCorgi)
            const Row(
              children: [
                SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFF16A34A),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  '柯基正在为你准备温暖复盘...',
                  style: TextStyle(fontSize: 12, color: Color(0xFF166534)),
                ),
              ],
            )
          else
            Text(
              _corgiFeedback ??
                  '本次实际专注了 $actualMinutes 分钟。每一次跨出第一步都算数，随时点击“让柯基说说”听听鼓励！',
              style: const TextStyle(
                fontSize: 12.5,
                height: 1.45,
                color: Color(0xFF166534),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _saveReflection({
    int? difficulty,
    int? focus,
    MoodChange? mood,
    required String nextAction,
  }) async {
    if (_isSaving) return;
    setState(() => _isSaving = true);
    try {
      await commitReflection(
        ref: ref,
        difficulty: difficulty,
        focus: focus,
        mood: mood,
        nextAction: nextAction,
      );
      if (mounted) context.go('/summary');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}

class _MoodChip extends StatelessWidget {
  const _MoodChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: isSelected ? AppTheme.primaryLight : Colors.white,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected
                    ? AppTheme.primaryColor
                    : AppTheme.cardBorderColor,
                width: isSelected ? 1.8 : 1.2,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  icon,
                  color: isSelected
                      ? AppTheme.primaryColor
                      : AppTheme.textSecondary,
                  size: 24,
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected
                        ? AppTheme.primaryColor
                        : AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
