import 'package:flutter/material.dart';

class ReusableTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final String? hintText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final int maxLines;
  final VoidCallback? onTap;
  final bool readOnly;
  final bool enabled; // New property

  const ReusableTextField({
    super.key,
    required this.controller,
    required this.labelText,
    this.hintText,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.maxLines = 1,
    this.onTap,
    this.readOnly = false,
    this.enabled = true, // Default is true for backward compatibility
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? null : () {}, // Block touch interactions for disabled
      child: IgnorePointer(
        ignoring: !enabled, // Ignore all pointer interactions when disabled
        child: TextFormField(
          controller: controller,
          decoration: InputDecoration(
            labelText: labelText,
            hintText: hintText,
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: enabled
                    ? Colors.grey
                    : Colors.grey.shade400, // Border color
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.grey.shade300, // Lighter border for disabled
              ),
            ),
            labelStyle: TextStyle(
              color: enabled ? Colors.black : Colors.grey, // Label color
            ),
            hintStyle: TextStyle(
              color:
                  enabled ? Colors.black45 : Colors.grey.shade400, // Hint color
            ),
          ),
          keyboardType: keyboardType,
          validator: validator,
          maxLines: maxLines,
          readOnly: readOnly || !enabled, // Combine readOnly and enabled
          onTap: enabled ? onTap : null, // Disable onTap if not enabled
          style: TextStyle(
            color: enabled ? Colors.black : Colors.grey, // Text color
          ),
          focusNode:
              enabled ? null : AlwaysDisabledFocusNode(), // Prevent focus
        ),
      ),
    );
  }
}

// A custom FocusNode to prevent focus on disabled fields
class AlwaysDisabledFocusNode extends FocusNode {
  @override
  bool get hasFocus => false; // Always return false for focus state
}
