// lib/features/friends/widgets/create_group_card.dart
import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';

class CreateGroupCard extends StatelessWidget {
  final VoidCallback onTap;

  const CreateGroupCard({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: DottedBorder(
        color: Colors.grey.shade400,
        strokeWidth: 1.5,
        borderType: BorderType.RRect,
        radius: const Radius.circular(16),
        dashPattern: const [6, 5], // Patrón de guiones (6px de línea, 5px de espacio)
        child: Container(
          width: 120, // Ancho fijo para la tarjeta
          height: 120, // Alto fijo
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.group_add_outlined,
                color: Color(0xFF0CC0DF), // Color azul
                size: 32,
              ),
              SizedBox(height: 8),
              Text(
                'Create group',
                style: TextStyle(
                  color: Color(0xFF1E293B),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}