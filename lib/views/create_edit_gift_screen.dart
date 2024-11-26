import 'package:flutter/material.dart';
import '../widgets/reusable_text_field.dart';
import '../widgets/gift_category_dropdown.dart';
import '../widgets/primary_button.dart';

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
  String _category = 'Electronics';
  bool _isPledged = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final gift =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

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

      Navigator.pop(context, giftDetails);
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
              ReusableTextField(
                controller: _nameController,
                labelText: 'Gift Name',
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter a gift name'
                    : null,
              ),

              const SizedBox(height: 16),

              // Description
              ReusableTextField(
                controller: _descriptionController,
                labelText: 'Description',
                maxLines: 3,
              ),

              const SizedBox(height: 16),

              // Category Dropdown
              GiftCategoryDropdown(
                value: _category,
                onChanged: (value) {
                  setState(() {
                    _category = value!;
                  });
                },
              ),

              const SizedBox(height: 16),

              // Price
              ReusableTextField(
                controller: _priceController,
                labelText: 'Price (\$)',
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

              const SizedBox(height: 16),

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

              const SizedBox(height: 16),

              // Save Button
              PrimaryButton(
                text: 'Save Gift',
                onPressed: _saveGift,
                snackbarMessage: 'Gift saved successfully!',
                snackbarColor: Colors.green,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
