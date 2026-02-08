import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/product.dart';
import '../providers/order_provider.dart';

class CheckoutScreen extends StatefulWidget {
  final Product product;

  const CheckoutScreen({super.key, required this.product});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String _selectedPaymentMethod = 'click_to_pay';
  final TextEditingController _addressController = TextEditingController();

  Future<void> _processOrder() async {
    if (_addressController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a shipping address')),
      );
      return;
    }

    // Mock Payment Step
    bool confirmed = await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Payment'),
        content: Text('Proceed with payment via $_selectedPaymentMethod for ${widget.product.price} TND?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Confirm')),
        ],
      ),
    );

    if (confirmed) {
      final success = await Provider.of<OrderProvider>(context, listen: false).createOrder(
        widget.product.id,
        _selectedPaymentMethod,
        _addressController.text,
      );

      if (success) {
        if (mounted) {
            // Show Success & Go to Home or Order History
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Order Placed Successfully!')),
            );
            Navigator.of(context).popUntil((route) => route.isFirst);
        }
      } else {
        if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Failed to place order.')),
            );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Summary
            Card(
              child: ListTile(
                leading: widget.product.images.isNotEmpty
                    ? Image.network(widget.product.images.first, width: 50, height: 50, fit: BoxFit.cover, errorBuilder: (_,__,___)=>const Icon(Icons.image))
                    : const Icon(Icons.image),
                title: Text(widget.product.title),
                subtitle: Text('${widget.product.price} TND'),
              ),
            ),
            const SizedBox(height: 20),
            
            // Shipping Address
            const Text('Shipping Address', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            TextField(
              controller: _addressController,
              decoration: const InputDecoration(
                hintText: 'Enter your full address',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 20),

            // Payment Method
            const Text('Payment Method', style: TextStyle(fontWeight: FontWeight.bold)),
            RadioListTile(
              title: const Text('Click to Pay (Bank Card)'),
              value: 'click_to_pay',
              groupValue: _selectedPaymentMethod,
              onChanged: (val) => setState(() => _selectedPaymentMethod = val!),
            ),
            RadioListTile(
              title: const Text('Flouci Wallet'),
              value: 'flouci',
              groupValue: _selectedPaymentMethod,
              onChanged: (val) => setState(() => _selectedPaymentMethod = val!),
            ),
             RadioListTile(
              title: const Text('Cash on Delivery'),
              value: 'cash_on_delivery',
              groupValue: _selectedPaymentMethod,
              onChanged: (val) => setState(() => _selectedPaymentMethod = val!),
            ),

            const SizedBox(height: 30),
            
            // Fee Breakdown
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Subtotal'),
                Text('${widget.product.price} TND'),
              ],
            ),
            const SizedBox(height: 5),
             const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                 Text('Delivery Fee'),
                 Text('7.0 TND'),
              ],
            ),
            const Divider(),
             Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                Text('${widget.product.price + 7} TND', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Theme.of(context).primaryColor)),
              ],
            ),
            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _processOrder,
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                child: const Text('Confirm Purchase'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
