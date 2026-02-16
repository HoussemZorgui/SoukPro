import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../../home/screens/main_layout_screen.dart';
import 'dart:async';
import '../../../core/utils/responsive.dart';

class VerificationScreen extends StatefulWidget {
  final String email;

  const VerificationScreen({super.key, required this.email});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final List<TextEditingController> _controllers = List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  bool _isLoading = false;
  int _timerSeconds = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _timerSeconds = 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timerSeconds == 0) {
        timer.cancel();
      } else {
        setState(() => _timerSeconds--);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  Future<void> _verify() async {
    String code = _controllers.map((c) => c.text).join();
    if (code.length < 6) return;

    setState(() => _isLoading = true);
    
    // Smooth delay for "elegant" feel
    await Future.delayed(const Duration(milliseconds: 800));

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.verifyCode(widget.email, code);
      
      if (success && mounted) {
        // Show success state
        setState(() => _isLoading = false);
        _showSuccessDialog();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')), 
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle, color: Colors.green, size: 64),
              ),
              const SizedBox(height: 24),
              const Text(
                'Succès !',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                'Votre compte est vérifié et actif.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
              const SizedBox(height: 32),
              const CircularProgressIndicator(strokeWidth: 2),
              const SizedBox(height: 16),
              const Text('Redirection...', style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ),
      ),
    );

    Timer(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const MainLayoutScreen()),
          (route) => false,
        );
      }
    });
  }

  Future<void> _resend() async {
    if (_timerSeconds > 0) return;

    setState(() => _isLoading = true);
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.resendCode(widget.email);
      
      if (success && mounted) {
        _startTimer();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Un nouveau code a été envoyé.')),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage ?? 'Erreur lors de l\'envoi'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF0B1C2D)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: Responsive.getWidth(context, 8),
                vertical: Responsive.getHeight(context, 2),
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Vérification',
                        style: TextStyle(
                          fontSize: Responsive.getFontSize(context, 32),
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF0B1C2D),
                          letterSpacing: -1.0,
                        ),
                      ),
                      const SizedBox(height: 12),
                      RichText(
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: Responsive.getFontSize(context, 16),
                            color: Colors.grey[600],
                            height: 1.5,
                            fontFamily: 'Outfit',
                          ),
                          children: [
                            const TextSpan(text: 'Nous avons envoyé un code de 6 chiffres à\n'),
                            TextSpan(
                              text: widget.email,
                              style: const TextStyle(
                                color: Color(0xFF0B1C2D),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: Responsive.getHeight(context, 6)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(6, (index) {
                          return Expanded(
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              child: TextField(
                                controller: _controllers[index],
                                focusNode: _focusNodes[index],
                                textAlign: TextAlign.center,
                                keyboardType: TextInputType.number,
                                maxLength: 1,
                                style: TextStyle(
                                  fontSize: Responsive.getFontSize(context, 24), 
                                  fontWeight: FontWeight.w900,
                                  color: const Color(0xFF0B1C2D),
                                ),
                                decoration: InputDecoration(
                                  counterText: '',
                                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide(color: Colors.grey[200]!, width: 2),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: const BorderSide(color: Color(0xFFC9A24D), width: 2),
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey[50],
                                ),
                                onChanged: (value) {
                                  if (value.isNotEmpty && index < 5) {
                                    _focusNodes[index + 1].requestFocus();
                                  }
                                  if (value.isEmpty && index > 0) {
                                    _focusNodes[index - 1].requestFocus();
                                  }
                                  if (_controllers.every((c) => c.text.isNotEmpty)) {
                                    _verify();
                                  }
                                },
                              ),
                            ),
                          );
                        }),
                      ),
                      SizedBox(height: Responsive.getHeight(context, 6)),
                      SizedBox(
                        width: double.infinity,
                        height: 58,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _verify,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0B1C2D),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                            elevation: 0,
                          ),
                          child: Text(
                            'VÉRIFIER',
                            style: TextStyle(
                              fontSize: Responsive.getFontSize(context, 16), 
                              fontWeight: FontWeight.w800, 
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: Responsive.getHeight(context, 4)),
                      Center(
                        child: Column(
                          children: [
                            Text(
                              'Vous n\'avez pas reçu le code ?',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: Responsive.getFontSize(context, 14),
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextButton(
                              onPressed: _timerSeconds > 0 ? null : _resend,
                              child: Text(
                                _timerSeconds > 0 
                                    ? 'Renvoyer dans ${_timerSeconds}s'
                                    : 'Renvoyer le code',
                                style: TextStyle(
                                  color: _timerSeconds > 0 ? Colors.grey : const Color(0xFFC9A24D),
                                  fontWeight: FontWeight.w900,
                                  fontSize: Responsive.getFontSize(context, 14),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (_isLoading)
               _buildLoadingOverlay(context),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingOverlay(BuildContext context) {
     return Container(
        color: Colors.white.withOpacity(0.8),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: Color(0xFF2563EB)),
              const SizedBox(height: 16),
              Text(
                'Vérification en cours...',
                style: TextStyle(
                  color: const Color(0xFF2563EB),
                  fontWeight: FontWeight.w600,
                  fontSize: Responsive.getFontSize(context, 16),
                ),
              ),
            ],
          ),
        ),
      );
  }
}
