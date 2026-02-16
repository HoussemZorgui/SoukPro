import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/order.dart';
import '../../auth/providers/auth_provider.dart';
import '../services/order_service.dart';
import 'order_detail_screen.dart';

class OrderLoaderScreen extends StatefulWidget {
  final String orderId;

  const OrderLoaderScreen({super.key, required this.orderId});

  @override
  State<OrderLoaderScreen> createState() => _OrderLoaderScreenState();
}

class _OrderLoaderScreenState extends State<OrderLoaderScreen> {
  final OrderService _orderService = OrderService();
  bool _isLoading = true;
  String? _error;
  Order? _order;

  @override
  void initState() {
    super.initState();
    print('OrderLoaderScreen initialized with orderId: "${widget.orderId}"');
    _loadOrder();
  }

  Future<void> _loadOrder() async {
    try {
      final order = await _orderService.getOrderById(widget.orderId);
      if (mounted) {
        setState(() {
          _order = order;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceAll('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Color(0xFFC9A24D))),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Erreur')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 60, color: Colors.red),
              const SizedBox(height: 20),
              Text(_error!),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loadOrder,
                child: const Text('Réessayer'),
              )
            ],
          ),
        ),
      );
    }

    if (_order != null) {
      final user = context.read<AuthProvider>().user;
      
      bool isSeller = false;
      if (user != null) {
        print('OrderLoader: Current User ID: ${user.id}, Order Buyer ID: ${_order!.buyerId}');
        if (_order!.buyerId != user.id) {
           isSeller = true;
        }
      }
      print('OrderLoader: Navigating to OrderDetailScreen. isSeller: $isSeller');

      return OrderDetailScreen(order: _order!, isSellerView: isSeller);
    }

    return const Scaffold(body: SizedBox.shrink());
  }
}
