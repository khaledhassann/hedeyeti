import 'package:flutter/material.dart';
import 'package:hedeyeti/models/Gift.dart';
import '../services/database_helper.dart';
import '../services/firebase_helper.dart';
import '../widgets/reusable_text_field.dart';
import '../widgets/gift_category_dropdown.dart';
import '../widgets/primary_button.dart';
import 'package:flutter/scheduler.dart';

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
  String? _giftId; // For editing
  late String _eventId; // Event ID for the gift
  String? _loggedInUserId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (args == null || !args.containsKey('eventId')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Missing event ID.')),
      );
      Navigator.pop(context);
      return;
    }

    _eventId = args['eventId'] as String;
    _giftId = args['gift']?.id;

    _nameController = TextEditingController(text: args['gift']?.name ?? '');
    _descriptionController =
        TextEditingController(text: args['gift']?.description ?? '');
    _priceController =
        TextEditingController(text: args['gift']?.price?.toString() ?? '');
    _category = args['gift']?.category ?? 'Electronics';
    _isPledged = args['gift']?.status == 'Pledged';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _saveGiftToLocalDatabase() async {
    if (_formKey.currentState!.validate()) {
      final dbHelper = DatabaseHelper();

      final giftId =
          _giftId ?? DateTime.now().millisecondsSinceEpoch.toString();

      final gift = Gift(
        id: giftId,
        name: _nameController.text,
        description: _descriptionController.text.isNotEmpty
            ? _descriptionController.text
            : null,
        category: _category,
        price: double.tryParse(_priceController.text) ?? 0.0,
        status: _isPledged ? 'Pledged' : 'Available',
        eventId: _eventId,
        pledgerId: _isPledged ? _loggedInUserId : null,
        isPublished: false,
      );

      await dbHelper.insertGift(gift);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(_giftId == null
                ? 'Gift added locally!'
                : 'Gift updated locally!')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_giftId == null ? 'Add Gift' : 'Edit Gift'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text(
                'Gift Details',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Divider(),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Gift Name',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => value == null || value.isEmpty
                            ? 'Please enter a gift name'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _category,
                        onChanged: (value) =>
                            setState(() => _category = value!),
                        decoration: const InputDecoration(
                          labelText: 'Category',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'Electronics',
                            child: Text('Electronics'),
                          ),
                          DropdownMenuItem(
                            value: 'Clothing',
                            child: Text('Clothing'),
                          ),
                          DropdownMenuItem(
                            value: 'Books',
                            child: Text('Books'),
                          ),
                          DropdownMenuItem(
                            value: 'Accessories',
                            child: Text('Accessories'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _priceController,
                        decoration: const InputDecoration(
                          labelText: 'Price (EGP)',
                          border: OutlineInputBorder(),
                        ),
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
                      SwitchListTile(
                        value: _isPledged,
                        onChanged: (value) =>
                            setState(() => _isPledged = value),
                        title: const Text('Mark as Pledged'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveGiftToLocalDatabase,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                ),
                child: const Text('Save Gift'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
