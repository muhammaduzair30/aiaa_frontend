import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection.dart';
import '../../../job/domain/entities/job_entity.dart';
import '../cubit/analysis_cubit.dart';
import '../../../cv/domain/entities/cv_entity.dart';
import '../../../cv/presentation/cubit/cv_cubit.dart';

class AnalysisScreen extends StatelessWidget {
  const AnalysisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<AnalysisCubit>()),
        BlocProvider(create: (_) => sl<CVCubit>()),
      ],
      child: const _AnalysisScreenView(),
    );
  }
}

class _AnalysisScreenView extends StatefulWidget {
  const _AnalysisScreenView();

  @override
  State<_AnalysisScreenView> createState() => _AnalysisScreenViewState();
}

class _AnalysisScreenViewState extends State<_AnalysisScreenView> {
  String? _selectedCvId;
  JobEntity? _selectedJob;

  @override
  void initState() {
    super.initState();
    context.read<CVCubit>().loadCVs();
  }

  void _onRunAnalysis() {
    if (_selectedCvId != null && _selectedJob != null) {
      context.read<AnalysisCubit>().runAnalysis(
            _selectedCvId!,
            _selectedJob!.rawText,
            jobId: _selectedJob!.id,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Start Analysis')),
      body: BlocConsumer<AnalysisCubit, AnalysisState>(
        listener: (context, state) {
          if (state is AnalysisComplete) {
            context.push('/analysis/result', extra: state.analysis);
          } else if (state is AnalysisError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          if (state is AnalysisRunning) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 24),
                  Text(
                    'Analyzing Job Description & CV...\nThis may take 10-15 seconds.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('1. Select Your CV', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                BlocBuilder<CVCubit, CVState>(
                  builder: (context, cvState) {
                    if (cvState is CVLoading) {
                      return const CircularProgressIndicator();
                    } else if (cvState is CVLoaded) {
                      if (cvState.cvs.isEmpty) {
                        return const Text('No CVs found. Please upload a CV first.');
                      }
                      return DropdownButtonFormField<String>(
                        decoration: const InputDecoration(border: OutlineInputBorder()),
                        value: _selectedCvId,
                        hint: const Text('Select a CV'),
                        items: cvState.cvs.map((cv) {
                          return DropdownMenuItem(
                            value: cv.id,
                            child: Text(cv.originalFilename),
                          );
                        }).toList(),
                        onChanged: (val) {
                          setState(() {
                            _selectedCvId = val;
                          });
                        },
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
                const SizedBox(height: 24),
                const Text('2. Select Job Description', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: () async {
                    final result = await context.push<JobEntity>('/job/input');
                    if (result != null) {
                      setState(() {
                        _selectedJob = result;
                      });
                    }
                  },
                  icon: const Icon(Icons.work),
                  label: const Text('Input / Scrape Job Description'),
                ),
                if (_selectedJob != null) ...[
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_selectedJob!.jobTitle != null)
                            Text(_selectedJob!.jobTitle!, style: const TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text(
                            _selectedJob!.rawText,
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                const Spacer(),
                ElevatedButton(
                  onPressed: (_selectedCvId != null && _selectedJob != null) ? _onRunAnalysis : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Run Analysis', style: TextStyle(fontSize: 18)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
