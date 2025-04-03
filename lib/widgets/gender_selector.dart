import 'package:flutter/material.dart';

class GenderSelector extends StatelessWidget {
  final String selectedGender;
  final Function(String) onGenderSelected;

  const GenderSelector({
    Key? key,
    required this.selectedGender,
    required this.onGenderSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildGenderCard(
            context,
            'Male',
            Icons.male,
            selectedGender == 'Male',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildGenderCard(
            context,
            'Female',
            Icons.female,
            selectedGender == 'Female',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildGenderCard(
            context,
            'Other',
            Icons.person,
            selectedGender == 'Other',
          ),
        ),
      ],
    );
  }

  Widget _buildGenderCard(
    BuildContext context,
    String gender,
    IconData icon,
    bool isSelected,
  ) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: () => onGenderSelected(gender),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primary : theme.cardTheme.color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 50,
              color: isSelected
                  ? theme.colorScheme.onPrimary
                  : theme.colorScheme.primary,
            ),
            const SizedBox(height: 8),
            Text(
              gender,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isSelected
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}