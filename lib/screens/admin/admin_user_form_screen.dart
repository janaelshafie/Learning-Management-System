import 'package:flutter/material.dart';
import '../../services/api_services.dart';

class AdminUserFormScreen extends StatefulWidget {
  final Map<String, dynamic>? user; // null for add, populated for edit

  const AdminUserFormScreen({
    super.key,
    this.user,
  });

  @override
  State<AdminUserFormScreen> createState() => _AdminUserFormScreenState();
}

class _AdminUserFormScreenState extends State<AdminUserFormScreen> {
  final ApiService _apiService = ApiService();
  final _formKey = GlobalKey<FormState>();
  
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _officialMailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();
  final _nationalIdController = TextEditingController();
  final _passwordController = TextEditingController();
  
  // Role-specific fields
  final _studentUidController = TextEditingController();
  final _officeHoursController = TextEditingController();
  final _studentNationalIdController = TextEditingController();
  
  String _selectedRole = 'student';
  String? _selectedInstructorType;
  int? _selectedDepartmentId;
  int? _selectedAdvisorId;
  bool _isLoading = false;
  bool _obscurePassword = true;
  
  List<dynamic> _departments = [];
  List<dynamic> _instructors = [];
  bool _isLoadingData = false;

  @override
  void initState() {
    super.initState();
    _loadDepartmentsAndInstructors();
    if (widget.user != null) {
      // Edit mode - populate fields
      _nameController.text = widget.user!['name'] ?? '';
      _emailController.text = widget.user!['email'] ?? '';
      _officialMailController.text = widget.user!['officialMail'] ?? '';
      _phoneController.text = widget.user!['phone'] ?? '';
      _locationController.text = widget.user!['location'] ?? '';
      _nationalIdController.text = widget.user!['nationalId'] ?? '';
      _selectedRole = (widget.user!['role'] ?? 'student').toString();
      
      // Load role-specific data if available
      if (_selectedRole == 'student' && widget.user!['studentUid'] != null) {
        _studentUidController.text = widget.user!['studentUid'] ?? '';
        _selectedDepartmentId = widget.user!['departmentId'];
        _selectedAdvisorId = widget.user!['advisorId'];
      } else if (_selectedRole == 'instructor') {
        _selectedInstructorType = widget.user!['instructorType'] ?? 'professor';
        _selectedDepartmentId = widget.user!['departmentId'];
        _officeHoursController.text = widget.user!['officeHours'] ?? '';
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _officialMailController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _nationalIdController.dispose();
    _passwordController.dispose();
    _studentUidController.dispose();
    _officeHoursController.dispose();
    _studentNationalIdController.dispose();
    super.dispose();
  }

  Future<void> _loadDepartmentsAndInstructors() async {
    setState(() {
      _isLoadingData = true;
    });

    try {
      final deptResponse = await _apiService.getAllDepartments();
      if (deptResponse['status'] == 'success') {
        _departments = deptResponse['departments'] ?? [];
      }

      final instResponse = await _apiService.getAllInstructors();
      if (instResponse['status'] == 'success') {
        _instructors = instResponse['instructors'] ?? [];
      }
    } catch (e) {
      // Ignore errors, continue with empty lists
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingData = false;
        });
      }
    }
  }

  Future<void> _saveUser() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validate role-specific fields
    if (_selectedRole == 'student') {
      if (_studentUidController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter Student UID')),
        );
        return;
      }
    } else if (_selectedRole == 'instructor') {
      if (_selectedInstructorType == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select Instructor Type')),
        );
        return;
      }
    } else if (_selectedRole == 'parent') {
      if (_studentNationalIdController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter Student National ID')),
        );
        return;
      }
    }

    setState(() {
      _isLoading = true;
    });

    try {
      if (widget.user == null) {
        // Add new user
        final userData = {
          'name': _nameController.text.trim(),
          'email': _emailController.text.trim(),
          'officialMail': _officialMailController.text.trim(),
          'phone': _phoneController.text.trim(),
          'location': _locationController.text.trim(),
          'nationalId': _nationalIdController.text.trim(),
          'password': _passwordController.text,
          'role': _selectedRole,
        };

        // Add role-specific fields
        if (_selectedRole == 'student') {
          userData['studentUid'] = _studentUidController.text.trim();
          if (_selectedDepartmentId != null) {
            userData['departmentId'] = _selectedDepartmentId.toString();
          }
          if (_selectedAdvisorId != null) {
            userData['advisorId'] = _selectedAdvisorId.toString();
          }
        } else if (_selectedRole == 'instructor') {
          userData['instructorType'] = _selectedInstructorType ?? 'professor';
          if (_selectedDepartmentId != null) {
            userData['departmentId'] = _selectedDepartmentId.toString();
          }
          if (_officeHoursController.text.trim().isNotEmpty) {
            userData['officeHours'] = _officeHoursController.text.trim();
          }
        } else if (_selectedRole == 'parent') {
          userData['studentNationalId'] = _studentNationalIdController.text.trim();
        }

        final result = await _apiService.createUser(userData);

        if (result['status'] == 'success') {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('User created successfully')),
            );
            Navigator.of(context).pop(true);
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(result['message'] ?? 'Error creating user'),
              ),
            );
          }
        }
      } else {
        // Update existing user
        final result = await _apiService.updateUser({
          'userId': widget.user!['userId'].toString(),
          'name': _nameController.text.trim(),
          'email': _emailController.text.trim(),
          'officialMail': _officialMailController.text.trim(),
          'phone': _phoneController.text.trim(),
          'location': _locationController.text.trim(),
          'role': _selectedRole,
        });

        if (result['status'] == 'success') {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('User updated successfully')),
            );
            Navigator.of(context).pop(true);
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(result['message'] ?? 'Error updating user'),
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildRoleSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'ACCOUNT ROLE',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E3A8A),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildRoleButton(
                'student',
                'Student',
                Icons.school,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildRoleButton(
                'instructor',
                'Instructor',
                Icons.menu_book,
                Colors.purple,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildRoleButton(
                'admin',
                'Admin',
                Icons.admin_panel_settings,
                Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildRoleButton(
                'parent',
                'Parent',
                Icons.family_restroom,
                Colors.green,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRoleButton(String role, String label, IconData icon, Color color) {
    final isSelected = _selectedRole == role;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedRole = role;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? color : Colors.grey[300]!,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : color,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 16),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF1E3A8A), size: 20),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E3A8A),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditMode = widget.user != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(isEditMode ? 'Edit User' : 'Create New Account'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E3A8A),
        elevation: 0,
      ),
      body: _isLoadingData
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Header Banner
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: const BoxDecoration(
                      color: Color(0xFF1E3A8A),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue[300],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.person_add,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'User Registration Form',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Enter details to generate new user, login credentials, and role-specific records.',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Form Content
                  Container(
                    margin: const EdgeInsets.all(24),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Role Selector
                          _buildRoleSelector(),
                          const SizedBox(height: 32),
                          // Personal Information Section
                          _buildSectionHeader('Personal Information', Icons.person),
                          TextFormField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              labelText: 'Full Name *',
                              hintText: 'e.g. John Doe',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.person),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter a name';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _nationalIdController,
                                  decoration: const InputDecoration(
                                    labelText: 'National ID *',
                                    hintText: 'National ID Number',
                                    border: OutlineInputBorder(),
                                    prefixIcon: Icon(Icons.badge),
                                  ),
                                  enabled: !isEditMode,
                                  validator: (value) {
                                    if (!isEditMode &&
                                        (value == null || value.trim().isEmpty)) {
                                      return 'Required';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: TextFormField(
                                  controller: _phoneController,
                                  decoration: const InputDecoration(
                                    labelText: 'Phone Number',
                                    hintText: '+1 234 567 8900',
                                    border: OutlineInputBorder(),
                                    prefixIcon: Icon(Icons.phone),
                                  ),
                                  keyboardType: TextInputType.phone,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _locationController,
                            decoration: const InputDecoration(
                              labelText: 'Address / Location',
                              hintText: '123 University Ave, City',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.location_on),
                            ),
                          ),
                          // Account Credentials Section
                          _buildSectionHeader('Account Credentials', Icons.lock),
                          TextFormField(
                            controller: _officialMailController,
                            decoration: const InputDecoration(
                              labelText: 'Official Email *',
                              hintText: 'user@university.edu',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.mail_outline),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter an official email';
                              }
                              if (!value.contains('@')) {
                                return 'Please enter a valid email';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _emailController,
                            decoration: const InputDecoration(
                              labelText: 'Personal Email *',
                              hintText: 'user@gmail.com',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.email),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter a personal email';
                              }
                              if (!value.contains('@')) {
                                return 'Please enter a valid email';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          if (!isEditMode) ...[
                            TextFormField(
                              controller: _passwordController,
                              decoration: InputDecoration(
                                labelText: 'Initial Password *',
                                border: const OutlineInputBorder(),
                                prefixIcon: const Icon(Icons.lock),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                              ),
                              obscureText: _obscurePassword,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a password';
                                }
                                if (value.length < 6) {
                                  return 'Password must be at least 6 characters';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Must be hashed before storing in DB (Backend logic).',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                          // Role-Specific Sections
                          if (_selectedRole == 'student') ...[
                            _buildSectionHeader('Student Details', Icons.school),
                            TextFormField(
                              controller: _studentUidController,
                              decoration: const InputDecoration(
                                labelText: 'Student UID *',
                                hintText: 'S-2023-XXXX',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.badge),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter Student UID';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            DropdownButtonFormField<int?>(
                              decoration: const InputDecoration(
                                labelText: 'Department',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.business),
                              ),
                              value: _selectedDepartmentId,
                              items: [
                                const DropdownMenuItem<int?>(
                                  value: null,
                                  child: Text('Select Department'),
                                ),
                                ..._departments.map((dept) {
                                  return DropdownMenuItem<int?>(
                                    value: dept['departmentId'],
                                    child: Text(dept['name'] ?? 'Unknown'),
                                  );
                                }),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _selectedDepartmentId = value;
                                  // Reset advisor when department changes
                                  _selectedAdvisorId = null;
                                });
                              },
                            ),
                            const SizedBox(height: 16),
                            DropdownButtonFormField<int?>(
                              decoration: const InputDecoration(
                                labelText: 'Advisor',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.person_outline),
                              ),
                              value: _selectedAdvisorId,
                              items: [
                                const DropdownMenuItem<int?>(
                                  value: null,
                                  child: Text('Select Faculty Advisor'),
                                ),
                                ..._instructors
                                    .where((inst) =>
                                        _selectedDepartmentId == null ||
                                        inst['departmentId'] ==
                                            _selectedDepartmentId)
                                    .map((inst) {
                                  return DropdownMenuItem<int?>(
                                    value: inst['userId'],
                                    child: Text(inst['name'] ?? 'Unknown'),
                                  );
                                }),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _selectedAdvisorId = value;
                                });
                              },
                            ),
                          ] else if (_selectedRole == 'instructor') ...[
                            _buildSectionHeader('Instructor Details', Icons.menu_book),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.purple[50],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.purple[200]!),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  DropdownButtonFormField<String>(
                                    decoration: const InputDecoration(
                                      labelText: 'Instructor Type *',
                                      border: OutlineInputBorder(),
                                    ),
                                    value: _selectedInstructorType ?? 'professor',
                                    items: const [
                                      DropdownMenuItem(
                                        value: 'professor',
                                        child: Text('Professor'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'ta',
                                        child: Text('TA'),
                                      ),
                                    ],
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedInstructorType = value;
                                      });
                                    },
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please select instructor type';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  DropdownButtonFormField<int?>(
                                    decoration: const InputDecoration(
                                      labelText: 'Department',
                                      border: OutlineInputBorder(),
                                    ),
                                    value: _selectedDepartmentId,
                                    items: [
                                      const DropdownMenuItem<int?>(
                                        value: null,
                                        child: Text('Select Department'),
                                      ),
                                      ..._departments.map((dept) {
                                        return DropdownMenuItem<int?>(
                                          value: dept['departmentId'],
                                          child: Text(dept['name'] ?? 'Unknown'),
                                        );
                                      }),
                                    ],
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedDepartmentId = value;
                                      });
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    controller: _officeHoursController,
                                    decoration: const InputDecoration(
                                      labelText: 'Office Hours',
                                      hintText: 'e.g. Mon/Wed 10:00 - 12:00',
                                      border: OutlineInputBorder(),
                                      prefixIcon: Icon(Icons.access_time),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ] else if (_selectedRole == 'parent') ...[
                            _buildSectionHeader('Parent Details', Icons.family_restroom),
                            TextFormField(
                              controller: _studentNationalIdController,
                              decoration: const InputDecoration(
                                labelText: 'Student National ID *',
                                hintText: 'Enter the National ID of the student',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.person_search),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter Student National ID';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Enter the National ID of the student you are the parent of.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                          const SizedBox(height: 32),
                          // Action Buttons
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: _isLoading
                                      ? null
                                      : () => Navigator.of(context).pop(),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                  ),
                                  child: const Text('Cancel'),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                flex: 2,
                                child: ElevatedButton.icon(
                                  onPressed: _isLoading ? null : _saveUser,
                                  icon: const Icon(Icons.person_add),
                                  label: Text(
                                    isEditMode ? 'Update User' : 'Create User',
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF1E3A8A),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
