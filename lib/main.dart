import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/di/injection.dart' as di;
import 'app.dart';

import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/cv/presentation/cubit/cv_cubit.dart';
import 'features/job/presentation/cubit/job_cubit.dart';
import 'features/analysis/presentation/cubit/analysis_cubit.dart';
import 'features/job_application/presentation/cubit/job_application_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await dotenv.load(fileName: ".env");
  
  await di.initInjection();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(create: (_) => di.sl<AuthBloc>()..add(AuthCheckRequested())),
        BlocProvider<CVCubit>(create: (_) => di.sl<CVCubit>()),
        BlocProvider<JobCubit>(create: (_) => di.sl<JobCubit>()),
        BlocProvider<AnalysisCubit>(create: (_) => di.sl<AnalysisCubit>()),
        BlocProvider<JobApplicationCubit>(create: (_) => di.sl<JobApplicationCubit>()),
      ],
      child: const App(),
    ),
  );
}
