import 'package:flutter/material.dart';

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
  String _category = 'Birthday'; // Default category

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Retrieve and verify the passed arguments
    final args = ModalRoute.of(context)?.settings.arguments;
    print("Received Arguments: ${args.runtimeType} - $args");

    if (args is Map<dynamic, dynamic>) {
      // Initialize controllers with passed arguments
      _nameController = TextEditingController(text: args['name'] ?? '');
      _dateController = TextEditingController(text: args['date'] ?? '');
      _locationController = TextEditingController(text: args['location'] ?? '');
      _descriptionController =
          TextEditingController(text: args['description'] ?? '');
      _category = args['category'] ?? 'Birthday';
    } else {
      // Initialize empty controllers for "Create" mode
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

  void _saveEvent() {
    if (_formKey.currentState!.validate()) {
      final eventDetails = {
        'name': _nameController.text,
        'date': _dateController.text,
        'location': _locationController.text,
        'description': _descriptionController.text,
        'category': _category,
      };

      // Save or pass back the event data
      Navigator.pop(context, eventDetails);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          ModalRoute.of(context)?.settings.arguments == null
              ? 'Create Event'
              : 'Edit Event',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Event Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Event Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an event name';
                  }
                  return null;
                },
              ),

              // Event Date
              TextFormField(
                controller: _dateController,
                decoration: const InputDecoration(
                  labelText: 'Date',
                  hintText: 'YYYY-MM-DD',
                ),
                keyboardType: TextInputType.datetime,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a valid date';
                  }
                  return null;
                },
              ),

              // Location
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(labelText: 'Location'),
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
                  DropdownMenuItem(value: 'Birthday', child: Text('Birthday')),
                  DropdownMenuItem(value: 'Wedding', child: Text('Wedding')),
                  DropdownMenuItem(
                      value: 'Graduation', child: Text('Graduation')),
                  DropdownMenuItem(value: 'Holiday', child: Text('Holiday')),
                ],
                onChanged: (value) {
                  setState(() {
                    _category = value!;
                  });
                },
                decoration: const InputDecoration(labelText: 'Category'),
              ),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveEvent,
                  child: const Text('Save Event'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
