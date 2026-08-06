import 'package:medica_admin/features/secretaries/data/models/secretary_model.dart';

abstract class SecretaryState {}

class SecretaryInitialState extends SecretaryState {}

// حالات جلب السكرتارية
class GetSecretariesLoadingState extends SecretaryState {}

class GetSecretariesSuccessState extends SecretaryState {
  final List<SecretaryModel> secretaries;
  GetSecretariesSuccessState(this.secretaries);
}

class GetSecretariesErrorState extends SecretaryState {
  final String message;
  GetSecretariesErrorState(this.message);
}

// حالات الإضافة
class AddSecretaryLoadingState extends SecretaryState {}

class AddSecretarySuccessState extends SecretaryState {
  final String message;
  AddSecretarySuccessState(this.message);
}

class AddSecretaryErrorState extends SecretaryState {
  final String message;
  AddSecretaryErrorState(this.message);
}

// حالات التعديل والتفعيل/الإيقاف
class UpdateSecretaryLoadingState extends SecretaryState {}

class UpdateSecretarySuccessState extends SecretaryState {
  final String message;
  UpdateSecretarySuccessState(this.message);
}

class UpdateSecretaryErrorState extends SecretaryState {
  final String message;
  UpdateSecretaryErrorState(this.message);
}

// حالات الإزالة والحذف
class DeleteSecretaryLoadingState extends SecretaryState {}

class DeleteSecretarySuccessState extends SecretaryState {
  final String message;
  DeleteSecretarySuccessState(this.message);
}

class DeleteSecretaryErrorState extends SecretaryState {
  final String message;
  DeleteSecretaryErrorState(this.message);
}
