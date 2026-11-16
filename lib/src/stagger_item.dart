import 'package:flutter/widgets.dart';

/// Applies a fade and slide to one entry of a [StaggeredColumn].
///
/// Pass your own [itemBuilder] to [StaggeredColumn] when you need a different
/// transition, for example a scale.
class StaggerItem extends StatelessWidget {
  const StaggerItem({
    super.key,
    required this.animation,
    required this.offset,
    required this.child,
  });

  /// Drives the transition; usually produced by [StaggerConfig.window].
  final Animation<double> animation;

  /// Slide start point, in fractions of the child size.
  final Offset offset;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(begin: offset, end: Offset.zero)
            .animate(animation),
        child: child,
      ),
    );
  }
}
