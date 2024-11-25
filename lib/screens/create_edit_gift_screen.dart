import 'package:flutter/material.dart';

class CreateEditGiftPage extends StatefulWidget {
  static const routeName = '/create-edit-gift';

  const CreateEditGiftPage({Key? key}) : super(key: key);

  @override
  State<CreateEditGiftPage> createState() => _CreateEditGiftPageState();
}

class _CreateEditGiftPageState extends State<CreateEditGiftPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  String _category = 'Electronics'; // Default category
  bool _isPledged = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Retrieve gift data from arguments
    final gift =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    // Initialize controllers with gift data if available
    _nameController = TextEditingController(text: gift?['name'] ?? '');
    _descriptionController =
        TextEditingController(text: gift?['description'] ?? '');
    _priceController =
        TextEditingController(text: gift?['price']?.toString() ?? '');
    _category = gift?['category'] ?? 'Electronics';
    _isPledged = gift?['status'] == 'Pledged';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _saveGift() {
    if (_formKey.currentState!.validate()) {
      final giftDetails = {
        'name': _nameController.text,
        'description': _descriptionController.text,
        'price': double.tryParse(_priceController.text) ?? 0.0,
        'category': _category,
        'status': _isPledged ? 'Pledged' : 'Available',
      };

      print('Gift saved: $giftDetails');
      Navigator.pop(
          context, giftDetails); // Pass data back to the previous screen
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          ModalRoute.of(context)?.settings.arguments == null
              ? 'Add Gift'
              : 'Edit Gift',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Gift Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Gift Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a gift name';
                  }
                  return null;
                },
              ),

              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),

              // Category Dropdown
              DropdownButtonFormField<String>(
                value: _category,
                items: const [
                  DropdownMenuItem(
                      value: 'Electronics', child: Text('Electronics')),
                  DropdownMenuItem(value: 'Books', child: Text('Books')),
                  DropdownMenuItem(value: 'Clothing', child: Text('Clothing')),
                  DropdownMenuItem(
                      value: 'Accessories', child: Text('Accessories')),
                ],
                onChanged: (value) {
                  setState(() {
                    _category = value!;
                  });
                },
                decoration: const InputDecoration(labelText: 'Category'),
              ),

              // Price
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Price (\$)'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a price';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),

              // Status Toggle
              SwitchListTile(
                value: _isPledged,
                onChanged: (value) {
                  setState(() {
                    _isPledged = value;
                  });
                },
                title: const Text('Mark as Pledged'),
              ),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveGift,
                  child: const Text('Save Gift'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
