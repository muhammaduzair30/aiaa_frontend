import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../models/job_model.dart';

abstract class JobRemoteDataSource {
  Future<JobModel> createJob(String? title, String rawText, String? sourceUrl);
  Future<List<JobModel>> getJobs();
  Future<String> scrapeJob(String url);
  Future<void> deleteJob(String id);
}

class JobRemoteDataSourceImpl implements JobRemoteDataSource {
  final DioClient dioClient;

  JobRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<JobModel> createJob(
      String? title, String rawText, String? sourceUrl) async {
    final response = await dioClient.dio.post(
      ApiConstants.job,
      data: {
        'job_title': title,
        'raw_text': rawText,
        'source_url': sourceUrl,
      },
    );
    return JobModel.fromJson(response.data);
  }

  @override
  Future<List<JobModel>> getJobs() async {
    final response = await dioClient.dio.get(ApiConstants.job);
    final List<dynamic> data = response.data;
    return data.map((json) => JobModel.fromJson(json)).toList();
  }

  @override
  Future<String> scrapeJob(String url) async {
    final response = await dioClient.dio.get(
      ApiConstants.jobScrape,
      queryParameters: {'url': url},
    );
    return response.data['job_description'];
  }

  @override
  Future<void> deleteJob(String id) async {
    await dioClient.dio.delete(ApiConstants.jobById(id));
  }
}
