import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../../home/screens/main_layout_screen.dart';
import 'package:mobile/core/widgets/google_button.dart';
import 'verification_screen.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/utils/responsive.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _role = 'user'; // 'user' or 'professional'

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.register(
        _nameController.text,
        _emailController.text,
        _passwordController.text,
        _role,
      );

      if (success && mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => VerificationScreen(email: _emailController.text),
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage ?? 'Inscription échouée'),
            behavior: SnackBarBehavior.floating,
          ),
        );
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
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF0B1C2D)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: Responsive.getHeight(context, 2),
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    FadeInDown(
                      child: Image.asset(
                        'assets/images/SoukPro.png',
                        height: Responsive.getHeight(context, 12),
                        fit: BoxFit.contain,
                      ),
                    ),
                    SizedBox(height: Responsive.getHeight(context, 2)),
                    FadeInLeft(
                      child: Text(
                        'Créer un compte',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: Responsive.getFontSize(context, 28),
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF0B1C2D),
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    FadeInRight(
                      child: Text(
                        'Rejoignez la plus grande place de marché',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: Responsive.getFontSize(context, 14),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    SizedBox(height: Responsive.getHeight(context, 4)),
                    // Role Selector (Premium Style)
                    FadeInUp(
                      child: Center(
                        child: SegmentedButton<String>(
                          segments: const [
                            ButtonSegment(
                              value: 'user',
                              label: Text('Particulier'),
                              icon: Icon(Icons.person_outline, size: 18),
                            ),
                            ButtonSegment(
                              value: 'professional',
                              label: Text('Boutique'),
                              icon: Icon(Icons.storefront_outlined, size: 18),
                            ),
                          ],
                          selected: {_role},
                          onSelectionChanged: (Set<String> newSelection) {
                            setState(() => _role = newSelection.first);
                          },
                          style: SegmentedButton.styleFrom(
                            backgroundColor: Colors.grey[100],
                            selectedBackgroundColor: const Color(0xFF0B1C2D),
                            selectedForegroundColor: Colors.white,
                            side: BorderSide.none,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: Responsive.getHeight(context, 4)),
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Nom complet',
                        hintText: 'John Doe',
                        prefixIcon: const Icon(Icons.person_outline),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                      ),
                      validator: (value) => value == null || value.isEmpty ? 'Entrez votre nom' : null,
                    ),
                    const SizedBox(height: 16),
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
                      validator: (value) => value == null || value.length < 6 ? 'Min 6 caractères' : null,
                    ),
                    SizedBox(height: Responsive.getHeight(context, 4)),
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
                              'CRÉER UN COMPTE',
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
                    const GoogleSignInButton(showRoleSelection: true),
                    SizedBox(height: Responsive.getHeight(context, 2)),
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
