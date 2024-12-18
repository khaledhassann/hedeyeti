import 'package:flutter/material.dart';
import 'package:hedeyeti/services/firebase_helper.dart';
import '../models/Event.dart';
import '../services/database_helper.dart';

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
  String? _eventId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;

    if (args is Event) {
      _eventId = args.id;
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

  Future<void> _saveEventLocally() async {
    final dbHelper = DatabaseHelper();
    final currentUser = await dbHelper.getUser();

    final event = Event(
      id: _eventId ?? DateTime.now().toIso8601String(),
      name: _nameController.text,
      date: DateTime.parse(_dateController.text),
      category: _category,
      location: _locationController.text,
      description: _descriptionController.text,
      userId: currentUser.id,
      isPublished: false,
    );

    await dbHelper.insertEvent(event.toSQLite());
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Event saved locally!'),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_eventId == null ? 'Create Event' : 'Edit Event'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text(
                'Event Details',
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
                          labelText: 'Event Name',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => value == null || value.isEmpty
                            ? 'Please enter an event name'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _dateController,
                        decoration: const InputDecoration(
                          labelText: 'Event Date',
                          hintText: 'YYYY-MM-DD',
                          border: OutlineInputBorder(),
                        ),
                        readOnly: true,
                        onTap: () => _selectDate(context),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _locationController,
                        decoration: const InputDecoration(
                          labelText: 'Location',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => value == null || value.isEmpty
                            ? 'Please enter a location'
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
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a description';
                          } else {
                            return null;
                          }
                        },
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
                            value: 'Birthday',
                            child: Text('Birthday'),
                          ),
                          DropdownMenuItem(
                            value: 'Wedding',
                            child: Text('Wedding'),
                          ),
                          DropdownMenuItem(
                            value: 'Graduation',
                            child: Text('Graduation'),
                          ),
                          DropdownMenuItem(
                            value: 'Holiday',
                            child: Text('Holiday'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveEventLocally,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                ),
                child: const Text('Save Event'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
