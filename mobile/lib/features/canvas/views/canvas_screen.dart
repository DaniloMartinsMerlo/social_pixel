import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:mobile/features/canvas/viewmodels/canvas_viewmodel.dart';
import 'package:mobile/shared/widgets/pixel_grid.dart';

class CanvasScreen extends StatefulWidget {
  const CanvasScreen({super.key});

  @override
  State<CanvasScreen> createState() => _CanvasScreenState();
}

class _CanvasScreenState extends State<CanvasScreen> {
  final CanvasViewModel _canvasViewModel = CanvasViewModel();
  final TextEditingController _titleController =
      TextEditingController(text: 'Nova pixel art');

  @override
  void dispose() {
    _titleController.dispose();
    _canvasViewModel.dispose();
    super.dispose();
  }

    void _showColorPicker(BuildContext context) {
    Color current = Color(int.parse(
        _canvasViewModel.selectedColor.replaceFirst('#', '0xFF'),
    ));

    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        builder: (_) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
                Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                ),
                ),
                const SizedBox(height: 16),
                FractionallySizedBox(
                widthFactor: 0.9,
                child: ColorPicker(
                    pickerColor: current,
                    onColorChanged: (color) {
                    setModalState(() => current = color);
                    final hex = '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
                    _canvasViewModel.setColor(hex);
                    },
                    enableAlpha: false,
                    labelTypes: const [],
                    pickerAreaHeightPercent: 0.4,
                    displayThumbColor: true,
                    portraitOnly: true,
                ),
                ),
            ],
            ),
        ),
        ),
    );
    }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _canvasViewModel,
      builder: (context, _) {
        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          children: [
            Text('Canvas', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 12),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Título da arte'),
              onChanged: _canvasViewModel.setTitle,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    initialValue: _canvasViewModel.width,
                    decoration:
                        const InputDecoration(labelText: 'Tamanho do canvas'),
                    items: const [12, 16, 24, 32, 48, 64]
                        .map((v) => DropdownMenuItem<int>(
                            value: v, child: Text('${v}x${v}')))
                        .toList(growable: false),
                    onChanged: (value) {
                      if (value != null) {
                        _canvasViewModel.setCanvasSize(value, value);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () => _showColorPicker(context),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Color(int.parse(
                        _canvasViewModel.selectedColor
                            .replaceFirst('#', '0xFF'),
                      )),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            PixelGrid(
              width: _canvasViewModel.width,
              height: _canvasViewModel.height,
              pixels: _canvasViewModel.pixels,
              selectedColor: _canvasViewModel.selectedColor,
              onPixelTap: _canvasViewModel.paintPixel,
            ),
            const SizedBox(height: 16),
            if (_canvasViewModel.errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  _canvasViewModel.errorMessage!,
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.error),
                ),
              ),
            FilledButton(
              onPressed: _canvasViewModel.isSubmitting
                  ? null
                  : () async {
                      final messenger = ScaffoldMessenger.of(context);
                      await _canvasViewModel.submitCanvas();
                      if (!mounted ||
                          _canvasViewModel.errorMessage != null) return;
                      messenger.showSnackBar(
                        const SnackBar(
                            content: Text('Arte enviada para o feed')),
                      );
                    },
              child: _canvasViewModel.isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Publicar arte'),
            ),
          ],
        );
      },
    );
  }
}