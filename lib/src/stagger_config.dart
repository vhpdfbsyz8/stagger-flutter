import 'package:flutter/animation.dart';

/// Timing description for a staggered reveal.
///
/// The reveal of item `i` starts at `i * interval` and takes [itemDuration],
/// so the whole sequence runs for `totalDuration(count)`.
@immutable
class StaggerConfig {
  const StaggerConfig({
    this.itemDuration = const Duration(milliseconds: 320),
    this.interval = const Duration(milliseconds: 55),
    this.curve = Curves.easeOutCubic,
    this.reverseCurve = Curves.easeInCubic,
    this.slideOffset = const Offset(0, 0.06),
  })  : assert(itemDuration > Duration.zero, 'itemDuration must be positive'),
        assert(interval >= Duration.zero, 'interval must not be negative');

  /// How long a single item takes to fade and slide in.
  final Duration itemDuration;

  /// Gap between the start of one item and the start of the next.
  final Duration interval;

  /// Curve applied while the sequence plays forward.
  final Curve curve;

  /// Curve applied while the sequence plays in reverse.
  final Curve reverseCurve;

  /// Start offset of an item, in fractions of its own size.
  final Offset slideOffset;

  /// Wall-clock length of revealing [count] items.
  Duration totalDuration(int count) {
    if (count <= 1) return itemDuration;
    return itemDuration + interval * (count - 1);
  }

  /// Maps [parent] onto the slice of the timeline that belongs to [index].
  ///
  /// The returned animation is 0 before its slice and 1 after it, which lets
  /// every item drive a plain [FadeTransition] without bookkeeping.
  Animation<double> window(Animation<double> parent, int index, int count) {
    final total = totalDuration(count).inMicroseconds;
    final start = interval.inMicroseconds * index;
    final begin = (start / total).clamp(0.0, 1.0);
    final end = ((start + itemDuration.inMicroseconds) / total).clamp(begin, 1.0);
    return CurvedAnimation(
      parent: parent,
      curve: Interval(begin, end, curve: curve),
      reverseCurve: Interval(begin, end, curve: reverseCurve),
    );
  }

  StaggerConfig copyWith({
    Duration? itemDuration,
    Duration? interval,
    Curve? curve,
    Curve? reverseCurve,
    Offset? slideOffset,
  }) {
    return StaggerConfig(
      itemDuration: itemDuration ?? this.itemDuration,
      interval: interval ?? this.interval,
      curve: curve ?? this.curve,
      reverseCurve: reverseCurve ?? this.reverseCurve,
      slideOffset: slideOffset ?? this.slideOffset,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is StaggerConfig &&
        other.itemDuration == itemDuration &&
        other.interval == interval &&
        other.curve == curve &&
        other.reverseCurve == reverseCurve &&
        other.slideOffset == slideOffset;
  }

  @override
  int get hashCode =>
      Object.hash(itemDuration, interval, curve, reverseCurve, slideOffset);

  @override
  String toString() => 'StaggerConfig(itemDuration: $itemDuration, '
      'interval: $interval, curve: $curve, slideOffset: $slideOffset)';
}
