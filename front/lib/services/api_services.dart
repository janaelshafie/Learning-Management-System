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
}
