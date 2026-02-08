import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/screens/login_screen.dart';
import '../../../core/constants/api_constants.dart';
import '../../shop/screens/all_shops_screen.dart';

class GlobalDrawer extends StatelessWidget {
  const GlobalDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return Drawer(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          // Centered Ultra-Elegant Header
          Container(
            padding: const EdgeInsets.only(top: 60, bottom: 30, left: 20, right: 20),
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFFDBB881),
              borderRadius: BorderRadius.only(bottomRight: Radius.circular(40)),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFDBB881), Color(0xFFC9A24D)],
              ),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withOpacity(0.2), width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    backgroundImage: (user?.avatar != null && user!.avatar!.isNotEmpty)
                        ? NetworkImage(user.avatar!.startsWith('http')
                            ? user.avatar!
                            : '${ApiConstants.baseUrl.replaceAll('/api', '')}/${user.avatar!}')
                        : null,
                    child: (user?.avatar == null || user!.avatar!.isEmpty)
                        ? const Icon(Icons.person, size: 50, color: Color(0xFF0B1C2D))
                        : null,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  user?.name ?? 'Invité',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user?.email ?? 'Rejoignez SoukPro aujourd\'hui',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              children: [
                _buildDrawerItem(
                  context,
                  icon: Icons.storefront_outlined,
                  title: 'Toutes les Boutiques',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AllShopsScreen()),
                    );
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.local_offer_outlined,
                  title: 'Offres & Réductions',
                  onTap: () => Navigator.pop(context),
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.event_available_outlined,
                  title: 'Événements',
                  onTap: () => Navigator.pop(context),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  child: Divider(color: Color(0xFFEEEEEE), thickness: 1),
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.assignment_late_outlined,
                  title: 'Réclamations',
                  onTap: () => Navigator.pop(context),
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.help_outline,
                  title: 'Centre d\'Aide',
                  onTap: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          // Footer Section
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                const Divider(thickness: 1),
                const SizedBox(height: 10),
                _buildDrawerItem(
                  context,
                  icon: Icons.logout,
                  title: 'Déconnexion',
                  color: Colors.redAccent,
                  isLogout: true,
                  onTap: () {
                    Provider.of<AuthProvider>(context, listen: false).logout();
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? color,
    bool isLogout = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isLogout ? Colors.red.withOpacity(0.05) : Colors.transparent,
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        leading: Icon(icon, color: color ?? const Color(0xFF0B1C2D), size: 24),
        title: Text(
          title,
          style: TextStyle(
            color: color ?? const Color(0xFF0B1C2D),
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
        trailing: isLogout ? null : const Icon(Icons.chevron_right, size: 18, color: Colors.grey),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
    );
  }
}
