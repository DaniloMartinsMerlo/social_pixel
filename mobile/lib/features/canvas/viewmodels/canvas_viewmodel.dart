import 'package:flutter/foundation.dart';

import 'package:mobile/core/storage/local_storage.dart';
import 'package:mobile/features/canvas/models/pixel_model.dart';
import 'package:mobile/features/canvas/repositories/canvas_repository.dart';
import 'package:mobile/features/feed/models/artwork_model.dart';

class CanvasViewModel extends ChangeNotifier {
  CanvasViewModel({CanvasRepository? canvasRepository, LocalStorage? localStorage})
      : _canvasRepository = canvasRepository ?? const CanvasRepository(),
        _localStorage = localStorage ?? const LocalStorage();

  final CanvasRepository _canvasRepository;
  final LocalStorage _localStorage;

  String selectedColor = '#1E4F4F';
  int width = 16;
  int height = 16;
  String title = 'Untitled pixel art';
  final Map<String, String> pixels = <String, String>{};
  bool isSubmitting = false;
  String? errorMessage;

  void setColor(String color) {
    selectedColor = color;
    notifyListeners();
  }

  void setCanvasSize(int newWidth, int newHeight) {
    width = newWidth;
    height = newHeight;
    pixels.removeWhere((key, value) {
      final parts = key.split(',');
      final x = int.tryParse(parts[0]) ?? 0;
      final y = int.tryParse(parts[1]) ?? 0;
      return x >= newWidth || y >= newHeight;
    });
    notifyListeners();
  }

  void setTitle(String newTitle) {
    title = newTitle;
    notifyListeners();
  }

  void paintPixel(int x, int y) {
    final pixel = PixelModel(x: x, y: y, color: selectedColor);
    pixels.addAll(pixel.toMapEntry());
    notifyListeners();
  }

  void erasePixel(int x, int y) {
    pixels.remove('$x,$y');
    notifyListeners();
  }

  Future<ArtworkModel?> submitCanvas() async {
    isSubmitting = true;
    errorMessage = null;
    notifyListeners();

    try {
      final userId = await _requireUserId();
      return await _canvasRepository.createArtwork(
        userId: userId,
        title: title,
        width: width,
        height: height,
        pixels: pixels,
      );
    } catch (error) {
      errorMessage = error.toString();
      return null;
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }

  Future<String> _requireUserId() async {
    final userId = await _localStorage.getUserId();
    if (userId == null || userId.isEmpty) {
      throw StateError('No user session found');
    }
    return userId;
  }
}