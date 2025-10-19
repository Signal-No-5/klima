class GoBagItem {
  final String id;
  final String category; // documents, food, medical, tools, clothing, communication
  final String name;
  final String description;
  final bool isChecked;
  final int priority; // 1 (critical) to 3 (recommended)
  final String? icon;

  GoBagItem({
    required this.id,
    required this.category,
    required this.name,
    required this.description,
    this.isChecked = false,
    this.priority = 2,
    this.icon,
  });

  GoBagItem copyWith({
    String? id,
    String? category,
    String? name,
    String? description,
    bool? isChecked,
    int? priority,
    String? icon,
  }) {
    return GoBagItem(
      id: id ?? this.id,
      category: category ?? this.category,
      name: name ?? this.name,
      description: description ?? this.description,
      isChecked: isChecked ?? this.isChecked,
      priority: priority ?? this.priority,
      icon: icon ?? this.icon,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'name': name,
      'description': description,
      'is_checked': isChecked,
      'priority': priority,
      'icon': icon,
    };
  }

  factory GoBagItem.fromJson(Map<String, dynamic> json) {
    return GoBagItem(
      id: json['id'] ?? '',
      category: json['category'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      isChecked: json['is_checked'] ?? false,
      priority: json['priority'] ?? 2,
      icon: json['icon'],
    );
  }
}
