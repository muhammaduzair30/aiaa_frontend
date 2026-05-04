import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/job_application_entity.dart';

class ApplicationCard extends StatelessWidget {
  final JobApplicationEntity application;

  const ApplicationCard({super.key, required this.application});

  @override
  Widget build(BuildContext context) {
    final statusColor = AppConstants.statusColors[application.status] ?? Colors.grey;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Job ID: ${application.jobId}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: statusColor),
                  ),
                  child: Text(
                    application.status.toUpperCase(),
                    style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('CV: ${application.cvId}', style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (application.analysisId != null)
                  const Row(
                    children: [
                      Icon(Icons.analytics, size: 16, color: Colors.blue),
                      SizedBox(width: 4),
                      Text('Analysis Attached', style: TextStyle(fontSize: 12, color: Colors.blue)),
                    ],
                  )
                else
                  const SizedBox.shrink(),
                Text(
                  application.appliedDate != null 
                    ? 'Applied: ${DateFormat('MMM dd').format(application.appliedDate!)}' 
                    : 'Saved: ${DateFormat('MMM dd').format(application.createdAt)}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
