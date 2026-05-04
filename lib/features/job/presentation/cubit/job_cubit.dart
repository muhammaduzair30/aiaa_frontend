import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/job_entity.dart';
import '../../domain/usecases/create_job_usecase.dart';
import '../../domain/usecases/delete_job_usecase.dart';
import '../../domain/usecases/get_jobs_usecase.dart';
import '../../domain/usecases/scrape_job_usecase.dart';

part 'job_state.dart';

class JobCubit extends Cubit<JobState> {
  final CreateJobUseCase _createJobUseCase;
  final GetJobsUseCase _getJobsUseCase;
  final ScrapeJobUseCase _scrapeJobUseCase;
  final DeleteJobUseCase _deleteJobUseCase;

  JobCubit({
    required CreateJobUseCase createJobUseCase,
    required GetJobsUseCase getJobsUseCase,
    required ScrapeJobUseCase scrapeJobUseCase,
    required DeleteJobUseCase deleteJobUseCase,
  })  : _createJobUseCase = createJobUseCase,
        _getJobsUseCase = getJobsUseCase,
        _scrapeJobUseCase = scrapeJobUseCase,
        _deleteJobUseCase = deleteJobUseCase,
        super(JobInitial());

  Future<void> loadJobs() async {
    emit(JobLoading());
    final result = await _getJobsUseCase(NoParams());
    result.fold(
      (failure) => emit(JobError(failure.message)),
      (jobs) => emit(JobLoaded(jobs)),
    );
  }

  Future<void> createJob(String? title, String rawText, String? sourceUrl) async {
    emit(JobLoading());
    final result = await _createJobUseCase(
      CreateJobParams(title: title, rawText: rawText, sourceUrl: sourceUrl),
    );
    result.fold(
      (failure) => emit(JobError(failure.message)),
      (job) => emit(JobCreated(job)),
    );
  }

  Future<void> scrapeJob(String url) async {
    emit(JobLoading());
    final result = await _scrapeJobUseCase(ScrapeJobParams(url: url));
    result.fold(
      (failure) => emit(JobError(failure.message)),
      (text) => emit(JobScraped(text)),
    );
  }

  Future<void> deleteJob(String id) async {
    final currentState = state;
    List<JobEntity> currentJobs = [];
    if (currentState is JobLoaded) {
      currentJobs = currentState.jobs;
    }
    
    emit(JobLoading());
    final result = await _deleteJobUseCase(DeleteJobParams(id: id));
    result.fold(
      (failure) => emit(JobError(failure.message)),
      (_) {
        final updatedJobs = currentJobs.where((job) => job.id != id).toList();
        emit(JobLoaded(updatedJobs));
      },
    );
  }
}
