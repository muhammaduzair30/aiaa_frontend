part of 'job_application_cubit.dart';

abstract class JobApplicationState extends Equatable {
  const JobApplicationState();

  @override
  List<Object?> get props => [];
}

class JobApplicationInitial extends JobApplicationState {}

class JobApplicationLoading extends JobApplicationState {}

class JobApplicationLoaded extends JobApplicationState {
  final List<JobApplicationEntity> applications;

  const JobApplicationLoaded(this.applications);

  @override
  List<Object?> get props => [applications];
}

class JobApplicationCreated extends JobApplicationState {
  final JobApplicationEntity application;

  const JobApplicationCreated(this.application);

  @override
  List<Object?> get props => [application];
}

class JobApplicationUpdated extends JobApplicationState {
  final JobApplicationEntity application;

  const JobApplicationUpdated(this.application);

  @override
  List<Object?> get props => [application];
}

class JobApplicationDetailLoaded extends JobApplicationState {
  final JobApplicationEntity application;

  const JobApplicationDetailLoaded(this.application);

  @override
  List<Object?> get props => [application];
}

class JobApplicationError extends JobApplicationState {
  final String message;

  const JobApplicationError(this.message);

  @override
  List<Object?> get props => [message];
}
