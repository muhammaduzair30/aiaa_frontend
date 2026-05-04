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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _tabs[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.description), label: 'CVs'),
          BottomNavigationBarItem(icon: Icon(Icons.work_outline), label: 'Jobs'),
          BottomNavigationBarItem(icon: Icon(Icons.analytics), label: 'Analysis'),
          BottomNavigationBarItem(icon: Icon(Icons.work), label: 'Applications'),
        ],
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<JobApplicationCubit>()..loadApplications()),
        BlocProvider(create: (_) => sl<AnalysisCubit>()..loadHistory()),
        BlocProvider(create: (_) => sl<CVCubit>()..loadCVs()),
      ],
      child: const _HomeTabView(),
    );
  }
}

class _HomeTabView extends StatelessWidget {
  const _HomeTabView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: BlocBuilder<JobApplicationCubit, JobApplicationState>(
        builder: (context, state) {
          int total = 0;
          int saved = 0;
          int applied = 0;
          int interview = 0;
          int offer = 0;

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

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Overview', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total Applications', style: TextStyle(fontSize: 16)),
                        if (state is JobApplicationLoading)
                          const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                        else
                          Text('$total', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Applications by Status', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 2.5,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  children: [
                    _buildStatusCard('Saved', '$saved', Colors.grey),
                    _buildStatusCard('Applied', '$applied', Colors.blue),
                    _buildStatusCard('Interview', '$interview', Colors.orange),
                    _buildStatusCard('Offer', '$offer', Colors.green),
                  ],
                ),
                const SizedBox(height: 24),
                const Text('Quick Actions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => context.push('/cv/upload'),
                      icon: const Icon(Icons.add),
                      label: const Text('New CV'),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => context.push('/analysis'),
                      icon: const Icon(Icons.analytics),
                      label: const Text('New Analysis'),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Recent Analyses', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    TextButton(
                      onPressed: () => context.push('/analysis/history'),
                      child: const Text('View All'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                BlocBuilder<AnalysisCubit, AnalysisState>(
                  builder: (context, state) {
                    if (state is AnalysisRunning) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is AnalysisHistoryEmpty) {
                      return const Center(child: Text('No recent analyses found.'));
                    } else if (state is AnalysisHistoryLoaded) {
                      if (state.history.isEmpty) {
                        return const Center(child: Text('No recent analyses found.'));
                      }
                      final recent = state.history.take(3).toList();
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: recent.length,
                        itemBuilder: (context, index) {
                          final analysis = recent[index];
                          Color scoreColor = analysis.matchScore >= 80 ? Colors.green : (analysis.matchScore >= 50 ? Colors.orange : Colors.red);
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              onTap: () => context.push('/analysis/result', extra: analysis),
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: scoreColor.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: scoreColor, width: 2),
                                ),
                                child: Text('${analysis.matchScore}%', style: TextStyle(color: scoreColor, fontWeight: FontWeight.bold, fontSize: 12)),
                              ),
                              title: BlocBuilder<CVCubit, CVState>(
                                builder: (context, cvState) {
                                  String cvName = 'Loading...';
                                  if (cvState is CVLoaded) {
                                    try {
                                      cvName = cvState.cvs.firstWhere((c) => c.id == analysis.cvId).originalFilename;
                                    } catch (_) {
                                      cvName = 'Unknown CV';
                                    }
                                  }
                                  return Text(cvName, style: const TextStyle(fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis);
                                },
                              ),
                              subtitle: Text(analysis.createdAt.toLocal().toString().split(' ')[0]),
                            ),
                          );
                        },
                      );
                    }
                    return const Center(child: Text('No recent analyses found.'));
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusCard(String title, String count, Color color) {
    return Card(
      elevation: 2,
      child: Container(
        decoration: BoxDecoration(
          border: Border(left: BorderSide(color: color, width: 4)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            Text(count, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
