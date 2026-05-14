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
  bool _cvExpanded = false;
  bool _coverExpanded = false;

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
      buffer.writeln();
    }
    return buffer.toString().trim();
  }

  void _copyToClipboard(
      BuildContext context, List<ContentBlockEntity> blocks, String type) {
    final text = _convertBlocksToText(blocks);
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline,
                color: Color(0xFF1D9E75), size: 16),
            const SizedBox(width: 8),
            Text('$type copied to clipboard!',
                style: const TextStyle(color: Color(0xFFEEEDFE))),
          ],
        ),
        backgroundColor: const Color(0xFF1A1730),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showSaveApplicationSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF13112A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return MultiBlocProvider(
          providers: [
            BlocProvider.value(value: context.read<JobApplicationCubit>()),
            BlocProvider.value(value: context.read<CVCubit>()),
            BlocProvider.value(value: context.read<JobCubit>()),
          ],
          child: Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom),
            child: _SaveApplicationSheet(analysis: widget.analysis),
          ),
        );
      },
    );
  }

  Color get _scoreColor {
    final s = widget.analysis.matchScore;
    if (s >= 80) return const Color(0xFF1D9E75);
    if (s >= 50) return const Color(0xFFEF9F27);
    return const Color(0xFFE24B4A);
  }

  String get _scoreLabel {
    final s = widget.analysis.matchScore;
    if (s >= 80) return 'Strong Match';
    if (s >= 50) return 'Average Match';
    return 'Weak Match';
  }

  @override
  Widget build(BuildContext context) {
    final isWeb = MediaQuery.of(context).size.width > 768;

    return Scaffold(
      backgroundColor: const Color(0xFF0D0B1E),
      body: BlocListener<JobApplicationCubit, JobApplicationState>(
        listener: (context, state) {
          if (state is JobApplicationCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Row(
                  children: [
                    Icon(Icons.check_circle_outline,
                        color: Color(0xFF1D9E75), size: 16),
                    SizedBox(width: 8),
                    Text('Application saved to tracker',
                        style: TextStyle(color: Color(0xFFEEEDFE))),
                  ],
                ),
                backgroundColor: const Color(0xFF1A1730),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            );
            context.go('/');
          } else if (state is JobApplicationError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message,
                    style: const TextStyle(color: Color(0xFFEEEDFE))),
                backgroundColor: const Color(0xFF1A1730),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            );
          }
        },
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context, isWeb),
              Expanded(
                child: isWeb
                    ? _buildWebLayout(context, isWeb)
                    : _buildMobileLayout(context, isWeb),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Header ──────────────────────────────────────────────────────────────────

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
                  'Analysis Result',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFEEEDFE),
                    letterSpacing: -0.4,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'CV vs job description match',
                  style: TextStyle(fontSize: 12, color: Color(0xFF6B7089)),
                ),
              ],
            ),
          ),
          // Date badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
              border:
                  Border.all(color: Colors.white.withOpacity(0.07), width: 0.5),
            ),
            child: Text(
              widget.analysis.createdAt.toLocal().toString().split(' ')[0],
              style: const TextStyle(fontSize: 11, color: Color(0xFF6B7089)),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Web Layout ───────────────────────────────────────────────────────────────

  Widget _buildWebLayout(BuildContext context, bool isWeb) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left column: score + skills + summary
        Expanded(
          flex: 5,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildScoreCard(isWeb),
                const SizedBox(height: 24),
                _buildSkillsSection(isWeb),
                const SizedBox(height: 24),
                _buildSummaryCard(),
                const SizedBox(height: 24),
                _buildSaveButton(context),
              ],
            ),
          ),
        ),
        // Right column: CV + cover letter
        Expanded(
          flex: 5,
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(
                    color: Colors.white.withOpacity(0.06), width: 0.5),
              ),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  _buildExpandableSection(
                    context: context,
                    title: 'Optimized CV Content',
                    icon: Icons.description_outlined,
                    color: const Color(0xFF534AB7),
                    blocks: widget.analysis.optimizedCvContent,
                    isExpanded: _cvExpanded,
                    onToggle: () => setState(() => _cvExpanded = !_cvExpanded),
                    copyLabel: 'CV Content',
                  ),
                  const SizedBox(height: 16),
                  _buildExpandableSection(
                    context: context,
                    title: 'Generated Cover Letter',
                    icon: Icons.mail_outline_rounded,
                    color: const Color(0xFF1D9E75),
                    blocks: widget.analysis.generatedCoverLetter,
                    isExpanded: _coverExpanded,
                    onToggle: () =>
                        setState(() => _coverExpanded = !_coverExpanded),
                    copyLabel: 'Cover Letter',
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ─── Mobile Layout ────────────────────────────────────────────────────────────

  Widget _buildMobileLayout(BuildContext context, bool isWeb) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildScoreCard(isWeb),
          const SizedBox(height: 20),
          _buildSkillsSection(isWeb),
          const SizedBox(height: 20),
          _buildSummaryCard(),
          const SizedBox(height: 20),
          _buildExpandableSection(
            context: context,
            title: 'Optimized CV Content',
            icon: Icons.description_outlined,
            color: const Color(0xFF534AB7),
            blocks: widget.analysis.optimizedCvContent,
            isExpanded: _cvExpanded,
            onToggle: () => setState(() => _cvExpanded = !_cvExpanded),
            copyLabel: 'CV Content',
          ),
          const SizedBox(height: 16),
          _buildExpandableSection(
            context: context,
            title: 'Generated Cover Letter',
            icon: Icons.mail_outline_rounded,
            color: const Color(0xFF1D9E75),
            blocks: widget.analysis.generatedCoverLetter,
            isExpanded: _coverExpanded,
            onToggle: () => setState(() => _coverExpanded = !_coverExpanded),
            copyLabel: 'Cover Letter',
          ),
          const SizedBox(height: 24),
          _buildSaveButton(context),
        ],
      ),
    );
  }

  // ─── Score Card ───────────────────────────────────────────────────────────────

  Widget _buildScoreCard(bool isWeb) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _scoreColor.withOpacity(0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _scoreColor.withOpacity(0.2), width: 0.5),
      ),
      child: isWeb
          ? Row(
              children: [
                _buildScoreCircle(80),
                const SizedBox(width: 28),
                Expanded(child: _buildScoreMeta()),
              ],
            )
          : Column(
              children: [
                _buildScoreCircle(72),
                const SizedBox(height: 20),
                _buildScoreMeta(),
              ],
            ),
    );
  }

  Widget _buildScoreCircle(double size) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: CircularProgressIndicator(
            value: widget.analysis.matchScore / 100,
            backgroundColor: _scoreColor.withOpacity(0.15),
            valueColor: AlwaysStoppedAnimation(_scoreColor),
            strokeWidth: 6,
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${widget.analysis.matchScore}%',
              style: TextStyle(
                fontSize: size * 0.26,
                fontWeight: FontWeight.w800,
                color: _scoreColor,
                letterSpacing: -1,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildScoreMeta() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: _scoreColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _scoreColor.withOpacity(0.3), width: 0.5),
          ),
          child: Text(
            _scoreLabel,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: _scoreColor,
            ),
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Match Score',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFFEEEDFE),
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Based on skills, experience and keyword alignment between your CV and the job description.',
          style: TextStyle(fontSize: 12, color: Color(0xFF6B7089), height: 1.5),
        ),
      ],
    );
  }

  // ─── Skills Section ───────────────────────────────────────────────────────────

  Widget _buildSkillsSection(bool isWeb) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel('Skills Breakdown'),
        const SizedBox(height: 12),
        // Use existing SkillGapWidget but wrapped in themed container
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.04),
            borderRadius: BorderRadius.circular(18),
            border:
                Border.all(color: Colors.white.withOpacity(0.07), width: 0.5),
          ),
          child: SkillGapWidget(
            matched: widget.analysis.matchedSkills,
            missingCritical: widget.analysis.missingCriticalSkills,
            missingOptional: widget.analysis.missingOptionalSkills,
          ),
        ),
      ],
    );
  }

  // ─── Summary Card ─────────────────────────────────────────────────────────────

  Widget _buildSummaryCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel('Recommendation Summary'),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.04),
            borderRadius: BorderRadius.circular(18),
            border:
                Border.all(color: Colors.white.withOpacity(0.07), width: 0.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF534AB7).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.tips_and_updates_outlined,
                        color: Color(0xFF8B82D4), size: 16),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'AI Recommendation',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFEEEDFE),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                widget.analysis.recommendationSummary,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFFAAAABB),
                  height: 1.7,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─── Expandable Section ───────────────────────────────────────────────────────

  Widget _buildExpandableSection({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color color,
    required List<ContentBlockEntity> blocks,
    required bool isExpanded,
    required VoidCallback onToggle,
    required String copyLabel,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.07), width: 0.5),
      ),
      child: Column(
        children: [
          // Header row
          GestureDetector(
            onTap: onToggle,
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: color, size: 16),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFEEEDFE),
                      ),
                    ),
                  ),
                  // Copy button
                  GestureDetector(
                    onTap: () => _copyToClipboard(context, blocks, copyLabel),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: color.withOpacity(0.2), width: 0.5),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.copy_rounded, color: color, size: 12),
                          const SizedBox(width: 4),
                          Text('Copy',
                              style: TextStyle(
                                  fontSize: 11,
                                  color: color,
                                  fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: isExpanded
                          ? const Color(0xFF8B82D4)
                          : const Color(0xFF4A4E6A),
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Expanded content
          AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: isExpanded
                ? Column(
                    children: [
                      Divider(
                          color: Colors.white.withOpacity(0.06),
                          thickness: 0.5,
                          height: 0),
                      Padding(
                        padding: const EdgeInsets.all(18),
                        child: StructuredContentViewer(contentBlocks: blocks),
                      ),
                    ],
                  )
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }

  // ─── Save Button ──────────────────────────────────────────────────────────────

  Widget _buildSaveButton(BuildContext context) {
    final canSave = widget.analysis.jobId != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        BlocBuilder<JobApplicationCubit, JobApplicationState>(
          builder: (context, state) {
            final isLoading = state is JobApplicationLoading;
            return GestureDetector(
              onTap: canSave && !isLoading
                  ? () => _showSaveApplicationSheet(context)
                  : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 52,
                decoration: BoxDecoration(
                  gradient: canSave
                      ? const LinearGradient(
                          colors: [Color(0xFF6C63E0), Color(0xFF534AB7)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  color: canSave ? null : Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(14),
                  border: canSave
                      ? null
                      : Border.all(
                          color: Colors.white.withOpacity(0.08), width: 0.5),
                  boxShadow: canSave
                      ? [
                          BoxShadow(
                            color: const Color(0xFF534AB7).withOpacity(0.4),
                            blurRadius: 18,
                            offset: const Offset(0, 5),
                          )
                        ]
                      : null,
                ),
                child: isLoading
                    ? const Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.bookmark_add_outlined,
                            color: canSave
                                ? Colors.white
                                : const Color(0xFF4A4E6A),
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Save as Job Application',
                            style: TextStyle(
                              color: canSave
                                  ? Colors.white
                                  : const Color(0xFF4A4E6A),
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
              ),
            );
          },
        ),
        if (!canSave) ...[
          const SizedBox(height: 8),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.info_outline_rounded,
                  color: Color(0xFF6B7089), size: 13),
              SizedBox(width: 5),
              Text(
                'No linked job — cannot save application.',
                style: TextStyle(fontSize: 12, color: Color(0xFF6B7089)),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: Color(0xFFEEEDFE),
        letterSpacing: -0.2,
      ),
    );
  }
}

// ─── Save Application Sheet ───────────────────────────────────────────────────

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
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Title
          const Text(
            'Save as Application',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFFEEEDFE),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Track this application in your pipeline.',
            style: TextStyle(fontSize: 13, color: Color(0xFF6B7089)),
          ),
          const SizedBox(height: 20),

          // CV info row
          BlocBuilder<CVCubit, CVState>(
            builder: (context, state) {
              String cvName = 'Loading...';
              if (state is CVLoaded) {
                try {
                  cvName = state.cvs
                      .firstWhere((c) => c.id == widget.analysis.cvId)
                      .originalFilename;
                } catch (_) {
                  cvName = 'Unknown CV';
                }
              }
              return _InfoRow(
                icon: Icons.description_outlined,
                color: const Color(0xFF534AB7),
                label: 'CV used',
                value: cvName,
              );
            },
          ),
          const SizedBox(height: 10),

          // Job info row
          BlocBuilder<JobCubit, JobState>(
            builder: (context, state) {
              String jobTitle = 'Loading...';
              if (state is JobLoaded) {
                try {
                  jobTitle = state.jobs
                          .firstWhere((j) => j.id == widget.analysis.jobId)
                          .jobTitle ??
                      'Untitled Job';
                } catch (_) {
                  jobTitle = 'Unknown Job';
                }
              }
              return _InfoRow(
                icon: Icons.work_outline_rounded,
                color: const Color(0xFF1D9E75),
                label: 'Job',
                value: jobTitle,
              );
            },
          ),
          const SizedBox(height: 20),

          Divider(color: Colors.white.withOpacity(0.07), thickness: 0.5),
          const SizedBox(height: 16),

          // Status label
          const Text(
            'APPLICATION STATUS',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
              color: Color(0xFF6B7089),
            ),
          ),
          const SizedBox(height: 10),

          // Status pills
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: AppConstants.statusValues.map((s) {
              final isSelected = _selectedStatus == s;
              final color = _statusColor(s);
              return GestureDetector(
                onTap: () => setState(() => _selectedStatus = s),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? color.withOpacity(0.15)
                        : Colors.white.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? color.withOpacity(0.4)
                          : Colors.white.withOpacity(0.07),
                      width: isSelected ? 1 : 0.5,
                    ),
                  ),
                  child: Text(
                    s[0].toUpperCase() + s.substring(1),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: isSelected ? color : const Color(0xFF6B7089),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // Notes field
          const Text(
            'NOTES',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
              color: Color(0xFF6B7089),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.04),
              borderRadius: BorderRadius.circular(14),
              border:
                  Border.all(color: Colors.white.withOpacity(0.08), width: 0.5),
            ),
            child: TextField(
              controller: _notesController,
              maxLines: 3,
              style: const TextStyle(color: Color(0xFFEEEDFE), fontSize: 14),
              decoration: const InputDecoration(
                hintText: 'Any notes about this application...',
                hintStyle: TextStyle(color: Color(0xFF4A4E6A), fontSize: 13),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.all(14),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: Colors.white.withOpacity(0.08), width: 0.5),
                    ),
                    child: const Center(
                      child: Text('Cancel',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFFAAAABB))),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    context.read<JobApplicationCubit>().createApplication(
                          widget.analysis.cvId,
                          widget.analysis.jobId!,
                          widget.analysis.id,
                          _selectedStatus,
                          _notesController.text,
                        );
                    Navigator.pop(context);
                  },
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6C63E0), Color(0xFF534AB7)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF534AB7).withOpacity(0.4),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text('Save Application',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

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
}

// ─── Info Row ─────────────────────────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.06), width: 0.5),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 10, color: Color(0xFF6B7089))),
                const SizedBox(height: 2),
                Text(value,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFEEEDFE),
                    ),
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
