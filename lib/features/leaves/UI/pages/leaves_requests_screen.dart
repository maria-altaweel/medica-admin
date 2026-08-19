import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medica_admin/core/helpers/App_Colors.dart';
import 'package:medica_admin/core/networking/service_locator.dart';
import 'package:medica_admin/features/clinics/data/models/clinic_model.dart';
import 'package:medica_admin/features/clinics/data/repos/clinic_repo.dart';
import 'package:medica_admin/features/clinics/logic/clinic_bloc/clinic_bloc.dart';
import 'package:medica_admin/features/clinics/logic/clinic_bloc/clinic_event.dart';
import 'package:medica_admin/features/doctors/ui/widgets/select_clinic_dialog.dart';
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

  // 👇 دالة إعادة ضبط الفلاتر بالكامل وتصفير القيم
  void _resetFilters() {
    setState(() {
      selectedStatus = null;
      searchQuery = '';
      dateFrom = null;
      dateTo = null;
    });
    _fetchLeaveRequests();
  }

  // دالة فتح نافذة اختيار العيادة باستخدام الديالوج الجديد الموحد
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
    final parentContext = context;
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: parentContext.read<LeaveCubit>(),
        child: AlertDialog(
          content: SizedBox(
            width: 700,
            child: LeaveRequestDetailsPanel(
              selectedLeave: leave,
              currentClinic: currentClinic!,
            ),
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
            // 1. الهيدر
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
              onRefresh: _fetchLeaveRequests,
            ),
            const SizedBox(height: 20),

            // 2. شريط الفلاتر والبحث والتواريخ مع تمرير onReset
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
              onReset: _resetFilters, // 👈 أضيفت هنا بنجاح وبدون أخطاء
            ),
            const SizedBox(height: 20),

            // 3. الجدول بعرض الشاشة الكامل مع زر إعادة التحميل عند الأخطاء
            Expanded(
              child: LeaveRequestsTableCard(
                searchQuery: searchQuery,
                selectedLeave: null,
                onLeaveSelected: (leave) {
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
