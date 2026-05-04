import 'package:aiaa/features/analysis/presentation/cubit/analysis_cubit.dart';
import 'package:aiaa/features/cv/presentation/cubit/cv_cubit.dart';
import 'package:aiaa/features/job/presentation/cubit/job_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/injection.dart';
import '../../domain/entities/job_application_entity.dart';
import '../cubit/job_application_cubit.dart';

class ApplicationDetailScreen extends StatelessWidget {
  final String id;
  final JobApplicationEntity? application;

  const ApplicationDetailScreen({
    super.key,
    required this.id,
    this.application,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
            create: (_) {
              final cubit = sl<JobApplicationCubit>();
              // Only fetch from API if no entity was passed directly
              if (application == null) {
                cubit.getApplication(id);
              }
              return cubit;
            }),
        BlocProvider(create: (_) => sl<CVCubit>()..loadCVs()),
        BlocProvider(create: (_) => sl<JobCubit>()..loadJobs()),
        BlocProvider(create: (_) => sl<AnalysisCubit>()),
      ],
      child: _ApplicationDetailScreenView(id: id, initialApplication: application),
    );
  }
}

class _ApplicationDetailScreenView extends StatefulWidget {
  final String id;
  final JobApplicationEntity? initialApplication;

  const _ApplicationDetailScreenView({
    required this.id,
    this.initialApplication,
  });

  @override
  State<_ApplicationDetailScreenView> createState() =>
      _ApplicationDetailScreenViewState();
}

class _ApplicationDetailScreenViewState
    extends State<_ApplicationDetailScreenView> {
  final _notesController = TextEditingController();
  String _currentStatus = 'saved';
  DateTime? _appliedDate;
  late JobApplicationEntity? _application;
  bool _isInit = false;

  @override
  void initState() {
    super.initState();
    _application = widget.initialApplication;
    if (_application != null) {
      _initFields(_application!);
    }
  }

  void _initFields(JobApplicationEntity app) {
    _currentStatus = app.status;
    _notesController.text = app.notes ?? '';
    _appliedDate = app.appliedDate;
    _isInit = true;

    if (app.analysisId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.read<AnalysisCubit>().loadAnalysis(app.analysisId!);
        }
      });
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _appliedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _appliedDate) {
      setState(() {
        _appliedDate = picked;
      });
    }
  }

  void _onSaveChanges() {
    context.read<JobApplicationCubit>().updateApplication(
          widget.id,
          _currentStatus,
          _notesController.text,
          _appliedDate,
        );
  }

  void _onDelete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content:
            const Text('Are you sure you want to delete this application?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCEL')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<JobApplicationCubit>().deleteApplication(widget.id);
              context.pop();
            },
            child: const Text('DELETE', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Application Details'),
        actions: [
          IconButton(icon: const Icon(Icons.delete), onPressed: _onDelete),
        ],
      ),
      body: BlocListener<JobApplicationCubit, JobApplicationState>(
        listener: (context, state) {
          if (state is JobApplicationUpdated) {
            // Update local state directly with the saved values
            setState(() {
              _application = state.application;
              _currentStatus = state.application.status;
              _notesController.text = state.application.notes ?? '';
              _appliedDate = state.application.appliedDate;
            });
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('Changes saved successfully')));
            Navigator.pop(context, true);
          } else if (state is JobApplicationDetailLoaded) {
            // Only when fetched from API (fallback when no entity was passed)
            if (!_isInit) {
              setState(() {
                _application = state.application;
              });
              _initFields(state.application);
            }
          } else if (state is JobApplicationError) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    final app = _application;
    if (app == null) {
      // Still waiting for API fetch (fallback path)
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BlocBuilder<CVCubit, CVState>(
            builder: (context, cvState) {
              if (cvState is CVLoaded) {
                try {
                  final cv =
                      cvState.cvs.firstWhere((c) => c.id == app.cvId);
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.description,
                        size: 40, color: Colors.blue),
                    title: const Text('CV Used',
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey)),
                    subtitle: Text(cv.originalFilename,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16)),
                  );
                } catch (_) {
                  return const SizedBox.shrink();
                }
              }
              return const CircularProgressIndicator();
            },
          ),
          const Divider(),
          BlocBuilder<JobCubit, JobState>(
            builder: (context, jobState) {
              if (jobState is JobLoaded) {
                try {
                  final job = jobState.jobs
                      .firstWhere((j) => j.id == app.jobId);
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.work,
                            size: 40, color: Colors.green),
                        title: const Text('Job Title',
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey)),
                        subtitle: Text(job.jobTitle ?? 'Untitled Job',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16)),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        job.rawText,
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  );
                } catch (_) {
                  return const SizedBox.shrink();
                }
              }
              return const CircularProgressIndicator();
            },
          ),
          const Divider(),
          if (app.analysisId != null)
            BlocBuilder<AnalysisCubit, AnalysisState>(
              builder: (context, analysisState) {
                if (analysisState is AnalysisComplete) {
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.analytics,
                        size: 40, color: Colors.orange),
                    title: const Text('Match Score',
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey)),
                    subtitle: Text(
                        '${analysisState.analysis.matchScore}%',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16)),
                  );
                } else if (analysisState is AnalysisRunning) {
                  return const Center(
                      child: CircularProgressIndicator());
                }
                return const SizedBox.shrink();
              },
            ),
          if (app.analysisId != null) const Divider(),
          const SizedBox(height: 16),
          const Text('Update Status',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _currentStatus,
            decoration:
                const InputDecoration(border: OutlineInputBorder()),
            items: AppConstants.statusValues
                .map((s) => DropdownMenuItem(
                    value: s, child: Text(s.toUpperCase())))
                .toList(),
            onChanged: (val) {
              if (val != null) setState(() => _currentStatus = val);
            },
          ),
          const SizedBox(height: 16),
          const Text('Applied Date',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          InkWell(
            onTap: () => _selectDate(context),
            child: InputDecorator(
              decoration:
                  const InputDecoration(border: OutlineInputBorder()),
              child: Text(_appliedDate != null
                  ? DateFormat('yyyy-MM-dd').format(_appliedDate!)
                  : 'Select Date'),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Notes',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(
            controller: _notesController,
            maxLines: 4,
            decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Add notes here...'),
          ),
          const SizedBox(height: 24),
          if (app.analysisId != null) ...[
            OutlinedButton.icon(
              onPressed: () =>
                  context.push('/analysis/${app.analysisId}'),
              icon: const Icon(Icons.analytics),
              label: const Text('View Full Analysis Result'),
              style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48)),
            ),
            const SizedBox(height: 16),
          ],
          ElevatedButton.icon(
            onPressed: _onSaveChanges,
            icon: const Icon(Icons.save),
            label: const Text('Save Changes'),
            style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(48)),
          ),
        ],
      ),
    );
  }
}
