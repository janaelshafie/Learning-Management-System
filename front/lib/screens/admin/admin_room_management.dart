import 'package:flutter/material.dart';
import '../../services/api_services.dart';

class AdminRoomManagementScreen extends StatefulWidget {
  final int userId;

  const AdminRoomManagementScreen({super.key, required this.userId});

  @override
  State<AdminRoomManagementScreen> createState() =>
      _AdminRoomManagementScreenState();
}

class _AdminRoomManagementScreenState extends State<AdminRoomManagementScreen> {
  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>> _rooms = [];
  bool _isLoading = true;
  String? _selectedRoomType;
  String? _selectedBuilding;
  String? _selectedStatus;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadRooms();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadRooms() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _apiService.getRooms(
        roomType: _selectedRoomType,
        building: _selectedBuilding,
        status: _selectedStatus,
      );

      if (response['status'] == 'success') {
        setState(() {
          _rooms = List<Map<String, dynamic>>.from(response['rooms'] ?? []);
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message'] ?? 'Error loading rooms'),
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _deleteRoom(int roomId, String roomName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Room'),
        content: Text('Are you sure you want to delete $roomName?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final response = await _apiService.deleteRoom(roomId);
        if (response['status'] == 'success') {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Room deleted successfully')),
            );
          }
          _loadRooms();
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(response['message'] ?? 'Error deleting room'),
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: $e')));
        }
      }
    }
  }

  void _showAddRoomDialog() {
    showDialog(
      context: context,
      builder: (context) => _AddRoomDialog(
        userId: widget.userId,
        onRoomAdded: () {
          Navigator.pop(context);
          _loadRooms();
        },
      ),
    );
  }

  void _showEditRoomDialog(Map<String, dynamic> room) {
    showDialog(
      context: context,
      builder: (context) => _EditRoomDialog(
        userId: widget.userId,
        room: room,
        onRoomUpdated: () {
          Navigator.pop(context);
          _loadRooms();
        },
      ),
    );
  }

  void _showAssignRoomDialog(Map<String, dynamic> room) {
    showDialog(
      context: context,
      builder: (context) => _AssignRoomDialog(
        userId: widget.userId,
        room: room,
        onRoomAssigned: () {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Room assigned successfully')),
          );
        },
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'available':
        return Colors.green;
      case 'maintenance':
        return Colors.orange;
      case 'out_of_service':
        return Colors.red;
      case 'reserved':
        return Colors.blue;
      case 'in_use':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _getRoomTypeDisplay(String type) {
    switch (type) {
      case 'classroom':
        return 'Classroom';
      case 'lab':
        return 'Laboratory';
      case 'office':
        return 'Office';
      case 'auditorium':
        return 'Auditorium';
      default:
        return type;
    }
  }

  List<Map<String, dynamic>> get _filteredRooms {
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) return _rooms;

    return _rooms.where((room) {
      final name = room['roomName']?.toString().toLowerCase() ?? '';
      final building = room['building']?.toString().toLowerCase() ?? '';
      return name.contains(query) || building.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Room Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddRoomDialog,
            tooltip: 'Add Room',
          ),
        ],
      ),
      body: Column(
        children: [
          // Filters
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: 'Search by room name or building...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedRoomType,
                        decoration: const InputDecoration(
                          labelText: 'Room Type',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text('All Types'),
                          ),
                          const DropdownMenuItem(
                            value: 'classroom',
                            child: Text('Classroom'),
                          ),
                          const DropdownMenuItem(
                            value: 'lab',
                            child: Text('Laboratory'),
                          ),
                          const DropdownMenuItem(
                            value: 'office',
                            child: Text('Office'),
                          ),
                          const DropdownMenuItem(
                            value: 'auditorium',
                            child: Text('Auditorium'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedRoomType = value;
                          });
                          _loadRooms();
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedStatus,
                        decoration: const InputDecoration(
                          labelText: 'Status',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text('All Status'),
                          ),
                          const DropdownMenuItem(
                            value: 'available',
                            child: Text('Available'),
                          ),
                          const DropdownMenuItem(
                            value: 'maintenance',
                            child: Text('Maintenance'),
                          ),
                          const DropdownMenuItem(
                            value: 'out_of_service',
                            child: Text('Out of Service'),
                          ),
                          const DropdownMenuItem(
                            value: 'reserved',
                            child: Text('Reserved'),
                          ),
                          const DropdownMenuItem(
                            value: 'in_use',
                            child: Text('In Use'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedStatus = value;
                          });
                          _loadRooms();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Room List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredRooms.isEmpty
                ? const Center(child: Text('No rooms found'))
                : ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: _filteredRooms.length,
                    itemBuilder: (context, index) {
                      final room = _filteredRooms[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: _getStatusColor(
                              room['status'] ?? 'available',
                            ),
                            child: Icon(
                              room['roomType'] == 'lab'
                                  ? Icons.science
                                  : Icons.meeting_room,
                              color: Colors.white,
                            ),
                          ),
                          title: Text(
                            '${room['building'] ?? 'N/A'} - ${room['roomName'] ?? 'Unknown'}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Type: ${_getRoomTypeDisplay(room['roomType'] ?? '')}',
                              ),
                              Text('Capacity: ${room['capacity'] ?? 0}'),
                              if (room['statusNotes'] != null)
                                Text(
                                  'Notes: ${room['statusNotes']}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Chip(
                                label: Text(
                                  (room['status'] ?? 'available').toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.white,
                                  ),
                                ),
                                backgroundColor: _getStatusColor(
                                  room['status'] ?? 'available',
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.blue,
                                ),
                                tooltip: 'Edit Room',
                                onPressed: () => _showEditRoomDialog(room),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.assignment,
                                  color: Colors.green,
                                ),
                                tooltip: 'Assign Room',
                                onPressed: () => _showAssignRoomDialog(room),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                tooltip: 'Delete Room',
                                onPressed: () => _deleteRoom(
                                  room['roomId'],
                                  room['roomName'] ?? 'Room',
                                ),
                              ),
                            ],
                          ),
                          onTap: () => _showEditRoomDialog(room),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _AddRoomDialog extends StatefulWidget {
  final int userId;
  final VoidCallback onRoomAdded;

  const _AddRoomDialog({required this.userId, required this.onRoomAdded});

  @override
  State<_AddRoomDialog> createState() => _AddRoomDialogState();
}

class _AddRoomDialogState extends State<_AddRoomDialog> {
  final ApiService _apiService = ApiService();
  final _formKey = GlobalKey<FormState>();
  final _buildingController = TextEditingController();
  final _roomNameController = TextEditingController();
  final _capacityController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedRoomType = 'classroom';
  bool _isSubmitting = false;

  @override
  void dispose() {
    _buildingController.dispose();
    _roomNameController.dispose();
    _capacityController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final roomData = {
        'building': _buildingController.text.trim(),
        'roomName': _roomNameController.text.trim(),
        'roomType': _selectedRoomType,
        'capacity': int.tryParse(_capacityController.text) ?? 0,
        'description': _descriptionController.text.trim(),
      };

      final response = await _apiService.createRoom(roomData);

      if (response['status'] == 'success') {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Room created successfully')),
          );
        }
        widget.onRoomAdded();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message'] ?? 'Error creating room'),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Room'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _buildingController,
                decoration: const InputDecoration(
                  labelText: 'Building',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Building is required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _roomNameController,
                decoration: const InputDecoration(
                  labelText: 'Room Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Room name is required' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedRoomType,
                decoration: const InputDecoration(
                  labelText: 'Room Type',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'classroom',
                    child: Text('Classroom'),
                  ),
                  DropdownMenuItem(value: 'lab', child: Text('Laboratory')),
                  DropdownMenuItem(value: 'office', child: Text('Office')),
                  DropdownMenuItem(
                    value: 'auditorium',
                    child: Text('Auditorium'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedRoomType = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _capacityController,
                decoration: const InputDecoration(
                  labelText: 'Capacity',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Capacity is required';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (Optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _submit,
          child: _isSubmitting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Add Room'),
        ),
      ],
    );
  }
}

// Edit Room Dialog
class _EditRoomDialog extends StatefulWidget {
  final int userId;
  final Map<String, dynamic> room;
  final VoidCallback onRoomUpdated;

  const _EditRoomDialog({
    required this.userId,
    required this.room,
    required this.onRoomUpdated,
  });

  @override
  State<_EditRoomDialog> createState() => _EditRoomDialogState();
}

class _EditRoomDialogState extends State<_EditRoomDialog> {
  final ApiService _apiService = ApiService();
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _buildingController;
  late TextEditingController _roomNameController;
  late TextEditingController _capacityController;
  late TextEditingController _descriptionController;
  late TextEditingController _statusNotesController;
  late String _selectedRoomType;
  late String _selectedStatus;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _buildingController = TextEditingController(
      text: widget.room['building'] ?? '',
    );
    _roomNameController = TextEditingController(
      text: widget.room['roomName'] ?? '',
    );
    _capacityController = TextEditingController(
      text: (widget.room['capacity'] ?? 0).toString(),
    );
    _descriptionController = TextEditingController(
      text: widget.room['description'] ?? '',
    );
    _statusNotesController = TextEditingController(
      text: widget.room['statusNotes'] ?? '',
    );
    _selectedRoomType = widget.room['roomType'] ?? 'classroom';
    _selectedStatus = widget.room['status'] ?? 'available';
  }

  @override
  void dispose() {
    _buildingController.dispose();
    _roomNameController.dispose();
    _capacityController.dispose();
    _descriptionController.dispose();
    _statusNotesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final roomData = {
        'building': _buildingController.text.trim(),
        'roomName': _roomNameController.text.trim(),
        'roomType': _selectedRoomType,
        'capacity': int.tryParse(_capacityController.text) ?? 0,
        'description': _descriptionController.text.trim(),
        'status': _selectedStatus,
        'statusNotes': _statusNotesController.text.trim(),
        'updatedByUserId': widget.userId,
      };

      final response = await _apiService.updateRoom(
        widget.room['roomId'],
        roomData,
      );

      if (response['status'] == 'success') {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Room updated successfully')),
          );
        }
        widget.onRoomUpdated();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message'] ?? 'Error updating room'),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'available':
        return Colors.green;
      case 'maintenance':
        return Colors.orange;
      case 'out_of_service':
        return Colors.red;
      case 'reserved':
        return Colors.blue;
      case 'in_use':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Room'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _buildingController,
                decoration: const InputDecoration(
                  labelText: 'Building',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Building is required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _roomNameController,
                decoration: const InputDecoration(
                  labelText: 'Room Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Room name is required' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedRoomType,
                decoration: const InputDecoration(
                  labelText: 'Room Type',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'classroom',
                    child: Text('Classroom'),
                  ),
                  DropdownMenuItem(value: 'lab', child: Text('Laboratory')),
                  DropdownMenuItem(value: 'office', child: Text('Office')),
                  DropdownMenuItem(
                    value: 'auditorium',
                    child: Text('Auditorium'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedRoomType = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _capacityController,
                decoration: const InputDecoration(
                  labelText: 'Capacity',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Capacity is required';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (Optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              const Text(
                'Room Status',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedStatus,
                decoration: InputDecoration(
                  labelText: 'Status',
                  border: const OutlineInputBorder(),
                  prefixIcon: Icon(
                    Icons.circle,
                    color: _getStatusColor(_selectedStatus),
                    size: 16,
                  ),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'available',
                    child: Text('Available'),
                  ),
                  DropdownMenuItem(
                    value: 'maintenance',
                    child: Text('Under Maintenance'),
                  ),
                  DropdownMenuItem(
                    value: 'out_of_service',
                    child: Text('Out of Service'),
                  ),
                  DropdownMenuItem(value: 'reserved', child: Text('Reserved')),
                  DropdownMenuItem(value: 'in_use', child: Text('In Use')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedStatus = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _statusNotesController,
                decoration: const InputDecoration(
                  labelText: 'Status Notes (Optional)',
                  hintText: 'e.g., Under repair until Jan 5',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _submit,
          child: _isSubmitting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Save Changes'),
        ),
      ],
    );
  }
}

// Assign Room Dialog
class _AssignRoomDialog extends StatefulWidget {
  final int userId;
  final Map<String, dynamic> room;
  final VoidCallback onRoomAssigned;

  const _AssignRoomDialog({
    required this.userId,
    required this.room,
    required this.onRoomAssigned,
  });

  @override
  State<_AssignRoomDialog> createState() => _AssignRoomDialogState();
}

class _AssignRoomDialogState extends State<_AssignRoomDialog> {
  final ApiService _apiService = ApiService();
  final _formKey = GlobalKey<FormState>();
  final _purposeController = TextEditingController();
  final _notesController = TextEditingController();

  String _selectedAssignmentType = 'course';
  DateTime? _startDate;
  TimeOfDay? _startTime;
  DateTime? _endDate;
  TimeOfDay? _endTime;
  bool _isSubmitting = false;
  bool _isRecurring = false;
  String? _recurrencePattern;
  DateTime? _recurrenceEndDate;

  // For course/instructor/department selection
  List<Map<String, dynamic>> _instructors = [];
  List<Map<String, dynamic>> _departments = [];
  List<Map<String, dynamic>> _courses = [];
  int? _selectedInstructorId;
  int? _selectedDepartmentId;
  int? _selectedCourseId;
  bool _isLoadingData = true;

  @override
  void initState() {
    super.initState();
    _loadSelectionData();
  }

  @override
  void dispose() {
    _purposeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadSelectionData() async {
    try {
      // Load instructors
      final instructorsResponse = await _apiService.getAllInstructors();
      if (instructorsResponse['status'] == 'success') {
        _instructors = List<Map<String, dynamic>>.from(
          instructorsResponse['instructors'] ?? [],
        );
      }

      // Load departments
      final deptResponse = await _apiService.getDepartments();
      if (deptResponse['status'] == 'success') {
        _departments = List<Map<String, dynamic>>.from(
          deptResponse['departments'] ?? [],
        );
      }

      // Load offered courses
      final coursesResponse = await _apiService.getAllOfferedCourses();
      if (coursesResponse['status'] == 'success') {
        _courses = List<Map<String, dynamic>>.from(
          coursesResponse['offeredCourses'] ?? [],
        );
      }
    } catch (e) {
      // Handle error silently
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingData = false;
        });
      }
    }
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _selectTime(BuildContext context, bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  String _formatDateTime(DateTime date, TimeOfDay time) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')} '
        '${time.hour.toString().padLeft(2, '0')}:'
        '${time.minute.toString().padLeft(2, '0')}:00';
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_startDate == null ||
        _startTime == null ||
        _endDate == null ||
        _endTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select date and time')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final assignmentData = {
        'roomId': widget.room['roomId'],
        'assignedByUserId': widget.userId,
        'assignmentType': _selectedAssignmentType,
        'startDatetime': _formatDateTime(_startDate!, _startTime!),
        'endDatetime': _formatDateTime(_endDate!, _endTime!),
        'purpose': _purposeController.text.trim(),
        'notes': _notesController.text.trim(),
        'isRecurring': _isRecurring,
        if (_isRecurring && _recurrencePattern != null)
          'recurrencePattern': _recurrencePattern,
        if (_isRecurring && _recurrenceEndDate != null)
          'recurrenceEndDate':
              '${_recurrenceEndDate!.year}-${_recurrenceEndDate!.month.toString().padLeft(2, '0')}-${_recurrenceEndDate!.day.toString().padLeft(2, '0')}',
        if (_selectedCourseId != null)
          'relatedOfferedCourseId': _selectedCourseId,
        if (_selectedInstructorId != null)
          'relatedInstructorId': _selectedInstructorId,
        if (_selectedDepartmentId != null)
          'relatedDepartmentId': _selectedDepartmentId,
      };

      final response = await _apiService.adminAssignRoom(assignmentData);

      if (response['status'] == 'success') {
        widget.onRoomAssigned();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message'] ?? 'Error assigning room'),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Assign Room: ${widget.room['roomName']}'),
      content: _isLoadingData
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Assignment Type
                    DropdownButtonFormField<String>(
                      value: _selectedAssignmentType,
                      decoration: const InputDecoration(
                        labelText: 'Assignment Type',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'course',
                          child: Text('Course'),
                        ),
                        DropdownMenuItem(
                          value: 'instructor',
                          child: Text('Instructor'),
                        ),
                        DropdownMenuItem(
                          value: 'department',
                          child: Text('Department'),
                        ),
                        DropdownMenuItem(
                          value: 'event',
                          child: Text('Event/Other'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedAssignmentType = value;
                            _selectedCourseId = null;
                            _selectedInstructorId = null;
                            _selectedDepartmentId = null;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    // Course selection
                    if (_selectedAssignmentType == 'course') ...[
                      if (_courses.isNotEmpty)
                        DropdownButtonFormField<int>(
                          key: const ValueKey('course_dropdown'),
                          value: _selectedCourseId,
                          decoration: const InputDecoration(
                            labelText: 'Select Course',
                            border: OutlineInputBorder(),
                          ),
                          items: _courses.map((course) {
                            return DropdownMenuItem<int>(
                              value: course['offeredCourseId'] as int?,
                              child: Text(
                                course['courseName'] ?? 'Unknown Course',
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedCourseId = value;
                            });
                          },
                        )
                      else
                        const Text('No courses available'),
                      const SizedBox(height: 16),
                    ],

                    // Instructor selection
                    if (_selectedAssignmentType == 'instructor') ...[
                      if (_instructors.isNotEmpty)
                        DropdownButtonFormField<int>(
                          key: const ValueKey('instructor_dropdown'),
                          value: _selectedInstructorId,
                          decoration: const InputDecoration(
                            labelText: 'Select Instructor',
                            border: OutlineInputBorder(),
                          ),
                          items: _instructors.map((instructor) {
                            return DropdownMenuItem<int>(
                              value: instructor['userId'] as int?,
                              child: Text(instructor['name'] ?? 'Unknown'),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedInstructorId = value;
                            });
                          },
                        )
                      else
                        const Text('No instructors available'),
                      const SizedBox(height: 16),
                    ],

                    // Department selection
                    if (_selectedAssignmentType == 'department') ...[
                      if (_departments.isNotEmpty)
                        DropdownButtonFormField<int>(
                          key: const ValueKey('department_dropdown'),
                          value: _selectedDepartmentId,
                          decoration: const InputDecoration(
                            labelText: 'Select Department',
                            border: OutlineInputBorder(),
                          ),
                          items: _departments.map((dept) {
                            return DropdownMenuItem<int>(
                              value: dept['departmentId'] as int?,
                              child: Text(dept['name'] ?? 'Unknown'),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedDepartmentId = value;
                            });
                          },
                        )
                      else
                        const Text('No departments available'),
                      const SizedBox(height: 16),
                    ],

                    // Date/Time Selection
                    const Text(
                      'Start Date & Time',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.calendar_today),
                            label: Text(
                              _startDate != null
                                  ? '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}'
                                  : 'Select Date',
                            ),
                            onPressed: () => _selectDate(context, true),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.access_time),
                            label: Text(
                              _startTime != null
                                  ? _formatTimeOfDay(_startTime!)
                                  : 'Select Time',
                            ),
                            onPressed: () => _selectTime(context, true),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'End Date & Time',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.calendar_today),
                            label: Text(
                              _endDate != null
                                  ? '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'
                                  : 'Select Date',
                            ),
                            onPressed: () => _selectDate(context, false),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.access_time),
                            label: Text(
                              _endTime != null
                                  ? _formatTimeOfDay(_endTime!)
                                  : 'Select Time',
                            ),
                            onPressed: () => _selectTime(context, false),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Recurring option
                    CheckboxListTile(
                      title: const Text('Recurring Assignment'),
                      value: _isRecurring,
                      onChanged: (value) {
                        setState(() {
                          _isRecurring = value ?? false;
                        });
                      },
                      contentPadding: EdgeInsets.zero,
                    ),

                    if (_isRecurring) ...[
                      DropdownButtonFormField<String>(
                        value: _recurrencePattern,
                        decoration: const InputDecoration(
                          labelText: 'Recurrence Pattern',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'daily',
                            child: Text('Daily'),
                          ),
                          DropdownMenuItem(
                            value: 'weekly',
                            child: Text('Weekly'),
                          ),
                          DropdownMenuItem(
                            value: 'biweekly',
                            child: Text('Bi-weekly'),
                          ),
                          DropdownMenuItem(
                            value: 'monthly',
                            child: Text('Monthly'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _recurrencePattern = value;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton.icon(
                        icon: const Icon(Icons.calendar_today),
                        label: Text(
                          _recurrenceEndDate != null
                              ? 'End: ${_recurrenceEndDate!.day}/${_recurrenceEndDate!.month}/${_recurrenceEndDate!.year}'
                              : 'Select End Date',
                        ),
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now().add(
                              const Duration(days: 30),
                            ),
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(
                              const Duration(days: 365),
                            ),
                          );
                          if (picked != null) {
                            setState(() {
                              _recurrenceEndDate = picked;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Purpose
                    TextFormField(
                      controller: _purposeController,
                      decoration: const InputDecoration(
                        labelText: 'Purpose',
                        hintText: 'e.g., CS101 Lecture, Faculty Meeting',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),

                    // Notes
                    TextFormField(
                      controller: _notesController,
                      decoration: const InputDecoration(
                        labelText: 'Notes (Optional)',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
            ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isSubmitting || _isLoadingData ? null : _submit,
          child: _isSubmitting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Assign Room'),
        ),
      ],
    );
  }
}
