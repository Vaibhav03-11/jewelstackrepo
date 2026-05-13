import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart' show NumberFormat;
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../auth/application/auth_service.dart';
import '../../../../core/widgets/shop_app_drawer.dart';
import '../../../../core/widgets/metal_price_ticker.dart';

// Color Palette
class AppColors {
  static const Color primaryGold = Color(0xFFD4AF37);
  static const Color secondaryGold = Color(0xFFB8860B);
  static const Color accentGold = Color(0xFFFFD700);
  static const Color darkBackground = Color(0xFF1A1A1A);
  static const Color lightBackground = Color(0xFFF8F8F8);
  static const Color textPrimary = Color(0xFF333333);
  static const Color textSecondary = Color(0xFF666666);
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color cardBackground = Color(0xFFFAF9F6);
  static const Color borderColor = Color(0xFFE8E6E);
}

class DetailsPage extends StatefulWidget {
  const DetailsPage({super.key});

  @override
  State<DetailsPage> createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  static const String _goldApiKey = 'goldapi-3o7yqsmfwlwyiv-io';
  static const String _goldApiUrl = 'https://www.goldapi.io/api/XAU/INR';
  static const String _silverApiUrl = 'https://www.goldapi.io/api/XAG/INR';
  static const Duration _tickerRefreshInterval = Duration(minutes: 30);

  String _selectedCategory = 'Gold';
  Future<MetalTickerData>? _tickerFuture;
  Timer? _tickerRefreshTimer;

  String _profileName = '';
  String _profileShopName = '';
  String _profileShopLocation = '';
  String _profileMobile = '';
  bool _isProfileExpanded = false;

  @override
  void initState() {
    super.initState();
    _tickerFuture = _fetchTickerData();
    _tickerRefreshTimer = Timer.periodic(_tickerRefreshInterval, (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _tickerFuture = _fetchTickerData();
      });
    });
  }

  @override
  void dispose() {
    _tickerRefreshTimer?.cancel();
    super.dispose();
  }

  Future<MetalTickerData> _fetchTickerData() async {
    final results = await Future.wait([
      _fetchMetalPrice(label: 'Gold 24K', url: _goldApiUrl),
      _fetchMetalPrice(label: 'Silver', url: _silverApiUrl),
    ]);

    return MetalTickerData(
      gold: results[0],
      silver: results[1],
      updatedAt: DateTime.now(),
    );
  }

  Future<MetalPrice> _fetchMetalPrice({
    required String label,
    required String url,
  }) async {
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'x-access-token': _goldApiKey,
        'Content-Type': 'application/json',
      },
    );
    print("--> ${response.body}");
    if (response.statusCode != 200) {
      throw Exception('Price fetch failed: ${response.statusCode}');
    }

    final payload = jsonDecode(response.body) as Map<String, dynamic>;
    final rawValue = payload['price_gram_24k'] ??
        payload['price_gram_999'] ??
        payload['price'] ??
        payload['bid'];
    final price = rawValue is num ? rawValue.toDouble() : double.tryParse('$rawValue');

    return MetalPrice(label: label, pricePerGram: price);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Jewel Stack',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            fontSize: 26,
            letterSpacing: 1.5,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.primaryGold,
        foregroundColor: Colors.white,
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.4),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: const MetalPriceTicker(),
        ),
      ),
      drawer: const ShopAppDrawer(),
      body: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.primaryGold.withOpacity(0.2),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryGold.withOpacity(0.08),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                child: Row(
                  children: [
                    _buildPremiumChip(
                      label: ' Gold',
                      isSelected: _selectedCategory == 'Gold',
                      accentColor: AppColors.primaryGold,
                      onTap: () => setState(() => _selectedCategory = 'Gold'),
                    ),
                    _buildPremiumChip(
                      label: ' Rudraksh',
                      isSelected: _selectedCategory == 'Rudraksh',
                      accentColor: const Color(0xFF8B7355),
                      onTap: () => setState(() => _selectedCategory = 'Rudraksh'),
                    ),
                    _buildPremiumChip(
                      label: ' Gemstones',
                      isSelected: _selectedCategory == 'Gemstones',
                      accentColor: const Color(0xFF6B46C1),
                      onTap: () => setState(() => _selectedCategory = 'Gemstones'),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: _selectedCategory == 'Gold'
                  ? const GoldDetailsTab()
                  : _selectedCategory == 'Rudraksh'
                      ? const RudrakshDetailsTab()
                      : const GemstonesDetailsTab(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumChip({
    required String label,
    required bool isSelected,
    required Color accentColor,
    required VoidCallback onTap,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? accentColor : Colors.white,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: accentColor.withOpacity(isSelected ? 0 : 0.4),
              width: 2,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: accentColor.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            style: GoogleFonts.poppins(
              color: isSelected ? Colors.white : accentColor,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
              fontSize: 15,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ),
    );
  }

  bool get _hasProfileData {
    return _profileName.isNotEmpty ||
        _profileShopName.isNotEmpty ||
        _profileShopLocation.isNotEmpty ||
        _profileMobile.isNotEmpty;
  }

  Widget _buildProfileCard(BuildContext context) {
    return InkWell(
      onTap: () => setState(() => _isProfileExpanded = !_isProfileExpanded),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderColor),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryGold.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Profile',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Icon(
                  _isProfileExpanded ? Icons.expand_less : Icons.expand_more,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 6),
                TextButton.icon(
                  onPressed: () => _showProfileEditor(context),
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Edit'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primaryGold,
                    textStyle: GoogleFonts.roboto(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            if (_isProfileExpanded)
              if (!_hasProfileData)
                Text(
                  'Add your details to personalize the drawer.',
                  style: GoogleFonts.roboto(
                    color: AppColors.textSecondary,
                    fontSize: 12.5,
                  ),
                )
              else ...[
                _buildProfileInfoRow('Name', _profileName),
                _buildProfileInfoRow('Shop', _profileShopName),
                _buildProfileInfoRow('Location', _profileShopLocation),
                _buildProfileInfoRow('Mobile', _profileMobile),
              ],
          ],
        ),
      ),
    );
  }

  Widget _buildProfileInfoRow(String label, String value) {
    if (value.trim().isEmpty) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: GoogleFonts.roboto(
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
              fontSize: 12.5,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.roboto(
                color: AppColors.textPrimary,
                fontSize: 12.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showProfileEditor(BuildContext context) {
    final nameController = TextEditingController(text: _profileName);
    final shopController = TextEditingController(text: _profileShopName);
    final locationController = TextEditingController(text: _profileShopLocation);
    final mobileController = TextEditingController(text: _profileMobile);

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: Text(
            'Edit Profile',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w700,
              fontSize: 18,
              color: AppColors.textPrimary,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildProfileField('User name', nameController),
                const SizedBox(height: 12),
                _buildProfileField('Shop name', shopController),
                const SizedBox(height: 12),
                _buildProfileField('Shop location', locationController),
                const SizedBox(height: 12),
                _buildProfileField(
                  'Mobile number',
                  mobileController,
                  keyboardType: TextInputType.phone,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                'Cancel',
                style: GoogleFonts.roboto(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _profileName = nameController.text.trim();
                  _profileShopName = shopController.text.trim();
                  _profileShopLocation = locationController.text.trim();
                  _profileMobile = mobileController.text.trim();
                });
                Navigator.of(dialogContext).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGold,
                foregroundColor: Colors.white,
              ),
              child: Text(
                'Save',
                style: GoogleFonts.roboto(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildProfileField(
    String label,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryGold),
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          contentPadding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGold.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.primaryGold.withOpacity(0.25),
                      ),
                    ),
                    child: const Icon(
                      Icons.auto_awesome,
                      color: AppColors.primaryGold,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'About JewelStack',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Purpose-built for jewelry retailers and artisans.',
                style: GoogleFonts.roboto(
                  fontSize: 12.5,
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
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'At JewelStack, we believe small jewelry businesses and artisans '
                  'deserve the same powerful tools as large retailers. The jewelry '
                  'industry often struggles with challenges like inventory '
                  'mismanagement, price volatility, and inefficient order '
                  'processing. Traditional manual systems simply do not provide the '
                  'real-time insights needed to thrive in today’s market.',
                  style: GoogleFonts.roboto(
                    fontSize: 14,
                    height: 1.55,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'That is why we built JewelStack — a mobile-first jewelry '
                  'inventory management system designed to transform everyday '
                  'operations into streamlined digital workflows.',
                  style: GoogleFonts.roboto(
                    fontSize: 14,
                    height: 1.55,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGold.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primaryGold.withOpacity(0.2),
                    ),
                  ),
                  child: Text(
                    'Created by Vaibhav and designed at PES University.',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                'Close',
                style: GoogleFonts.roboto(
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryGold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showContactSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
          decoration: const BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Contact Us',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'We are here to help you quickly.',
                style: GoogleFonts.roboto(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              _buildContactTile(
                icon: Icons.email_outlined,
                label: 'Email',
                value: 'vaibhavsureshkurdekar@gmail.com',
                color: AppColors.primaryGold,
                onTap: () => _launchExternal(
                  'mailto:vaibhavsureshkurdekar@gmail.com',
                ),
              ),
              const SizedBox(height: 12),
              _buildContactTile(
                icon: Icons.chat_bubble_outline,
                label: 'WhatsApp',
                value: '+91 8904064179',
                color: const Color(0xFF25D366),
                onTap: () => _launchExternal(
                  'https://wa.me/918904064179',
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContactTile({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.borderColor),
            color: Colors.white,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: GoogleFonts.roboto(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value,
                      style: GoogleFonts.roboto(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: color.withOpacity(0.7)),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _launchExternal(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to open the link.')),
        );
      }
    }
  }
}

class MetalPrice {
  final String label;
  final double? pricePerGram;

  const MetalPrice({
    required this.label,
    required this.pricePerGram,
  });
}

class MetalTickerData {
  final MetalPrice gold;
  final MetalPrice silver;
  final DateTime updatedAt;

  const MetalTickerData({
    required this.gold,
    required this.silver,
    required this.updatedAt,
  });
}

class PriceTickerBar extends StatefulWidget {
  final Future<MetalTickerData>? pricesFuture;

  const PriceTickerBar({
    super.key,
    required this.pricesFuture,
  });

  @override
  State<PriceTickerBar> createState() => _PriceTickerBarState();
}

class _PriceTickerBarState extends State<PriceTickerBar> {
  final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.darkBackground, Color(0xFF101010)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        border: const Border(
          top: BorderSide(color: AppColors.primaryGold, width: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: FutureBuilder<MetalTickerData>(
        future: widget.pricesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Row(
              children: [
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(AppColors.accentGold),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Loading prices...',
                  style: GoogleFonts.roboto(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            );
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return Text(
              'Prices unavailable',
              style: GoogleFonts.roboto(
                color: Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            );
          }

          final data = snapshot.data!;
          final goldText = _formatPrice(data.gold);
          final silverText = _formatPrice(data.silver);
          final tickerText = '$goldText   •   $silverText';

          return TickerTape(
            text: tickerText,
            style: GoogleFonts.poppins(
              color: AppColors.accentGold.withOpacity(0.75),
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.4,
              shadows: [
                Shadow(
                  color: AppColors.primaryGold.withOpacity(0.6),
                  blurRadius: 6,
                ),
              ],
            ),
            duration: const Duration(seconds: 22),
          );
        },
      ),
    );
  }

  String _formatPrice(MetalPrice price) {
    final value = price.pricePerGram;
    if (value == null) {
      return '${price.label}: --/g';
    }
    return '${price.label}: ${_currencyFormat.format(value)}/g';
  }
}

class TickerTape extends StatefulWidget {
  final String text;
  final TextStyle style;
  final Duration duration;

  const TickerTape({
    super.key,
    required this.text,
    required this.style,
    required this.duration,
  });

  @override
  State<TickerTape> createState() => _TickerTapeState();
}

class _TickerTapeState extends State<TickerTape> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat();
  }

  @override
  void didUpdateWidget(TickerTape oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.duration != widget.duration) {
      _controller.duration = widget.duration;
    }
    if (oldWidget.text != widget.text) {
      _controller
        ..reset()
        ..repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final displayText = '${widget.text}     ${widget.text}';
        final textPainter = TextPainter(
          text: TextSpan(text: displayText, style: widget.style),
          textDirection: TextDirection.ltr,
        )..layout();
        final textWidth = textPainter.width;
        final containerWidth = constraints.maxWidth;

        if (textWidth <= containerWidth) {
          return Align(
            alignment: Alignment.centerLeft,
            child: Text(widget.text, style: widget.style),
          );
        }

        final totalDistance = containerWidth + textWidth;

        return ClipRect(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final dx = containerWidth - (totalDistance * _controller.value);
              return Transform.translate(
                offset: Offset(dx, 0),
                child: child,
              );
            },
            child: Text(displayText, style: widget.style),
          ),
        );
      },
    );
  }
}

class GoldDetailsTab extends StatelessWidget {
  const GoldDetailsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('golddetails').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error: ${snapshot.error}',
              style: GoogleFonts.roboto(color: AppColors.error),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(AppColors.primaryGold),
            ),
          );
        }

        final docs = snapshot.data?.docs ?? [];

        if (docs.isEmpty) {
          return Center(
            child: Text(
              'No gold details found.',
              style: GoogleFonts.roboto(
                color: AppColors.textSecondary,
                fontSize: 16,
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.primaryGold.withOpacity(0.25),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryGold.withOpacity(0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Theme(
                  data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGold,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryGold.withOpacity(0.35),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: const Icon(Icons.diamond, color: Colors.white, size: 24),
                    ),
                    title: Text(
                      data['color of gold'] ?? 'N/A',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                        color: AppColors.textPrimary,
                        letterSpacing: 0.3,
                      ),
                    ),
                    subtitle: Text(
                      'Carat: ${data['carat of gold'] ?? 'N/A'} • Fineness: ${data['fineness'] ?? 'N/A'}',
                      style: GoogleFonts.roboto(
                        color: AppColors.primaryGold.withOpacity(0.7),
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppColors.lightBackground,
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(16),
                            bottomRight: Radius.circular(16),
                          ),
                          border: Border(
                            top: BorderSide(
                              color: AppColors.primaryGold.withOpacity(0.15),
                              width: 1,
                            ),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildPremiumDetailRow('Gold Content', data['gold'] ?? 'N/A', AppColors.primaryGold),
                            _buildPremiumDetailRow('Silver Content', data['silver'] ?? 'N/A', const Color(0xFFC0C0C0)),
                            _buildPremiumDetailRow('Copper Content', data['copper'] ?? 'N/A', const Color(0xFFB87333)),
                            _buildPremiumDetailRow('Other Metals', data['other'] ?? 'N/A', const Color(0xFF9CA3AF)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
            );
          },
        );
      },
    );
  }

  Widget _buildPremiumDetailRow(String label, String value, Color accentColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 4,
            height: 24,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [accentColor, accentColor.withOpacity(0.5)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: GoogleFonts.roboto(
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: GoogleFonts.montserrat(
                fontWeight: FontWeight.w600,
                color: accentColor,
                fontSize: 14,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class RudrakshDetailsTab extends StatelessWidget {
  const RudrakshDetailsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('rudrakshdetails').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error: ${snapshot.error}',
              style: GoogleFonts.roboto(color: AppColors.error),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(AppColors.primaryGold),
            ),
          );
        }

        final docs = snapshot.data?.docs ?? [];

        if (docs.isEmpty) {
          return Center(
            child: Text(
              'No rudraksh details found.',
              style: GoogleFonts.roboto(
                color: AppColors.textSecondary,
                fontSize: 16,
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            final symbolism = (data['symbolism'] as List<dynamic>?)?.cast<String>() ?? [];
            final healthBenifits = (data['health benifits'] as List<dynamic>?)?.cast<String>() ?? [];

            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFF8B7355).withOpacity(0.25),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF8B7355).withOpacity(0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
                child: Theme(
                  data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF5D4037),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF5D4037).withOpacity(0.35),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: const Icon(Icons.grain, color: Colors.white, size: 24),
                    ),
                    title: Text(
                      data['type of rudraksh'] ?? 'N/A',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                        color: AppColors.textPrimary,
                        letterSpacing: 0.3,
                      ),
                    ),
                    subtitle: Text(
                      'Sacred Spiritual Bead',
                      style: GoogleFonts.roboto(
                        color: const Color(0xFF8B7355).withOpacity(0.7),
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppColors.lightBackground,
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(16),
                            bottomRight: Radius.circular(16),
                          ),
                          border: Border(
                            top: BorderSide(
                              color: const Color(0xFF8B7355).withOpacity(0.15),
                              width: 1,
                            ),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (symbolism.isNotEmpty)
                              _buildPremiumArrayRow('Symbolism', symbolism, const Color(0xFF8B7355)),
                            if (symbolism.isNotEmpty && healthBenifits.isNotEmpty)
                              const SizedBox(height: 20),
                            if (healthBenifits.isNotEmpty)
                              _buildPremiumArrayRow('Health Benefits', healthBenifits, const Color(0xFFA1887F)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
            );
          },
        );
      },
    );
  }

  Widget _buildPremiumArrayRow(String label, List<String> items, Color accentColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 24,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [accentColor, accentColor.withOpacity(0.5)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700,
                color: accentColor,
                fontSize: 14,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...items.asMap().entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(left: 20, bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '◆',
                  style: TextStyle(
                    color: accentColor.withOpacity(0.6),
                    fontSize: 8,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    entry.value,
                    style: GoogleFonts.roboto(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

class GemstonesDetailsTab extends StatelessWidget {
  const GemstonesDetailsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('gemstone').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error: ${snapshot.error}',
              style: GoogleFonts.roboto(color: AppColors.error),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(AppColors.primaryGold),
            ),
          );
        }

        final docs = snapshot.data?.docs ?? [];

        if (docs.isEmpty) {
          return Center(
            child: Text(
              'No gemstone details found.',
              style: GoogleFonts.roboto(
                color: AppColors.textSecondary,
                fontSize: 16,
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            final qualities = (data['qualities'] as List<dynamic>?)?.cast<String>() ?? [];
            final wearingInstructions = (data['wearingInstructions'] as List<dynamic>?)?.cast<String>() ?? [];
            final benifits = (data['benifits'] as List<dynamic>?)?.cast<String>() ?? [];

            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFF1E3A5F).withOpacity(0.25),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1E3A5F).withOpacity(0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
                child: Theme(
                  data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E3A5F),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF1E3A5F).withOpacity(0.35),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: const Icon(Icons.diamond, color: Colors.white, size: 24),
                    ),
                    title: Text(
                      data['name'] ?? 'N/A',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                        color: AppColors.textPrimary,
                        letterSpacing: 0.3,
                      ),
                    ),
                    subtitle: Text(
                      '${data['primaryGemstone'] ?? 'N/A'} • Alt: ${data['alternative'] ?? 'N/A'}',
                      style: GoogleFonts.roboto(
                        color: const Color(0xFF1E3A5F).withOpacity(0.7),
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppColors.lightBackground,
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(16),
                            bottomRight: Radius.circular(16),
                          ),
                          border: Border(
                            top: BorderSide(
                              color: const Color(0xFF1E3A5F).withOpacity(0.15),
                              width: 1,
                            ),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildPremiumDetailRow('Primary Gemstone', data['primaryGemstone'] ?? 'N/A', const Color(0xFF2D5016)),
                            _buildPremiumDetailRow('Alternative', data['alternative'] ?? 'N/A', const Color(0xFF1E3A5F)),
                            if (qualities.isNotEmpty) ...[
                              const SizedBox(height: 20),
                              _buildPremiumArrayRow('Qualities', qualities, const Color(0xFF1E3A5F)),
                            ],
                            if (wearingInstructions.isNotEmpty) ...[
                              const SizedBox(height: 20),
                              _buildPremiumArrayRow('Wearing Instructions', wearingInstructions, const Color(0xFF2D5016)),
                            ],
                            if ((data['mantra'] ?? '').isNotEmpty) ...[
                              const SizedBox(height: 20),
                              _buildPremiumDetailRow('Mantra', data['mantra'] ?? 'N/A', const Color(0xFF4A3F35)),
                            ],
                            if (benifits.isNotEmpty) ...[
                              const SizedBox(height: 20),
                              _buildPremiumArrayRow('Benefits', benifits, const Color(0xFF2D5016)),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
            );
          },
        );
      },
    );
  }

  Widget _buildPremiumDetailRow(String label, String value, Color accentColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 4,
            height: 24,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [accentColor, accentColor.withOpacity(0.5)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: GoogleFonts.roboto(
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: GoogleFonts.montserrat(
                fontWeight: FontWeight.w600,
                color: accentColor,
                fontSize: 13,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumArrayRow(String label, List<String> items, Color accentColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 24,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [accentColor, accentColor.withOpacity(0.5)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700,
                color: accentColor,
                fontSize: 14,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...items.asMap().entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(left: 20, bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '◆',
                  style: TextStyle(
                    color: accentColor.withOpacity(0.6),
                    fontSize: 8,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    entry.value,
                    style: GoogleFonts.roboto(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
