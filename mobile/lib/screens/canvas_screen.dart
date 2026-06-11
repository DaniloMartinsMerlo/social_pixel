import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:async';
import '../services/api_service.dart';
import '../theme.dart';
import '../widgets/pixel_grid_painter.dart';

class CanvasScreen extends StatefulWidget {
  final String userId;
  const CanvasScreen({super.key, required this.userId});

  @override
  State<CanvasScreen> createState() => _CanvasScreenState();
}

class _CanvasScreenState extends State<CanvasScreen> {
  static const List<int> _sizes = [12, 16, 24, 32, 48, 64];

  int _gridSize = 16;
  Color _selectedColor = const Color(0xFF7C3AED);
  Map<String, String> _pixels = {};
  bool _publishing = false;
  final _titleCtrl = TextEditingController();

  final List<Map<String, String>> _history = [];
  final List<Map<String, String>> _redoStack = [];

  StreamSubscription? _shakeSub;
  DateTime? _lastShake;

  @override
  void initState() {
    super.initState();
    _listenShake();
  }

  void _listenShake() {
    _shakeSub = accelerometerEventStream().listen((event) {
      final magnitude = event.x.abs() + event.y.abs() + event.z.abs();
      if (magnitude > 100) {
        final now = DateTime.now();
        if (_lastShake == null ||
            now.difference(_lastShake!) > const Duration(seconds: 2)) {
          _lastShake = now;
          _confirmClear();
        }
      }
    });
  }

  void _confirmClear() {
    if (_pixels.isEmpty) return;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Apagar tudo?',
            style: TextStyle(color: AppColors.textPrimary)),
        content: const Text('Chacoalhar apagou o canvas. Confirma?',
            style: TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _clearCanvas();
            },
            child: const Text('Apagar'),
          ),
        ],
      ),
    );
  }

  void _saveHistory() {
    _history.add(Map.from(_pixels));
    if (_history.length > 50) _history.removeAt(0);
  }

  void _paintPixel(Offset localPos, Size canvasSize) {
    final cellSize = canvasSize.width / _gridSize;
    final x = (localPos.dx / cellSize).floor();
    final y = (localPos.dy / cellSize).floor();
    if (x < 0 || x >= _gridSize || y < 0 || y >= _gridSize) return;
    final key = '$x,$y';
    final hex = _colorToHex(_selectedColor);
    if (_pixels[key] == hex) return;
    _saveHistory();
    _redoStack.clear();
    setState(() => _pixels[key] = hex);
  }

  void _undo() {
    if (_history.isEmpty) return;
    _redoStack.add(Map.from(_pixels));
    setState(() => _pixels = _history.removeLast());
  }

  void _redo() {
    if (_redoStack.isEmpty) return;
    _history.add(Map.from(_pixels));
    setState(() => _pixels = _redoStack.removeLast());
  }

  void _clearCanvas() {
    _saveHistory();
    _redoStack.clear();
    setState(() => _pixels = {});
  }

  void _changeGridSize(int size) {
    _history.clear();
    _redoStack.clear();
    setState(() {
      _gridSize = size;
      _pixels = {};
    });
  }

  String _colorToHex(Color c) =>
      '#${c.red.toRadixString(16).padLeft(2, '0')}${c.green.toRadixString(16).padLeft(2, '0')}${c.blue.toRadixString(16).padLeft(2, '0')}';

  Future<void> _openColorPicker() async {
    Color temp = _selectedColor;
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Escolher cor',
            style: TextStyle(color: AppColors.textPrimary)),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: temp,
            onColorChanged: (c) => temp = c,
            pickerAreaHeightPercent: 0.7,
            hexInputBar: true,
            labelTypes: const [],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() => _selectedColor = temp);
              Navigator.of(context).pop();
            },
            child: const Text('OK',
                style: TextStyle(color: AppColors.primaryLight)),
          ),
        ],
      ),
    );
  }

  Future<void> _publish() async {
    if (_pixels.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pinte pelo menos um pixel antes de publicar.'),
          backgroundColor: AppColors.surface,
        ),
      );
      return;
    }
    _titleCtrl.clear();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Título da arte',
            style: TextStyle(color: AppColors.textPrimary)),
        content: TextField(
          controller: _titleCtrl,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: const InputDecoration(hintText: 'Ex: Minha pixel art'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Publicar',
                style: TextStyle(color: AppColors.primaryLight)),
          ),
        ],
      ),
    );

    if (confirmed != true || _titleCtrl.text.trim().isEmpty) return;

    setState(() => _publishing = true);
    try {
      final api = ApiService(userId: widget.userId);
      await api.createArtwork(
        title: _titleCtrl.text.trim(),
        width: _gridSize,
        height: _gridSize,
        pixels: _pixels,
      );
      if (!mounted) return;
      _history.clear();
      _redoStack.clear();
      setState(() => _pixels = {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Arte publicada!'),
          backgroundColor: AppColors.primary,
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro: $e'),
            backgroundColor: AppColors.like,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _publishing = false);
    }
  }

  @override
  void dispose() {
    _shakeSub?.cancel();
    _titleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  const Text(
                    'Nova pixel art',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: _gridSize,
                        dropdownColor: AppColors.surface,
                        style: const TextStyle(
                            color: AppColors.textPrimary, fontSize: 14),
                        items: _sizes
                            .map((s) => DropdownMenuItem(
                                  value: s,
                                  child: Text('${s}x$s'),
                                ))
                            .toList(),
                        onChanged: (v) {
                          if (v != null) _changeGridSize(v);
                        },
                      ),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: _history.isEmpty ? null : _undo,
                    icon: const Icon(Icons.undo),
                    color: AppColors.textPrimary,
                    disabledColor: AppColors.border,
                    tooltip: 'Desfazer',
                  ),
                  IconButton(
                    onPressed: _redoStack.isEmpty ? null : _redo,
                    icon: const Icon(Icons.redo),
                    color: AppColors.textPrimary,
                    disabledColor: AppColors.border,
                    tooltip: 'Refazer',
                  ),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: _openColorPicker,
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: _selectedColor,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: _selectedColor.withOpacity(0.5),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: LayoutBuilder(
                  builder: (_, constraints) {
                    final side = constraints.maxWidth;
                    return GestureDetector(
                      onPanStart: (d) =>
                          _paintPixel(d.localPosition, Size(side, side)),
                      onPanUpdate: (d) =>
                          _paintPixel(d.localPosition, Size(side, side)),
                      onTapDown: (d) =>
                          _paintPixel(d.localPosition, Size(side, side)),
                      child: Container(
                        width: side,
                        height: side,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: AppColors.border, width: 1),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: CustomPaint(
                          painter: PixelGridPainter(
                            pixels: _pixels,
                            width: _gridSize,
                            height: _gridSize,
                            showGrid: true,
                            gridColor: const Color(0xFF2E3A50),
                            backgroundColor: const Color(0xFF0E1420),
                          ),
                          size: Size(side, side),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ElevatedButton(
                onPressed: _publishing ? null : _publish,
                child: _publishing
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Publicar arte'),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}