import 'package:medica_admin/features/ads/data/models/ad_model.dart';

abstract class AdState {}

class AdInitial extends AdState {}

// ================== جلب الإعلانات ==================
class GetAdsLoading extends AdState {}

class GetAdsSuccess extends AdState {}

class GetAdsError extends AdState {
  final String error;
  GetAdsError(this.error);
}

// حالة خاصة بتحميل الدفعة الجديدة (Pagination) عشان ما نخفي الإعلانات القديمة
class GetAdsPaginationLoading extends AdState {}

class GetAdsPaginationError extends AdState {
  final String error;
  GetAdsPaginationError(this.error);
}

// ================== إضافة إعلان ==================
class CreateAdLoading extends AdState {}

class CreateAdSuccess extends AdState {
  final String message;
  CreateAdSuccess(this.message);
}

class CreateAdError extends AdState {
  final String error;
  CreateAdError(this.error);
}

// ================== تعديل إعلان ==================
class UpdateAdLoading extends AdState {}

class UpdateAdSuccess extends AdState {
  final String message;
  UpdateAdSuccess(this.message);
}

class UpdateAdError extends AdState {
  final String error;
  UpdateAdError(this.error);
}

// ================== حذف إعلان ==================
class DeleteAdLoading extends AdState {
  final int
  adId; // عشان نقدر نطلع مؤشر تحميل على زر الحذف الخاص بهاد الإعلان بالذات
  DeleteAdLoading(this.adId);
}

class DeleteAdSuccess extends AdState {
  final String message;
  DeleteAdSuccess(this.message);
}

class DeleteAdError extends AdState {
  final String error;
  DeleteAdError(this.error);
}

// ================== تفعيل / تعطيل إعلان ==================
class ToggleAdStatusLoading extends AdState {
  final int adId;
  ToggleAdStatusLoading(this.adId);
}

class ToggleAdStatusSuccess extends AdState {
  final String message;
  ToggleAdStatusSuccess(this.message);
}

class ToggleAdStatusError extends AdState {
  final String error;
  ToggleAdStatusError(this.error);
}
