import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/screens/login_screen.dart';
import '../../../core/constants/api_constants.dart';
import '../../shop/screens/all_shops_screen.dart';
import '../../../core/utils/responsive.dart';

class GlobalDrawer extends StatelessWidget {
  const GlobalDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    double drawerWidth = Responsive.getWidth(context, 85);
    if (drawerWidth > 350) drawerWidth = 350;

    return Drawer(
      width: drawerWidth,
      backgroundColor: const Color(0xFF0B1C2D),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: Column(
        children: [
          _buildHeader(context, user),
          const SizedBox(height: 10),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ListView(
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildMenuSection(context, 'GENERAL'),
                  _buildDrawerItem(
                    context: context,
                    index: 0,
                    icon: Icons.storefront_rounded,
                    title: 'Boutiques',
                    subtitle: 'Explorer les commerçants',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const AllShopsScreen()));
                    },
                  ),
                  _buildDrawerItem(
                    context: context,
                    index: 1,
                    icon: Icons.local_offer_rounded,
                    title: 'Offres Flash',
                    subtitle: 'Promotions de la semaine',
                    onTap: () => Navigator.pop(context),
                  ),
                  _buildDrawerItem(
                    context: context,
                    index: 2,
                    icon: Icons.flash_on_rounded,
                    title: 'Enchères Live',
                    subtitle: 'Ventes en temps réel',
                    onTap: () => Navigator.pop(context),
                  ),
                  const SizedBox(height: 20),
                  _buildMenuSection(context, 'SUPPORT'),
                  _buildDrawerItem(
                    context: context,
                    index: 3,
                    icon: Icons.chat_bubble_outline_rounded,
                    title: 'Réclamations',
                    subtitle: 'Nous sommes à votre écoute',
                    onTap: () => Navigator.pop(context),
                  ),
                  _buildDrawerItem(
                    context: context,
                    index: 4,
                    icon: Icons.help_outline_rounded,
                    title: 'Centre d\'aide',
                    subtitle: 'FAQ et guides',
                    onTap: () => Navigator.pop(context),
                  ),
                  _buildDrawerItem(
                    context: context,
                    index: 5,
                    icon: Icons.info_outline_rounded,
                    title: 'À propos de nous',
                    subtitle: 'L\'histoire de SoukPro',
                    onTap: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
          ),
          _buildFooter(context, authProvider),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, dynamic user) {
    double avatarRadius = Responsive.getFontSize(context, 40);
    if (avatarRadius > 50) avatarRadius = 50;

    return FadeInDown(
      duration: const Duration(milliseconds: 600),
      child: Container(
        padding: EdgeInsets.fromLTRB(25, Responsive.getHeight(context, 8), 25, 30),
        decoration: const BoxDecoration(
          color: Color(0xFF0B1C2D),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFC9A24D), width: 2),
                boxShadow: [
                  BoxShadow(color: const Color(0xFFC9A24D).withOpacity(0.2), blurRadius: 20, spreadRadius: 2)
                ],
              ),
              child: CircleAvatar(
                radius: avatarRadius,
                backgroundColor: Colors.white12,
                backgroundImage: (user?.avatar != null && user!.avatar!.isNotEmpty)
                  ? NetworkImage(user.avatar!.startsWith('http')
                    ? user.avatar!
                    : '${ApiConstants.baseUrl.replaceAll('/api', '')}/${user.avatar!}')
                  : null,
                child: (user?.avatar == null || user!.avatar!.isEmpty)
                  ? Icon(Icons.person, size: avatarRadius * 0.8, color: Colors.white)
                  : null,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              user?.name ?? 'Bienvenue',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: Responsive.getFontSize(context, 22),
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    user?.email ?? 'Connectez-vous pour continuer',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.outfit(
                      color: Colors.white60,
                      fontSize: Responsive.getFontSize(context, 12),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuSection(BuildContext context, String title) {
    return FadeIn(
      delay: const Duration(milliseconds: 300),
      child: Padding(
        padding: const EdgeInsets.only(left: 10, bottom: 15, top: 10),
        child: Text(
          title,
          style: GoogleFonts.outfit(
            color: const Color(0xFFC9A24D).withOpacity(0.7),
            fontSize: Responsive.getFontSize(context, 10),
            fontWeight: FontWeight.w800,
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required BuildContext context,
    required int index,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return FadeInLeft(
      delay: Duration(milliseconds: 100 * index + 400),
      duration: const Duration(milliseconds: 500),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(18),
            splashColor: const Color(0xFFC9A24D).withOpacity(0.1),
            highlightColor: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
                gradient: LinearGradient(
                  colors: [Colors.white.withOpacity(0.05), Colors.transparent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: const Color(0xFFC9A24D), size: Responsive.getFontSize(context, 20)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: Responsive.getFontSize(context, 14),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          subtitle,
                          style: GoogleFonts.outfit(
                            color: Colors.white38,
                            fontSize: Responsive.getFontSize(context, 10),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios_rounded, size: 10, color: Colors.white.withOpacity(0.2)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context, AuthProvider auth) {
    return FadeInUp(
      child: Container(
        padding: EdgeInsets.fromLTRB(25, 20, 25, Responsive.isSmallPortrait(context) ? 20 : 40),
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
        ),
        child: Column(
          children: [
            _buildLogoutButton(context, auth),
            const SizedBox(height: 15),
            Text(
              'SOUKPRO v2.0.4',
              style: GoogleFonts.outfit(
                color: Colors.white24,
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context, AuthProvider auth) {
    return GestureDetector(
      onTap: () {
        auth.logout();
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.redAccent.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.redAccent.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.logout_rounded, color: Colors.redAccent, size: 18),
            const SizedBox(width: 10),
            Text(
              'DÉCONNEXION',
              style: GoogleFonts.outfit(
                color: Colors.redAccent,
                fontWeight: FontWeight.w800,
                fontSize: Responsive.getFontSize(context, 12),
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

