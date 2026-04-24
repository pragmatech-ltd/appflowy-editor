import 'package:flutter/material.dart';

class MobileMagnifier extends StatelessWidget {
  const MobileMagnifier({
    super.key,
    required this.size,
    required this.offset,
    this.focalPointOffsetFromBottom = 22.0,
    this.borderSide = BorderSide.none,
  });

  final Size size;
  final Offset offset;
  final double focalPointOffsetFromBottom;
  final BorderSide borderSide;

  @override
  Widget build(BuildContext context) {
    final clampedFocalPointOffsetFromBottom = focalPointOffsetFromBottom.clamp(
      0.0,
      size.height,
    );
    // the magnifier will blink if the center is the same as the offset.
    final magicOffset = Offset(
      0,
      size.height - clampedFocalPointOffsetFromBottom,
    );

    return Positioned.fromRect(
      rect: Rect.fromCenter(
        center: offset - magicOffset,
        width: size.width,
        height: size.height,
      ),
      child: IgnorePointer(
        child: _CustomMagnifier(
          size: size,
          additionalFocalPointOffset: magicOffset,
          borderSide: borderSide,
        ),
      ),
    );
  }
}

class _CustomMagnifier extends StatelessWidget {
  const _CustomMagnifier({
    this.additionalFocalPointOffset = Offset.zero,
    this.borderSide = BorderSide.none,
    required this.size,
  });

  final Size size;
  final Offset additionalFocalPointOffset;
  final BorderSide borderSide;

  @override
  Widget build(BuildContext context) {
    return RawMagnifier(
      decoration: MagnifierDecoration(
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.all(Radius.circular(40)),
          side: borderSide,
        ),
        shadows: const <BoxShadow>[
          BoxShadow(
            blurRadius: 1.5,
            offset: Offset(0, 2),
            spreadRadius: 0.75,
            color: Color.fromARGB(25, 0, 0, 0),
          ),
        ],
      ),
      magnificationScale: 1.25,
      focalPointOffset: additionalFocalPointOffset,
      size: size,
      child: const ColoredBox(
        color: Color.fromARGB(8, 158, 158, 158),
      ),
    );
  }
}
