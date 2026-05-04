import 'dart:io';
import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../models/cv_model.dart';

abstract class CVRemoteDataSource {
  Future<CVModel> uploadCV(List<int> bytes, String fileName);
  Future<List<CVModel>> getCVs();
  Future<void> deleteCV(String id);
}

class CVRemoteDataSourceImpl implements CVRemoteDataSource {
  final DioClient dioClient;

  CVRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<CVModel> uploadCV(List<int> bytes, String fileName) async {
    final formData = FormData.fromMap({
      'file': MultipartFile.fromBytes(
        bytes,
        filename: fileName,
      ),
    });

    final response = await dioClient.dio.post(
      ApiConstants.cvUpload,
      data: formData,
    );

    return CVModel.fromJson(response.data);
  }

  @override
  Future<List<CVModel>> getCVs() async {
    final response = await dioClient.dio.get(ApiConstants.cv);
    final List<dynamic> data = response.data;
    return data.map((json) => CVModel.fromJson(json)).toList();
  }

  @override
  Future<void> deleteCV(String id) async {
    await dioClient.dio.delete(ApiConstants.cvById(id));
  }
}
