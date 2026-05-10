import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/job_application_entity.dart';

class ApplicationCard extends StatelessWidget {
  final JobApplicationEntity application;
  final bool isGrid;

  const ApplicationCard({
    super.key,
    required this.application,
    this.isGrid = false,
  });

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'saved':
        return const Color(0xFF6B7089);
      case 'applied':
        return const Color(0xFF378ADD);
      case 'interview':
        return const Color(0xFFEF9F27);
      case 'offer':
        return const Color(0xFF1D9E75);
      case 'rejected':
        return const Color(0xFFE24B4A);
      default:
        return const Color(0xFF6B7089);
    }
  }

  IconData _statusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'saved':
        return Icons.bookmark_outline_rounded;
      case 'applied':
        return Icons.send_rounded;
      case 'interview':
        return Icons.event_note_rounded;
      case 'offer':
        return Icons.celebration_rounded;
      case 'rejected':
        return Icons.close_rounded;
      default:
        return Icons.circle_outlined;
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return DateFormat('MMM d').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(application.status);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.07), width: 0.5),
      ),
      child: isGrid
          ? _buildGridContent(color)
          : _buildListContent(color),
    );
  }

  Widget _buildGridContent(Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top row: icon + status badge
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF534AB7).withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.work_outline_rounded,
                  color: Color(0xFF8B82D4), size: 20),
            ),
            _StatusBadge(status: application.status, color: color),
          ],
        ),
        const Spacer(),
        // Job title
        Text(
          application.jobTitle ?? 'Untitled Job',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFFEEEDFE),
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 6),
        // CV name
        Row(
          children: [
            const Icon(Icons.description_outlined,
                size: 10, color: Color(0xFF6B7089)),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                application.cvFilename ?? 'CV',
                style: const TextStyle(fontSize: 11, color: Color(0xFF6B7089)),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        // Date
        Row(
          children: [
            const Icon(Icons.calendar_today_outlined,
                size: 10, color: Color(0xFF4A4E6A)),
            const SizedBox(width: 4),
            Text(
              application.appliedDate != null
                  ? _formatDate(application.appliedDate)
                  : _formatDate(application.createdAt),
              style: const TextStyle(fontSize: 10, color: Color(0xFF4A4E6A)),
            ),
            if (application.analysisId != null) ...[
              const Spacer(),
              const Icon(Icons.insights_rounded,
                  size: 12, color: Color(0xFF534AB7)),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildListContent(Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            // Status icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(_statusIcon(application.status),
                  color: color, size: 20),
            ),
            const SizedBox(width: 14),
            // Title + CV
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    application.jobTitle ?? 'Untitled Job',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFEEEDFE),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Icon(Icons.description_outlined,
                          size: 10, color: Color(0xFF6B7089)),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          application.cvFilename ?? 'CV',
                          style: const TextStyle(
                              fontSize: 11, color: Color(0xFF6B7089)),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Status badge + chevron
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _StatusBadge(status: application.status, color: color),
                const SizedBox(height: 8),
                const Icon(Icons.chevron_right_rounded,
                    color: Color(0xFF4A4E6A), size: 18),
              ],
            ),
          ],
        ),
        // Bottom row: date + analysis indicator
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.03),
            borderRadius: BorderRadius.circular(10),
            border:
                Border.all(color: Colors.white.withOpacity(0.05), width: 0.5),
          ),
          child: Row(
            children: [
              const Icon(Icons.calendar_today_outlined,
                  size: 10, color: Color(0xFF6B7089)),
              const SizedBox(width: 4),
              Text(
                application.appliedDate != null
                    ? 'Applied ${_formatDate(application.appliedDate)}'
                    : 'Saved ${_formatDate(application.createdAt)}',
                style:
                    const TextStyle(fontSize: 11, color: Color(0xFF6B7089)),
              ),
              if (application.analysisId != null) ...[
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF534AB7).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                        color: const Color(0xFF534AB7).withOpacity(0.25),
                        width: 0.5),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.insights_rounded,
                          size: 10, color: Color(0xFF8B82D4)),
                      SizedBox(width: 4),
                      Text('Analyzed',
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF8B82D4))),
                    ],
                  ),
                ),
              ],
              if (application.notes != null &&
                  application.notes!.isNotEmpty) ...[
                if (application.analysisId == null) const Spacer(),
                const SizedBox(width: 8),
                const Icon(Icons.sticky_note_2_outlined,
                    size: 12, color: Color(0xFF4A4E6A)),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Status Badge ───────────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final String status;
  final Color color;

  const _StatusBadge({required this.status, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.25), width: 0.5),
      ),
      child: Text(
        status[0].toUpperCase() + status.substring(1),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
