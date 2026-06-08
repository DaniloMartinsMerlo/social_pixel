class PixelModel {
  const PixelModel({
    required this.x,
    required this.y,
    required this.color,
  });

  final int x;
  final int y;
  final String color;

  String get key => '$x,$y';

  Map<String, String> toMapEntry() => {key: color};
}