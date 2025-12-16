import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../auth/application/auth_service.dart';

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
        title: const Text(
          ' Jewel Stack',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 24,
            letterSpacing: 2.0,
            color: Color(0xFFFAF9F6),
          ),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF1F1F1F),
                Color(0xFF2D2416),
                Color(0xFF3E2723),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: const Color(0xFFFAF9F6),
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.3),
      ),
      drawer: Drawer(
        backgroundColor: const Color(0xFFFAF9F6),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF1F1F1F),
                    Color(0xFF2D2416),
                    Color(0xFF3E2723),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TweenAnimationBuilder(
                    duration: const Duration(milliseconds: 600),
                    tween: Tween<double>(begin: 0, end: 1),
                    builder: (context, double value, child) {
                      return Transform.scale(
                        scale: value * 0.8 + 0.2,
                        child: child,
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD4AF37).withOpacity(0.2),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFD4AF37),
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.account_circle,
                        size: 50,
                        color: Color(0xFFD4AF37),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user?.email ?? 'Guest User',
                    style: const TextStyle(
                      color: Color(0xFFFAF9F6),
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
                    color: const Color(0xFFE8695D).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color(0xFFE8695D).withOpacity(0.3),
                    ),
                  ),
                  child: const Icon(
                    Icons.logout,
                    color: Color(0xFFE8695D),
                    size: 20,
                  ),
                ),
                title: const Text(
                  'Logout',
                  style: TextStyle(
                    color: Color(0xFFE8695D),
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
        color: const Color(0xFFFAF9F6),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFE8E6E1),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 20,
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
                      accentColor: const Color(0xFFD4AF37),
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
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                switchInCurve: Curves.easeInOutCubic,
                switchOutCurve: Curves.easeInOutCubic,
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.15, 0),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeInOutCubic,
                      )),
                      child: child,
                    ),
                  );
                },
                child: _selectedCategory == 'Gold'
                    ? const GoldDetailsTab(key: ValueKey('gold'))
                    : _selectedCategory == 'Rudraksh'
                        ? const RudrakshDetailsTab(key: ValueKey('rudraksh'))
                        : const GemstonesDetailsTab(key: ValueKey('gemstones')),
              ),
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
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? accentColor : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: accentColor.withOpacity(isSelected ? 0 : 0.3),
              width: 1.5,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: accentColor.withOpacity(0.25),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : accentColor,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
              fontSize: 14,
              letterSpacing: 0.5,
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
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data?.docs ?? [];

        if (docs.isEmpty) {
          return const Center(child: Text('No gold details found.'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            return TweenAnimationBuilder(
              duration: Duration(milliseconds: 400 + (index * 100)),
              tween: Tween<double>(begin: 0, end: 1),
              curve: Curves.easeInOutCubic,
              builder: (context, double value, child) {
                return Transform.translate(
                  offset: Offset(0, 30 * (1 - value)),
                  child: Opacity(
                    opacity: value,
                    child: child,
                  ),
                );
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFFFAF9F6),
                      const Color(0xFFD4AF37).withOpacity(0.08),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFD4AF37).withOpacity(0.3),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
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
                        gradient: const LinearGradient(
                          colors: [Color(0xFFD4AF37), Color(0xFFC19A00)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFD4AF37).withOpacity(0.3),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: const Icon(Icons.diamond, color: Color(0xFFFAF9F6), size: 24),
                    ),
                    title: Text(
                      data['color of gold'] ?? 'N/A',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                        color: Color(0xFF1F1F1F),
                        letterSpacing: 0.5,
                      ),
                    ),
                    subtitle: Text(
                      'Carat: ${data['carat of gold'] ?? 'N/A'} • Fineness: ${data['fineness'] ?? 'N/A'}',
                      style: TextStyle(
                        color: const Color(0xFFD4AF37).withOpacity(0.7),
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFAF9F6).withOpacity(0.8),
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(16),
                            bottomRight: Radius.circular(16),
                          ),
                          border: Border(
                            top: BorderSide(
                              color: const Color(0xFFD4AF37).withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildPremiumDetailRow('Gold Content', data['gold'] ?? 'N/A', const Color(0xFFD4AF37)),
                            _buildPremiumDetailRow('Silver Content', data['silver'] ?? 'N/A', const Color(0xFFC0C0C0)),
                            _buildPremiumDetailRow('Copper Content', data['copper'] ?? 'N/A', const Color(0xFFB87333)),
                            _buildPremiumDetailRow('Other Metals', data['other'] ?? 'N/A', const Color(0xFF9CA3AF)),
                          ],
                        ),
                      ),
                    ],
                  ),
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
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF3F3F3F),
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: accentColor,
                fontSize: 14,
                letterSpacing: 0.5,
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
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data?.docs ?? [];

        if (docs.isEmpty) {
          return const Center(child: Text('No rudraksh details found.'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            final symbolism = (data['symbolism'] as List<dynamic>?)?.cast<String>() ?? [];
            final healthBenifits = (data['health benifits'] as List<dynamic>?)?.cast<String>() ?? [];

            return TweenAnimationBuilder(
              duration: Duration(milliseconds: 400 + (index * 100)),
              tween: Tween<double>(begin: 0, end: 1),
              curve: Curves.easeInOutCubic,
              builder: (context, double value, child) {
                return Transform.translate(
                  offset: Offset(0, 30 * (1 - value)),
                  child: Opacity(
                    opacity: value,
                    child: child,
                  ),
                );
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFFFAF9F6),
                      const Color(0xFF8B7355).withOpacity(0.08),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF8B7355).withOpacity(0.3),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
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
                        gradient: const LinearGradient(
                          colors: [Color(0xFF5D4037), Color(0xFF3E2723)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF5D4037).withOpacity(0.3),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: const Icon(Icons.grain, color: Color(0xFFFAF9F6), size: 24),
                    ),
                    title: Text(
                      data['type of rudraksh'] ?? 'N/A',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                        color: Color(0xFF1F1F1F),
                        letterSpacing: 0.5,
                      ),
                    ),
                    subtitle: Text(
                      'Sacred Spiritual Bead',
                      style: TextStyle(
                        color: const Color(0xFF8B7355).withOpacity(0.7),
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFAF9F6).withOpacity(0.8),
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(16),
                            bottomRight: Radius.circular(16),
                          ),
                          border: Border(
                            top: BorderSide(
                              color: const Color(0xFF8B7355).withOpacity(0.2),
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
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: accentColor,
                fontSize: 14,
                letterSpacing: 0.5,
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
                    style: const TextStyle(
                      color: Color(0xFF3F3F3F),
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
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data?.docs ?? [];

        if (docs.isEmpty) {
          return const Center(child: Text('No gemstone details found.'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            final qualities = (data['qualities'] as List<dynamic>?)?.cast<String>() ?? [];
            final wearingInstructions = (data['wearingInstructions'] as List<dynamic>?)?.cast<String>() ?? [];
            final benifits = (data['benifits'] as List<dynamic>?)?.cast<String>() ?? [];

            return TweenAnimationBuilder(
              duration: Duration(milliseconds: 400 + (index * 100)),
              tween: Tween<double>(begin: 0, end: 1),
              curve: Curves.easeInOutCubic,
              builder: (context, double value, child) {
                return Transform.translate(
                  offset: Offset(0, 30 * (1 - value)),
                  child: Opacity(
                    opacity: value,
                    child: child,
                  ),
                );
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFFFAF9F6),
                      const Color(0xFF1E3A5F).withOpacity(0.06),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF1E3A5F).withOpacity(0.3),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
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
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1E3A5F), Color(0xFF2D5016)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF1E3A5F).withOpacity(0.3),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: const Icon(Icons.diamond, color: Color(0xFFFAF9F6), size: 24),
                    ),
                    title: Text(
                      data['name'] ?? 'N/A',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                        color: Color(0xFF1F1F1F),
                        letterSpacing: 0.5,
                      ),
                    ),
                    subtitle: Text(
                      '${data['primaryGemstone'] ?? 'N/A'} • Alt: ${data['alternative'] ?? 'N/A'}',
                      style: TextStyle(
                        color: const Color(0xFF1E3A5F).withOpacity(0.7),
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFAF9F6).withOpacity(0.8),
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(16),
                            bottomRight: Radius.circular(16),
                          ),
                          border: Border(
                            top: BorderSide(
                              color: const Color(0xFF1E3A5F).withOpacity(0.2),
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
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF3F3F3F),
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: accentColor,
                fontSize: 13,
                letterSpacing: 0.3,
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
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: accentColor,
                fontSize: 14,
                letterSpacing: 0.5,
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
                    style: const TextStyle(
                      color: Color(0xFF3F3F3F),
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
