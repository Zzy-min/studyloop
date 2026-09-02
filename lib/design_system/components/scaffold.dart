import 'package:flutter/material.dart';
import '../colors.dart';

class StudyLoopScaffold extends StatelessWidget {
  const StudyLoopScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.bottomNavigationBar,
    this.backgroundColor = StudyLoopColors.background,
    this.safeAreaTop = true,
    this.safeAreaBottom = true,
  });

  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;
  final Color backgroundColor;
  final bool safeAreaTop;
  final bool safeAreaBottom;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: appBar,
      body: SafeArea(top: safeAreaTop, bottom: safeAreaBottom, child: body),
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}
