import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/constants/route.dart';

// ══════════════════════════════════════
// HELPER — Redirection selon le rôle
// ══════════════════════════════════════
void handleLoginRedirect(BuildContext context) {
  final auth = Provider.of<AuthProvider>(context, listen: false);

  if (!auth.isAuthenticated) {
    Navigator.pushNamed(context, AppRoutes.login);
    return;
  }

  const routes = {
    'ROLE_STUDENT': AppRoutes.studentDashboard,
    'ROLE_TEACHER': AppRoutes.teacherDashboard,
    'ROLE_ADMIN':   AppRoutes.adminDashboard,
  };

  final route = routes[auth.role];
  if (route != null) {
    Navigator.pushNamedAndRemoveUntil(context, route, (_) => false);
  } else {
    // Rôle inconnu → déconnecter par sécurité
    auth.logout();
    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (_) => false);
  }
}

// ══════════════════════════════════════
// HOME SCREEN
// ══════════════════════════════════════
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SingleChildScrollView(
        child: Column(
          children: const [
            _HeroSection(),
            _StatsSection(),
            _FeaturesSection(),
            _CtaSection(),
            _Footer(),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════
// HERO SECTION
// ══════════════════════════════════════
class _HeroSection extends StatelessWidget {
  const _HeroSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1E3A8A),
            Color(0xFF2563EB),
            Color(0xFF3B82F6),
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Navbar ──
              _NavBar(),

              const SizedBox(height: 36),

              // ── Badge ──
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.25)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6, height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFF93C5FD),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'Plateforme universitaire',
                      style: TextStyle(
                        color: Color(0xFFBFDBFE),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ── Titre ──
              RichText(
                text: const TextSpan(
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.25,
                  ),
                  children: [
                    TextSpan(text: 'Apprenez à\nvotre '),
                    TextSpan(
                      text: 'rythme',
                      style: TextStyle(color: Color(0xFF93C5FD)),
                    ),
                    TextSpan(text: ',\nprogressez à\nvotre '),
                    TextSpan(
                      text: 'niveau',
                      style: TextStyle(color: Color(0xFF93C5FD)),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // ── Sous-titre ──
              const Text(
                'Cours universitaires, quiz interactifs\n'
                'et certificats reconnus — tout en un.',
                style: TextStyle(
                  color: Color(0xFFBFDBFE),
                  fontSize: 13,
                  height: 1.6,
                ),
              ),

              const SizedBox(height: 28),

              // ── Boutons adaptés selon l'état de connexion ──
              _HeroButtons(),

              const SizedBox(height: 24),

              // ── Social proof ──
              Center(
                child: RichText(
                  text: const TextSpan(
                    style: TextStyle(fontSize: 12, color: Color(0xFF93C5FD)),
                    children: [
                      TextSpan(text: 'Déjà '),
                      TextSpan(
                        text: '12 000+ étudiants',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextSpan(text: ' nous font confiance'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════
// NAVBAR — s'adapte selon l'auth
// ══════════════════════════════════════
class _NavBar extends StatelessWidget {
  const _NavBar();

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Logo
            Row(
              children: [
                Container(
                  width: 34, height: 34,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.menu_book_rounded,
                    color: Colors.white, size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'E-Learning',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),

            // Boutons navbar : différents selon auth
            if (auth.isAuthenticated)
              _AuthenticatedNavActions(auth: auth)
            else
              _GuestNavActions(),
          ],
        );
      },
    );
  }
}

// ── Navbar : utilisateur connecté ──
class _AuthenticatedNavActions extends StatelessWidget {
  final AuthProvider auth;
  const _AuthenticatedNavActions({required this.auth});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Bouton dashboard
        GestureDetector(
          onTap: () => handleLoginRedirect(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.4)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.dashboard_rounded, color: Colors.white, size: 14),
                SizedBox(width: 6),
                Text(
                  'Dashboard',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        // Bouton logout
        GestureDetector(
          onTap: () async {
            await auth.logout();
            // Reste sur la home, les boutons se mettent à jour automatiquement
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.logout_rounded, color: Color(0xFFBFDBFE), size: 14),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Navbar : visiteur non connecté ──
class _GuestNavActions extends StatelessWidget {
  const _GuestNavActions();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, AppRoutes.login),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.3)),
        ),
        child: const Text(
          'Connexion',
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════
// BOUTONS HERO — adaptés selon l'auth
// ══════════════════════════════════════
class _HeroButtons extends StatelessWidget {
  const _HeroButtons();

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        if (auth.isAuthenticated) {
          // ── Utilisateur connecté : dashboard + logout ──
          return Column(
            children: [
              // Bouton principal : accéder au dashboard
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => handleLoginRedirect(context),
                  icon: const Icon(Icons.dashboard_rounded, size: 18),
                  label: const Text(
                    'Accéder au dashboard',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF1E3A8A),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // Bouton secondaire : déconnexion
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await auth.logout();
                    // L'UI se reconstruit automatiquement via Consumer
                  },
                  icon: const Icon(
                    Icons.logout_rounded,
                    size: 18,
                    color: Colors.white,
                  ),
                  label: const Text(
                    'Se déconnecter',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    side: BorderSide(color: Colors.white.withOpacity(0.4)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // Indicateur de rôle connecté
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6, height: 6,
                        decoration: const BoxDecoration(
                          color: Color(0xFF4ADE80),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Connecté · ${_roleLabel(auth.role)}',
                        style: const TextStyle(
                          color: Color(0xFFBFDBFE),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }

        // ── Visiteur non connecté : inscription + connexion ──
        return Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/register'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF1E3A8A),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Commencer gratuitement',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.pushNamed(context, AppRoutes.login),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  side: BorderSide(color: Colors.white.withOpacity(0.4)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'J\'ai déjà un compte',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  String _roleLabel(String? role) {
    switch (role) {
      case 'ROLE_STUDENT': return 'Étudiant';
      case 'ROLE_TEACHER': return 'Professeur';
      case 'ROLE_ADMIN':   return 'Administrateur';
      default:             return 'Utilisateur';
    }
  }
}

// ══════════════════════════════════════
// STATS SECTION
// ══════════════════════════════════════
class _StatsSection extends StatelessWidget {
  const _StatsSection();

  static const _stats = [
    {'valeur': '500+', 'label': 'Cours'},
    {'valeur': '12k+', 'label': 'Étudiants'},
    {'valeur': '80+',  'label': 'Professeurs'},
    {'valeur': '95%',  'label': 'Satisfaction'},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        children: _stats.asMap().entries.map((entry) {
          final isLast = entry.key == _stats.length - 1;
          return Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  right: isLast
                      ? BorderSide.none
                      : const BorderSide(color: Color(0xFFE2E8F0)),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    entry.value['valeur']!,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E3A8A),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    entry.value['label']!,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ══════════════════════════════════════
// FEATURES SECTION
// ══════════════════════════════════════
class _FeaturesSection extends StatelessWidget {
  const _FeaturesSection();

  static const _features = [
    {
      'titre':    'Cours PDF',
      'desc':     'Téléchargez et lisez à tout moment',
      'icon':     Icons.picture_as_pdf_outlined,
      'bgColor':  Color(0xFFEFF6FF),
      'iconColor': Color(0xFF2563EB),
    },
    {
      'titre':    'Quiz',
      'desc':     'Testez vos connaissances',
      'icon':     Icons.quiz_outlined,
      'bgColor':  Color(0xFFF5F3FF),
      'iconColor': Color(0xFF7C3AED),
    },
    {
      'titre':    'Progression',
      'desc':     'Suivez votre avancement',
      'icon':     Icons.bar_chart_rounded,
      'bgColor':  Color(0xFFF0FDF4),
      'iconColor': Color(0xFF059669),
    },
    {
      'titre':    'Certificats',
      'desc':     'Obtenez votre diplôme',
      'icon':     Icons.workspace_premium_outlined,
      'bgColor':  Color(0xFFFFFBEB),
      'iconColor': Color(0xFFD97706),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ce que vous obtenez',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Une plateforme complète pour étudiants\n'
            'et professeurs.',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF94A3B8),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 18),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.1,
            children: _features.map((f) =>
              _FeatureCard(
                titre:     f['titre'] as String,
                desc:      f['desc']  as String,
                icon:      f['icon']  as IconData,
                bgColor:   f['bgColor']  as Color,
                iconColor: f['iconColor'] as Color,
              ),
            ).toList(),
          ),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final String   titre;
  final String   desc;
  final IconData icon;
  final Color    bgColor;
  final Color    iconColor;

  const _FeatureCard({
    required this.titre,
    required this.desc,
    required this.icon,
    required this.bgColor,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            titre,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            desc,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF94A3B8),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════
// CTA SECTION — adaptée selon l'auth
// ══════════════════════════════════════
class _CtaSection extends StatelessWidget {
  const _CtaSection();

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        return Container(
          margin: const EdgeInsets.fromLTRB(20, 10, 20, 10),
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFBFDBFE)),
          ),
          child: Column(
            children: [
              Text(
                auth.isAuthenticated
                    ? 'Continuez votre apprentissage'
                    : 'Prêt à commencer ?',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E3A8A),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                auth.isAuthenticated
                    ? 'Accédez à vos cours\net suivez votre progression.'
                    : 'Compte étudiant gratuit,\n'
                      'accès immédiat à tous les cours.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF3B82F6),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: auth.isAuthenticated
                      ? () => handleLoginRedirect(context)
                      : () => Navigator.pushNamed(context, '/register'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    auth.isAuthenticated
                        ? 'Aller au dashboard'
                        : 'Créer mon compte gratuitement',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ══════════════════════════════════════
// FOOTER — adapté selon l'auth
// ══════════════════════════════════════
class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
          ),
          child: Column(
            children: [
              // Logo
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 26, height: 26,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.menu_book_rounded,
                      color: Colors.white, size: 14,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'E-Learning',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // Liens selon l'état auth
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: auth.isAuthenticated
                    ? [
                        GestureDetector(
                          onTap: () => handleLoginRedirect(context),
                          child: const Text(
                            'Mon dashboard',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Text('·',
                            style: TextStyle(color: Color(0xFF94A3B8))),
                        ),
                        GestureDetector(
                          onTap: () => auth.logout(),
                          child: const Text(
                            'Se déconnecter',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                        ),
                      ]
                    : [
                        GestureDetector(
                          onTap: () =>
                              Navigator.pushNamed(context, AppRoutes.login),
                          child: const Text(
                            'Connexion',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Text('·',
                            style: TextStyle(color: Color(0xFF94A3B8))),
                        ),
                        GestureDetector(
                          onTap: () =>
                              Navigator.pushNamed(context, '/register'),
                          child: const Text(
                            'Inscription',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                        ),
                      ],
              ),

              const SizedBox(height: 10),

              const Text(
                '© 2024 E-Learning — Plateforme universitaire',
                style: TextStyle(fontSize: 11, color: Color(0xFFCBD5E1)),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}