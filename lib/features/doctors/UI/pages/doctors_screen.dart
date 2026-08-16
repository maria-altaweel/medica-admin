import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medica_admin/core/helpers/App_Colors.dart';
import 'package:medica_admin/core/networking/service_locator.dart';
import 'package:medica_admin/features/clinics/data/models/clinic_model.dart';
import 'package:medica_admin/features/clinics/logic/clinic_bloc/clinic_bloc.dart';
import 'package:medica_admin/features/clinics/logic/clinic_bloc/clinic_event.dart';
import 'package:medica_admin/features/clinics/logic/clinic_bloc/clinic_state.dart';
import 'package:medica_admin/features/doctors/UI/widgets/doctors_header.dart';
import 'package:medica_admin/features/doctors/UI/widgets/doctors_requests_table.dart';
import 'package:medica_admin/features/doctors/UI/widgets/doctors_table.dart';
import 'package:medica_admin/features/doctors/logic/doctor_cubit/doctor_cubit.dart';
import 'package:medica_admin/features/doctors/ui/widgets/select_clinic_dialog.dart';

class DoctorsScreen extends StatefulWidget {
  final bool isRequestsView;

  const DoctorsScreen({super.key, this.isRequestsView = false});

  @override
  State<DoctorsScreen> createState() => _DoctorsScreenState();
}

class _DoctorsScreenState extends State<DoctorsScreen> {
  ClinicModel? selectedClinic;

  @override
  void didUpdateWidget(covariant DoctorsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isRequestsView != widget.isRequestsView) {
      _loadDoctorsData(context);
    }
  }

  // جلب البيانات بناءً على العيادة المختارة فقط
  void _loadDoctorsData(BuildContext context) {
    if (selectedClinic == null) return;

    final doctorCubit = context.read<DoctorCubit>();
    if (widget.isRequestsView) {
      doctorCubit.fetchDoctorRequests(selectedClinic!.id);
    } else {
      doctorCubit.fetchDoctors(selectedClinic!.id);
    }
  }

  // نافذة اختيار العيادة فقط
  void _openSelectClinicDialog(
    BuildContext currentContext,
    List<ClinicModel> clinics,
  ) {
    showDialog(
      context: currentContext,
      builder: (_) => SelectClinicDialog(
        clinics: clinics,
        selectedClinic: selectedClinic,
        onClinicSelected: (clinic) {
          setState(() {
            selectedClinic = clinic;
          });
          _loadDoctorsData(currentContext);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => getIt<ClinicsBloc>()..add(FetchClinicsEvent()),
        ),
        BlocProvider(create: (context) => getIt<DoctorCubit>()),
      ],
      child: Builder(
        builder: (innerContext) {
          return Scaffold(
            backgroundColor: AppColors.pageBackground,
            body: Padding(
              padding: const EdgeInsets.all(24.0),
              child: BlocConsumer<ClinicsBloc, ClinicsState>(
                listener: (context, state) {
                  // اختيار أول عيادة تلقائياً وجلب أطبائها
                  if (state is ClinicsSuccessState &&
                      state.clinics.isNotEmpty) {
                    if (selectedClinic == null) {
                      setState(() {
                        selectedClinic = state.clinics.first;
                      });
                      _loadDoctorsData(context);
                    }
                  }

                  if (state is ClinicsErrorState) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.errorMessage),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  List<ClinicModel> availableClinics = [];
                  if (state is ClinicsSuccessState) {
                    availableClinics = state.clinics;
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // الهيدر الرئيسي مع زر تحديث القائمة يدوياً (بدون سناك بار)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: DoctorsHeader(
                              title: widget.isRequestsView
                                  ? 'طلبات انضمام الأطباء'
                                  : 'الأطباء',
                              selectedClinicName:
                                  selectedClinic?.name ?? 'اختر العيادة',
                              onChangeClinicTap: () => _openSelectClinicDialog(
                                context,
                                availableClinics,
                              ),
                            ),
                          ),
                          // زر التحديث العلوي البسيط
                          if (selectedClinic != null) ...[
                            const SizedBox(width: 16),
                            IconButton(
                              onPressed: () {
                                _loadDoctorsData(
                                  context,
                                ); // يتم التحديث بصمت وبدون سناك بار مزعجة
                              },
                              icon: const Icon(
                                Icons.refresh,
                                color: AppColors.primary,
                              ),
                              tooltip: 'تحديث البيانات',
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 24),
                      Expanded(child: _buildBodyContent(context, state)),
                    ],
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBodyContent(BuildContext context, ClinicsState state) {
    if (state is ClinicsLoadingState && selectedClinic == null) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (state is ClinicsErrorState && selectedClinic == null) {
      return Center(
        child: Text(
          'حدث خطأ أثناء تحميل العيادات: ${state.errorMessage}',
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 16),
        ),
      );
    }

    if (selectedClinic == null) {
      return const Center(
        child: Text(
          'لا توجد عيادات متاحة حالياً',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
        ),
      );
    }

    // عرض الجدول مباشرة بدون تعقيد
    return widget.isRequestsView
        ? DoctorRequestsTable(clinicId: selectedClinic!.id)
        : DoctorsTable(clinicId: selectedClinic!.id);
  }
}
