import 'package:flutter/material.dart';

class SkillGapWidget extends StatelessWidget {
  final List<String> matched;
  final List<String> missingCritical;
  final List<String> missingOptional;

  const SkillGapWidget({
    super.key,
    required this.matched,
    required this.missingCritical,
    required this.missingOptional,
  });

  Widget _buildChipSection(String title, List<String> items, Color color) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8.0,
          runSpacing: 4.0,
          children: items.map((item) => Chip(
            label: Text(item, style: const TextStyle(color: Colors.white, fontSize: 12)),
            backgroundColor: color,
          )).toList(),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildChipSection('Matched Skills', matched, Colors.green),
        _buildChipSection('Missing Critical Skills', missingCritical, Colors.red),
        _buildChipSection('Missing Optional Skills', missingOptional, Colors.orange),
      ],
    );
  }
}
