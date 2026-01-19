import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';
import '../../core/cache/admin_cache_service.dart';
import '../../core/sync/admin_sync_manager.dart';
import '../../core/sync/admin_sync_operation.dart';

/// Offline-first repository for schools
class SchoolOfflineRepository {
  final Dio dio;
  final AdminCacheService _cache = AdminCacheService();
  final AdminSyncManager _syncManager = AdminSyncManager();
  final Uuid _uuid = const Uuid();

  String serverUrl = 'http://10.240.0.129:8000';

  SchoolOfflineRepository(this.dio);

  /// Get all schools (offline-first)
  Future<List<Map<String, dynamic>>> getSchools() async {
    try {
      // Try to fetch from server first
      final response = await dio.get('$serverUrl/api/schools');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        final schools = data.map((e) => Map<String, dynamic>.from(e)).toList();

        // Cache the data
        await _cache.cacheSchools(schools);

        return schools;
      }
    } catch (e) {
      print('Failed to fetch from server: $e');
    }

    // Fallback to cache
    final cached = _cache.getCachedSchools();
    print('Returning ${cached.length} schools from cache');
    return cached;
  }

  /// Get school by ID (offline-first)
  Future<Map<String, dynamic>?> getSchool(String id) async {
    try {
      final response = await dio.get('$serverUrl/api/schools/$id');

      if (response.statusCode == 200) {
        final school = Map<String, dynamic>.from(response.data);
        await _cache.cacheSchool(school);
        return school;
      }
    } catch (e) {
      print('Failed to fetch school from server: $e');
    }

    // Fallback to cache
    return _cache.getCachedSchool(id);
  }

  /// Create school (works offline)
  Future<Map<String, dynamic>> createSchool(Map<String, dynamic> school) async {
    // Generate ID if not present
    if (!school.containsKey('id') || school['id'] == null) {
      school['id'] = _uuid.v4();
    }

    school['created_at'] = DateTime.now().toIso8601String();
    school['updated_at'] = DateTime.now().toIso8601String();

    try {
      // Try to create on server
      final response = await dio.post('$serverUrl/api/schools', data: school);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final created = Map<String, dynamic>.from(response.data);
        await _cache.cacheSchool(created);
        return created;
      }
    } catch (e) {
      print('Server unavailable, queueing create operation: $e');
    }

    // Server unavailable - queue operation and save locally
    await _syncManager.queueOperation(
      type: AdminOperationType.create,
      entity: 'school',
      data: school,
    );

    // Save to cache immediately (optimistic update)
    await _cache.cacheSchool(school);

    return school;
  }

  /// Update school (works offline)
  Future<Map<String, dynamic>> updateSchool(String id, Map<String, dynamic> school) async {
    school['id'] = id;
    school['updated_at'] = DateTime.now().toIso8601String();

    try {
      // Try to update on server
      final response = await dio.put('$serverUrl/api/schools/$id', data: school);

      if (response.statusCode == 200) {
        final updated = Map<String, dynamic>.from(response.data);
        await _cache.cacheSchool(updated);
        return updated;
      }
    } catch (e) {
      print('Server unavailable, queueing update operation: $e');
    }

    // Server unavailable - queue operation and update cache
    await _syncManager.queueOperation(
      type: AdminOperationType.update,
      entity: 'school',
      data: school,
    );

    // Update cache immediately (optimistic update)
    await _cache.cacheSchool(school);

    return school;
  }

  /// Delete school (works offline)
  Future<bool> deleteSchool(String id) async {
    try {
      // Try to delete on server
      final response = await dio.delete('$serverUrl/api/schools/$id');

      if (response.statusCode == 200 || response.statusCode == 204) {
        await _cache.removeCachedSchool(id);
        return true;
      }
    } catch (e) {
      print('Server unavailable, queueing delete operation: $e');
    }

    // Server unavailable - queue operation
    await _syncManager.queueOperation(
      type: AdminOperationType.delete,
      entity: 'school',
      data: {'id': id},
    );

    // Remove from cache immediately (optimistic update)
    await _cache.removeCachedSchool(id);

    return true;
  }

  /// Search schools (cache only when offline)
  Future<List<Map<String, dynamic>>> searchSchools(String query) async {
    try {
      final response = await dio.get(
        '$serverUrl/api/schools/search',
        queryParameters: {'q': query},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((e) => Map<String, dynamic>.from(e)).toList();
      }
    } catch (e) {
      print('Search failed, searching in cache: $e');
    }

    // Search in cache
    final cached = _cache.getCachedSchools();
    return cached.where((school) {
      final name = school['name']?.toString().toLowerCase() ?? '';
      final address = school['address']?.toString().toLowerCase() ?? '';
      final q = query.toLowerCase();
      return name.contains(q) || address.contains(q);
    }).toList();
  }
}
