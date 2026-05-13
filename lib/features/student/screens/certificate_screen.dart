import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../../auth/providers/auth_provider.dart';
import 'package:provider/provider.dart';

// ══════════════════════════════════════
// MODÈLE
// ══════════════════════════════════════
class CertificateModel {
  final int    id;
  final String titreCours;
  final String nomFormateur;
  final String categorie;
  final String dateEmission;
  final String codeVerification;
  final int    dureeHeures;

  const CertificateModel({
    required this.id,
    required this.titreCours,
    required this.nomFormateur,
    required this.dateEmission,
    required this.codeVerification,
    required this.categorie,
    required this.dureeHeures,
  });
}

// ══════════════════════════════════════
// DONNÉES DE TEST
// ══════════════════════════════════════
const _mockCertificates = [
  CertificateModel(
    id:                1,
    titreCours:        'Java Spring Boot — Débutant à Avancé',
    nomFormateur:      'Karim Benali',
    categorie:         'Informatique',
    dateEmission:      '12 Mars 2024',
    codeVerification:  'CERT-2024-HAMZA-SPB-001',
    dureeHeures:       42,
  ),
  CertificateModel(
    id:                2,
    titreCours:        'Algèbre Linéaire',
    nomFormateur:      'Fatima El Amrani',
    categorie:         'Mathématiques',
    dateEmission:      '28 Avril 2024',
    codeVerification:  'CERT-2024-SARA-ALG-003',
    dureeHeures:       30,
  ),
  CertificateModel(
    id:                3,
    titreCours:        'Base de Données SQL',
    nomFormateur:      'Youssef Tahiri',
    categorie:         'Base de données',
    dateEmission:      '05 Mai 2024',
    codeVerification:  'CERT-2024-LUCAS-SQL-004',
    dureeHeures:       28,
  ),
];

// ══════════════════════════════════════
// PAGE PRINCIPALE
// ══════════════════════════════════════
class CertificateScreen extends StatefulWidget {
  const CertificateScreen({super.key});

  @override
  State<CertificateScreen> createState() =>
      _CertificateScreenState();
}

class _CertificateScreenState extends State<CertificateScreen> {
  @override
  Widget build(BuildContext context) {
    final nom = context.watch<AuthProvider>().nom;
    final prenom = context.watch<AuthProvider>().prenom;
    final nomEtudiant = nom != null
        ? '$nom $prenom'
        : 'Étudiant';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildSummaryBanner(),
            Expanded(
              child: _mockCertificates.isEmpty
                  ? _buildEmpty()
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(
                          20, 8, 20, 100),
                      itemCount: _mockCertificates.length,
                      itemBuilder: (_, i) => _CertificateCard(
                        certificate:  _mockCertificates[i],
                        nomEtudiant:  nomEtudiant,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Header ──
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: const BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.only(
          bottomLeft:  Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.white, size: 16),
                ),
              ),
              const SizedBox(width: 14),
              const Text('Mes Certificats',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 52, height: 52,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.workspace_premium_rounded,
                  color: Colors.white, size: 28),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Vos réussites',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${_mockCertificates.length} certificat'
                    '${_mockCertificates.length > 1 ? 's' : ''} obtenu'
                    '${_mockCertificates.length > 1 ? 's' : ''}',
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

  // ── Bannière résumé ──
  Widget _buildSummaryBanner() {
    final totalHeures = _mockCertificates.fold<int>(
        0, (sum, c) => sum + c.dureeHeures);

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      padding: const EdgeInsets.symmetric(
          vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          _buildStatItem(
            '${_mockCertificates.length}',
            'Certificats',
            Icons.workspace_premium_outlined,
            AppColors.warning,
          ),
          _buildDivider(),
          _buildStatItem(
            '$totalHeures h',
            'Formation',
            Icons.access_time_outlined,
            AppColors.primary,
          ),
          _buildDivider(),
          _buildStatItem(
            '100%',
            'Réussite',
            Icons.verified_outlined,
            AppColors.success,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
      String val, String label, IconData icon, Color color) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(val,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textHint,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() => Container(
    width: 1, height: 40,
    color: AppColors.border,
  );

  // ── État vide ──
  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.workspace_premium_outlined,
              color: AppColors.primary, size: 36),
          ),
          const SizedBox(height: 16),
          const Text('Aucun certificat pour l\'instant',
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
            onPressed: () =>
                Navigator.pushNamed(context, '/student-courses'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(
                  horizontal: 28, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: const Text('Voir mes cours',
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

// ══════════════════════════════════════
// CARTE CERTIFICAT
// ══════════════════════════════════════
class _CertificateCard extends StatelessWidget {
  final CertificateModel certificate;
  final String           nomEtudiant;

  const _CertificateCard({
    required this.certificate,
    required this.nomEtudiant,
  });

  @override
  Widget build(BuildContext context) {
    final catColor = AppColors.colorForCategory(
        certificate.categorie);
    final catBg    = AppColors.bgForCategory(
        certificate.categorie);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [

          // ── Visuel certificat ──
          _buildCertVisual(catColor, catBg),

          // ── Infos ──
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // Titre cours
                Text(certificate.titreCours,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),

                // Formateur
                Row(
                  children: [
                    const Icon(Icons.person_outline,
                      size: 15, color: AppColors.textHint),
                    const SizedBox(width: 5),
                    Text(certificate.nomFormateur,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecond,
                      ),
                    ),
                    const Spacer(),
                    const Icon(Icons.access_time_outlined,
                      size: 15, color: AppColors.textHint),
                    const SizedBox(width: 4),
                    Text('${certificate.dureeHeures}h',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecond,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Date + Catégorie
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: catBg,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(certificate.categorie,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: catColor,
                        ),
                      ),
                    ),
                    const Spacer(),
                    const Icon(Icons.calendar_today_outlined,
                      size: 13, color: AppColors.textHint),
                    const SizedBox(width: 4),
                    Text(certificate.dateEmission,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecond,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Code vérification
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.qr_code_outlined,
                        size: 16, color: AppColors.textHint),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          certificate.codeVerification,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecond,
                            fontFamily: 'monospace',
                            letterSpacing: 0.5,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _copyCode(
                            context,
                            certificate.codeVerification),
                        child: const Icon(Icons.copy_outlined,
                          size: 16, color: AppColors.primary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Boutons actions
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () =>
                            _showCertificateDetail(
                                context, certificate,
                                nomEtudiant),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                              color: AppColors.border),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(
                              vertical: 10),
                        ),
                        icon: const Icon(
                          Icons.visibility_outlined,
                          size: 16,
                          color: AppColors.textSecond,
                        ),
                        label: const Text('Voir',
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
                        onPressed: () =>
                            _downloadCertificate(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(
                              vertical: 10),
                        ),
                        icon: const Icon(
                          Icons.download_outlined,
                          size: 16,
                          color: Colors.white,
                        ),
                        label: const Text('Télécharger',
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

  // ── Visuel certificat ──
  Widget _buildCertVisual(Color catColor, Color catBg) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            catColor.withOpacity(0.12),
            catColor.withOpacity(0.04),
          ],
        ),
        borderRadius: const BorderRadius.only(
          topLeft:  Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        border: Border(
          bottom: BorderSide(color: AppColors.border),
        ),
      ),
      child: Column(
        children: [
          // Icône médaille
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(
              color: catColor.withOpacity(0.15),
              shape: BoxShape.circle,
              border: Border.all(
                color: catColor.withOpacity(0.3),
                width: 2),
            ),
            child: Icon(
              Icons.workspace_premium_rounded,
              color: catColor, size: 28),
          ),
          const SizedBox(height: 10),
          const Text('CERTIFICAT DE RÉUSSITE',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: AppColors.textHint,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 4),
          Text('Ce certificat est décerné à',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textHint,
            ),
          ),
          const SizedBox(height: 4),
          Text(nomEtudiant,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: catColor,
            ),
          ),
          const SizedBox(height: 2),
          const Text('pour avoir complété avec succès',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textHint,
            ),
          ),

          // Séparateur décoratif
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                Expanded(child: Divider(
                  color: catColor.withOpacity(0.3))),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8),
                  child: Icon(Icons.star_rounded,
                    color: catColor, size: 14),
                ),
                Expanded(child: Divider(
                  color: catColor.withOpacity(0.3))),
              ],
            ),
          ),

          // Badge vérifié
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.successSoft,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: AppColors.success.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.verified_rounded,
                  color: AppColors.success, size: 14),
                const SizedBox(width: 5),
                const Text('Certifié & Vérifié',
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

  // ── Copier le code ──
  void _copyCode(BuildContext context, String code) {
    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle_outline,
              color: Colors.white, size: 18),
            SizedBox(width: 8),
            Text('Code copié dans le presse-papiers'),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // ── Télécharger ──
  void _downloadCertificate(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            SizedBox(
              width: 18, height: 18,
              child: CircularProgressIndicator(
                color: Colors.white, strokeWidth: 2),
            ),
            SizedBox(width: 10),
            Text('Téléchargement en cours...'),
          ],
        ),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // ── Modal détail certificat ──
  void _showCertificateDetail(
    BuildContext context,
    CertificateModel cert,
    String nomEtudiant,
  ) {
    final catColor = AppColors.colorForCategory(cert.categorie);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft:  Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),

            // Header modal
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 20),
              child: Row(
                children: [
                  const Text('Détail du certificat',
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
                      width: 32, height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius:
                            BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.close,
                        size: 18,
                        color: AppColors.textSecond),
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
                    // Visuel certificat grand format
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            catColor.withOpacity(0.1),
                            catColor.withOpacity(0.03),
                          ],
                        ),
                        borderRadius:
                            BorderRadius.circular(20),
                        border: Border.all(
                          color: catColor.withOpacity(0.2)),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.workspace_premium_rounded,
                            color: catColor, size: 52),
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
                          Text(nomEtudiant,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: catColor,
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
                          Text(cert.titreCours,
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

                    // Détails
                    _detailRow(
                      Icons.person_outline,
                      'Formateur',
                      cert.nomFormateur,
                    ),
                    _detailRow(
                      Icons.category_outlined,
                      'Catégorie',
                      cert.categorie,
                    ),
                    _detailRow(
                      Icons.calendar_today_outlined,
                      'Date d\'émission',
                      cert.dateEmission,
                    ),
                    _detailRow(
                      Icons.access_time_outlined,
                      'Durée de formation',
                      '${cert.dureeHeures} heures',
                    ),
                    _detailRow(
                      Icons.qr_code_outlined,
                      'Code de vérification',
                      cert.codeVerification,
                      isCode: true,
                    ),
                    const SizedBox(height: 20),

                    // Bouton partager
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(14)),
                        ),
                        icon: const Icon(Icons.share_outlined,
                          color: Colors.white, size: 18),
                        label: const Text('Partager',
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
      IconData icon, String label, String value,
      {bool isCode = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(
          horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textHint),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textHint,
                ),
              ),
              const SizedBox(height: 2),
              Text(value,
                style: TextStyle(
                  fontSize: isCode ? 11 : 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                  fontFamily:
                      isCode ? 'monospace' : null,
                  letterSpacing: isCode ? 0.5 : 0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}