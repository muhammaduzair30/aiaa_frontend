import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';

import '../network/auth_interceptor.dart';
import '../network/dio_client.dart';

// Auth
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/register_usecase.dart';
import '../../features/auth/domain/usecases/logout_usecase.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';

// CV
import '../../features/cv/domain/repositories/cv_repository.dart';
import '../../features/cv/data/repositories/cv_repository_impl.dart';
import '../../features/cv/data/datasources/cv_remote_datasource.dart';
import '../../features/cv/domain/usecases/upload_cv_usecase.dart';
import '../../features/cv/domain/usecases/get_cvs_usecase.dart';
import '../../features/cv/domain/usecases/delete_cv_usecase.dart';
import '../../features/cv/presentation/cubit/cv_cubit.dart';

// Job
import '../../features/job/domain/repositories/job_repository.dart';
import '../../features/job/data/repositories/job_repository_impl.dart';
import '../../features/job/data/datasources/job_remote_datasource.dart';
import '../../features/job/domain/usecases/create_job_usecase.dart';
import '../../features/job/domain/usecases/get_jobs_usecase.dart';
import '../../features/job/domain/usecases/scrape_job_usecase.dart';
import '../../features/job/domain/usecases/delete_job_usecase.dart';
import '../../features/job/presentation/cubit/job_cubit.dart';

// Analysis
import '../../features/analysis/domain/repositories/analysis_repository.dart';
import '../../features/analysis/data/repositories/analysis_repository_impl.dart';
import '../../features/analysis/data/datasources/analysis_remote_datasource.dart';
import '../../features/analysis/domain/usecases/run_analysis_usecase.dart';
import '../../features/analysis/domain/usecases/get_history_usecase.dart';
import '../../features/analysis/domain/usecases/get_analysis_usecase.dart';
import '../../features/analysis/presentation/cubit/analysis_cubit.dart';

// Job Application
import '../../features/job_application/domain/repositories/job_application_repository.dart';
import '../../features/job_application/data/repositories/job_application_repository_impl.dart';
import '../../features/job_application/data/datasources/job_application_remote_datasource.dart';
import '../../features/job_application/domain/usecases/create_application_usecase.dart';
import '../../features/job_application/domain/usecases/get_applications_usecase.dart';
import '../../features/job_application/domain/usecases/get_application_usecase.dart';
import '../../features/job_application/domain/usecases/update_application_usecase.dart';
import '../../features/job_application/domain/usecases/delete_application_usecase.dart';
import '../../features/job_application/presentation/cubit/job_application_cubit.dart';

final GetIt sl = GetIt.instance;

Future<void> initInjection() async {
  // Core
  sl.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(),
  );

  sl.registerLazySingleton<Dio>(() => Dio());

  // AuthRemoteDataSource must be registered before AuthInterceptor
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(dio: sl(), secureStorage: sl()),
  );

  sl.registerLazySingleton<AuthInterceptor>(
    () => AuthInterceptor(
      secureStorage: sl(),
      dio: sl(),
      authDataSource: sl(),
    ),
  );

  sl.registerSingleton<DioClient>(
    DioClient(
      dio: sl(),
      authInterceptor: sl(),
    ),
  );

  // --- Data Sources ---
  sl.registerLazySingleton<CVRemoteDataSource>(
    () => CVRemoteDataSourceImpl(dioClient: sl()),
  );
  sl.registerLazySingleton<JobRemoteDataSource>(
    () => JobRemoteDataSourceImpl(dioClient: sl()),
  );
  sl.registerLazySingleton<AnalysisRemoteDataSource>(
    () => AnalysisRemoteDataSourceImpl(dioClient: sl()),
  );
  sl.registerLazySingleton<JobApplicationRemoteDataSource>(
    () => JobApplicationRemoteDataSourceImpl(dioClient: sl()),
  );

  // --- Repositories ---
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<CVRepository>(
    () => CVRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<JobRepository>(
    () => JobRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<AnalysisRepository>(
    () => AnalysisRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<JobApplicationRepository>(
    () => JobApplicationRepositoryImpl(remoteDataSource: sl()),
  );

  // --- Use Cases ---
  // Auth
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  // CV
  sl.registerLazySingleton(() => UploadCVUseCase(sl()));
  sl.registerLazySingleton(() => GetCVsUseCase(sl()));
  sl.registerLazySingleton(() => DeleteCVUseCase(sl()));
  // Job
  sl.registerLazySingleton(() => CreateJobUseCase(sl()));
  sl.registerLazySingleton(() => GetJobsUseCase(sl()));
  sl.registerLazySingleton(() => ScrapeJobUseCase(sl()));
  sl.registerLazySingleton(() => DeleteJobUseCase(sl()));
  // Analysis
  sl.registerLazySingleton(() => RunAnalysisUseCase(sl()));
  sl.registerLazySingleton(() => GetHistoryUseCase(sl()));
  sl.registerLazySingleton(() => GetAnalysisUseCase(sl()));
  // Job Application
  sl.registerLazySingleton(() => CreateApplicationUseCase(sl()));
  sl.registerLazySingleton(() => GetApplicationsUseCase(sl()));
  sl.registerLazySingleton(() => GetApplicationUseCase(sl()));
  sl.registerLazySingleton(() => UpdateApplicationUseCase(sl()));
  sl.registerLazySingleton(() => DeleteApplicationUseCase(sl()));

  // --- Blocs and Cubits ---
  sl.registerFactory(
    () => AuthBloc(
      loginUseCase: sl(),
      registerUseCase: sl(),
      logoutUseCase: sl(),
      authRepository: sl(),
    ),
  );
  sl.registerFactory(
    () => CVCubit(
      uploadCVUseCase: sl(),
      getCVsUseCase: sl(),
      deleteCVUseCase: sl(),
    ),
  );
  sl.registerFactory(
    () => JobCubit(
      createJobUseCase: sl(),
      getJobsUseCase: sl(),
      scrapeJobUseCase: sl(),
      deleteJobUseCase: sl(),
    ),
  );
  sl.registerFactory(
    () => AnalysisCubit(
      runAnalysisUseCase: sl(),
      getHistoryUseCase: sl(),
      getAnalysisUseCase: sl(),
    ),
  );
  sl.registerFactory(
    () => JobApplicationCubit(
      createUseCase: sl(),
      getAllUseCase: sl(),
      getSingleUseCase: sl(),
      updateUseCase: sl(),
      deleteUseCase: sl(),
    ),
  );
}
