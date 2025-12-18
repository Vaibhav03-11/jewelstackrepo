import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../auth/application/auth_service.dart';

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
  static const Color borderColor = Color(0xFFE8E6E1);
}

class DetailsPage extends StatefulWidget {
  const DetailsPage({super.key});

  @override
  State<DetailsPage> createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  String _selectedCategory = 'Gold';

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final user = authService.currentUser;

    return Scaffold(
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
      ),
      drawer: Drawer(
        backgroundColor: AppColors.cardBackground,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: AppColors.darkBackground,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGold.withOpacity(0.2),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primaryGold,
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.account_circle,
                      size: 50,
                      color: AppColors.primaryGold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user?.email ?? 'Guest User',
                    style: GoogleFonts.roboto(
                      color: AppColors.cardBackground,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            MouseRegion(
              onEnter: (_) {},
              onExit: (_) {},
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.error.withOpacity(0.3),
                    ),
                  ),
                  child: const Icon(
                    Icons.logout,
                    color: AppColors.error,
                    size: 20,
                  ),
                ),
                title: Text(
                  'Logout',
                  style: GoogleFonts.roboto(
                    color: AppColors.error,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                onTap: () async {
                  await authService.signOut();
                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
                },
              ),
            ),
          ],
        ),
      ),
      body: Container(
        color: AppColors.lightBackground,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
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
                padding: const EdgeInsets.all(16),
                child: Wrap(
                  spacing: 12,
                  alignment: WrapAlignment.center,
                  children: [
                    _buildPremiumChip(
                      label: '🥇 Gold',
                      isSelected: _selectedCategory == 'Gold',
                      accentColor: AppColors.primaryGold,
                      onTap: () => setState(() => _selectedCategory = 'Gold'),
                    ),
                    _buildPremiumChip(
                      label: '📿 Rudraksh',
                      isSelected: _selectedCategory == 'Rudraksh',
                      accentColor: const Color(0xFF8B7355),
                      onTap: () => setState(() => _selectedCategory = 'Rudraksh'),
                    ),
                    _buildPremiumChip(
                      label: '💎 Gemstones',
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
