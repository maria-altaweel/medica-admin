import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medica_admin/core/helpers/AppsnackBar.dart';
import 'package:medica_admin/core/helpers/app_colors.dart';
import 'package:medica_admin/core/widgets/App_Loadingindicator.dart';

import 'package:medica_admin/features/secretaries/data/models/secretary_model.dart';
import 'package:medica_admin/features/secretaries/logic/secretary_cubit/secretary_cubit.dart';
import 'package:medica_admin/features/secretaries/logic/secretary_cubit/secretary_state.dart';

abstract class SecretaryDialogs {
  // ---------------------------------------------------------------------------
  // 1. نافذة إضافة سكرتيرة جديدة
  // ---------------------------------------------------------------------------
  static void showAddDialog(BuildContext context, int clinicId) {
    final cubit = context.read<SecretaryCubit>();
    cubit.clearControllers();

    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: cubit,
        child: BlocListener<SecretaryCubit, SecretaryState>(
          listener: (context, state) {
            if (state is AddSecretarySuccessState) {
              Navigator.pop(dialogContext);
              Appsnackbar.showSuccess(context, state.message);
            } else if (state is AddSecretaryErrorState) {
              Appsnackbar.showError(context, state.message);
            }
          },
          child: Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: 420,
                child: Form(
                  key: cubit.formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.close,
                              color: AppColors.textTertiary,
                            ),
                            onPressed: () => Navigator.pop(dialogContext),
                          ),
                          const Text(
                            "إضافة سكرتيرة جديدة",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        "الاسم الأول *",
                        cubit.firstNameController,
                        "أدخل الاسم الأول",
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        "الاسم الأخير *",
                        cubit.lastNameController,
                        "أدخل الاسم الأخير",
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        "رقم الهاتف *",
                        cubit.phoneController,
                        "0999123456",
                        isPhone: true,
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        "كلمة المرور *",
                        cubit.passwordController,
                        "أدخل كلمة المرور",
                        isPassword: true,
                      ),
                      const SizedBox(height: 24),
                      BlocBuilder<SecretaryCubit, SecretaryState>(
                        builder: (context, state) {
                          if (state is AddSecretaryLoadingState) {
                            return const Center(
                              child: AppLoadingIndicator(size: 40),
                            );
                          }
                          return Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => Navigator.pop(dialogContext),
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(
                                      color: AppColors.borderColor,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                  ),
                                  child: const Text(
                                    "إلغاء",
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    if (cubit.formKey.currentState
                                            ?.validate() ??
                                        false) {
                                      cubit.addSecretary(clinicId);
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                  ),
                                  child: const Text(
                                    "إضافة",
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
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 2. نافذة تعديل سكرتيرة
  // ---------------------------------------------------------------------------
  static void showEditDialog(
    BuildContext context,
    int clinicId,
    SecretaryModel secretary,
  ) {
    final cubit = context.read<SecretaryCubit>();
    cubit.firstNameController.text = secretary.firstName;
    cubit.lastNameController.text = secretary.lastName;

    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: cubit,
        child: _EditSecretaryDialogContent(
          clinicId: clinicId,
          secretary: secretary,
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 3. نافذة إزالة سكرتيرة من العيادة (تعليق)
  // ---------------------------------------------------------------------------
  static void showRemoveDialog(
    BuildContext context,
    int clinicId,
    int secretaryId,
  ) {
    final cubit = context.read<SecretaryCubit>();

    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: cubit,
        child: BlocListener<SecretaryCubit, SecretaryState>(
          listener: (context, state) {
            if (state is DeleteSecretarySuccessState) {
              Navigator.pop(dialogContext);
              Appsnackbar.showSuccess(context, state.message);
            } else if (state is DeleteSecretaryErrorState) {
              Appsnackbar.showError(context, state.message);
            }
          },
          child: Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: 400,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircleAvatar(
                      radius: 30,
                      backgroundColor: AppColors.warningLight,
                      child: Icon(
                        Icons.person_off_outlined,
                        color: AppColors.warning,
                        size: 30,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "إزالة سكرتيرة من العيادة",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "هل أنت تأكد من إزالة هذه السكرتيرة من العيادة؟\nسيتم تعليق حسابها ولن تتمكن من الوصول للعيادة بعد الآن.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 24),
                    BlocBuilder<SecretaryCubit, SecretaryState>(
                      builder: (context, state) {
                        if (state is DeleteSecretaryLoadingState) {
                          return const Center(
                            child: AppLoadingIndicator(size: 40),
                          );
                        }
                        return Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => Navigator.pop(dialogContext),
                                child: const Text(
                                  "إلغاء",
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  cubit.removeSecretaryFromClinic(
                                    clinicId,
                                    secretaryId,
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.warning,
                                ),
                                child: const Text(
                                  "إزالة",
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
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 4. نافذة حذف سكرتيرة نهائياً
  // ---------------------------------------------------------------------------
  static void showDeleteDialog(
    BuildContext context,
    int clinicId,
    int secretaryId,
  ) {
    final cubit = context.read<SecretaryCubit>();

    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: cubit,
        child: BlocListener<SecretaryCubit, SecretaryState>(
          listener: (context, state) {
            if (state is DeleteSecretarySuccessState) {
              Navigator.pop(dialogContext);
              Appsnackbar.showSuccess(context, state.message);
            } else if (state is DeleteSecretaryErrorState) {
              Appsnackbar.showError(context, state.message);
            }
          },
          child: Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: 400,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircleAvatar(
                      radius: 30,
                      backgroundColor: AppColors.errorLight,
                      child: Icon(
                        Icons.delete_outline,
                        color: AppColors.error,
                        size: 30,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "حذف سكرتيرة نهائياً",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "هل أنت تأكد من حذف هذه السكرتيرة نهائياً؟\nسيتم حذف حسابها نهائياً ولا يمكن التراجع عن هذا الإجراء.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 24),
                    BlocBuilder<SecretaryCubit, SecretaryState>(
                      builder: (context, state) {
                        if (state is DeleteSecretaryLoadingState) {
                          return const Center(
                            child: AppLoadingIndicator(size: 40),
                          );
                        }
                        return Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => Navigator.pop(dialogContext),
                                child: const Text(
                                  "إلغاء",
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  cubit.deleteSecretaryPermanently(
                                    clinicId,
                                    secretaryId,
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.error,
                                ),
                                child: const Text(
                                  "حذف نهائياً",
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
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  static Widget _buildTextField(
    String label,
    TextEditingController controller,
    String hint, {
    bool isPassword = false,
    bool isPhone = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          obscureText: isPassword,
          keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
          validator: (val) =>
              (val == null || val.trim().isEmpty) ? "هذا الحقل مطلوب" : null,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              color: AppColors.textTertiary,
              fontSize: 13,
            ),
            filled: true,
            fillColor: AppColors.textField,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: AppColors.borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: AppColors.borderColor),
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Private Widget لتعديل سكرتيرة
// ---------------------------------------------------------------------------
class _EditSecretaryDialogContent extends StatefulWidget {
  final int clinicId;
  final SecretaryModel secretary;

  const _EditSecretaryDialogContent({
    required this.clinicId,
    required this.secretary,
  });

  @override
  State<_EditSecretaryDialogContent> createState() =>
      _EditSecretaryDialogContentState();
}

class _EditSecretaryDialogContentState
    extends State<_EditSecretaryDialogContent> {
  late bool isActive;
  final GlobalKey<FormState> _editFormKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    isActive = widget.secretary.isActive;
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SecretaryCubit>();
    return BlocListener<SecretaryCubit, SecretaryState>(
      listener: (context, state) {
        if (state is UpdateSecretarySuccessState) {
          Navigator.pop(context);
          Appsnackbar.showSuccess(context, state.message);
        } else if (state is UpdateSecretaryErrorState) {
          Appsnackbar.showError(context, state.message);
        }
      },
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SizedBox(
            width: 420,
            child: Form(
              key: _editFormKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.close,
                          color: AppColors.textTertiary,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Text(
                        "تعديل سكرتيرة",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SecretaryDialogs._buildTextField(
                    "الاسم الأول *",
                    cubit.firstNameController,
                    "",
                  ),
                  const SizedBox(height: 12),
                  SecretaryDialogs._buildTextField(
                    "الاسم الأخير *",
                    cubit.lastNameController,
                    "",
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Switch(
                        value: isActive,
                        activeColor: AppColors.success,
                        onChanged: (val) => setState(() => isActive = val),
                      ),
                      const Text(
                        "الحالة مفعلة",
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  BlocBuilder<SecretaryCubit, SecretaryState>(
                    builder: (context, state) {
                      if (state is UpdateSecretaryLoadingState) {
                        return const Center(
                          child: AppLoadingIndicator(size: 40),
                        );
                      }
                      return Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                  color: AppColors.borderColor,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                              child: const Text(
                                "إلغاء",
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                if (_editFormKey.currentState?.validate() ??
                                    false) {
                                  cubit.updateSecretary(
                                    clinicId: widget.clinicId,
                                    secretaryId: widget.secretary.id,
                                    firstName: cubit.firstNameController.text,
                                    lastName: cubit.lastNameController.text,
                                    isActive: isActive,
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                              child: const Text(
                                "حفظ التغييرات",
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
