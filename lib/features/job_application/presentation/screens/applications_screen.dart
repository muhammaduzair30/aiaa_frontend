import 'package:aiaa/features/cv/presentation/cubit/cv_cubit.dart';
import 'package:aiaa/features/job/presentation/cubit/job_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/constants/app_constants.dart';
import '../cubit/job_application_cubit.dart';
import '../widgets/application_card.dart';
import '../../domain/entities/job_application_entity.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';

class ApplicationsScreen extends StatelessWidget {
  const ApplicationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _ApplicationsScreenView();
  }
}

class _ApplicationsScreenView extends StatefulWidget {
  const _ApplicationsScreenView();

  @override
  State<_ApplicationsScreenView> createState() =>
      _ApplicationsScreenViewState();
}

class _ApplicationsScreenViewState extends State<_ApplicationsScreenView> {
  int _activeFilter = 0;
  final List<String> _filters = ['All', ...AppConstants.statusValues];

  @override
  void initState() {
    super.initState();
    context.read<JobApplicationCubit>().loadApplications();
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

  void _showCreateBottomSheet() {
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
              bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
            ),
            child: const _CreateApplicationSheet(),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWeb = MediaQuery.of(context).size.width > 768;

    return Scaffold(
      backgroundColor: const Color(0xFF0D0B1E),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(isWeb),
            _buildFilterChips(),
            Expanded(
              child: BlocConsumer<JobApplicationCubit, JobApplicationState>(
                listener: (context, state) {
                  if (state is JobApplicationError) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(state.message,
                          style: const TextStyle(color: Color(0xFFEEEDFE))),
                      backgroundColor: const Color(0xFF1A1730),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ));
                  } else if (state is JobApplicationCreated) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: const Row(children: [
                        Icon(Icons.check_circle_outline,
                            color: Color(0xFF1D9E75), size: 16),
                        SizedBox(width: 8),
                        Text('Application added',
                            style: TextStyle(color: Color(0xFFEEEDFE))),
                      ]),
                      backgroundColor: const Color(0xFF1A1730),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ));
                  } else if (state is JobApplicationUpdated) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: const Row(children: [
                        Icon(Icons.check_circle_outline,
                            color: Color(0xFF1D9E75), size: 16),
                        SizedBox(width: 8),
                        Text('Application updated',
                            style: TextStyle(color: Color(0xFFEEEDFE))),
                      ]),
                      backgroundColor: const Color(0xFF1A1730),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ));
                  } else if (state is JobApplicationDeleted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: const Row(children: [
                        Icon(Icons.check_circle_outline,
                            color: Color(0xFFE24B4A), size: 16),
                        SizedBox(width: 8),
                        Text('Application deleted',
                            style: TextStyle(color: Color(0xFFEEEDFE))),
                      ]),
                      backgroundColor: const Color(0xFF1A1730),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ));
                  }
                },
                buildWhen: (previous, current) {
                  return current is JobApplicationLoading ||
                      current is JobApplicationLoaded ||
                      (current is JobApplicationError &&
                          previous is! JobApplicationLoaded);
                },
                builder: (context, state) {
                  if (state is JobApplicationLoading) {
                    return const Center(
                        child: CircularProgressIndicator(
                            color: Color(0xFF534AB7)));
                  }
                  if (state is JobApplicationLoaded) {
                    final statusTab = _filters[_activeFilter];
                    List<JobApplicationEntity> filtered = state.applications;
                    if (statusTab != 'All') {
                      filtered = state.applications
                          .where((a) => a.status == statusTab)
                          .toList();
                    }
                    if (filtered.isEmpty) return const _EmptyState();
                    return RefreshIndicator(
                      color: const Color(0xFF534AB7),
                      backgroundColor: const Color(0xFF13112A),
                      onRefresh: () => context
                          .read<JobApplicationCubit>()
                          .loadApplications(),
                      child: isWeb
                          ? _buildWebGrid(filtered)
                          : _buildMobileList(filtered),
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

  Widget _buildHeader(bool isWeb) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        isWeb ? 32 : 20,
        isWeb ? 32 : 20,
        isWeb ? 32 : 20,
        isWeb ? 20 : 16,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF0D0B1E),
        border: Border(
            bottom:
                BorderSide(color: Colors.white.withOpacity(0.06), width: 0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Applications',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFEEEDFE),
                      letterSpacing: -0.5,
                    )),
                const SizedBox(height: 4),
                BlocBuilder<JobApplicationCubit, JobApplicationState>(
                  builder: (context, state) {
                    final count = state is JobApplicationLoaded
                        ? state.applications.length
                        : 0;
                    return Text(
                      '$count application${count == 1 ? '' : 's'} tracked',
                      style: const TextStyle(
                          fontSize: 13, color: Color(0xFF6B7089)),
                    );
                  },
                ),
              ],
            ),
          ),
          Row(
            children: [
              GestureDetector(
                onTap: _showCreateBottomSheet,
                child: Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: isWeb ? 18 : 14, vertical: 10),
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
                          offset: const Offset(0, 4)),
                    ],
                  ),
                  child: Row(children: [
                    const Icon(Icons.add_rounded, color: Colors.white, size: 16),
                    if (isWeb) ...[
                      const SizedBox(width: 6),
                      const Text('New Application',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600)),
                    ],
                  ]),
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
                      border:
                          Border.all(color: Colors.white.withOpacity(0.08), width: 0.5),
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

  // ─── Filter Chips ───────────────────────────────────────────────────────────

  Widget _buildFilterChips() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(_filters.length, (i) {
            final isActive = _activeFilter == i;
            final label = _filters[i];
            final color =
                label == 'All' ? const Color(0xFF534AB7) : _statusColor(label);
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => setState(() => _activeFilter = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isActive
                        ? color.withOpacity(0.15)
                        : Colors.white.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isActive
                          ? color.withOpacity(0.4)
                          : Colors.white.withOpacity(0.07),
                      width: isActive ? 1 : 0.5,
                    ),
                  ),
                  child: Text(
                    label[0].toUpperCase() + label.substring(1),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                      color: isActive ? color : const Color(0xFF6B7089),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  // ─── Web Grid ───────────────────────────────────────────────────────────────

  Widget _buildWebGrid(List<JobApplicationEntity> apps) {
    return GridView.builder(
      padding: const EdgeInsets.all(32),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.5,
      ),
      itemCount: apps.length,
      itemBuilder: (context, index) {
        final app = apps[index];
        return GestureDetector(
          onTap: () async {
            final result =
                await context.push('/application/${app.id}', extra: app);
            if (result == true && context.mounted) {
              context.read<JobApplicationCubit>().loadApplications();
            }
          },
          child: ApplicationCard(application: app, isGrid: true),
        );
      },
    );
  }

  // ─── Mobile List ────────────────────────────────────────────────────────────

  Widget _buildMobileList(List<JobApplicationEntity> apps) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
      itemCount: apps.length,
      itemBuilder: (context, index) {
        final app = apps[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GestureDetector(
            onTap: () async {
              final result =
                  await context.push('/application/${app.id}', extra: app);
              if (result == true && context.mounted) {
                context.read<JobApplicationCubit>().loadApplications();
              }
            },
            child: ApplicationCard(application: app),
          ),
        );
      },
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
              child: const Icon(Icons.work_outline_rounded,
                  color: Color(0xFF534AB7), size: 36),
            ),
            const SizedBox(height: 20),
            const Text('No applications yet',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFEEEDFE),
                )),
            const SizedBox(height: 8),
            const Text(
              'Track your job applications by adding\nyour first one above.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 13, color: Color(0xFF6B7089), height: 1.6),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Create Application Bottom Sheet ──────────────────────────────────────────

class _CreateApplicationSheet extends StatefulWidget {
  const _CreateApplicationSheet();

  @override
  State<_CreateApplicationSheet> createState() =>
      _CreateApplicationSheetState();
}

class _CreateApplicationSheetState extends State<_CreateApplicationSheet> {
  String? _selectedCvId;
  String? _selectedJobId;
  String _selectedStatus = 'saved';
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
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
    final cvState = context.watch<CVCubit>().state;
    final jobState = context.watch<JobCubit>().state;

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
          const Text('New Application',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFFEEEDFE),
                letterSpacing: -0.4,
              )),
          const SizedBox(height: 4),
          const Text('Track a new job application',
              style: TextStyle(fontSize: 13, color: Color(0xFF6B7089))),
          const SizedBox(height: 24),

          // CV Selector
          _buildFieldLabel('Select CV'),
          const SizedBox(height: 8),
          if (cvState is CVLoaded)
            ..._buildSelectorList(
              items: cvState.cvs
                  .map((cv) => _SelectorItem(
                      id: cv.id,
                      label: cv.originalFilename,
                      icon: Icons.description_outlined))
                  .toList(),
              selectedId: _selectedCvId,
              onSelect: (id) => setState(() => _selectedCvId = id),
              color: const Color(0xFF534AB7),
            )
          else
            _buildLoadingField(),
          const SizedBox(height: 20),

          // Job Selector
          _buildFieldLabel('Select Job'),
          const SizedBox(height: 8),
          if (jobState is JobLoaded)
            ..._buildSelectorList(
              items: jobState.jobs
                  .map((j) => _SelectorItem(
                      id: j.id,
                      label: j.jobTitle ?? 'Untitled Job',
                      icon: Icons.work_outline_rounded))
                  .toList(),
              selectedId: _selectedJobId,
              onSelect: (id) => setState(() => _selectedJobId = id),
              color: const Color(0xFF1D9E75),
            )
          else
            _buildLoadingField(),
          const SizedBox(height: 20),

          // Status
          _buildFieldLabel('Status'),
          const SizedBox(height: 10),
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

          // Notes
          _buildFieldLabel('Notes (optional)'),
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
              style: const TextStyle(
                  color: Color(0xFFEEEDFE), fontSize: 14, height: 1.5),
              decoration: const InputDecoration(
                hintText: 'Add any notes about this application...',
                hintStyle: TextStyle(color: Color(0xFF4A4E6A), fontSize: 13),
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(16),
                filled: true,
                fillColor: Colors.transparent,
              ),
            ),
          ),
          const SizedBox(height: 28),

          // Buttons
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
                              color: Color(0xFFAAAABB),
                            ))),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    if (_selectedCvId != null && _selectedJobId != null) {
                      context.read<JobApplicationCubit>().createApplication(
                            _selectedCvId!,
                            _selectedJobId!,
                            null,
                            _selectedStatus,
                            _notesController.text,
                          );
                      Navigator.pop(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: const Text('Please select CV and Job',
                            style: TextStyle(color: Color(0xFFEEEDFE))),
                        backgroundColor: const Color(0xFF1A1730),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ));
                    }
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
                            blurRadius: 16,
                            offset: const Offset(0, 4)),
                      ],
                    ),
                    child: const Center(
                        child: Text('Save',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ))),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label.toUpperCase(),
      style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
          color: Color(0xFF6B7089)),
    );
  }

  Widget _buildLoadingField() {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.08), width: 0.5),
      ),
      child: const Center(
          child: SizedBox(
        width: 18,
        height: 18,
        child:
            CircularProgressIndicator(color: Color(0xFF534AB7), strokeWidth: 2),
      )),
    );
  }

  List<Widget> _buildSelectorList({
    required List<_SelectorItem> items,
    required String? selectedId,
    required ValueChanged<String> onSelect,
    required Color color,
  }) {
    if (items.isEmpty) {
      return [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFEF9F27).withOpacity(0.06),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: const Color(0xFFEF9F27).withOpacity(0.2), width: 0.5),
          ),
          child: const Text('No items available',
              style: TextStyle(fontSize: 13, color: Color(0xFFEF9F27))),
        ),
      ];
    }
    return items.map((item) {
      final isSelected = selectedId == item.id;
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: GestureDetector(
          onTap: () => onSelect(item.id),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected
                  ? color.withOpacity(0.12)
                  : Colors.white.withOpacity(0.04),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? color.withOpacity(0.5)
                    : Colors.white.withOpacity(0.08),
                width: isSelected ? 1 : 0.5,
              ),
            ),
            child: Row(children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: isSelected
                      ? color.withOpacity(0.2)
                      : Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(item.icon,
                    color: isSelected ? color : const Color(0xFF4A4E6A),
                    size: 16),
              ),
              const SizedBox(width: 10),
              Expanded(
                  child: Text(
                item.label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected
                      ? const Color(0xFFEEEDFE)
                      : const Color(0xFFAAAABB),
                ),
                overflow: TextOverflow.ellipsis,
              )),
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? color : Colors.transparent,
                  border: Border.all(
                      color: isSelected ? color : Colors.white.withOpacity(0.2),
                      width: 1.5),
                ),
                child: isSelected
                    ? const Icon(Icons.check_rounded,
                        color: Colors.white, size: 10)
                    : null,
              ),
            ]),
          ),
        ),
      );
    }).toList();
  }
}

class _SelectorItem {
  final String id;
  final String label;
  final IconData icon;
  const _SelectorItem(
      {required this.id, required this.label, required this.icon});
}
