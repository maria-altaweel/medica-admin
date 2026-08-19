import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medica_admin/core/helpers/app_colors.dart';
import 'package:medica_admin/features/articles/UI/widgets/add_articles_dialog.dart';
import 'package:medica_admin/features/articles/UI/widgets/articles_details_dialog.dart';
import 'package:medica_admin/features/articles/data/models/article_model.dart';
import 'package:medica_admin/features/articles/logic/articles_cubit/articles_cubit.dart';

class ArticlesTable extends StatelessWidget {
  final List<ArticleModel> articles;

  const ArticlesTable({super.key, required this.articles});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
              dataRowMinHeight: 52,
              dataRowMaxHeight: 60,
              columns: const [
                DataColumn(
                  label: Text(
                    "عنوان المقال",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    "الفئة",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    "الكاتب",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    "الحالة",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    "المشاهدات",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    "تاريخ الإنشاء",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    "الإجراءات",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
              rows: articles.map((article) {
                // استخراج اسم الفئة بأمان من الـ Map الموجود في الموديل
                String categoryName = '-';
                if (article.category.containsKey('name')) {
                  categoryName = article.category['name']?.toString() ?? '-';
                }

                return DataRow(
                  cells: [
                    DataCell(
                      SizedBox(
                        width: 200,
                        child: Text(
                          article.title,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                    DataCell(Text(categoryName)),
                    DataCell(Text(article.authorName ?? "مشرف")),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(
                            article.status,
                          ).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          _getStatusArabic(article.status),
                          style: TextStyle(
                            color: _getStatusColor(article.status),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    DataCell(Text(article.viewCount.toString())),
                    DataCell(Text(article.createdAt)),

                    // استبدل الـ DataCell الخاصة بالأيقونات في ملف ArticlesTable بهذا الكود:
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.visibility,
                              color: Colors.blue,
                            ),
                            onPressed: () {
                              final cubit = context.read<ArticlesCubit>();
                              showDialog(
                                context: context,
                                builder: (dialogContext) => BlocProvider.value(
                                  value: cubit,
                                  child: ArticleDetailsDialog(
                                    article: article,
                                  ), // سننشئ هذا الملف بالخطوة الثانية
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.edit_outlined,
                              color: Colors.blue,
                              size: 20,
                            ),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (_) => BlocProvider.value(
                                  value: context.read<ArticlesCubit>(),
                                  child: AddArticleDialog(
                                    article: article,
                                    onOpenClinicDialog: (onClinicSelected) {},
                                  ),
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.red,
                              size: 20,
                            ),
                            onPressed: () {
                              // كود الحذف الخاص بك كما هو لا تغيير عليه
                              showDialog(
                                context: context,
                                builder: (BuildContext dialogContext) {
                                  return AlertDialog(
                                    title: const Text("تأكيد الحذف"),
                                    content: const Text(
                                      "هل أنت متأكد من رغبتك في حذف هذا المقال؟",
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(dialogContext),
                                        child: const Text("إلغاء"),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(dialogContext);
                                          context
                                              .read<ArticlesCubit>()
                                              .deleteArticle(article.id);
                                        },
                                        child: const Text(
                                          "حذف",
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'published':
        return Colors.green;
      case 'draft':
        return Colors.orange;
      case 'archived':
        return Colors.grey;
      default:
        return AppColors.primary;
    }
  }

  String _getStatusArabic(String status) {
    switch (status.toLowerCase()) {
      case 'published':
        return 'منشور';
      case 'draft':
        return 'مسودة';
      case 'archived':
        return 'مؤرشف';
      default:
        return status;
    }
  }
}
