import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import '../../../../core/constants/colors.dart';

class MlInsightsPage extends StatefulWidget {
  const MlInsightsPage({super.key});

  @override
  State<MlInsightsPage> createState() => _MlInsightsPageState();
}

class _MlInsightsPageState extends State<MlInsightsPage> {
  static const String _predictHost = 'ml-diamond-price-1.onrender.com';
  static const String _predictPath = '/predict';
  static const Duration _requestTimeout = Duration(seconds: 35);

  final TextEditingController _caratController = TextEditingController();
  final TextEditingController _cutController = TextEditingController();
  final TextEditingController _colorController = TextEditingController();
  final TextEditingController _clarityController = TextEditingController();
  final TextEditingController _depthController = TextEditingController();
  final TextEditingController _tableController = TextEditingController();
  final TextEditingController _xController = TextEditingController();
  final TextEditingController _yController = TextEditingController();
  final TextEditingController _zController = TextEditingController();

  bool _isSubmitting = false;
  String? _resultText;
  String? _errorText;
  String? _selectedCut;
  String? _selectedColor;
  String? _selectedClarity;

  @override
  void initState() {
    super.initState();
    _caratController.text = '1.52';
    _cutController.text = 'Premium';
    _colorController.text = 'F';
    _clarityController.text = 'VS2';
    _selectedCut = _cutController.text;
    _selectedColor = _colorController.text;
    _selectedClarity = _clarityController.text;
    _depthController.text = '62.5';
    _tableController.text = '58.0';
    _xController.text = '7.27';
    _yController.text = '7.33';
    _zController.text = '4.57';
  }

  @override
  void dispose() {
    _caratController.dispose();
    _cutController.dispose();
    _colorController.dispose();
    _clarityController.dispose();
    _depthController.dispose();
    _tableController.dispose();
    _xController.dispose();
    _yController.dispose();
    _zController.dispose();
    super.dispose();
  }

  Future<void> _submitPrediction() async {
    setState(() {
      _isSubmitting = true;
      _resultText = null;
      _errorText = null;
    });

    final payload = {
      'carat': _parseDouble(_caratController.text),
      'cut': _cutController.text.trim(),
      'color': _colorController.text.trim(),
      'clarity': _clarityController.text.trim(),
      'depth': _parseDouble(_depthController.text),
      'table': _parseDouble(_tableController.text),
      'x': _parseDouble(_xController.text),
      'y': _parseDouble(_yController.text),
      'z': _parseDouble(_zController.text),
    };

    if (payload.values.any((value) => value == null || value == '')) {
      setState(() {
        _isSubmitting = false;
        _errorText = 'Please fill all fields with valid values.';
      });
      return;
    }

    try {
      final response = await _postPredictionWithRetry(payload);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final formatted = _formatPredictionResult(response.body);
        setState(() {
          if (formatted != null) {
            _resultText = formatted;
          } else {
            _errorText = 'Prediction failed: Unexpected response format.';
          }
        });
      } else {
        final apiMessage = _extractApiErrorMessage(response.body);
        setState(() {
          _errorText = apiMessage == null
              ? 'Prediction failed: ${response.statusCode}'
              : 'Prediction failed: ${response.statusCode} - $apiMessage';
        });
      }
    } on http.ClientException catch (error) {
      setState(() {
        _errorText = 'Prediction error: ${error.message}. Please try again.';
      });
    } on TimeoutException {
      setState(() {
        _errorText =
            'Prediction error: Request timed out. Server may be waking up, please retry.';
      });
    } on SocketException {
      setState(() {
        _errorText =
            'Prediction error: Network unavailable. Check internet connection and retry.';
      });
    } catch (error) {
      setState(() {
        _errorText = 'Prediction error: $error';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Future<http.Response> _postPredictionWithRetry(
    Map<String, dynamic> payload,
  ) async {
    Future<http.Response> callApi() {
      return http
          .post(
            Uri.https(_predictHost, _predictPath),
            headers: const {
              'Content-Type': 'application/json',
            },
            body: jsonEncode(payload),
          )
          .timeout(_requestTimeout);
    }

    try {
      return await callApi();
    } on TimeoutException {
      await Future<void>.delayed(const Duration(seconds: 2));
      return callApi();
    } on http.ClientException {
      await Future<void>.delayed(const Duration(seconds: 2));
      return callApi();
    } on SocketException {
      await Future<void>.delayed(const Duration(seconds: 2));
      return callApi();
    }
  }

  String? _extractApiErrorMessage(String responseBody) {
    try {
      final decoded = jsonDecode(responseBody);
      if (decoded is Map<String, dynamic>) {
        final message = decoded['message']?.toString().trim();
        if (message != null && message.isNotEmpty) {
          return message;
        }
        final error = decoded['error']?.toString().trim();
        if (error != null && error.isNotEmpty) {
          return error;
        }
      }
    } catch (_) {
      // Ignore non-JSON error bodies.
    }
    return null;
  }

  double? _parseDouble(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return null;
    }
    return double.tryParse(trimmed);
  }

  String? _formatPredictionResult(String responseBody) {
    final dynamic decoded = jsonDecode(responseBody);
    if (decoded is! Map<String, dynamic>) {
      return null;
    }
    final status = decoded['status']?.toString().toLowerCase();
    if (status != null && status != 'success') {
      final message = decoded['message']?.toString();
      return message == null || message.isEmpty
          ? 'Prediction failed.'
          : 'Prediction failed: $message';
    }
    final prediction = decoded['prediction'];
    num? value;
    if (prediction is List && prediction.isNotEmpty) {
      final first = prediction.first;
      if (first is num) {
        value = first;
      } else if (first is String) {
        value = num.tryParse(first);
      }
    } else if (prediction is num) {
      value = prediction;
    } else if (prediction is String) {
      value = num.tryParse(prediction);
    }
    if (value == null) {
      return null;
    }
    final formatted = value.toStringAsFixed(2);
    return 'Estimated price: \u20B9$formatted';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        title: Text(
          'ML Insights',
          style: GoogleFonts.playfairDisplay(
            fontWeight: FontWeight.w700,
            letterSpacing: 0.6,
          ),
        ),
        backgroundColor: AppColors.primaryGold,
        foregroundColor: AppColors.textLight,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 840),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.primaryGold.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: AppColors.primaryGold.withOpacity(0.4),
                          ),
                        ),
                        child: const Icon(
                          Icons.insights,
                          color: AppColors.secondaryGold,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Diamond Price Prediction',
                              style: GoogleFonts.playfairDisplay(
                                fontSize: 26,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Provide precise measurements to estimate the diamond value.',
                              style: GoogleFonts.roboto(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.borderColor,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 24,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _sectionHeader('Core Attributes', 'Describe the diamond profile.'),
                        const SizedBox(height: 16),
                        _buildFieldGrid([
                          _buildNumberField(label: 'Carat', controller: _caratController, hintText: '1.52'),
                          _buildDropdownField(
                            label: 'Cut',
                            value: _selectedCut,
                            items: const [
                              'Ideal',
                              'Premium',
                              'Very Good',
                              'Good',
                              'Fair',
                            ],
                            onChanged: (value) {
                              setState(() {
                                _selectedCut = value;
                                _cutController.text = value ?? '';
                              });
                            },
                          ),
                          _buildDropdownField(
                            label: 'Color',
                            value: _selectedColor,
                            items: const [
                              'G',
                              'E',
                              'F',
                              'H',
                              'D',
                              'I',
                              'J',
                            ],
                            onChanged: (value) {
                              setState(() {
                                _selectedColor = value;
                                _colorController.text = value ?? '';
                              });
                            },
                          ),
                          _buildDropdownField(
                            label: 'Clarity',
                            value: _selectedClarity,
                            items: const [
                              'SI2',
                              'VS2',
                              'SI1',
                              'VS1',
                              'VVS2',
                              'VVS1',
                              'IF',
                              'I1',
                            ],
                            onChanged: (value) {
                              setState(() {
                                _selectedClarity = value;
                                _clarityController.text = value ?? '';
                              });
                            },
                          ),
                        ]),
                        const SizedBox(height: 24),
                        _sectionHeader('Proportions', 'Fine-grained dimensions for accurate scoring.'),
                        const SizedBox(height: 16),
                        _buildFieldGrid([
                          _buildNumberField(label: 'Depth', controller: _depthController, hintText: '62.5'),
                          _buildNumberField(label: 'Table', controller: _tableController, hintText: '58.0'),
                          _buildNumberField(label: 'X', controller: _xController, hintText: '7.27'),
                          _buildNumberField(label: 'Y', controller: _yController, hintText: '7.33'),
                          _buildNumberField(label: 'Z', controller: _zController, hintText: '4.57'),
                        ]),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isSubmitting ? null : _submitPrediction,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryGold,
                              foregroundColor: AppColors.textLight,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: _isSubmitting
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        AppColors.textLight,
                                      ),
                                    ),
                                  )
                                : Text(
                                    'Predict Value',
                                    style: GoogleFonts.roboto(
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.6,
                                    ),
                                  ),
                          ),
                        ),
                        if (_errorText != null) ...[
                          const SizedBox(height: 16),
                          _buildStatusCard(
                            label: 'Request issue',
                            message: _errorText!,
                            background: AppColors.error.withOpacity(0.08),
                            border: AppColors.error.withOpacity(0.35),
                            textColor: AppColors.error,
                          ),
                        ],
                        if (_resultText != null) ...[
                          const SizedBox(height: 16),
                          _buildStatusCard(
                            label: 'Prediction result',
                            message: _resultText ?? '',
                            background: AppColors.success.withOpacity(0.1),
                            border: AppColors.success.withOpacity(0.35),
                            textColor: AppColors.success,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    String? hintText,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextField(
      controller: controller,
      inputFormatters: inputFormatters,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        filled: true,
        fillColor: AppColors.cardBackground,
        labelStyle: GoogleFonts.roboto(
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        hintStyle: GoogleFonts.roboto(color: AppColors.hintColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryGold, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildNumberField({
    required String label,
    required TextEditingController controller,
    String? hintText,
  }) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        filled: true,
        fillColor: AppColors.cardBackground,
        labelStyle: GoogleFonts.roboto(
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        hintStyle: GoogleFonts.roboto(color: AppColors.hintColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryGold, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: AppColors.cardBackground,
        labelStyle: GoogleFonts.roboto(
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryGold, width: 1.5),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down),
          items: items
              .map((item) => DropdownMenuItem<String>(
                    value: item,
                    child: Text(
                      item,
                      style: GoogleFonts.roboto(
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _sectionHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 6,
              height: 24,
              decoration: BoxDecoration(
                color: AppColors.primaryGold,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.playfairDisplay(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: GoogleFonts.roboto(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: 1,
          width: double.infinity,
          color: AppColors.borderColor,
        ),
      ],
    );
  }

  Widget _buildFieldGrid(List<Widget> fields) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final useTwoColumns = constraints.maxWidth >= 560;
        final spacing = 16.0;
        final fieldWidth = useTwoColumns
            ? (constraints.maxWidth - spacing) / 2
            : constraints.maxWidth;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: fields
              .map((field) => SizedBox(width: fieldWidth, child: field))
              .toList(),
        );
      },
    );
  }

  Widget _buildStatusCard({
    required String label,
    required String message,
    required Color background,
    required Color border,
    required Color textColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.roboto(
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            style: GoogleFonts.roboto(
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final upper = newValue.text.toUpperCase();
    return newValue.copyWith(
      text: upper,
      selection: TextSelection.collapsed(offset: upper.length),
    );
  }
}

class _TitleCaseFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final words = newValue.text
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .map((word) {
      final lower = word.toLowerCase();
      return '${lower[0].toUpperCase()}${lower.substring(1)}';
    }).toList();
    final text = words.join(' ');
    return newValue.copyWith(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
