import 'package:futurex_app/constants/base_urls.dart';

class UploadModel {
  final int id;
  final String title;
  final String htmlFilePath;
  String? localPath;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool fileExists;
  final String? onlineUrl;

  UploadModel({
    required this.id,
    required this.title,
    required this.htmlFilePath,
    this.localPath,
    required this.createdAt,
    required this.updatedAt,
    required this.fileExists,
    this.onlineUrl,
  });

  factory UploadModel.fromJson(Map<String, dynamic> json) {
    return UploadModel(
      id: json['id'] as int,
      title: json['title'] as String,
      htmlFilePath: json['htmlFilePath'] as String,
      localPath: json['localPath'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      fileExists: json['fileExists'] == true || json['fileExists'] == 1,
      onlineUrl: '${BaseUrls.adminService}/${json['htmlFilePath']}',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'htmlFilePath': htmlFilePath,
      'localPath': localPath,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'fileExists': fileExists ? 1 : 0,
      'onlineUrl': onlineUrl,
    };
  }

  factory UploadModel.fromMap(Map<String, dynamic> map) {
    return UploadModel(
      id: map['id'] as int,
      title: map['title'] as String,
      htmlFilePath: map['htmlFilePath'] as String,
      localPath: map['localPath'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
      fileExists: map['fileExists'] == 1,
      onlineUrl: map['onlineUrl'] as String?,
    );
  }
}
