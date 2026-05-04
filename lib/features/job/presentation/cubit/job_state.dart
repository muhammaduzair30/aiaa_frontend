part of 'job_cubit.dart';

abstract class JobState extends Equatable {
  const JobState();

  @override
  List<Object?> get props => [];
}

class JobInitial extends JobState {}

class JobLoading extends JobState {}

class JobLoaded extends JobState {
  final List<JobEntity> jobs;

  const JobLoaded(this.jobs);

  @override
  List<Object?> get props => [jobs];
}

class JobCreated extends JobState {
  final JobEntity job;

  const JobCreated(this.job);

  @override
  List<Object?> get props => [job];
}

class JobScraped extends JobState {
  final String text;

  const JobScraped(this.text);

  @override
  List<Object?> get props => [text];
}

class JobError extends JobState {
  final String message;

  const JobError(this.message);

  @override
  List<Object?> get props => [message];
}
