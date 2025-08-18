import 'dart:convert';
import 'package:flutter/material.dart';

class Course {
  final int id;
  final String title;
   
  final String short_description;
  final String description;
  final List<String> outcomes;
  final String language;
  final int? category_id;
  final List<int> section;
  final List<String> requirements;
  final String price;
  final bool discount_flag;
  final String discounted_price;
  final String thumbnail;
  final String video_url;
  final bool is_top_course;
  final String status;
  final String video;
  final bool? is_free_course;
  final bool multi_instructor;
  final String creator;
  final String createdAt;
  final String updatedAt;
  final int like_count;
  final int comment_count;
  final Category? category;
  final String? localThumbnailPath;

  Course({
    required this.id,
    required this.title,
   
    required this.short_description,
    required this.description,
    required this.outcomes,
    required this.language,
    this.category_id,
    required this.section,
    required this.requirements,
    required this.price,
    required this.discount_flag,
    required this.discounted_price,
    required this.thumbnail,
    required this.video_url,
    required this.is_top_course,
    required this.status,
    required this.video,
    required this.is_free_course,
    required this.multi_instructor,
    required this.creator,
    required this.createdAt,
    required this.updatedAt,
    required this.like_count,
    required this.comment_count,
    this.category,
    this.localThumbnailPath,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    List<String> parseStringList(dynamic input) {
      if (input == null) return [];
      if (input is String) {
        try {
          final decoded = jsonDecode(input);
          if (decoded is List) return List<String>.from(decoded.map((x) => x.toString()));
        } catch (e) {
          debugPrint('Error parsing string list: $input, Error: $e');
          return input.split(',').map((e) => e.trim()).toList();
        }
      }
      if (input is List) return List<String>.from(input.map((x) => x.toString()));
      return [];
    }

    List<int> parseIntList(dynamic input) {
      if (input == null) return [];
      if (input is String) {
        try {
          final decoded = jsonDecode(input);
          if (decoded is List) return List<int>.from(decoded.map((x) => int.tryParse(x.toString()) ?? 0));
        } catch (e) {
          debugPrint('Error parsing int list: $input, Error: $e');
          return input.split(',').map((e) => int.tryParse(e.trim()) ?? 0).toList();
        }
      }
      if (input is List) return List<int>.from(input.map((x) => int.tryParse(x.toString()) ?? 0));
      return [];
    }

    return Course(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      title: json['title']?.toString() ?? "",
   
      short_description: json['short_description']?.toString() ?? "",
      description: json['description']?.toString() ?? "",
      outcomes: parseStringList(json['outcomes']),
      language: json['language']?.toString() ?? "",
      category_id: json['category_id'] is int ? json['category_id'] : int.tryParse(json['category_id']?.toString() ?? ''),
      section: parseIntList(json['section']),
      requirements: parseStringList(json['requirements']),
      price: json['price']?.toString() ?? "0.00",
      discount_flag: (json['discount_flag'] is bool)
          ? json['discount_flag']
          : (json['discount_flag'] is int)
              ? json['discount_flag'] == 1
              : json['discount_flag']?.toString().toLowerCase() == 'true',
      discounted_price: json['discounted_price']?.toString() ?? "0.00",
      thumbnail: json['thumbnail']?.toString() ?? "",
      video_url: json['video_url']?.toString() ?? "",
      is_top_course: (json['is_top_course'] is bool)
          ? json['is_top_course']
          : (json['is_top_course'] is int)
              ? json['is_top_course'] == 1
              : json['is_top_course']?.toString().toLowerCase() == 'true',
      status: json['status']?.toString() ?? "draft",
      video: json['video']?.toString() ?? "",
      is_free_course: (json['is_free_course'] is bool)
          ? json['is_free_course']
          : (json['is_free_course'] is int)
              ? json['is_free_course'] == 1
              : json['is_free_course']?.toString().toLowerCase() == 'true',
      multi_instructor: (json['multi_instructor'] is bool)
          ? json['multi_instructor']
          : (json['multi_instructor'] is int)
              ? json['multi_instructor'] == 1
              : json['multi_instructor']?.toString().toLowerCase() == 'true',
      creator: json['creator']?.toString() ?? "",
      createdAt: json['createdAt']?.toString() ?? "",
      updatedAt: json['updatedAt']?.toString() ?? "",
      like_count: json['like_count'] is int ? json['like_count'] : int.tryParse(json['like_count']?.toString() ?? '0') ?? 0,
      comment_count: json['comment_count'] is int ? json['comment_count'] : int.tryParse(json['comment_count']?.toString() ?? '0') ?? 0,
      category: json['category'] != null
          ? (json['category'] is String
              ? Category.fromJson(jsonDecode(json['category']))
              : Category.fromJson(json['category']))
          : null,
      localThumbnailPath: json['localThumbnailPath']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
   
      'short_description': short_description,
      'description': description,
      'outcomes': jsonEncode(outcomes),
      'language': language,
      'category_id': category_id,
      'section': jsonEncode(section),
      'requirements': jsonEncode(requirements),
      'price': price,
      'discount_flag': discount_flag ? 1 : 0,
      'discounted_price': discounted_price,
      'thumbnail': thumbnail,
      'video_url': video_url,
      'is_top_course': is_top_course ? 1 : 0,
      'status': status,
      'video': video,
      'is_free_course': is_free_course ?? false ? 1 : 0,
      'multi_instructor': multi_instructor ? 1 : 0,
      'creator': creator,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'like_count': like_count,
      'comment_count': comment_count,
      'category': category?.toJson(),
      'localThumbnailPath': localThumbnailPath,
    };
  }
}

class Category {
  final int id;
  final String catagory;

  Category({required this.id, required this.catagory});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      catagory: json['catagory']?.toString() ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'catagory': catagory,
    };
  }
}