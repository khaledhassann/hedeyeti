// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import '../widgets/event_category_dropdown.dart';
import '../widgets/primary_button.dart';
import '../widgets/reusable_text_field.dart';
import '../services/database_helper.dart'; // Import the database helper class

class CreateEditEventPage extends StatefulWidget {
  static const routeName = '/create-edit-event';

  const CreateEditEventPage({Key? key}) : super(key: key);

  @override
  State<CreateEditEventPage> createState() => _CreateEditEventPageState();
}

class _CreateEditEventPageState extends State<CreateEditEventPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _dateController;
  late TextEditingController _locationController;
  late TextEditingController _descriptionController;
  String _category = 'Birthday';
  String? _eventId; // To track if editing an existing event

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args = ModalRoute.of(context)?.settings.arguments;

    if (args is Map<dynamic, dynamic>) {
      _eventId = args['id']; // Get the ID if editing an existing event
      _nameController = TextEditingController(text: args['name'] ?? '');
      _dateController = TextEditingController(text: args['date'] ?? '');
      _locationController = TextEditingController(text: args['location'] ?? '');
      _descriptionController =
          TextEditingController(text: args['description'] ?? '');
      _category = args['category'] ?? 'Birthday';
    } else {
      _nameController = TextEditingController();
      _dateController = TextEditingController();
      _locationController = TextEditingController();
      _descriptionController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dateController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _dateController.text =
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  Future<void> _saveEventToDatabase() async {
    if (_formKey.currentState!.validate()) {
      final dbHelper = DatabaseHelper();
      final eventDetails = {
        'name': _nameController.text,
        'date': _dateController.text,
        'location': _locationController.text,
        'description': _descriptionController.text,
        'category': _category,
      };

      if (_eventId == null) {
        // Create new event
        await dbHelper.insertEvent(eventDetails);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Event created successfully!'),
              backgroundColor: Colors.green),
        );
      } else {
        // Update existing event
        await dbHelper.updateEvent(_eventId!, eventDetails);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Event updated successfully!'),
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
          _eventId == null ? 'Create Event' : 'Edit Event',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              ReusableTextField(
                controller: _nameController,
                labelText: 'Event Name',
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter an event name'
                    : null,
              ),
              // Event Date with Date Picker
              ReusableTextField(
                controller: _dateController,
                labelText: 'Event Date',
                hintText: 'YYYY-MM-DD',
                readOnly: true,
                onTap: () => _selectDate(context),
              ),
              ReusableTextField(
                controller: _locationController,
                labelText: 'Location',
              ),
              ReusableTextField(
                controller: _descriptionController,
                labelText: 'Description',
                maxLines: 3,
              ),
              EventCategoryDropdown(
                value: _category,
                onChanged: (value) {
                  setState(() {
                    _category = value!;
                  });
                },
              ),
              PrimaryButton(
                text: 'Save Event',
                onPressed: _saveEventToDatabase,
                snackbarMessage: 'Event saved successfully!',
                snackbarColor: Colors.green,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
