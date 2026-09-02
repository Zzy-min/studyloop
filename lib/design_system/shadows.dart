import 'package:flutter/material.dart';

abstract final class StudyLoopShadows {
  static const List<BoxShadow> subtle = [
    BoxShadow(color: Color(0x08000000), blurRadius: 10, offset: Offset(0, 3)),
  ];

  static const List<BoxShadow> card = [
    BoxShadow(color: Color(0x06000000), blurRadius: 12, offset: Offset(0, 4)),
  ];

  static const List<BoxShadow> floating = [
    BoxShadow(color: Color(0x10000000), blurRadius: 20, offset: Offset(0, 8)),
  ];
}
