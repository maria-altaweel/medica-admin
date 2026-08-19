import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medica_admin/core/helpers/AppsnackBar.dart';
import 'package:medica_admin/core/helpers/app_colors.dart';
import 'package:medica_admin/core/widgets/App_Loadingindicator.dart';
import 'package:medica_admin/features/articles/UI/widgets/articles_tables.dart';
import 'package:medica_admin/features/articles/ui/widgets/articles_filter_bar.dart';
import 'package:medica_admin/features/articles/UI/widgets/add_articles_dialog.dart'; // تأكد من مسار ديالوج المقال
import 'package:medica_admin/features/articles/logic/articles_cubit/articles_cubit.dart';
import 'package:medica_admin/features/articles/logic/articles_cubit/articles_state.dart';
import 'package:medica_admin/features/clinics/data/models/clinic_model.dart';
import 'package:medica_admin/features/doctors/UI/widgets/select_clinic_dialog.dart';

class ArticlesScreen extends StatefulWidget {
  const ArticlesScreen({super.key});

  @override
  State<ArticlesScreen> createState() => _ArticlesScreenState();
}

class _ArticlesScreenState extends State<ArticlesScreen> {
  @override
  void initState() {
    super.initState();
    // جلب البيانات الأولية
    context.read<ArticlesCubit>().getArticles(isRefresh: true);
    context.read<ArticlesCubit>().getCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // الهيدر
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "المقالات والإعلانات",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkHeader,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    final articlesCubit = context.read<ArticlesCubit>();
                    showDialog(
                      context: context,
                      builder: (dialogContext) => BlocProvider.value(
                        value: articlesCubit,
                        child: AddArticleDialog(
                          onOpenClinicDialog: (onClinicSelected) {
                            // استدعاء ديالوج العيادات الحقيقي
                            showDialog(
                              context: dialogContext,
                              builder: (context) => SelectClinicDialog(
                                selectedClinic:
                                    null, // null لأننا نضيف مقال جديد
                                onClinicSelected: (ClinicModel clinic) {
                                  // تمرير الـ id والاسم إلى ديالوج المقال
                                  onClinicSelected(clinic.id, clinic.name);
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text(
                    "إضافة مقال",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // الفلتر
            const ArticlesFilterBar(),
            const SizedBox(height: 16),

            // الجدول والاستماع للستايتس
            Expanded(
              child: BlocConsumer<ArticlesCubit, ArticlesState>(
                listener: (context, state) {
                  // الاستماع لحالات الخطأ والنجاح
                  if (state is GetArticlesError) {
                    Appsnackbar.showError(context, state.error);
                  } else if (state is ArticleActionError) {
                    Appsnackbar.showError(context, state.error);
                  } else if (state is ArticleActionSuccess) {
                    Appsnackbar.showSuccess(context, state.message);
                  }
                },
                builder: (context, state) {
                  // 👈 إضافة مهمة جداً: إذا كانت البيانات موجودة أصلاً في الكيوبت، اعرضها مباشرة
                  final articlesCubit = context.read<ArticlesCubit>();
                  if (state is ArticlesInitialState &&
                      articlesCubit.articlesList.isNotEmpty) {
                    return ArticlesTable(articles: articlesCubit.articlesList);
                  }

                  // حالة التحميل
                  if (state is GetArticlesLoading ||
                      state is ArticlesInitialState) {
                    return AppLoadingIndicator();
                  }
                  // حالة النجاح
                  else if (state is GetArticlesSuccess) {
                    if (state.articles.isEmpty) {
                      return const Center(child: Text("لا توجد مقالات حالياً"));
                    }
                    return ArticlesTable(articles: state.articles);
                  }
                  // حالة الخطأ
                  else if (state is GetArticlesError) {
                    return Center(child: Text(state.error));
                  }

                  // إذا كانت القائمة مليئة بأي حالة أخرى
                  if (articlesCubit.articlesList.isNotEmpty) {
                    return ArticlesTable(articles: articlesCubit.articlesList);
                  }

                  return const Center(child: Text("لا توجد مقالات حالياً"));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
