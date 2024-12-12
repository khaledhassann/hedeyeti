import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class ImageHelper {
  static final ImagePicker _imagePicker = ImagePicker();

  /// Capture an image using the camera.
  static Future<String?> captureImage(BuildContext context) async {
    final hasPermission = await _requestCameraPermission(context);
    if (!hasPermission) return null;

    final pickedFile = await _imagePicker.pickImage(source: ImageSource.camera);
    return pickedFile?.path;
  }

  /// Select an image from the gallery.
  static Future<String?> selectImage() async {
    final pickedFile =
        await _imagePicker.pickImage(source: ImageSource.gallery);
    return pickedFile?.path;
  }

  /// Request camera permissions.
  static Future<bool> _requestCameraPermission(BuildContext context) async {
    final status = await Permission.camera.status;

    if (status.isGranted) {
      return true; // Permission is already granted
    } else if (status.isDenied) {
      final result = await Permission.camera.request();
      return result.isGranted;
    } else if (status.isPermanentlyDenied) {
      _showPermanentDenialDialog(context);
      return false;
    }

    return false;
  }

  /// Show a dialog for permanent denial of camera permissions.
  static void _showPermanentDenialDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Permission Permanently Denied'),
        content: const Text(
            'You have permanently denied camera access. Please enable it in the app settings.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }
}
