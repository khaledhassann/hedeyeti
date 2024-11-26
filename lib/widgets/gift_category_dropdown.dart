import 'package:flutter/material.dart';

class GiftCategoryDropdown extends StatelessWidget {
  final String value;
  final ValueChanged<String?> onChanged;

  const GiftCategoryDropdown({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      items: const [
        DropdownMenuItem(value: 'Electronics', child: Text('Electronics')),
        DropdownMenuItem(value: 'Books', child: Text('Books')),
        DropdownMenuItem(value: 'Clothing', child: Text('Clothing')),
        DropdownMenuItem(value: 'Accessories', child: Text('Accessories')),
      ],
      onChanged: onChanged,
      decoration: const InputDecoration(labelText: 'Category'),
    );
  }
}
