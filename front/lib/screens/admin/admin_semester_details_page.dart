import 'package:flutter/material.dart';
import '../../services/api_services.dart';
import '../../common/app_state.dart';

class AdminSemesterDetailsPage extends StatefulWidget {
  final Map<String, dynamic> semester;
  final bool isReadOnly;

  const AdminSemesterDetailsPage({
    super.key,
    required this.semester,
    this.isReadOnly = false,
  });

  @override
  State<AdminSemesterDetailsPage> createState() =>
      _AdminSemesterDetailsPageState();
}

class _AdminSemesterDetailsPageState extends State<AdminSemesterDetailsPage> {
  final ApiService _apiService = ApiService();
  List<dynamic> _allOfferedCourses = [];
  List<dynamic> _departments = [];
  List<dynamic> _allCourses = [];
  bool _isLoading = true;
  bool _registrationOpen = false;

  @override
  void initState() {
    super.initState();
    _registrationOpen = widget.semester['registrationOpen'] ?? false;
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load departments
      final deptResponse = await _apiService.getAllDepartments();
      if (deptResponse['status'] == 'success') {
        _departments = deptResponse['departments'] ?? [];
      }

      // Load all courses
      final coursesResponse = await _apiService.getAllCourses();
      if (coursesResponse['status'] == 'success') {
        _allCourses = coursesResponse['courses'] ?? [];
      }

      // Load offered courses for each department
      await _loadOfferedCourses();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading data: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadOfferedCourses() async {
    List<dynamic> newOfferedCourses = [];
    for (var dept in _departments) {
      try {
        final offeredResponse = await _apiService.getOfferedCourses(
          widget.semester['semesterId'],
          dept['departmentId'],
        );
        if (offeredResponse['status'] == 'success') {
          final courses = offeredResponse['offeredCourses'] ?? [];
          for (var course in courses) {
            course['departmentName'] = dept['name'];
            course['departmentId'] = dept['departmentId'];
            
            // Load room assignments for this course
            try {
              // Format dates to yyyy-MM-dd
              String? startDateStr;
              String? endDateStr;
              
              if (widget.semester['startDate'] != null) {
                final startDate = DateTime.tryParse(widget.semester['startDate'].toString());
                if (startDate != null) {
                  startDateStr = '${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}';
                }
              }
              
              if (widget.semester['endDate'] != null) {
                final endDate = DateTime.tryParse(widget.semester['endDate'].toString());
                if (endDate != null) {
                  endDateStr = '${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}';
                }
              }
              
              final roomAssignmentsResponse = await _apiService.getRoomAssignments(
                startDate: startDateStr,
                endDate: endDateStr,
              );
              if (roomAssignmentsResponse['status'] == 'success') {
                final assignments = roomAssignmentsResponse['assignments'] ?? [];
                // Find assignments for this course
                final courseAssignments = assignments.where((assignment) {
                  return assignment['relatedOfferedCourseId'] == course['offeredCourseId'] &&
                         (assignment['isRecurring'] == true || assignment['isRecurring'] == 'true');
                }).toList();
                
                if (courseAssignments.isNotEmpty) {
                  // Get the first recurring assignment
                  final assignment = courseAssignments[0];
                  course['roomAssignment'] = assignment;
                }
              }
            } catch (e) {
              // Continue if room assignment fetch fails
            }
            
            newOfferedCourses.add(course);
          }
        }
      } catch (e) {
        // Continue with next department
      }
    }
    if (mounted) {
      setState(() {
        _allOfferedCourses = newOfferedCourses;
      });
    }
  }
  
  String _formatRoomAssignment(Map<String, dynamic>? assignment) {
    if (assignment == null) return '';
    
    // Backend returns 'roomName' not 'roomNumber'
    final roomName = assignment['roomName'] ?? assignment['roomNumber'] ?? 'Unknown';
    final building = assignment['building'] ?? '';
    final roomDisplay = building.toString().isNotEmpty ? '$building $roomName' : roomName.toString();
    
    // Extract day from recurrence pattern (e.g., "WEEKLY:Wednesday" -> "Wed")
    String dayAbbr = '';
    if (assignment['recurrencePattern'] != null) {
      final pattern = assignment['recurrencePattern'].toString();
      if (pattern.contains(':')) {
        final dayName = pattern.split(':')[1];
        final dayMap = {
          'Monday': 'Mon',
          'Tuesday': 'Tue',
          'Wednesday': 'Wed',
          'Thursday': 'Thu',
          'Friday': 'Fri',
          'Saturday': 'Sat',
          'Sunday': 'Sun',
        };
        dayAbbr = dayMap[dayName] ?? dayName.substring(0, 3);
      }
    }
    
    // Extract time from start_datetime and end_datetime
    String timeDisplay = '';
    try {
      if (assignment['startDatetime'] != null && assignment['endDatetime'] != null) {
        final startStr = assignment['startDatetime'].toString();
        final endStr = assignment['endDatetime'].toString();
        
        // Parse datetime strings (format: "yyyy-MM-dd HH:mm:ss" or timestamp)
        DateTime? startTime;
        DateTime? endTime;
        
        if (startStr.contains('T')) {
          startTime = DateTime.parse(startStr.split('T')[0] + ' ' + startStr.split('T')[1].split('.')[0]);
        } else if (startStr.contains(' ')) {
          startTime = DateTime.parse(startStr.split('.')[0]);
        }
        
        if (endStr.contains('T')) {
          endTime = DateTime.parse(endStr.split('T')[0] + ' ' + endStr.split('T')[1].split('.')[0]);
        } else if (endStr.contains(' ')) {
          endTime = DateTime.parse(endStr.split('.')[0]);
        }
        
        if (startTime != null && endTime != null) {
          final startHour = startTime.hour;
          final startMin = startTime.minute;
          final endHour = endTime.hour;
          final endMin = endTime.minute;
          
          // Format as "HH:MM-HH:MM" or "H-H" if minutes are 0
          if (startMin == 0 && endMin == 0) {
            timeDisplay = '$startHour-$endHour';
          } else {
            timeDisplay = '${startHour.toString().padLeft(2, '0')}:${startMin.toString().padLeft(2, '0')}-${endHour.toString().padLeft(2, '0')}:${endMin.toString().padLeft(2, '0')}';
          }
        }
      }
    } catch (e) {
      // If parsing fails, try to extract from string
    }
    
    if (dayAbbr.isNotEmpty && timeDisplay.isNotEmpty) {
      return '$roomDisplay, $dayAbbr $timeDisplay';
    } else if (dayAbbr.isNotEmpty) {
      return '$roomDisplay, $dayAbbr';
    } else if (timeDisplay.isNotEmpty) {
      return '$roomDisplay, $timeDisplay';
    }
    
    return roomDisplay;
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'Unknown';
    try {
      final date = DateTime.parse(dateString);
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateString;
    }
  }

  Future<void> _openNewCourse() async {
    if (widget.isReadOnly) return;

    // Get courses not yet offered in this semester
    final offeredCourseIds = _allOfferedCourses
        .map((oc) => oc['courseId'] as int?)
        .where((id) => id != null)
        .toSet();

    final availableCourses = _allCourses.where((course) {
      return !offeredCourseIds.contains(course['courseId']);
    }).toList();

    if (availableCourses.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No available courses to open')),
      );
      return;
    }

    int? selectedCourseId;
    int? selectedDepartmentId;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Open New Course'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<int?>(
                  decoration: const InputDecoration(
                    labelText: 'Select Department',
                    border: OutlineInputBorder(),
                  ),
                  items: _departments.map((dept) {
                    return DropdownMenuItem<int?>(
                      value: dept['departmentId'],
                      child: Text(dept['name']),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setDialogState(() {
                      selectedDepartmentId = value;
                      selectedCourseId = null; // Reset course selection
                    });
                  },
                ),
                if (selectedDepartmentId != null) ...[
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int?>(
                    decoration: const InputDecoration(
                      labelText: 'Select Course',
                      border: OutlineInputBorder(),
                    ),
                    items: availableCourses
                        .where((course) {
                          // Filter courses by department if possible
                          return true; // For now, show all courses
                        })
                        .map((course) {
                      return DropdownMenuItem<int?>(
                        value: course['courseId'],
                        child: Text(
                          '${course['courseCode'] ?? ''} - ${course['title'] ?? 'Unknown'}',
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setDialogState(() {
                        selectedCourseId = value;
                      });
                    },
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: (selectedCourseId == null ||
                      selectedDepartmentId == null)
                  ? null
                  : () async {
                      try {
                        final result = await _apiService.createOfferedCourse(
                          selectedCourseId!,
                          widget.semester['semesterId'],
                        );

                        if (result['status'] == 'success') {
                          Navigator.of(context).pop();
                          // Reload offered courses to show the newly opened course
                          await _loadOfferedCourses();
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Course opened successfully'),
                              ),
                            );
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                result['message'] ?? 'Error opening course',
                              ),
                            ),
                          );
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: $e')),
                        );
                      }
                    },
              child: const Text('Open Course'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleRegistration() async {
    if (widget.isReadOnly) return;

    setState(() {
      _registrationOpen = !_registrationOpen;
    });

    try {
      final result = await _apiService.updateSemester({
        'semesterId': widget.semester['semesterId'].toString(),
        'name': widget.semester['name'],
        'startDate': widget.semester['startDate'],
        'endDate': widget.semester['endDate'],
        'registrationOpen': _registrationOpen,
      });

      if (result['status'] != 'success') {
        setState(() {
          _registrationOpen = !_registrationOpen; // Revert on error
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result['message'] ?? 'Error updating registration status',
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _registrationOpen
                  ? 'Registration opened'
                  : 'Registration closed',
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _registrationOpen = !_registrationOpen; // Revert on error
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _assignInstructor(Map<String, dynamic> offeredCourse) async {
    if (widget.isReadOnly) return;

    final departmentId = offeredCourse['departmentId'];
    if (departmentId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Department information missing')),
      );
      return;
    }

    // Load all instructors
    List<dynamic> allInstructors = [];
    try {
      final instResponse =
          await _apiService.getAllInstructorsForAssignment();
      if (instResponse['status'] == 'success') {
        allInstructors = instResponse['instructors'] ?? [];
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading instructors: $e')),
      );
      return;
    }

    if (allInstructors.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No instructors available'),
        ),
      );
      return;
    }

    int? selectedInstructorId;
    String searchQuery = '';
    List<dynamic> filteredInstructors = allInstructors;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          // Filter instructors based on search query
          if (searchQuery.isNotEmpty) {
            filteredInstructors = allInstructors.where((instructor) {
              final name = (instructor['name'] ?? '').toString().toLowerCase();
              final email = (instructor['email'] ?? '').toString().toLowerCase();
              final query = searchQuery.toLowerCase();
              return name.contains(query) || email.contains(query);
            }).toList();
          } else {
            filteredInstructors = allInstructors;
          }

          return AlertDialog(
            title: const Text('Assign Instructor'),
            content: SizedBox(
              width: double.maxFinite,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Search field
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Search Instructor',
                        hintText: 'Type name or email to search...',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        setDialogState(() {
                          searchQuery = value;
                          selectedInstructorId = null; // Reset selection on search
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    // Dropdown with filtered instructors
                    DropdownButtonFormField<int?>(
                      decoration: const InputDecoration(
                        labelText: 'Select Instructor',
                        border: OutlineInputBorder(),
                      ),
                      value: selectedInstructorId,
                      items: filteredInstructors.map((instructor) {
                        final name = instructor['name'] ?? 'Unknown Instructor';
                        final email = instructor['email'] ?? '';
                        String displayName = name;
                        if (email.isNotEmpty) {
                          displayName += ' ($email)';
                        }
                        return DropdownMenuItem<int?>(
                          value: instructor['instructorId'],
                          child: Text(displayName),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setDialogState(() {
                          selectedInstructorId = value;
                        });
                      },
                    ),
                    if (filteredInstructors.isEmpty && searchQuery.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          'No instructors found matching "$searchQuery"',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: selectedInstructorId == null
                    ? null
                    : () async {
                        try {
                          final result = await _apiService.assignInstructor(
                            offeredCourse['offeredCourseId'],
                            selectedInstructorId!,
                            departmentId,
                          );

                          if (result['status'] == 'success') {
                            Navigator.of(context).pop();
                            _loadOfferedCourses();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Instructor assigned successfully'),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  result['message'] ??
                                      'Error assigning instructor',
                                ),
                              ),
                            );
                          }
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error: $e')),
                          );
                        }
                      },
                child: const Text('Assign'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _assignRoom(Map<String, dynamic> offeredCourse) async {
    if (widget.isReadOnly) return;

    // Check if currentUserId is set
    if (currentUserId == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User not logged in. Please log in again.'),
        ),
      );
      return;
    }

    // Load all rooms
    List<dynamic> allRooms = [];
    try {
      final roomsResponse = await _apiService.getRooms();
      if (roomsResponse['status'] == 'success') {
        allRooms = roomsResponse['rooms'] ?? [];
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              roomsResponse['message'] ?? 'Error loading rooms',
            ),
          ),
        );
        return;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading rooms: $e')),
      );
      return;
    }

    if (allRooms.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No rooms available'),
        ),
      );
      return;
    }

    int? selectedRoomId;
    String searchQuery = '';
    String? selectedDayOfWeek;
    TimeOfDay? startTime;
    TimeOfDay? endTime;
    List<dynamic> filteredRooms = allRooms;
    
    final List<String> weekDays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          // Filter rooms based on search query
          if (searchQuery.isNotEmpty) {
            filteredRooms = allRooms.where((room) {
              final roomNumber = (room['roomNumber'] ?? '').toString().toLowerCase();
              final building = (room['building'] ?? '').toString().toLowerCase();
              final roomType = (room['roomType'] ?? '').toString().toLowerCase();
              final query = searchQuery.toLowerCase();
              return roomNumber.contains(query) || 
                     building.contains(query) || 
                     roomType.contains(query);
            }).toList();
          } else {
            filteredRooms = allRooms;
          }

          return AlertDialog(
            title: const Text('Assign Room'),
            content: SizedBox(
              width: double.maxFinite,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Search field
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Search Room',
                        hintText: 'Type room number, building, or type...',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        setDialogState(() {
                          searchQuery = value;
                          selectedRoomId = null; // Reset selection on search
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    // Room dropdown
                    DropdownButtonFormField<int?>(
                      decoration: const InputDecoration(
                        labelText: 'Select Room',
                        border: OutlineInputBorder(),
                      ),
                      value: selectedRoomId,
                      items: filteredRooms.map((room) {
                        final roomNumber = room['roomNumber'] ?? 'Unknown';
                        final building = room['building'] ?? '';
                        final roomType = room['roomType'] ?? '';
                        final capacity = room['capacity'] ?? '';
                        String displayName = '$building $roomNumber';
                        if (roomType.isNotEmpty) {
                          displayName += ' ($roomType)';
                        }
                        if (capacity.toString().isNotEmpty) {
                          displayName += ' - Capacity: $capacity';
                        }
                        return DropdownMenuItem<int?>(
                          value: room['roomId'],
                          child: Text(displayName),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setDialogState(() {
                          selectedRoomId = value;
                        });
                      },
                    ),
                    if (filteredRooms.isEmpty && searchQuery.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          'No rooms found matching "$searchQuery"',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),
                    // Day of week selector (always weekly recurring)
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Day of Week',
                        border: OutlineInputBorder(),
                        helperText: 'Select which day of the week (repeats weekly for entire semester)',
                      ),
                      value: selectedDayOfWeek,
                      items: weekDays.map((day) {
                        return DropdownMenuItem<String>(
                          value: day,
                          child: Text(day),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setDialogState(() {
                          selectedDayOfWeek = value;
                        });
                      },
                    ),
                    const SizedBox(height: 8),
                    // Start time picker
                    ListTile(
                      title: Text(
                        startTime == null
                            ? 'Select Start Time'
                            : 'Start Time: ${startTime!.format(context)}',
                      ),
                      trailing: const Icon(Icons.access_time),
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        if (picked != null) {
                          setDialogState(() {
                            startTime = picked;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 8),
                    // End time picker
                    ListTile(
                      title: Text(
                        endTime == null
                            ? 'Select End Time'
                            : 'End Time: ${endTime!.format(context)}',
                      ),
                      trailing: const Icon(Icons.access_time),
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now().replacing(
                            hour: (TimeOfDay.now().hour + 1) % 24,
                          ),
                        );
                        if (picked != null) {
                          setDialogState(() {
                            endTime = picked;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: (selectedRoomId == null ||
                        selectedDayOfWeek == null ||
                        startTime == null ||
                        endTime == null)
                    ? null
                    : () async {
                        try {
                          // Validate end time is after start time
                          final startMinutes = startTime!.hour * 60 + startTime!.minute;
                          final endMinutes = endTime!.hour * 60 + endTime!.minute;
                          
                          if (endMinutes <= startMinutes) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('End time must be after start time'),
                              ),
                            );
                            return;
                          }

                          // Always weekly recurring for entire semester
                          // Get semester start date
                          final semesterStartDate = widget.semester['startDate'];
                          DateTime firstOccurrence;
                          
                          if (semesterStartDate != null) {
                            try {
                              firstOccurrence = DateTime.parse(semesterStartDate);
                            } catch (e) {
                              firstOccurrence = DateTime.now();
                            }
                          } else {
                            firstOccurrence = DateTime.now();
                          }
                          
                          // Find the first occurrence of the selected day
                          final targetDayIndex = weekDays.indexOf(selectedDayOfWeek!);
                          final currentDayIndex = firstOccurrence.weekday - 1;
                          int daysToAdd = (targetDayIndex - currentDayIndex + 7) % 7;
                          if (daysToAdd == 0 && firstOccurrence.weekday - 1 != targetDayIndex) {
                            daysToAdd = 7; // If same day but in future, add a week
                          }
                          final firstDate = firstOccurrence.add(Duration(days: daysToAdd));
                          
                          final startDateTime = DateTime(
                            firstDate.year,
                            firstDate.month,
                            firstDate.day,
                            startTime!.hour,
                            startTime!.minute,
                          );
                          final endDateTime = DateTime(
                            firstDate.year,
                            firstDate.month,
                            firstDate.day,
                            endTime!.hour,
                            endTime!.minute,
                          );
                          
                          final startDatetimeStr =
                              '${startDateTime.year}-${startDateTime.month.toString().padLeft(2, '0')}-${startDateTime.day.toString().padLeft(2, '0')} ${startDateTime.hour.toString().padLeft(2, '0')}:${startDateTime.minute.toString().padLeft(2, '0')}:00';
                          final endDatetimeStr =
                              '${endDateTime.year}-${endDateTime.month.toString().padLeft(2, '0')}-${endDateTime.day.toString().padLeft(2, '0')} ${endDateTime.hour.toString().padLeft(2, '0')}:${endDateTime.minute.toString().padLeft(2, '0')}:00';
                          
                          // Build request data - always recurring weekly
                          final requestData = {
                            'roomId': selectedRoomId!,
                            'assignedByUserId': currentUserId,
                            'assignmentType': 'course',
                            'relatedOfferedCourseId': offeredCourse['offeredCourseId'],
                            'startDatetime': startDatetimeStr,
                            'endDatetime': endDatetimeStr,
                            'isRecurring': true,
                            'recurrencePattern': 'WEEKLY:$selectedDayOfWeek',
                          };
                          
                          // Set recurrence end date to semester end date
                          final semesterEndDate = widget.semester['endDate'];
                          if (semesterEndDate != null) {
                            try {
                              final endDate = DateTime.parse(semesterEndDate);
                              requestData['recurrenceEndDate'] = 
                                  '${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}';
                            } catch (e) {
                              // If parsing fails, calculate end date
                              final endDate = DateTime.now().add(const Duration(days: 90));
                              requestData['recurrenceEndDate'] = 
                                  '${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}';
                            }
                          }

                          final result = await _apiService.adminAssignRoom(requestData);

                          if (result['status'] == 'success') {
                            Navigator.of(context).pop();
                            _loadOfferedCourses(); // Reload to show the room assignment
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Room assigned successfully'),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  result['message'] ?? 'Error assigning room',
                                ),
                              ),
                            );
                          }
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error: $e')),
                          );
                        }
                      },
                child: const Text('Assign'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _closeCourse(Map<String, dynamic> offeredCourse) async {
    if (widget.isReadOnly) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Close Course'),
        content: const Text(
          'Are you sure you want to close this course? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Close Course'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final result = await _apiService.removeOfferedCourse(
        offeredCourse['offeredCourseId'],
      );

      if (result['status'] == 'success') {
        _loadOfferedCourses();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Course closed successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Error closing course'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.semester['name'] ?? 'Semester Details'),
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Semester Information Card
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                widget.semester['name'] ?? 'Unknown Semester',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E3A8A),
                                ),
                              ),
                              if (!widget.isReadOnly)
                                Switch(
                                  value: _registrationOpen,
                                  onChanged: (_) => _toggleRegistration(),
                                  activeColor: Colors.green,
                                ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Start Date: ${_formatDate(widget.semester['startDate'])}',
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'End Date: ${_formatDate(widget.semester['endDate'])}',
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Text(
                                'Registration: ',
                                style: TextStyle(fontSize: 16),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _registrationOpen
                                      ? Colors.green[100]
                                      : Colors.red[100],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  _registrationOpen ? 'Open' : 'Closed',
                                  style: TextStyle(
                                    color: _registrationOpen
                                        ? Colors.green[800]
                                        : Colors.red[800],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Action Button (only for editable)
                  if (!widget.isReadOnly) ...[
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: _openNewCourse,
                          icon: const Icon(Icons.add),
                          label: const Text('Open New Course'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1E3A8A),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                  // Offered Courses Section
                  const Text(
                    'Offered Courses',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E3A8A),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_allOfferedCourses.isEmpty)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Center(
                          child: Text(
                            'No courses offered in this semester',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    )
                  else
                    ..._allOfferedCourses.map((course) {
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${course['title'] ?? 'Unknown'} ${course['courseCode'] ?? ''}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          widget.semester['name'] ?? 'Current Semester',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (!widget.isReadOnly)
                                    PopupMenuButton<String>(
                                      onSelected: (value) {
                                        if (value == 'assign') {
                                          _assignInstructor(course);
                                        } else if (value == 'assignRoom') {
                                          _assignRoom(course);
                                        } else if (value == 'close') {
                                          _closeCourse(course);
                                        }
                                      },
                                      itemBuilder: (context) => [
                                        const PopupMenuItem(
                                          value: 'assign',
                                          child: Row(
                                            children: [
                                              Icon(Icons.person_add,
                                                  size: 20),
                                              SizedBox(width: 8),
                                              Text('Assign Instructor'),
                                            ],
                                          ),
                                        ),
                                        const PopupMenuItem(
                                          value: 'assignRoom',
                                          child: Row(
                                            children: [
                                              Icon(Icons.meeting_room, size: 20),
                                              SizedBox(width: 8),
                                              Text('Assign Room'),
                                            ],
                                          ),
                                        ),
                                        const PopupMenuItem(
                                          value: 'close',
                                          child: Row(
                                            children: [
                                              Icon(Icons.close, size: 20),
                                              SizedBox(width: 8),
                                              Text('Close Course'),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                              if (course['instructor'] != null) ...[
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.person,
                                      size: 16,
                                      color: Colors.blue,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Instructor: ${course['instructor']['name'] ?? 'Unknown'}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.blue[700],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ] else if (!widget.isReadOnly) ...[
                                const SizedBox(height: 8),
                                TextButton.icon(
                                  onPressed: () => _assignInstructor(course),
                                  icon: const Icon(Icons.person_add, size: 16),
                                  label: const Text('Assign Instructor'),
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.blue,
                                  ),
                                ),
                              ] else ...[
                                const SizedBox(height: 8),
                                Text(
                                  'Instructor: Not Assigned',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                              if (course['roomAssignment'] != null) ...[
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.meeting_room,
                                      size: 16,
                                      color: Colors.blue,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Room: ${_formatRoomAssignment(course['roomAssignment'])}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.blue[700],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ] else if (!widget.isReadOnly) ...[
                                const SizedBox(height: 8),
                                TextButton.icon(
                                  onPressed: () => _assignRoom(course),
                                  icon: const Icon(Icons.meeting_room, size: 16),
                                  label: const Text('Assign Room'),
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.blue,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                ],
              ),
            ),
    );
  }
}

