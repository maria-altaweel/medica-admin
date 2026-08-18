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
  String? selectedStatus;

  @override
  void didUpdateWidget(covariant DoctorsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isRequestsView != widget.isRequestsView) {
      _loadDoctorsData(context);
    }
  }

  void _loadDoctorsData(BuildContext context) {
    if (selectedClinic == null) return;

    final doctorCubit = context.read<DoctorCubit>();
    if (widget.isRequestsView) {
      doctorCubit.fetchDoctorRequests(selectedClinic!.id);
    } else {
      doctorCubit.fetchDoctors(selectedClinic!.id, status: selectedStatus);
    }
  }

  void _openSelectClinicDialog(BuildContext currentContext) {
    showDialog(
      context: currentContext,
      builder: (_) => BlocProvider(
        create: (context) => getIt<ClinicsBloc>()..add(FetchClinicsEvent()),
        child: SelectClinicDialog(
          clinics: const [],
          selectedClinic: selectedClinic,
          onClinicSelected: (clinic) {
            setState(() {
              selectedClinic = clinic;
              selectedStatus = null;
            });
            _loadDoctorsData(currentContext);
          },
        ),
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
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                              onChangeClinicTap: () =>
                                  _openSelectClinicDialog(context),
                            ),
                          ),
                          if (selectedClinic != null) ...[
                            const SizedBox(width: 16),
                            IconButton(
                              onPressed: () {
                                _loadDoctorsData(context);
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
                      if (!widget.isRequestsView && selectedClinic != null) ...[
                        const SizedBox(height: 24),
                        _buildFilterTabs(innerContext),
                      ],
                      const SizedBox(height: 24),
                      Expanded(child: _buildBodyContent(innerContext, state)),
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

  Widget _buildFilterTabs(BuildContext context) {
    return Row(
      children: [
        _buildFilterTab(context, title: 'الكل', value: null),
        const SizedBox(width: 12),
        _buildFilterTab(context, title: 'مقبول', value: 'approved'),
        const SizedBox(width: 12),
        _buildFilterTab(context, title: 'معلق', value: 'pending'),
        const SizedBox(width: 12),
        _buildFilterTab(context, title: 'مرفوض', value: 'rejected'),
      ],
    );
  }

  Widget _buildFilterTab(
    BuildContext context, {
    required String title,
    required String? value,
  }) {
    final isSelected = selectedStatus == value;
    return InkWell(
      onTap: () {
        if (selectedStatus != value) {
          setState(() {
            selectedStatus = value;
          });
          _loadDoctorsData(context);
        }
      },
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : Colors.grey.withOpacity(0.5),
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade700,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
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
          style: const TextStyle(color: Colors.grey, fontSize: 16),
        ),
      );
    }
    if (selectedClinic == null) {
      return const Center(
        child: Text(
          'لا توجد عيادات متاحة حالياً',
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
      );
    }

    return widget.isRequestsView
        ? DoctorRequestsTable(clinicId: selectedClinic!.id)
        : DoctorsTable(clinicId: selectedClinic!.id);
  }
}
