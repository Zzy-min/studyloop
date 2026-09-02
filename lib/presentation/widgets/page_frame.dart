import 'package:flutter/material.dart';
import '../../domain/models.dart';
import '../theme/app_theme.dart';
import 'companion_card.dart';

class PageFrame extends StatelessWidget {
  const PageFrame({
    super.key,
    required this.title,
    this.subtitle,
    this.dogState,
    this.onBack,
    this.headerAction,
    this.bottomNavigationBar,
    required this.child,
  });

  final String title;
  final String? subtitle;
  final DogState? dogState;
  final VoidCallback? onBack;
  final Widget? headerAction;
  final Widget? bottomNavigationBar;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        leading: onBack == null
            ? null
            : IconButton(
                tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                onPressed: onBack,
                icon: const Icon(Icons.arrow_back_rounded),
              ),
        title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: headerAction != null
            ? [headerAction!, const SizedBox(width: 8)]
            : null,
      ),
      bottomNavigationBar: bottomNavigationBar,
      body: SafeArea(
        child: ListView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.manual,
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
          children: [
            if (subtitle != null) ...[
              Text(
                subtitle!,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
            ],
            if (dogState != null) DogCompanion(state: dogState!),
            child,
          ],
        ),
      ),
    );
  }
}
