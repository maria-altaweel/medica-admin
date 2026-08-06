import 'package:medica_admin/core/networking/api_service.dart';
import 'package:medica_admin/features/secretaries/data/models/secretary_model.dart';
import 'package:medica_admin/features/secretaries/data/repos/secretary_repo.dart';

class SecretaryRepoImpl implements SecretaryRepo {
  final ApiService _apiService;

  SecretaryRepoImpl(this._apiService);

  @override
  Future<List<SecretaryModel>> getSecretaries(int clinicId) async {
    final response = await _apiService.get(
      'admin/clinics/$clinicId/secretaries',
    );
    // ApiService يرخص الـ JSON مباشرة، لا داعي لـ response.data
    final List data = response['data'];
    return data.map((e) => SecretaryModel.fromJson(e)).toList();
  }

  @override
  Future<void> addSecretary({
    required int clinicId,
    required String firstName,
    required String lastName,
    required String phone,
    required String password,
  }) async {
    // إرسال Map مباشرة كمُعامل ثاني لدالة post
    await _apiService.post('admin/clinics/$clinicId/secretaries', {
      'first_name': firstName,
      'last_name': lastName,
      'phone': phone,
      'password': password,
    });
  }

  @override
  Future<void> updateSecretary({
    required int clinicId,
    required int secretaryId,
    String? firstName,
    String? lastName,
    bool? isActive,
  }) async {
    final Map<String, dynamic> bodyData = {};
    if (firstName != null) bodyData['first_name'] = firstName;
    if (lastName != null) bodyData['last_name'] = lastName;
    if (isActive != null) bodyData['is_active'] = isActive;

    await _apiService.put(
      'admin/clinics/$clinicId/secretaries/$secretaryId',
      body: bodyData,
    );
  }

  @override
  Future<void> removeSecretaryFromClinic(int clinicId, int secretaryId) async {
    await _apiService.delete(
      'admin/clinics/$clinicId/secretaries/$secretaryId/remove',
    );
  }

  @override
  Future<void> deleteSecretaryPermanently(int clinicId, int secretaryId) async {
    await _apiService.delete(
      'admin/clinics/$clinicId/secretaries/$secretaryId',
    );
  }
}
