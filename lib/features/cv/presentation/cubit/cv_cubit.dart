import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/cv_entity.dart';
import '../../domain/usecases/delete_cv_usecase.dart';
import '../../domain/usecases/get_cvs_usecase.dart';
import '../../domain/usecases/upload_cv_usecase.dart';

part 'cv_state.dart';

class CVCubit extends Cubit<CVState> {
  final GetCVsUseCase _getCVsUseCase;
  final UploadCVUseCase _uploadCVUseCase;
  final DeleteCVUseCase _deleteCVUseCase;

  CVCubit({
    required GetCVsUseCase getCVsUseCase,
    required UploadCVUseCase uploadCVUseCase,
    required DeleteCVUseCase deleteCVUseCase,
  })  : _getCVsUseCase = getCVsUseCase,
        _uploadCVUseCase = uploadCVUseCase,
        _deleteCVUseCase = deleteCVUseCase,
        super(CVInitial());

  Future<void> loadCVs() async {
    emit(CVLoading());
    final result = await _getCVsUseCase(NoParams());
    result.fold(
      (failure) => emit(CVError(failure.message)),
      (cvs) => emit(CVLoaded(cvs)),
    );
  }

  Future<void> uploadCV(List<int> bytes, String fileName) async {
    emit(CVUploading());
    final result = await _uploadCVUseCase(UploadCVParams(bytes: bytes, fileName: fileName));
    result.fold(
      (failure) => emit(CVError(failure.message)),
      (cv) => emit(CVUploadSuccess(cv)),
    );
  }

  Future<void> deleteCV(String id) async {
    final currentState = state;
    List<CVEntity> currentCVs = [];
    if (currentState is CVLoaded) {
      currentCVs = currentState.cvs;
    }
    
    emit(CVLoading());
    final result = await _deleteCVUseCase(DeleteCVParams(id: id));
    result.fold(
      (failure) => emit(CVError(failure.message)),
      (_) {
        final updatedCVs = currentCVs.where((cv) => cv.id != id).toList();
        emit(CVLoaded(updatedCVs));
      },
    );
  }
}
