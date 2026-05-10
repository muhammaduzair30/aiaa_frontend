import 'package:aiaa/features/analysis/presentation/cubit/analysis_cubit.dart';
import 'package:aiaa/features/cv/presentation/cubit/cv_cubit.dart';
import 'package:aiaa/features/job/presentation/cubit/job_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
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
            if (application == null) cubit.getApplication(id);
            return cubit;
          },
        ),
        BlocProvider(create: (_) => sl<CVCubit>()..loadCVs()),
        BlocProvider(create: (_) => sl<JobCubit>()..loadJobs()),
        BlocProvider(create: (_) => sl<AnalysisCubit>()),
      ],
      child:
          _ApplicationDetailScreenView(id: id, initialApplication: application),
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
  JobApplicationEntity? _application;
  bool _isInit = false;
  bool _notesFocused = false;

  // Cache loaded CVs/Jobs so tiles stay clickable during download operations
  List<dynamic> _cachedCvs = [];
  List<dynamic> _cachedJobs = [];

  @override
  void initState() {
    super.initState();
    _application = widget.initialApplication;
    if (_application != null) _initFields(_application!);
  }

  void _initFields(JobApplicationEntity app) {
    _currentStatus = app.status;
    _notesController.text = app.notes ?? '';
    _appliedDate = app.appliedDate;
    _isInit = true;
    if (app.analysisId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted)
          context.read<AnalysisCubit>().loadAnalysis(app.analysisId!);
      });
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _appliedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF534AB7),
            surface: Color(0xFF13112A),
            onSurface: Color(0xFFEEEDFE),
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null && picked != _appliedDate) {
      setState(() => _appliedDate = picked);
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
      builder: (ctx) => Dialog(
        backgroundColor: const Color(0xFF13112A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFFE24B4A).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.delete_outline_rounded,
                    color: Color(0xFFE24B4A), size: 24),
              ),
              const SizedBox(height: 16),
              const Text('Delete Application?',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFEEEDFE))),
              const SizedBox(height: 8),
              const Text(
                'This application will be permanently removed from your tracker.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 13, color: Color(0xFF6B7089), height: 1.5),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(ctx),
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.08),
                              width: 0.5),
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
                        Navigator.pop(ctx);
                        context
                            .read<JobApplicationCubit>()
                            .deleteApplication(widget.id);
                        context.pop();
                      },
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE24B4A).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: const Color(0xFFE24B4A).withOpacity(0.3),
                              width: 0.5),
                        ),
                        child: const Center(
                          child: Text('Delete',
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFFE24B4A))),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
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

  @override
  Widget build(BuildContext context) {
    final isWeb = MediaQuery.of(context).size.width > 768;

    // Initialize caches from current state to ensure initial clickability
    final cvState = context.read<CVCubit>().state;
    if (cvState is CVLoaded && _cachedCvs.isEmpty) {
      _cachedCvs = cvState.cvs;
    }
    final jobState = context.read<JobCubit>().state;
    if (jobState is JobLoaded && _cachedJobs.isEmpty) {
      _cachedJobs = jobState.jobs;
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0D0B1E),
      body: MultiBlocListener(
        listeners: [
          BlocListener<JobApplicationCubit, JobApplicationState>(
            listener: (context, state) {
              if (state is JobApplicationUpdated) {
                setState(() {
                  _application = state.application;
                  _currentStatus = state.application.status;
                  _notesController.text = state.application.notes ?? '';
                  _appliedDate = state.application.appliedDate;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Row(
                      children: [
                        Icon(Icons.check_circle_outline,
                            color: Color(0xFF1D9E75), size: 16),
                        SizedBox(width: 8),
                        Text('Changes saved successfully',
                            style: TextStyle(color: Color(0xFFEEEDFE))),
                      ],
                    ),
                    backgroundColor: const Color(0xFF1A1730),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                );
                Navigator.pop(context, true);
              } else if (state is JobApplicationDetailLoaded && !_isInit) {
                setState(() => _application = state.application);
                _initFields(state.application);
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
          ),
          // Listen for CV download URL ready → open in browser
          BlocListener<CVCubit, CVState>(
            listener: (context, state) {
              if (state is CVLoaded) {
                setState(() {
                  _cachedCvs = state.cvs;
                });
              } else if (state is CVDownloadUrlReady) {
                launchUrl(Uri.parse(state.url),
                    mode: LaunchMode.externalApplication);
                // Reload CVs to restore CVLoaded state
                context.read<CVCubit>().loadCVs();
              } else if (state is CVError) {
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
                // Reload to restore state
                context.read<CVCubit>().loadCVs();
              }
            },
          ),
          // Cache loaded jobs
          BlocListener<JobCubit, JobState>(
            listener: (context, state) {
              if (state is JobLoaded) {
                setState(() {
                  _cachedJobs = state.jobs;
                });
              }
            },
          ),
        ],
        child: SafeArea(
          child: _application == null
              ? const Center(
                  child: CircularProgressIndicator(color: Color(0xFF534AB7)))
              : Column(
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
    final statusColor = _statusColor(_currentStatus);

    return Container(
      padding: EdgeInsets.fromLTRB(
          isWeb ? 32 : 20, isWeb ? 28 : 16, isWeb ? 32 : 20, isWeb ? 20 : 16),
      decoration: BoxDecoration(
        color: const Color(0xFF0D0B1E),
        border: Border(
            bottom:
                BorderSide(color: Colors.white.withOpacity(0.06), width: 0.5)),
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _application?.jobTitle ?? 'Application Details',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFEEEDFE),
                    letterSpacing: -0.4,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                // Status badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                        color: statusColor.withOpacity(0.3), width: 0.5),
                  ),
                  child: Text(
                    _currentStatus[0].toUpperCase() +
                        _currentStatus.substring(1),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Delete button
          GestureDetector(
            onTap: _onDelete,
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFFE24B4A).withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: const Color(0xFFE24B4A).withOpacity(0.2),
                    width: 0.5),
              ),
              child: const Icon(Icons.delete_outline_rounded,
                  color: Color(0xFFE24B4A), size: 18),
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
        // Left: info cards
        Expanded(
          flex: 5,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoCards(context),
                if (_application?.analysisId != null) ...[
                  const SizedBox(height: 16),
                  _buildAnalysisCard(context),
                ],
              ],
            ),
          ),
        ),
        // Right: edit form
        Expanded(
          flex: 5,
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                  left: BorderSide(
                      color: Colors.white.withOpacity(0.06), width: 0.5)),
            ),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(32),
                    child: _buildEditForm(context, isWeb),
                  ),
                ),
                _buildActionBar(context, isWeb),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ─── Mobile Layout ────────────────────────────────────────────────────────────

  Widget _buildMobileLayout(BuildContext context, bool isWeb) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoCards(context),
                if (_application?.analysisId != null) ...[
                  const SizedBox(height: 16),
                  _buildAnalysisCard(context),
                ],
                const SizedBox(height: 24),
                _buildEditForm(context, isWeb),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
        _buildActionBar(context, isWeb),
      ],
    );
  }

  // ─── Info Cards ───────────────────────────────────────────────────────────────

  Widget _buildInfoCards(BuildContext context) {
    final app = _application!;

    // Use cached lists which survive non-Loaded states (e.g. CVDownloadLoading)
    dynamic matchedCv;
    String cvName = app.cvFilename ?? 'Loading...';
    try {
      matchedCv = _cachedCvs.firstWhere((c) => c.id == app.cvId);
      if (app.cvFilename == null) cvName = matchedCv.originalFilename;
    } catch (_) {
      if (app.cvFilename == null && _cachedCvs.isNotEmpty)
        cvName = 'Unknown CV';
    }

    dynamic matchedJob;
    String jobTitle = app.jobTitle ?? 'Loading...';
    try {
      matchedJob = _cachedJobs.firstWhere((j) => j.id == app.jobId);
      if (app.jobTitle == null)
        jobTitle = matchedJob.jobTitle ?? 'Untitled Job';
    } catch (_) {
      if (app.jobTitle == null && _cachedJobs.isNotEmpty)
        jobTitle = 'Unknown Job';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('Application info'),
        const SizedBox(height: 12),
        // CV card – clickable
        _buildInfoTile(
          icon: Icons.description_outlined,
          color: const Color(0xFF534AB7),
          label: 'CV used',
          valueWidget: Text(cvName,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFEEEDFE))),
          onTap: matchedCv != null
              ? () => _showCVOptionsSheet(context, matchedCv)
              : null,
        ),
        const SizedBox(height: 10),
        // Job card – clickable
        _buildInfoTile(
          icon: Icons.work_outline_rounded,
          color: const Color(0xFF1D9E75),
          label: 'Job applied for',
          valueWidget: Text(jobTitle,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFEEEDFE))),
          onTap: matchedJob != null
              ? () => _showJobDetailSheet(context, matchedJob)
              : null,
        ),
        if (_appliedDate != null) ...[
          const SizedBox(height: 10),
          _buildInfoTile(
            icon: Icons.calendar_today_outlined,
            color: const Color(0xFF378ADD),
            label: 'Applied on',
            valueWidget: Text(
              DateFormat('MMM d, yyyy').format(_appliedDate!),
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFEEEDFE)),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required Color color,
    required String label,
    required Widget valueWidget,
    VoidCallback? onTap,
  }) {
    final tile = Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.07), width: 0.5),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 11, color: Color(0xFF6B7089))),
                const SizedBox(height: 3),
                valueWidget,
              ],
            ),
          ),
          if (onTap != null)
            const Icon(Icons.chevron_right_rounded,
                color: Color(0xFF4A4E6A), size: 18),
        ],
      ),
    );

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: tile);
    }
    return tile;
  }

  // ─── Analysis Card ────────────────────────────────────────────────────────────

  Widget _buildAnalysisCard(BuildContext context) {
    return BlocBuilder<AnalysisCubit, AnalysisState>(
      builder: (context, state) {
        if (state is AnalysisRunning) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.04),
              borderRadius: BorderRadius.circular(14),
              border:
                  Border.all(color: Colors.white.withOpacity(0.07), width: 0.5),
            ),
            child: const Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      color: Color(0xFF534AB7), strokeWidth: 2),
                ),
                SizedBox(width: 12),
                Text('Loading analysis...',
                    style: TextStyle(fontSize: 13, color: Color(0xFF6B7089))),
              ],
            ),
          );
        }

        if (state is AnalysisComplete) {
          final score = state.analysis.matchScore;
          final scoreColor = score >= 80
              ? const Color(0xFF1D9E75)
              : score >= 50
                  ? const Color(0xFFEF9F27)
                  : const Color(0xFFE24B4A);
          final scoreLabel = score >= 80
              ? 'Strong'
              : score >= 50
                  ? 'Average'
                  : 'Weak';

          return GestureDetector(
            onTap: () => context.push('/analysis/${_application!.analysisId}'),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: scoreColor.withOpacity(0.06),
                borderRadius: BorderRadius.circular(14),
                border:
                    Border.all(color: scoreColor.withOpacity(0.2), width: 0.5),
              ),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: scoreColor.withOpacity(0.1),
                      border: Border.all(
                          color: scoreColor.withOpacity(0.4), width: 1.5),
                    ),
                    child: Center(
                      child: Text('$score%',
                          style: TextStyle(
                              color: scoreColor,
                              fontWeight: FontWeight.w700,
                              fontSize: 13)),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('AI Match Score',
                            style: TextStyle(
                                fontSize: 11, color: Color(0xFF6B7089))),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text('$score% match',
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: scoreColor)),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: scoreColor.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(scoreLabel,
                                  style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: scoreColor)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded,
                      color: Color(0xFF4A4E6A), size: 18),
                ],
              ),
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  // ─── Edit Form ────────────────────────────────────────────────────────────────

  Widget _buildEditForm(BuildContext context, bool isWeb) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('Update application'),
        const SizedBox(height: 16),

        // Status pills
        const Text('STATUS',
            style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
                color: Color(0xFF6B7089))),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: AppConstants.statusValues.map((s) {
            final isSelected = _currentStatus == s;
            final color = _statusColor(s);
            return GestureDetector(
              onTap: () => setState(() => _currentStatus = s),
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
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected ? color : const Color(0xFF6B7089),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),

        // Applied date
        const Text('APPLIED DATE',
            style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
                color: Color(0xFF6B7089))),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => _selectDate(context),
          child: Container(
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(14),
              border:
                  Border.all(color: Colors.white.withOpacity(0.09), width: 0.5),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today_outlined,
                    color: Color(0xFF534AB7), size: 18),
                const SizedBox(width: 12),
                Text(
                  _appliedDate != null
                      ? DateFormat('MMM d, yyyy').format(_appliedDate!)
                      : 'Select date',
                  style: TextStyle(
                    fontSize: 14,
                    color: _appliedDate != null
                        ? const Color(0xFFEEEDFE)
                        : const Color(0xFF4A4E6A),
                  ),
                ),
                const Spacer(),
                const Icon(Icons.chevron_right_rounded,
                    color: Color(0xFF4A4E6A), size: 18),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Notes
        const Text('NOTES',
            style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
                color: Color(0xFF6B7089))),
        const SizedBox(height: 8),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: _notesFocused
                ? const Color(0xFF534AB7).withOpacity(0.06)
                : Colors.white.withOpacity(0.04),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: _notesFocused
                  ? const Color(0xFF534AB7).withOpacity(0.5)
                  : Colors.white.withOpacity(0.08),
              width: 0.5,
            ),
          ),
          child: Focus(
            onFocusChange: (v) => setState(() => _notesFocused = v),
            child: TextField(
              controller: _notesController,
              maxLines: 4,
              style: const TextStyle(
                  color: Color(0xFFEEEDFE), fontSize: 14, height: 1.5),
              decoration: const InputDecoration(
                hintText: 'Add notes about this application...',
                hintStyle: TextStyle(color: Color(0xFF4A4E6A), fontSize: 13),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.all(14),
                filled: true,
                fillColor: Colors.transparent,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ─── Action Bar ───────────────────────────────────────────────────────────────

  Widget _buildActionBar(BuildContext context, bool isWeb) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          isWeb ? 32 : 20, 16, isWeb ? 32 : 20, isWeb ? 24 : 28),
      decoration: BoxDecoration(
        color: const Color(0xFF0D0B1E),
        border: Border(
            top: BorderSide(color: Colors.white.withOpacity(0.06), width: 0.5)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // View analysis button (if available)
          if (_application?.analysisId != null) ...[
            GestureDetector(
              onTap: () =>
                  context.push('/analysis/${_application!.analysisId}'),
              child: Container(
                width: double.infinity,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF534AB7).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: const Color(0xFF534AB7).withOpacity(0.3),
                      width: 0.5),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.insights_rounded,
                        color: Color(0xFF8B82D4), size: 16),
                    SizedBox(width: 8),
                    Text('View Full Analysis',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF8B82D4))),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
          // Save changes button
          BlocBuilder<JobApplicationCubit, JobApplicationState>(
            builder: (context, state) {
              final isLoading = state is JobApplicationLoading;
              return GestureDetector(
                onTap: isLoading ? null : _onSaveChanges,
                child: Container(
                  width: double.infinity,
                  height: 52,
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
                        blurRadius: 18,
                        offset: const Offset(0, 5),
                      ),
                    ],
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
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.save_outlined,
                                color: Colors.white, size: 18),
                            SizedBox(width: 8),
                            Text('Save Changes',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String label) {
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

  // ─── CV Options Sheet ──────────────────────────────────────────────────────────

  void _showCVOptionsSheet(BuildContext context, dynamic cv) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF13112A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              // File name header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF534AB7).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.description_outlined,
                        color: Color(0xFF8B82D4), size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cv.originalFilename ?? 'Untitled CV',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFEEEDFE),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Uploaded ${DateFormat('MMM d, yyyy').format(cv.createdAt)}',
                          style: const TextStyle(
                              fontSize: 11, color: Color(0xFF6B7089)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Divider(color: Colors.white.withOpacity(0.07), thickness: 0.5),
              const SizedBox(height: 8),
              // Actions
              _buildSheetAction(
                icon: Icons.insights_outlined,
                label: 'Run Analysis',
                color: const Color(0xFF534AB7),
                onTap: () {
                  Navigator.pop(context);
                  context.push('/analysis', extra: cv);
                },
              ),
              _buildSheetAction(
                icon: Icons.visibility_outlined,
                label: 'View / Download',
                color: const Color(0xFF378ADD),
                onTap: () {
                  Navigator.pop(context);
                  context.read<CVCubit>().getDownloadUrl(cv.id);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Job Detail Sheet ──────────────────────────────────────────────────────────

  void _showJobDetailSheet(BuildContext context, dynamic job) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF13112A),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.65,
        minChildSize: 0.4,
        maxChildSize: 0.92,
        builder: (_, scrollController) => Column(
          children: [
            // Handle + header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Column(
                children: [
                  Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          job.jobTitle ?? 'Untitled Job',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFEEEDFE),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.07),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.close_rounded,
                              color: Color(0xFF6B7089), size: 16),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.calendar_today_outlined,
                              size: 12, color: Color(0xFF6B7089)),
                          const SizedBox(width: 5),
                          Text(
                            'Added ${DateFormat('MMM d, yyyy').format(job.createdAt)}',
                            style: const TextStyle(
                                fontSize: 12, color: Color(0xFF6B7089)),
                          ),
                        ],
                      ),
                      if (job.sourceUrl != null && job.sourceUrl!.isNotEmpty)
                        GestureDetector(
                          onTap: () => launchUrl(Uri.parse(job.sourceUrl!)),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF378ADD).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.link_rounded,
                                    color: Color(0xFF378ADD), size: 12),
                                SizedBox(width: 6),
                                Text('Original URL',
                                    style: TextStyle(
                                        color: Color(0xFF378ADD),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Divider(
                      color: Colors.white.withOpacity(0.07), thickness: 0.5),
                ],
              ),
            ),
            // Scrollable body
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                child: Text(
                  job.rawText,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFFAAAABB),
                    height: 1.7,
                  ),
                ),
              ),
            ),
            // Action bar
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
              decoration: BoxDecoration(
                color: const Color(0xFF13112A),
                border: Border(
                  top: BorderSide(
                      color: Colors.white.withOpacity(0.07), width: 0.5),
                ),
              ),
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  context.push('/analysis', extra: job);
                },
                child: Container(
                  width: double.infinity,
                  height: 46,
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
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.insights_rounded,
                          color: Colors.white, size: 16),
                      SizedBox(width: 8),
                      Text(
                        'Run Analysis',
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
            ),
          ],
        ),
      ),
    );
  }

  // ─── Sheet Action Helper ───────────────────────────────────────────────────────

  Widget _buildSheetAction({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 14),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFFEEEDFE),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
