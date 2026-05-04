import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../cubit/job_cubit.dart';

class JobInputScreen extends StatefulWidget {
  const JobInputScreen({super.key});

  @override
  State<JobInputScreen> createState() => _JobInputScreenState();
}

class _JobInputScreenState extends State<JobInputScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _titleController = TextEditingController();
  final _rawTextController = TextEditingController();
  final _urlController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _titleController.dispose();
    _rawTextController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  void _onScrapePressed() {
    if (_urlController.text.isNotEmpty) {
      context.read<JobCubit>().scrapeJob(_urlController.text);
    }
  }

  void _onSaveJobPressed() {
    if (_rawTextController.text.isNotEmpty) {
      context.read<JobCubit>().createJob(
        _titleController.text.isNotEmpty ? _titleController.text : null,
        _rawTextController.text,
        _urlController.text.isNotEmpty ? _urlController.text : null,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Input Job Description'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Paste Text'),
            Tab(text: 'From URL'),
          ],
        ),
      ),
      body: BlocConsumer<JobCubit, JobState>(
        listener: (context, state) {
          if (state is JobError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
          } else if (state is JobScraped) {
            _rawTextController.text = state.text;
            _tabController.animateTo(0);
          } else if (state is JobCreated) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Job Saved Successfully!')));
            context.pop(state.job);
          }
        },
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Job Title (Optional)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // Tab 1: Paste Text
                      TextField(
                        controller: _rawTextController,
                        maxLines: null,
                        expands: true,
                        textAlignVertical: TextAlignVertical.top,
                        decoration: const InputDecoration(
                          hintText: 'Paste Job Description here...',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      // Tab 2: From URL
                      Column(
                        children: [
                          TextField(
                            controller: _urlController,
                            decoration: const InputDecoration(
                              labelText: 'Job URL',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (state is JobLoading)
                            const CircularProgressIndicator()
                          else
                            ElevatedButton(
                              onPressed: _onScrapePressed,
                              child: const Text('Scrape Job Description'),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                if (state is JobLoading)
                  const CircularProgressIndicator()
                else
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _onSaveJobPressed,
                      child: const Text('Save Job'),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
