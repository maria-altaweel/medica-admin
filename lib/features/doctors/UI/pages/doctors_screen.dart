import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medica_admin/core/helpers/App_Colors.dart';
import 'package:medica_admin/core/networking/service_locator.dart';
import 'package:medica_admin/features/clinics/data/models/clinic_model.dart';
import 'package:medica_admin/features/clinics/logic/clinic_bloc/clinic_bloc.dart';
import 'package:medica_admin/features/clinics/logic/clinic_bloc/clinic_event.dart';
import 'package:medica_admin/features/clinics/logic/clinic_bloc/clinic_state.dart';
import 'package:medica_admin/features/doctors/ui/widgets/doctors_requests_table.dart';
import 'package:medica_admin/features/doctors/logic/doctor_cubit/doctor_cubit.dart';
import 'package:medica_admin/features/doctors/ui/widgets/doctors_header.dart';
import 'package:medica_admin/features/doctors/ui/widgets/doctors_table.dart';
import 'package:medica_admin/features/doctors/ui/widgets/select_clinic_dialog.dart';

class DoctorsScreen extends StatefulWidget {
  final bool isRequestsView; // false: قائمة الأطباء | true: طلبات الانضمام

  const DoctorsScreen({super.key, this.isRequestsView = false});

  @override
  State<DoctorsScreen> createState() => _DoctorsScreenState();
}

class _DoctorsScreenState extends State<DoctorsScreen> {
  ClinicModel? selectedClinic;
  String searchQuery = '';

  void _loadDoctorsData() {
    if (selectedClinic == null) return;
    final doctorCubit = context.read<DoctorCubit>();
    if (widget.isRequestsView) {
      doctorCubit.fetchDoctorRequests(selectedClinic!.id);
    } else {
      doctorCubit.fetchDoctors(selectedClinic!.id);
    }
  }

  void _openSelectClinicDialog(List<ClinicModel> clinics) {
    showDialog(
      context: context,
      builder: (context) => SelectClinicDialog(
        clinics: clinics,
        selectedClinic: selectedClinic,
        onClinicSelected: (clinic) {
          setState(() {
            selectedClinic = clinic;
          });
          _loadDoctorsData();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<ClinicsBloc>()..add(FetchClinicsEvent()),
      child: Scaffold(
        backgroundColor: AppColors.pageBackground,
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: BlocConsumer<ClinicsBloc, ClinicsState>(
            listener: (context, state) {
              if (state is ClinicsSuccessState && state.clinics.isNotEmpty) {
                if (selectedClinic == null) {
                  setState(() {
                    selectedClinic = state.clinics.first;
                  });
                  _loadDoctorsData();
                }
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
                  // 1. الهيدر العام مع زر إضافة طبيب للأنواع العادية
                  DoctorsHeader(
                    title: widget.isRequestsView
                        ? 'طلبات انضمام الأطباء'
                        : 'الأطباء',
                    selectedClinicName: selectedClinic?.name ?? 'اختر العيادة',
                    onChangeClinicTap: () =>
                        _openSelectClinicDialog(availableClinics),
                    onSearchChanged: (query) {
                      setState(() {
                        searchQuery = query;
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  // 2. المحتوى/الجدول حسب التاب المفتوح
                  Expanded(
                    child: selectedClinic == null
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                            ),
                          )
                        : widget.isRequestsView
                        ? DoctorRequestsTable(
                            clinicId: selectedClinic!.id,
                            searchQuery: searchQuery,
                          )
                        : DoctorsTable(
                            clinicId: selectedClinic!.id,
                            searchQuery: searchQuery,
                          ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
