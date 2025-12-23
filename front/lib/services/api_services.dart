import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://localhost:8080/api/auth';

  Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/login');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'status': 'error',
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'status': 'error', 'message': 'Error: $e'};
    }
  }

  Future<Map<String, dynamic>> signup(Map<String, dynamic> signupData) async {
    final url = Uri.parse('$baseUrl/signup');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(signupData),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'status': 'error',
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'status': 'error', 'message': 'Error: $e'};
    }
  }

  Future<Map<String, dynamic>> getPendingAccounts() async {
    final url = Uri.parse('http://localhost:8080/api/admin/pending-accounts');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'status': 'error',
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'status': 'error', 'message': 'Error: $e'};
    }
  }

  Future<Map<String, dynamic>> approveAccount(int userId) async {
    final url = Uri.parse('http://localhost:8080/api/admin/approve-account');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'userId': userId.toString()}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'status': 'error',
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'status': 'error', 'message': 'Error: $e'};
    }
  }

  Future<Map<String, dynamic>> rejectAccount(int userId) async {
    final url = Uri.parse('http://localhost:8080/api/admin/reject-account');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'userId': userId.toString()}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'status': 'error',
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'status': 'error', 'message': 'Error: $e'};
    }
  }

  Future<Map<String, dynamic>> getAllUsers() async {
    final url = Uri.parse('http://localhost:8080/api/admin/all-users');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'status': 'error',
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'status': 'error', 'message': 'Error: $e'};
    }
  }

  Future<Map<String, dynamic>> deleteUser(int userId) async {
    final url = Uri.parse('http://localhost:8080/api/admin/delete-user');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'userId': userId.toString()}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'status': 'error',
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'status': 'error', 'message': 'Error: $e'};
    }
  }

  Future<Map<String, dynamic>> updateUser(Map<String, dynamic> userData) async {
    final url = Uri.parse('http://localhost:8080/api/admin/update-user');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(userData),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'status': 'error',
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'status': 'error', 'message': 'Error: $e'};
    }
  }

  // Profile Changes Management Methods
  Future<Map<String, dynamic>> getPendingProfileChanges() async {
    final url = Uri.parse(
      'http://localhost:8080/api/admin/pending-profile-changes',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'status': 'error',
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'status': 'error', 'message': 'Error: $e'};
    }
  }

  Future<Map<String, dynamic>> approveProfileChange(
    int changeId,
    int adminUserId,
  ) async {
    final url = Uri.parse(
      'http://localhost:8080/api/admin/approve-profile-change',
    );

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'changeId': changeId.toString(),
          'adminUserId': adminUserId.toString(),
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'status': 'error',
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'status': 'error', 'message': 'Error: $e'};
    }
  }

  Future<Map<String, dynamic>> rejectProfileChange(
    int changeId,
    int adminUserId,
  ) async {
    final url = Uri.parse(
      'http://localhost:8080/api/admin/reject-profile-change',
    );

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'changeId': changeId.toString(),
          'adminUserId': adminUserId.toString(),
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'status': 'error',
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'status': 'error', 'message': 'Error: $e'};
    }
  }

  // Department Management Methods
  Future<Map<String, dynamic>> getAllDepartments() async {
    final url = Uri.parse('http://localhost:8080/api/admin/departments/all');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'status': 'error',
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'status': 'error', 'message': 'Error: $e'};
    }
  }

  Future<Map<String, dynamic>> createDepartment(
    Map<String, dynamic> departmentData,
  ) async {
    final url = Uri.parse('http://localhost:8080/api/admin/departments/create');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(departmentData),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'status': 'error',
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'status': 'error', 'message': 'Error: $e'};
    }
  }

  Future<Map<String, dynamic>> updateDepartment(
    Map<String, dynamic> departmentData,
  ) async {
    final url = Uri.parse('http://localhost:8080/api/admin/departments/update');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(departmentData),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'status': 'error',
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'status': 'error', 'message': 'Error: $e'};
    }
  }

  Future<Map<String, dynamic>> deleteDepartment(int departmentId) async {
    final url = Uri.parse('http://localhost:8080/api/admin/departments/delete');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'departmentId': departmentId.toString()}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'status': 'error',
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'status': 'error', 'message': 'Error: $e'};
    }
  }

  // Course Management Methods
  Future<Map<String, dynamic>> getAllCourses() async {
    final url = Uri.parse(
      'http://localhost:8080/api/admin/departments/courses/all',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'status': 'error',
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'status': 'error', 'message': 'Error: $e'};
    }
  }

  Future<Map<String, dynamic>> createCourse(
    Map<String, dynamic> courseData,
  ) async {
    final url = Uri.parse(
      'http://localhost:8080/api/admin/departments/courses/create',
    );

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(courseData),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'status': 'error',
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'status': 'error', 'message': 'Error: $e'};
    }
  }

  Future<Map<String, dynamic>> updateCourse(
    Map<String, dynamic> courseData,
  ) async {
    final url = Uri.parse(
      'http://localhost:8080/api/admin/departments/courses/update',
    );

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(courseData),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'status': 'error',
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'status': 'error', 'message': 'Error: $e'};
    }
  }

  Future<Map<String, dynamic>> deleteCourse(int courseId) async {
    final url = Uri.parse(
      'http://localhost:8080/api/admin/departments/courses/delete',
    );

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'courseId': courseId.toString()}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'status': 'error',
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'status': 'error', 'message': 'Error: $e'};
    }
  }

  Future<Map<String, dynamic>> getCoursePrerequisites(int courseId) async {
    final url = Uri.parse(
      'http://localhost:8080/api/admin/courses/$courseId/prerequisites',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'status': 'error',
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'status': 'error', 'message': 'Error: $e'};
    }
  }

  Future<Map<String, dynamic>> addPrerequisite(
    int courseId,
    int prereqCourseId,
  ) async {
    final url = Uri.parse(
      'http://localhost:8080/api/admin/courses/prerequisites/add',
    );

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'courseId': courseId.toString(),
          'prereqCourseId': prereqCourseId.toString(),
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'status': 'error',
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'status': 'error', 'message': 'Error: $e'};
    }
  }

  Future<Map<String, dynamic>> removePrerequisite(
    int courseId,
    int prereqCourseId,
  ) async {
    final url = Uri.parse(
      'http://localhost:8080/api/admin/courses/prerequisites/remove',
    );

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'courseId': courseId.toString(),
          'prereqCourseId': prereqCourseId.toString(),
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'status': 'error',
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'status': 'error', 'message': 'Error: $e'};
    }
  }

  Future<Map<String, dynamic>> linkCourseToDepartment({
    required int departmentId,
    required int courseId,
    required String courseType,
    int? capacity,
    String? eligibilityRequirements,
  }) async {
    final url = Uri.parse(
      'http://localhost:8080/api/admin/courses/departments/link',
    );

    try {
      final body = {
        'departmentId': departmentId.toString(),
        'courseId': courseId.toString(),
        'courseType': courseType,
      };
      if (capacity != null) {
        body['capacity'] = capacity.toString();
      }
      if (eligibilityRequirements != null &&
          eligibilityRequirements.isNotEmpty) {
        body['eligibilityRequirements'] = eligibilityRequirements;
      }

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'status': 'error',
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'status': 'error', 'message': 'Error: $e'};
    }
  }

  Future<Map<String, dynamic>> unlinkCourseFromDepartment(
    int departmentId,
    int courseId,
  ) async {
    final url = Uri.parse(
      'http://localhost:8080/api/admin/courses/departments/unlink',
    );

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'departmentId': departmentId.toString(),
          'courseId': courseId.toString(),
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'status': 'error',
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'status': 'error', 'message': 'Error: $e'};
    }
  }

  Future<Map<String, dynamic>> getDepartmentCourses(
    int departmentId, {
    String? courseType,
  }) async {
    String urlString =
        'http://localhost:8080/api/admin/courses/departments/$departmentId/courses';
    if (courseType != null && courseType.isNotEmpty) {
      urlString += '?courseType=$courseType';
    }
    final url = Uri.parse(urlString);

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'status': 'error',
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'status': 'error', 'message': 'Error: $e'};
    }
  }

  // Get courses by department code (from Course table, not DepartmentCourse)
  Future<Map<String, dynamic>> getCoursesByDepartmentCode(
    int departmentId,
  ) async {
    final url = Uri.parse(
      'http://localhost:8080/api/admin/departments/$departmentId/courses-by-code',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'status': 'error',
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'status': 'error', 'message': 'Error: $e'};
    }
  }

  Future<Map<String, dynamic>> getCoreCourses(int departmentId) async {
    final url = Uri.parse(
      'http://localhost:8080/api/admin/courses/departments/$departmentId/core-courses',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'status': 'error',
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'status': 'error', 'message': 'Error: $e'};
    }
  }

  Future<Map<String, dynamic>> getElectiveCourses(int departmentId) async {
    final url = Uri.parse(
      'http://localhost:8080/api/admin/courses/departments/$departmentId/elective-courses',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'status': 'error',
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'status': 'error', 'message': 'Error: $e'};
    }
  }

  Future<Map<String, dynamic>> getAllInstructors() async {
    final url = Uri.parse(
      'http://localhost:8080/api/admin/departments/instructors',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'status': 'error',
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'status': 'error', 'message': 'Error: $e'};
    }
  }

  // Announcement Management Methods
  Future<Map<String, dynamic>> createAnnouncement(
    Map<String, String> announcementData,
  ) async {
    final url = Uri.parse(
      'http://localhost:8080/api/admin/create-announcement',
    );
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(announcementData),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'status': 'error',
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'status': 'error', 'message': 'Error: $e'};
    }
  }

  Future<List<dynamic>> getAllAnnouncements() async {
    final url = Uri.parse('http://localhost:8080/api/admin/announcements');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  Future<List<dynamic>> getAnnouncementsForUserType(String userType) async {
    final url = Uri.parse(
      'http://localhost:8080/api/admin/announcements/$userType',
    );
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  Future<Map<String, dynamic>> updateAnnouncement(
    Map<String, String> announcementData,
  ) async {
    final url = Uri.parse(
      'http://localhost:8080/api/admin/update-announcement',
    );
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(announcementData),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'status': 'error',
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'status': 'error', 'message': 'Error: $e'};
    }
  }

  Future<Map<String, dynamic>> deleteAnnouncement(String announcementId) async {
    final url = Uri.parse(
      'http://localhost:8080/api/admin/delete-announcement',
    );
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'announcementId': announcementId}),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'status': 'error',
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'status': 'error', 'message': 'Error: $e'};
    }
  }

  Future<List<dynamic>> getPendingProfileChangesForUser(int userId) async {
    final url = Uri.parse(
      'http://localhost:8080/api/admin/pending-profile-changes/$userId',
    );
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          return List<Map<String, dynamic>>.from(data['data'] ?? []);
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // Get course announcements for a specific course
  Future<List<dynamic>> getCourseAnnouncements(int offeredCourseId) async {
    final url = Uri.parse(
      'http://localhost:8080/api/course/announcements/$offeredCourseId',
    );
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          return data['data'] ?? [];
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // Get course materials for a specific course
  Future<List<dynamic>> getCourseMaterials(int offeredCourseId) async {
    final url = Uri.parse(
      'http://localhost:8080/api/course/materials/$offeredCourseId',
    );
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          return data['data'] ?? [];
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // Upload course material file (for mobile/desktop - uses file path)
  Future<Map<String, dynamic>> uploadCourseMaterial({
    required int offeredCourseId,
    required String filePath,
    required String fileName,
    int? instructorId,
    String? title,
  }) async {
    final url = Uri.parse('http://localhost:8080/api/course/materials/upload');
    
    try {
      var request = http.MultipartRequest('POST', url);
      
      // Add file from path
      var file = await http.MultipartFile.fromPath('file', filePath);
      request.files.add(file);
      
      // Add form fields
      request.fields['offeredCourseId'] = offeredCourseId.toString();
      if (instructorId != null) {
        request.fields['instructorId'] = instructorId.toString();
      }
      if (title != null && title.isNotEmpty) {
        request.fields['title'] = title;
      }
      
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'status': 'error',
          'message': 'Upload failed: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Error uploading file: $e',
      };
    }
  }

  // Upload course material file (for web - uses bytes)
  Future<Map<String, dynamic>> uploadCourseMaterialFromBytes({
    required int offeredCourseId,
    required List<int> fileBytes,
    required String fileName,
    int? instructorId,
    String? title,
  }) async {
    final url = Uri.parse('http://localhost:8080/api/course/materials/upload');
    
    try {
      var request = http.MultipartRequest('POST', url);
      
      // Add file from bytes
      var file = http.MultipartFile.fromBytes(
        'file',
        fileBytes,
        filename: fileName,
      );
      request.files.add(file);
      
      // Add form fields
      request.fields['offeredCourseId'] = offeredCourseId.toString();
      if (instructorId != null) {
        request.fields['instructorId'] = instructorId.toString();
      }
      if (title != null && title.isNotEmpty) {
        request.fields['title'] = title;
      }
      
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'status': 'error',
          'message': 'Upload failed: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Error uploading file: $e',
      };
    }
  }

  // Delete course material
  Future<Map<String, dynamic>> deleteCourseMaterial(int materialId) async {
    final url = Uri.parse(
      'http://localhost:8080/api/course/materials/$materialId',
    );
    try {
      final response = await http.delete(url);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'status': 'error',
          'message': 'Delete failed: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Error deleting material: $e',
      };
    }
  }

  // Download course material
  Future<String?> downloadCourseMaterial(int materialId) async {
    final url = Uri.parse(
      'http://localhost:8080/api/course/materials/download/$materialId',
    );
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return url.toString();
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  // Create course-specific announcement
  Future<Map<String, dynamic>> createCourseAnnouncement({
    required int offeredCourseId,
    required int authorUserId,
    required String title,
    required String content,
    String? priority,
  }) async {
    final url = Uri.parse('http://localhost:8080/api/course/announcements/create');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'offeredCourseId': offeredCourseId,
          'authorUserId': authorUserId,
          'title': title,
          'content': content,
          if (priority != null) 'priority': priority,
        }),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'status': 'error',
          'message': 'Failed: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Error creating announcement: $e',
      };
    }
  }

  // Delete course announcement
  Future<Map<String, dynamic>> deleteCourseAnnouncement(int announcementId) async {
    final url = Uri.parse(
      'http://localhost:8080/api/course/announcements/$announcementId',
    );
    try {
      final response = await http.delete(url);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'status': 'error',
          'message': 'Delete failed: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Error deleting announcement: $e',
      };
    }
  }

  // Create assignment
  Future<Map<String, dynamic>> createAssignment({
    required int offeredCourseId,
    required String title,
    required String dueDate,
    String? description,
    int? instructorId,
    double? maxGrade,
  }) async {
    final url = Uri.parse('http://localhost:8080/api/course/assignments/create');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'offeredCourseId': offeredCourseId,
          'title': title,
          'dueDate': dueDate,
          if (description != null) 'description': description,
          if (instructorId != null) 'instructorId': instructorId,
          if (maxGrade != null) 'maxGrade': maxGrade,
        }),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'status': 'error',
          'message': 'Failed: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Error creating assignment: $e',
      };
    }
  }

  // Get course assignments
  Future<List<dynamic>> getCourseAssignments(int offeredCourseId) async {
    final url = Uri.parse(
      'http://localhost:8080/api/course/assignments/$offeredCourseId',
    );
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          return data['data'] ?? [];
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // Delete assignment
  Future<Map<String, dynamic>> deleteAssignment(int assignmentId) async {
    final url = Uri.parse(
      'http://localhost:8080/api/course/assignments/$assignmentId',
    );
    try {
      final response = await http.delete(url);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'status': 'error',
          'message': 'Delete failed: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Error deleting assignment: $e',
      };
    }
  }

  // Create quiz
  Future<Map<String, dynamic>> createQuiz({
    required int offeredCourseId,
    required String title,
    required String dueDate,
    String? description,
    int? instructorId,
    double? maxGrade,
  }) async {
    final url = Uri.parse('http://localhost:8080/api/course/quizzes/create');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'offeredCourseId': offeredCourseId,
          'title': title,
          'dueDate': dueDate,
          if (description != null) 'description': description,
          if (instructorId != null) 'instructorId': instructorId,
          if (maxGrade != null) 'maxGrade': maxGrade,
        }),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'status': 'error',
          'message': 'Failed: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Error creating quiz: $e',
      };
    }
  }

  // Get course quizzes
  Future<List<dynamic>> getCourseQuizzes(int offeredCourseId) async {
    final url = Uri.parse(
      'http://localhost:8080/api/course/quizzes/$offeredCourseId',
    );
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          return data['data'] ?? [];
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // Delete quiz
  Future<Map<String, dynamic>> deleteQuiz(int quizId) async {
    final url = Uri.parse(
      'http://localhost:8080/api/course/quizzes/$quizId',
    );
    try {
      final response = await http.delete(url);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'status': 'error',
          'message': 'Delete failed: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Error deleting quiz: $e',
      };
    }
  }

  // Get offered course ID by course ID and semester ID
  Future<int?> getOfferedCourseId(int courseId, int semesterId) async {
    final url = Uri.parse('http://localhost:8080/api/course/offered-course-id');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'courseId': courseId, 'semesterId': semesterId}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          return data['data']['offeredCourseId'];
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>> getUserByEmail(String email) async {
    final url = Uri.parse('http://localhost:8080/api/auth/get-user-by-email');
    print('API: getUserByEmail called with email: $email');
    print('API: URL: $url');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );
      print('API: Response status code: ${response.statusCode}');
      print('API: Response body: ${response.body}');

      if (response.statusCode == 200) {
        final decodedResponse = jsonDecode(response.body);
        print('API: Decoded response: $decodedResponse');
        return decodedResponse;
      } else {
        print('API: Error status code: ${response.statusCode}');
        return {
          'status': 'error',
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('API: Exception caught: $e');
      return {'status': 'error', 'message': 'Error: $e'};
    }
  }

  Future<Map<String, dynamic>> getStudentData(int userId) async {
    final url = Uri.parse(
      'http://localhost:8080/api/admin/student-data/$userId',
    );
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'status': 'error',
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'status': 'error', 'message': 'Error: $e'};
    }
  }

  Future<Map<String, dynamic>> getStudentRegistrationData(int studentId) async {
    final url = Uri.parse(
      'http://localhost:8080/api/student/$studentId/registration',
    );
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'status': 'error',
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'status': 'error', 'message': 'Error: $e'};
    }
  }

  Future<Map<String, dynamic>> registerStudentForSection(
    int studentId,
    int sectionId,
  ) async {
    final url = Uri.parse('http://localhost:8080/api/student/register');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'studentId': studentId, 'sectionId': sectionId}),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'status': 'error',
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'status': 'error', 'message': 'Error: $e'};
    }
  }

  Future<Map<String, dynamic>> dropStudentEnrollment(
    int studentId,
    int enrollmentId,
  ) async {
    final url = Uri.parse('http://localhost:8080/api/student/drop');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'studentId': studentId,
          'enrollmentId': enrollmentId,
        }),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'status': 'error',
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'status': 'error', 'message': 'Error: $e'};
    }
  }

  // Create a new user
  Future<Map<String, dynamic>> createUser(Map<String, dynamic> userData) async {
    final url = Uri.parse('http://localhost:8080/api/admin/create-user');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(userData),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'status': 'error',
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'status': 'error', 'message': 'Error: $e'};
    }
  }

  // Replace existing parent with new parent
  Future<Map<String, dynamic>> replaceParent(
    Map<String, dynamic> parentData,
  ) async {
    final url = Uri.parse('http://localhost:8080/api/admin/replace-parent');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(parentData),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'status': 'error',
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'status': 'error', 'message': 'Error: $e'};
    }
  }

  // ========== COURSE MANAGEMENT API METHODS ==========

  // Get all departments
  Future<Map<String, dynamic>> getDepartments() async {
    final url = Uri.parse(
      'http://localhost:8080/api/admin/courses/departments',
    );
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'status': 'error',
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'status': 'error', 'message': 'Error: $e'};
    }
  }

  // Get all semesters
  Future<Map<String, dynamic>> getSemesters() async {
    final url = Uri.parse('http://localhost:8080/api/admin/courses/semesters');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'status': 'error',
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'status': 'error', 'message': 'Error: $e'};
    }
  }

  // Create a new semester
  Future<Map<String, dynamic>> createSemester(
    Map<String, dynamic> semesterData,
  ) async {
    final url = Uri.parse('http://localhost:8080/api/admin/semesters/create');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(semesterData),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'status': 'error',
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'status': 'error', 'message': 'Error: $e'};
    }
  }

  // Update a semester
  Future<Map<String, dynamic>> updateSemester(
    Map<String, dynamic> semesterData,
  ) async {
    final url = Uri.parse('http://localhost:8080/api/admin/semesters/update');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(semesterData),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'status': 'error',
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'status': 'error', 'message': 'Error: $e'};
    }
  }

  // Get courses for a department
  Future<Map<String, dynamic>> getCoursesByDepartment(int departmentId) async {
    final url = Uri.parse(
      'http://localhost:8080/api/admin/courses/departments/$departmentId/courses',
    );
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'status': 'error',
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'status': 'error', 'message': 'Error: $e'};
    }
  }

  // Get all instructors (for course assignment)
  Future<Map<String, dynamic>> getAllInstructorsForAssignment() async {
    final url = Uri.parse(
      'http://localhost:8080/api/admin/courses/instructors/all',
    );
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'status': 'error',
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'status': 'error', 'message': 'Error: $e'};
    }
  }

  // Get instructors for a department
  Future<Map<String, dynamic>> getInstructorsByDepartment(
    int departmentId,
  ) async {
    final url = Uri.parse(
      'http://localhost:8080/api/admin/courses/departments/$departmentId/instructors',
    );
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'status': 'error',
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'status': 'error', 'message': 'Error: $e'};
    }
  }

  // Get offered courses for a semester and department
  Future<Map<String, dynamic>> getOfferedCourses(
    int semesterId,
    int departmentId,
  ) async {
    final url = Uri.parse(
      'http://localhost:8080/api/admin/courses/semesters/$semesterId/departments/$departmentId/offered-courses',
    );
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'status': 'error',
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'status': 'error', 'message': 'Error: $e'};
    }
  }

  // Get all offered courses (for room assignment)
  Future<Map<String, dynamic>> getAllOfferedCourses() async {
    final url = Uri.parse('http://localhost:8080/api/rooms/offered-courses');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'status': 'error',
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'status': 'error', 'message': 'Error: $e'};
    }
  }

  // Create an offered course
  Future<Map<String, dynamic>> createOfferedCourse(
    int courseId,
    int semesterId,
  ) async {
    final url = Uri.parse(
      'http://localhost:8080/api/admin/courses/offered-courses/create',
    );
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'courseId': courseId, 'semesterId': semesterId}),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'status': 'error',
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'status': 'error', 'message': 'Error: $e'};
    }
  }

  // Assign instructor to an offered course
  Future<Map<String, dynamic>> assignInstructor(
    int offeredCourseId,
    int instructorId,
    int departmentId,
  ) async {
    final url = Uri.parse(
      'http://localhost:8080/api/admin/courses/offered-courses/$offeredCourseId/assign-instructor',
    );
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'instructorId': instructorId,
          'departmentId': departmentId,
        }),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'status': 'error',
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'status': 'error', 'message': 'Error: $e'};
    }
  }

  // Remove an offered course
  Future<Map<String, dynamic>> removeOfferedCourse(int offeredCourseId) async {
    final url = Uri.parse(
      'http://localhost:8080/api/admin/courses/offered-courses/$offeredCourseId',
    );
    try {
      final response = await http.delete(url);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'status': 'error',
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'status': 'error', 'message': 'Error: $e'};
    }
  }

  // Get instructor data including courses, students count, and office hours
  Future<Map<String, dynamic>> getInstructorData(int instructorId) async {
    final url = Uri.parse(
      'http://localhost:8080/api/instructors/$instructorId/dashboard',
    );
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'status': 'error',
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'status': 'error', 'message': 'Error: $e'};
    }
  }

  Future<Map<String, dynamic>> getInstructorCourseDetail(
    int instructorId,
    int offeredCourseId,
  ) async {
    final url = Uri.parse(
      'http://localhost:8080/api/instructors/$instructorId/courses/$offeredCourseId',
    );
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'status': 'error',
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'status': 'error', 'message': 'Error: $e'};
    }
  }

  Future<Map<String, dynamic>> updateStudentGrade(
    int enrollmentId,
    Map<String, dynamic> gradeData,
  ) async {
    final url = Uri.parse(
      'http://localhost:8080/api/instructors/grades/$enrollmentId',
    );
    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(gradeData),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'status': 'error',
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'status': 'error', 'message': 'Error: $e'};
    }
  }

  // Grade Component Configuration
  Future<Map<String, dynamic>> getGradeComponentConfig(int offeredCourseId) async {
    final url = Uri.parse(
      'http://localhost:8080/api/course/grade-config/$offeredCourseId',
    );
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'status': 'error',
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'status': 'error', 'message': 'Error: $e'};
    }
  }

  Future<Map<String, dynamic>> configureGradeComponents(
    int offeredCourseId,
    Map<String, double?> components,
  ) async {
    final url = Uri.parse(
      'http://localhost:8080/api/course/grade-config/$offeredCourseId',
    );
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(components),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'status': 'error',
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'status': 'error', 'message': 'Error: $e'};
    }
  }

  Future<Map<String, dynamic>> calculateFinalGrade(int enrollmentId) async {
    final url = Uri.parse(
      'http://localhost:8080/api/instructors/grades/$enrollmentId/calculate-final-grade',
    );
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'status': 'error',
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'status': 'error', 'message': 'Error: $e'};
    }
  }

  // Get pending registration/drop requests for advisor
  Future<Map<String, dynamic>> getPendingRequests(int instructorId) async {
    final url = Uri.parse(
      'http://localhost:8080/api/instructors/$instructorId/pending-requests',
    );
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'status': 'error',
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'status': 'error', 'message': 'Error: $e'};
    }
  }

  // Approve or reject a registration/drop request
  Future<Map<String, dynamic>> approveRequest(
    int instructorId,
    int enrollmentId,
    String action, // "approve" or "reject"
  ) async {
    final url = Uri.parse(
      'http://localhost:8080/api/instructors/approve-request',
    );
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'instructorId': instructorId,
          'enrollmentId': enrollmentId,
          'action': action,
        }),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'status': 'error',
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'status': 'error', 'message': 'Error: $e'};
    }
  }

  // Update instructor office hours (stored as a single string column)
  Future<Map<String, dynamic>> updateInstructorOfficeHours(
    int instructorId,
    List<Map<String, dynamic>> slots,
  ) async {
    final url = Uri.parse(
      'http://localhost:8080/api/instructors/$instructorId/office-hours',
    );

    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'slots': slots}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'status': 'error',
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'status': 'error', 'message': 'Error: $e'};
    }
  }

  // Parent API methods
  Future<Map<String, dynamic>> getParentStudents(int parentId) async {
    final url = Uri.parse(
      'http://localhost:8080/api/parent/$parentId/students',
    );
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'status': 'error',
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'status': 'error', 'message': 'Error: $e'};
    }
  }

  Future<Map<String, dynamic>> getStudentAcademicRecords(int studentId) async {
    final url = Uri.parse(
      'http://localhost:8080/api/parent/student/$studentId/academic-records',
    );
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'status': 'error',
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'status': 'error', 'message': 'Error: $e'};
    }
  }

  Future<Map<String, dynamic>> getStudentCurrentCourses(int studentId) async {
    final url = Uri.parse(
      'http://localhost:8080/api/parent/student/$studentId/current-courses',
    );
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'status': 'error',
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'status': 'error', 'message': 'Error: $e'};
    }
  }

  // Messaging API methods
  Future<Map<String, dynamic>> getStudentRecipients(int studentId) async {
    final url = Uri.parse(
      'http://localhost:8080/api/message/student/$studentId/recipients',
    );
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'status': 'error',
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'status': 'error', 'message': 'Error: $e'};
    }
  }

  Future<Map<String, dynamic>> getParentRecipients(
    int parentId,
    int studentId,
  ) async {
    final url = Uri.parse(
      'http://localhost:8080/api/message/parent/$parentId/student/$studentId/recipients',
    );
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'status': 'error',
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'status': 'error', 'message': 'Error: $e'};
    }
  }

  Future<Map<String, dynamic>> sendMessage(
    int senderUserId,
    int recipientUserId,
    String content,
  ) async {
    final url = Uri.parse('http://localhost:8080/api/message/send');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'senderUserId': senderUserId,
          'recipientUserId': recipientUserId,
          'content': content,
        }),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'status': 'error',
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'status': 'error', 'message': 'Error: $e'};
    }
  }

  Future<Map<String, dynamic>> getInbox(int userId) async {
    final url = Uri.parse('http://localhost:8080/api/message/$userId/inbox');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'status': 'error',
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'status': 'error', 'message': 'Error: $e'};
    }
  }

  Future<Map<String, dynamic>> getSentMessages(int userId) async {
    final url = Uri.parse('http://localhost:8080/api/message/$userId/sent');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'status': 'error',
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'status': 'error', 'message': 'Error: $e'};
    }
  }

  Future<Map<String, dynamic>> markMessageAsRead(int messageId) async {
    final url = Uri.parse('http://localhost:8080/api/message/$messageId/read');
    try {
      final response = await http.put(url);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'status': 'error',
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'status': 'error', 'message': 'Error: $e'};
    }
  }

  // Room Management API methods
  Future<Map<String, dynamic>> getRooms({
    String? roomType,
    String? building,
    String? status,
  }) async {
    String queryParams = '';
    List<String> params = [];
    if (roomType != null) params.add('roomType=$roomType');
    if (building != null) params.add('building=$building');
    if (status != null) params.add('status=$status');
    if (params.isNotEmpty) queryParams = '?${params.join('&')}';

    final url = Uri.parse('http://localhost:8080/api/rooms/list$queryParams');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'status': 'error',
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'status': 'error', 'message': 'Error: $e'};
    }
  }

  Future<Map<String, dynamic>> getRoomById(int roomId) async {
    final url = Uri.parse('http://localhost:8080/api/rooms/$roomId');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'status': 'error',
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'status': 'error', 'message': 'Error: $e'};
    }
  }

  Future<Map<String, dynamic>> createRoom(Map<String, dynamic> roomData) async {
    final url = Uri.parse('http://localhost:8080/api/rooms');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(roomData),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        return {
          'status': 'error',
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'status': 'error', 'message': 'Error: $e'};
    }
  }

  Future<Map<String, dynamic>> deleteRoom(int roomId) async {
    final url = Uri.parse('http://localhost:8080/api/rooms/$roomId');
    try {
      final response = await http.delete(url);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'status': 'error',
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'status': 'error', 'message': 'Error: $e'};
    }
  }

  Future<Map<String, dynamic>> updateRoomStatus(
    int roomId,
    String status, {
    String? statusNotes,
    int? updatedByUserId,
  }) async {
    final url = Uri.parse('http://localhost:8080/api/rooms/$roomId/status');
    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'status': status,
          if (statusNotes != null) 'statusNotes': statusNotes,
          if (updatedByUserId != null) 'updatedByUserId': updatedByUserId,
        }),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'status': 'error',
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'status': 'error', 'message': 'Error: $e'};
    }
  }

  Future<Map<String, dynamic>> getAvailableRooms(
    String startDatetime,
    String endDatetime, {
    String? roomType,
    int? minCapacity,
  }) async {
    String queryParams =
        'startDatetime=$startDatetime&endDatetime=$endDatetime';
    if (roomType != null) queryParams += '&roomType=$roomType';
    if (minCapacity != null) queryParams += '&minCapacity=$minCapacity';

    final url = Uri.parse(
      'http://localhost:8080/api/rooms/available?$queryParams',
    );
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'status': 'error',
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'status': 'error', 'message': 'Error: $e'};
    }
  }

  Future<Map<String, dynamic>> createReservation(
    Map<String, dynamic> reservationData,
  ) async {
    final url = Uri.parse('http://localhost:8080/api/rooms/reservations');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(reservationData),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        return {
          'status': 'error',
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'status': 'error', 'message': 'Error: $e'};
    }
  }

  Future<Map<String, dynamic>> getRoomReservations(
    int roomId, {
    String? startDate,
    String? endDate,
  }) async {
    String queryParams = '';
    if (startDate != null && endDate != null) {
      queryParams = '?startDate=$startDate&endDate=$endDate';
    }

    final url = Uri.parse(
      'http://localhost:8080/api/rooms/$roomId/reservations$queryParams',
    );
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'status': 'error',
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'status': 'error', 'message': 'Error: $e'};
    }
  }

  Future<Map<String, dynamic>> getUserReservations(int userId) async {
    final url = Uri.parse(
      'http://localhost:8080/api/rooms/reservations/user/$userId',
    );
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'status': 'error',
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'status': 'error', 'message': 'Error: $e'};
    }
  }

  Future<Map<String, dynamic>> updateReservationStatus(
    int reservationId,
    String status, {
    int? approvedByUserId,
  }) async {
    final url = Uri.parse(
      'http://localhost:8080/api/rooms/reservations/$reservationId/status',
    );
    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'status': status,
          if (approvedByUserId != null) 'approvedByUserId': approvedByUserId,
        }),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'status': 'error',
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'status': 'error', 'message': 'Error: $e'};
    }
  }

  Future<Map<String, dynamic>> getPendingReservations() async {
    final url = Uri.parse(
      'http://localhost:8080/api/rooms/reservations/pending',
    );
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'status': 'error',
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'status': 'error', 'message': 'Error: $e'};
    }
  }

  // Update room (full update)
  Future<Map<String, dynamic>> updateRoom(
    int roomId,
    Map<String, dynamic> roomData,
  ) async {
    final url = Uri.parse('http://localhost:8080/api/rooms/$roomId');
    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(roomData),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'status': 'error',
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'status': 'error', 'message': 'Error: $e'};
    }
  }

  // Admin assign room
  Future<Map<String, dynamic>> adminAssignRoom(
    Map<String, dynamic> assignmentData,
  ) async {
    final url = Uri.parse('http://localhost:8080/api/rooms/admin/assign');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(assignmentData),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        return {
          'status': 'error',
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'status': 'error', 'message': 'Error: $e'};
    }
  }

  // Get all room assignments (for instructors to view)
  Future<Map<String, dynamic>> getRoomAssignments({
    String? startDate,
    String? endDate,
    int? roomId,
    int? departmentId,
    int? instructorId,
  }) async {
    List<String> params = [];
    if (startDate != null) params.add('startDate=$startDate');
    if (endDate != null) params.add('endDate=$endDate');
    if (roomId != null) params.add('roomId=$roomId');
    if (departmentId != null) params.add('departmentId=$departmentId');
    if (instructorId != null) params.add('instructorId=$instructorId');

    String queryParams = params.isNotEmpty ? '?${params.join('&')}' : '';
    final url = Uri.parse(
      'http://localhost:8080/api/rooms/assignments$queryParams',
    );
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'status': 'error',
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'status': 'error', 'message': 'Error: $e'};
    }
  }

  // ========== QUESTION MANAGEMENT ==========

  /// Create a question for a quiz or assignment
  Future<Map<String, dynamic>> createQuestion({
    required String assessmentType, // 'quiz' or 'assignment'
    required int assessmentId,
    required String questionText,
    required String questionType, // 'MCQ', 'TRUE_FALSE', 'SHORT_TEXT'
    int? questionOrder,
    double? maxMarks,
    List<String>? options, // For MCQ
    dynamic correctAnswer, // For MCQ: index (int), For TRUE_FALSE/SHORT_TEXT: string
  }) async {
    final url = Uri.parse('http://localhost:8080/api/questions/create');
    try {
      final requestData = {
        'assessmentType': assessmentType,
        'assessmentId': assessmentId,
        'questionText': questionText,
        'questionType': questionType,
        if (questionOrder != null) 'questionOrder': questionOrder,
        if (maxMarks != null) 'maxMarks': maxMarks,
        if (options != null) 'options': options,
        if (correctAnswer != null) 'correctAnswer': correctAnswer,
      };

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        return {
          'status': 'error',
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'status': 'error', 'message': 'Error: $e'};
    }
  }

  /// Update a question
  Future<Map<String, dynamic>> updateQuestion({
    required int questionId,
    String? questionText,
    int? questionOrder,
    double? maxMarks,
    List<String>? options,
    dynamic correctAnswer,
  }) async {
    final url = Uri.parse('http://localhost:8080/api/questions/$questionId');
    try {
      final requestData = <String, dynamic>{};
      if (questionText != null) requestData['questionText'] = questionText;
      if (questionOrder != null) requestData['questionOrder'] = questionOrder;
      if (maxMarks != null) requestData['maxMarks'] = maxMarks;
      if (options != null) requestData['options'] = options;
      if (correctAnswer != null) requestData['correctAnswer'] = correctAnswer;

      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestData),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'status': 'error',
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'status': 'error', 'message': 'Error: $e'};
    }
  }

  /// Get a question by ID
  Future<Map<String, dynamic>> getQuestion(int questionId) async {
    final url = Uri.parse('http://localhost:8080/api/questions/$questionId');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'status': 'error',
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'status': 'error', 'message': 'Error: $e'};
    }
  }

  /// Get all questions for a quiz/assignment
  Future<Map<String, dynamic>> getQuestionsForAssessment({
    required String assessmentType,
    required int assessmentId,
  }) async {
    final url = Uri.parse(
      'http://localhost:8080/api/questions/assessment/$assessmentType/$assessmentId',
    );
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'status': 'error',
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'status': 'error', 'message': 'Error: $e'};
    }
  }

  /// Delete a question
  Future<Map<String, dynamic>> deleteQuestion(int questionId) async {
    final url = Uri.parse('http://localhost:8080/api/questions/$questionId');
    try {
      final response = await http.delete(url);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'status': 'error',
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'status': 'error', 'message': 'Error: $e'};
    }
  }

  // ========== STUDENT ANSWER MANAGEMENT ==========

  /// Submit an answer for a question
  Future<Map<String, dynamic>> submitAnswer({
    required int studentId,
    required int questionId,
    required String questionType,
    dynamic selectedOption, // For MCQ: index or option text
    String? answer, // For TRUE_FALSE/SHORT_TEXT: the answer
  }) async {
    final url = Uri.parse('http://localhost:8080/api/student-answers/submit');
    try {
      final requestData = {
        'studentId': studentId,
        'questionId': questionId,
        'questionType': questionType,
        if (selectedOption != null) 'selectedOption': selectedOption,
        if (answer != null) 'answer': answer,
      };

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        return {
          'status': 'error',
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'status': 'error', 'message': 'Error: $e'};
    }
  }

  /// Grade a student answer (instructor reviews and sets grade/feedback)
  Future<Map<String, dynamic>> gradeAnswer({
    required int studentAnswerId,
    required double grade,
    String? feedback,
  }) async {
    final url = Uri.parse(
      'http://localhost:8080/api/student-answers/$studentAnswerId/grade',
    );
    try {
      final requestData = {
        'grade': grade,
        if (feedback != null) 'feedback': feedback,
      };

      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestData),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'status': 'error',
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'status': 'error', 'message': 'Error: $e'};
    }
  }

  /// Get all answers for a quiz/assignment (for instructor to review)
  Future<Map<String, dynamic>> getAnswersForAssessment({
    required String assessmentType,
    required int assessmentId,
  }) async {
    final url = Uri.parse(
      'http://localhost:8080/api/student-answers/assessment/$assessmentType/$assessmentId',
    );
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'status': 'error',
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'status': 'error', 'message': 'Error: $e'};
    }
  }

  /// Get all answers for a student for a quiz/assignment
  Future<Map<String, dynamic>> getStudentAnswersForAssessment({
    required int studentId,
    required String assessmentType,
    required int assessmentId,
  }) async {
    final url = Uri.parse(
      'http://localhost:8080/api/student-answers/student/$studentId/assessment/$assessmentType/$assessmentId',
    );
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'status': 'error',
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'status': 'error', 'message': 'Error: $e'};
    }
  }

  /// Get all answers for a specific question (for instructor to review)
  Future<Map<String, dynamic>> getAnswersForQuestion(int questionId) async {
    final url = Uri.parse(
      'http://localhost:8080/api/student-answers/question/$questionId',
    );
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'status': 'error',
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'status': 'error', 'message': 'Error: $e'};
    }
  }

  // ========== Assignment File Methods ==========

  /// Upload question file for an assignment (instructor) - path-based (mobile/desktop)
  Future<Map<String, dynamic>> uploadAssignmentQuestionFile({
    required int assignmentId,
    required String filePath,
  }) async {
    final url = Uri.parse(
      'http://localhost:8080/api/course/assignments/$assignmentId/question-file/upload',
    );
    
    try {
      var request = http.MultipartRequest('POST', url);
      var file = await http.MultipartFile.fromPath('file', filePath);
      request.files.add(file);
      
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'status': 'error',
          'message': 'Upload failed: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Error uploading file: $e',
      };
    }
  }

  /// Upload question file for an assignment (instructor) - bytes-based (web)
  Future<Map<String, dynamic>> uploadAssignmentQuestionFileFromBytes({
    required int assignmentId,
    required List<int> fileBytes,
    required String fileName,
  }) async {
    final url = Uri.parse(
      'http://localhost:8080/api/course/assignments/$assignmentId/question-file/upload',
    );
    
    try {
      var request = http.MultipartRequest('POST', url);
      var file = http.MultipartFile.fromBytes(
        'file',
        fileBytes,
        filename: fileName,
      );
      request.files.add(file);
      
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'status': 'error',
          'message': 'Upload failed: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Error uploading file: $e',
      };
    }
  }

  /// Get question file info for an assignment
  Future<Map<String, dynamic>> getAssignmentQuestionFileInfo(int assignmentId) async {
    final url = Uri.parse(
      'http://localhost:8080/api/course/assignments/$assignmentId/question-file',
    );
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'status': 'error',
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'status': 'error', 'message': 'Error: $e'};
    }
  }

  /// Download question file for an assignment
  Future<String?> downloadAssignmentQuestionFile(int assignmentId) async {
    final url = Uri.parse(
      'http://localhost:8080/api/course/assignments/$assignmentId/question-file/download',
    );
    return url.toString(); // Return URL for url_launcher
  }

  /// Delete question file for an assignment
  Future<Map<String, dynamic>> deleteAssignmentQuestionFile(int assignmentId) async {
    final url = Uri.parse(
      'http://localhost:8080/api/course/assignments/$assignmentId/question-file',
    );
    try {
      final response = await http.delete(url);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'status': 'error',
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'status': 'error', 'message': 'Error: $e'};
    }
  }

  /// Upload answer file for an assignment (student) - path-based (mobile/desktop)
  Future<Map<String, dynamic>> submitAssignmentAnswerFile({
    required int assignmentId,
    required int studentId,
    required String filePath,
  }) async {
    final url = Uri.parse(
      'http://localhost:8080/api/course/assignments/$assignmentId/submit',
    );
    
    try {
      var request = http.MultipartRequest('POST', url);
      var file = await http.MultipartFile.fromPath('file', filePath);
      request.files.add(file);
      request.fields['studentId'] = studentId.toString();
      
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'status': 'error',
          'message': 'Upload failed: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Error uploading file: $e',
      };
    }
  }

  /// Upload answer file for an assignment (student) - bytes-based (web)
  Future<Map<String, dynamic>> submitAssignmentAnswerFileFromBytes({
    required int assignmentId,
    required int studentId,
    required List<int> fileBytes,
    required String fileName,
  }) async {
    final url = Uri.parse(
      'http://localhost:8080/api/course/assignments/$assignmentId/submit',
    );
    
    try {
      var request = http.MultipartRequest('POST', url);
      var file = http.MultipartFile.fromBytes(
        'file',
        fileBytes,
        filename: fileName,
      );
      request.files.add(file);
      request.fields['studentId'] = studentId.toString();
      
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'status': 'error',
          'message': 'Upload failed: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Error uploading file: $e',
      };
    }
  }

  /// Get all submissions for an assignment (instructor view)
  Future<Map<String, dynamic>> getAssignmentSubmissions(int assignmentId) async {
    final url = Uri.parse(
      'http://localhost:8080/api/course/assignments/$assignmentId/submissions',
    );
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'status': 'error',
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'status': 'error', 'message': 'Error: $e'};
    }
  }

  /// Get student's submission for an assignment
  Future<Map<String, dynamic>> getStudentAssignmentSubmission({
    required int assignmentId,
    required int studentId,
  }) async {
    final url = Uri.parse(
      'http://localhost:8080/api/course/assignments/$assignmentId/submissions/$studentId',
    );
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'status': 'error',
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'status': 'error', 'message': 'Error: $e'};
    }
  }

  /// Download student answer file
  Future<String?> downloadAssignmentAnswerFile(int submissionId) async {
    final url = Uri.parse(
      'http://localhost:8080/api/course/assignments/submissions/$submissionId/download',
    );
    return url.toString(); // Return URL for url_launcher
  }

  /// Grade an assignment submission
  Future<Map<String, dynamic>> gradeAssignmentSubmission({
    required int submissionId,
    required double grade,
    String? feedback,
  }) async {
    final url = Uri.parse(
      'http://localhost:8080/api/course/assignments/submissions/$submissionId/grade',
    );
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'grade': grade,
          if (feedback != null) 'feedback': feedback,
        }),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'status': 'error',
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'status': 'error', 'message': 'Error: $e'};
    }
  }
}
