import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:carelink/core/exceptions.dart';
import 'package:carelink/core/constants.dart';

/// Firebase Firestore Service
/// Handles all database operations with proper error handling and type safety
class FirestoreService {
  final FirebaseFirestore _firestore;

  FirestoreService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  FirebaseFirestore get firestore => _firestore;

  // ============== Generic Methods ==============

  /// Get a single document
  Future<DocumentSnapshot<Map<String, dynamic>>> getDocument({
    required String collection,
    required String docId,
  }) async {
    try {
      final doc = await _firestore
          .collection(collection)
          .doc(docId)
          .get()
          .timeout(AppConstants.databaseTimeout);

      return doc;
    } on FirebaseException catch (e) {
      throw _handleFirebaseException(e);
    } catch (e) {
      throw FirestoreException.readFailed(e.toString());
    }
  }

  /// Create a new document
  Future<DocumentReference<Map<String, dynamic>>> createDocument({
    required String collection,
    required Map<String, dynamic> data,
    String? customId,
  }) async {
    try {
      DocumentReference<Map<String, dynamic>> ref;

      if (customId != null) {
        ref = _firestore.collection(collection).doc(customId);
        await ref.set(data).timeout(AppConstants.databaseTimeout);
      } else {
        ref = await _firestore
            .collection(collection)
            .add(data)
            .timeout(AppConstants.databaseTimeout);
      }

      return ref;
    } on FirebaseException catch (e) {
      throw _handleFirebaseException(e);
    } catch (e) {
      throw FirestoreException.writeFailed(e.toString());
    }
  }

  /// Create a new document in a subcollection.
  Future<DocumentReference<Map<String, dynamic>>> createSubcollectionDocument({
    required String parentCollection,
    required String parentDocId,
    required String collection,
    required Map<String, dynamic> data,
    String? customId,
  }) async {
    try {
      final parentDoc = _firestore
          .collection(parentCollection)
          .doc(parentDocId);
      DocumentReference<Map<String, dynamic>> ref;

      if (customId != null) {
        ref = parentDoc.collection(collection).doc(customId);
        await ref.set(data).timeout(AppConstants.databaseTimeout);
      } else {
        ref = await parentDoc
            .collection(collection)
            .add(data)
            .timeout(AppConstants.databaseTimeout);
      }

      return ref;
    } on FirebaseException catch (e) {
      throw _handleFirebaseException(e);
    } catch (e) {
      throw FirestoreException.writeFailed(e.toString());
    }
  }

  /// Update a document
  Future<void> updateDocument({
    required String collection,
    required String docId,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _firestore
          .collection(collection)
          .doc(docId)
          .update(data)
          .timeout(AppConstants.databaseTimeout);
    } on FirebaseException catch (e) {
      throw _handleFirebaseException(e);
    } catch (e) {
      throw FirestoreException.writeFailed(e.toString());
    }
  }

  /// Delete a document
  Future<void> deleteDocument({
    required String collection,
    required String docId,
  }) async {
    try {
      await _firestore
          .collection(collection)
          .doc(docId)
          .delete()
          .timeout(AppConstants.databaseTimeout);
    } on FirebaseException catch (e) {
      throw _handleFirebaseException(e);
    } catch (e) {
      throw FirestoreException.writeFailed(e.toString());
    }
  }

  /// Query documents with optional conditions
  Future<QuerySnapshot<Map<String, dynamic>>> queryDocuments({
    required String collection,
    List<QueryCondition>? conditions,
    int? limit,
    String? orderBy,
    bool descending = false,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _firestore.collection(collection);

      // Apply conditions
      if (conditions != null) {
        for (final condition in conditions) {
          query = condition.apply(query) as Query<Map<String, dynamic>>;
        }
      }

      // Apply ordering
      if (orderBy != null) {
        query = query.orderBy(orderBy, descending: descending);
      }

      // Apply limit
      if (limit != null) {
        query = query.limit(limit);
      }

      return await query.get().timeout(AppConstants.databaseTimeout);
    } on FirebaseException catch (e) {
      throw _handleFirebaseException(e);
    } catch (e) {
      throw FirestoreException.readFailed(e.toString());
    }
  }

  /// Query documents in a subcollection with optional conditions.
  Future<QuerySnapshot<Map<String, dynamic>>> querySubcollectionDocuments({
    required String parentCollection,
    required String parentDocId,
    required String collection,
    List<QueryCondition>? conditions,
    int? limit,
    String? orderBy,
    bool descending = false,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _firestore
          .collection(parentCollection)
          .doc(parentDocId)
          .collection(collection);

      if (conditions != null) {
        for (final condition in conditions) {
          query = condition.apply(query) as Query<Map<String, dynamic>>;
        }
      }

      if (orderBy != null) {
        query = query.orderBy(orderBy, descending: descending);
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      return await query.get().timeout(AppConstants.databaseTimeout);
    } on FirebaseException catch (e) {
      throw _handleFirebaseException(e);
    } catch (e) {
      throw FirestoreException.readFailed(e.toString());
    }
  }

  /// Stream documents with optional conditions
  Stream<QuerySnapshot<Map<String, dynamic>>> streamDocuments({
    required String collection,
    List<QueryCondition>? conditions,
    int? limit,
    String? orderBy,
    bool descending = false,
  }) {
    try {
      Query<Map<String, dynamic>> query = _firestore.collection(collection);

      // Apply conditions
      if (conditions != null) {
        for (final condition in conditions) {
          query = condition.apply(query) as Query<Map<String, dynamic>>;
        }
      }

      // Apply ordering
      if (orderBy != null) {
        query = query.orderBy(orderBy, descending: descending);
      }

      // Apply limit
      if (limit != null) {
        query = query.limit(limit);
      }

      return query.snapshots();
    } catch (e) {
      throw FirestoreException.readFailed(e.toString());
    }
  }

  /// Stream documents in a subcollection with optional conditions.
  Stream<QuerySnapshot<Map<String, dynamic>>> streamSubcollectionDocuments({
    required String parentCollection,
    required String parentDocId,
    required String collection,
    List<QueryCondition>? conditions,
    int? limit,
    String? orderBy,
    bool descending = false,
  }) {
    try {
      Query<Map<String, dynamic>> query = _firestore
          .collection(parentCollection)
          .doc(parentDocId)
          .collection(collection);

      if (conditions != null) {
        for (final condition in conditions) {
          query = condition.apply(query) as Query<Map<String, dynamic>>;
        }
      }

      if (orderBy != null) {
        query = query.orderBy(orderBy, descending: descending);
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      return query.snapshots();
    } catch (e) {
      throw FirestoreException.readFailed(e.toString());
    }
  }

  /// Batch write operations
  Future<void> batchWrite(List<BatchOperation> operations) async {
    try {
      final batch = _firestore.batch();

      for (final operation in operations) {
        operation.apply(batch, _firestore);
      }

      await batch.commit().timeout(AppConstants.databaseTimeout);
    } on TimeoutException {
      throw FirestoreException.writeFailed(
        'Database write timed out after ${AppConstants.databaseTimeout.inSeconds} seconds. Please check your connection and try again.',
      );
    } on FirebaseException catch (e) {
      throw _handleFirebaseException(e);
    } catch (e) {
      throw FirestoreException.writeFailed(e.toString());
    }
  }

  /// Run a transaction
  Future<T> runTransaction<T>(
    Future<T> Function(Transaction) transactionHandler,
  ) async {
    try {
      return await _firestore
          .runTransaction(transactionHandler)
          .timeout(AppConstants.databaseTimeout);
    } on FirebaseException catch (e) {
      throw _handleFirebaseException(e);
    } catch (e) {
      throw FirestoreException.writeFailed(
        'Transaction failed: ${e.toString()}',
      );
    }
  }

  /// Handle Firebase exceptions
  FirestoreException _handleFirebaseException(FirebaseException e) {
    switch (e.code) {
      case 'permission-denied':
        return FirestoreException.permissionDenied();
      case 'not-found':
        return FirestoreException.documentNotFound('');
      case 'unavailable':
        return FirestoreException(
          message: 'Service temporarily unavailable. Please try again later.',
          code: e.code,
        );
      default:
        return FirestoreException.generic(
          e.message ?? 'Database error occurred',
          code: e.code,
        );
    }
  }
}

/// Helper class for query conditions
class QueryCondition {
  final String field;
  final dynamic value;
  final String operator;

  QueryCondition({
    required this.field,
    required this.value,
    this.operator = '==',
  });

  Query apply(Query query) {
    switch (operator) {
      case '==':
        return query.where(field, isEqualTo: value);
      case '<':
        return query.where(field, isLessThan: value);
      case '<=':
        return query.where(field, isLessThanOrEqualTo: value);
      case '>':
        return query.where(field, isGreaterThan: value);
      case '>=':
        return query.where(field, isGreaterThanOrEqualTo: value);
      case 'array-contains':
        return query.where(field, arrayContains: value);
      case 'in':
        return query.where(field, whereIn: value);
      default:
        return query;
    }
  }
}

/// Helper class for batch operations
abstract class BatchOperation {
  void apply(WriteBatch batch, FirebaseFirestore firestore);
}

/// Set operation in batch
class BatchSetOperation extends BatchOperation {
  final String collection;
  final String docId;
  final Map<String, dynamic> data;
  final bool merge;

  BatchSetOperation({
    required this.collection,
    required this.docId,
    required this.data,
    this.merge = false,
  });

  @override
  void apply(WriteBatch batch, FirebaseFirestore firestore) {
    batch.set(
      firestore.collection(collection).doc(docId),
      data,
      SetOptions(merge: merge),
    );
  }
}

/// Update operation in batch
class BatchUpdateOperation extends BatchOperation {
  final String collection;
  final String docId;
  final Map<String, dynamic> data;

  BatchUpdateOperation({
    required this.collection,
    required this.docId,
    required this.data,
  });

  @override
  void apply(WriteBatch batch, FirebaseFirestore firestore) {
    batch.update(firestore.collection(collection).doc(docId), data);
  }
}

/// Delete operation in batch
class BatchDeleteOperation extends BatchOperation {
  final String collection;
  final String docId;

  BatchDeleteOperation({required this.collection, required this.docId});

  @override
  void apply(WriteBatch batch, FirebaseFirestore firestore) {
    batch.delete(firestore.collection(collection).doc(docId));
  }
}
