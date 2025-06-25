import 'package:flutter/material.dart';

/// El botón principal de acción para unirse a un partido.
///
/// Muestra un indicador de progreso cuando [isJoining] es verdadero y se
/// deshabilita si [canJoin] es falso.
class JoinGameButton extends StatelessWidget {
  final bool isJoining;
  final bool canJoin;
  final VoidCallback? onPressed;

  const JoinGameButton({
    super.key,
    required this.isJoining,
    required this.canJoin,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        // El botón se deshabilita si no se puede unir O si ya se está uniendo
        onPressed: (canJoin && !isJoining) ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF008060),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          disabledBackgroundColor: Colors.grey.shade400,
        ),
        child: isJoining
            ? const SizedBox(
          height: 24,
          width: 24,
          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
        )
            : const Text(
          "Let's Play",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }
}