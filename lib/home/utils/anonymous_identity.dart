import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// Generates a stable, privacy-safe display identity (alias + gradient
/// avatar) from any seed string (e.g. a Firebase uid or post id).
/// Never derive this from a real name/email — the seed only needs to
/// be *consistent*, not personally identifiable.
class AnonymousIdentity {
  AnonymousIdentity._();

  static const List<String> _adjectives = [
    'Quiet', 'Curious', 'Hidden', 'Gentle', 'Bold',
    'Calm', 'Wandering', 'Silent', 'Bright', 'Lone',
  ];

  static const List<String> _nouns = [
    'Falcon', 'Fox', 'Willow', 'Comet', 'Harbor',
    'Maple', 'Ember', 'Otter', 'Lynx', 'Cedar',
  ];

  static int _hash(String seed) => seed.codeUnits.fold(0, (a, b) => a + b);

  static String aliasFor(String seed) {
    final h = _hash(seed);
    final adjective = _adjectives[h % _adjectives.length];
    final noun = _nouns[(h ~/ 7) % _nouns.length];
    return '$adjective $noun';
  }

  static List<Color> gradientFor(String seed) {
    final h = _hash(seed);
    return AppColors.identityGradients[h % AppColors.identityGradients.length];
  }

  static String initialFor(String seed) => aliasFor(seed)[0];
}