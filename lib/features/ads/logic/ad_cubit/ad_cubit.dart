import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medica_admin/core/helpers/Image_Picker_helper.dart';
import 'package:medica_admin/features/ads/data/models/ad_model.dart';
import 'package:medica_admin/features/ads/data/repos/ad_repo.dart';
import 'ad_state.dart';

class AdCubit extends Cubit<AdState> {
  final AdRepository _adRepo;

  AdCubit(this._adRepo) : super(AdInitial());

  List<AdModel> adsList = [];
  int? _lastId;
  bool hasMoreAds = true;
  bool isFetchingPagination = false;

  /// 1. جلب الإعلانات
  Future<void> getAds({required int clinicId, bool isRefresh = false}) async {
    if (isRefresh) {
      _lastId = null;
      hasMoreAds = true;
      adsList.clear();
      emit(GetAdsLoading());
    } else {
      if (!hasMoreAds || isFetchingPagination) return;
      isFetchingPagination = true;
      emit(GetAdsPaginationLoading());
    }

    try {
      final response = await _adRepo.getAds(
        clinicId: clinicId,
        lastId: _lastId,
        limit: 15,
      );

      final List<AdModel> newAds = response['ads'];
      final Map<String, dynamic> pagination = response['pagination'];

      if (isRefresh) {
        adsList = newAds;
      } else {
        adsList.addAll(newAds);
      }

      // تحديث المرجع ليقرأه الـ UI كقائمة جديدة
      adsList = List.from(adsList);

      hasMoreAds = pagination['has_more'];
      _lastId = pagination['next_last_id'];
      isFetchingPagination = false;

      emit(GetAdsSuccess());
    } catch (e) {
      isFetchingPagination = false;
      if (isRefresh) {
        emit(GetAdsError(e.toString()));
      } else {
        emit(GetAdsPaginationError(e.toString()));
      }
    }
  }

  /// 2. إضافة إعلان
  /// 2. إضافة إعلان
  Future<void> createAd({
    required int clinicId,
    required PickedFileData image,
  }) async {
    emit(CreateAdLoading());
    try {
      await _adRepo.createAd(clinicId: clinicId, image: image);
      // فقط نصدر حالة النجاح بدون اللعب بالقائمة يدوياً
      emit(CreateAdSuccess("تم إضافة الإعلان بنجاح"));
    } catch (e) {
      emit(CreateAdError(e.toString()));
    }
  }

  /// 3. تعديل إعلان
  Future<void> updateAd({
    required int adId,
    required PickedFileData image,
  }) async {
    emit(UpdateAdLoading());
    try {
      await _adRepo.updateAd(adId: adId, image: image);
      emit(UpdateAdSuccess("تم تعديل صورة الإعلان بنجاح"));
    } catch (e) {
      emit(UpdateAdError(e.toString()));
    }
  }

  /// 4. حذف إعلان
  Future<void> deleteAd(int adId) async {
    emit(DeleteAdLoading(adId));
    try {
      final message = await _adRepo.deleteAd(adId: adId);
      emit(DeleteAdSuccess(message));
    } catch (e) {
      emit(DeleteAdError(e.toString()));
    }
  }

  /// 5. تفعيل / تعطيل حالة الإعلان (مع التحديث اللحظي Optimistic Update)
  Future<void> toggleAdStatus(int adId) async {
    final index = adsList.indexWhere((ad) => ad.id == adId);
    if (index == -1) return;

    // حفظ الحالة القديمة للرجوع إليها في حال فشل السيرفر
    final oldStatus = adsList[index].isActive;

    // 1. تغيير الحالة محلياً فوراً (عشان زر السويتش ما يرجع لحالته القديمة)
    adsList[index] = adsList[index].copyWith(isActive: !oldStatus);
    adsList = List.from(adsList);
    // نُصدر حالة نجاح مؤقتة ليقوم الجدول بإعادة الرسم فوراً
    emit(ToggleAdStatusSuccess("جاري تحديث الحالة..."));

    try {
      // 2. إرسال الطلب للسيرفر في الخلفية
      final updatedAd = await _adRepo.toggleAdStatus(adId: adId);

      // 3. تأكيد التحديث بالبيانات الراجعة من السيرفر
      adsList[index] = updatedAd;
      adsList = List.from(adsList);
      emit(ToggleAdStatusSuccess("تم تغيير حالة الإعلان بنجاح"));
    } catch (e) {
      // 4. لو صار خطأ بالانترنت، بنرجع الزر لحالته القديمة
      adsList[index] = adsList[index].copyWith(isActive: oldStatus);
      adsList = List.from(adsList);
      emit(ToggleAdStatusError(e.toString()));
    }
  }
}
