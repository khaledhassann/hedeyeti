import 'package:flutter/material.dart';
import '../services/database_helper.dart';
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
  int? _giftId; // For editing
  late int _eventId; // To link the gift to an event

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    _giftId = args?['id']; // Nullable for new gifts
    _eventId = args?['eventId'] ?? 0; // Event ID must be passed

    _nameController = TextEditingController(text: args?['name'] ?? '');
    _descriptionController =
        TextEditingController(text: args?['description'] ?? '');
    _priceController =
        TextEditingController(text: args?['price']?.toString() ?? '');
    _category = args?['category'] ?? 'Electronics';
    _isPledged = args?['status'] == 'Pledged';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _saveGiftToDatabase() async {
    if (_formKey.currentState!.validate()) {
      final dbHelper = DatabaseHelper();
      final giftDetails = {
        'name': _nameController.text,
        'description': _descriptionController.text,
        'price': double.tryParse(_priceController.text) ?? 0.0,
        'category': _category,
        'status': _isPledged ? 'Pledged' : 'Available',
        'event_id': _eventId, // Link to the event
      };

      if (_giftId == null) {
        // Insert new gift
        await dbHelper.insertGift(giftDetails);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Gift added successfully!'),
              backgroundColor: Colors.green),
        );
      } else {
        // Update existing gift
        await dbHelper.updateGift(_giftId!, giftDetails);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Gift updated successfully!'),
              backgroundColor: Colors.green),
        );
      }

      Navigator.pop(context); // Return to the previous screen
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _giftId == null ? 'Add Gift' : 'Edit Gift',
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
                onPressed: _saveGiftToDatabase,
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
