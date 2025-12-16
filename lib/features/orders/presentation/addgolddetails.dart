import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddGoldDetailsPage extends StatefulWidget {
  const AddGoldDetailsPage({super.key});

  @override
  State<AddGoldDetailsPage> createState() => _AddGoldDetailsPageState();
}

class _AddGoldDetailsPageState extends State<AddGoldDetailsPage> {
  final _formKey = GlobalKey<FormState>();

  final _colorOfGoldController = TextEditingController();
  final _caratOfGoldController = TextEditingController();
  final _finenessController = TextEditingController();
  final _goldController = TextEditingController();
  final _silverController = TextEditingController();
  final _copperController = TextEditingController();
  final _otherController = TextEditingController();

  bool _isSubmitting = false;

  @override
  void dispose() {
    _colorOfGoldController.dispose();
    _caratOfGoldController.dispose();
    _finenessController.dispose();
    _goldController.dispose();
    _silverController.dispose();
    _copperController.dispose();
    _otherController.dispose();
    super.dispose();
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _colorOfGoldController.clear();
    _caratOfGoldController.clear();
    _finenessController.clear();
    _goldController.clear();
    _silverController.clear();
    _copperController.clear();
    _otherController.clear();
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;
    final formValid = _formKey.currentState?.validate() ?? false;
    if (!formValid) return;

    setState(() => _isSubmitting = true);
    try {
      final data = {
        'color of gold': _colorOfGoldController.text.trim(),
        'carat of gold': _caratOfGoldController.text.trim(),
        'fineness': _finenessController.text.trim(),
        'gold': _goldController.text.trim(),
        'silver': _silverController.text.trim(),
        'copper': _copperController.text.trim(),
        'other': _otherController.text.trim(),
      };
      
      await FirebaseFirestore.instance.collection('golddetails').add(data);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gold details saved successfully.')),
        );
        _resetForm();
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save gold details: $error')),
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
        title: const Text('Add Gold Details'),
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
                  controller: _colorOfGoldController,
                  label: 'Color of Gold',
                  validatorMessage: 'Color of gold is required',
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: _caratOfGoldController,
                  label: 'Carat of Gold',
                  validatorMessage: 'Carat of gold is required',
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: _finenessController,
                  label: 'Fineness',
                  validatorMessage: 'Fineness is required',
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: _goldController,
                  label: 'Gold',
                  validatorMessage: 'Gold is required',
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: _silverController,
                  label: 'Silver',
                  validatorMessage: 'Silver is required',
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: _copperController,
                  label: 'Copper',
                  validatorMessage: 'Copper is required',
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: _otherController,
                  label: 'Other',
                  validatorMessage: 'Other is required',
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
}
