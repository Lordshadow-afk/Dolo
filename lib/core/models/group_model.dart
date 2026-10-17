import 'contact_model.dart';

class GroupMemberModel {
  final String id;
  final String groupId;
  final String contactId;
  final String nickname;
  final DateTime joinedAt;
  final ContactModel? contact;

  const GroupMemberModel({
    required this.id,
    required this.groupId,
    required this.contactId,
    required this.nickname,
    required this.joinedAt,
    this.contact,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'group_id': groupId,
      'contact_id': contactId,
      'nickname': nickname,
      'joined_at': joinedAt.toIso8601String(),
    };
  }

  factory GroupMemberModel.fromMap(Map<String, dynamic> map, {ContactModel? contact}) {
    return GroupMemberModel(
      id: map['id'] as String,
      groupId: map['group_id'] as String,
      contactId: map['contact_id'] as String,
      nickname: map['nickname'] as String,
      joinedAt: DateTime.parse(map['joined_at'] as String),
      contact: contact,
    );
  }
}

class GroupModel {
  final String id;
  final String name;
  final String? icon;
  final DateTime createdAt;
  final bool cloudSynced;
  final List<GroupMemberModel> members;

  const GroupModel({
    required this.id,
    required this.name,
    this.icon,
    required this.createdAt,
    this.cloudSynced = false,
    this.members = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'created_at': createdAt.toIso8601String(),
      'cloud_synced': cloudSynced ? 1 : 0,
    };
  }

  factory GroupModel.fromMap(Map<String, dynamic> map, {List<GroupMemberModel> members = const []}) {
    return GroupModel(
      id: map['id'] as String,
      name: map['name'] as String,
      icon: map['icon'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      cloudSynced: (map['cloud_synced'] as int? ?? 0) == 1,
      members: members,
    );
  }
}
