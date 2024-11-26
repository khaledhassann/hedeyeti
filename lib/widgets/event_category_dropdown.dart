import 'package:flutter/material.dart';

class EventCategoryDropdown extends StatelessWidget {
  final String value;
  final ValueChanged<String?> onChanged;

  const EventCategoryDropdown({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      items: const [
        DropdownMenuItem(value: 'Birthday', child: Text('Birthday')),
        DropdownMenuItem(value: 'Wedding', child: Text('Wedding')),
        DropdownMenuItem(value: 'Graduation', child: Text('Graduation')),
        DropdownMenuItem(value: 'Holiday', child: Text('Holiday')),
      ],
      onChanged: onChanged,
      decoration: const InputDecoration(labelText: 'Category'),
    );
  }
}
