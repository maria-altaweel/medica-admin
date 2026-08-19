class ArticleModel {
  final int id;
  final String title;
  final String? summary;
  final String content;
  final String? featuredImageUrl;
  final Map<String, dynamic> category;
  final String? authorType;
  final int? authorId;
  final String? authorName;
  final String status;
  final String? publishedAt;
  final int viewCount;
  final String createdAt;
  final String updatedAt;

  ArticleModel({
    required this.id,
    required this.title,
    this.summary,
    required this.content,
    this.featuredImageUrl,
    required this.category,
    this.authorType,
    this.authorId,
    this.authorName,
    required this.status,
    this.publishedAt,
    required this.viewCount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ArticleModel.fromJson(Map<String, dynamic> json) {
    return ArticleModel(
      id: json['id'] != null ? int.tryParse(json['id'].toString()) ?? 0 : 0,
      title: json['title'],
      summary: json['summary'],
      content: json['content'],
      featuredImageUrl: json['featured_image_url'],
      category: json['category'] ?? {},
      authorType: json['author_type'],
      // 👇 هنا تم الإصلاح: تحويل آمن لرقم العيادة حتى لو وصل كنص
      authorId: json['author_id'] != null
          ? int.tryParse(json['author_id'].toString())
          : null,
      authorName: json['author_name'],
      status: json['status'],
      publishedAt: json['published_at'],
      viewCount: json['view_count'] != null
          ? int.tryParse(json['view_count'].toString()) ?? 0
          : 0,
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}
