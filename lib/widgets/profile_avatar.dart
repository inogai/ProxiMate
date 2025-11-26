import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ProfileAvatar extends StatelessWidget {
  final String name;
  final String? imagePath;
  final double size;

  const ProfileAvatar({
    super.key,
    required this.name,
    this.imagePath,
    required this.size,
  });

  String _getInitials(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();

    switch (parts) {
      case []:
        return 'N/A';
      case [final head]:
        final end = math.min(4, head.length);
        return head.substring(0, end).toUpperCase();
      default:
        return parts.take(4).map((e) => e[0]).join().toUpperCase();
    }
  }

  Widget buildPlaceholder(Color color, String text, double fontSize) {
    return Container(
      width: size,
      height: size,
      color: color,
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: fontSize,
          ),
        ),
      ),
    );
  }

  Widget buildImageAvatar(
    ImageProvider imageProvider,
    Color color,
    String text,
    double fontSize,
  ) {
    return ClipOval(
      child: Image(
        image: imageProvider,
        fit: BoxFit.cover,
        width: size,
        height: size,
        gaplessPlayback: true,
        filterQuality: FilterQuality.medium,
        errorBuilder: (context, error, stackTrace) {
          return buildPlaceholder(color, text, fontSize);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = _generateColor(name);
    final text = _getInitials(name);
    final fontSize = text.length <= 3 ? size * 0.3 : size * 0.25;

    return ClipOval(
      child: imagePath != null
          ? buildImageAvatar(
              getImageProvider(imagePath!),
              color,
              text,
              fontSize,
            )
          : buildPlaceholder(color, text, fontSize),
    );
  }

  Color _generateColor(String name) {
    final colors = [
      Colors.red.shade900,
      Colors.blue.shade900,
      Colors.green.shade900,
      Colors.purple.shade900,
      Colors.orange.shade900,
      Colors.pink.shade900,
      Colors.teal.shade900,
      Colors.indigo.shade900,
      Colors.brown.shade900,
      Colors.grey.shade900,
    ];
    return colors[name.hashCode % colors.length];
  }

  static ImageProvider getImageProvider(String imagePath) {
    if (kIsWeb) {
      if (imagePath.startsWith('data:')) {
        // Base64 data URL
        return MemoryImage(base64Decode(imagePath.split(',')[1]));
      } else {
        // Blob URL or network URL
        return NetworkImage(imagePath);
      }
    } else {
      // Mobile: file path
      return FileImage(File(imagePath));
    }
  }
}
