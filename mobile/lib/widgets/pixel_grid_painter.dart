import 'package:flutter/material.dart';

class PixelGridPainter extends CustomPainter {
  final Map<String, String> pixels;
  final int width;
  final int height;
  final bool showGrid;
  final Color gridColor;
  final Color backgroundColor;

  PixelGridPainter({
    required this.pixels,
    required this.width,
    required this.height,
    this.showGrid = false,
    this.gridColor = const Color(0xFF2E3A50),
    this.backgroundColor = Colors.white,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cellW = size.width / width;
    final cellH = size.height / height;

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = backgroundColor,
    );

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final key = '$x,$y';
        final colorHex = pixels[key];
        if (colorHex != null) {
          final paint = Paint()
            ..color = _hexToColor(colorHex)
            ..style = PaintingStyle.fill;
          canvas.drawRect(
            Rect.fromLTWH(x * cellW, y * cellH, cellW, cellH),
            paint,
          );
        }
      }
    }

    if (showGrid) {
      final gridPaint = Paint()
        ..color = gridColor
        ..strokeWidth = 0.5
        ..style = PaintingStyle.stroke;

      for (int x = 0; x <= width; x++) {
        canvas.drawLine(
          Offset(x * cellW, 0),
          Offset(x * cellW, size.height),
          gridPaint,
        );
      }
      for (int y = 0; y <= height; y++) {
        canvas.drawLine(
          Offset(0, y * cellH),
          Offset(size.width, y * cellH),
          gridPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(PixelGridPainter old) =>
      old.pixels != pixels || old.width != width || old.height != height;

  static Color _hexToColor(String hex) {
    try {
      String h = hex.replaceAll('#', '');
      if (h.length == 6) h = 'FF$h';
      return Color(int.parse(h, radix: 16));
    } catch (_) {
      return Colors.white;
    }
  }
}

class PixelArtDisplay extends StatelessWidget {
  final Map<String, String> pixels;
  final int width;
  final int height;
  final double? size;
  final bool showGrid;

  const PixelArtDisplay({
    super.key,
    required this.pixels,
    required this.width,
    required this.height,
    this.size,
    this.showGrid = false,
  });

  @override
  Widget build(BuildContext context) {
    final s = size ?? double.infinity;
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: s == double.infinity ? null : s,
        height: s == double.infinity ? null : s,
        child: AspectRatio(
          aspectRatio: width / height,
          child: CustomPaint(
            painter: PixelGridPainter(
              pixels: pixels,
              width: width,
              height: height,
              showGrid: showGrid,
            ),
          ),
        ),
      ),
    );
  }
}
