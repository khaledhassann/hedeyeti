import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final String? snackbarMessage;
  final Color? snackbarColor;

  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.snackbarMessage,
    this.snackbarColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          onPressed();

          // Show snackbar if a message is provided
          if (snackbarMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(snackbarMessage!),
                backgroundColor:
                    snackbarColor ?? Theme.of(context).primaryColor,
                duration: const Duration(seconds: 2),
              ),
            );
          }
        },
        child: Text(text),
      ),
    );
  }
}
