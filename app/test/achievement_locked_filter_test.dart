import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_forge_app/core/achievements/achievement_catalog.dart';

/// Regression test for "the whole achievements grid turned into a solid #9C9588
/// slab" (found on a real device, Android 17).
///
/// The locked-achievement icon used to be desaturated with
/// `ColorFilter.mode(Color(0xFF9C9588), BlendMode.saturation)`. A blend-mode
/// filter paints through a `saveLayer` whose bounds are the canvas **clip**, so
/// it tints every pixel in that clip — including the transparent ones between
/// cards. Blending an opaque colour onto transparent pixels yields that colour,
/// which is why the grid viewport came back as #9C9588 (sampled pixel-for-pixel
/// from the device screenshot) while the cards themselves vanished behind it.
///
/// The matrix filter keeps alpha, so empty stays empty. These tests pin both
/// halves: no bleed, and the artwork still visibly desaturates.
void main() {
  testWidgets('the locked filter paints nothing where nothing was drawn', (tester) async {
    final probe = await _renderProbe(
      tester,
      colorFilter: AchievementCatalog.lockedFilter,
      child: const SizedBox(width: 24, height: 24),
    );

    expect(
      _pixelAt(probe, 100, 100).a,
      0,
      reason: 'a transparent area inside the filtered clip must stay transparent',
    );
    expect(_pixelAt(probe, 100, 100), const Color(0x00000000));
  });

  testWidgets('the locked filter still desaturates the artwork it wraps', (tester) async {
    final probe = await _renderProbe(
      tester,
      colorFilter: AchievementCatalog.lockedFilter,
      child: const SizedBox(
        width: 24,
        height: 24,
        child: ColoredBox(color: Color(0xFFFF0000)),
      ),
    );

    final inside = _pixelAt(probe, 8, 8);
    expect(inside.a, 255, reason: 'opaque artwork stays opaque');
    expect(inside.r, closeTo(inside.g, 2), reason: 'red must come back grey');
    expect(inside.g, closeTo(inside.b, 2));
  });
}

const Key _probeKey = ValueKey('filter-probe');
const double _probeSize = 120;

Future<({ByteData data, int width})> _renderProbe(
  WidgetTester tester, {
  required ColorFilter colorFilter,
  required Widget child,
}) async {
  await tester.pumpWidget(
    Directionality(
      textDirection: TextDirection.ltr,
      child: Center(
        child: RepaintBoundary(
          key: _probeKey,
          child: SizedBox(
            width: _probeSize,
            height: _probeSize,
            child: Align(
              alignment: Alignment.topLeft,
              child: ColorFiltered(colorFilter: colorFilter, child: child),
            ),
          ),
        ),
      ),
    ),
  );

  final boundary = tester.renderObject<RenderRepaintBoundary>(find.byKey(_probeKey));
  late ByteData data;
  late int width;
  await tester.runAsync(() async {
    final image = await boundary.toImage(pixelRatio: 1);
    width = image.width;
    data = (await image.toByteData(format: ui.ImageByteFormat.rawRgba))!;
    image.dispose();
  });
  return (data: data, width: width);
}

Color _pixelAt(({ByteData data, int width}) probe, int x, int y) {
  final px = x.clamp(0, probe.width - 1);
  final py = y.clamp(0, probe.width - 1);
  final i = (py * probe.width + px) * 4;
  return Color.fromARGB(
    probe.data.getUint8(i + 3),
    probe.data.getUint8(i),
    probe.data.getUint8(i + 1),
    probe.data.getUint8(i + 2),
  );
}
