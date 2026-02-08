import 'package:flutter/material.dart';

class GlobalAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool showMenu;
  
  const GlobalAppBar({
    super.key,
    this.showMenu = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: 100,
      title: Image.asset(
        'assets/images/SoukPro.png',
        height: 150,
        fit: BoxFit.contain,
      ),
      centerTitle: true,
      elevation: 0,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      foregroundColor: Colors.black,
      leading: showMenu 
        ? Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu, color: Color(0xFF0B1C2D)),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          )
        : IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF0B1C2D)),
            onPressed: () => Navigator.pop(context),
          ),
      actions: [
        IconButton(
          icon: const Icon(Icons.shopping_cart_outlined, color: Color(0xFF0B1C2D)),
          onPressed: () {},
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(100);
}
