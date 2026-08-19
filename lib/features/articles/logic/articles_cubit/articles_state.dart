import 'package:medica_admin/features/articles/data/models/article_model.dart';
import 'package:medica_admin/features/articles/data/models/category_model.dart';

abstract class ArticlesState {}

class ArticlesInitialState extends ArticlesState {}

// --- حالات جلب المقالات ---
class GetArticlesLoading extends ArticlesState {}

class GetArticlesSuccess extends ArticlesState {
  final List<ArticleModel> articles;
  final bool hasMore;
  GetArticlesSuccess(this.articles, this.hasMore);
}

class GetArticlesError extends ArticlesState {
  final String error;
  GetArticlesError(this.error);
}

// --- حالات جلب الفئات (Categories) ---
class GetCategoriesLoading extends ArticlesState {} // 👈 تمت الإضافة

class GetCategoriesSuccess extends ArticlesState {
  final List<CategoryModel> categories;
  GetCategoriesSuccess(this.categories);
}

class GetCategoriesError extends ArticlesState {
  // 👈 تمت الإضافة
  final String error;
  GetCategoriesError(this.error);
}

// --- حالات الإجراءات (إضافة، تعديل، حذف، تغيير حالة) ---
class ArticleActionLoading extends ArticlesState {}

class ArticleActionSuccess extends ArticlesState {
  final String message;
  ArticleActionSuccess(this.message);
}

class ArticleActionError extends ArticlesState {
  final String error;
  ArticleActionError(this.error);
}
