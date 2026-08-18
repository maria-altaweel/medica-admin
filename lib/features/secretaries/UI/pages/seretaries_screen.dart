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
import 'package:medica_admin/features/doctors/ui/widgets/select_clinic_dialog.dart';
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
  ClinicModel? currentClinicObj;

  @override
  void initState() {
    super.initState();
    selectedClinicId = widget.initialClinicId;
  }

  // 👈 دالة فتح نافذة اختيار العيادة باستخدام الـ parentContext الصحيح
  void _openSelectClinicDialog(
    BuildContext parentContext,
    List<ClinicModel> clinics,
  ) {
    if (selectedClinicId != null && clinics.isNotEmpty) {
      try {
        currentClinicObj = clinics.firstWhere((c) => c.id == selectedClinicId);
      } catch (_) {
        currentClinicObj = clinics.first;
      }
    } else if (clinics.isNotEmpty) {
      currentClinicObj = clinics.first;
    }

    showDialog(
      context: parentContext,
      builder: (_) => BlocProvider(
        create: (context) => getIt<ClinicsBloc>()..add(FetchClinicsEvent()),
        child: SelectClinicDialog(
          clinics: clinics,
          selectedClinic: currentClinicObj,
          onClinicSelected: (clinic) {
            setState(() {
              selectedClinicId = clinic.id;
              currentClinicObj = clinic;
            });

            // 🔥 هنا استخدام الـ parentContext لضمان قراءة الـ SecretaryCubit وتحديث البيانات
            parentContext.read<SecretaryCubit>().fetchSecretaries(clinic.id);
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
        BlocProvider(create: (context) => getIt<SecretaryCubit>()),
      ],
      child: Builder(
        builder: (innerContext) {
          return Scaffold(
            backgroundColor: AppColors.pageBackground,
            body: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. الهيدر واختيار العيادة
                  BlocConsumer<ClinicsBloc, ClinicsState>(
                    listener: (context, state) {
                      if (state is ClinicsSuccessState &&
                          state.clinics.isNotEmpty) {
                        if (selectedClinicId == null) {
                          setState(() {
                            selectedClinicId = state.clinics.first.id;
                            currentClinicObj = state.clinics.first;
                          });
                          context.read<SecretaryCubit>().fetchSecretaries(
                            selectedClinicId!,
                          );
                        } else {
                          try {
                            currentClinicObj = state.clinics.firstWhere(
                              (c) => c.id == selectedClinicId,
                            );
                          } catch (_) {
                            currentClinicObj = state.clinics.first;
                          }
                        }
                      }
                    },
                    builder: (context, state) {
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
                        onOpenClinicDialog: () =>
                            _openSelectClinicDialog(innerContext, clinics),
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
                                return const Center(
                                  child: AppLoadingIndicator(),
                                );
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
          );
        },
      ),
    );
  }
}
