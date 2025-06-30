// lib/features/payment/payment_process_view.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:teamup/models/game_model.dart';
import 'package:teamup/services/payment_service.dart';

// Datos estáticos para los métodos de pago.
const Map<String, dynamic> paymentData = {
  'pago_movil': {
    'title': 'Pago Móvil',
    'icon': Icons.phone_android,
    'details': {
      'Banco': 'Banco Nacional de Crédito',
      'RIF': 'J-123456789',
      'Teléfono': '0412-45678886'
    }
  },
  'zelle': {
    'title': 'Zelle',
    'icon': Icons.email_outlined,
    'details': {
      'Beneficiario': 'TEAMUP LLC',
      'Correo': 'teamUp@gmail.com'
    }
  },
  'binance': {
    'title': 'Binance Pay',
    'icon': Icons.currency_bitcoin,
    'details': {
      'Correo/Teléfono': 'operaciones@teamup.com',
      'Pay ID': '123445677'
    }
  },
  'transferencia': {
    'title': 'Transferencia',
    'icon': Icons.account_balance,
    'details': {
      'Banco': 'Bancamiga',
      'Nro. Cuenta': '0172-0110-2556-2334-9721',
      'RIF/CI': 'J-12324456',
      'Beneficiario': 'TeamUp Solutions C.A.'
    }
  }
};

class PaymentProcessView extends StatefulWidget {
  final GameModel game;
  final int totalPeopleJoining;

  const PaymentProcessView({
    super.key,
    required this.game,
    required this.totalPeopleJoining,
  });

  @override
  State<PaymentProcessView> createState() => _PaymentProcessViewState();
}

class _PaymentProcessViewState extends State<PaymentProcessView> {
  String? _selectedMethodKey;
  bool _isLoading = false;
  File? _selectedImage;

  final _formKey = GlobalKey<FormState>();
  final _referenceController = TextEditingController();
  final PaymentService _paymentService = PaymentService();

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _notifyPayment() async {
    if (_selectedMethodKey == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Por favor, selecciona un método de pago."),
        backgroundColor: Colors.orange,
      ));
      return;
    }
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);

    // ▼▼▼ AQUÍ ESTÁ LA CORRECCIÓN ▼▼▼
    final result = await _paymentService.notifyPayment(
      game: widget.game,
      method: _selectedMethodKey!, // <-- CORRECCIÓN: Se añade el parámetro que faltaba.
      reference: _referenceController.text,
      amount: widget.game.price * widget.totalPeopleJoining,
      guestsCount: widget.totalPeopleJoining - 1,
      receiptImage: _selectedImage,
    );
    // ▲▲▲ FIN DE LA CORRECCIÓN ▲▲▲

    if (mounted) {
      if (result == "Success") {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("✅ ¡Pago notificado! Recibirás una confirmación pronto."),
          backgroundColor: Color(0xFF008060),
        ));
        Navigator.of(context).popUntil((route) => route.isFirst);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("❌ $result"),
          backgroundColor: Colors.red,
        ));
      }
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalCost = widget.game.price * widget.totalPeopleJoining;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        title: const Text("Procesar Pago", style: TextStyle(color: Color(0xFF1C1C1E))),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Color(0xFF1C1C1E)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummaryCard(totalCost),
            const SizedBox(height: 24),
            _buildSectionTitle("1. Selecciona un método de pago"),
            const SizedBox(height: 16),
            _buildPaymentMethodsGrid(),
            if (_selectedMethodKey != null) ...[
              const SizedBox(height: 24),
              _buildSectionTitle("2. Realiza la transferencia"),
              const SizedBox(height: 12),
              _buildPaymentDetailsCard(_selectedMethodKey!),
              const SizedBox(height: 24),
              _buildSectionTitle("3. Notifica tu pago"),
              const SizedBox(height: 12),
              _buildNotificationForm(),
            ]
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ElevatedButton(
          onPressed: (_selectedMethodKey == null || _isLoading) ? null : _notifyPayment,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF008060),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            disabledBackgroundColor: Colors.grey.shade400,
          ),
          child: _isLoading
              ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
              : const Text("Notificar Pago", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1C1C1E)));
  }

  Widget _buildSummaryCard(double totalCost) {
    return Card(
      elevation: 2,
      shadowColor: Colors.black.withAlpha(25),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Total a Pagar", style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
                const SizedBox(height: 4),
                Text("\$${totalCost.toStringAsFixed(2)}", style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1C1C1E))),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: const Color(0xFF008060).withAlpha(26), borderRadius: BorderRadius.circular(8)),
              child: Text(
                "${widget.totalPeopleJoining} Jugador${widget.totalPeopleJoining > 1 ? 'es' : ''}",
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF008060)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 2.5,
      children: paymentData.entries.map((entry) {
        return _buildMethodButton(entry.value['title'], entry.key, entry.value['icon']);
      }).toList(),
    );
  }

  Widget _buildMethodButton(String title, String key, IconData icon) {
    final isSelected = _selectedMethodKey == key;
    return InkWell(
      onTap: () => setState(() => _selectedMethodKey = key),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF008060).withAlpha(26) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF008060) : Colors.grey.shade300,
            width: 2.0,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? const Color(0xFF008060) : Colors.grey.shade700, size: 28),
            const SizedBox(height: 8),
            Text(title, style: TextStyle(fontWeight: FontWeight.w600, color: isSelected ? const Color(0xFF008060) : Colors.black87)),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentDetailsCard(String methodKey) {
    final detailsMap = paymentData[methodKey]!['details'] as Map<String, String>;
    return Card(
      elevation: 0,
      color: Colors.blueGrey.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: detailsMap.entries.map((detail) => _detailRow(detail.key, detail.value)).toList(),
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("$label:", style: TextStyle(color: Colors.grey.shade700, fontSize: 14)),
          const SizedBox(width: 16),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15), textAlign: TextAlign.end)),
        ],
      ),
    );
  }

  Widget _buildNotificationForm() {
    return Form(
      key: _formKey,
      child: Card(
        elevation: 2,
        shadowColor: Colors.black.withAlpha(25),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextFormField(
                controller: _referenceController,
                decoration: InputDecoration(
                  labelText: "Número de Referencia",
                  hintText: "Introduce los últimos dígitos",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  prefixIcon: const Icon(Icons.receipt_long_outlined),
                ),
                keyboardType: TextInputType.text,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Este campo es obligatorio';
                  }
                  if (value.length < 4) {
                    return 'La referencia parece muy corta';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              if (_selectedImage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Stack(
                    alignment: Alignment.topRight,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(_selectedImage!, height: 150, width: double.infinity, fit: BoxFit.cover),
                      ),
                      IconButton(
                        icon: const CircleAvatar(backgroundColor: Colors.black54, child: Icon(Icons.close, color: Colors.white, size: 18)),
                        onPressed: () => setState(() => _selectedImage = null),
                      )
                    ],
                  ),
                ),
              OutlinedButton.icon(
                onPressed: _pickImage,
                icon: Icon(_selectedImage == null ? Icons.attach_file_outlined : Icons.check_circle, color: _selectedImage != null ? Colors.green : null),
                label: Text(_selectedImage == null ? "Adjuntar Comprobante" : "Comprobante Adjunto"),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  foregroundColor: const Color(0xFF008060),
                  side: BorderSide(color: Colors.grey.shade400),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}