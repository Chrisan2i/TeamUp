import 'package:flutter/material.dart';

class ProfileEditor extends StatefulWidget {
  const ProfileEditor({super.key});

  @override
  State<ProfileEditor> createState() => _ProfileEditorState();
}

class _ProfileEditorState extends State<ProfileEditor> {
  // Variables de estado para cada campo
  String fullName = 'Ana Orozco';
  String email = 'aniorozco25@gmail.com';
  String country = 'United States';
  String skillLevel = 'Beginner';
  String position = 'Not specified';
  String birthday = 'February 25, 2003';
  String gender = 'Female';

  // Controladores para los campos de texto
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _skillController = TextEditingController();
  final TextEditingController _positionController = TextEditingController();
  final TextEditingController _birthdayController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _countryController.dispose();
    _skillController.dispose();
    _positionController.dispose();
    _birthdayController.dispose();
    _genderController.dispose();
    super.dispose();
  }

  // Diálogo para editar nombre
  void _showNameEditorDialog(BuildContext context) {
    final names = fullName.split(' ');
    _firstNameController.text = names.isNotEmpty ? names.first : '';
    _lastNameController.text = names.length > 1 ? names.sublist(1).join(' ') : '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return _buildEditDialog(
          context,
          title: 'What is your name?',
          description: 'Providing your real name helps build trust among players and facilities.',
          content: Column(
            children: [
              const Text(
                'First Name',
                style: TextStyle(
                  color: Color(0xFF374151),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _firstNameController,
                decoration: _inputDecoration('Enter your first name'),
              ),
              const SizedBox(height: 24),
              const Text(
                'Last Name',
                style: TextStyle(
                  color: Color(0xFF374151),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _lastNameController,
                decoration: _inputDecoration('Enter your last name'),
              ),
            ],
          ),
          onSave: () {
            setState(() {
              fullName = '${_firstNameController.text} ${_lastNameController.text}';
            });
          },
        );
      },
    );
  }

  // Diálogo para editar email
  void _showEmailEditorDialog(BuildContext context) {
    _emailController.text = email;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return _buildEditDialog(
          context,
          title: 'What is your email?',
          description: 'Your email will be used for account notifications and password recovery.',
          content: TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: _inputDecoration('Enter your email'),
          ),
          onSave: () {
            setState(() {
              email = _emailController.text;
            });
          },
        );
      },
    );
  }

  // Diálogo para editar país
  void _showCountryEditorDialog(BuildContext context) {
    _countryController.text = country;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return _buildEditDialog(
          context,
          title: 'Which country do you represent?',
          description: 'Select your country to connect with local players and facilities.',
          content: TextField(
            controller: _countryController,
            decoration: _inputDecoration('Enter your country'),
          ),
          onSave: () {
            setState(() {
              country = _countryController.text;
            });
          },
        );
      },
    );
  }

  // Diálogo para editar nivel de habilidad
  void _showSkillEditorDialog(BuildContext context) {
    _skillController.text = skillLevel;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return _buildEditDialog(
          context,
          title: 'What is your skill level?',
          description: 'Select your current skill level to match with players of similar ability.',
          content: TextField(
            controller: _skillController,
            decoration: _inputDecoration('Enter your skill level'),
          ),
          onSave: () {
            setState(() {
              skillLevel = _skillController.text;
            });
          },
        );
      },
    );
  }

  // Diálogo para editar posición
  void _showPositionEditorDialog(BuildContext context) {
    _positionController.text = position;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return _buildEditDialog(
          context,
          title: 'What is your preferred position?',
          description: 'Select your preferred playing position to find suitable games.',
          content: TextField(
            controller: _positionController,
            decoration: _inputDecoration('Enter your position'),
          ),
          onSave: () {
            setState(() {
              position = _positionController.text;
            });
          },
        );
      },
    );
  }

  // Diálogo para editar cumpleaños
  void _showBirthdayEditorDialog(BuildContext context) {
    _birthdayController.text = birthday;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return _buildEditDialog(
          context,
          title: 'When is your birthday?',
          description: 'Your age helps us match you with appropriate games and players.',
          content: TextField(
            controller: _birthdayController,
            decoration: _inputDecoration('Enter your birthday'),
          ),
          onSave: () {
            setState(() {
              birthday = _birthdayController.text;
            });
          },
        );
      },
    );
  }

  // Diálogo para editar género
  void _showGenderEditorDialog(BuildContext context) {
    _genderController.text = gender;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return _buildEditDialog(
          context,
          title: 'What is your gender?',
          description: 'This helps us match you with appropriate games and players.',
          content: TextField(
            controller: _genderController,
            decoration: _inputDecoration('Enter your gender'),
          ),
          onSave: () {
            setState(() {
              gender = _genderController.text;
            });
          },
        );
      },
    );
  }

  // Widget genérico para construir diálogos de edición
  Widget _buildEditDialog(
    BuildContext context, {
    required String title,
    required String description,
    required Widget content,
    required VoidCallback onSave,
  }) {
    return Dialog(
      insetPadding: const EdgeInsets.all(24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF111827),
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                description,
                style: const TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 32),
              content,
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: Color(0xFFE5E7EB)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: Color(0xFF374151),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        onSave();
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0CC0DF),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Save',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Decoración común para los campos de texto
  InputDecoration _inputDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: Color(0xFF999999)),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            Center(
              child: Column(
                children: [
                  Stack(
                    children: [
                      const CircleAvatar(
                        radius: 60,
                        backgroundColor: Color(0xFF10B981),
                        child: Text(
                          'A',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () {},
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF59E0B),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 2,
                              ),
                            ),
                            child: const Icon(
                              Icons.edit,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "$fullName's profile",
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Your profile details helps personalize your Plei experience and connects you with the right games and players.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            _buildProfileField(
              label: 'MY NAME',
              value: fullName,
              onEdit: () => _showNameEditorDialog(context),
            ),
            _buildProfileField(
              label: 'EMAIL',
              value: email,
              onEdit: () => _showEmailEditorDialog(context),
            ),
            _buildProfileField(
              label: 'COUNTRY I REPRESENT',
              value: country,
              onEdit: () => _showCountryEditorDialog(context),
            ),
            _buildProfileField(
              label: 'MY SKILL LEVEL',
              value: skillLevel,
              onEdit: () => _showSkillEditorDialog(context),
            ),
            _buildProfileField(
              label: 'PREFERRED POSITION',
              value: position,
              onEdit: () => _showPositionEditorDialog(context),
              extraWidget: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Missing info',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            _buildProfileField(
              label: 'MY BIRTHDAY',
              value: birthday,
              onEdit: () => _showBirthdayEditorDialog(context),
            ),
            _buildProfileField(
              label: 'MY GENDER',
              value: gender,
              onEdit: () => _showGenderEditorDialog(context),
              isLast: true,
            ),
            
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Done',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileField({
    required String label,
    required String value,
    required VoidCallback onEdit,
    Widget? extraWidget,
    bool isLast = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: const BorderSide(color: Color(0xFFE5E7EB)),
          bottom: isLast 
              ? const BorderSide(color: Color(0xFFE5E7EB))
              : BorderSide.none,
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: Row(
        children: [
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    if (extraWidget != null) ...[
                      const SizedBox(width: 8),
                      extraWidget,
                    ],
                  ],
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: onEdit,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              foregroundColor: const Color(0xFF0CC0DF),
              elevation: 0,
              padding: const EdgeInsets.all(8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Icon(Icons.edit_outlined, size: 20),
          ),
        ],
      ),
    );
  }
}