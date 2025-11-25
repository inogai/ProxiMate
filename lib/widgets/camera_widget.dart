import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:html' as html;

/// Widget for camera functionality
class CameraWidget extends StatefulWidget {
  const CameraWidget({super.key});

  @override
  State<CameraWidget> createState() => _CameraWidgetState();
}

class _CameraWidgetState extends State<CameraWidget> {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;
  List<CameraDescription>? cameras;
  bool _isCameraAvailable = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      // For web platform, add additional checks
      if (kIsWeb) {
        // Check if browser supports mediaDevices
        if (html.window.navigator.mediaDevices == null) {
          throw Exception('Camera not supported in this browser');
        }
      }

      // Get available cameras with null safety
      final cameras = await availableCameras();

      if (cameras.isEmpty) {
        throw Exception('No cameras found');
      }

      this.cameras = cameras;

      // Initialize camera controller with error handling
      // Use medium resolution for better compatibility across browsers
      _controller = CameraController(
        cameras[0], // Use first available camera
        kIsWeb ? ResolutionPreset.medium : ResolutionPreset.high,
        enableAudio: false, // Disable audio to prevent issues
        // Add web-specific options
        imageFormatGroup: kIsWeb
            ? ImageFormatGroup.jpeg
            : ImageFormatGroup.unknown,
      );

      _initializeControllerFuture = _controller!
          .initialize()
          .then((_) {
            if (mounted) {
              setState(() {});
            }
          })
          .catchError((error) {
            throw Exception('Failed to initialize camera controller: $error');
          });
    } catch (e) {
      print('Error initializing camera: $e');
      setState(() {
        _isCameraAvailable = false;
        _errorMessage = e.toString();
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to initialize camera: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _takePicture() async {
    try {
      await _initializeControllerFuture;
      final image = await _controller!.takePicture();

      if (mounted) {
        // Navigate back with image path
        Navigator.of(context).pop(image.path);
      }
    } catch (e) {
      print('Error taking picture: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to take picture: $e')));
      }
    }
  }

  void _switchCamera() {
    if (cameras != null && cameras!.length > 1) {
      final currentCamera = _controller?.description;
      final nextCamera = cameras!.firstWhere(
        (camera) => camera != currentCamera,
        orElse: () => cameras![0],
      );

      _controller = CameraController(
        nextCamera,
        kIsWeb ? ResolutionPreset.medium : ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: kIsWeb
            ? ImageFormatGroup.jpeg
            : ImageFormatGroup.unknown,
      );
      _initializeControllerFuture = _controller!.initialize();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show error state if camera is not available
    if (!_isCameraAvailable) {
      return Container(
        color: Colors.black,
        width: double.infinity,
        height: double.infinity,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.camera_alt_outlined,
                size: 64,
                color: Colors.white54,
              ),
              const SizedBox(height: 16),
              const Text(
                'Camera Unavailable',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    _errorMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isCameraAvailable = true;
                    _errorMessage = null;
                  });
                  _initializeCamera();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      color: Colors.black,
      width: double.infinity,
      height: double.infinity,
      child: _controller == null
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : FutureBuilder<void>(
              future: _initializeControllerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return Stack(
                    children: [
                      // Use a LayoutBuilder to get the available space
                      LayoutBuilder(
                        builder: (context, constraints) {
                          // Calculate the optimal size for the camera preview
                          final size = constraints.biggest;

                          // Get the camera controller's aspect ratio
                          final aspectRatio = _controller!.value.aspectRatio;

                          // Calculate the best fit size maintaining aspect ratio
                          double previewWidth, previewHeight;

                          if (size.width / size.height > aspectRatio) {
                            // Container is wider than camera aspect ratio
                            previewHeight = size.height;
                            previewWidth = previewHeight * aspectRatio;
                          } else {
                            // Container is taller than camera aspect ratio
                            previewWidth = size.width;
                            previewHeight = previewWidth / aspectRatio;
                          }

                          return Center(
                            child: Container(
                              width: previewWidth,
                              height: previewHeight,
                              // Add a clip to prevent overflow
                              clipBehavior: Clip.hardEdge,
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(0),
                              ),
                              child: CameraPreview(_controller!),
                            ),
                          );
                        },
                      ),
                      Positioned(
                        bottom: 32,
                        left: 0,
                        right: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Switch camera button
                            if (cameras != null && cameras!.length > 1)
                              Container(
                                margin: const EdgeInsets.only(right: 32),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.5),
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.flip_camera_ios,
                                    color: Colors.white,
                                    size: 32,
                                  ),
                                  onPressed: _switchCamera,
                                ),
                              ),

                            // Capture button
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.3),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 4,
                                ),
                              ),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.camera,
                                  color: Colors.white,
                                  size: 40,
                                ),
                                onPressed: _takePicture,
                              ),
                            ),

                            // Close button
                            Container(
                              margin: const EdgeInsets.only(left: 32),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.5),
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 32,
                                ),
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                } else {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  );
                }
              },
            ),
    );
  }
}
