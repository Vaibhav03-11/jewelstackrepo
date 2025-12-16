import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddRudrakshPage extends StatefulWidget {
  const AddRudrakshPage({super.key});

  @override
  State<AddRudrakshPage> createState() => _AddRudrakshPageState();
}

class _AddRudrakshPageState extends State<AddRudrakshPage> {
  final _formKey = GlobalKey<FormState>();

  final _typeOfRudrakshController = TextEditingController();

  List<TextEditingController> _symbolismControllers = [TextEditingController()];
  List<TextEditingController> _healthBenifitsControllers = [TextEditingController()];

  bool _isSubmitting = false;

  @override
  void dispose() {
    _typeOfRudrakshController.dispose();
    _disposeList(_symbolismControllers);
    _disposeList(_healthBenifitsControllers);
    super.dispose();
  }

  void _disposeList(List<TextEditingController> controllers) {
    for (final controller in controllers) {
      controller.dispose();
    }
  }

  void _addField(List<TextEditingController> controllers) {
    setState(() {
      controllers.add(TextEditingController());
    });
  }

  void _removeField(List<TextEditingController> controllers, int index) {
    if (controllers.length <= 1) return;
    setState(() {
      controllers.removeAt(index).dispose();
    });
  }

  List<String> _extractList(List<TextEditingController> controllers) {
    return controllers
        .map((controller) => controller.text.trim())
        .where((value) => value.isNotEmpty)
        .toList();
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _typeOfRudrakshController.clear();

    _disposeList(_symbolismControllers);
    _disposeList(_healthBenifitsControllers);

    _symbolismControllers = [TextEditingController()];
    _healthBenifitsControllers = [TextEditingController()];
    setState(() {});
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;
    final formValid = _formKey.currentState?.validate() ?? false;
    if (!formValid) return;

    final symbolism = _extractList(_symbolismControllers);
    final healthBenifits = _extractList(_healthBenifitsControllers);

    if (symbolism.isEmpty || healthBenifits.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one entry for all list fields.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final data = {
        'type of rudraksh': _typeOfRudrakshController.text.trim(),
        'symbolism': symbolism,
        'health benifits': healthBenifits,
      };

      await FirebaseFirestore.instance.collection('rudrakshdetails').add(data);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Rudraksh details saved successfully.')),
        );
        _resetForm();
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save rudraksh details: $error')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Rudraksh'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTextField(
                  controller: _typeOfRudrakshController,
                  label: 'Type of Rudraksh',
                  validatorMessage: 'Type of rudraksh is required',
                ),
                const SizedBox(height: 12),
                _buildArrayField(
                  label: 'Symbolism',
                  controllers: _symbolismControllers,
                ),
                const SizedBox(height: 12),
                _buildArrayField(
                  label: 'Health Benifits',
                  controllers: _healthBenifitsControllers,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submit,
                    child: _isSubmitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Submit'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String validatorMessage,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      validator: (value) => (value == null || value.trim().isEmpty) ? validatorMessage : null,
    );
  }

  Widget _buildArrayField({
    required String label,
    required List<TextEditingController> controllers,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: Theme.of(context).textTheme.titleMedium),
            IconButton(
              icon: const Icon(Icons.add),
              tooltip: 'Add $label entry',
              onPressed: () => _addField(controllers),
            ),
          ],
        ),
        ...List.generate(controllers.length, (index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: controllers[index],
                    decoration: InputDecoration(
                      labelText: '$label ${index + 1}',
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (controllers.length > 1)
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline),
                    tooltip: 'Remove',
                    onPressed: () => _removeField(controllers, index),
                  ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
