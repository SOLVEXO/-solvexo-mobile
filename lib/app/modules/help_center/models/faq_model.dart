class FaqModel {
  final String id;
  final String question;
  final String answer;
  final String category;
  final int order;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  FaqModel({
    required this.id,
    required this.question,
    required this.answer,
    required this.category,
    required this.order,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  factory FaqModel.fromJson(Map<String, dynamic> json) {
    return FaqModel(
      id: json['_id']?.toString() ?? '',
      question: json['question']?.toString() ?? '',
      answer: json['answer']?.toString() ?? '',
      category: json['category']?.toString() ?? 'general',
      order: json['order'] as int? ?? 0,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'question': question,
      'answer': answer,
      'category': category,
      'order': order,
      'isActive': isActive,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }

  @override
  String toString() => 'FaqModel(id: $id, question: $question)';
}
