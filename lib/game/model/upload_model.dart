class UploadModel {
  final int id;
  final String title;
  final String htmlFilePath;
  final String createdAt;
  final String updatedAt;
  final bool fileExists;
  String? localPath;

  UploadModel({
    required this.id,
    required this.title,
    required this.htmlFilePath,
    required this.createdAt,
    required this.updatedAt,
    required this.fileExists,
    this.localPath,
  });

  factory UploadModel.fromJson(Map<String, dynamic> json) => UploadModel(
    id: json['id'] as int,
    title: json['title'] as String? ?? '',
    htmlFilePath: json['htmlFilePath'] as String? ?? '',
    createdAt: json['createdAt'] as String? ?? '',
    updatedAt: json['updatedAt'] as String? ?? '',
    fileExists: (json['fileExists'] as bool?) ?? true,
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'htmlFilePath': htmlFilePath,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
    'fileExists': fileExists ? 1 : 0,
    'localPath': localPath,
  };

  static UploadModel fromMap(Map<String, dynamic> m) => UploadModel(
    id: m['id'] as int,
    title: m['title'] as String? ?? '',
    htmlFilePath: m['htmlFilePath'] as String? ?? '',
    createdAt: m['createdAt'] as String? ?? '',
    updatedAt: m['updatedAt'] as String? ?? '',
    fileExists: (m['fileExists'] as int) == 1,
    localPath: m['localPath'] as String?,
  );
}
