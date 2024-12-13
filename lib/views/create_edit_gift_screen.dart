import 'package:flutter/material.dart';
import 'package:hedeyeti/models/Gift.dart';
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
  late String _eventId; // To link the gift to an event
  String? _loggedInUserId; // Logged-in user's ID
  final FirebaseHelper _firebaseHelper = FirebaseHelper();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Retrieve arguments from route
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    // Ensure event ID is passed
    if (args == null || !args.containsKey('eventId')) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: Missing event ID.')),
        );
        Navigator.pop(context); // Return to the previous screen
      });
      return;
    }

    _eventId = args['eventId'] as String;
    _giftId = args['gift']?.id; // Nullable for new gifts

    // Get the logged-in user's ID
    _firebaseHelper.getCurrentUser().then((user) {
      if (mounted) {
        setState(() {
          _loggedInUserId = user?.id;
        });
      }
    });

    // Initialize controllers with existing data if editing
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

  Future<void> _saveGiftToFirestore() async {
    if (_formKey.currentState!.validate()) {
      // Ensure userId is fetched before proceeding
      final userId = _loggedInUserId;

      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error: Unable to determine logged-in user.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final giftId = _giftId ??
          _firebaseHelper.gifts.doc().id; // Generate a new ID if null

      final gift = Gift(
        id: giftId,
        name: _nameController.text,
        description: _descriptionController.text.isNotEmpty
            ? _descriptionController.text
            : null, // Ensure description is null if empty
        category: _category,
        price: double.tryParse(_priceController.text) ?? 0.0,
        status: _isPledged ? 'Pledged' : 'Available',
        eventId: _eventId,
        pledgerId: _isPledged ? userId : null,
      );

      try {
        if (_giftId == null) {
          // Insert new gift
          await _firebaseHelper.insertGiftInFirestore(gift);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Gift added successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          // Update existing gift
          await _firebaseHelper.updateGiftInFirestore(
            giftId: gift.id,
            name: gift.name,
            description: gift.description,
            category: gift.category,
            price: gift.price,
            status: gift.status,
            pledgerId:
                _isPledged ? userId : null, // Clear pledgerId if not pledged
          );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Gift updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }

        Navigator.pop(context); // Close the screen
      } catch (e) {
        print('Error saving gift: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save gift: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
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
                labelText: 'Price (EGP)',
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
                onPressed: _saveGiftToFirestore,
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
