import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/student_provider.dart';
import '../models/StudentSummary.dart';
import '../models/CourseProgress.dart';
import '../../../core/services/storage_service.dart';

// ─── Color tokens ────────────────────────────────────────────────────────────
class _C {
  static const navy = Color(0xFF1A1F3C);
  static const navyLight = Color(0xFF2D3566);
  static const indigo = Color(0xFF7B9FFF);
  static const indigoBg = Color(0xFFEEF2FF);
  static const indigoText = Color(0xFF4B5FCC);
  static const teal = Color(0xFF5DCAA5);
  static const tealBg = Color(0xFFE1F5EE);
  static const tealText = Color(0xFF0F6E56);
  static const pageBg = Color(0xFFF5F6FB);
  static const card = Colors.white;
  static const cardBorder = Color(0xFFECEEF5);
  static const subText = Color(0xFF9095A8);
  static const bodyText = Color(0xFF2D3142);
}

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({Key? key}) : super(key: key);

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  Map<String, String>? _userData;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<StudentProvider>(context, listen: false).fetchDashboardData();
    });
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final data = await StorageService().getUserData();
    setState(() => _userData = data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.pageBg,
      body: Consumer<StudentProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.profile == null) {
            return const Center(
              child: CircularProgressIndicator(color: _C.indigo),
            );
          }

          if (provider.errorMessage != null && provider.profile == null) {
            return _ErrorState(onRetry: provider.fetchDashboardData);
          }

          return CustomScrollView(
            slivers: [
              _buildHeroBar(context),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Stats row is now inside the hero (see below)
                      // ── Activity section
                      _SectionLabel(label: 'Activité récente'),
                      const SizedBox(height: 12),
                      if (provider.dashboardData != null)
                        _buildActivityCard(provider.dashboardData!)
                      else
                        _buildEmptyState(),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: _BottomNav(),
    );
  }

  // ── Hero SliverAppBar ──────────────────────────────────────────────────────
  Widget _buildHeroBar(BuildContext context) {
    final prenom = _userData?['prenom'] ?? '';
    final nom = _userData?['nom'] ?? '';
    final name = '$prenom $nom'.trim().isEmpty ? 'Étudiant' : '$prenom\n$nom';

    return SliverAppBar(
      expandedHeight: 230.0, // was 200.0 — gives the column more room
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: _C.navy,
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.pin,
        background: _HeroBg(
          name: name,
          onLogout: () {
            Provider.of<AuthProvider>(context, listen: false).logout();
            Navigator.pushReplacementNamed(context, '/');
          },
          dashboardData: Provider.of<StudentProvider>(
            context,
            listen: false,
          ).dashboardData,
        ),
      ),
    );
  }

  // ── Activity list card ─────────────────────────────────────────────────────
  Widget _buildActivityCard(StudentSummary data) {
    final items = data.courseProgressList;
    return _CourseActivityCard(items: items);
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(36),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: _C.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _C.cardBorder),
      ),
      child: Column(
        children: [
          Icon(
            Icons.menu_book_rounded,
            size: 56,
            color: _C.subText.withOpacity(.35),
          ),
          const SizedBox(height: 14),
          Text(
            'Aucun cours pour le moment',
            style: TextStyle(fontSize: 15, color: _C.subText),
          ),
        ],
      ),
    );
  }
}

// ─── Hero background widget ───────────────────────────────────────────────────
class _HeroBg extends StatelessWidget {
  final String name;
  final VoidCallback onLogout;
  final StudentSummary? dashboardData;

  const _HeroBg({
    required this.name,
    required this.onLogout,
    this.dashboardData,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _C.navy,
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            top: -50,
            right: -50,
            child: _Circle(size: 180, color: _C.navyLight),
          ),
          Positioned(
            bottom: -20,
            left: 60,
            child: _Circle(size: 110, color: const Color(0xFF252B52)),
          ),
          // Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'BONJOUR',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.white.withOpacity(.5),
                                fontWeight: FontWeight.w300,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              name,
                              style: GoogleFonts.dmSerifDisplay(
                                fontSize: 26,
                                color: Colors.white,
                                height: 1.1,
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: onLogout,
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(.1),
                            border: Border.all(
                              color: Colors.white.withOpacity(.15),
                            ),
                          ),
                          child: const Icon(
                            Icons.logout_rounded,
                            size: 16,
                            color: Colors.white70,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _StatPill(
                          icon: Icons.play_arrow_rounded,
                          value: '${dashboardData?.enrolledCoursesCount ?? 0}',
                          label: 'En cours',
                          color: _C.indigo,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatPill(
                          icon: Icons.check_circle_outline_rounded,
                          value: '${dashboardData?.completedCoursesCount ?? 0}',
                          label: 'Terminés',
                          color: _C.teal,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Frosted stat pill ────────────────────────────────────────────────────────
class _StatPill extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatPill({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w600,
              color: color,
              height: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.white.withOpacity(.5),
              fontWeight: FontWeight.w300,
              letterSpacing: .3,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Course activity card (real data) ───────────────────────────────────────
class _CourseActivityCard extends StatelessWidget {
  final List<CourseProgress> items;
  const _CourseActivityCard({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _C.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _C.cardBorder),
      ),
      child: Column(
        children: items
            .asMap()
            .entries
            .map(
              (e) => _CourseProgressRow(
                item: e.value,
                isLast: e.key == items.length - 1,
              ),
            )
            .toList(),
      ),
    );
  }
}

class _CourseProgressRow extends StatelessWidget {
  final CourseProgress item;
  final bool isLast;
  const _CourseProgressRow({required this.item, required this.isLast});

  @override
  Widget build(BuildContext context) {
    final percent = item.progressPercentage.clamp(0, 100);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(bottom: BorderSide(color: Color(0xFFF3F4F9))),
      ),
      child: Row(
        children: [
          // Thumbnail
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey.shade200,
              image: item.imageUrl.isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(item.imageUrl),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            alignment: Alignment.center,
            child: item.imageUrl.isEmpty
                ? Icon(Icons.menu_book_rounded, color: Colors.grey.shade400)
                : null,
          ),
          const SizedBox(width: 12),
          // Title / instructor
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _C.bodyText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${item.instructorName} · ${item.completedLessons}/${item.totalLessons} leçons',
                  style: const TextStyle(fontSize: 11, color: _C.subText),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Progress badge
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: percent >= 100 ? _C.tealBg : _C.indigoBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$percent%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: percent >= 100 ? _C.tealText : _C.indigoText,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              SizedBox(
                width: 64,
                child: LinearProgressIndicator(
                  value: percent / 100.0,
                  backgroundColor: Colors.grey.shade200,
                  color: percent >= 100 ? _C.teal : _C.indigo,
                  minHeight: 6,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}


// ─── Section label ────────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: _C.subText,
        letterSpacing: .8,
      ),
    );
  }
}

// ─── Bottom nav ───────────────────────────────────────────────────────────────
class _BottomNav extends StatelessWidget {
  const _BottomNav();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFECEEF5))),
      ),
      child: BottomNavigationBar(
        currentIndex: 0,
        backgroundColor: Colors.transparent,
        selectedItemColor: _C.navy,
        unselectedItemColor: _C.subText,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        elevation: 0,
        selectedLabelStyle: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
        unselectedLabelStyle: const TextStyle(fontSize: 10),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_rounded),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.play_circle_outline_rounded),
            label: 'Cours',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}

// ─── Helpers ──────────────────────────────────────────────────────────────────
class _Circle extends StatelessWidget {
  final double size;
  final Color color;
  const _Circle({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(.6),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
          const SizedBox(height: 16),
          const Text('Erreur lors du chargement.'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(backgroundColor: _C.navy),
            child: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }
}
