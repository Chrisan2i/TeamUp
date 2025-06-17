import 'package:flutter/material.dart';
import 'register_step1.dart';
import 'register_step2.dart';
import 'register_step3.dart';
import 'register_step4.dart';

class RegistrationFlowScreen extends StatefulWidget {
  const RegistrationFlowScreen({super.key});

  @override
  State<RegistrationFlowScreen> createState() => _RegistrationFlowScreenState();
}

class _RegistrationFlowScreenState extends State<RegistrationFlowScreen> {
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToNextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeIn,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: _pageController,
      // Deshabilitamos el deslizamiento para forzar el uso de los botones
      physics: const NeverScrollableScrollPhysics(),
      children: [
        // Pasamos la función para ir a la siguiente página a cada paso
        RegisterStep1(onNext: _goToNextPage),
        RegisterStep2(onNext: _goToNextPage),
        RegisterStep3(onNext: _goToNextPage),
        const RegisterStep4(), // El último paso no necesita 'onNext'
      ],
    );
  }
}