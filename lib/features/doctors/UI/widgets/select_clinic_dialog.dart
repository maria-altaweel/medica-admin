import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medica_admin/core/helpers/App_Colors.dart';
import 'package:medica_admin/features/clinics/data/models/clinic_model.dart';
import 'package:medica_admin/features/clinics/logic/clinic_bloc/clinic_bloc.dart';
import 'package:medica_admin/features/clinics/logic/clinic_bloc/clinic_state.dart';

class SelectClinicDialog extends StatefulWidget {
  final List<ClinicModel>? clinics;
  final ClinicModel? selectedClinic;
  final ValueChanged<ClinicModel> onClinicSelected;

  const SelectClinicDialog({
    super.key,
    this.clinics,
    required this.selectedClinic,
    required this.onClinicSelected,
  });

  @override
  State<SelectClinicDialog> createState() => _SelectClinicDialogState();
}

class _SelectClinicDialogState extends State<SelectClinicDialog> {
  ClinicModel? tempSelected;

  @override
  void initState() {
    super.initState();
    tempSelected = widget.selectedClinic;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.scaffoldBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 440,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.75,
        ),
        padding: const EdgeInsets.all(24),
        child: BlocBuilder<ClinicsBloc, ClinicsState>(
          builder: (context, state) {
            if (state is ClinicsLoadingState) {
              return const SizedBox(
                height: 200,
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              );
            }

            if (state is ClinicsErrorState) {
              return SizedBox(
                height: 150,
                child: Center(
                  child: Text(
                    'خطأ في التحميل: ${state.errorMessage}',
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              );
            }

            List<ClinicModel> currentClinics = widget.clinics ?? [];
            if (state is ClinicsSuccessState) {
              currentClinics = state.clinics;
            }

            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'اختر العيادة',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkHeader,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: AppColors.textTertiary,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Flexible(
                  child: currentClinics.isEmpty
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20.0),
                            child: Text(
                              'لا توجد عيادات متاحة',
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          itemCount: currentClinics.length,
                          itemBuilder: (context, index) {
                            final clinic = currentClinics[index];
                            final isSelected = tempSelected?.id == clinic.id;
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.lightPrimary
                                    : AppColors.cardBackground,
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.borderColor,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                leading: Radio<int>(
                                  value: clinic.id,
                                  groupValue: tempSelected?.id,
                                  activeColor: AppColors.primary,
                                  onChanged: (_) {
                                    setState(() {
                                      tempSelected = clinic;
                                    });
                                  },
                                ),
                                title: Text(
                                  clinic.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                subtitle: Text(
                                  clinic.address ?? '',
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 13,
                                  ),
                                ),
                                trailing: const Icon(
                                  Icons.local_hospital_outlined,
                                  color: AppColors.primary,
                                ),
                                onTap: () {
                                  setState(() {
                                    tempSelected = clinic;
                                  });
                                },
                              ),
                            );
                          },
                        ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      if (tempSelected != null) {
                        widget.onClinicSelected(tempSelected!);
                      }
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'تأكيد الاختيار',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
