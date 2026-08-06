import 'package:medica_admin/features/secretaries/data/models/secretary_model.dart';

abstract class SecretaryRepo {
  Future<List<SecretaryModel>> getSecretaries(int clinicId);

  Future<void> addSecretary({
    required int clinicId,
    required String firstName,
    required String lastName,
    required String phone,
    required String password,
  });

  Future<void> updateSecretary({
    required int clinicId,
    required int secretaryId,
    String? firstName,
    String? lastName,
    bool? isActive,
  });

  Future<void> removeSecretaryFromClinic(int clinicId, int secretaryId);

  Future<void> deleteSecretaryPermanently(int clinicId, int secretaryId);
}
