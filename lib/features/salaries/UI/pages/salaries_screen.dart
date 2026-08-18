import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart'; // تأكدي من وجود هاد الـ import عشان التواريخ
import 'package:medica_admin/core/helpers/app_colors.dart';
import 'package:medica_admin/core/networking/service_locator.dart';
import 'package:medica_admin/features/clinics/data/models/clinic_model.dart';
import 'package:medica_admin/features/clinics/logic/clinic_bloc/clinic_bloc.dart';
import 'package:medica_admin/features/clinics/logic/clinic_bloc/clinic_event.dart';
import 'package:medica_admin/features/clinics/logic/clinic_bloc/clinic_state.dart';
import 'package:medica_admin/features/doctors/ui/widgets/select_clinic_dialog.dart';
import 'package:medica_admin/features/salaries/UI/widget/salaries_filtter_widget.dart';
import 'package:medica_admin/features/salaries/UI/widget/salaries_header_widget.dart';
import 'package:medica_admin/features/salaries/UI/widget/salaries_table-widget.dart';
import 'package:medica_admin/features/salaries/logic/salary_cubit/salary_cubit.dart';

class SalariesScreen extends StatefulWidget {
  final int? initialClinicId;
  final VoidCallback? onNavigateToCreateSalary;

  const SalariesScreen({
    super.key,
    this.initialClinicId,
    this.onNavigateToCreateSalary,
  });

  @override
  State<SalariesScreen> createState() => _SalariesScreenState();
}

class _SalariesScreenState extends State<SalariesScreen> {
  int? selectedClinicId;
  String? selectedStatus;
  DateTime? periodStart;
  DateTime? periodEnd;
  List<ClinicModel> cachedClinics = [];

  @override
  void initState() {
    super.initState();
    selectedClinicId = widget.initialClinicId;
  }

  // دالة جلب البيانات المحدثة (مع التواريخ)
  void _fetchSalaries(BuildContext context) {
    context.read<SalaryCubit>().getSalaries(
      clinicId: selectedClinicId,
      status: selectedStatus,
      // تحويل التواريخ لنص يقرأه الـ Backend
      periodStart: periodStart != null
          ? DateFormat('yyyy-MM-dd').format(periodStart!)
          : null,
      periodEnd: periodEnd != null
          ? DateFormat('yyyy-MM-dd').format(periodEnd!)
          : null,
    );
  }

  void _openSelectClinicDialog(BuildContext parentContext) {
    showDialog(
      context: parentContext,
      builder: (_) => BlocProvider(
        create: (context) => getIt<ClinicsBloc>()..add(FetchClinicsEvent()),
        child: SelectClinicDialog(
          clinics: cachedClinics,
          selectedClinic: selectedClinicId != null && cachedClinics.isNotEmpty
              ? cachedClinics.firstWhere(
                  (c) => c.id == selectedClinicId,
                  orElse: () => cachedClinics.first,
                )
              : null,
          onClinicSelected: (clinic) {
            setState(() {
              selectedClinicId = clinic.id;
            });
            _fetchSalaries(parentContext);
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
        BlocProvider(
          create: (context) => getIt<SalaryCubit>()
            ..getSalaries(clinicId: selectedClinicId, status: selectedStatus),
        ),
      ],
      child: Builder(
        builder: (innerContext) {
          return Scaffold(
            backgroundColor: AppColors.scaffoldBackground,
            body: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BlocListener<ClinicsBloc, ClinicsState>(
                    listener: (context, state) {
                      if (state is ClinicsSuccessState) {
                        setState(() {
                          cachedClinics = state.clinics;
                        });
                      }
                    },
                    child: const SizedBox.shrink(),
                  ),
                  // الهيدر
                  SalariesHeaderWidget(
                    onGeneratePressed: () {
                      if (widget.onNavigateToCreateSalary != null) {
                        widget
                            .onNavigateToCreateSalary!(); // الانتقال لصفحة إنشاء الرواتب فوراً
                      }
                    },
                  ),
                  const SizedBox(height: 24),

                  // الفلتر (الذي يحتوي الآن على العيادة، الحالة، والتاريخ)
                  SalariesFiltersWidget(
                    selectedClinicName:
                        selectedClinicId != null && cachedClinics.isNotEmpty
                        ? cachedClinics
                              .firstWhere((c) => c.id == selectedClinicId)
                              .name
                        : null,
                    onClinicTap: () => _openSelectClinicDialog(innerContext),
                    selectedStatus: selectedStatus,
                    onStatusChanged: (status) {
                      setState(() => selectedStatus = status);
                      _fetchSalaries(innerContext);
                    },
                    periodStart: periodStart,
                    periodEnd: periodEnd,
                    onDateChanged: (start, end) {
                      setState(() {
                        periodStart = start;
                        periodEnd = end;
                      });
                      _fetchSalaries(innerContext);
                    },
                    onResetPressed: () {
                      setState(() {
                        selectedClinicId = null;
                        selectedStatus = null;
                        periodStart = null;
                        periodEnd = null;
                      });
                      _fetchSalaries(innerContext);
                    },
                  ),
                  const SizedBox(height: 24),

                  const Expanded(child: SalariesTableWidget()),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
