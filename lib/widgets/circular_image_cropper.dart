import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// A custom circular image cropper widget
class CircularImageCropper extends StatefulWidget {
  final File imageFile;
  final Function(File) onCropped;
  final VoidCallback onCancel;

  const CircularImageCropper({
    super.key,
    required this.imageFile,
    required this.onCropped,
    required this.onCancel,
  });

  @override
  State<CircularImageCropper> createState() => _CircularImageCropperState();
}

class _CircularImageCropperState extends State<CircularImageCropper> {
  ui.Image? _image;
  double _scale = 1.0;
  Offset _offset = Offset.zero;
  Offset? _startFocalPoint;
  double? _startScale;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    final bytes = await widget.imageFile.readAsBytes();
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    setState(() {
      _image = frame.image;
      _isLoading = false;
      // Center the image initially
      _calculateInitialTransform();
    });
  }

  void _calculateInitialTransform() {
    if (_image == null) return;
    
    // Calculate scale to fit the image in the crop circle
    final imageAspect = _image!.width / _image!.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final cropSize = screenWidth * 0.8;
    
    if (imageAspect > 1) {
      // Landscape
      _scale = cropSize / _image!.height;
    } else {
      // Portrait
      _scale = cropSize / _image!.width;
    }
  }

  Future<void> _cropAndSave() async {
    if (_image == null) return;

    setState(() => _isLoading = true);

    try {
      final screenWidth = MediaQuery.of(context).size.width;
      final cropSize = screenWidth * 0.8;
      final cropRadius = cropSize / 2;

      // Create a recorder to capture the cropped area
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);

      // Calculate the center of the crop circle on screen
      final centerX = screenWidth / 2;
      final centerY = MediaQuery.of(context).size.height / 2;

      // Calculate image position accounting for scale and offset
      final imageWidth = _image!.width * _scale;
      final imageHeight = _image!.height * _scale;
      final imageX = centerX - (imageWidth / 2) + _offset.dx;
      final imageY = centerY - (imageHeight / 2) + _offset.dy;

      // Calculate the crop area in image coordinates
      final cropCenterX = (centerX - imageX) / _scale;
      final cropCenterY = (centerY - imageY) / _scale;
      final cropRadiusInImage = cropRadius / _scale;

      // Create circular clip
      final path = Path()
        ..addOval(Rect.fromCircle(
          center: Offset(cropRadius, cropRadius),
          radius: cropRadius,
        ));
      canvas.clipPath(path);

      // Draw the cropped portion
      final srcRect = Rect.fromCenter(
        center: Offset(cropCenterX, cropCenterY),
        width: cropRadiusInImage * 2,
        height: cropRadiusInImage * 2,
      );
      final dstRect = Rect.fromLTWH(0, 0, cropSize, cropSize);

      canvas.drawImageRect(_image!, srcRect, dstRect, Paint());

      // Convert to image
      final picture = recorder.endRecording();
      final img = await picture.toImage(cropSize.toInt(), cropSize.toInt());
      final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();

      // Save to a temporary file
      final tempDir = widget.imageFile.parent;
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final croppedFile = File('${tempDir.path}/cropped_$timestamp.png');
      await croppedFile.writeAsBytes(pngBytes);

      if (mounted) {
        widget.onCropped(croppedFile);
      }
    } catch (e) {
      debugPrint('Error cropping image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error cropping image: $e'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cropSize = screenWidth * 0.8;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Crop Profile Image'),
        backgroundColor: Colors.deepPurple,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: widget.onCancel,
        ),
        actions: [
          if (!_isLoading)
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _cropAndSave,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                // Image viewer with pan and zoom
                Center(
                  child: GestureDetector(
                    onScaleStart: (details) {
                      _startFocalPoint = details.focalPoint;
                      _startScale = _scale;
                    },
                    onScaleUpdate: (details) {
                      setState(() {
                        // Handle zoom
                        _scale = (_startScale! * details.scale).clamp(0.5, 4.0);

                        // Handle pan
                        if (_startFocalPoint != null) {
                          _offset += details.focalPoint - _startFocalPoint!;
                          _startFocalPoint = details.focalPoint;
                        }
                      });
                    },
                    child: _image != null
                        ? CustomPaint(
                            size: Size(screenWidth, MediaQuery.of(context).size.height),
                            painter: ImagePainter(
                              image: _image!,
                              scale: _scale,
                              offset: _offset,
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                ),
                // Crop circle overlay
                Center(
                  child: Container(
                    width: cropSize,
                    height: cropSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 2,
                      ),
                    ),
                  ),
                ),
                // Dark overlay with hole for crop circle
                IgnorePointer(
                  child: CustomPaint(
                    size: Size(screenWidth, MediaQuery.of(context).size.height),
                    painter: OverlayPainter(cropSize: cropSize),
                  ),
                ),
                // Instructions
                Positioned(
                  bottom: 40,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    margin: const EdgeInsets.symmetric(horizontal: 40),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Pinch to zoom • Drag to move',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class ImagePainter extends CustomPainter {
  final ui.Image image;
  final double scale;
  final Offset offset;

  ImagePainter({
    required this.image,
    required this.scale,
    required this.offset,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final imageWidth = image.width * scale;
    final imageHeight = image.height * scale;

    final x = (size.width - imageWidth) / 2 + offset.dx;
    final y = (size.height - imageHeight) / 2 + offset.dy;

    final srcRect = Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble());
    final dstRect = Rect.fromLTWH(x, y, imageWidth, imageHeight);

    canvas.drawImageRect(image, srcRect, dstRect, Paint());
  }

  @override
  bool shouldRepaint(covariant ImagePainter oldDelegate) {
    return oldDelegate.scale != scale || oldDelegate.offset != offset;
  }
}

class OverlayPainter extends CustomPainter {
  final double cropSize;

  OverlayPainter({required this.cropSize});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.6)
      ..style = PaintingStyle.fill;

    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addOval(Rect.fromCircle(
        center: Offset(size.width / 2, size.height / 2),
        radius: cropSize / 2,
      ))
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
