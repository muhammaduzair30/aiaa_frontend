import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/analysis_entity.dart';
import '../../domain/usecases/get_analysis_usecase.dart';
import '../../domain/usecases/get_history_usecase.dart';
import '../../domain/usecases/run_analysis_usecase.dart';

part 'analysis_state.dart';

class AnalysisCubit extends Cubit<AnalysisState> {
  final RunAnalysisUseCase _runAnalysisUseCase;
  final GetHistoryUseCase _getHistoryUseCase;
  final GetAnalysisUseCase _getAnalysisUseCase;

  AnalysisCubit({
    required RunAnalysisUseCase runAnalysisUseCase,
    required GetHistoryUseCase getHistoryUseCase,
    required GetAnalysisUseCase getAnalysisUseCase,
  })  : _runAnalysisUseCase = runAnalysisUseCase,
        _getHistoryUseCase = getHistoryUseCase,
        _getAnalysisUseCase = getAnalysisUseCase,
        super(AnalysisInitial());

  Future<void> runAnalysis(String cvId, String jdText, {String? jobId}) async {
    emit(AnalysisRunning());
    final result = await _runAnalysisUseCase(
      RunAnalysisParams(cvId: cvId, jdText: jdText, jobId: jobId),
    );
    result.fold(
      (failure) => emit(AnalysisError(failure.message)),
      (analysis) => emit(AnalysisComplete(analysis)),
    );
  }

  Future<void> loadHistory() async {
    emit(AnalysisRunning());
    final result = await _getHistoryUseCase(NoParams());
    result.fold(
      (failure) => emit(AnalysisError(failure.message)),
      (history) {
        if (history.isEmpty) {
          emit(AnalysisHistoryEmpty());
        } else {
          final sortedHistory = List<AnalysisEntity>.from(history)
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
          emit(AnalysisHistoryLoaded(sortedHistory));
        }
      },
    );
  }

  Future<void> loadAnalysis(String id) async {
    emit(AnalysisRunning());
    final result = await _getAnalysisUseCase(GetAnalysisParams(id: id));
    result.fold(
      (failure) => emit(AnalysisError(failure.message)),
      (analysis) => emit(AnalysisComplete(analysis)),
    );
  }
}
