import 'package:flutter/material.dart';

import '../../domain/models.dart';

enum CorgiPortraitSize { avatar, compact, medium, hero, timer }

class CorgiPortrait extends StatelessWidget {
  const CorgiPortrait({
    super.key,
    required this.state,
    this.size = CorgiPortraitSize.medium,
    this.semanticLabel,
  });

  final DogState state;
  final CorgiPortraitSize size;
  final String? semanticLabel;

  static String assetFor(DogState state) {
    return switch (state) {
      DogState.focusing => 'assets/images/corgi_focus.png',
      DogState.waiting => 'assets/images/corgi_welcome.png',
      DogState.prompting => 'assets/images/corgi_welcome.png',
      DogState.completed => 'assets/images/corgi_welcome.png',
      DogState.interrupted => 'assets/images/corgi_resting.png',
      DogState.resting => 'assets/images/corgi_resting.png',
    };
  }

  Size get _box => switch (size) {
    CorgiPortraitSize.avatar => const Size(36, 36),
    CorgiPortraitSize.compact => const Size(28, 28),
    CorgiPortraitSize.medium => const Size(112, 104),
    CorgiPortraitSize.hero => const Size(240, 250),
    CorgiPortraitSize.timer => const Size(130, 124),
  };

  @override
  Widget build(BuildContext context) {
    final box = _box;
    return Semantics(
      label: semanticLabel,
      image: true,
      child: SizedBox(
        width: box.width,
        height: box.height,
        child: Image.asset(
          assetFor(state),
          width: box.width,
          height: box.height,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.high,
          gaplessPlayback: true,
        ),
      ),
    );
  }
}
