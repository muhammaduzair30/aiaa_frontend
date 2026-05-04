part of 'analysis_cubit.dart';

abstract class AnalysisState extends Equatable {
  const AnalysisState();

  @override
  List<Object?> get props => [];
}

class AnalysisInitial extends AnalysisState {}

class AnalysisRunning extends AnalysisState {}

class AnalysisComplete extends AnalysisState {
  final AnalysisEntity analysis;

  const AnalysisComplete(this.analysis);

  @override
  List<Object?> get props => [analysis];
}

class AnalysisHistoryLoaded extends AnalysisState {
  final List<AnalysisEntity> history;

  const AnalysisHistoryLoaded(this.history);

  @override
  List<Object?> get props => [history];
}

class AnalysisError extends AnalysisState {
  final String message;

  const AnalysisError(this.message);

  @override
  List<Object?> get props => [message];
}

class AnalysisHistoryEmpty extends AnalysisState {}
