import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/colors.dart';

class GoldCalculatorPage extends StatefulWidget {
  const GoldCalculatorPage({super.key});

  @override
  State<GoldCalculatorPage> createState() => _GoldCalculatorPageState();
}

class _GoldCalculatorPageState extends State<GoldCalculatorPage> {
  static const double _defaultCurrentWeight = 10.00;
  static const double _defaultWastagePercent = 10;
  static const double _defaultGoldPricePer10g = 150000;
  static const double _defaultPurityPercent = 85;

  late final TextEditingController _currentWeightController;
  late final TextEditingController _wastagePercentController;
  late final TextEditingController _goldPricePer10gController;
  late final TextEditingController _purityPercentController;

  final NumberFormat _rupeeFormatter =
      NumberFormat.currency(locale: 'en_IN', symbol: '₹ ', decimalDigits: 0);

  double currentWeight = _defaultCurrentWeight;
  double wastagePercent = _defaultWastagePercent;
  double goldPricePer10g = _defaultGoldPricePer10g;
  double purityPercent = _defaultPurityPercent;

  String? _currentWeightError;
  String? _wastagePercentError;
  String? _goldPricePer10gError;
  String? _purityPercentError;

  double _finalWeight = 0;
  double _pricePerGram = 0;
  double _totalAmount = 0;
  bool _hasValidationError = false;

  @override
  void initState() {
    super.initState();
    _currentWeightController =
        TextEditingController(text: _defaultCurrentWeight.toStringAsFixed(2));
    _wastagePercentController =
        TextEditingController(text: _defaultWastagePercent.toStringAsFixed(0));
    _goldPricePer10gController =
        TextEditingController(text: _defaultGoldPricePer10g.toStringAsFixed(0));
    _purityPercentController =
        TextEditingController(text: _defaultPurityPercent.toStringAsFixed(0));
    _validateAndCalculate();
  }

  @override
  void dispose() {
    _currentWeightController.dispose();
    _wastagePercentController.dispose();
    _goldPricePer10gController.dispose();
    _purityPercentController.dispose();
    super.dispose();
  }

  void _onInputChanged() {
    setState(_validateAndCalculate);
  }

  void _validateAndCalculate() {
    _currentWeightError = null;
    _wastagePercentError = null;
    _goldPricePer10gError = null;
    _purityPercentError = null;

    final parsedCurrentWeight = _tryParse(_currentWeightController.text);
    final parsedWastagePercent = _tryParse(_wastagePercentController.text);
    final parsedGoldPricePer10g = _tryParse(_goldPricePer10gController.text);
    final parsedPurityPercent = _tryParse(_purityPercentController.text);

    if (parsedCurrentWeight == null || parsedCurrentWeight <= 0) {
      _currentWeightError = 'Weight must be a number greater than 0';
    }

    if (parsedWastagePercent == null || parsedWastagePercent < 0) {
      _wastagePercentError = 'Wastage % must be a number 0 or greater';
    }

    if (parsedGoldPricePer10g == null || parsedGoldPricePer10g <= 0) {
      _goldPricePer10gError =
          'Gold Price per 10g must be a number greater than 0';
    }

    if (parsedPurityPercent == null ||
        parsedPurityPercent <= 0 ||
        parsedPurityPercent > 100) {
      _purityPercentError =
          'Purity % must be greater than 0 and less than or equal to 100';
    }

    _hasValidationError = _currentWeightError != null ||
        _wastagePercentError != null ||
        _goldPricePer10gError != null ||
        _purityPercentError != null;

    if (_hasValidationError) {
      _finalWeight = 0;
      _pricePerGram = 0;
      _totalAmount = 0;
      return;
    }

    currentWeight = parsedCurrentWeight!;
    wastagePercent = parsedWastagePercent!;
    goldPricePer10g = parsedGoldPricePer10g!;
    purityPercent = parsedPurityPercent!;

    final wastageAmount = currentWeight * (wastagePercent / 100);
    final finalWeight = currentWeight + wastageAmount;
    final adjustedPricePer10g = goldPricePer10g * (purityPercent / 100);
    final pricePerGram = adjustedPricePer10g / 10;
    final totalAmount = finalWeight * pricePerGram;

    _finalWeight = finalWeight;
    _pricePerGram = pricePerGram;
    _totalAmount = totalAmount;
  }

  double? _tryParse(String value) {
    final normalized = value.replaceAll(',', '').trim();
    if (normalized.isEmpty) {
      return null;
    }
    return double.tryParse(normalized);
  }

  void _resetDefaults() {
    _currentWeightController.text = _defaultCurrentWeight.toStringAsFixed(2);
    _wastagePercentController.text = _defaultWastagePercent.toStringAsFixed(0);
    _goldPricePer10gController.text = _defaultGoldPricePer10g.toStringAsFixed(0);
    _purityPercentController.text = _defaultPurityPercent.toStringAsFixed(0);

    setState(_validateAndCalculate);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('Gold Calculator'),
        backgroundColor: AppColors.primaryGold,
        foregroundColor: AppColors.textLight,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFD4AF37), Color(0xFFB8860B)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(color: const Color(0xFFB8860B), width: 1.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Jewelry Gold Costing',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Enter weight, wastage, market rate, and purity to compute final costing.',
                      style: TextStyle(
                        color: Color(0xFFFFF7D6),
                        fontSize: 10,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Input Details',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF333333),
                ),
              ),
              const SizedBox(height: 4),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 0.65,
                crossAxisSpacing: 6,
                mainAxisSpacing: 6,
                children: [
                  _buildInputCard(
                    label: 'Current Weight (g)',
                    hintText: 'e.g. 10.00',
                    icon: Icons.scale_rounded,
                    helperText: 'Gross weight in grams',
                    controller: _currentWeightController,
                    errorText: _currentWeightError,
                  ),
                  _buildInputCard(
                    label: 'Wastage (%)',
                    hintText: 'e.g. 10',
                    icon: Icons.auto_graph_rounded,
                    helperText: 'Making/wastage percentage',
                    controller: _wastagePercentController,
                    errorText: _wastagePercentError,
                  ),
                  _buildInputCard(
                    label: 'Gold Price / 10g (₹)',
                    hintText: 'e.g. 150000',
                    icon: Icons.currency_rupee_rounded,
                    helperText: 'Market rate for 10 grams',
                    controller: _goldPricePer10gController,
                    errorText: _goldPricePer10gError,
                  ),
                  _buildInputCard(
                    label: 'Purity (%)',
                    hintText: 'e.g. 85',
                    icon: Icons.verified_rounded,
                    helperText: 'Purity percentage value',
                    controller: _purityPercentController,
                    errorText: _purityPercentError,
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Align(
                alignment: Alignment.centerLeft,
                child: OutlinedButton.icon(
                  onPressed: _resetDefaults,
                  icon: const Icon(Icons.refresh_rounded, size: 16),
                  label: const Text('Reset', style: TextStyle(fontSize: 11)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.secondaryGold,
                    side: const BorderSide(color: Color(0xFFB8860B), width: 1.2),
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 3),
              const Divider(height: 8, color: Color(0xFFE0E0E0)),
              _buildResultTile(
                title: 'Final Weight',
                value: '${_finalWeight.toStringAsFixed(2)} g',
              ),
              const SizedBox(height: 3),
              _buildResultTile(
                title: 'Price per Gram',
                value: _rupeeFormatter.format(_pricePerGram),
              ),
              const SizedBox(height: 4),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryGold,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.secondaryGold, width: 2),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x22000000),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'TOTAL AMOUNT',
                      style: TextStyle(
                        color: Colors.white,
                        letterSpacing: 0.8,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _rupeeFormatter.format(_totalAmount),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        height: 1,
                      ),
                    ),
                    if (_hasValidationError) ...[
                      const SizedBox(height: 4),
                      const Text(
                        'Fix input errors to get valid totals.',
                        style: TextStyle(
                          color: Color(0xFFFFB4B4),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputCard({
    required String label,
    required String hintText,
    required IconData icon,
    required String helperText,
    required TextEditingController controller,
    required String? errorText,
  }) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: errorText == null
              ? const Color(0xFFE0E0E0)
              : AppColors.error.withOpacity(0.45),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: AppColors.primaryGold.withOpacity(0.16),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Icon(
                  icon,
                  size: 12,
                  color: AppColors.secondaryGold,
                ),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF333333),
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      helperText,
                      style: const TextStyle(
                        fontSize: 8,
                        color: Color(0xFF7A7A7A),
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF8F8F8),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: errorText == null
                    ? const Color(0xFFE8E8E8)
                    : AppColors.error.withOpacity(0.35),
              ),
            ),
            child: TextField(
              controller: controller,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
              ],
              onChanged: (_) => _onInputChanged(),
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
                color: Color(0xFF333333),
              ),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: const TextStyle(
                  color: Color(0xFF9E9E9E),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
                prefixIcon: Icon(
                  Icons.edit_note_rounded,
                  color: AppColors.hintColor,
                  size: 14,
                ),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 4,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(height: 1),
          Text(
            errorText ?? ' ',
            maxLines: 1,
            style: TextStyle(
              color: AppColors.error.withOpacity(0.9),
              fontSize: 8,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildResultTile({required String title, required String value}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Color(0xFF666666),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFFD4AF37),
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
