import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Jobs'),
      ),
      body: BlocConsumer<JobCubit, JobState>(
        listener: (context, state) {
          if (state is JobError) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          if (state is JobLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is JobLoaded) {
            if (state.jobs.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.work_outline,
                        size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    const Text('No saved jobs yet',
                        style: TextStyle(fontSize: 18, color: Colors.grey)),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => context.push('/job/input'),
                      icon: const Icon(Icons.add),
                      label: const Text('Add Job'),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: state.jobs.length,
              itemBuilder: (context, index) {
                final job = state.jobs[index];
                return Dismissible(
                  key: Key(job.id),
                  direction: DismissDirection.endToStart,
                  confirmDismiss: (direction) async {
                    return await showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text("Confirm"),
                          content: const Text(
                              "Are you sure you wish to delete this job?"),
                          actions: <Widget>[
                            TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(false),
                                child: const Text("CANCEL")),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: const Text("DELETE",
                                  style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  onDismissed: (direction) {
                    context.read<JobCubit>().deleteJob(job.id);
                  },
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  child: Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      title: Text(job.jobTitle ?? 'Untitled Job',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(
                        'Added ${DateFormat('MMM d, yyyy').format(job.createdAt)}\n${job.rawText.split('\n').first.substring(0, job.rawText.split('\n').first.length > 50 ? 50 : job.rawText.split('\n').first.length)}...',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      isThreeLine: true,
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text(job.jobTitle ?? 'Untitled Job'),
                            content:
                                SingleChildScrollView(child: Text(job.rawText)),
                            actions: [
                              TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('CLOSE')),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/job/input'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
