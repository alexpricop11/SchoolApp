import 'package:dio/dio.dart';
import '../models/dashboard_stats_model.dart';

class DashboardDataSource {
  final Dio dio;

  DashboardDataSource(this.dio);

  Future<DashboardStatsModel> getDashboardStats() async {
    try {
      final response = await dio.get('/dashboard/stats');
      return DashboardStatsModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}