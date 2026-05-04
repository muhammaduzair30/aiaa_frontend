import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../models/job_application_model.dart';

abstract class JobApplicationRemoteDataSource {
  Future<JobApplicationModel> createApplication(String cvId, String jobId,
      String? analysisId, String status, String? notes);
  Future<List<JobApplicationModel>> getApplications();
  Future<JobApplicationModel> getApplication(String id);
  Future<JobApplicationModel> updateApplication(
      String id, String status, String? notes, DateTime? appliedDate);
  Future<void> deleteApplication(String id);
}

class JobApplicationRemoteDataSourceImpl
    implements JobApplicationRemoteDataSource {
  final DioClient dioClient;

  JobApplicationRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<JobApplicationModel> createApplication(String cvId, String jobId,
      String? analysisId, String status, String? notes) async {
    final response = await dioClient.dio.post(
      ApiConstants.applications,
      data: {
        'cv_id': cvId,
        'job_id': jobId,
        if (analysisId != null) 'analysis_id': analysisId,
        'status': status,
        if (notes != null) 'notes': notes,
      },
    );
    return JobApplicationModel.fromJson(response.data);
  }

  @override
  Future<List<JobApplicationModel>> getApplications() async {
    final response = await dioClient.dio.get(ApiConstants.applications);
    final List<dynamic> data = response.data;
    return data.map((json) => JobApplicationModel.fromJson(json)).toList();
  }

  @override
  Future<JobApplicationModel> getApplication(String id) async {
    final response = await dioClient.dio.get(ApiConstants.applicationsById(id));
    return JobApplicationModel.fromJson(response.data);
  }

  @override
  Future<JobApplicationModel> updateApplication(
      String id, String status, String? notes, DateTime? appliedDate) async {
    final response = await dioClient.dio.patch(
      ApiConstants.applicationsById(id),
      data: {
        'status': status,
        if (notes != null) 'notes': notes,
        if (appliedDate != null) 'applied_date': appliedDate.toIso8601String(),
      },
    );
    return JobApplicationModel.fromJson(response.data);
  }

  @override
  Future<void> deleteApplication(String id) async {
    await dioClient.dio.delete(ApiConstants.applicationsById(id));
  }
}
