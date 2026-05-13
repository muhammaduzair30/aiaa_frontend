import 'package:aiaa/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/di/injection.dart';
import '../cubit/cv_cubit.dart';
import '../widgets/cv_card.dart';
import '../../domain/entities/cv_entity.dart';

class CVListScreen extends StatelessWidget {
  const CVListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _CVListScreenView();
  }
}

class _CVListScreenView extends StatefulWidget {
  const _CVListScreenView();

  @override
  State<_CVListScreenView> createState() => _CVListScreenViewState();
}

class _CVListScreenViewState extends State<_CVListScreenView> {
  @override
  void initState() {
    super.initState();
    context.read<CVCubit>().loadCVs();
  }

  @override
  Widget build(BuildContext context) {
    final isWeb = MediaQuery.of(context).size.width > 768;

    return Container(
      color: const Color(0xFF0D0B1E),
      child: BlocConsumer<CVCubit, CVState>(
        listener: (context, state) {
          if (state is CVError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: const Color(0xFF1A1730),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            );
          } else if (state is CVUploadSuccess) {
            context.read<CVCubit>().loadCVs();
          } else if (state is CVDownloadUrlReady) {
            launchUrl(Uri.parse(state.url),
                mode: LaunchMode.externalApplication);
          }
        },
        buildWhen: (previous, current) =>
            current is CVLoading ||
            current is CVLoaded ||
            current is CVError && previous is! CVLoaded,
        builder: (context, state) {
          return Column(
            children: [
              // ── Header ──────────────────────────────────────────────
              _CVHeader(isWeb: isWeb),

              // ── Body ────────────────────────────────────────────────
              Expanded(
                child: () {
                  if (state is CVLoading) {
                    return const Center(
                      child:
                          CircularProgressIndicator(color: Color(0xFF534AB7)),
                    );
                  }

                  if (state is CVLoaded) {
                    if (state.cvs.isEmpty) return const _EmptyState();

                    return isWeb
                        ? _WebGrid(cvs: state.cvs)
                        : _MobileList(cvs: state.cvs);
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

class _CVHeader extends StatelessWidget {
  final bool isWeb;
  const _CVHeader({required this.isWeb});

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
                'My CVs',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFEEEDFE),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              BlocBuilder<CVCubit, CVState>(
                builder: (context, state) {
                  final count = state is CVLoaded ? state.cvs.length : 0;
                  return Text(
                    '$count document${count == 1 ? '' : 's'} uploaded',
                    style:
                        const TextStyle(fontSize: 13, color: Color(0xFF6B7089)),
                  );
                },
              ),
            ],
          ),
          Row(
            children: [
              // Upload button
              GestureDetector(
                onTap: () => context.push('/cv/upload'),
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
                    children: [
                      const Icon(Icons.add_rounded,
                          color: Colors.white, size: 16),
                      if (isWeb) ...[
                        const SizedBox(width: 6),
                        const Text(
                          'Upload CV',
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

// ─── Web Grid Layout ──────────────────────────────────────────────────────────

class _WebGrid extends StatelessWidget {
  final List cvs;
  const _WebGrid({required this.cvs});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(32),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.5,
      ),
      itemCount: cvs.length,
      itemBuilder: (context, index) {
        final cv = cvs[index];
        return _PremiumCVCard(cv: cv, isGrid: true);
      },
    );
  }
}

// ─── Mobile List Layout ───────────────────────────────────────────────────────

class _MobileList extends StatelessWidget {
  final List cvs;
  const _MobileList({required this.cvs});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      itemCount: cvs.length,
      itemBuilder: (context, index) {
        final cv = cvs[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Dismissible(
            key: Key(cv.id),
            direction: DismissDirection.endToStart,
            confirmDismiss: (direction) async {
              return await _showDeleteDialog(context);
            },
            onDismissed: (direction) {
              context.read<CVCubit>().deleteCV(cv.id);
            },
            background: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFE24B4A).withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
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
            child: _PremiumCVCard(cv: cv, isGrid: false),
          ),
        );
      },
    );
  }
}

// ─── Premium CV Card ──────────────────────────────────────────────────────────

class _PremiumCVCard extends StatelessWidget {
  final CVEntity cv;
  final bool isGrid;

  const _PremiumCVCard({required this.cv, required this.isGrid});

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showOptionsSheet(context, cv),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withOpacity(0.08), width: 0.5),
        ),
        child: isGrid
            ? _GridCardContent(cv: cv, formatDate: _formatDate)
            : _ListCardContent(
                cv: cv, formatDate: _formatDate, context: context),
      ),
    );
  }
}

class _GridCardContent extends StatelessWidget {
  final CVEntity cv;
  final String Function(DateTime?) formatDate;

  const _GridCardContent({
    required this.cv,
    required this.formatDate,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF534AB7).withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.description_outlined,
                  color: Color(0xFF8B82D4), size: 20),
            ),
            // Options menu
            GestureDetector(
              onTap: () => _showOptionsSheet(context, cv),
              child: const Icon(Icons.more_horiz_rounded,
                  color: Color(0xFF4A4E6A), size: 18),
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              cv.originalFilename ?? 'Untitled CV',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFFEEEDFE),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  formatDate(cv.createdAt),
                  style:
                      const TextStyle(fontSize: 11, color: Color(0xFF6B7089)),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class _ListCardContent extends StatelessWidget {
  final CVEntity cv;
  final String Function(DateTime?) formatDate;
  final BuildContext context;

  const _ListCardContent({
    required this.cv,
    required this.formatDate,
    required this.context,
  });

  @override
  Widget build(BuildContext _) {
    return Row(
      children: [
        // File icon
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFF534AB7).withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.description_outlined,
              color: Color(0xFF8B82D4), size: 22),
        ),
        const SizedBox(width: 14),
        // Name + meta
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
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.calendar_today_outlined,
                      size: 10, color: Color(0xFF6B7089)),
                  const SizedBox(width: 4),
                  Text(
                    formatDate(cv.createdAt),
                    style:
                        const TextStyle(fontSize: 11, color: Color(0xFF6B7089)),
                  ),
                ],
              ),
            ],
          ),
        ),
        // Options
        GestureDetector(
          onTap: () => _showOptionsSheet(context, cv),
          child: Container(
            padding: const EdgeInsets.all(8),
            child: const Icon(Icons.more_vert_rounded,
                color: Color(0xFF4A4E6A), size: 18),
          ),
        ),
      ],
    );
  }
}

// ─── Options Bottom Sheet ─────────────────────────────────────────────────────

void _showOptionsSheet(BuildContext context, CVEntity cv) {
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
                  child: Text(
                    cv.originalFilename ?? 'Untitled CV',
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
            const SizedBox(height: 20),
            Divider(color: Colors.white.withOpacity(0.07), thickness: 0.5),
            const SizedBox(height: 8),
            // Actions
            _SheetAction(
              icon: Icons.insights_outlined,
              label: 'Run Analysis',
              color: const Color(0xFF534AB7),
              onTap: () {
                Navigator.pop(context);
                context.push('/analysis', extra: cv);
              },
            ),
            _SheetAction(
              icon: Icons.visibility_outlined,
              label: 'View',
              color: const Color(0xFF378ADD),
              onTap: () {
                Navigator.pop(context);
                context.read<CVCubit>().getDownloadUrl(cv.id);
              },
            ),
            _SheetAction(
              icon: Icons.download_outlined,
              label: 'Download',
              color: const Color(0xFF1D9E75),
              onTap: () {
                Navigator.pop(context);
                context.read<CVCubit>().getDownloadUrl(cv.id);
              },
            ),
            _SheetAction(
              icon: Icons.delete_outline_rounded,
              label: 'Delete',
              color: const Color(0xFFE24B4A),
              onTap: () {
                Navigator.pop(context);
                _showDeleteDialog(context).then((confirmed) {
                  if (confirmed == true) {
                    context.read<CVCubit>().deleteCV(cv.id);
                  }
                });
              },
            ),
          ],
        ),
      ),
    ),
  );
}

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
              'Delete CV?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFFEEEDFE),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'This action cannot be undone. The CV and all associated analyses will be permanently removed.',
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
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFFAAAABB)),
                        ),
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
                        child: Text(
                          'Delete',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFE24B4A),
                          ),
                        ),
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
            child: const Icon(Icons.description_outlined,
                color: Color(0xFF534AB7), size: 36),
          ),
          const SizedBox(height: 20),
          const Text(
            'No CVs yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFFEEEDFE),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Upload your first CV to get started\nwith AI-powered job matching.',
            textAlign: TextAlign.center,
            style:
                TextStyle(fontSize: 13, color: Color(0xFF6B7089), height: 1.6),
          ),
          const SizedBox(height: 28),
          GestureDetector(
            onTap: () => context.push('/cv/upload'),
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
                  Icon(Icons.upload_file_rounded,
                      color: Colors.white, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Upload your first CV',
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
