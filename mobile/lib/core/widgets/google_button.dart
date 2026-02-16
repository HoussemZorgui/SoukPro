import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/home/screens/main_layout_screen.dart';
import '../../../core/utils/responsive.dart';

class GoogleSignInButton extends StatelessWidget {
  final String? role;
  final bool showRoleSelection;
  const GoogleSignInButton({super.key, this.role, this.showRoleSelection = false});

  Future<void> _handleSignIn(BuildContext context, AuthProvider authProvider, String? selectedRole) async {
    final navigator = Navigator.of(context);
    final success = await authProvider.signInWithGoogle(role: selectedRole);
    if (success) {
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
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Type de compte',
              style: TextStyle(
                fontSize: Responsive.getFontSize(context, 24), 
                fontWeight: FontWeight.w900,
                color: const Color(0xFF0B1C2D),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Comment souhaitez-vous utiliser SoukPro ?',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: Responsive.getFontSize(context, 14),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            _buildRoleOption(
              context,
              title: 'Acheteur / Utilisateur',
              description: 'Trouvez les meilleures pépites et enchérissez.',
              icon: Icons.person_outline_rounded,
              color: const Color(0xFF0B1C2D),
              onTap: () {
                Navigator.pop(context);
                _handleSignIn(context, authProvider, 'user');
              },
            ),
            const SizedBox(height: 16),
            _buildRoleOption(
              context,
              title: 'Boutique Certifiée',
              description: 'Vendez vos produits et booster votre business.',
              icon: Icons.storefront_rounded,
              color: const Color(0xFFC9A24D),
              onTap: () {
                Navigator.pop(context);
                _handleSignIn(context, authProvider, 'professional');
              },
            ),
            const SizedBox(height: 24),
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
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[200]!, width: 2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, 
                    style: TextStyle(
                      fontWeight: FontWeight.w800, 
                      fontSize: Responsive.getFontSize(context, 16),
                      color: const Color(0xFF0B1C2D)
                    )),
                  const SizedBox(height: 4),
                  Text(description, 
                    style: TextStyle(
                      fontSize: Responsive.getFontSize(context, 12), 
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500
                    )),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isLoading = authProvider.isLoading;

    return SizedBox(
      height: 58,
      child: OutlinedButton(
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
          side: BorderSide(color: Colors.grey[300]!, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(
              'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/1200px-Google_%22G%22_logo.svg.png',
              height: 22,
            ),
            const SizedBox(width: 12),
            Text(
              'Continuer avec Google',
              style: TextStyle(
                color: const Color(0xFF0B1C2D),
                fontWeight: FontWeight.w700,
                fontSize: Responsive.getFontSize(context, 15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
