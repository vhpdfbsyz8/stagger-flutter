import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stagger_flutter/stagger_flutter.dart';

Widget _harness({
  Object? runKey,
  Duration item = const Duration(milliseconds: 100),
  Duration gap = const Duration(milliseconds: 100),
  VoidCallback? onCompleted,
}) {
  return Directionality(
    textDirection: TextDirection.ltr,
    child: MediaQuery(
      data: const MediaQueryData(disableAnimations: false),
      child: StaggeredColumn(
        runKey: runKey,
        onCompleted: onCompleted,
        config: StaggerConfig(itemDuration: item, interval: gap),
        children: const [
          SizedBox(key: ValueKey('a'), width: 10, height: 10),
          SizedBox(key: ValueKey('b'), width: 10, height: 10),
          SizedBox(key: ValueKey('c'), width: 10, height: 10),
        ],
      ),
    ),
  );
}

double _opacity(WidgetTester tester, String key) {
  final fade = tester.widget<FadeTransition>(
    find.ancestor(
      of: find.byKey(ValueKey(key)),
      matching: find.byType(FadeTransition),
    ),
  );
  return fade.opacity.value;
}

void main() {
  testWidgets('reveals children in order and reports completion',
      (tester) async {
    var completed = 0;
    await tester.pumpWidget(_harness(onCompleted: () => completed++));

    expect(_opacity(tester, 'a'), 0);
    await tester.pump(const Duration(milliseconds: 150));
    expect(_opacity(tester, 'a'), 1);
    expect(_opacity(tester, 'b'), greaterThan(0));
    expect(_opacity(tester, 'c'), 0);

    await tester.pumpAndSettle();
    expect(_opacity(tester, 'c'), 1);
    expect(completed, 1);
  });

  testWidgets('new runKey replays from the start', (tester) async {
    await tester.pumpWidget(_harness(runKey: 'today'));
    await tester.pumpAndSettle();
    expect(_opacity(tester, 'a'), 1);

    await tester.pumpWidget(_harness(runKey: 'week'));
    await tester.pump();
    expect(_opacity(tester, 'a'), 0);
    await tester.pumpAndSettle();
    expect(_opacity(tester, 'c'), 1);
  });

  testWidgets('reduced motion jumps to the finished state', (tester) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: StaggeredColumn(
            children: const [Text('only')],
          ),
        ),
      ),
    );
    expect(
      tester.widget<FadeTransition>(find.byType(FadeTransition)).opacity.value,
      1,
    );
  });

  test('total duration covers the whole sequence', () {
    const config = StaggerConfig(
      itemDuration: Duration(milliseconds: 100),
      interval: Duration(milliseconds: 40),
    );
    expect(config.totalDuration(3), const Duration(milliseconds: 180));
    expect(config.totalDuration(0), const Duration(milliseconds: 100));
  });
}
