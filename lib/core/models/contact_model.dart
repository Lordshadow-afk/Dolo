class ContactModel {
  final String id;
  final String name;
  final String? phone;
  final String? raastId;
  final String avatarInitials;
  final String avatarColor;
  final bool isShadow;
  final DateTime createdAt;

  const ContactModel({
    required this.id,
    required this.name,
    this.phone,
    this.raastId,
    required this.avatarInitials,
    required this.avatarColor,
    this.isShadow = false,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'raast_id': raastId,
      'avatar_initials': avatarInitials,
      'avatar_color': avatarColor,
      'is_shadow': isShadow ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory ContactModel.fromMap(Map<String, dynamic> map) {
    return ContactModel(
      id: map['id'] as String,
      name: map['name'] as String,
      phone: map['phone'] as String?,
      raastId: map['raast_id'] as String?,
      avatarInitials: map['avatar_initials'] as String,
      avatarColor: map['avatar_color'] as String,
      isShadow: (map['is_shadow'] as int? ?? 0) == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  ContactModel copyWith({
    String? id,
    String? name,
    String? phone,
    String? raastId,
    String? avatarInitials,
    String? avatarColor,
    bool? isShadow,
    DateTime? createdAt,
  }) {
    return ContactModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      raastId: raastId ?? this.raastId,
      avatarInitials: avatarInitials ?? this.avatarInitials,
      avatarColor: avatarColor ?? this.avatarColor,
      isShadow: isShadow ?? this.isShadow,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
