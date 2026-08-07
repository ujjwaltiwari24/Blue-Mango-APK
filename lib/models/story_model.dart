class StoryModel {
  const StoryModel({
    required this.id,
    required this.seed,
    required this.viewed,
    this.isOwn = false,
  });

  final String id;

  /// Seed used to derive this story's anonymous alias/avatar gradient —
  /// never a real user identifier surfaced elsewhere.
  final String seed;
  final bool viewed;
  final bool isOwn;
}