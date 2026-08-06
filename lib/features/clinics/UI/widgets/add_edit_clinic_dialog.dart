import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medica_admin/core/helpers/Image_Picker_helper.dart';
import 'package:medica_admin/core/helpers/app_colors.dart';
import 'package:medica_admin/features/clinics/logic/clinic_bloc/clinic_bloc.dart';
import 'package:medica_admin/features/clinics/logic/clinic_bloc/clinic_event.dart';
import 'package:medica_admin/features/clinics/logic/clinic_bloc/clinic_state.dart'; // تأكد من استيراد الـ States
import '../../data/models/clinic_model.dart';

class AddEditClinicDialog extends StatefulWidget {
  final ClinicModel? clinic;

  const AddEditClinicDialog({super.key, this.clinic});

  @override
  State<AddEditClinicDialog> createState() => _AddEditClinicDialogState();
}

class _AddEditClinicDialogState extends State<AddEditClinicDialog> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _phoneController;
  late TextEditingController _emergencyPhoneController;
  late TextEditingController _emailController;
  late TextEditingController _bankAccountController;

  PickedFileData? _selectedImage;
  bool get _isEditMode => widget.clinic != null;

  // 🔑 1. متغير متابعة حالة التحميل داخل النافذة فقط
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.clinic?.name ?? '');
    _addressController = TextEditingController(
      text: widget.clinic?.address ?? '',
    );
    _phoneController = TextEditingController(text: widget.clinic?.phone ?? '');
    _emergencyPhoneController = TextEditingController(
      text: widget.clinic?.emergencyPhone ?? '',
    );
    _emailController = TextEditingController(text: widget.clinic?.email ?? '');
    _bankAccountController = TextEditingController(
      text: widget.clinic?.bankAccount ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emergencyPhoneController.dispose();
    _emailController.dispose();
    _bankAccountController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedData = await ImagePickerHelper.picImageFromGallery();
    if (pickedData != null) {
      setState(() {
        _selectedImage = pickedData;
      });
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      // 🔑 2. إيقاف الإغلاق الفوري وتفعيل التحميل بالزر
      setState(() {
        _isSubmitting = true;
      });

      if (_isEditMode) {
        context.read<ClinicsBloc>().add(
          UpdateClinicEvent(
            clinicId: widget.clinic!.id,
            name: _nameController.text.trim(),
            address: _addressController.text.trim(),
            phone: _phoneController.text.trim(),
            emergencyPhone: _emergencyPhoneController.text.trim(),
            email: _emailController.text.trim(),
            bankAccount: _bankAccountController.text.trim(),
            logoFile: _selectedImage,
          ),
        );
      } else {
        context.read<ClinicsBloc>().add(
          AddClinicEvent(
            name: _nameController.text.trim(),
            address: _addressController.text.trim(),
            phone: _phoneController.text.trim(),
            emergencyPhone: _emergencyPhoneController.text.trim(),
            email: _emailController.text.trim(),
            bankAccount: _bankAccountController.text.trim(),
            logoFile: _selectedImage,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 🔑 3. تغليف النافذة بـ BlocListener لمتابعة النجاح أو الفشل دون إغلاق عشواءي
    return BlocListener<ClinicsBloc, ClinicsState>(
      listener: (context, state) {
        if (state is ClinicsSuccessState || state is ClinicActionSuccessState) {
          Navigator.pop(context); // الإغلاق فقط عند النجاح
        } else if (state is ClinicsErrorState) {
          setState(() {
            _isSubmitting = false; // إعادة الزر لحالته الأصلية عند وقوع خطأ
          });
        }
      },
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 520,
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1️⃣ عنوان المودال
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _isEditMode ? 'تعديل عيادة' : 'إضافة عيادة',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkHeader,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(
                          Icons.close,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                  const Divider(),
                  const SizedBox(height: 16),

                  // 2️⃣ حقول الإدخال
                  _buildTextField(
                    'اسم العيادة *',
                    _nameController,
                    isRequired: true,
                  ),
                  _buildTextField(
                    'العنوان *',
                    _addressController,
                    isRequired: true,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          'الهاتف *',
                          _phoneController,
                          isRequired: true,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTextField(
                          'هاتف الطوارئ *',
                          _emergencyPhoneController,
                          isRequired: true,
                        ),
                      ),
                    ],
                  ),
                  _buildTextField('البريد الإلكتروني', _emailController),
                  _buildTextField('الحساب البنكي', _bankAccountController),

                  const SizedBox(height: 12),
                  const Text(
                    'شعار العيادة',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                  const SizedBox(height: 8),

                  // 3️⃣ منطقة اختيار الشعار
                  _buildImagePickerArea(),

                  const SizedBox(height: 24),

                  // 4️⃣ أزرار الإجراءات
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isSubmitting ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          // 🔑 4. عرض مؤشر التحميل داخل الزر
                          child: _isSubmitting
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  _isEditMode ? 'حفظ التغييرات' : 'حفظ',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _isSubmitting
                              ? null
                              : () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'إلغاء',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool isRequired = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            validator: (value) {
              if (isRequired && (value == null || value.trim().isEmpty)) {
                return 'هذا الحقل مطلوب';
              }
              return null;
            },
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.textField,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.borderColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.borderColor),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePickerArea() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Row(
        children: [
          if (_selectedImage != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.memory(
                _selectedImage!.bytes,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
              ),
            )
          else if (_isEditMode && widget.clinic?.logo != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              // 🔑 5. حماية الصورة بواسطة errorBuilder عند الفشل
              child: Image.network(
                widget.clinic!.logo!,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 60,
                    height: 60,
                    color: Colors.grey.shade200,
                    child: const Icon(
                      Icons.broken_image_outlined,
                      color: Colors.grey,
                      size: 26,
                    ),
                  );
                },
              ),
            )
          else
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.lightPrimary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.image_outlined,
                color: AppColors.primary,
                size: 28,
              ),
            ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              OutlinedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.upload_outlined, size: 16),
                label: Text(
                  // 🔑 6. إصلاح شرط النص
                  (_selectedImage != null || widget.clinic?.logo != null)
                      ? 'تغيير الصورة'
                      : 'اختر صورة',
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'الملفات المسموحة: PNG, JPG, WEBP (الحد الأقصى 2MB)',
                style: TextStyle(fontSize: 10, color: AppColors.textTertiary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
