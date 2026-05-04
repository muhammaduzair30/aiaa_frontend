import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/injection.dart';
import '../../domain/entities/analysis_entity.dart';
import '../../domain/entities/content_block_entity.dart';
import '../widgets/match_score_widget.dart';
import '../widgets/skill_gap_widget.dart';
import '../widgets/structured_content_viewer.dart';
import 'package:aiaa/features/job_application/presentation/cubit/job_application_cubit.dart';
import 'package:aiaa/features/cv/presentation/cubit/cv_cubit.dart';
import 'package:aiaa/features/job/presentation/cubit/job_cubit.dart';

class ResultScreen extends StatelessWidget {
  final AnalysisEntity analysis;

  const ResultScreen({super.key, required this.analysis});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<JobApplicationCubit>()),
        BlocProvider(create: (_) => sl<CVCubit>()..loadCVs()),
        BlocProvider(create: (_) => sl<JobCubit>()..loadJobs()),
      ],
      child: _ResultScreenView(analysis: analysis),
    );
  }
}

class _ResultScreenView extends StatefulWidget {
  final AnalysisEntity analysis;
  const _ResultScreenView({required this.analysis});

  @override
  State<_ResultScreenView> createState() => _ResultScreenViewState();
}

class _ResultScreenViewState extends State<_ResultScreenView> {

  String _convertBlocksToText(List<ContentBlockEntity> blocks) {
    final buffer = StringBuffer();
    for (var block in blocks) {
      if (block.type == 'divider') {
        buffer.writeln('----------------------------------------');
      } else if (block.type == 'list') {
        final items = (block.content as List).map((e) => e.toString()).toList();
        for (var item in items) {
          buffer.writeln('- $item');
        }
      } else {
        buffer.writeln(block.content.toString());
      }
      buffer.writeln(); // Add extra spacing between blocks
    }
    return buffer.toString().trim();
  }

  void _copyToClipboard(
      BuildContext context, List<ContentBlockEntity> blocks, String type) {
    final text = _convertBlocksToText(blocks);
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$type copied to clipboard!')),
    );
  }

  void _showSaveApplicationSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return MultiBlocProvider(
          providers: [
            BlocProvider.value(value: context.read<JobApplicationCubit>()),
            BlocProvider.value(value: context.read<CVCubit>()),
            BlocProvider.value(value: context.read<JobCubit>()),
          ],
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
            ),
            child: _SaveApplicationSheet(analysis: widget.analysis),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Analysis Result')),
      body: BlocListener<JobApplicationCubit, JobApplicationState>(
        listener: (context, state) {
          if (state is JobApplicationCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Application saved to tracker')),
            );
            // Navigate to applications screen. Usually that's the 4th tab on Home, or just pop to root
            // If the route is /applications, use that:
            context.go('/');
          } else if (state is JobApplicationError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: MatchScoreWidget(score: widget.analysis.matchScore),
              ),
              const SizedBox(height: 24),
              SkillGapWidget(
                matched: widget.analysis.matchedSkills,
                missingCritical: widget.analysis.missingCriticalSkills,
                missingOptional: widget.analysis.missingOptionalSkills,
              ),
              const Divider(),
              const Text('Recommendation Summary',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 8),
              Text(widget.analysis.recommendationSummary),
              const SizedBox(height: 24),
              ExpansionTile(
                title: const Text('Optimized CV Content',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () => _copyToClipboard(
                          context, widget.analysis.optimizedCvContent, 'CV Content'),
                      icon: const Icon(Icons.copy, size: 16),
                      label: const Text('Copy'),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: StructuredContentViewer(
                        contentBlocks: widget.analysis.optimizedCvContent),
                  ),
                ],
              ),
              ExpansionTile(
                title: const Text('Generated Cover Letter',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () => _copyToClipboard(
                          context, widget.analysis.generatedCoverLetter, 'Cover Letter'),
                      icon: const Icon(Icons.copy, size: 16),
                      label: const Text('Copy'),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: StructuredContentViewer(
                        contentBlocks: widget.analysis.generatedCoverLetter),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: BlocBuilder<JobApplicationCubit, JobApplicationState>(
                  builder: (context, state) {
                    if (state is JobApplicationLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return ElevatedButton.icon(
                      onPressed: widget.analysis.jobId != null ? () => _showSaveApplicationSheet(context) : null,
                      icon: const Icon(Icons.save),
                      label: const Text('Save as Job Application'),
                      style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16)),
                    );
                  },
                ),
              ),
              if (widget.analysis.jobId == null)
                 const Padding(
                   padding: EdgeInsets.only(top: 8.0),
                   child: Text('Cannot save application without a linked Job.', style: TextStyle(color: Colors.red, fontSize: 12), textAlign: TextAlign.center,),
                 ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SaveApplicationSheet extends StatefulWidget {
  final AnalysisEntity analysis;

  const _SaveApplicationSheet({required this.analysis});

  @override
  State<_SaveApplicationSheet> createState() => _SaveApplicationSheetState();
}

class _SaveApplicationSheetState extends State<_SaveApplicationSheet> {
  String _selectedStatus = 'applied';
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Save as Job Application', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          BlocBuilder<CVCubit, CVState>(
            builder: (context, state) {
              String cvName = 'Loading...';
              if (state is CVLoaded) {
                try {
                  cvName = state.cvs.firstWhere((c) => c.id == widget.analysis.cvId).originalFilename;
                } catch (_) {
                  cvName = 'Unknown CV';
                }
              }
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.description, color: Colors.blue),
                title: const Text('CV Used', style: TextStyle(fontSize: 12, color: Colors.grey)),
                subtitle: Text(cvName, style: const TextStyle(fontWeight: FontWeight.bold)),
              );
            },
          ),
          BlocBuilder<JobCubit, JobState>(
            builder: (context, state) {
              String jobTitle = 'Loading...';
              if (state is JobLoaded) {
                try {
                  jobTitle = state.jobs.firstWhere((j) => j.id == widget.analysis.jobId).jobTitle ?? 'Untitled Job';
                } catch (_) {
                  jobTitle = 'Unknown Job';
                }
              }
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.work, color: Colors.green),
                title: const Text('Job', style: TextStyle(fontSize: 12, color: Colors.grey)),
                subtitle: Text(jobTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
              );
            },
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _selectedStatus,
            decoration: const InputDecoration(labelText: 'Status', border: OutlineInputBorder()),
            items: AppConstants.statusValues.map((s) => DropdownMenuItem(value: s, child: Text(s.toUpperCase()))).toList(),
            onChanged: (val) {
              if (val != null) setState(() => _selectedStatus = val);
            },
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _notesController,
            decoration: const InputDecoration(labelText: 'Notes (optional)', border: OutlineInputBorder()),
            maxLines: 3,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    context.read<JobApplicationCubit>().createApplication(
                      widget.analysis.cvId,
                      widget.analysis.jobId!,
                      widget.analysis.id,
                      _selectedStatus,
                      _notesController.text,
                    );
                    Navigator.pop(context);
                  },
                  child: const Text('Confirm Save'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
