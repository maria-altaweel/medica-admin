import 'package:medica_admin/core/helpers/Image_Picker_helper.dart';
import 'package:medica_admin/core/networking/api_service.dart';
import 'package:medica_admin/features/articles/data/models/article_model.dart';
import 'package:medica_admin/features/articles/data/models/category_model.dart';

class ArticlesRepository {
  final ApiService _apiService;

  ArticlesRepository(this._apiService);

  /// 1. جلب قائمة المقالات (مع دعم الفلترة والبحث والترقيم)
  Future<Map<String, dynamic>> getArticles(
    Map<String, dynamic> queryParameters,
  ) async {
    String endpoint = "admin/articles";
    if (queryParameters.isNotEmpty) {
      final queryString = queryParameters.entries
          .where((e) => e.value != null && e.value.toString().isNotEmpty)
          .map((e) => '${e.key}=${e.value}')
          .join('&');
      if (queryString.isNotEmpty) {
        endpoint += "?$queryString";
      }
    }

    final response = await _apiService.get(endpoint);

    final List data = response['data'] ?? [];
    final List<ArticleModel> articles = data
        .map((json) => ArticleModel.fromJson(json))
        .toList();

    final pagination = response['pagination'] ?? {};

    return {
      'articles': articles,
      'has_more': pagination['has_more'] ?? false,
      'next_last_id': pagination['next_last_id'],
    };
  }

  /// 2. جلب قائمة الفئات (Categories)
  Future<List<CategoryModel>> getCategories() async {
    final response = await _apiService.get("admin/categories");
    final List data = response['data'] ?? [];
    return data.map((json) => CategoryModel.fromJson(json)).toList();
  }

  /// 3. إنشاء مقال جديد (يدعم رفع الصورة عبر postMultipart المتوافقة مع الويب والموبايل)
  Future<ArticleModel> createArticle({
    required int clinicId,
    required String title,
    String? summary,
    required String content,
    required int categoryId,
    PickedFileData? featuredImage,
  }) async {
    final Map<String, String> fields = {
      'title': title,
      if (summary != null && summary.isNotEmpty) 'summary': summary,
      'content': content,
      'category_id': categoryId.toString(),
    };

    final response = await _apiService.postMultipart(
      endpoint: "admin/clinics/$clinicId/articles",
      fields: fields,
      file: featuredImage,
      fileKey: 'featured_image',
    );

    return ArticleModel.fromJson(response['data']);
  }

  /// 4. تعديل مقال (يدعم أيضاً إرسال صورة جديدة أو التحديث النصي)
  Future<ArticleModel> updateArticle({
    required int articleId,
    required int clinicId,
    String? title,
    String? summary,
    String? content,
    int? categoryId,
    PickedFileData? featuredImage,
  }) async {
    final Map<String, String> fields = {};
    if (title != null) fields['title'] = title;
    if (summary != null) fields['summary'] = summary;
    if (content != null) fields['content'] = content;
    if (categoryId != null) fields['category_id'] = categoryId.toString();

    // إذا كان هناك صورة جديدة، نستخدم postMultipart لأن الباك إند يستقبل POST على هذا المسار لرفع الملفات
    if (featuredImage != null) {
      final response = await _apiService.postMultipart(
        endpoint: "admin/articles/$articleId",
        fields: fields,
        file: featuredImage,
        fileKey: 'featured_image',
      );
      return ArticleModel.fromJson(response['data']);
    } else {
      // إذا لم يكن هناك صورة جديدة، نستخدم الـ post العادية مع الـ body
      final response = await _apiService.put(
        "admin/articles/$articleId",
        body: fields,
      );
      return ArticleModel.fromJson(response['data']);
    }
  }

  /// 5. حذف مقال
  Future<String> deleteArticle(int articleId) async {
    final response = await _apiService.delete("admin/articles/$articleId");
    return response['message'] ?? "Article deleted successfully";
  }

  /// 6. تغيير حالة المقال (published, draft, archived)
  Future<ArticleModel> updateArticleStatus({
    required int articleId,
    required String status,
  }) async {
    final response = await _apiService.patch(
      "admin/articles/$articleId/status",
      body: {'status': status},
    );
    return ArticleModel.fromJson(response['data']);
  }
}
