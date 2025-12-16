import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddGemstonesPage extends StatefulWidget {
  const AddGemstonesPage({super.key});

  @override
  State<AddGemstonesPage> createState() => _AddGemstonesPageState();
}

class _AddGemstonesPageState extends State<AddGemstonesPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _primaryGemstoneController = TextEditingController();
  final _alternativeController = TextEditingController();
  final _mantraController = TextEditingController();

  List<TextEditingController> _qualitiesControllers = [TextEditingController()];
  List<TextEditingController> _wearingInstructionsControllers = [TextEditingController()];
  List<TextEditingController> _benifitsControllers = [TextEditingController()];

  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _primaryGemstoneController.dispose();
    _alternativeController.dispose();
    _mantraController.dispose();
    _disposeList(_qualitiesControllers);
    _disposeList(_wearingInstructionsControllers);
    _disposeList(_benifitsControllers);
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
    _nameController.clear();
    _primaryGemstoneController.clear();
    _alternativeController.clear();
    _mantraController.clear();

    _disposeList(_qualitiesControllers);
    _disposeList(_wearingInstructionsControllers);
    _disposeList(_benifitsControllers);

    _qualitiesControllers = [TextEditingController()];
    _wearingInstructionsControllers = [TextEditingController()];
    _benifitsControllers = [TextEditingController()];
    setState(() {});
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;
    final formValid = _formKey.currentState?.validate() ?? false;
    if (!formValid) return;

    final qualities = _extractList(_qualitiesControllers);
    final wearingInstructions = _extractList(_wearingInstructionsControllers);
    final benifits = _extractList(_benifitsControllers);

    if (qualities.isEmpty || wearingInstructions.isEmpty || benifits.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one entry for all list fields.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await FirebaseFirestore.instance.collection('gemstone').add({
        'name': _nameController.text.trim(),
        'primaryGemstone': _primaryGemstoneController.text.trim(),
        'alternative': _alternativeController.text.trim(),
        'qualities': qualities,
        'wearingInstructions': wearingInstructions,
        'mantra': _mantraController.text.trim(),
        'benifits': benifits,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gemstone saved successfully.')),
        );
        _resetForm();
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save gemstone: $error')),
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
        title: const Text('Add Gemstone'),
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
                  controller: _nameController,
                  label: 'Name',
                  validatorMessage: 'Name is required',
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: _primaryGemstoneController,
                  label: 'Primary Gemstone',
                  validatorMessage: 'Primary gemstone is required',
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: _alternativeController,
                  label: 'Alternative',
                  validatorMessage: 'Alternative is required',
                ),
                const SizedBox(height: 12),
                _buildArrayField(
                  label: 'Qualities',
                  controllers: _qualitiesControllers,
                ),
                const SizedBox(height: 12),
                _buildArrayField(
                  label: 'Wearing Instructions',
                  controllers: _wearingInstructionsControllers,
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: _mantraController,
                  label: 'Mantra',
                  validatorMessage: 'Mantra is required',
                ),
                const SizedBox(height: 12),
                _buildArrayField(
                  label: 'Benifits',
                  controllers: _benifitsControllers,
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