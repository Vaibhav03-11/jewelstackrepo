import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/colors.dart';

class AlloyMeltingCalculatorPage extends StatefulWidget {
  const AlloyMeltingCalculatorPage({super.key});

  @override
  State<AlloyMeltingCalculatorPage> createState() =>
      _AlloyMeltingCalculatorPageState();
}

class _AlloyMeltingCalculatorPageState
    extends State<AlloyMeltingCalculatorPage> {
  static const double _defaultSilverPercent = 50;
  static const double _defaultCopperPercent = 50;
  static const double _defaultOtherPercent = 0;
  final _formKey = GlobalKey<FormState>();

  final _currentWeightController = TextEditingController();
  final _currentPurityController = TextEditingController();
  final _targetPurityController = TextEditingController();
  final _targetPurityPercentController = TextEditingController();
  final _fineGoldPurityController = TextEditingController();
  final _raisingCurrentWeightController = TextEditingController();
  final _raisingCurrentPurityController = TextEditingController();
  final _raisingTargetPurityController = TextEditingController();

  String? _errorText;
  String? _raisingErrorText;
  Map<String, String>? _result;
  _RaisingPurityResult? _raisingResult;

  @override
  void dispose() {
    _currentWeightController.dispose();
    _currentPurityController.dispose();
    _targetPurityController.dispose();
    _targetPurityPercentController.dispose();
    _fineGoldPurityController.dispose();
    _raisingCurrentWeightController.dispose();
    _raisingCurrentPurityController.dispose();
    _raisingTargetPurityController.dispose();
    super.dispose();
  }

  void _calculate() {
    setState(() {
      _errorText = null;
      _result = null;
    });

    final currentWeight = _parseDouble(_currentWeightController.text);
    final currentPurity = _parseDouble(_currentPurityController.text);
    final targetPurity = _parseDouble(_targetPurityController.text);
    final targetPurityPercentInput =
        _parseDouble(_targetPurityPercentController.text);
    final fineGoldPurityInput = _parseDouble(_fineGoldPurityController.text);

    if (currentWeight == null || currentWeight <= 0) {
      _setError('Enter a valid current weight.');
      return;
    }
    if (currentPurity == null || currentPurity <= 0) {
      _setError('Enter a valid current purity.');
      return;
    }

    final currentPercent = _normalizePurityPercent(currentPurity);
    final targetPercent = targetPurityPercentInput != null
        ? _normalizePercent(targetPurityPercentInput)
        : (targetPurity != null
            ? _normalizePurityPercent(targetPurity)
            : null);

    if (targetPercent == null || targetPercent <= 0 || targetPercent >= 100) {
      _setError('Enter a valid target purity percentage.');
      return;
    }

    if (targetPercent < currentPercent) {
      final alloyToAdd =
          currentWeight * ((currentPercent - targetPercent) / targetPercent);

      if (alloyToAdd <= 0) {
        _setError('No alloy needed for the selected target purity.');
        return;
      }
      final targetKarat = (targetPercent / 100.0) * 24.0;
      final silverAdd =
          alloyToAdd * (_defaultSilverPercent / 100.0);
      final copperAdd =
          alloyToAdd * (_defaultCopperPercent / 100.0);
      final otherAdd = alloyToAdd * (_defaultOtherPercent / 100.0);

      setState(() {
        _result = {
          'scenario': 'lower',
          'totalAlloyToAdd': alloyToAdd.toStringAsFixed(2),
          'silverAdd': silverAdd.toStringAsFixed(2),
          'copperAdd': copperAdd.toStringAsFixed(2),
          'otherAdd': otherAdd.toStringAsFixed(2),
          'targetPurityPercent': targetPercent.toStringAsFixed(2),
          'targetKarat': targetKarat.toStringAsFixed(2),
        };
      });
      return;
    }

    final fineGoldPercent = fineGoldPurityInput != null
        ? _normalizePurityPercent(fineGoldPurityInput)
        : 99.5;

    if (fineGoldPercent <= targetPercent || fineGoldPercent >= 100) {
      _setError('Fine gold purity must be above target purity.');
      return;
    }

    final fineGoldToAdd = currentWeight *
        ((targetPercent - currentPercent) /
            (fineGoldPercent - targetPercent));
    final targetKarat = (targetPercent / 100.0) * 24.0;

    setState(() {
      _result = {
        'scenario': 'raise',
        'fineGoldToAdd': fineGoldToAdd.toStringAsFixed(2),
        'targetPurityPercent': targetPercent.toStringAsFixed(2),
        'targetKarat': targetKarat.toStringAsFixed(2),
        'fineGoldPercent': fineGoldPercent.toStringAsFixed(2),
      };
    });
  }

  void _setError(String message) {
    setState(() {
      _errorText = message;
      _result = null;
    });
  }

  void _setRaisingError(String message) {
    setState(() {
      _raisingErrorText = message;
      _raisingResult = null;
    });
  }

  void _calculateRaisingPurity() {
    setState(() {
      _raisingErrorText = null;
      _raisingResult = null;
    });

    final currentWeight = _parseDouble(_raisingCurrentWeightController.text);
    final currentPurity = _parseDouble(_raisingCurrentPurityController.text);
    final targetPurity = _parseDouble(_raisingTargetPurityController.text);

    if (currentWeight == null || currentWeight <= 0) {
      _setRaisingError('Enter a valid current weight.');
      return;
    }
    if (currentPurity == null || currentPurity <= 0) {
      _setRaisingError('Enter a valid current purity percentage.');
      return;
    }
    if (targetPurity == null || targetPurity <= 0 || targetPurity >= 100) {
      _setRaisingError('Enter a valid target purity percentage.');
      return;
    }
    if (targetPurity <= currentPurity) {
      _setRaisingError('Target purity must be higher than current purity.');
      return;
    }

    final goldToAdd =
        (currentWeight * currentPurity) / (targetPurity * 10.0);
    final totalNewWeight = currentWeight + goldToAdd;

    setState(() {
      _raisingResult = _RaisingPurityResult(
        goldToAdd: goldToAdd,
        totalNewWeight: totalNewWeight,
        finalPurity: targetPurity,
      );
    });
  }

  double? _parseDouble(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return null;
    }
    return double.tryParse(trimmed);
  }

  double _normalizePercent(double value) {
    if (value <= 1) {
      return value * 100.0;
    }
    if (value > 100 && value <= 1000) {
      return value / 10.0;
    }
    return value;
  }

  double _normalizePurityPercent(double value) {
    if (value <= 1) {
      return value * 100.0;
    }
    if (value <= 24) {
      return (value / 24.0) * 100.0;
    }
    if (value > 100 && value <= 1000) {
      return value / 10.0;
    }
    return value;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('Alloy & Melting Calculator'),
        backgroundColor: AppColors.primaryGold,
        foregroundColor: AppColors.textLight,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeroCard(),
                const SizedBox(height: 20),
                _buildInputCard(),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _calculate,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGold,
                      foregroundColor: AppColors.textLight,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 2,
                    ),
                    child: const Text('Calculate'),
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
                if (_result != null) ...[
                  const SizedBox(height: 16),
                  _buildStatusCard(
                    label: 'Calculation result',
                    message: _buildResultText(_result!),
                    background: AppColors.success.withOpacity(0.08),
                    border: AppColors.success.withOpacity(0.35),
                    textColor: AppColors.success,
                  ),
                ],
                const SizedBox(height: 28),
                _buildRaisingPurityCard(),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _calculateRaisingPurity,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGold,
                      foregroundColor: AppColors.textLight,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 2,
                    ),
                    child: const Text('Calculate Raising Purity'),
                  ),
                ),
                if (_raisingErrorText != null) ...[
                  const SizedBox(height: 16),
                  _buildStatusCard(
                    label: 'Request issue',
                    message: _raisingErrorText!,
                    background: AppColors.error.withOpacity(0.08),
                    border: AppColors.error.withOpacity(0.35),
                    textColor: AppColors.error,
                  ),
                ],
                if (_raisingResult != null) ...[
                  const SizedBox(height: 16),
                  _buildStatusCard(
                    label: 'Raising purity result',
                    message: _buildRaisingPurityResultText(_raisingResult!),
                    background: AppColors.success.withOpacity(0.08),
                    border: AppColors.success.withOpacity(0.35),
                    textColor: AppColors.success,
                  ),
                ],
                const SizedBox(height: 28),
                _buildSignatureBlock(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          colors: [
            AppColors.primaryGold.withOpacity(0.18),
            AppColors.cardBackground,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: AppColors.primaryGold.withOpacity(0.25)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryGold.withOpacity(0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.auto_fix_high,
              color: AppColors.secondaryGold,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Fine Gold Constancy',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Balance purity while preserving pure gold mass.',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader('Inputs', 'Enter the current and target purity.'),
          const SizedBox(height: 16),
          _buildFieldGrid([
            _buildNumberField(
              label: 'Current Weight',
              controller: _currentWeightController,
              hintText: '100',
              helperText: 'In grams',
              prefixIcon: Icons.scale,
              suffixText: 'g',
            ),
            _buildNumberField(
              label: 'Current Purity',
              controller: _currentPurityController,
              hintText: '22',
              helperText: 'Karat or percent',
              prefixIcon: Icons.workspace_premium,
            ),
            _buildNumberField(
              label: 'Target Purity (K)',
              controller: _targetPurityController,
              hintText: '18',
              helperText: 'Karat target',
              prefixIcon: Icons.trending_down,
            ),
            _buildNumberField(
              label: 'Target Purity (%)',
              controller: _targetPurityPercentController,
              hintText: '75',
              helperText: 'Percent target',
              prefixIcon: Icons.percent,
              suffixText: '%',
            ),
            _buildNumberField(
              label: 'Fine Gold Purity',
              controller: _fineGoldPurityController,
              hintText: '99.5',
              helperText: 'Used for purity raise',
              prefixIcon: Icons.auto_fix_high,
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildRaisingPurityCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader('Raising Purity', 'Add pure gold to hit your target.'),
          const SizedBox(height: 16),
          _buildFieldGrid([
            _buildNumberField(
              label: 'Current Weight',
              controller: _raisingCurrentWeightController,
              hintText: '10',
              helperText: 'In grams',
              prefixIcon: Icons.scale,
              suffixText: 'g',
            ),
            _buildNumberField(
              label: 'Current Purity (%)',
              controller: _raisingCurrentPurityController,
              hintText: '85',
              helperText: 'Current percent',
              prefixIcon: Icons.percent,
              suffixText: '%',
            ),
            _buildNumberField(
              label: 'Target Purity (%)',
              controller: _raisingTargetPurityController,
              hintText: '91.6',
              helperText: 'Target percent',
              prefixIcon: Icons.trending_up,
              suffixText: '%',
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildNumberField({
    required String label,
    required TextEditingController controller,
    String? hintText,
    String? helperText,
    IconData? prefixIcon,
    String? suffixText,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        helperText: helperText,
        prefixIcon: prefixIcon == null
            ? null
            : Icon(prefixIcon, color: AppColors.secondaryGold),
        suffixText: suffixText,
        filled: true,
        fillColor: AppColors.cardBackground,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
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
          children:
              fields.map((field) => SizedBox(width: fieldWidth, child: field)).toList(),
        );
      },
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
                style: const TextStyle(
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
          style: const TextStyle(
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
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            style: TextStyle(color: textColor),
          ),
        ],
      ),
    );
  }

  String _buildResultText(Map<String, String> result) {
    final targetLine =
        'Target purity: ${result['targetPurityPercent']}% (${result['targetKarat']}K)';
    if (result['scenario'] == 'raise') {
      return '$targetLine\n'
          'Fine gold purity: ${result['fineGoldPercent']}%\n'
          'Add fine gold: ${result['fineGoldToAdd']} g';
    }
    return '$targetLine\n'
        'Total alloy to add: ${result['totalAlloyToAdd']} g\n'
        'Add silver: ${result['silverAdd']} g\n'
        'Add copper: ${result['copperAdd']} g\n'
        'Add other: ${result['otherAdd']} g';
  }

  String _buildRaisingPurityResultText(_RaisingPurityResult result) {
    final goldToAdd = result.goldToAdd.toStringAsFixed(3);
    final totalWeight = result.totalNewWeight.toStringAsFixed(3);
    final finalPurity = result.finalPurity.toStringAsFixed(1);
    return 'Add $goldToAdd g of Pure Gold. Total Weight will be '
        '$totalWeight g with $finalPurity% purity.';
  }
}

class _RaisingPurityResult {
  const _RaisingPurityResult({
    required this.goldToAdd,
    required this.totalNewWeight,
    required this.finalPurity,
  });

  final double goldToAdd;
  final double totalNewWeight;
  final double finalPurity;
}

class _SignatureTag extends StatelessWidget {
  const _SignatureTag(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primaryGold.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primaryGold.withOpacity(0.35)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: AppColors.secondaryGold,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

Widget _buildSignatureBlock() {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(18),
      gradient: LinearGradient(
        colors: [
          AppColors.primaryGold.withOpacity(0.08),
          AppColors.cardBackground,
          AppColors.primaryGold.withOpacity(0.05),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      border: Border.all(color: AppColors.primaryGold.withOpacity(0.2)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primaryGold.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primaryGold.withOpacity(0.3)),
              ),
              child: const Icon(
                Icons.workspace_premium,
                size: 18,
                color: AppColors.secondaryGold,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  '#jewelstack',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: 0.3,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Crafted in PESU',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                    letterSpacing: 0.4,
                  ),
                ),
              ],
            ),
            const Spacer(),
            _SignatureTag('#caring gold smith'),
          ],
        ),
        const SizedBox(height: 14),
        Container(
          height: 1,
          width: double.infinity,
          color: AppColors.primaryGold.withOpacity(0.2),
        ),
        const SizedBox(height: 12),
        const Text(
          'Made for India. Built for every jeweler who values precision.',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
            letterSpacing: 0.3,
          ),
        ),
      ],
    ),
  );
}
