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

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Summary row
        _buildSummaryRow(),
        const SizedBox(height: 20),

        // Matched skills
        if (matched.isNotEmpty) ...[
          _buildGroupHeader(
            icon: Icons.check_circle_outline_rounded,
            label: 'Matched Skills',
            count: matched.length,
            color: const Color(0xFF1D9E75),
          ),
          const SizedBox(height: 10),
          _buildSkillWrap(matched, const Color(0xFF1D9E75)),
        ],

        // Missing critical
        if (missingCritical.isNotEmpty) ...[
          SizedBox(height: matched.isNotEmpty ? 20 : 0),
          _buildGroupHeader(
            icon: Icons.error_outline_rounded,
            label: 'Missing Critical',
            count: missingCritical.length,
            color: const Color(0xFFE24B4A),
          ),
          const SizedBox(height: 10),
          _buildSkillWrap(missingCritical, const Color(0xFFE24B4A)),
        ],

        // Missing optional
        if (missingOptional.isNotEmpty) ...[
          const SizedBox(height: 20),
          _buildGroupHeader(
            icon: Icons.info_outline_rounded,
            label: 'Missing Optional',
            count: missingOptional.length,
            color: const Color(0xFFEF9F27),
          ),
          const SizedBox(height: 10),
          _buildSkillWrap(missingOptional, const Color(0xFFEF9F27)),
        ],
      ],
    );
  }

  // ─── Summary Row ─────────────────────────────────────────────────────────────

  Widget _buildSummaryRow() {
    final total =
        matched.length + missingCritical.length + missingOptional.length;
    final matchPct = total == 0 ? 0 : (matched.length / total * 100).round();

    return Row(
      children: [
        Expanded(
          child: _SummaryPill(
            value: '${matched.length}',
            label: 'Matched',
            color: const Color(0xFF1D9E75),
            icon: Icons.check_rounded,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _SummaryPill(
            value: '${missingCritical.length}',
            label: 'Critical',
            color: const Color(0xFFE24B4A),
            icon: Icons.priority_high_rounded,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _SummaryPill(
            value: '${missingOptional.length}',
            label: 'Optional',
            color: const Color(0xFFEF9F27),
            icon: Icons.add_rounded,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _SummaryPill(
            value: '$matchPct%',
            label: 'Coverage',
            color: const Color(0xFF534AB7),
            icon: Icons.pie_chart_outline_rounded,
          ),
        ),
      ],
    );
  }

  // ─── Group Header ─────────────────────────────────────────────────────────────

  Widget _buildGroupHeader({
    required IconData icon,
    required String label,
    required int count,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 14),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '$count',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            height: 0.5,
            color: color.withOpacity(0.2),
          ),
        ),
      ],
    );
  }

  // ─── Skill Chips Wrap ─────────────────────────────────────────────────────────

  Widget _buildSkillWrap(List<String> skills, Color color) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: skills
          .map((skill) => _SkillChip(label: skill, color: color))
          .toList(),
    );
  }
}

// ─── Summary Pill ─────────────────────────────────────────────────────────────

class _SummaryPill extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  final IconData icon;

  const _SummaryPill({
    required this.value,
    required this.label,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2), width: 0.5),
      ),
      child: Column(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 14),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: color,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: Color(0xFF6B7089),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Skill Chip ───────────────────────────────────────────────────────────────

class _SkillChip extends StatelessWidget {
  final String label;
  final Color color;

  const _SkillChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.25), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 7),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }
}
