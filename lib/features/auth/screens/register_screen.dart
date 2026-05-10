import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:elearning/features/auth/providers/auth_provider.dart';
import '../../../core/constants/app_colors.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey          = GlobalKey<FormState>();
  final _nomController    = TextEditingController();
  final _prenomController = TextEditingController();
  final _emailController  = TextEditingController();
  final _passController   = TextEditingController();
  final _confirmController= TextEditingController();

  bool _obscurePass    = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _emailController.dispose();
    _passController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final auth    = context.read<AuthProvider>();
    final success = await auth.register(
      _emailController.text.trim(),
      _passController.text,
      _nomController.text.trim(),
      _prenomController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      _nomController.clear();
      _prenomController.clear();
      _emailController.clear();
      _passController.clear();
      _confirmController.clear();
      Navigator.pushReplacementNamed(context, '/student-dashboard');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Erreur lors de l\'inscription'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [

              // ── Header gradient ──
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.only(
                    bottomLeft:  Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                ),
                child: Column(
                  children: [
                    // Bouton retour
                    Align(
                      alignment: Alignment.centerLeft,
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 38, height: 38,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3)),
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new,
                            color: Colors.white, size: 16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Logo
                    Container(
                      width: 64, height: 64,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1.5),
                      ),
                      child: const Icon(
                        Icons.person_add_outlined,
                        color: Colors.white, size: 30),
                    ),
                    const SizedBox(height: 16),

                    const Text('Créer un compte',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Inscription réservée aux étudiants',
                      style: TextStyle(
                        color: Color(0xFFBFDBFE),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

              // ── Formulaire ──
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      // ── Prénom + Nom ──
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                _buildLabel('Prénom'),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _prenomController,
                                  style: _inputTextStyle(),
                                  decoration: _inputDecoration(
                                    hint: 'Prénom',
                                    prefixIcon:
                                        Icons.person_outline,
                                  ),
                                  validator: (v) =>
                                      (v == null || v.isEmpty)
                                          ? 'Obligatoire'
                                          : null,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                _buildLabel('Nom'),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _nomController,
                                  style: _inputTextStyle(),
                                  decoration: _inputDecoration(
                                    hint: 'Nom',
                                    prefixIcon:
                                        Icons.person_outline,
                                  ),
                                  validator: (v) =>
                                      (v == null || v.isEmpty)
                                          ? 'Obligatoire'
                                          : null,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),

                      // ── Email ──
                      _buildLabel('Email universitaire'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: _inputTextStyle(),
                        decoration: _inputDecoration(
                          hint: 'vous@univ.ma',
                          prefixIcon: Icons.email_outlined,
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty)
                            return 'Email obligatoire';
                          final regex =
                              RegExp(r'^[^@]+@[^@]+\.[^@]+');
                          if (!regex.hasMatch(v))
                            return 'Email invalide';
                          return null;
                        },
                      ),
                      const SizedBox(height: 18),

                      // ── Mot de passe ──
                      _buildLabel('Mot de passe'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _passController,
                        obscureText: _obscurePass,
                        style: _inputTextStyle(),
                        decoration: _inputDecoration(
                          hint: 'Minimum 8 caractères',
                          prefixIcon: Icons.lock_outline,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePass
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              size: 20,
                              color: AppColors.textHint,
                            ),
                            onPressed: () => setState(
                              () => _obscurePass = !_obscurePass),
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty)
                            return 'Mot de passe obligatoire';
                          if (v.length < 8)
                            return 'Minimum 8 caractères';
                          return null;
                        },
                      ),
                      const SizedBox(height: 18),

                      // ── Confirmer mot de passe ──
                      _buildLabel('Confirmer le mot de passe'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _confirmController,
                        obscureText: _obscureConfirm,
                        style: _inputTextStyle(),
                        decoration: _inputDecoration(
                          hint: 'Répétez le mot de passe',
                          prefixIcon: Icons.lock_outline,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirm
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              size: 20,
                              color: AppColors.textHint,
                            ),
                            onPressed: () => setState(
                              () => _obscureConfirm =
                                  !_obscureConfirm),
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty)
                            return 'Confirmation obligatoire';
                          if (v != _passController.text)
                            return 'Les mots de passe ne correspondent pas';
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // ── Badge info ──
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primarySoft,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFFBFDBFE)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.info_outline,
                              color: AppColors.primary, size: 18),
                            const SizedBox(width: 10),
                            const Expanded(
                              child: Text(
                                'Les profs et admins sont créés '
                                'par l\'administrateur.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.primary,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),

                      // ── Bouton S'inscrire ──
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            disabledBackgroundColor:
                                AppColors.primary.withOpacity(0.5),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(14)),
                            elevation: 0,
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  width: 22, height: 22,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : const Text(
                                  'Créer mon compte étudiant',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 18),

                      // ── Lien Login ──
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Déjà un compte ? ',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textHint,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.pushNamed(
                              context, '/login'),
                            child: const Text('Se connecter',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
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

  // ── Helpers ──

  Widget _buildLabel(String text) {
    return Text(text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
      ),
    );
  }

  TextStyle _inputTextStyle() => const TextStyle(
    fontSize: 14,
    color: AppColors.textPrimary,
  );

  InputDecoration _inputDecoration({
    required String hint,
    required IconData prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: AppColors.textHint, fontSize: 14),
      prefixIcon: Icon(prefixIcon,
        size: 20, color: AppColors.textHint),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: AppColors.border, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: AppColors.border, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: AppColors.error, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: AppColors.error, width: 2),
      ),
    );
  }
}