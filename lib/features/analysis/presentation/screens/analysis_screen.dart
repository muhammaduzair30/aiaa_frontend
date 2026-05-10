import 'package:aiaa/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection.dart';
import '../../../job/domain/entities/job_entity.dart';
import '../cubit/analysis_cubit.dart';
import '../../../cv/domain/entities/cv_entity.dart';
import '../../../cv/presentation/cubit/cv_cubit.dart';

class AnalysisScreen extends StatelessWidget {
  final String? preSelectedCvId;
  final JobEntity? preSelectedJob;

  const AnalysisScreen({
    super.key,
    this.preSelectedCvId,
    this.preSelectedJob,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<AnalysisCubit>()),
        BlocProvider(create: (_) => sl<CVCubit>()),
      ],
      child: _AnalysisScreenView(
        preSelectedCvId: preSelectedCvId,
        preSelectedJob: preSelectedJob,
      ),
    );
  }
}

class _AnalysisScreenView extends StatefulWidget {
  final String? preSelectedCvId;
  final JobEntity? preSelectedJob;

  const _AnalysisScreenView({
    this.preSelectedCvId,
    this.preSelectedJob,
  });

  @override
  State<_AnalysisScreenView> createState() => _AnalysisScreenViewState();
}

class _AnalysisScreenViewState extends State<_AnalysisScreenView> {
  String? _selectedCvId;
  JobEntity? _selectedJob;

  @override
  void initState() {
    super.initState();
    _selectedCvId = widget.preSelectedCvId;
    _selectedJob = widget.preSelectedJob;
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

  bool get _canRun => _selectedCvId != null && _selectedJob != null;

  @override
  Widget build(BuildContext context) {
    final isWeb = MediaQuery.of(context).size.width > 768;

    return Scaffold(
      backgroundColor: const Color(0xFF0D0B1E),
      body: BlocConsumer<AnalysisCubit, AnalysisState>(
        listener: (context, state) {
          if (state is AnalysisComplete) {
            context.push('/analysis/result', extra: state.analysis);
          } else if (state is AnalysisError) {
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
        builder: (context, state) {
          final isRunning = state is AnalysisRunning;

          return SafeArea(
            child: isRunning
                ? _buildRunningState()
                : Column(
                    children: [
                      _buildHeader(isWeb),
                      Expanded(
                        child: isWeb
                            ? _buildWebLayout(isWeb)
                            : _buildMobileLayout(isWeb),
                      ),
                    ],
                  ),
          );
        },
      ),
    );
  }

  // ─── Running / Loading State ─────────────────────────────────────────────────

  Widget _buildRunningState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated AI icon
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF534AB7).withOpacity(0.12),
              border: Border.all(
                  color: const Color(0xFF534AB7).withOpacity(0.3), width: 1.5),
            ),
            child: const Icon(Icons.insights_rounded,
                color: Color(0xFF8B82D4), size: 40),
          ),
          const SizedBox(height: 28),
          const Text(
            'Analyzing your match...',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFFEEEDFE),
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'AI is comparing your CV with the job\ndescription. This takes 10–15 seconds.',
            textAlign: TextAlign.center,
            style:
                TextStyle(fontSize: 13, color: Color(0xFF6B7089), height: 1.6),
          ),
          const SizedBox(height: 32),
          // Progress steps
          _buildAnalysisSteps(),
        ],
      ),
    );
  }

  Widget _buildAnalysisSteps() {
    final steps = [
      'Reading CV content',
      'Parsing job requirements',
      'Calculating match score',
      'Generating recommendations',
    ];
    return Column(
      children: steps.map((step) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  color: const Color(0xFF534AB7).withOpacity(0.6),
                  strokeWidth: 1.5,
                ),
              ),
              const SizedBox(width: 10),
              Text(step,
                  style:
                      const TextStyle(fontSize: 12, color: Color(0xFF6B7089))),
            ],
          ),
        );
      }).toList(),
    );
  }

  // ─── Header ──────────────────────────────────────────────────────────────────

  Widget _buildHeader(bool isWeb) {
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
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'New Analysis',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFEEEDFE),
                  letterSpacing: -0.4,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Match your CV against a job description',
                style: TextStyle(fontSize: 12, color: Color(0xFF6B7089)),
              ),
            ],
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => context.push('/analysis/history'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF534AB7).withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: const Color(0xFF534AB7).withOpacity(0.3),
                    width: 0.5),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.history_rounded,
                      color: Color(0xFF8B82D4), size: 16),
                  SizedBox(width: 6),
                  Text(
                    'History',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFEEEDFE),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (!isWeb) ...[
            const SizedBox(width: 12),
            GestureDetector(
              onTap: () {
                context.read<AuthBloc>().add(AuthLogoutRequested());
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: Colors.white.withOpacity(0.08), width: 0.5),
                ),
                child: const Icon(Icons.logout_rounded,
                    color: Color(0xFFE24B4A), size: 18),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ─── Web Layout ───────────────────────────────────────────────────────────────

  Widget _buildWebLayout(bool isWeb) {
    return Row(
      children: [
        // Left: form
        Expanded(
          flex: 6,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(40, 32, 40, 0),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: _buildFormContent(isWeb: true),
                  ),
                ),
              ),
              _buildRunBar(isWeb: true),
            ],
          ),
        ),
        // Right: how it works panel
        Container(
          width: 300,
          decoration: BoxDecoration(
            border: Border(
              left:
                  BorderSide(color: Colors.white.withOpacity(0.06), width: 0.5),
            ),
          ),
          child: _buildHowItWorksPanel(),
        ),
      ],
    );
  }

  // ─── Mobile Layout ────────────────────────────────────────────────────────────

  Widget _buildMobileLayout(bool isWeb) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
            child: _buildFormContent(isWeb: false),
          ),
        ),
        _buildRunBar(isWeb: false),
      ],
    );
  }

  // ─── Form Content ─────────────────────────────────────────────────────────────

  Widget _buildFormContent({required bool isWeb}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Step 1: CV
        _buildStepLabel('01', 'Select your CV'),
        const SizedBox(height: 12),
        BlocBuilder<CVCubit, CVState>(
          builder: (context, cvState) {
            if (cvState is CVLoading) {
              return Container(
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: Colors.white.withOpacity(0.08), width: 0.5),
                ),
                child: const Center(
                  child: SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        color: Color(0xFF534AB7), strokeWidth: 2),
                  ),
                ),
              );
            }

            if (cvState is CVLoaded) {
              if (cvState.cvs.isEmpty) {
                return _buildNoCVsCard();
              }
              return _buildCVSelector(cvState.cvs);
            }

            return const SizedBox.shrink();
          },
        ),

        const SizedBox(height: 28),

        // Step 2: Job
        _buildStepLabel('02', 'Select job description'),
        const SizedBox(height: 12),
        _buildJobSelector(),

        // Selected job preview
        if (_selectedJob != null) ...[
          const SizedBox(height: 16),
          _buildJobPreview(),
        ],

        const SizedBox(height: 24),
      ],
    );
  }

  // ─── Step Label ───────────────────────────────────────────────────────────────

  Widget _buildStepLabel(String number, String label) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: const Color(0xFF534AB7).withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
                color: const Color(0xFF534AB7).withOpacity(0.3), width: 0.5),
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: Color(0xFF8B82D4),
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Color(0xFFEEEDFE),
          ),
        ),
      ],
    );
  }

  // ─── CV Selector ──────────────────────────────────────────────────────────────

  Widget _buildCVSelector(List<CVEntity> cvs) {
    return Column(
      children: cvs.map((cv) {
        final isSelected = _selectedCvId == cv.id;
        return GestureDetector(
          onTap: () => setState(() => _selectedCvId = cv.id),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFF534AB7).withOpacity(0.12)
                  : Colors.white.withOpacity(0.04),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFF534AB7).withOpacity(0.6)
                    : Colors.white.withOpacity(0.08),
                width: isSelected ? 1 : 0.5,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF534AB7).withOpacity(0.2)
                        : Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.description_outlined,
                    color: isSelected
                        ? const Color(0xFF8B82D4)
                        : const Color(0xFF4A4E6A),
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    cv.originalFilename,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: isSelected
                          ? const Color(0xFFEEEDFE)
                          : const Color(0xFFAAAABB),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected
                        ? const Color(0xFF534AB7)
                        : Colors.transparent,
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF534AB7)
                          : Colors.white.withOpacity(0.2),
                      width: 1.5,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(Icons.check_rounded,
                          color: Colors.white, size: 12)
                      : null,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // ─── No CVs Card ─────────────────────────────────────────────────────────────

  Widget _buildNoCVsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFEF9F27).withOpacity(0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: const Color(0xFFEF9F27).withOpacity(0.2), width: 0.5),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded,
              color: Color(0xFFEF9F27), size: 20),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'No CVs uploaded yet. Upload a CV first to run an analysis.',
              style: TextStyle(
                  fontSize: 13, color: Color(0xFFEF9F27), height: 1.4),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () => context.push('/cv/upload'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: const Color(0xFFEF9F27).withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: const Color(0xFFEF9F27).withOpacity(0.3),
                    width: 0.5),
              ),
              child: const Text(
                'Upload',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFEF9F27),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Job Selector ─────────────────────────────────────────────────────────────

  Widget _buildJobSelector() {
    return GestureDetector(
      onTap: () async {
        final result = await context.push<JobEntity>('/job/input');
        if (result != null) {
          setState(() => _selectedJob = result);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _selectedJob != null
              ? const Color(0xFF1D9E75).withOpacity(0.08)
              : Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _selectedJob != null
                ? const Color(0xFF1D9E75).withOpacity(0.4)
                : const Color(0xFF534AB7).withOpacity(0.3),
            width: _selectedJob != null ? 1 : 0.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: _selectedJob != null
                    ? const Color(0xFF1D9E75).withOpacity(0.15)
                    : const Color(0xFF534AB7).withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                _selectedJob != null
                    ? Icons.check_circle_outline_rounded
                    : Icons.work_outline_rounded,
                color: _selectedJob != null
                    ? const Color(0xFF1D9E75)
                    : const Color(0xFF8B82D4),
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _selectedJob != null
                    ? (_selectedJob!.jobTitle ?? 'Job description selected')
                    : 'Paste text or import from URL',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight:
                      _selectedJob != null ? FontWeight.w600 : FontWeight.w400,
                  color: _selectedJob != null
                      ? const Color(0xFFEEEDFE)
                      : const Color(0xFF6B7089),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(
              _selectedJob != null
                  ? Icons.swap_horiz_rounded
                  : Icons.arrow_forward_rounded,
              color: _selectedJob != null
                  ? const Color(0xFF6B7089)
                  : const Color(0xFF534AB7),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  // ─── Job Preview ──────────────────────────────────────────────────────────────

  Widget _buildJobPreview() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.06), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.article_outlined,
                  color: Color(0xFF6B7089), size: 14),
              const SizedBox(width: 6),
              const Text(
                'JOB PREVIEW',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                  color: Color(0xFF6B7089),
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => setState(() => _selectedJob = null),
                child: const Text(
                  'Remove',
                  style: TextStyle(fontSize: 11, color: Color(0xFFE24B4A)),
                ),
              ),
            ],
          ),
          if (_selectedJob!.jobTitle != null) ...[
            const SizedBox(height: 10),
            Text(
              _selectedJob!.jobTitle!,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFFEEEDFE),
              ),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            _selectedJob!.rawText,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF6B7089),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Run Bar ──────────────────────────────────────────────────────────────────

  Widget _buildRunBar({required bool isWeb}) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          isWeb ? 40 : 20, 16, isWeb ? 40 : 20, isWeb ? 24 : 28),
      decoration: BoxDecoration(
        color: const Color(0xFF0D0B1E),
        border: Border(
          top: BorderSide(color: Colors.white.withOpacity(0.06), width: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Readiness indicators
          if (!_canRun)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  _buildReadinessChip(
                    label: 'CV selected',
                    done: _selectedCvId != null,
                  ),
                  const SizedBox(width: 8),
                  _buildReadinessChip(
                    label: 'Job added',
                    done: _selectedJob != null,
                  ),
                ],
              ),
            ),
          // Run button
          GestureDetector(
            onTap: _canRun ? _onRunAnalysis : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 52,
              decoration: BoxDecoration(
                gradient: _canRun
                    ? const LinearGradient(
                        colors: [Color(0xFF6C63E0), Color(0xFF534AB7)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: _canRun ? null : Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(14),
                border: _canRun
                    ? null
                    : Border.all(
                        color: Colors.white.withOpacity(0.08), width: 0.5),
                boxShadow: _canRun
                    ? [
                        BoxShadow(
                          color: const Color(0xFF534AB7).withOpacity(0.45),
                          blurRadius: 20,
                          offset: const Offset(0, 6),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.insights_rounded,
                    color: _canRun ? Colors.white : const Color(0xFF4A4E6A),
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Run Analysis',
                    style: TextStyle(
                      color: _canRun ? Colors.white : const Color(0xFF4A4E6A),
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReadinessChip({required String label, required bool done}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: done
            ? const Color(0xFF1D9E75).withOpacity(0.1)
            : Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: done
              ? const Color(0xFF1D9E75).withOpacity(0.3)
              : Colors.white.withOpacity(0.07),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            done
                ? Icons.check_circle_rounded
                : Icons.radio_button_unchecked_rounded,
            size: 12,
            color: done ? const Color(0xFF1D9E75) : const Color(0xFF4A4E6A),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: done ? const Color(0xFF1D9E75) : const Color(0xFF4A4E6A),
            ),
          ),
        ],
      ),
    );
  }

  // ─── How It Works Panel (web) ─────────────────────────────────────────────────

  Widget _buildHowItWorksPanel() {
    final steps = [
      (
        icon: Icons.description_outlined,
        title: 'CV is parsed',
        body: 'AI reads your CV and extracts skills, experience and keywords.',
        color: const Color(0xFF534AB7),
      ),
      (
        icon: Icons.work_outline_rounded,
        title: 'Job is analyzed',
        body: 'The job description is scanned for requirements and priorities.',
        color: const Color(0xFF378ADD),
      ),
      (
        icon: Icons.compare_arrows_rounded,
        title: 'Match is scored',
        body: 'A 0–100% match score is computed based on alignment.',
        color: const Color(0xFF1D9E75),
      ),
      (
        icon: Icons.tips_and_updates_outlined,
        title: 'Recommendations',
        body: 'Actionable suggestions to improve your CV for this role.',
        color: const Color(0xFFEF9F27),
      ),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          const Text(
            'How it works',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFFEEEDFE),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 20),
          ...steps.asMap().entries.map((entry) {
            final i = entry.key;
            final s = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: s.color.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(s.icon, color: s.color, size: 16),
                      ),
                      if (i < steps.length - 1)
                        Container(
                          width: 1,
                          height: 24,
                          color: Colors.white.withOpacity(0.07),
                          margin: const EdgeInsets.symmetric(vertical: 4),
                        ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(s.title,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFEEEDFE),
                              )),
                          const SizedBox(height: 3),
                          Text(s.body,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF6B7089),
                                height: 1.5,
                              )),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
