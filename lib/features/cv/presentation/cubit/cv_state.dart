part of 'cv_cubit.dart';

abstract class CVState extends Equatable {
  const CVState();

  @override
  List<Object?> get props => [];
}

class CVInitial extends CVState {}

class CVLoading extends CVState {}

class CVLoaded extends CVState {
  final List<CVEntity> cvs;

  const CVLoaded(this.cvs);

  @override
  List<Object?> get props => [cvs];
}

class CVUploading extends CVState {}

class CVUploadSuccess extends CVState {
  final CVEntity cv;

  const CVUploadSuccess(this.cv);

  @override
  List<Object?> get props => [cv];
}

class CVError extends CVState {
  final String message;

  const CVError(this.message);

  @override
  List<Object?> get props => [message];
}

class CVDownloadLoading extends CVState {
  final String cvId;

  const CVDownloadLoading(this.cvId);

  @override
  List<Object?> get props => [cvId];
}

class CVDownloadUrlReady extends CVState {
  final String url;

  const CVDownloadUrlReady(this.url);

  @override
  List<Object?> get props => [url];
}
