import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../cart/providers/cart_provider.dart';
import '../../cart/screens/cart_screen.dart';

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
        Consumer<CartProvider>(
          builder: (context, cart, _) => Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined, color: Color(0xFF0B1C2D)),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen())),
              ),
              if (cart.itemCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFC9A24D),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Text(
                      '${cart.itemCount}',
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(100);
}
