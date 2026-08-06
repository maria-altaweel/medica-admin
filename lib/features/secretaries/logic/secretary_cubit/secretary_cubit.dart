import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medica_admin/features/secretaries/data/models/secretary_model.dart';
import 'package:medica_admin/features/secretaries/data/repos/secretary_repo.dart';
import 'secretary_state.dart';

class SecretaryCubit extends Cubit<SecretaryState> {
  final SecretaryRepo _secretaryRepo;

  SecretaryCubit(this._secretaryRepo) : super(SecretaryInitialState());

  List<SecretaryModel> secretariesList = [];

  // Controllers للنماذج (Forms)
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  // 1. جلب السكرتارية لعيادة محدده
  Future<void> fetchSecretaries(int clinicId) async {
    emit(GetSecretariesLoadingState());
    try {
      secretariesList = await _secretaryRepo.getSecretaries(clinicId);
      emit(GetSecretariesSuccessState(secretariesList));
    } catch (e) {
      emit(
        GetSecretariesErrorState(e.toString().replaceAll("Exception: ", "")),
      );
    }
  }

  // 2. إضافة سكرتيرة جديدة
  Future<void> addSecretary(int clinicId) async {
    if (!formKey.currentState!.validate()) return;

    emit(AddSecretaryLoadingState());
    try {
      await _secretaryRepo.addSecretary(
        clinicId: clinicId,
        firstName: firstNameController.text.trim(),
        lastName: lastNameController.text.trim(),
        phone: phoneController.text.trim(),
        password: passwordController.text,
      );
      clearControllers();
      emit(AddSecretarySuccessState("تمت إضافة السكرتيرة بنجاح"));
      fetchSecretaries(clinicId); // إعادة جلب القائمة بعد الإضافة
    } catch (e) {
      emit(AddSecretaryErrorState(e.toString().replaceAll("Exception: ", "")));
    }
  }

  // 3. تعديل بيانات سكرتيرة
  Future<void> updateSecretary({
    required int clinicId,
    required int secretaryId,
    String? firstName,
    String? lastName,
    bool? isActive,
  }) async {
    emit(UpdateSecretaryLoadingState());
    try {
      await _secretaryRepo.updateSecretary(
        clinicId: clinicId,
        secretaryId: secretaryId,
        firstName: firstName,
        lastName: lastName,
        isActive: isActive,
      );
      emit(UpdateSecretarySuccessState("تم تحديث البيانات بنجاح"));
      fetchSecretaries(clinicId);
    } catch (e) {
      emit(
        UpdateSecretaryErrorState(e.toString().replaceAll("Exception: ", "")),
      );
    }
  }

  // 4. إزالة سكرتيرة من العيادة
  Future<void> removeSecretaryFromClinic(int clinicId, int secretaryId) async {
    emit(DeleteSecretaryLoadingState());
    try {
      await _secretaryRepo.removeSecretaryFromClinic(clinicId, secretaryId);
      emit(DeleteSecretarySuccessState("تمت إزالة السكرتيرة من العيادة بنجاح"));
      fetchSecretaries(clinicId);
    } catch (e) {
      emit(
        DeleteSecretaryErrorState(e.toString().replaceAll("Exception: ", "")),
      );
    }
  }

  // 5. حذف سكرتيرة نهائياً
  Future<void> deleteSecretaryPermanently(int clinicId, int secretaryId) async {
    emit(DeleteSecretaryLoadingState());
    try {
      await _secretaryRepo.deleteSecretaryPermanently(clinicId, secretaryId);
      emit(DeleteSecretarySuccessState("تم حذف السكرتيرة نهائياً بنجاح"));
      fetchSecretaries(clinicId);
    } catch (e) {
      emit(
        DeleteSecretaryErrorState(e.toString().replaceAll("Exception: ", "")),
      );
    }
  }

  void clearControllers() {
    firstNameController.clear();
    lastNameController.clear();
    phoneController.clear();
    passwordController.clear();
  }

  @override
  Future<void> close() {
    firstNameController.dispose();
    lastNameController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    return super.close();
  }
}
