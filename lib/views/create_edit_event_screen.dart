import 'package:flutter/material.dart';
import 'package:hedeyeti/services/firebase_helper.dart';
import '../models/Event.dart';
import '../widgets/event_category_dropdown.dart';
import '../widgets/primary_button.dart';
import '../widgets/reusable_text_field.dart';

class CreateEditEventPage extends StatefulWidget {
  static const routeName = '/create-edit-event';

  const CreateEditEventPage({Key? key}) : super(key: key);

  @override
  State<CreateEditEventPage> createState() => _CreateEditEventPageState();
}

class _CreateEditEventPageState extends State<CreateEditEventPage> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseHelper _firebaseHelper = FirebaseHelper();

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

    if (args is Event) {
      _eventId = args.id; // Get the ID if editing an existing event
      _nameController = TextEditingController(text: args.name);
      _dateController = TextEditingController(text: args.formattedDate);
      _locationController = TextEditingController(text: args.location);
      _descriptionController = TextEditingController(text: args.description);
      _category = args.category;
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
      try {
        final currentUser = await _firebaseHelper.getCurrentUser();
        if (currentUser == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('User not logged in.'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        final eventDetails = {
          'name': _nameController.text,
          'date': _dateController.text,
          'location': _locationController.text,
          'description': _descriptionController.text,
          'category': _category,
          'userId': currentUser.id, // Add the current user's ID
        };

        if (_eventId == null) {
          // Create new event
          final newEvent = Event(
            id: _firebaseHelper.events.doc().id,
            name: eventDetails['name']!,
            date: DateTime.parse(eventDetails['date']!),
            location: eventDetails['location']!,
            description: eventDetails['description']!,
            category: eventDetails['category']!,
            userId: eventDetails['userId']!,
          );
          await _firebaseHelper.insertEventInFirestore(newEvent);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Event created successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          // Update existing event
          await _firebaseHelper.updateEventInFirestore(
            eventId: _eventId!,
            name: eventDetails['name'],
            date: DateTime.parse(eventDetails['date']!),
            category: eventDetails['category'],
            location: eventDetails['location'],
            description: eventDetails['description'],
          );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Event updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }

        Navigator.pop(context); // Return to the previous screen
      } catch (e) {
        print('Error saving event: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to save event.'),
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
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter a location'
                    : null,
              ),
              ReusableTextField(
                  controller: _descriptionController,
                  labelText: 'Description',
                  maxLines: 3,
                  validator: (value) => value == null || value.isEmpty
                      ? 'Please enter a short description'
                      : null),
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
