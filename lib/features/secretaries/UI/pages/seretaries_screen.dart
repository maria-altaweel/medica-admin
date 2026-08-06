import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medica_admin/core/helpers/AppsnackBar.dart';
import 'package:medica_admin/core/helpers/app_colors.dart';
import 'package:medica_admin/core/networking/service_locator.dart';
import 'package:medica_admin/core/widgets/App_Loadingindicator.dart';
import 'package:medica_admin/features/clinics/data/models/clinic_model.dart';
import 'package:medica_admin/features/clinics/logic/clinic_bloc/clinic_bloc.dart';
import 'package:medica_admin/features/clinics/logic/clinic_bloc/clinic_event.dart';
import 'package:medica_admin/features/clinics/logic/clinic_bloc/clinic_state.dart';
import 'package:medica_admin/features/secretaries/UI/widgets/secretaries_header.dart';
import 'package:medica_admin/features/secretaries/UI/widgets/secrtaries_table.dart';
import 'package:medica_admin/features/secretaries/logic/secretary_cubit/secretary_cubit.dart';
import 'package:medica_admin/features/secretaries/logic/secretary_cubit/secretary_state.dart';

class SecretariesScreen extends StatefulWidget {
  final int? initialClinicId;

  const SecretariesScreen({super.key, this.initialClinicId});

  @override
  State<SecretariesScreen> createState() => _SecretariesScreenState();
}

class _SecretariesScreenState extends State<SecretariesScreen> {
  int? selectedClinicId;

  @override
  void initState() {
    super.initState();
    selectedClinicId = widget.initialClinicId;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<ClinicsBloc>()..add(FetchClinicsEvent()),
      child: Scaffold(
        backgroundColor: AppColors.pageBackground,
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. الهيدر واختيار العيادة
              BlocConsumer<ClinicsBloc, ClinicsState>(
                listener: (context, state) {
                  // 🎯 ذكاء الحركة: إذا نجح جلب العيادات ولم يحدد المستخدم عيادة بعد
                  if (state is ClinicsSuccessState &&
                      state.clinics.isNotEmpty) {
                    if (selectedClinicId == null) {
                      setState(() {
                        selectedClinicId =
                            state.clinics.first.id; // تحديد أول عيادة
                      });
                      // جلب سكرتارية أول عيادة فوراً!
                      context.read<SecretaryCubit>().fetchSecretaries(
                        selectedClinicId!,
                      );
                    }
                  }
                },
                builder: (context, state) {
                  // تحويل القائمة صراحة إلى List<ClinicModel> لحل الخطأ 🛠️
                  List<ClinicModel> clinics = [];
                  if (state is ClinicsSuccessState) {
                    clinics = state.clinics;
                  }

                  return SecretariesHeader(
                    clinics: clinics,
                    selectedClinicId: selectedClinicId,
                    onClinicChanged: (clinicId) {
                      setState(() {
                        selectedClinicId = clinicId;
                      });
                      if (clinicId != null) {
                        context.read<SecretaryCubit>().fetchSecretaries(
                          clinicId,
                        );
                      }
                    },
                  );
                },
              ),
              const SizedBox(height: 24),

              // 2. جدول السكرتارية
              Expanded(
                child: selectedClinicId == null
                    ? const Center(
                        child: Text(
                          "يرجى اختيار عيادة لعرض السكرتارية الخاصة بها",
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 16,
                          ),
                        ),
                      )
                    : BlocConsumer<SecretaryCubit, SecretaryState>(
                        listener: (context, state) {
                          if (state is AddSecretarySuccessState) {
                            Appsnackbar.showSuccess(context, state.message);
                          } else if (state is AddSecretaryErrorState) {
                            Appsnackbar.showError(context, state.message);
                          } else if (state is DeleteSecretarySuccessState) {
                            Appsnackbar.showSuccess(context, state.message);
                          } else if (state is DeleteSecretaryErrorState) {
                            Appsnackbar.showError(context, state.message);
                          } else if (state is UpdateSecretarySuccessState) {
                            Appsnackbar.showSuccess(
                              context,
                              "تم تحديث البيانات بنجاح",
                            );
                          } else if (state is GetSecretariesErrorState) {
                            Appsnackbar.showError(context, state.message);
                          }
                        },
                        builder: (context, state) {
                          if (state is GetSecretariesLoadingState) {
                            return const Center(child: AppLoadingIndicator());
                          }

                          final cubit = context.read<SecretaryCubit>();
                          if (cubit.secretariesList.isEmpty) {
                            return const Center(
                              child: Text(
                                "لا يوجد سكرتارية مضافين لهذه العيادة بعد",
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 16,
                                ),
                              ),
                            );
                          }

                          return SecretariesTable(
                            secretaries: cubit.secretariesList,
                            clinicId: selectedClinicId!,
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
