import 'package:flutter/material.dart';

class PixelGrid extends StatelessWidget {
  const PixelGrid({
    super.key,
    required this.width,
    required this.height,
    required this.pixels,
    required this.selectedColor,
    this.readOnly = false,
    this.onPixelTap,
  });

  final int width;
  final int height;
  final Map<String, String> pixels;
  final String selectedColor;
  final bool readOnly;
  final void Function(int x, int y)? onPixelTap;

  @override
  Widget build(BuildContext context) {
    final aspectRatio = width / height;

    return AspectRatio(
      aspectRatio: aspectRatio,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE5DED4)),
        ),
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: width,
          ),
          itemCount: width * height,
          itemBuilder: (context, index) {
            final x = index % width;
            final y = index ~/ width;
            final color = pixels['$x,$y'];
            return GestureDetector(
              onTap: readOnly ? null : () => onPixelTap?.call(x, y),
              child: Container(
                decoration: BoxDecoration(
                  color: color == null ? Colors.transparent : _parseColor(color),
                  border: Border.all(color: const Color(0xFFE5DED4), width: 0.4),
                ),
                child: color == null && !readOnly && selectedColor.isNotEmpty
                    ? const SizedBox.shrink()
                    : null,
              ),
            );
          },
        ),
      ),
    );
  }

  Color _parseColor(String value) {
    final cleaned = value.replaceFirst('#', '');
    final normalized = cleaned.length == 6 ? 'FF$cleaned' : cleaned;
    return Color(int.parse(normalized, radix: 16));
  }
}