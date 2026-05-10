import 'package:aiaa/features/analysis/presentation/screens/analysis_screen.dart';
import 'package:aiaa/features/cv/presentation/screens/cv_list_screen.dart';
import 'package:aiaa/features/job_application/presentation/screens/applications_screen.dart';
import 'package:aiaa/features/job/presentation/screens/jobs_list_screen.dart';
import 'package:aiaa/features/job_application/presentation/cubit/job_application_cubit.dart';
import 'package:aiaa/features/analysis/presentation/cubit/analysis_cubit.dart';
import 'package:aiaa/features/cv/presentation/cubit/cv_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection.dart';
import 'package:aiaa/features/auth/presentation/bloc/auth_bloc.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _tabs = const [
    _HomeTab(),
    CVListScreen(),
    JobsListScreen(),
    AnalysisScreen(),
    ApplicationsScreen(),
  ];

  // Nav items config
  static const _navItems = [
    (icon: Icons.grid_view_rounded, label: 'Home'),
    (icon: Icons.description_outlined, label: 'CVs'),
    (icon: Icons.work_outline_rounded, label: 'Jobs'),
    (icon: Icons.insights_rounded, label: 'Analysis'),
    (icon: Icons.send_outlined, label: 'Applications'),
  ];

  @override
  Widget build(BuildContext context) {
    final isWeb = MediaQuery.of(context).size.width > 768;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          context.go('/login');
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF0D0B1E),
        body: isWeb
            ? Row(
                children: [
                  _WebSidebar(
                    currentIndex: _currentIndex,
                    onTap: (i) => setState(() => _currentIndex = i),
                    navItems: _navItems,
                  ),
                  Expanded(child: _tabs[_currentIndex]),
                ],
              )
            : _tabs[_currentIndex],
        bottomNavigationBar: isWeb
            ? null
            : _MobileNavBar(
                currentIndex: _currentIndex,
                onTap: (i) => setState(() => _currentIndex = i),
                navItems: _navItems,
              ),
      ),
    );
  }
}

// ─── Web Sidebar ──────────────────────────────────────────────────────────────

class _WebSidebar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<({IconData icon, String label})> navItems;

  const _WebSidebar({
    required this.currentIndex,
    required this.onTap,
    required this.navItems,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      height: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF100E1F),
        border: Border(
          right: BorderSide(color: Colors.white.withOpacity(0.06), width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 32, 20, 32),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6C63E0), Color(0xFF534AB7)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF534AB7).withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.auto_awesome,
                      color: Colors.white, size: 18),
                ),
                const SizedBox(width: 10),
                const Text(
                  'AIAA',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFEEEDFE),
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
          // Nav items
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                children: List.generate(navItems.length, (i) {
                  final item = navItems[i];
                  final isActive = i == currentIndex;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: GestureDetector(
                      onTap: () => onTap(i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: isActive
                              ? const Color(0xFF534AB7).withOpacity(0.18)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isActive
                                ? const Color(0xFF534AB7).withOpacity(0.35)
                                : Colors.transparent,
                            width: 0.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              item.icon,
                              size: 18,
                              color: isActive
                                  ? const Color(0xFF8B82D4)
                                  : const Color(0xFF4A4E6A),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              item.label,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: isActive
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                                color: isActive
                                    ? const Color(0xFFEEEDFE)
                                    : const Color(0xFF4A4E6A),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
          // Bottom user section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.04),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: Colors.white.withOpacity(0.07), width: 0.5),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF534AB7), Color(0xFF1D9E75)],
                      ),
                    ),
                    child: const Center(
                      child: Text('U',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('My Account',
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFEEEDFE))),
                        Text('Pro',
                            style: TextStyle(
                                fontSize: 10, color: Color(0xFF6B7089))),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      context.read<AuthBloc>().add(AuthLogoutRequested());
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.logout_rounded,
                          size: 16, color: Color(0xFF4A4E6A)),
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

// ─── Mobile Bottom Nav ────────────────────────────────────────────────────────

class _MobileNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<({IconData icon, String label})> navItems;

  const _MobileNavBar({
    required this.currentIndex,
    required this.onTap,
    required this.navItems,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF100E1F),
        border: Border(
          top: BorderSide(color: Colors.white.withOpacity(0.06), width: 0.5),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(navItems.length, (i) {
              final item = navItems[i];
              final isActive = i == currentIndex;
              return GestureDetector(
                onTap: () => onTap(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isActive
                        ? const Color(0xFF534AB7).withOpacity(0.18)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        item.icon,
                        size: 20,
                        color: isActive
                            ? const Color(0xFF8B82D4)
                            : const Color(0xFF4A4E6A),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.label,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight:
                              isActive ? FontWeight.w600 : FontWeight.w400,
                          color: isActive
                              ? const Color(0xFF8B82D4)
                              : const Color(0xFF4A4E6A),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

// ─── Home Tab ─────────────────────────────────────────────────────────────────

class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
            create: (_) => sl<JobApplicationCubit>()..loadApplications()),
        BlocProvider(create: (_) => sl<AnalysisCubit>()..loadHistory()),
        BlocProvider(create: (_) => sl<CVCubit>()..loadCVs()),
      ],
      child: const _HomeTabView(),
    );
  }
}

// ─── Home Tab View ────────────────────────────────────────────────────────────

class _HomeTabView extends StatelessWidget {
  const _HomeTabView();

  @override
  Widget build(BuildContext context) {
    final isWeb = MediaQuery.of(context).size.width > 768;

    return Container(
      color: const Color(0xFF0D0B1E),
      child: BlocBuilder<JobApplicationCubit, JobApplicationState>(
        builder: (context, state) {
          int total = 0, saved = 0, applied = 0, interview = 0, offer = 0;

          if (state is JobApplicationLoaded) {
            total = state.applications.length;
            for (var app in state.applications) {
              switch (app.status.toLowerCase()) {
                case 'saved':
                  saved++;
                  break;
                case 'applied':
                  applied++;
                  break;
                case 'interview':
                  interview++;
                  break;
                case 'offer':
                  offer++;
                  break;
              }
            }
          }

          final isLoading = state is JobApplicationLoading;

          return SingleChildScrollView(
            padding: EdgeInsets.all(isWeb ? 32 : 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                _DashboardHeader(isWeb: isWeb),
                SizedBox(height: isWeb ? 32 : 24),

                // Stats row
                _StatsRow(
                  total: total,
                  saved: saved,
                  applied: applied,
                  interview: interview,
                  offer: offer,
                  isLoading: isLoading,
                  isWeb: isWeb,
                ),
                SizedBox(height: isWeb ? 32 : 24),

                // Quick actions
                _SectionHeader(title: 'Quick Actions'),
                const SizedBox(height: 12),
                _QuickActions(isWeb: isWeb),
                SizedBox(height: isWeb ? 32 : 24),

                // Recent analyses
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _SectionHeader(title: 'Recent Analyses'),
                    GestureDetector(
                      onTap: () => context.push('/analysis/history'),
                      child: const Text(
                        'View all →',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF7C74E0),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _RecentAnalyses(isWeb: isWeb),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ─── Dashboard Header ─────────────────────────────────────────────────────────

class _DashboardHeader extends StatelessWidget {
  final bool isWeb;
  const _DashboardHeader({required this.isWeb});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Good morning 👋',
              style: TextStyle(
                fontSize: isWeb ? 28 : 22,
                fontWeight: FontWeight.w700,
                color: const Color(0xFFEEEDFE),
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              "Here's your job hunt overview",
              style: TextStyle(fontSize: 13, color: Color(0xFF6B7089)),
            ),
          ],
        ),
        Row(
          children: [
            // Notification bell
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border:
                    Border.all(color: Colors.white.withOpacity(0.08), width: 0.5),
              ),
              child: const Icon(Icons.notifications_outlined,
                  color: Color(0xFF6B7089), size: 18),
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
    );
  }
}

// ─── Stats Row ────────────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  final int total, saved, applied, interview, offer;
  final bool isLoading, isWeb;

  const _StatsRow({
    required this.total,
    required this.saved,
    required this.applied,
    required this.interview,
    required this.offer,
    required this.isLoading,
    required this.isWeb,
  });

  @override
  Widget build(BuildContext context) {
    final stats = [
      (label: 'Total', value: total, color: const Color(0xFF534AB7)),
      (label: 'Saved', value: saved, color: const Color(0xFF6B7089)),
      (label: 'Applied', value: applied, color: const Color(0xFF378ADD)),
      (label: 'Interview', value: interview, color: const Color(0xFFEF9F27)),
      (label: 'Offer', value: offer, color: const Color(0xFF1D9E75)),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isWeb ? 5 : 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: isWeb ? 1.4 : 2.2,
      ),
      itemCount: stats.length,
      itemBuilder: (context, i) {
        final s = stats[i];
        return _StatCard(
          label: s.label,
          value: isLoading ? '—' : '${s.value}',
          color: s.color,
          isLoading: isLoading,
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final bool isLoading;

  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.07), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF6B7089),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Color(0xFF534AB7)),
                )
              : Text(
                  value,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: color,
                    letterSpacing: -0.5,
                  ),
                ),
        ],
      ),
    );
  }
}

// ─── Quick Actions ────────────────────────────────────────────────────────────

class _QuickActions extends StatelessWidget {
  final bool isWeb;
  const _QuickActions({required this.isWeb});

  @override
  Widget build(BuildContext context) {
    final actions = [
      (
        icon: Icons.upload_file_rounded,
        label: 'New CV',
        subtitle: 'Upload & optimize',
        color: const Color(0xFF534AB7),
        route: '/cv/upload',
      ),
      (
        icon: Icons.insights_rounded,
        label: 'New Analysis',
        subtitle: 'Match CV to job',
        color: const Color(0xFF1D9E75),
        route: '/analysis',
      ),
      (
        icon: Icons.work_outline_rounded,
        label: 'Browse Jobs',
        subtitle: 'Find opportunities',
        color: const Color(0xFF378ADD),
        route: '/jobs',
      ),
      (
        icon: Icons.send_outlined,
        label: 'Track Application',
        subtitle: 'Log a new apply',
        color: const Color(0xFFEF9F27),
        route: '/applications',
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isWeb ? 4 : 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: isWeb ? 1.6 : 1.8,
      ),
      itemCount: actions.length,
      itemBuilder: (context, i) {
        final a = actions[i];
        return GestureDetector(
          onTap: () => context.push(a.route),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: a.color.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: a.color.withOpacity(0.2), width: 0.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: a.color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(a.icon, color: a.color, size: 18),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      a.label,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFEEEDFE),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      a.subtitle,
                      style: const TextStyle(
                          fontSize: 11, color: Color(0xFF6B7089)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─── Section Header ───────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: Color(0xFFEEEDFE),
        letterSpacing: -0.2,
      ),
    );
  }
}

// ─── Recent Analyses ──────────────────────────────────────────────────────────

class _RecentAnalyses extends StatelessWidget {
  final bool isWeb;
  const _RecentAnalyses({required this.isWeb});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AnalysisCubit, AnalysisState>(
      builder: (context, state) {
        if (state is AnalysisRunning) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(color: Color(0xFF534AB7)),
            ),
          );
        }

        if (state is AnalysisHistoryEmpty ||
            (state is AnalysisHistoryLoaded && state.history.isEmpty)) {
          return Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.03),
              borderRadius: BorderRadius.circular(16),
              border:
                  Border.all(color: Colors.white.withOpacity(0.07), width: 0.5),
            ),
            child: const Center(
              child: Column(
                children: [
                  Icon(Icons.insights_outlined,
                      color: Color(0xFF4A4E6A), size: 32),
                  SizedBox(height: 8),
                  Text('No analyses yet',
                      style: TextStyle(color: Color(0xFF6B7089), fontSize: 14)),
                  SizedBox(height: 4),
                  Text('Run your first CV analysis to see results here.',
                      style: TextStyle(color: Color(0xFF4A4E6A), fontSize: 12)),
                ],
              ),
            ),
          );
        }

        if (state is AnalysisHistoryLoaded) {
          final recent = state.history.take(3).toList();
          return Column(
            children: List.generate(recent.length, (index) {
              final analysis = recent[index];
              final score = analysis.matchScore;
              final Color scoreColor = score >= 80
                  ? const Color(0xFF1D9E75)
                  : score >= 50
                      ? const Color(0xFFEF9F27)
                      : const Color(0xFFE24B4A);

              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: GestureDetector(
                  onTap: () =>
                      context.push('/analysis/result', extra: analysis),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.04),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: Colors.white.withOpacity(0.07), width: 0.5),
                    ),
                    child: Row(
                      children: [
                        // Score circle
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
                            child: Text(
                              '$score%',
                              style: TextStyle(
                                color: scoreColor,
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        // CV name + date
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              BlocBuilder<CVCubit, CVState>(
                                builder: (context, cvState) {
                                  String cvName = 'Loading...';
                                  if (cvState is CVLoaded) {
                                    try {
                                      cvName = cvState.cvs
                                          .firstWhere(
                                              (c) => c.id == analysis.cvId)
                                          .originalFilename;
                                    } catch (_) {
                                      cvName = 'Unknown CV';
                                    }
                                  }
                                  return Text(
                                    cvName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                      color: Color(0xFFEEEDFE),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  );
                                },
                              ),
                              const SizedBox(height: 4),
                              Text(
                                analysis.createdAt
                                    .toLocal()
                                    .toString()
                                    .split(' ')[0],
                                style: const TextStyle(
                                    fontSize: 12, color: Color(0xFF6B7089)),
                              ),
                            ],
                          ),
                        ),
                        // Score badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: scoreColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: scoreColor.withOpacity(0.25),
                                width: 0.5),
                          ),
                          child: Text(
                            score >= 80
                                ? 'Strong'
                                : score >= 50
                                    ? 'Average'
                                    : 'Weak',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: scoreColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.chevron_right_rounded,
                            color: Color(0xFF4A4E6A), size: 18),
                      ],
                    ),
                  ),
                ),
              );
            }),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}
