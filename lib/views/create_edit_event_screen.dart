import 'package:flutter/material.dart';
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
  late TextEditingController _nameController;
  late TextEditingController _dateController;
  late TextEditingController _locationController;
  late TextEditingController _descriptionController;
  String _category = 'Birthday';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args = ModalRoute.of(context)?.settings.arguments;

    if (args is Map<dynamic, dynamic>) {
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

  void _saveEvent() {
    if (_formKey.currentState!.validate()) {
      final eventDetails = {
        'name': _nameController.text,
        'date': _dateController.text,
        'location': _locationController.text,
        'description': _descriptionController.text,
        'category': _category,
      };
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
                onPressed: _saveEvent,
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
