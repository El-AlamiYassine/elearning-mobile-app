import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../providers/student_provider.dart';
import '../../models/Certificate.dart';
import '../../../core/constants/BottomNavStudent.dart';

class CertificateScreen extends StatefulWidget {
  const CertificateScreen({super.key});

  @override
  State<CertificateScreen> createState() => _CertificateScreenState();
}

class _CertificateScreenState extends State<CertificateScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<StudentProvider>(context, listen: false).fetchCertificates();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<StudentProvider>(
      builder: (context, provider, _) {
        final certs = provider.certificates;

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: Column(
              children: [
                _buildHeader(context, certs.length),
                _buildSummaryBanner(certs.length),

                if (provider.isLoading)
                  const Expanded(
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    ),
                  )
                else if (provider.errorMessage != null)
                  Expanded(
                    child: _buildError(
                      context,
                      provider.errorMessage!,
                      onRetry: provider.fetchCertificates,
                    ),
                  )
                else if (certs.isEmpty)
                  Expanded(child: _buildEmpty(context))
                else
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                      itemCount: certs.length,
                      itemBuilder: (_, i) =>
                          _CertificateCard(certificate: certs[i]),
                    ),
                  ),
              ],
            ),
          ),
          bottomNavigationBar: const BottomNavStudent(currentIndex: 3),
        );
      },
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context, int count) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: const BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                child: const Text(
                  'Mes Certificats',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                )
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.workspace_premium_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Vos réussites',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '$count certificat${count > 1 ? 's' : ''}'
                    ' obtenu${count > 1 ? 's' : ''}',
                    style: const TextStyle(
                      color: Color(0xFFBFDBFE),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Summary banner ────────────────────────────────────────────────────────
  Widget _buildSummaryBanner(int count) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          _statItem(
            '$count',
            'Certificats',
            Icons.workspace_premium_outlined,
            AppColors.warning,
          ),
          _vDivider(),
          _statItem(
            '100%',
            'Réussite',
            Icons.verified_outlined,
            AppColors.success,
          ),
          _vDivider(),
          _statItem(
            'Actif',
            'Statut',
            Icons.shield_outlined,
            AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _statItem(String val, String label, IconData icon, Color color) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(
            val,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: AppColors.textHint),
          ),
        ],
      ),
    );
  }

  Widget _vDivider() =>
      Container(width: 1, height: 40, color: AppColors.border);

  // ── Error ─────────────────────────────────────────────────────────────────
  Widget _buildError(
    BuildContext context,
    String message, {
    required VoidCallback onRetry,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: AppColors.textSecond),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.refresh, color: Colors.white),
              label: const Text(
                'Réessayer',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Empty ─────────────────────────────────────────────────────────────────
  Widget _buildEmpty(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.workspace_premium_outlined,
              color: AppColors.primary,
              size: 36,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "Aucun certificat pour l'instant",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Terminez un cours pour obtenir\nvotre premier certificat.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textHint,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/student-courses'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Voir mes cours',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// CARTE
// ══════════════════════════════════════════════════════════════════════════════
class _CertificateCard extends StatelessWidget {
  final Certificate certificate;
  const _CertificateCard({required this.certificate});

  // Deterministic accent color from course title
  Color _accentColor() {
    const colors = [
      Color(0xFF4B5FCC),
      Color(0xFF0F6E56),
      Color(0xFFB7700F),
      Color(0xFF993C1D),
      Color(0xFF993556),
      Color(0xFF3B6D11),
    ];
    return colors[certificate.courseTitle.length % colors.length];
  }

  Color _accentBg() {
    const bgs = [
      Color(0xFFEEF2FF),
      Color(0xFFE1F5EE),
      Color(0xFFFEF9EE),
      Color(0xFFFAECE7),
      Color(0xFFFBEAF0),
      Color(0xFFEAF3DE),
    ];
    return bgs[certificate.courseTitle.length % bgs.length];
  }

  String _formattedDate() {
    final d = certificate.issueDate;
    const months = [
      'Janvier',
      'Février',
      'Mars',
      'Avril',
      'Mai',
      'Juin',
      'Juillet',
      'Août',
      'Septembre',
      'Octobre',
      'Novembre',
      'Décembre',
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  // ignore: unused_element
  String _initial() {
    final t = certificate.courseTitle.trim();
    return t.isNotEmpty ? t[0].toUpperCase() : 'C';
  }

  @override
  Widget build(BuildContext context) {
    final accent = _accentColor();
    final accentBg = _accentBg();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _buildVisual(accent, accentBg),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Course title
                Text(
                  certificate.courseTitle,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 10),

                // Student + date row
                Row(
                  children: [
                    const Icon(
                      Icons.person_outline,
                      size: 15,
                      color: AppColors.textHint,
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        certificate.studentName,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecond,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 13,
                      color: AppColors.textHint,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formattedDate(),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecond,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Verification code
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.qr_code_outlined,
                        size: 16,
                        color: AppColors.textHint,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          certificate.verificationCode,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecond,
                            fontFamily: 'monospace',
                            letterSpacing: .5,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      GestureDetector(
                        onTap: () =>
                            _copyCode(context, certificate.verificationCode),
                        child: const Icon(
                          Icons.copy_outlined,
                          size: 16,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Actions
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showDetail(context, accent, accentBg),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.border),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        icon: const Icon(
                          Icons.visibility_outlined,
                          size: 16,
                          color: AppColors.textSecond,
                        ),
                        label: const Text(
                          'Voir',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecond,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _download(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        icon: const Icon(
                          Icons.download_outlined,
                          size: 16,
                          color: Colors.white,
                        ),
                        label: const Text(
                          'Télécharger',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Visual banner ─────────────────────────────────────────────────────────
  Widget _buildVisual(Color accent, Color accentBg) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: accent.withOpacity(.06),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        children: [
          // Medal icon
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: accent.withOpacity(.15),
              shape: BoxShape.circle,
              border: Border.all(color: accent.withOpacity(.3), width: 2),
            ),
            child: Icon(
              Icons.workspace_premium_rounded,
              color: accent,
              size: 28,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'CERTIFICAT DE RÉUSSITE',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: AppColors.textHint,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            certificate.studentName,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: accent,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                Expanded(child: Divider(color: accent.withOpacity(.3))),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Icon(Icons.star_rounded, color: accent, size: 14),
                ),
                Expanded(child: Divider(color: accent.withOpacity(.3))),
              ],
            ),
          ),
          // Verified badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.successSoft,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.success.withOpacity(.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(
                  Icons.verified_rounded,
                  color: AppColors.success,
                  size: 14,
                ),
                SizedBox(width: 5),
                Text(
                  'Certifié & Vérifié',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  void _copyCode(BuildContext context, String code) {
    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle_outline, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Text('Code copié dans le presse-papiers'),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _download(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            ),
            SizedBox(width: 10),
            Text('Téléchargement en cours...'),
          ],
        ),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showDetail(BuildContext context, Color accent, Color accentBg) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        height: MediaQuery.of(context).size.height * 0.82,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            // Modal header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  const Text(
                    'Détail du certificat',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.close,
                        size: 18,
                        color: AppColors.textSecond,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Full visual
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: accent.withOpacity(.06),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: accent.withOpacity(.2)),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.workspace_premium_rounded,
                            color: accent,
                            size: 52,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'CERTIFICAT DE RÉUSSITE',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                              color: AppColors.textHint,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            certificate.studentName,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: accent,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'a complété avec succès',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textHint,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            certificate.courseTitle,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Detail rows — exactly the 4 fields we have
                    _detailRow(
                      Icons.person_outline,
                      'Étudiant',
                      certificate.studentName,
                    ),
                    _detailRow(
                      Icons.menu_book_outlined,
                      'Cours',
                      certificate.courseTitle,
                    ),
                    _detailRow(
                      Icons.calendar_today_outlined,
                      "Date d'émission",
                      _formattedDate(),
                    ),
                    _detailRow(
                      Icons.qr_code_outlined,
                      'Code de vérification',
                      certificate.verificationCode,
                      isCode: true,
                    ),

                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        icon: const Icon(
                          Icons.share_outlined,
                          color: Colors.white,
                          size: 18,
                        ),
                        label: const Text(
                          'Partager',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(
    IconData icon,
    String label,
    String value, {
    bool isCode = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textHint),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textHint,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: isCode ? 11 : 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                    fontFamily: isCode ? 'monospace' : null,
                    letterSpacing: isCode ? .5 : 0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
