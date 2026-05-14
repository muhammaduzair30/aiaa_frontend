import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection.dart';
import '../../../cv/presentation/cubit/cv_cubit.dart';
import '../../../job/presentation/cubit/job_cubit.dart';
import '../cubit/analysis_cubit.dart';

class AnalysisHistoryScreen extends StatelessWidget {
  const AnalysisHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<AnalysisCubit>()..loadHistory()),
        BlocProvider(create: (_) => sl<CVCubit>()..loadCVs()),
        BlocProvider(create: (_) => sl<JobCubit>()..loadJobs()),
      ],
      child: const _AnalysisHistoryScreenView(),
    );
  }
}

class _AnalysisHistoryScreenView extends StatelessWidget {
  const _AnalysisHistoryScreenView();

  @override
  Widget build(BuildContext context) {
    final isWeb = MediaQuery.of(context).size.width > 768;

    return Scaffold(
      backgroundColor: const Color(0xFF0D0B1E),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, isWeb),
            Expanded(
              child: BlocBuilder<AnalysisCubit, AnalysisState>(
                builder: (context, state) {
                  if (state is AnalysisRunning) {
                    return const Center(
                      child:
                          CircularProgressIndicator(color: Color(0xFF534AB7)),
                    );
                  }

                  if (state is AnalysisError) {
                    return _buildErrorState(context, state.message);
                  }

                  final isEmpty = state is AnalysisHistoryEmpty ||
                      (state is AnalysisHistoryLoaded && state.history.isEmpty);

                  if (isEmpty) {
                    return RefreshIndicator(
                      color: const Color(0xFF534AB7),
                      backgroundColor: const Color(0xFF13112A),
                      onRefresh: () =>
                          context.read<AnalysisCubit>().loadHistory(),
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: const [
                          SizedBox(height: 120),
                          _EmptyState(),
                        ],
                      ),
                    );
                  }

                  if (state is AnalysisHistoryLoaded) {
                    return RefreshIndicator(
                      color: const Color(0xFF534AB7),
                      backgroundColor: const Color(0xFF13112A),
                      onRefresh: () =>
                          context.read<AnalysisCubit>().loadHistory(),
                      child: isWeb
                          ? _buildWebGrid(context, state.history)
                          : _buildMobileList(context, state.history),
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Header ─────────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context, bool isWeb) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        isWeb ? 32 : 20,
        isWeb ? 28 : 16,
        isWeb ? 32 : 20,
        isWeb ? 20 : 16,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF0D0B1E),
        border: Border(
          bottom: BorderSide(color: Colors.white.withOpacity(0.06), width: 0.5),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: Colors.white.withOpacity(0.08), width: 0.5),
              ),
              child: const Icon(Icons.arrow_back_rounded,
                  color: Color(0xFF8B82D4), size: 18),
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Analysis History',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFEEEDFE),
                    letterSpacing: -0.4,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'All your CV vs job match analyses',
                  style: TextStyle(fontSize: 12, color: Color(0xFF6B7089)),
                ),
              ],
            ),
          ),
          // Refresh button
          GestureDetector(
            onTap: () => context.read<AnalysisCubit>().loadHistory(),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: Colors.white.withOpacity(0.08), width: 0.5),
              ),
              child: const Icon(Icons.refresh_rounded,
                  color: Color(0xFF6B7089), size: 18),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Web Grid ────────────────────────────────────────────────────────────────

  Widget _buildWebGrid(BuildContext context, List history) {
    return GridView.builder(
      padding: const EdgeInsets.all(32),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.5,
      ),
      itemCount: history.length,
      itemBuilder: (context, index) {
        return _AnalysisCard(
          analysis: history[index],
          isGrid: true,
        );
      },
    );
  }

  // ─── Mobile List ─────────────────────────────────────────────────────────────

  Widget _buildMobileList(BuildContext context, List history) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      itemCount: history.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _AnalysisCard(
            analysis: history[index],
            isGrid: false,
          ),
        );
      },
    );
  }

  // ─── Error State ─────────────────────────────────────────────────────────────

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFFE24B4A).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.error_outline_rounded,
                color: Color(0xFFE24B4A), size: 28),
          ),
          const SizedBox(height: 16),
          const Text('Something went wrong',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFEEEDFE))),
          const SizedBox(height: 6),
          Text(message,
              style: const TextStyle(fontSize: 13, color: Color(0xFF6B7089))),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: () => context.read<AnalysisCubit>().loadHistory(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF534AB7).withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: const Color(0xFF534AB7).withOpacity(0.3),
                    width: 0.5),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.refresh_rounded,
                      color: Color(0xFF8B82D4), size: 16),
                  SizedBox(width: 8),
                  Text('Try again',
                      style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF8B82D4),
                          fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Analysis Card ────────────────────────────────────────────────────────────

class _AnalysisCard extends StatelessWidget {
  final dynamic analysis;
  final bool isGrid;

  const _AnalysisCard({required this.analysis, required this.isGrid});

  Color get _scoreColor {
    final s = analysis.matchScore as int;
    if (s >= 80) return const Color(0xFF1D9E75);
    if (s >= 50) return const Color(0xFFEF9F27);
    return const Color(0xFFE24B4A);
  }

  String get _scoreLabel {
    final s = analysis.matchScore as int;
    if (s >= 80) return 'Strong';
    if (s >= 50) return 'Average';
    return 'Weak';
  }

  String get _dateStr =>
      (analysis.createdAt as DateTime).toLocal().toString().split(' ')[0];

  String get _summary {
    final s = analysis.recommendationSummary as String;
    return s.length > 90 ? '${s.substring(0, 90)}...' : s;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/analysis/result', extra: analysis),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withOpacity(0.07), width: 0.5),
        ),
        child: isGrid
            ? _GridContent(
                analysis: analysis,
                scoreColor: _scoreColor,
                scoreLabel: _scoreLabel,
                dateStr: _dateStr,
                summary: _summary,
              )
            : _ListContent(
                analysis: analysis,
                scoreColor: _scoreColor,
                scoreLabel: _scoreLabel,
                dateStr: _dateStr,
                summary: _summary,
              ),
      ),
    );
  }
}

// ─── Grid Card Content ────────────────────────────────────────────────────────

class _GridContent extends StatelessWidget {
  final dynamic analysis;
  final Color scoreColor;
  final String scoreLabel;
  final String dateStr;
  final String summary;

  const _GridContent({
    required this.analysis,
    required this.scoreColor,
    required this.scoreLabel,
    required this.dateStr,
    required this.summary,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top row: score circle + badge
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _ScoreCircle(
                score: analysis.matchScore as int, color: scoreColor, size: 48),
            _ScoreBadge(label: scoreLabel, color: scoreColor),
          ],
        ),
        const SizedBox(height: 14),
        // CV name
        BlocBuilder<CVCubit, CVState>(
          builder: (context, cvState) {
            return BlocBuilder<JobCubit, JobState>(
              builder: (context, jobState) {
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

                String jobContext = '';
                if (analysis.jobId != null && jobState is JobLoaded) {
                  try {
                    final job =
                        jobState.jobs.firstWhere((j) => j.id == analysis.jobId);
                    if (job.jobTitle != null && job.jobTitle!.isNotEmpty) {
                      jobContext = ' → ${job.jobTitle}';
                    }
                  } catch (_) {}
                } else if (analysis.jdText != null &&
                    analysis.jdText!.isNotEmpty) {
                  final text = analysis.jdText!.replaceAll('\n', ' ').trim();
                  final summary =
                      text.length > 25 ? '${text.substring(0, 25)}...' : text;
                  jobContext = ' → $summary';
                }

                return Text(
                  '$cvName$jobContext',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFEEEDFE),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                );
              },
            );
          },
        ),
        const SizedBox(height: 4),
        Text(
          summary,
          style: const TextStyle(
              fontSize: 11, color: Color(0xFF6B7089), height: 1.4),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const Spacer(),
        // Date
        Row(
          children: [
            const Icon(Icons.calendar_today_outlined,
                size: 10, color: Color(0xFF4A4E6A)),
            const SizedBox(width: 4),
            Text(dateStr,
                style: const TextStyle(fontSize: 10, color: Color(0xFF4A4E6A))),
          ],
        ),
      ],
    );
  }
}

// ─── List Card Content ────────────────────────────────────────────────────────

class _ListContent extends StatelessWidget {
  final dynamic analysis;
  final Color scoreColor;
  final String scoreLabel;
  final String dateStr;
  final String summary;

  const _ListContent({
    required this.analysis,
    required this.scoreColor,
    required this.scoreLabel,
    required this.dateStr,
    required this.summary,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top row
        Row(
          children: [
            _ScoreCircle(
                score: analysis.matchScore as int, color: scoreColor, size: 52),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // CV name
                  BlocBuilder<CVCubit, CVState>(
                    builder: (context, cvState) {
                      return BlocBuilder<JobCubit, JobState>(
                        builder: (context, jobState) {
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

                          String jobContext = '';
                          if (analysis.jobId != null && jobState is JobLoaded) {
                            try {
                              final job = jobState.jobs
                                  .firstWhere((j) => j.id == analysis.jobId);
                              if (job.jobTitle != null &&
                                  job.jobTitle!.isNotEmpty) {
                                jobContext = ' → ${job.jobTitle}';
                              }
                            } catch (_) {}
                          } else if (analysis.jdText != null &&
                              analysis.jdText!.isNotEmpty) {
                            final text =
                                analysis.jdText!.replaceAll('\n', ' ').trim();
                            final summary = text.length > 25
                                ? '${text.substring(0, 25)}...'
                                : text;
                            jobContext = ' → $summary';
                          }

                          return Text(
                            '$cvName$jobContext',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFEEEDFE),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined,
                          size: 10, color: Color(0xFF6B7089)),
                      const SizedBox(width: 4),
                      Text(dateStr,
                          style: const TextStyle(
                              fontSize: 11, color: Color(0xFF6B7089))),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Score badge + chevron
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _ScoreBadge(label: scoreLabel, color: scoreColor),
                const SizedBox(height: 8),
                const Icon(Icons.chevron_right_rounded,
                    color: Color(0xFF4A4E6A), size: 18),
              ],
            ),
          ],
        ),
        // Summary
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.03),
            borderRadius: BorderRadius.circular(10),
            border:
                Border.all(color: Colors.white.withOpacity(0.05), width: 0.5),
          ),
          child: Text(
            summary,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF6B7089),
              height: 1.5,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

// ─── Score Circle ─────────────────────────────────────────────────────────────

class _ScoreCircle extends StatelessWidget {
  final int score;
  final Color color;
  final double size;

  const _ScoreCircle({
    required this.score,
    required this.color,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.1),
        border: Border.all(color: color.withOpacity(0.4), width: 1.5),
      ),
      child: Center(
        child: Text(
          '$score%',
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w700,
            fontSize: size * 0.24,
          ),
        ),
      ),
    );
  }
}

// ─── Score Badge ──────────────────────────────────────────────────────────────

class _ScoreBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _ScoreBadge({required this.label, required this.color});

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
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

// ─── Empty State ──────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFF534AB7).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.insights_outlined,
                  color: Color(0xFF534AB7), size: 36),
            ),
            const SizedBox(height: 20),
            const Text(
              'No analyses yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFFEEEDFE),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Run your first CV vs job analysis to see your match scores and AI recommendations here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 13, color: Color(0xFF6B7089), height: 1.6),
            ),
            const SizedBox(height: 28),
            GestureDetector(
              onTap: () => context.push('/analysis'),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 13),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6C63E0), Color(0xFF534AB7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF534AB7).withOpacity(0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.insights_rounded, color: Colors.white, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Run first analysis',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
