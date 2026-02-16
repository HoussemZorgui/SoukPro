import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'register_screen.dart';
import '../../home/screens/main_layout_screen.dart';
import 'package:mobile/core/widgets/google_button.dart';
import 'verification_screen.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/utils/responsive.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.login(
        _emailController.text,
        _passwordController.text,
      );

      if (success && mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainLayoutScreen()),
        );
      } else if (mounted) {
        if (authProvider.errorMessage == 'VERIFY_REQUIRED') {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => VerificationScreen(email: _emailController.text),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(authProvider.errorMessage ?? 'Connexion échouée'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final double scWidth = Responsive.screenWidth(context);
    final double horizontalPadding = Responsive.getWidth(context, 8);
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: Responsive.getHeight(context, 4),
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    FadeInDown(
                      child: Image.asset(
                        'assets/images/SoukPro.png',
                        height: Responsive.getHeight(context, 18),
                        fit: BoxFit.contain,
                      ),
                    ),
                    SizedBox(height: Responsive.getHeight(context, 3)),
                    FadeInLeft(
                      child: Text(
                        'Bienvenue',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: Responsive.getFontSize(context, 32),
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF0B1C2D),
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    FadeInRight(
                      child: Text(
                        'Connectez-vous pour continuer',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: Responsive.getFontSize(context, 15),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    SizedBox(height: Responsive.getHeight(context, 5)),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        hintText: 'votre@email.com',
                        prefixIcon: const Icon(Icons.email_outlined),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                      ),
                      validator: (value) => value == null || value.isEmpty ? 'Entrez votre email' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Mot de passe',
                        hintText: '••••••••',
                        prefixIcon: const Icon(Icons.lock_outline),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                      ),
                      validator: (value) => value == null || value.isEmpty ? 'Entrez votre mot de passe' : null,
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {},
                        child: Text(
                          'Mot de passe oublié ?',
                          style: TextStyle(
                            color: const Color(0xFFC9A24D),
                            fontWeight: FontWeight.w700,
                            fontSize: Responsive.getFontSize(context, 13),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                  width: double.infinity,
                  height: 58,
                  child: ElevatedButton(
                        onPressed: authProvider.isLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0B1C2D),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                          elevation: 0,
                        ),
                        child: authProvider.isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              'SE CONNECTER',
                              style: GoogleFonts.outfit(
                                fontSize: Responsive.getFontSize(context, 16),
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1,
                              ),
                            ),
                  ),
                ),
                    SizedBox(height: Responsive.getHeight(context, 3)),
                    Row(
                      children: [
                        const Expanded(child: Divider()),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'OU',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const Expanded(child: Divider()),
                      ],
                    ),
                    SizedBox(height: Responsive.getHeight(context, 3)),
                    const GoogleSignInButton(),
                    SizedBox(height: Responsive.getHeight(context, 4)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Vous n'avez pas de compte ?",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: Responsive.getFontSize(context, 14),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const RegisterScreen()),
                            );
                          },
                          child: Text(
                            "S'inscrire",
                            style: TextStyle(
                              color: const Color(0xFF0B1C2D),
                              fontWeight: FontWeight.w900,
                              fontSize: Responsive.getFontSize(context, 14),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
