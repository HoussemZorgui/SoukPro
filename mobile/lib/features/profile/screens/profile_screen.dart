import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/screens/login_screen.dart';
import '../../shop/screens/shop_dashboard_screen.dart';
import 'order_history_screen.dart';
import 'edit_profile_screen.dart';
import '../../../core/constants/api_constants.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Ultra-Elegant Header Section
            FadeInDown(
              duration: const Duration(milliseconds: 600),
              child: Center(
                child: Stack(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFC9A24D).withOpacity(0.3), width: 2),
                      ),
                      child: CircleAvatar(
                        radius: 65,
                        backgroundColor: Colors.grey[50],
                        backgroundImage: (user?.avatar != null && user!.avatar!.isNotEmpty)
                            ? NetworkImage(user.avatar!.startsWith('http') 
                                ? user.avatar! 
                                : '${ApiConstants.baseUrl.replaceAll('/api', '')}/${user.avatar!}')
                            : null,
                        child: (user?.avatar == null || user!.avatar!.isEmpty)
                            ? Icon(Icons.person_rounded, size: 65, color: Colors.grey[300])
                            : null,
                      ),
                    ),
                    if (user?.role == 'professional')
                      Positioned(
                        bottom: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Color(0xFFC9A24D),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.verified_user_rounded, color: Colors.white, size: 20),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            FadeInUp(
              duration: const Duration(milliseconds: 600),
              child: Column(
                children: [
                  Text(
                    user?.name ?? 'Utilisateur',
                    style: GoogleFonts.outfit(
                      fontSize: 28, 
                      fontWeight: FontWeight.w800, 
                      color: const Color(0xFF0B1C2D),
                      letterSpacing: -0.5
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.email ?? '',
                    style: GoogleFonts.outfit(
                      color: Colors.grey[500], 
                      fontSize: 15,
                      fontWeight: FontWeight.w500
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            
            // Premium Action Sections
            FadeInUp(
              delay: const Duration(milliseconds: 200),
              child: _buildMenuSection('COMPTE PERSONNALISÉ', [
                _buildMenuItem(Icons.shopping_bag_outlined, 'Mes commandes', 'Historique et suivi', () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => const OrderHistoryScreen()));
                }),
                if (user?.role == 'professional' || user?.role == 'admin')
                  _buildMenuItem(Icons.storefront_rounded, 'Ma boutique', 'Gestion professionnelle', () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ShopDashboardScreen()));
                  }, isPremium: true),
                _buildMenuItem(Icons.person_outline_rounded, 'Éditer le profil', 'Informations personnelles', () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => const EditProfileScreen()));
                }),
              ]),
            ),
            
            const SizedBox(height: 24),
            FadeInUp(
              delay: const Duration(milliseconds: 400),
              child: _buildMenuSection('CONFIGURATION', [
                _buildMenuItem(Icons.notifications_none_rounded, 'Notifications', "Préférences d'alerte", () {}),
                _buildMenuItem(Icons.lock_open_rounded, 'Sécurité', 'Mot de passe et accès', () {}),
                _buildMenuItem(Icons.help_outline_rounded, 'Support client', "Centre d'aide", () {}),
              ]),
            ),

            const SizedBox(height: 48),
            FadeInUp(
              delay: const Duration(milliseconds: 600),
              child: SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: () {
                    Provider.of<AuthProvider>(context, listen: false).logout();
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                    );
                  },
                  icon: const Icon(Icons.logout_rounded, size: 20),
                  label: Text('Déconnexion', 
                    style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 16)),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red[700],
                    backgroundColor: Colors.red[50],
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 10, bottom: 16),
          child: Text(
            title,
            style: GoogleFonts.outfit(
              fontSize: 13, 
              fontWeight: FontWeight.w800, 
              color: const Color(0xFF0B1C2D).withOpacity(0.5), 
              letterSpacing: 1.5
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.grey[100]!),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Column(children: items),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem(IconData icon, String title, String subtitle, VoidCallback onTap, {bool isPremium = false}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isPremium ? const Color(0xFFC9A24D).withOpacity(0.1) : const Color(0xFF0B1C2D).withOpacity(0.05),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, color: isPremium ? const Color(0xFFC9A24D) : const Color(0xFF0B1C2D), size: 22),
      ),
      title: Text(title, 
        style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 16, color: const Color(0xFF0B1C2D))),
      subtitle: Text(subtitle, 
        style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey[500], fontWeight: FontWeight.w500)),
      trailing: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(color: Colors.grey[50], shape: BoxShape.circle),
        child: const Icon(Icons.chevron_right_rounded, color: Colors.grey, size: 18),
      ),
      onTap: onTap,
    );
  }
}
