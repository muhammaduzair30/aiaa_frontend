import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection.dart';
import '../../../cv/presentation/cubit/cv_cubit.dart';
import '../cubit/analysis_cubit.dart';
import '../widgets/match_score_widget.dart';

class AnalysisHistoryScreen extends StatelessWidget {
  const AnalysisHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<AnalysisCubit>()..loadHistory()),
        BlocProvider(create: (_) => sl<CVCubit>()..loadCVs()),
      ],
      child: const _AnalysisHistoryScreenView(),
    );
  }
}

class _AnalysisHistoryScreenView extends StatelessWidget {
  const _AnalysisHistoryScreenView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Analysis History')),
      body: BlocBuilder<AnalysisCubit, AnalysisState>(
        builder: (context, state) {
          if (state is AnalysisRunning) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is AnalysisHistoryEmpty) {
            return RefreshIndicator(
              onRefresh: () => context.read<AnalysisCubit>().loadHistory(),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 100),
                  Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Text(
                        'No analyses yet. Run your first analysis to see results here.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ),
                  ),
                ],
              ),
            );
          } else if (state is AnalysisHistoryLoaded) {
            if (state.history.isEmpty) {
              return RefreshIndicator(
                onRefresh: () => context.read<AnalysisCubit>().loadHistory(),
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: const [
                    SizedBox(height: 100),
                    Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Text(
                          'No analyses yet. Run your first analysis to see results here.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () => context.read<AnalysisCubit>().loadHistory(),
              child: ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: state.history.length,
                itemBuilder: (context, index) {
                  final analysis = state.history[index];
                  String summary = analysis.recommendationSummary;
                  if (summary.length > 60) {
                    summary = '${summary.substring(0, 60)}...';
                  }

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: InkWell(
                      onTap: () => context.push('/analysis/result', extra: analysis),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _getScoreColor(analysis.matchScore).withOpacity(0.1),
                                border: Border.all(color: _getScoreColor(analysis.matchScore), width: 2),
                              ),
                              child: Center(
                                child: Text(
                                  '${analysis.matchScore}%',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: _getScoreColor(analysis.matchScore),
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: BlocBuilder<CVCubit, CVState>(
                                          builder: (context, cvState) {
                                            String cvName = 'Loading...';
                                            if (cvState is CVLoaded) {
                                              try {
                                                cvName = cvState.cvs
                                                    .firstWhere((c) => c.id == analysis.cvId)
                                                    .originalFilename;
                                              } catch (_) {
                                                cvName = 'Unknown CV';
                                              }
                                            }
                                            return Text(
                                              cvName,
                                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                              overflow: TextOverflow.ellipsis,
                                            );
                                          },
                                        ),
                                      ),
                                      Text(
                                        analysis.createdAt.toLocal().toString().split(' ')[0],
                                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    summary,
                                    style: TextStyle(color: Colors.grey[700], fontSize: 14),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          } else if (state is AnalysisError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${state.message}', style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<AnalysisCubit>().loadHistory(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return Colors.green;
    if (score >= 50) return Colors.orange;
    return Colors.red;
  }
}
