import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medica_admin/core/helpers/App_Colors.dart';
import 'package:medica_admin/core/helpers/AppsnackBar.dart';
import 'package:medica_admin/core/helpers/Image_Picker_helper.dart';
import 'package:medica_admin/features/ads/data/models/ad_model.dart';
import 'package:medica_admin/features/ads/logic/ad_cubit/ad_cubit.dart';

class AddEditAdDialog extends StatefulWidget {
  final int clinicId;
  final String clinicName;
  final AdModel? ad;

  const AddEditAdDialog({
    super.key,
    required this.clinicId,
    required this.clinicName,
    this.ad,
  });

  @override
  State<AddEditAdDialog> createState() => _AddEditAdDialogState();
}

class _AddEditAdDialogState extends State<AddEditAdDialog> {
  PickedFileData? pickedImage;
  bool isLoading = false;

  String _getArabicErrorMessage(String serverError) {
    debugPrint(
      "=== SERVER ERROR: $serverError ===",
    ); // طباعة الخطأ القادم من السيرفر لمعرفته وهندسته

    if (serverError.contains("Unauthorized") || serverError.contains("401")) {
      return "انتهت صلاحية الجلسة، يرجى تسجيل الدخول مجدداً";
    } else if (serverError.contains("Network") ||
        serverError.contains("Connection")) {
      return "لا يوجد اتصال بالإنترنت، يرجى التحقق من الشبكة";
    } else if (serverError.contains("Too large") ||
        serverError.contains("size")) {
      return "حجم الصورة كبير جداً، الحد الأقصى هو 2MB";
    } else if (serverError.contains("404")) {
      return "الإعلان أو العيادة غير موجودة";
    }
    return "حدث خطأ غير متوقع: $serverError";
  }

  @override
  Widget build(BuildContext context) {
    final bool isEditing = widget.ad != null;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: AppColors.scaffoldBackground,
      title: Text(
        isEditing ? 'تعديل الإعلان' : 'إضافة إعلان جديد',
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
      content: SizedBox(
        width: 450,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'العيادة',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.textField,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.borderColor),
                ),
                child: Text(
                  widget.clinicName,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                isEditing ? 'تغيير الصورة *' : 'صورة الإعلان *',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              if (isEditing &&
                  pickedImage == null &&
                  widget.ad?.image != null) ...[
                const Text(
                  'الصورة الحالية:',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    widget.ad!.image!,
                    height: 140,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 140,
                      width: double.infinity,
                      color: AppColors.textField,
                      child: const Icon(
                        Icons.broken_image,
                        color: AppColors.textSecondary,
                        size: 40,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              InkWell(
                onTap: () async {
                  final image = await ImagePickerHelper.picImageFromGallery();
                  if (image != null) {
                    setState(() {
                      pickedImage = image;
                    });
                  }
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.textField,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.5),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.cloud_upload_outlined,
                        size: 40,
                        color: AppColors.primary,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        pickedImage != null
                            ? pickedImage!.name
                            : (isEditing
                                  ? 'رفع صورة جديدة مطلوبة للتعديل *'
                                  : 'رفع صورة الإعلان *'),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        '(2MB الحد الأقصى) PNG, JPG, JPEG',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'إلغاء',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          onPressed: isLoading
              ? null
              : () async {
                  // التحقق من اختيار الصورة في حالة الإضافة أو التعديل
                  if (pickedImage == null) {
                    Appsnackbar.showError(
                      context,
                      isEditing.toString().contains(
                            'true',
                          ) // للتوضيح، الشرط التالي يفصل الرسالة بدقة:
                          ? 'الرجاء اختيار صورة جديدة لتعديل الإعلان'
                          : 'الرجاء اختيار صورة للإعلان',
                    );
                    return;
                  }

                  setState(() {
                    isLoading = true;
                  });

                  final adCubit = context.read<AdCubit>();

                  try {
                    if (isEditing) {
                      await adCubit.updateAd(
                        adId: widget.ad!.id,
                        image: pickedImage!,
                      );
                    } else {
                      await adCubit.createAd(
                        clinicId: widget.clinicId,
                        image: pickedImage!,
                      );
                    }

                    if (context.mounted) {
                      Appsnackbar.showSuccess(
                        context,
                        isEditing
                            ? 'تم تعديل الإعلان بنجاح'
                            : 'تم إضافة الإعلان بنجاح',
                      );
                      Navigator.pop(context, true);
                    }
                  } catch (e) {
                    if (context.mounted) {
                      Appsnackbar.showError(
                        context,
                        _getArabicErrorMessage(e.toString()),
                      );
                    }
                  } finally {
                    if (mounted) {
                      setState(() {
                        isLoading = false;
                      });
                    }
                  }
                },
          child: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Text(
                  isEditing ? 'حفظ التعديلات' : 'إنشاء الإعلان',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ],
    );
  }
}
