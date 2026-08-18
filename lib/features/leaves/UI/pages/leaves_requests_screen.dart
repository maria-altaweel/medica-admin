import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medica_admin/core/helpers/App_Colors.dart';
import 'package:medica_admin/core/networking/service_locator.dart';
import 'package:medica_admin/features/clinics/data/models/clinic_model.dart';
import 'package:medica_admin/features/clinics/data/repos/clinic_repo.dart';
import 'package:medica_admin/features/clinics/logic/clinic_bloc/clinic_bloc.dart'; // 👈 أضفنا استدعاء البلوك
import 'package:medica_admin/features/clinics/logic/clinic_bloc/clinic_event.dart'; // 👈 أضفنا الحدث
import 'package:medica_admin/features/doctors/ui/widgets/select_clinic_dialog.dart'; // 👈 ديلاوج العيادات الموحد
import 'package:medica_admin/features/leaves/UI/widgets/leave_requests_details_panel.dart';
import 'package:medica_admin/features/leaves/UI/widgets/leave_requests_fillter.dart';
import 'package:medica_admin/features/leaves/UI/widgets/leave_requests_header.dart';
import 'package:medica_admin/features/leaves/UI/widgets/leave_requests_table.dart';
import 'package:medica_admin/features/leaves/data/models/leave_model.dart';
import 'package:medica_admin/features/leaves/logic/leave_cubit/leave_cubit.dart';

class LeaveRequestsScreen extends StatefulWidget {
  const LeaveRequestsScreen({super.key});

  @override
  State<LeaveRequestsScreen> createState() => _LeaveRequestsScreenState();
}

class _LeaveRequestsScreenState extends State<LeaveRequestsScreen> {
  List<ClinicModel> clinics = [];
  ClinicModel? currentClinic;
  String? selectedStatus;
  String searchQuery = '';
  String? dateFrom;
  String? dateTo;
  bool isLoadingClinics = true;

  @override
  void initState() {
    super.initState();
    _fetchClinicsAndLeaves();
  }

  Future<void> _fetchClinicsAndLeaves() async {
    try {
      final clinicsList = await getIt<ClinicsRepo>().getClinics();
      if (clinicsList.isNotEmpty) {
        setState(() {
          clinics = clinicsList;
          currentClinic = clinicsList.first;
          isLoadingClinics = false;
        });
        _fetchLeaveRequests();
      } else {
        setState(() {
          isLoadingClinics = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoadingClinics = false;
      });
    }
  }

  void _fetchLeaveRequests() {
    if (currentClinic == null) return;
    context.read<LeaveCubit>().getLeaveRequests(
      clinicId: currentClinic!.id,
      status: selectedStatus,
      dateFrom: dateFrom,
      dateTo: dateTo,
    );
  }

  // 👇 دالة فتح نافذة اختيار العيادة باستخدام الديالوج الجديد الموحد
  void _openSelectClinicDialog(BuildContext currentContext) {
    showDialog(
      context: currentContext,
      builder: (_) => BlocProvider(
        create: (context) => getIt<ClinicsBloc>()..add(FetchClinicsEvent()),
        child: SelectClinicDialog(
          clinics: clinics,
          selectedClinic: currentClinic,
          onClinicSelected: (clinic) {
            setState(() {
              currentClinic = clinic;
            });
            _fetchLeaveRequests();
          },
        ),
      ),
    );
  }

  // فتح نافذة التفاصيل والإجراءات بشكل منبثق واحترافي (Dialog)
  void _showLeaveDetailsDialog(LeaveModel leave) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: SizedBox(
          width: 700,
          child: LeaveRequestDetailsPanel(
            selectedLeave: leave,
            currentClinic: currentClinic!,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoadingClinics) {
      return const Scaffold(
        backgroundColor: AppColors.pageBackground,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (currentClinic == null || clinics.isEmpty) {
      return const Scaffold(
        backgroundColor: AppColors.pageBackground,
        body: Center(child: Text('لا توجد عيادات متاحة حالياً')),
      );
    }
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. الهيدر مع تمرير دالة فتح الديالوج الجديدة بأمان
            LeaveRequestsHeader(
              currentClinic: currentClinic!,
              clinics: clinics,
              onClinicChanged: (clinic) {
                setState(() {
                  currentClinic = clinic;
                });
                _fetchLeaveRequests();
              },
              onOpenClinicDialog: () => _openSelectClinicDialog(context),
            ),
            const SizedBox(height: 20),

            // 2. شريط الفلاتر والبحث والتواريخ
            LeaveRequestsFilterBar(
              selectedStatus: selectedStatus,
              dateFrom: dateFrom,
              dateTo: dateTo,
              onStatusChanged: (status) {
                setState(() => selectedStatus = status);
                _fetchLeaveRequests();
              },
              onSearchChanged: (query) {
                setState(() => searchQuery = query);
              },
              onDateFromChanged: (date) {
                setState(() => dateFrom = date);
                _fetchLeaveRequests();
              },
              onDateToChanged: (date) {
                setState(() => dateTo = date);
                _fetchLeaveRequests();
              },
            ),
            const SizedBox(height: 20),

            // 3. الجدول يمتد بعرض الشاشة بالكامل (Full Width)
            Expanded(
              child: LeaveRequestsTableCard(
                searchQuery: searchQuery,
                selectedLeave: null,
                onLeaveSelected: (leave) {
                  // عند الضغط على زر العين، يتم فتح التفاصيل في نافذة منبثقة Dialog
                  _showLeaveDetailsDialog(leave);
                },
                onRefreshNeeded: () {
                  _fetchLeaveRequests();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
