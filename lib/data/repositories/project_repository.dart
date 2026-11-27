import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:taskflow/core/constants/app_constants.dart';
import 'package:taskflow/data/models/project_model.dart';

/// A readable error the UI can show directly.
class ProjectFailure implements Exception {
  const ProjectFailure(this.message);

  final String message;

  @override
  String toString() => message;
}

/// The only class that talks to Firestore for projects.
class ProjectRepository {
  ProjectRepository({required FirebaseFirestore firestore, Random? random})
      : _firestore = firestore,
        _random = random ?? Random.secure();

  final FirebaseFirestore _firestore;
  final Random _random;

  // No 0/O or 1/I, so codes are easy to read out loud.
  static const _alphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  static const _codeLength = 6;

  CollectionReference<Map<String, dynamic>> get _projects =>
      _firestore.collection(AppConstants.projectsCollection);

  // ------------------------------------------------------------------ read

  /// Live list of the projects this user belongs to (newest first).
  /// Sorted here instead of in the query so no Firestore index is needed.
  Stream<List<ProjectModel>> watchProjects(String uid) {
    return _projects.where('memberIds', arrayContains: uid).snapshots().map((snap) {
      final list = snap.docs.map(ProjectModel.fromFirestore).toList();
      list.sort((a, b) {
        final ad = a.createdAt;
        final bd = b.createdAt;
        if (ad == null && bd == null) return 0;
        if (ad == null) return -1; // just created, still waiting for the server
        if (bd == null) return 1;
        return bd.compareTo(ad);
      });
      return list;
    });
  }

  // ----------------------------------------------------------------- write

  Future<ProjectModel> createProject({
    required String name,
    required String description,
    required String ownerId,
  }) {
    return _guard(() async {
      final code = await _uniqueInviteCode();
      final doc = _projects.doc();
      final project = ProjectModel(
        id: doc.id,
        name: name,
        description: description,
        ownerId: ownerId,
        memberIds: [ownerId],
        roles: {ownerId: ProjectModel.roleAdmin},
        inviteCode: code,
      );
      await doc.set(project.toFirestore());
      return project;
    });
  }

  Future<ProjectModel> joinByCode({required String code, required String uid}) {
    return _guard(() async {
      final snap = await _projects
          .where('inviteCode', isEqualTo: code.trim().toUpperCase())
          .limit(1)
          .get();
      if (snap.docs.isEmpty) {
        throw const ProjectFailure('No project found for that code.');
      }

      final doc = snap.docs.first;
      final project = ProjectModel.fromFirestore(doc);
      if (project.memberIds.contains(uid)) {
        throw const ProjectFailure("You're already in this project.");
      }

      await doc.reference.update({
        'memberIds': FieldValue.arrayUnion([uid]),
        'roles.$uid': ProjectModel.roleMember,
      });
      return project;
    });
  }

  /// Phase 7 note: Firestore does not delete sub-collections automatically.
  /// When tasks exist, delete them here too (or the tasks stay orphaned).
  Future<void> deleteProject(String projectId) {
    return _guard(() => _projects.doc(projectId).delete());
  }

  Future<void> leaveProject({required String projectId, required String uid}) {
    return _guard(() {
      return _projects.doc(projectId).update({
        'memberIds': FieldValue.arrayRemove([uid]),
        'roles.$uid': FieldValue.delete(),
      });
    });
  }

  // --------------------------------------------------------------- helpers

  String _randomCode() {
    return List.generate(
      _codeLength,
          (_) => _alphabet[_random.nextInt(_alphabet.length)],
    ).join();
  }

  Future<String> _uniqueInviteCode() async {
    for (var attempt = 0; attempt < 5; attempt++) {
      final code = _randomCode();
      final existing =
      await _projects.where('inviteCode', isEqualTo: code).limit(1).get();
      if (existing.docs.isEmpty) return code;
    }
    throw const ProjectFailure('Could not create an invite code. Try again.');
  }

  /// Turns Firebase and timeout errors into messages the UI can show.
  /// Without the timeout, a write made while offline would wait forever.
  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action().timeout(const Duration(seconds: 15));
    } on TimeoutException {
      throw const ProjectFailure('Taking too long. Check your internet connection.');
    } on FirebaseException catch (e) {
      switch (e.code) {
        case 'permission-denied':
          throw const ProjectFailure("You don't have permission to do that.");
        case 'unavailable':
          throw const ProjectFailure('No internet connection.');
        default:
          throw const ProjectFailure('Something went wrong. Try again.');
      }
    }
  }
}
