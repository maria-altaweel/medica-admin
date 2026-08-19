import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medica_admin/core/helpers/App_Colors.dart';
import 'package:medica_admin/features/articles/data/models/article_model.dart';
import 'package:medica_admin/features/articles/logic/articles_cubit/articles_cubit.dart';

class ArticleDetailsDialog extends StatelessWidget {
  final ArticleModel article;

  const ArticleDetailsDialog({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.scaffoldBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 800, // عرض مناسب للويب
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // الهيدر وزر الإغلاق
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "تفاصيل المقال",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 16),

            // محتوى التفاصيل
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // الصورة على اليمين
                Container(
                  width: 300,
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey[200],
                    image: article.featuredImageUrl != null
                        ? DecorationImage(
                            image: NetworkImage(article.featuredImageUrl!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: article.featuredImageUrl == null
                      ? const Icon(Icons.image, size: 50, color: Colors.grey)
                      : null,
                ),
                const SizedBox(width: 24),

                // النصوص التفصيلية
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        article.title,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildDetailRow("الحالة:", article.status, Colors.green),
                      _buildDetailRow(
                        "الكاتب:",
                        article.authorName ?? "غير محدد",
                        Colors.black87,
                      ),
                      _buildDetailRow(
                        "المشاهدات:",
                        "${article.viewCount}",
                        Colors.black87,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "الملخص:",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        article.summary ?? "لا يوجد ملخص",
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // الأزرار السفلية (كما في التصميم)
            Row(
              children: [
                const Spacer(),
                // 👈 زر تغيير الحالة يفتح النافذة المنبثقة
                OutlinedButton.icon(
                  icon: const Icon(Icons.keyboard_arrow_down),
                  label: const Text("تغيير الحالة"),
                  onPressed: () {
                    _showChangeStatusDialog(
                      context,
                      article.id,
                      article.status,
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String title, String value, Color valueColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: TextStyle(fontWeight: FontWeight.bold, color: valueColor),
          ),
        ],
      ),
    );
  }

  // 👈 ديالوج تغيير الحالة الداخلي
  void _showChangeStatusDialog(
    BuildContext context,
    int articleId,
    String currentStatus,
  ) {
    String selectedStatus = currentStatus;
    final cubit = context.read<ArticlesCubit>();

    showDialog(
      context: context,
      builder: (statusDialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.cardBackground,
          title: const Text("تغيير حالة المقال"),
          content: DropdownButtonFormField<String>(
            value: selectedStatus,
            items: const [
              DropdownMenuItem(value: "draft", child: Text("مسودة")),
              DropdownMenuItem(value: "published", child: Text("منشور")),
              DropdownMenuItem(value: "archived", child: Text("مؤرشف")),
            ],
            onChanged: (val) {
              if (val != null) selectedStatus = val;
            },
            decoration: const InputDecoration(border: OutlineInputBorder()),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(statusDialogContext),
              child: const Text("إلغاء"),
            ),
            ElevatedButton(
              onPressed: () {
                // استدعاء الدالة من الـ Cubit
                cubit.updateArticleStatus(
                  articleId: articleId,
                  status:
                      selectedStatus, // تأكد من إرسال الحالة كما يتوقعها الباك إند (مثلاً 'published' أو 'منشور')
                );
                Navigator.pop(statusDialogContext); // إغلاق نافذة الحالة
                Navigator.pop(
                  context,
                ); // إغلاق نافذة التفاصيل لإظهار التحديث في الجدول
                cubit.getArticles(isRefresh: true);
              },
              child: const Text(
                "حفظ الحالة",
                style: TextStyle(color: AppColors.primary),
              ),
            ),
          ],
        );
      },
    );
  }
}
