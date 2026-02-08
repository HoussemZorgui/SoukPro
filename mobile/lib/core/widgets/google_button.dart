import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/home/screens/main_layout_screen.dart';

class GoogleSignInButton extends StatelessWidget {
  final String? role;
  final bool showRoleSelection;
  const GoogleSignInButton({super.key, this.role, this.showRoleSelection = false});

  Future<void> _handleSignIn(BuildContext context, AuthProvider authProvider, String? selectedRole) async {
    // On capture le navigateur avant l'appel async pour éviter les problèmes de contexte
    final navigator = Navigator.of(context);
    
    final success = await authProvider.signInWithGoogle(role: selectedRole);
    
    if (success) {
      print("NAVIGATION: Redirection forcée vers Home...");
      navigator.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MainLayoutScreen()),
        (route) => false,
      );
    } else if (authProvider.errorMessage != null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(authProvider.errorMessage!)),
        );
      }
    }
  }

  void _showRoleSelectionBottomSheet(BuildContext context, AuthProvider authProvider) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Choisissez votre type de compte',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Comment souhaitez-vous utiliser SoukPro ?',
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            _buildRoleOption(
              context,
              title: 'Acheteur / Utilisateur',
              description: 'Achetez des produits, participez aux enchères et trouvez des pépites.',
              icon: Icons.person_outline,
              onTap: () {
                Navigator.pop(context);
                _handleSignIn(context, authProvider, 'user');
              },
            ),
            const SizedBox(height: 12),
            _buildRoleOption(
              context,
              title: 'Boutique Professionnelle',
              description: 'Vendez vos produits, gérez vos stocks et boostez votre activité.',
              icon: Icons.store_outlined,
              onTap: () {
                Navigator.pop(context);
                _handleSignIn(context, authProvider, 'professional');
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleOption(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: const Color(0xFF1E293B)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(description, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isLoading = authProvider.isLoading;

    return OutlinedButton(
      onPressed: isLoading
          ? null
          : () {
              if (showRoleSelection && role == null) {
                _showRoleSelectionBottomSheet(context, authProvider);
              } else {
                _handleSignIn(context, authProvider, role);
              }
            },
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        side: const BorderSide(color: Colors.grey),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.network(
            'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/1200px-Google_%22G%22_logo.svg.png',
            height: 20,
          ),
          const SizedBox(width: 12),
          const Text(
            'Continuer avec Google',
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
