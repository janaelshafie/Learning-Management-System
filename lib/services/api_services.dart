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
    final url = Uri.parse('http://localhost:8080/api/admin/pending-profile-changes');

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

  Future<Map<String, dynamic>> approveProfileChange(int changeId, int adminUserId) async {
    final url = Uri.parse('http://localhost:8080/api/admin/approve-profile-change');

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

  Future<Map<String, dynamic>> rejectProfileChange(int changeId, int adminUserId) async {
    final url = Uri.parse('http://localhost:8080/api/admin/reject-profile-change');

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

  Future<Map<String, dynamic>> createDepartment(Map<String, dynamic> departmentData) async {
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

  Future<Map<String, dynamic>> updateDepartment(Map<String, dynamic> departmentData) async {
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
    final url = Uri.parse('http://localhost:8080/api/admin/departments/courses/all');

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

  Future<Map<String, dynamic>> createCourse(Map<String, dynamic> courseData) async {
    final url = Uri.parse('http://localhost:8080/api/admin/departments/courses/create');

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

  Future<Map<String, dynamic>> updateCourse(Map<String, dynamic> courseData) async {
    final url = Uri.parse('http://localhost:8080/api/admin/departments/courses/update');

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
    final url = Uri.parse('http://localhost:8080/api/admin/departments/courses/delete');

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

  Future<Map<String, dynamic>> getAllInstructors() async {
    final url = Uri.parse('http://localhost:8080/api/admin/departments/instructors');

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
  Future<Map<String, dynamic>> createAnnouncement(Map<String, String> announcementData) async {
    final url = Uri.parse('http://localhost:8080/api/admin/create-announcement');
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
    final url = Uri.parse('http://localhost:8080/api/admin/announcements/$userType');
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

  Future<Map<String, dynamic>> updateAnnouncement(Map<String, String> announcementData) async {
    final url = Uri.parse('http://localhost:8080/api/admin/update-announcement');
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
    final url = Uri.parse('http://localhost:8080/api/admin/delete-announcement');
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
    final url = Uri.parse('http://localhost:8080/api/admin/pending-profile-changes/$userId');
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

  Future<Map<String, dynamic>> getUserByEmail(String email) async {
    final url = Uri.parse('http://localhost:8080/api/auth/get-user-by-email');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
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

  Future<Map<String, dynamic>> getStudentData(int userId) async {
    final url = Uri.parse('http://localhost:8080/api/admin/student-data/$userId');
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
  Future<Map<String, dynamic>> replaceParent(Map<String, dynamic> parentData) async {
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
}