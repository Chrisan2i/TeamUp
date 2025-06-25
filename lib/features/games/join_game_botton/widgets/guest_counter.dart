// lib/features/game/presentation/widgets/join_game_sheet/guest_counter.dart
import 'package:flutter/material.dart';

class GuestCounter extends StatelessWidget {
  final int currentGuestCount;
  final int spotsLeft;
  final ValueChanged<int> onChanged;

  const GuestCounter({
    super.key,
    required this.currentGuestCount,
    required this.spotsLeft,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    const textColor = Color(0xFF1C1C1E);
    return Center(
      child: Column(
        children: [
          Text("Want to bring guests?", style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: textColor)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _CounterButton(
                icon: Icons.remove,
                onPressed: currentGuestCount > 0 ? () => onChanged(currentGuestCount - 1) : null,
              ),
              Container(
                width: 100,
                margin: const EdgeInsets.symmetric(horizontal: 12),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  currentGuestCount.toString(),
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor),
                ),
              ),
              _CounterButton(
                icon: Icons.add,
                onPressed: () {
                  if (1 + currentGuestCount < spotsLeft) {
                    onChanged(currentGuestCount + 1);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("No hay suficientes lugares para más invitados.")));
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CounterButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  const _CounterButton({required this.icon, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(16),
        side: BorderSide(color: Colors.grey.shade300),
        disabledForegroundColor: Colors.grey.withOpacity(0.38),
      ),
      child: Icon(icon, color: onPressed != null ? Colors.black : Colors.grey),
    );
  }
}