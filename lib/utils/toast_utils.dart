import 'package:flutter/material.dart';
import 'package:anyhow/rust.dart';

class ToastUtils {
  static void showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  static void showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  static void showInfo(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.blue,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Displays a toast message based on the Result.
  /// If the result is Ok, it shows [successMessage] if provided.
  /// If the result is Err, it shows [errorMessage] concatenated with the error value if provided.
  static void showResult(
    BuildContext context,
    Result<void> result, {
    String? successMessage,
    String? errorMessage,
  }) {
    switch (result) {
      case Ok():
        if (successMessage != null) {
          showSuccess(context, successMessage);
        }
      case Err(v: final v):
        if (errorMessage != null) {
          showError(context, "$errorMessage$v");
        }
    }
  }

  static Future<void> showFutureResult(
    BuildContext context,
    Future<Result<void>> futureResult, {
    String? successMessage,
    String? errorMessage,
  }) async {
    final result = await futureResult;

    if (!context.mounted) return;

    showResult(
      context,
      result,
      successMessage: successMessage,
      errorMessage: errorMessage,
    );
  }
}
