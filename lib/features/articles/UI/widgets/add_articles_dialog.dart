import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medica_admin/core/helpers/Image_Picker_helper.dart';
import 'package:medica_admin/core/helpers/app_colors.dart';
import 'package:medica_admin/features/articles/data/models/article_model.dart';
import 'package:medica_admin/features/articles/logic/articles_cubit/articles_cubit.dart';
import 'package:medica_admin/features/articles/logic/articles_cubit/articles_state.dart';

class AddArticleDialog extends StatefulWidget {
  final ArticleModel? article;
  final Function(Function(int id, String name) onClinicSelected)?
  onOpenClinicDialog;

  const AddArticleDialog({super.key, this.article, this.onOpenClinicDialog});

  @override
  State<AddArticleDialog> createState() => _AddArticleDialogState();
}

class _AddArticleDialogState extends State<AddArticleDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _summaryController;
  late final TextEditingController _contentController;

  int? selectedCategoryId;
  int? selectedClinicId;
  String? selectedClinicName;
  PickedFileData? selectedImage;
  String? existingImageUrl;

  bool get isEditing => widget.article != null;

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController(text: widget.article?.title ?? '');
    _summaryController = TextEditingController(
      text: widget.article?.summary ?? '',
    );
    _contentController = TextEditingController(
      text: widget.article?.content ?? '',
    );

    if (isEditing) {
      if (widget.article!.category.isNotEmpty &&
          widget.article!.category['id'] != null) {
        selectedCategoryId = int.tryParse(
          widget.article!.category['id'].toString(),
        );
      }

      selectedClinicId = widget.article!.authorId;
      selectedClinicName = widget.article!.authorName;
      existingImageUrl =
          widget.article!.featuredImageUrl; // حفظ رابط الصورة القديمة للمعاينة
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cubit = context.read<ArticlesCubit>();
      if (cubit.categoriesList.isEmpty) {
        cubit.getCategories();
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _summaryController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 12, color: Colors.grey),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.borderColor),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ArticlesCubit, ArticlesState>(
      listener: (context, state) {
        if (state is ArticleActionSuccess) {
          Navigator.pop(context);
        } /*else if (state is ArticleActionError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error), backgroundColor: Colors.red),
          );
        }*/
      },
      builder: (context, state) {
        bool isLoading = state is ArticleActionLoading;

        return Dialog(
          backgroundColor: AppColors.scaffoldBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            width: 650,
            constraints: const BoxConstraints(maxHeight: 780),
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isEditing ? "تعديل المقال" : "إضافة مقال جديد",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkHeader,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const Divider(height: 24),

                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // العيادة المرتبطة
                          const Text(
                            "العيادة *",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 6),
                          InkWell(
                            onTap: () {
                              if (widget.onOpenClinicDialog != null) {
                                widget.onOpenClinicDialog!((id, name) {
                                  setState(() {
                                    selectedClinicId = id;
                                    selectedClinicName = name;
                                  });
                                });
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 14,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: AppColors.borderColor,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    selectedClinicName ?? "اختر العيادة",
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: selectedClinicName == null
                                          ? Colors.grey
                                          : Colors.black,
                                    ),
                                  ),
                                  const Icon(
                                    Icons.arrow_forward_ios,
                                    size: 14,
                                    color: Colors.grey,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // التصنيف
                          const Text(
                            "التصنيف *",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 6),
                          BlocBuilder<ArticlesCubit, ArticlesState>(
                            builder: (context, state) {
                              final cubit = context.read<ArticlesCubit>();
                              return DropdownButtonFormField<int>(
                                value: selectedCategoryId,
                                decoration: _inputDecoration("اختر التصنيف"),
                                items: cubit.categoriesList.map((cat) {
                                  return DropdownMenuItem<int>(
                                    value: cat.id,
                                    child: Text(cat.name ?? ''),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  setState(() {
                                    selectedCategoryId = val;
                                  });
                                },
                                validator: (val) =>
                                    val == null ? "يرجى اختيار التصنيف" : null,
                              );
                            },
                          ),
                          const SizedBox(height: 16),

                          // عنوان المقال
                          const Text(
                            "عنوان المقال *",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _titleController,
                            decoration: _inputDecoration("أدخل عنوان المقال"),
                            validator: (val) => val == null || val.isEmpty
                                ? "هذا الحقل مطلوب"
                                : null,
                          ),
                          const SizedBox(height: 16),

                          // 🖼️ قسم الصورة البارزة (الذي كان ناقصاً)
                          const Text(
                            "صورة المقال البارزة",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFE2E8F0),
                                  foregroundColor: Colors.black87,
                                ),
                                onPressed: () async {
                                  final picked =
                                      await ImagePickerHelper.picImageFromGallery();
                                  if (picked != null) {
                                    setState(() {
                                      selectedImage = picked;
                                    });
                                  }
                                },
                                icon: const Icon(Icons.image, size: 18),
                                label: const Text("اختيار صورة"),
                              ),
                              const SizedBox(width: 16),
                              if (selectedImage != null)
                                const Text(
                                  "تم اختيار صورة جديدة بنجاح",
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 12,
                                  ),
                                )
                              else if (existingImageUrl != null &&
                                  existingImageUrl!.isNotEmpty)
                                const Text(
                                  "توجد صورة قديمة للمقال",
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontSize: 12,
                                  ),
                                )
                              else
                                const Text(
                                  "لم يتم اختيار صورة",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // ملخص المقال
                          const Text(
                            "ملخص المقال",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _summaryController,
                            maxLines: 2,
                            decoration: _inputDecoration("أدخل ملخصاً قصيراً"),
                          ),
                          const SizedBox(height: 16),

                          // محتوى المقال
                          const Text(
                            "محتوى المقال *",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _contentController,
                            maxLines: 5,
                            decoration: _inputDecoration(
                              "أدخل تفاصيل المقال الكاملة",
                            ),
                            validator: (val) => val == null || val.isEmpty
                                ? "هذا الحقل مطلوب"
                                : null,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const Divider(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("إلغاء"),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                        ),
                        onPressed: isLoading
                            ? null
                            : () {
                                if (selectedClinicId == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        "يرجى اختيار العيادة أولاً",
                                      ),
                                    ),
                                  );
                                  return;
                                }

                                if (_formKey.currentState!.validate()) {
                                  if (isEditing) {
                                    context.read<ArticlesCubit>().updateArticle(
                                      articleId: widget.article!.id,
                                      clinicId: selectedClinicId!,
                                      title: _titleController.text,
                                      summary: _summaryController.text,
                                      content: _contentController.text,
                                      categoryId: selectedCategoryId,
                                      featuredImage: selectedImage,
                                    );
                                  } else {
                                    context.read<ArticlesCubit>().createArticle(
                                      clinicId: selectedClinicId!,
                                      title: _titleController.text,
                                      summary: _summaryController.text,
                                      content: _contentController.text,
                                      categoryId: selectedCategoryId!,
                                      featuredImage: selectedImage,
                                    );
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
                                isEditing ? "تعديل المقال" : "إنشاء المقال",
                                style: const TextStyle(color: Colors.white),
                              ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
