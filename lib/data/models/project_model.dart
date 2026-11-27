import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

/// Firestore document: projects/{projectId}
///
///   name, description, ownerId, inviteCode, createdAt
///   memberIds: [uid, uid, ...]          (used to query "my projects")
///   roles:     {uid: 'admin' | 'member'}
class ProjectModel extends Equatable {
  const ProjectModel({
    required this.id,
    required this.name,
    required this.description,
    required this.ownerId,
    required this.memberIds,
    required this.roles,
    required this.inviteCode,
    this.createdAt,
  });

  static const roleAdmin = 'admin';
  static const roleMember = 'member';

  final String id;
  final String name;
  final String description;
  final String ownerId;
  final List<String> memberIds;
  final Map<String, String> roles;
  final String inviteCode;

  /// Null for a moment after creation, until the server sets the timestamp.
  final DateTime? createdAt;

  int get memberCount => memberIds.length;

  bool isAdmin(String uid) => roles[uid] == roleAdmin;

  factory ProjectModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final map = doc.data() ?? <String, dynamic>{};
    return ProjectModel(
      id: doc.id,
      name: map['name'] as String? ?? '',
      description: map['description'] as String? ?? '',
      ownerId: map['ownerId'] as String? ?? '',
      memberIds: List<String>.from(map['memberIds'] as List? ?? const []),
      roles: Map<String, String>.from(map['roles'] as Map? ?? const {}),
      inviteCode: map['inviteCode'] as String? ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'name': name,
    'description': description,
    'ownerId': ownerId,
    'memberIds': memberIds,
    'roles': roles,
    'inviteCode': inviteCode,
    'createdAt': FieldValue.serverTimestamp(),
  };

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    ownerId,
    memberIds,
    roles,
    inviteCode,
    createdAt,
  ];
}