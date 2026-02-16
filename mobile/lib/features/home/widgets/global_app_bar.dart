import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../cart/providers/cart_provider.dart';
import '../../cart/screens/cart_screen.dart';
import '../../../core/utils/responsive.dart';

class GlobalAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool showMenu;
  
  const GlobalAppBar({
    super.key,
    this.showMenu = true,
  });

  @override
  Widget build(BuildContext context) {
    double barHeight = Responsive.getHeight(context, 8);
    if (barHeight < 60) barHeight = 60;
    if (barHeight > 100) barHeight = 100;

    return AppBar(
      toolbarHeight: barHeight,
      title: Image.asset(
        'assets/images/SoukPro.png',
        height: barHeight * 1.2,
        fit: BoxFit.contain,
      ),
      centerTitle: true,
      elevation: 0,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      foregroundColor: Colors.black,
      leading: showMenu 
        ? Builder(
            builder: (context) => IconButton(
              icon: Icon(Icons.menu, color: const Color(0xFF0B1C2D), size: Responsive.getFontSize(context, 24)),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          )
        : IconButton(
            icon: Icon(Icons.arrow_back, color: const Color(0xFF0B1C2D), size: Responsive.getFontSize(context, 24)),
            onPressed: () => Navigator.pop(context),
          ),
      actions: [
        Consumer<CartProvider>(
          builder: (context, cart, _) => Stack(
            children: [
              IconButton(
                icon: Icon(Icons.shopping_cart_outlined, color: const Color(0xFF0B1C2D), size: Responsive.getFontSize(context, 24)),
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
                      style: TextStyle(
                        color: Colors.white, 
                        fontSize: Responsive.getFontSize(context, 9), 
                        fontWeight: FontWeight.bold
                      ),
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
  Size get preferredSize => const Size.fromHeight(80); // This is a hint, actual height is set in build toolbarHeight
}
