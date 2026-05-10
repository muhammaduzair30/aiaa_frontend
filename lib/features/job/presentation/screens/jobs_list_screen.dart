import 'package:aiaa/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/di/injection.dart';
import '../cubit/job_cubit.dart';

class JobsListScreen extends StatelessWidget {
  const JobsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<JobCubit>()..loadJobs(),
      child: const _JobsListScreenView(),
    );
  }
}

class _JobsListScreenView extends StatelessWidget {
  const _JobsListScreenView();

  @override
  Widget build(BuildContext context) {
    final isWeb = MediaQuery.of(context).size.width > 768;

    return Container(
      color: const Color(0xFF0D0B1E),
      child: BlocConsumer<JobCubit, JobState>(
        listener: (context, state) {
          if (state is JobError) {
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
          return Column(
            children: [
              // ── Header ──────────────────────────────────────────────
              _JobsHeader(
                  isWeb: isWeb,
                  jobCount: state is JobLoaded ? state.jobs.length : 0),

              // ── Body ────────────────────────────────────────────────
              Expanded(
                child: () {
                  if (state is JobLoading) {
                    return const Center(
                      child:
                          CircularProgressIndicator(color: Color(0xFF534AB7)),
                    );
                  }

                  if (state is JobLoaded) {
                    if (state.jobs.isEmpty) return const _EmptyState();

                    return isWeb
                        ? _WebGrid(jobs: state.jobs)
                        : _MobileList(jobs: state.jobs);
                  }

                  return const SizedBox.shrink();
                }(),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ─── Header ───────────────────────────────────────────────────────────────────

class _JobsHeader extends StatelessWidget {
  final bool isWeb;
  final int jobCount;

  const _JobsHeader({required this.isWeb, required this.jobCount});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        isWeb ? 32 : 20,
        isWeb ? 32 : 56,
        isWeb ? 32 : 20,
        isWeb ? 24 : 20,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF0D0B1E),
        border: Border(
          bottom: BorderSide(color: Colors.white.withOpacity(0.06), width: 0.5),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Saved Jobs',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFEEEDFE),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$jobCount job${jobCount == 1 ? '' : 's'} saved',
                style: const TextStyle(fontSize: 13, color: Color(0xFF6B7089)),
              ),
            ],
          ),
          Row(
            children: [
              // Add job button
              GestureDetector(
                onTap: () => context.push('/job/input'),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isWeb ? 18 : 14,
                    vertical: 10,
                  ),
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
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.add_rounded,
                          color: Colors.white, size: 16),
                      if (isWeb) ...[
                        const SizedBox(width: 6),
                        const Text(
                          'Add Job',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
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
        ],
      ),
    );
  }
}

// ─── Web Grid ─────────────────────────────────────────────────────────────────

class _WebGrid extends StatelessWidget {
  final List jobs;
  const _WebGrid({required this.jobs});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(32),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.4,
      ),
      itemCount: jobs.length,
      itemBuilder: (context, index) {
        return _PremiumJobCard(job: jobs[index], isGrid: true);
      },
    );
  }
}

// ─── Mobile List ──────────────────────────────────────────────────────────────

class _MobileList extends StatelessWidget {
  final List jobs;
  const _MobileList({required this.jobs});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      itemCount: jobs.length,
      itemBuilder: (context, index) {
        final job = jobs[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Dismissible(
            key: Key(job.id),
            direction: DismissDirection.endToStart,
            confirmDismiss: (_) => _showDeleteDialog(context),
            onDismissed: (_) => context.read<JobCubit>().deleteJob(job.id),
            background: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFE24B4A).withOpacity(0.12),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                    color: const Color(0xFFE24B4A).withOpacity(0.3),
                    width: 0.5),
              ),
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(Icons.delete_outline_rounded,
                      color: Color(0xFFE24B4A), size: 20),
                  SizedBox(width: 6),
                  Text('Delete',
                      style: TextStyle(
                          color: Color(0xFFE24B4A),
                          fontSize: 13,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            child: _PremiumJobCard(job: job, isGrid: false),
          ),
        );
      },
    );
  }
}

// ─── Premium Job Card ─────────────────────────────────────────────────────────

class _PremiumJobCard extends StatelessWidget {
  final dynamic job;
  final bool isGrid;

  const _PremiumJobCard({required this.job, required this.isGrid});

  String _preview(String raw) {
    final first = raw.split('\n').first;
    return first.length > 80 ? '${first.substring(0, 80)}...' : first;
  }

  // Derive a color from job title initial for variety
  Color _accentColor(String? title) {
    final colors = [
      const Color(0xFF534AB7),
      const Color(0xFF1D9E75),
      const Color(0xFF378ADD),
      const Color(0xFFEF9F27),
      const Color(0xFFD4537E),
    ];
    if (title == null || title.isEmpty) return colors[0];
    return colors[title.codeUnitAt(0) % colors.length];
  }

  String _initials(String? title) {
    if (title == null || title.isEmpty) return 'J';
    final words = title.trim().split(' ');
    if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    }
    return words[0][0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final accent = _accentColor(job.jobTitle);
    final initials = _initials(job.jobTitle);
    final dateStr = DateFormat('MMM d, yyyy').format(job.createdAt);

    return GestureDetector(
      onTap: () => _showJobDetailSheet(context, job),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withOpacity(0.07), width: 0.5),
        ),
        child: isGrid
            ? _GridContent(
                job: job,
                accent: accent,
                initials: initials,
                dateStr: dateStr,
                preview: _preview(job.rawText),
                onDelete: () => _confirmDelete(context, job),
              )
            : _ListContent(
                job: job,
                accent: accent,
                initials: initials,
                dateStr: dateStr,
                preview: _preview(job.rawText),
                onOptions: () => _showOptionsSheet(context, job),
              ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, dynamic job) {
    _showDeleteDialog(context).then((confirmed) {
      if (confirmed == true) {
        context.read<JobCubit>().deleteJob(job.id);
      }
    });
  }
}

// ─── Grid Card Content ────────────────────────────────────────────────────────

class _GridContent extends StatelessWidget {
  final dynamic job;
  final Color accent;
  final String initials;
  final String dateStr;
  final String preview;
  final VoidCallback onDelete;

  const _GridContent({
    required this.job,
    required this.accent,
    required this.initials,
    required this.dateStr,
    required this.preview,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Avatar
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: accent.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  initials,
                  style: TextStyle(
                    color: accent,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: onDelete,
              child: const Icon(Icons.delete_outline_rounded,
                  color: Color(0xFF4A4E6A), size: 18),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          job.jobTitle ?? 'Untitled Job',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFFEEEDFE),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          preview,
          style: const TextStyle(fontSize: 11, color: Color(0xFF6B7089)),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const Spacer(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.calendar_today_outlined,
                    size: 10, color: Color(0xFF4A4E6A)),
                const SizedBox(width: 4),
                Text(
                  dateStr,
                  style:
                      const TextStyle(fontSize: 10, color: Color(0xFF4A4E6A)),
                ),
              ],
            ),
            if (job.sourceUrl != null && job.sourceUrl!.isNotEmpty)
              GestureDetector(
                onTap: () => launchUrl(Uri.parse(job.sourceUrl!)),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF378ADD).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.link_rounded,
                          color: Color(0xFF378ADD), size: 10),
                      SizedBox(width: 4),
                      Text('Link',
                          style: TextStyle(
                              color: Color(0xFF378ADD),
                              fontSize: 10,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

// ─── List Card Content ────────────────────────────────────────────────────────

class _ListContent extends StatelessWidget {
  final dynamic job;
  final Color accent;
  final String initials;
  final String dateStr;
  final String preview;
  final VoidCallback onOptions;

  const _ListContent({
    required this.job,
    required this.accent,
    required this.initials,
    required this.dateStr,
    required this.preview,
    required this.onOptions,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Avatar
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: accent.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              initials,
              style: TextStyle(
                color: accent,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),
        // Info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                job.jobTitle ?? 'Untitled Job',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFEEEDFE),
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 5),
              Text(
                preview,
                style: const TextStyle(
                    fontSize: 12, color: Color(0xFF6B7089), height: 1.4),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.calendar_today_outlined,
                      size: 10, color: Color(0xFF4A4E6A)),
                  const SizedBox(width: 4),
                  Text(
                    'Added $dateStr',
                    style:
                        const TextStyle(fontSize: 11, color: Color(0xFF4A4E6A)),
                  ),
                  if (job.sourceUrl != null && job.sourceUrl!.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => launchUrl(Uri.parse(job.sourceUrl!)),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF378ADD).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.link_rounded,
                                color: Color(0xFF378ADD), size: 10),
                            SizedBox(width: 4),
                            Text('Link',
                                style: TextStyle(
                                    color: Color(0xFF378ADD),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
        // Options
        GestureDetector(
          onTap: onOptions,
          child: const Padding(
            padding: EdgeInsets.all(4),
            child: Icon(Icons.more_vert_rounded,
                color: Color(0xFF4A4E6A), size: 18),
          ),
        ),
      ],
    );
  }
}

// ─── Job Detail Sheet ─────────────────────────────────────────────────────────

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
                Divider(color: Colors.white.withOpacity(0.07), thickness: 0.5),
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
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/analysis', extra: job);
                    },
                    child: Container(
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
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    _showDeleteDialog(context).then((confirmed) {
                      if (confirmed == true && context.mounted) {
                        context.read<JobCubit>().deleteJob(job.id);
                      }
                    });
                  },
                  child: Container(
                    height: 46,
                    width: 46,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE24B4A).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: const Color(0xFFE24B4A).withOpacity(0.3),
                          width: 0.5),
                    ),
                    child: const Icon(Icons.delete_outline_rounded,
                        color: Color(0xFFE24B4A), size: 18),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

// ─── Options Sheet ────────────────────────────────────────────────────────────

void _showOptionsSheet(BuildContext context, dynamic job) {
  showModalBottomSheet(
    context: context,
    backgroundColor: const Color(0xFF13112A),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF534AB7).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.work_outline_rounded,
                    color: Color(0xFF8B82D4), size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  job.jobTitle ?? 'Untitled Job',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFEEEDFE),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(color: Colors.white.withOpacity(0.07), thickness: 0.5),
          const SizedBox(height: 8),
          _SheetAction(
            icon: Icons.open_in_new_rounded,
            label: 'View Details',
            color: const Color(0xFF534AB7),
            onTap: () {
              Navigator.pop(context);
              _showJobDetailSheet(context, job);
            },
          ),
          _SheetAction(
            icon: Icons.insights_rounded,
            label: 'Run Analysis',
            color: const Color(0xFF1D9E75),
            onTap: () {
              Navigator.pop(context);
              context.push('/analysis', extra: job);
            },
          ),
          if (job.sourceUrl != null && job.sourceUrl!.isNotEmpty)
            _SheetAction(
              icon: Icons.link_rounded,
              label: 'Open Source URL',
              color: const Color(0xFF378ADD),
              onTap: () {
                Navigator.pop(context);
                launchUrl(Uri.parse(job.sourceUrl!));
              },
            ),
          _SheetAction(
            icon: Icons.delete_outline_rounded,
            label: 'Delete',
            color: const Color(0xFFE24B4A),
            onTap: () {
              Navigator.pop(context);
              _showDeleteDialog(context).then((confirmed) {
                if (confirmed == true && context.mounted) {
                  context.read<JobCubit>().deleteJob(job.id);
                }
              });
            },
          ),
        ],
      ),
    ),
  );
}

// ─── Delete Dialog ────────────────────────────────────────────────────────────

Future<bool?> _showDeleteDialog(BuildContext context) {
  return showDialog<bool>(
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
            const Text(
              'Delete Job?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFFEEEDFE),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'This job listing will be permanently removed from your saved jobs.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 13, color: Color(0xFF6B7089), height: 1.5),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.of(ctx).pop(false),
                    child: Container(
                      height: 44,
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
                    onTap: () => Navigator.of(ctx).pop(true),
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

// ─── Empty State ──────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
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
            child: const Icon(Icons.work_outline_rounded,
                color: Color(0xFF534AB7), size: 36),
          ),
          const SizedBox(height: 20),
          const Text(
            'No saved jobs yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFFEEEDFE),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add a job listing to start tracking\nand analyzing your applications.',
            textAlign: TextAlign.center,
            style:
                TextStyle(fontSize: 13, color: Color(0xFF6B7089), height: 1.6),
          ),
          const SizedBox(height: 28),
          GestureDetector(
            onTap: () => context.push('/job/input'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 13),
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
                  Icon(Icons.add_rounded, color: Colors.white, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Add your first job',
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
    );
  }
}

// ─── Sheet Action ─────────────────────────────────────────────────────────────

class _SheetAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _SheetAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
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
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: label == 'Delete'
                    ? const Color(0xFFE24B4A)
                    : const Color(0xFFEEEDFE),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
