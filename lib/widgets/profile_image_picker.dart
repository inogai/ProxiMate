import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'circular_image_cropper.dart';
import 'web_image_cropper.dart';

/// Widget for picking and cropping profile images
class ProfileImagePicker extends StatefulWidget {
  final String? currentImagePath;
  final Function(String?) onImageSelected;
  final double radius;

  const ProfileImagePicker({
    super.key,
    this.currentImagePath,
    required this.onImageSelected,
    this.radius = 60,
  });

  @override
  State<ProfileImagePicker> createState() => _ProfileImagePickerState();
}

class _ProfileImagePickerState extends State<ProfileImagePicker> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  Future<void> _pickAndCropImage() async {
    try {
      // Pick image from gallery or camera
      final source = await _showImageSourceDialog();
      if (source == null) {
        debugPrint('Image source selection cancelled');
        return;
      }

      debugPrint('Picking image from: ${source == ImageSource.camera ? 'Camera' : 'Gallery'}');
      
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile == null) {
        debugPrint('No image picked');
        return;
      }

      debugPrint('Image picked: ${pickedFile.path}');
      
      debugPrint('Image picked: ${pickedFile.path}');
      
      // On web, show the web cropper
      if (kIsWeb) {
        debugPrint('Web platform detected, showing web cropper');
        debugPrint('XFile details - path: ${pickedFile.path}, name: ${pickedFile.name}');
        
        try {
          debugPrint('Showing WebImageCropper in dialog...');
          
          final croppedBytes = await showDialog<Uint8List>(
            context: context,
            barrierDismissible: false,
            builder: (dialogContext) {
              debugPrint('WebImageCropper dialog builder called');
              return Dialog.fullscreen(
                child: WebImageCropper(
                  imageFile: pickedFile,
                  onCropped: (bytes) {
                    debugPrint('onCropped called with ${bytes.length} bytes');
                    Navigator.of(dialogContext).pop(bytes);
                  },
                  onCancel: () {
                    debugPrint('onCancel called');
                    Navigator.of(dialogContext).pop();
                  },
                ),
              );
            },
          );
          
          debugPrint('Navigation returned, croppedBytes: ${croppedBytes?.length ?? "null"}');
          
          if (croppedBytes != null) {
            // Convert bytes to base64 data URL for web storage
            final base64Image = base64Encode(croppedBytes);
            final dataUrl = 'data:image/png;base64,$base64Image';
            debugPrint('Image cropped on web, data URL length: ${dataUrl.length}');
            widget.onImageSelected(dataUrl);
            
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Profile image updated'),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 1),
                ),
              );
            }
          }
        } catch (webCropError, stackTrace) {
          debugPrint('Error in web cropper: $webCropError');
          debugPrint('Stack trace: $stackTrace');
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Cropper error: $webCropError'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
        return;
      }
      
      // Mobile platform - check file and show cropper
      final file = File(pickedFile.path);
      final exists = await file.exists();
      debugPrint('Picked file exists: $exists, size: ${exists ? await file.length() : 0}');

      // Navigate to custom circular cropper
      debugPrint('Starting image crop...');
      
      if (!context.mounted) return;
      
      final croppedFile = await Navigator.of(context).push<File>(
        MaterialPageRoute(
          builder: (context) => CircularImageCropper(
            imageFile: file,
            onCropped: (croppedFile) {
              Navigator.of(context).pop(croppedFile);
            },
            onCancel: () {
              Navigator.of(context).pop();
            },
          ),
        ),
      );

      debugPrint('Crop completed. Result: ${croppedFile?.path ?? 'null'}');

      if (croppedFile != null && croppedFile.path.isNotEmpty) {
        debugPrint('Image cropped successfully: ${croppedFile.path}');
        widget.onImageSelected(croppedFile.path);
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile image updated'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 1),
            ),
          );
        }
      } else {
        debugPrint('Image crop cancelled - using original');
      }
    } catch (e) {
      debugPrint('Error picking/cropping image: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<ImageSource?> _showImageSourceDialog() async {
    return showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Image Source'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
          ],
        ),
      ),
    );
  }

  void _showImageOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Change Photo'),
              onTap: () {
                Navigator.pop(context);
                _pickAndCropImage();
              },
            ),
            if (widget.currentImagePath != null)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Remove Photo', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  widget.onImageSelected(null);
                },
              ),
            ListTile(
              leading: const Icon(Icons.cancel),
              title: const Text('Cancel'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('ProfileImagePicker build - currentImagePath: ${widget.currentImagePath}');
    
    return GestureDetector(
      onTap: () => _showImageOptions(),
      child: Stack(
        children: [
          CircleAvatar(
            key: ValueKey(widget.currentImagePath), // Force rebuild when path changes
            radius: widget.radius,
            backgroundColor: Theme.of(context).primaryColor,
            backgroundImage: widget.currentImagePath != null && widget.currentImagePath!.isNotEmpty
                ? (kIsWeb
                    ? (widget.currentImagePath!.startsWith('data:')
                        ? MemoryImage(base64Decode(widget.currentImagePath!.split(',')[1]))
                        : NetworkImage(widget.currentImagePath!))
                    : FileImage(File(widget.currentImagePath!)))
                : null,
            child: widget.currentImagePath == null || widget.currentImagePath!.isEmpty
                ? Icon(
                    Icons.person,
                    size: widget.radius * 1.2,
                    color: Colors.white,
                  )
                : null,
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 2,
                ),
              ),
              padding: const EdgeInsets.all(8),
              child: Icon(
                widget.currentImagePath == null ? Icons.add_a_photo : Icons.edit,
                color: Colors.white,
                size: widget.radius * 0.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
