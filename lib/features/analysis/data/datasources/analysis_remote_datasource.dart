import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../models/analysis_model.dart';

abstract class AnalysisRemoteDataSource {
  Future<AnalysisModel> runAnalysis(String cvId, String jdText, String? jobId);
  Future<List<AnalysisModel>> getHistory();
  Future<AnalysisModel> getAnalysis(String id);
}

class AnalysisRemoteDataSourceImpl implements AnalysisRemoteDataSource {
  final DioClient dioClient;

  AnalysisRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<AnalysisModel> runAnalysis(String cvId, String jdText, String? jobId) async {
    final response = await dioClient.dio.post(
      ApiConstants.analysisRun,
      data: {
        'cv_id': cvId,
        'jd_text': jdText,
        if (jobId != null) 'job_id': jobId,
      },
    );
    return AnalysisModel.fromJson(response.data);
  }

  @override
  Future<List<AnalysisModel>> getHistory() async {
    final response = await dioClient.dio.get(ApiConstants.analysisHistory);
    final List<dynamic> data = response.data;
    return data.map((json) => AnalysisModel.fromJson(json)).toList();
  }

  @override
  Future<AnalysisModel> getAnalysis(String id) async {
    final response = await dioClient.dio.get(ApiConstants.analysisById(id));
    return AnalysisModel.fromJson(response.data);
  }
}
