import 'package:flutter/material.dart';

class EmptyListMessage extends StatelessWidget {
  final String message;

  const EmptyListMessage({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        message,
        style: const TextStyle(fontSize: 16, color: Colors.grey),
      ),
    );
  }
}
