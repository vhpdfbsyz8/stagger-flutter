# stagger_flutter

Staggered list reveals for Flutter: fade and slide a short list of widgets in
one after another, with declarative timing instead of a hand-rolled
`AnimationController` per row.

Most "list entrance" code in real apps is the same 20 lines copied around — one
controller, one `Interval` per index, a `StatusListener` to fire analytics after
the last row. This package keeps that timing math in one place, driven by a
single controller, and adds the two things the copy-paste version always misses:
reduced-motion support and a cheap way to replay.

```dart
// demo placeholder
// ![Staggered reveal of six transaction rows](doc/preview.gif)
```

## Why

- **One controller, not N.** `StaggerConfig.window` slices the timeline per item,
  so widgets stay stateless and rebuild once per frame.
- **Correct reverse timings.** Replay with `reverse: true` plays the last item
  first and uses `reverseCurve`, so lists do not unwind backwards on screen.
- **Reduced motion built in.** When the platform reports `disableAnimations`,
  the sequence jumps to its end state instead of half-animating.
- **Accessible taps.** Items are mounted and hit-testable from frame one; only
  opacity and offset change.

## Install

```yaml
dependencies:
  stagger_flutter:
    git:
      url: https://github.com/vhpdfbsyz8/stagger-flutter.git
      ref: main
```

Requires Flutter 3.22 or newer and Dart 3.4 (uses `MediaQuery.maybeDisableAnimationsOf`).

## Usage

```dart
import 'package:stagger_flutter/stagger_flutter.dart';

class ActivityList extends StatelessWidget {
  const ActivityList({super.key, required this.entries, required this.filterChanged});

  final List<ActivityEntry> entries;
  final Object filterChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: StaggeredColumn(
        runKey: filterChanged, // replay when the filter changes
        config: const StaggerConfig(
          itemDuration: Duration(milliseconds: 280),
          interval: Duration(milliseconds: 35),
        ),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [for (final entry in entries) EntryTile(entry)],
      ),
    );
  }
}
```

Custom transition with `itemBuilder`:

```dart
StaggeredColumn(
  children: tiles,
  itemBuilder: (context, animation, child) => ScaleTransition(
    scale: Tween<double>(begin: 0.94, end: 1).animate(animation),
    child: child,
  ),
)
```

## API

- `StaggerConfig` — `itemDuration`, `interval`, `curve`, `reverseCurve`,
  `slideOffset`. `totalDuration(count)` reports the full run time, `window(parent,
  index, count)` returns the item's slice as an `Animation<double>`.
- `StaggeredColumn` — a `Column` plus `runKey`, `reverse`, `onCompleted`,
  `respectReducedMotion` and `itemBuilder`.
- `StaggerItem` — the default fade + slide wrapper, exported for reuse.

Keep sequences under roughly 20 items; past that the tail waits too long and the
first rows are off screen anyway. For long feeds animate the visible window only.

## Platform notes

- Works on Android, iOS, web, macOS and Windows; no platform channels.
- On web the slide is subpixel — `RepaintBoundary` around the column helps.
- With `respectReducedMotion: false` the sequence always plays, use that only
  where the animation carries meaning (progress, ordering).

## Layout

```
lib/stagger_flutter.dart          public exports
lib/src/stagger_config.dart       timing math and curves
lib/src/stagger_item.dart         default fade + slide wrapper
lib/src/staggered_column.dart     controller and replay logic
test/                             widget tests
```

Run the tests with `flutter test`.

## License

MIT, see [LICENSE](LICENSE).
