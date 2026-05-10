import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── Couleurs principales ──
  static const Color primary      = Color(0xFF2563EB);
  static const Color primaryDark  = Color(0xFF1E3A8A);
  static const Color primaryLight = Color(0xFF3B82F6);
  static const Color primarySoft  = Color(0xFFEFF6FF);

  // ── Secondaire ──
  static const Color secondary      = Color(0xFF7C3AED);
  static const Color secondaryLight = Color(0xFFF5F3FF);

  // ── Statuts ──
  static const Color success      = Color(0xFF059669);
  static const Color successLight = Color(0xFFF0FDF4);
  static const Color successSoft  = Color(0xFFD1FAE5);

  static const Color warning      = Color(0xFFD97706);
  static const Color warningLight = Color(0xFFFFFBEB);
  static const Color warningSoft  = Color(0xFFFEF3C7);

  static const Color error        = Color(0xFFDC2626);
  static const Color errorLight   = Color(0xFFFEF2F2);
  static const Color errorSoft    = Color(0xFFFEE2E2);

  static const Color info         = Color(0xFF0891B2);
  static const Color infoLight    = Color(0xFFECFEFF);
  static const Color infoSoft     = Color(0xFFCFFAFE);

  // ── Textes ──
  static const Color textPrimary  = Color(0xFF0F172A);
  static const Color textSecond   = Color(0xFF64748B);
  static const Color textHint     = Color(0xFF94A3B8);
  static const Color textDisabled = Color(0xFFCBD5E1);
  static const Color textInverse  = Color(0xFFFFFFFF);

  // ── Backgrounds ──
  static const Color background       = Color(0xFFF8FAFC);
  static const Color backgroundCard   = Color(0xFFFFFFFF);
  static const Color backgroundInput  = Color(0xFFFFFFFF);
  static const Color backgroundModal  = Color(0xFFFFFFFF);

  // ── Surfaces ──
  static const Color surface         = Color(0xFFFFFFFF);
  static const Color surfaceSecond   = Color(0xFFF1F5F9);
  static const Color surfaceTertiary = Color(0xFFE2E8F0);

  // ── Bordures ──
  static const Color border        = Color(0xFFE2E8F0);
  static const Color borderLight   = Color(0xFFF1F5F9);
  static const Color borderFocus   = Color(0xFF2563EB);
  static const Color borderError   = Color(0xFFDC2626);

  // ── Couleurs par rôle ──
  static const Color student = Color(0xFF2563EB);
  static const Color teacher = Color(0xFF7C3AED);
  static const Color admin   = Color(0xFFDC2626);

  // ── Catégories de cours ──
  static const Color catInfo        = Color(0xFF2563EB);
  static const Color catInfoBg      = Color(0xFFEFF6FF);
  static const Color catMaths       = Color(0xFF7C3AED);
  static const Color catMathsBg     = Color(0xFFF5F3FF);
  static const Color catPhysique    = Color(0xFF0891B2);
  static const Color catPhysiqueBg  = Color(0xFFECFEFF);
  static const Color catLangues     = Color(0xFF059669);
  static const Color catLanguesBg   = Color(0xFFF0FDF4);
  static const Color catBdd         = Color(0xFFD97706);
  static const Color catBddBg       = Color(0xFFFFFBEB);
  static const Color catReseaux     = Color(0xFFDC2626);
  static const Color catReseauxBg   = Color(0xFFFEF2F2);
  static const Color catIa          = Color(0xFF7C3AED);
  static const Color catIaBg        = Color(0xFFF5F3FF);
  static const Color catGestion     = Color(0xFF0F172A);
  static const Color catGestionBg   = Color(0xFFF1F5F9);

  // ── Gradient principal ──
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF1E3A8A),
      Color(0xFF2563EB),
      Color(0xFF3B82F6),
    ],
  );

  // ── Gradient secondaire ──
  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF5B21B6),
      Color(0xFF7C3AED),
      Color(0xFF8B5CF6),
    ],
  );

  // ── Gradient succès ──
  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF065F46),
      Color(0xFF059669),
      Color(0xFF10B981),
    ],
  );

  // ── Helper : couleur selon le rôle ──
  static Color colorForRole(String role) {
    switch (role) {
      case 'ROLE_TEACHER': return teacher;
      case 'ROLE_ADMIN':   return admin;
      default:             return student;
    }
  }

  // ── Helper : couleur de fond selon le rôle ──
  static Color bgForRole(String role) {
    switch (role) {
      case 'ROLE_TEACHER': return secondaryLight;
      case 'ROLE_ADMIN':   return errorLight;
      default:             return primarySoft;
    }
  }

  // ── Helper : couleur selon la catégorie ──
  static Color colorForCategory(String nom) {
    switch (nom.toLowerCase()) {
      case 'informatique':  return catInfo;
      case 'mathématiques': return catMaths;
      case 'physique':      return catPhysique;
      case 'langues':       return catLangues;
      case 'base de données': return catBdd;
      case 'réseaux':       return catReseaux;
      case 'intelligence artificielle': return catIa;
      case 'gestion de projet': return catGestion;
      default:              return primary;
    }
  }

  // ── Helper : couleur de fond selon la catégorie ──
  static Color bgForCategory(String nom) {
    switch (nom.toLowerCase()) {
      case 'informatique':  return catInfoBg;
      case 'mathématiques': return catMathsBg;
      case 'physique':      return catPhysiqueBg;
      case 'langues':       return catLanguesBg;
      case 'base de données': return catBddBg;
      case 'réseaux':       return catReseauxBg;
      case 'intelligence artificielle': return catIaBg;
      case 'gestion de projet': return catGestionBg;
      default:              return primarySoft;
    }
  }

  // ── Helper : couleur selon le statut du cours ──
  static Color colorForStatut(String statut) {
    switch (statut.toUpperCase()) {
      case 'PUBLIE':    return success;
      case 'BROUILLON': return warning;
      case 'ARCHIVE':   return textHint;
      default:          return textHint;
    }
  }

  static Color bgForStatut(String statut) {
    switch (statut.toUpperCase()) {
      case 'PUBLIE':    return successSoft;
      case 'BROUILLON': return warningSoft;
      case 'ARCHIVE':   return surfaceSecond;
      default:          return surfaceSecond;
    }
  }

  // ── Helper : couleur selon le score quiz ──
  static Color colorForScore(int score) {
    if (score >= 80) return success;
    if (score >= 60) return warning;
    return error;
  }

  static Color bgForScore(int score) {
    if (score >= 80) return successSoft;
    if (score >= 60) return warningSoft;
    return errorSoft;
  }
}