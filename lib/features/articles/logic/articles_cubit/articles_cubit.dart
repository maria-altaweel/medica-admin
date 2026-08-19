import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medica_admin/core/helpers/Image_Picker_helper.dart';
import 'package:medica_admin/features/articles/data/models/article_model.dart';
import 'package:medica_admin/features/articles/data/models/category_model.dart';
import 'package:medica_admin/features/articles/data/repos/article_repo.dart';

import 'package:medica_admin/features/articles/logic/articles_cubit/articles_state.dart';

class ArticlesCubit extends Cubit<ArticlesState> {
  final ArticlesRepository _articlesRepo;

  ArticlesCubit(this._articlesRepo) : super(ArticlesInitialState());

  List<ArticleModel> articlesList = [];
  List<CategoryModel> categoriesList = [];
  bool hasMore = false;
  int? nextLastId;

  // 1. جلب قائمة المقالات
  Future<void> getArticles({
    bool isRefresh = false,
    String? status,
    int? categoryId,
    int? clinicId,
    String? search,
  }) async {
    if (isRefresh) {
      articlesList.clear();
      nextLastId = null;
      emit(GetArticlesLoading());
    } else if (articlesList.isEmpty) {
      emit(GetArticlesLoading());
    }

    try {
      final Map<String, dynamic> params = {
        'limit': 15,
        if (nextLastId != null) 'last_id': nextLastId,
        if (status != null && status.isNotEmpty) 'status': status,
        if (categoryId != null) 'category_id': categoryId,
        if (clinicId != null) 'clinic_id': clinicId,
        if (search != null && search.isNotEmpty) 'search': search,
      };

      final result = await _articlesRepo.getArticles(params);

      final List<ArticleModel> newArticles = result['articles'];
      hasMore = result['has_more'];
      nextLastId = result['next_last_id'];

      if (isRefresh) {
        articlesList = newArticles;
      } else {
        articlesList.addAll(newArticles);
      }

      emit(GetArticlesSuccess(articlesList, hasMore));
    } catch (e) {
      emit(GetArticlesError(e.toString()));
    }
  }

  // 2. جلب الفئات (Categories) للفلترة أو النماذج
  Future<void> getCategories() async {
    print('=== تم الدخول لدالة جلب الفئات ===');
    emit(GetCategoriesLoading()); // 👈 1. إعلام الواجهة بالتحميل
    try {
      categoriesList = await _articlesRepo.getCategories();
      print('=== عدد الفئات المجلوبة من السيرفر: ${categoriesList.length} ===');
      emit(GetCategoriesSuccess(categoriesList));
    } catch (e, stackTrace) {
      print('=== ❌ خطأ في جلب الفئات: $e ===');
      print(stackTrace);
      emit(GetCategoriesError(e.toString())); // 👈 2. إرسال الخطأ وعدم إهماله
    }
  }

  // 3. إنشاء مقال جديد
  Future<void> createArticle({
    required int clinicId,
    required String title,
    String? summary,
    required String content,
    required int categoryId,
    PickedFileData? featuredImage,
  }) async {
    emit(ArticleActionLoading());
    try {
      await _articlesRepo.createArticle(
        clinicId: clinicId,
        title: title,
        summary: summary,
        content: content,
        categoryId: categoryId,
        featuredImage: featuredImage,
      );
      emit(ArticleActionSuccess("تم إنشاء المقال بنجاح"));
      // إعادة تحميل القائمة لتحديث البيانات
      getArticles(isRefresh: true);
    } catch (e) {
      emit(ArticleActionError(e.toString()));
    }
  }

  // 4. تعديل مقال
  Future<void> updateArticle({
    required int articleId,
    required int clinicId,
    String? title,
    String? summary,
    String? content,
    int? categoryId,
    PickedFileData? featuredImage,
  }) async {
    emit(ArticleActionLoading());
    try {
      await _articlesRepo.updateArticle(
        articleId: articleId,
        clinicId: clinicId,
        title: title,
        summary: summary,
        content: content,
        categoryId: categoryId,
        featuredImage: featuredImage,
      );
      emit(ArticleActionSuccess("تم تعديل المقال بنجاح"));
      getArticles(isRefresh: true);
    } catch (e) {
      emit(ArticleActionError(e.toString()));
    }
  }

  // 5. حذف مقال
  Future<void> deleteArticle(int articleId) async {
    emit(ArticleActionLoading());
    try {
      await _articlesRepo.deleteArticle(articleId);
      articlesList.removeWhere((article) => article.id == articleId);
      emit(ArticleActionSuccess("تم حذف المقال بنجاح"));
      emit(GetArticlesSuccess(articlesList, hasMore));
    } catch (e) {
      emit(ArticleActionError(e.toString()));
    }
  }

  // 6. تغيير حالة المقال (published, draft, archived)
  Future<void> updateArticleStatus({
    required int articleId,
    required String status,
  }) async {
    emit(ArticleActionLoading());
    try {
      final updatedArticle = await _articlesRepo.updateArticleStatus(
        articleId: articleId,
        status: status,
      );

      // تحديث المقال داخل القائمة محلياً
      final index = articlesList.indexWhere((a) => a.id == articleId);
      if (index != -1) {
        articlesList[index] = updatedArticle;
      }

      emit(ArticleActionSuccess("تم تغيير حالة المقال بنجاح"));
      emit(GetArticlesSuccess(articlesList, hasMore));
    } catch (e) {
      emit(ArticleActionError(e.toString()));
    }
  }
}
