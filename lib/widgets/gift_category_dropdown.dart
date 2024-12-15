import 'package:flutter/material.dart';

class GiftCategoryDropdown extends StatelessWidget {
  final String value;
  final ValueChanged<String?>? onChanged; // Made nullable for disabled state
  final bool enabled; // New property

  const GiftCategoryDropdown({
    super.key,
    required this.value,
    required this.onChanged,
    this.enabled = true, // Default is true for backward compatibility
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: !enabled, // Disable all interactions if not enabled
      child: DropdownButtonFormField<String>(
        value: value,
        items: const [
          DropdownMenuItem(value: 'Electronics', child: Text('Electronics')),
          DropdownMenuItem(value: 'Books', child: Text('Books')),
          DropdownMenuItem(value: 'Clothing', child: Text('Clothing')),
          DropdownMenuItem(value: 'Accessories', child: Text('Accessories')),
        ],
        onChanged: enabled ? onChanged : null, // Disable if not enabled
        decoration: InputDecoration(
          labelText: 'Category',
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color:
                  enabled ? Colors.grey : Colors.grey.shade400, // Border color
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
        ),
        disabledHint: Text(
          value,
          style: const TextStyle(color: Colors.grey), // Disabled hint style
        ),
      ),
    );
  }
}
