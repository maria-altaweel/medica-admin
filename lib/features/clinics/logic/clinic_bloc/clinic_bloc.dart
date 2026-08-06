import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medica_admin/features/clinics/data/repos/clinic_repo.dart';
import 'package:medica_admin/features/clinics/logic/clinic_bloc/clinic_event.dart';
import 'package:medica_admin/features/clinics/logic/clinic_bloc/clinic_state.dart';

class ClinicsBloc extends Bloc<ClinicsEvent, ClinicsState> {
  final ClinicsRepo _clinicsRepo;

  ClinicsBloc(this._clinicsRepo) : super(ClinicsInitialState()) {
    // 1. جلب قائمة العيادات
    on<FetchClinicsEvent>((event, emit) async {
      emit(ClinicsLoadingState());
      try {
        final clinics = await _clinicsRepo.getClinics();
        emit(ClinicsSuccessState(clinics));
      } catch (e) {
        emit(ClinicsErrorState(e.toString().replaceAll('Exception: ', '')));
      }
    });

    // 2. جلب تفاصيل عيادة
    on<FetchClinicDetailsEvent>((event, emit) async {
      emit(ClinicsLoadingState());
      try {
        final details = await _clinicsRepo.getClinicDetails(event.clinicId);
        emit(ClinicDetailsSuccessState(details));
      } catch (e) {
        emit(ClinicsErrorState(e.toString().replaceAll('Exception: ', '')));
      }
    });

    // 3. جلب أطباء تخصص محدد
    on<FetchClinicDoctorsEvent>((event, emit) async {
      emit(ClinicsLoadingState());
      try {
        final doctors = await _clinicsRepo.getClinicDoctorsBySpecialization(
          clinicId: event.clinicId,
          specializationId: event.specializationId,
        );
        emit(ClinicDoctorsSuccessState(doctors));
      } catch (e) {
        emit(ClinicsErrorState(e.toString().replaceAll('Exception: ', '')));
      }
    });

    // 4. إضافة عيادة
    on<AddClinicEvent>((event, emit) async {
      emit(ClinicsLoadingState());
      try {
        await _clinicsRepo.addClinic(
          name: event.name,
          address: event.address,
          phone: event.phone,
          emergencyPhone: event.emergencyPhone,
          email: event.email,
          bankAccount: event.bankAccount,
          logoFile: event.logoFile, // أصبح يستقبل PickedFileData? بدون أي تعارض
        );
        emit(ClinicActionSuccessState('تمت إضافة العيادة بنجاح'));
        add(FetchClinicsEvent()); // إعادة جلب القائمة
      } catch (e) {
        emit(ClinicsErrorState(e.toString().replaceAll('Exception: ', '')));
      }
    });

    // 5. تعديل عيادة
    on<UpdateClinicEvent>((event, emit) async {
      emit(ClinicsLoadingState());
      try {
        await _clinicsRepo.updateClinic(
          clinicId: event.clinicId,
          name: event.name,
          address: event.address,
          phone: event.phone,
          emergencyPhone: event.emergencyPhone,
          email: event.email,
          bankAccount: event.bankAccount,
          logoFile: event.logoFile, // أصبح يستقبل PickedFileData? بدون أي تعارض
        );
        emit(ClinicActionSuccessState('تم تعديل بيانات العيادة بنجاح'));
        add(FetchClinicsEvent());
      } catch (e) {
        emit(ClinicsErrorState(e.toString().replaceAll('Exception: ', '')));
      }
    });

    // 6. حذف عيادة
    on<DeleteClinicEvent>((event, emit) async {
      emit(ClinicsLoadingState());
      try {
        await _clinicsRepo.deleteClinic(event.clinicId);
        emit(ClinicActionSuccessState('تم حذف العيادة بنجاح'));
        add(FetchClinicsEvent());
      } catch (e) {
        emit(ClinicsErrorState(e.toString().replaceAll('Exception: ', '')));
      }
    });
  }
}
