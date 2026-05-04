import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/job_application_entity.dart';
import '../../domain/usecases/create_application_usecase.dart';
import '../../domain/usecases/delete_application_usecase.dart';
import '../../domain/usecases/get_application_usecase.dart';
import '../../domain/usecases/get_applications_usecase.dart';
import '../../domain/usecases/update_application_usecase.dart';

part 'job_application_state.dart';

class JobApplicationCubit extends Cubit<JobApplicationState> {
  final CreateApplicationUseCase _createUseCase;
  final GetApplicationsUseCase _getAllUseCase;
  final GetApplicationUseCase _getSingleUseCase;
  final UpdateApplicationUseCase _updateUseCase;
  final DeleteApplicationUseCase _deleteUseCase;

  JobApplicationCubit({
    required CreateApplicationUseCase createUseCase,
    required GetApplicationsUseCase getAllUseCase,
    required GetApplicationUseCase getSingleUseCase,
    required UpdateApplicationUseCase updateUseCase,
    required DeleteApplicationUseCase deleteUseCase,
  })  : _createUseCase = createUseCase,
        _getAllUseCase = getAllUseCase,
        _getSingleUseCase = getSingleUseCase,
        _updateUseCase = updateUseCase,
        _deleteUseCase = deleteUseCase,
        super(JobApplicationInitial());

  Future<void> loadApplications() async {
    emit(JobApplicationLoading());
    final result = await _getAllUseCase(NoParams());
    result.fold(
      (failure) => emit(JobApplicationError(failure.message)),
      (apps) => emit(JobApplicationLoaded(apps)),
    );
  }

  Future<void> getApplication(String id) async {
    emit(JobApplicationLoading());
    final result = await _getSingleUseCase(GetApplicationParams(id: id));
    result.fold(
      (failure) => emit(JobApplicationError(failure.message)),
      (app) => emit(JobApplicationDetailLoaded(app)),
    );
  }

  Future<void> createApplication(String cvId, String jobId, String? analysisId,
      String status, String? notes) async {
    emit(JobApplicationLoading());
    final result = await _createUseCase(
      CreateApplicationParams(
          cvId: cvId,
          jobId: jobId,
          analysisId: analysisId,
          status: status,
          notes: notes),
    );
    result.fold(
      (failure) => emit(JobApplicationError(failure.message)),
      (app) async {
        emit(JobApplicationCreated(app));
        loadApplications();
      },
    );
  }

  Future<void> updateApplication(
      String id, String status, String? notes, DateTime? appliedDate) async {
    emit(JobApplicationLoading());
    final result = await _updateUseCase(
      UpdateApplicationParams(
          id: id, status: status, notes: notes, appliedDate: appliedDate),
    );
    result.fold(
      (failure) => emit(JobApplicationError(failure.message)),
      (app) async {
        emit(JobApplicationUpdated(app));
        loadApplications();
      },
    );
  }

  Future<void> deleteApplication(String id) async {
    emit(JobApplicationLoading());
    final result = await _deleteUseCase(DeleteApplicationParams(id: id));
    result.fold(
      (failure) => emit(JobApplicationError(failure.message)),
      (_) {
        emit(JobApplicationDeleted());
        loadApplications();
      },
    );
  }
}

class JobApplicationDeleted extends JobApplicationState {
  @override
  List<Object?> get props => [];
}
