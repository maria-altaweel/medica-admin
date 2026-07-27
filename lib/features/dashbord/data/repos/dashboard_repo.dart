import 'package:medica_admin/features/dashbord/data/models/dashboard_model.dart';

import '../../../../core/networking/api_service.dart';

class DashboardHomeRepo {
  final ApiService _apiService;

  DashboardHomeRepo(this._apiService);

  Future<DashboardHomeResponse> getDashboardHomeData() async {
    final response = await _apiService.get('admin/dashboard');
    return DashboardHomeResponse.fromJson(response);
  }
}
