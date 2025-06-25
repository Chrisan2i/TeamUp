import 'package:flutter/material.dart';

/// La vista que se muestra en un BottomSheet para permitir al usuario
/// seleccionar un método de pago de una lista.
class PaymentMethodsView extends StatelessWidget {
  final String currentMethod;
  final Function(String) onMethodSelected;

  const PaymentMethodsView({
    super.key,
    required this.currentMethod,
    required this.onMethodSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Métodos de Pago", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  PaymentMethodTile(
                    title: "Pago Móvil",
                    iconWidget: const Icon(Icons.phone_android_outlined, color: Color(0xFF008060)),
                    isSelected: currentMethod == "Pago Móvil",
                    onTap: () => onMethodSelected("Pago Móvil"),
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16,),
                  PaymentMethodTile(
                    title: "Añadir Tarjeta (Próximamente)",
                    iconWidget: const Icon(Icons.add, color: Colors.grey),
                    isSelected: false,
                    // Deshabilitamos el onTap o mostramos un mensaje
                    onTap: null,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF008060),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("Hecho", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Un item individual en la lista de métodos de pago.
class PaymentMethodTile extends StatelessWidget {
  final String title;
  final Widget iconWidget;
  final bool isSelected;
  final VoidCallback? onTap;

  const PaymentMethodTile({
    super.key,
    required this.title,
    required this.iconWidget,
    required this.isSelected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            iconWidget,
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(fontSize: 16, color: onTap != null ? Colors.black : Colors.grey),
            ),
            const Spacer(),
            if (isSelected)
              const CircleAvatar(
                radius: 12,
                backgroundColor: Color(0xFF008060),
                child: Icon(Icons.check, color: Colors.white, size: 16),
              ),
          ],
        ),
      ),
    );
  }
}