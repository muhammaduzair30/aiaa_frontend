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

class ApplicationsScreen extends StatelessWidget {
  const ApplicationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<JobApplicationCubit>()),
        BlocProvider(create: (_) => sl<CVCubit>()..loadCVs()),
        BlocProvider(create: (_) => sl<JobCubit>()..loadJobs()),
      ],
      child: const _ApplicationsScreenView(),
    );
  }
}

class _ApplicationsScreenView extends StatefulWidget {
  const _ApplicationsScreenView();

  @override
  State<_ApplicationsScreenView> createState() =>
      _ApplicationsScreenViewState();
}

class _ApplicationsScreenViewState extends State<_ApplicationsScreenView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _tabs = ['All', ...AppConstants.statusValues];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    context.read<JobApplicationCubit>().loadApplications();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showCreateBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Applications'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: _tabs.map((t) => Tab(text: t.toUpperCase())).toList(),
        ),
      ),
      body: BlocConsumer<JobApplicationCubit, JobApplicationState>(
        listener: (context, state) {
          if (state is JobApplicationError) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.message)));
          } else if (state is JobApplicationCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Application added')),
            );
          } else if (state is JobApplicationUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Application updated')),
            );
          } else if (state is JobApplicationDeleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Application deleted')),
            );
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
            return const Center(child: CircularProgressIndicator());
          } else if (state is JobApplicationLoaded) {
            return TabBarView(
              controller: _tabController,
              children: _tabs.map((statusTab) {
                List<JobApplicationEntity> filtered = state.applications;
                if (statusTab != 'All') {
                  filtered = state.applications
                      .where((app) => app.status == statusTab)
                      .toList();
                }

                if (filtered.isEmpty) {
                  return const Center(
                      child: Text('No applications in this status.'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final app = filtered[index];
                    return GestureDetector(
                      onTap: () async {
                        final result = await context.push('/application/${app.id}', extra: app);
                        if (result == true && context.mounted) {
                          context.read<JobApplicationCubit>().loadApplications();
                        }
                      },
                      child: ApplicationCard(application: app),
                    );
                  },
                );
              }).toList(),
            );
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateBottomSheet,
        child: const Icon(Icons.add),
      ),
    );
  }
}

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

  @override
  Widget build(BuildContext context) {
    final cvState = context.watch<CVCubit>().state;
    final jobState = context.watch<JobCubit>().state;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Create Application',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          if (cvState is CVLoaded)
            DropdownButtonFormField<String>(
              initialValue: _selectedCvId,
              decoration: const InputDecoration(
                  labelText: 'Select CV', border: OutlineInputBorder()),
              items: cvState.cvs
                  .map((cv) => DropdownMenuItem(
                      value: cv.id, child: Text(cv.originalFilename)))
                  .toList(),
              onChanged: (val) => setState(() => _selectedCvId = val),
            )
          else
            const Center(child: CircularProgressIndicator()),
          const SizedBox(height: 16),
          if (jobState is JobLoaded)
            DropdownButtonFormField<String>(
              initialValue: _selectedJobId,
              decoration: const InputDecoration(
                  labelText: 'Select Job', border: OutlineInputBorder()),
              items: jobState.jobs
                  .map((job) => DropdownMenuItem(
                      value: job.id,
                      child: Text(job.jobTitle ?? 'Untitled Job')))
                  .toList(),
              onChanged: (val) => setState(() => _selectedJobId = val),
            )
          else
            const Center(child: CircularProgressIndicator()),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _selectedStatus,
            decoration: const InputDecoration(
                labelText: 'Status', border: OutlineInputBorder()),
            items: AppConstants.statusValues
                .map((s) =>
                    DropdownMenuItem(value: s, child: Text(s.toUpperCase())))
                .toList(),
            onChanged: (val) {
              if (val != null) setState(() => _selectedStatus = val);
            },
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _notesController,
            decoration: const InputDecoration(
                labelText: 'Notes (optional)', border: OutlineInputBorder()),
            maxLines: 3,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    if (_selectedCvId != null && _selectedJobId != null) {
                      context.read<JobApplicationCubit>().createApplication(
                            _selectedCvId!,
                            _selectedJobId!,
                            null, // analysisId
                            _selectedStatus,
                            _notesController.text,
                          );
                      Navigator.pop(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('Please select CV and Job')));
                    }
                  },
                  child: const Text('Save'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
