import 'package:flutter/widgets.dart';

import 'stagger_config.dart';
import 'stagger_item.dart';

/// A [Column] whose children fade and slide in one after another.
///
/// The sequence plays once when the widget is first built, and replays whenever
/// [runKey] changes identity:
///
/// ```dart
/// StaggeredColumn(
///   runKey: selectedFilter,
///   config: const StaggerConfig(interval: Duration(milliseconds: 40)),
///   children: rows.map(RowTile.new).toList(),
/// )
/// ```
///
/// Each child stays in the tree for the whole sequence, so taps work as soon as
/// an item is visible. Set [respectReducedMotion] to false to always animate,
/// otherwise the platform "disable animations" flag jumps straight to the end.
class StaggeredColumn extends StatefulWidget {
  const StaggeredColumn({
    super.key,
    required this.children,
    this.config = const StaggerConfig(),
    this.runKey,
    this.reverse = false,
    this.respectReducedMotion = true,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.mainAxisSize = MainAxisSize.max,
    this.textDirection,
    this.verticalDirection = VerticalDirection.down,
    this.onCompleted,
    this.itemBuilder,
  });

  final List<Widget> children;
  final StaggerConfig config;

  /// Identity that restarts the sequence when it changes.
  final Object? runKey;

  /// When true the sequence plays backwards from the end on replay.
  final bool reverse;

  final bool respectReducedMotion;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisSize mainAxisSize;
  final TextDirection? textDirection;
  final VerticalDirection verticalDirection;
  final VoidCallback? onCompleted;

  /// Builds the per-item transition. The animation follows the item window.
  final Widget Function(BuildContext context, Animation<double> animation,
      Widget child)? itemBuilder;

  @override
  State<StaggeredColumn> createState() => _StaggeredColumnState();
}

class _StaggeredColumnState extends State<StaggeredColumn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.config.totalDuration(widget.children.length),
  )..addStatusListener(_handleStatus);

  bool _played = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_played) return;
    _played = true;
    final reduceMotion = widget.respectReducedMotion &&
        MediaQuery.maybeDisableAnimationsOf(context) == true;
    if (reduceMotion) {
      _controller.value = 1;
      widget.onCompleted?.call();
    } else {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(StaggeredColumn oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.children.length != widget.children.length ||
        oldWidget.config != widget.config) {
      _controller.duration =
          widget.config.totalDuration(widget.children.length);
    }
    if (oldWidget.runKey != widget.runKey) {
      _controller.value = 0;
      if (widget.reverse) {
        _controller.reverse(from: 1);
      } else {
        _controller.forward();
      }
    }
  }

  void _handleStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) widget.onCompleted?.call();
  }

  @override
  void dispose() {
    _controller
      ..removeStatusListener(_handleStatus)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final count = widget.children.length;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final items = <Widget>[];
        for (var i = 0; i < count; i++) {
          final animation = widget.config.window(_controller, i, count);
          final child = widget.children[i];
          items.add(
            widget.itemBuilder?.call(context, animation, child) ??
                StaggerItem(
                  key: ValueKey<int>(i),
                  animation: animation,
                  offset: widget.config.slideOffset,
                  child: child,
                ),
          );
        }
        return Column(
          mainAxisAlignment: widget.mainAxisAlignment,
          crossAxisAlignment: widget.crossAxisAlignment,
          mainAxisSize: widget.mainAxisSize,
          textDirection: widget.textDirection,
          verticalDirection: widget.verticalDirection,
          children: items,
        );
      },
    );
  }
}
