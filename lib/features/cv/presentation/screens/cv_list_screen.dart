import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection.dart';
import '../cubit/cv_cubit.dart';
import '../widgets/cv_card.dart';

class CVListScreen extends StatelessWidget {
  const CVListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<CVCubit>(),
      child: const _CVListScreenView(),
    );
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
    return Scaffold(
      appBar: AppBar(title: const Text('My CVs')),
      body: BlocConsumer<CVCubit, CVState>(
        listener: (context, state) {
          if (state is CVError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          } else if (state is CVUploadSuccess) {
            context.read<CVCubit>().loadCVs();
          }
        },
        buildWhen: (previous, current) {
          return current is CVLoading ||
              current is CVLoaded ||
              current is CVError && previous is! CVLoaded;
        },
        builder: (context, state) {
          if (state is CVLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is CVLoaded) {
            if (state.cvs.isEmpty) {
              return const Center(
                child: Text(
                    'No CVs uploaded yet. Tap the + button to upload one.'),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.cvs.length,
              itemBuilder: (context, index) {
                final cv = state.cvs[index];
                return Dismissible(
                  key: Key(cv.id),
                  direction: DismissDirection.endToStart,
                  confirmDismiss: (direction) async {
                    return await showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text("Confirm"),
                          content: const Text(
                              "Are you sure you wish to delete this CV?"),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text("CANCEL"),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: const Text("DELETE"),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  onDismissed: (direction) {
                    context.read<CVCubit>().deleteCV(cv.id);
                  },
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  child: CVCard(
                    cv: cv,
                    onDelete: () => context.read<CVCubit>().deleteCV(cv.id),
                  ),
                );
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/cv/upload'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
