import 'package:flutter/material.dart';

/// Muestra una fila con el método de pago seleccionado y un botón
/// para iniciar el flujo de cambio de método.
class PaymentDetailsRow extends StatelessWidget {
  final String selectedMethod;
  final VoidCallback onChangePayment;

  const PaymentDetailsRow({
    super.key,
    required this.selectedMethod,
    required this.onChangePayment,
  });

  @override
  Widget build(BuildContext context) {
    const subtextColor = Color(0xFF8A8A8E);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "DETALLES DE PAGO",
          style: TextStyle(fontSize: 12, color: subtextColor, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.phone_android_outlined, color: Colors.black54),
                const SizedBox(width: 8),
                Text(selectedMethod, style: const TextStyle(fontSize: 16)),
              ],
            ),
            TextButton(
              onPressed: onChangePayment,
              child: const Text(
                "CAMBIAR",
                style: TextStyle(color: Color(0xFF008060), fontWeight: FontWeight.bold),
              ),
            ),
          ],
        )
      ],
    );
  }
}