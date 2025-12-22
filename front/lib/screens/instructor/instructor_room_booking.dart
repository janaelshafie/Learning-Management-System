import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/api_services.dart';

class InstructorRoomBookingScreen extends StatefulWidget {
  final int userId;
  final int? offeredCourseId;
  final int? sectionId;
  final String? courseName;
  final String? sectionNumber;
  final bool isEmbedded;

  const InstructorRoomBookingScreen({
    super.key,
    required this.userId,
    this.offeredCourseId,
    this.sectionId,
    this.courseName,
    this.sectionNumber,
    this.isEmbedded = false,
  });

  @override
  State<InstructorRoomBookingScreen> createState() =>
      _InstructorRoomBookingScreenState();
}

class _InstructorRoomBookingScreenState
    extends State<InstructorRoomBookingScreen> {
  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>> _availableRooms = [];
  bool _isLoading = false;
  bool _isSubmitting = false;

  DateTime? _selectedStartDate;
  TimeOfDay? _selectedStartTime;
  DateTime? _selectedEndDate;
  TimeOfDay? _selectedEndTime;
  String? _selectedRoomType;
  int? _selectedRoomId;
  final TextEditingController _purposeController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    print('InstructorRoomBookingScreen: initState called');
    print('InstructorRoomBookingScreen: userId = ${widget.userId}');
    print('InstructorRoomBookingScreen: isEmbedded = ${widget.isEmbedded}');
  }

  @override
  void dispose() {
    print('InstructorRoomBookingScreen: dispose called');
    _purposeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _checkAvailability() async {
    if (_selectedStartDate == null ||
        _selectedStartTime == null ||
        _selectedEndDate == null ||
        _selectedEndTime == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select date and time')),
        );
      }
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final startDateTime = DateTime(
        _selectedStartDate!.year,
        _selectedStartDate!.month,
        _selectedStartDate!.day,
        _selectedStartTime!.hour,
        _selectedStartTime!.minute,
      );

      final endDateTime = DateTime(
        _selectedEndDate!.year,
        _selectedEndDate!.month,
        _selectedEndDate!.day,
        _selectedEndTime!.hour,
        _selectedEndTime!.minute,
      );

      if (endDateTime.isBefore(startDateTime) ||
          endDateTime.isAtSameMomentAs(startDateTime)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('End time must be after start time')),
          );
          setState(() {
            _isLoading = false;
          });
        }
        return;
      }

      final formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
      final startDatetime = formatter.format(startDateTime);
      final endDatetime = formatter.format(endDateTime);

      final response = await _apiService.getAvailableRooms(
        startDatetime,
        endDatetime,
        roomType: _selectedRoomType,
      );

      if (!mounted) return;

      if (response['status'] == 'success') {
        setState(() {
          _availableRooms = List<Map<String, dynamic>>.from(
            response['availableRooms'] ?? [],
          );
          _isLoading = false;
        });

        if (_availableRooms.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No rooms available for selected time slot'),
            ),
          );
        }
      } else {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Error checking availability'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _submitReservation() async {
    if (_selectedRoomId == null) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Please select a room')));
      }
      return;
    }

    if (_purposeController.text.trim().isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Please enter purpose')));
      }
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final startDateTime = DateTime(
        _selectedStartDate!.year,
        _selectedStartDate!.month,
        _selectedStartDate!.day,
        _selectedStartTime!.hour,
        _selectedStartTime!.minute,
      );

      final endDateTime = DateTime(
        _selectedEndDate!.year,
        _selectedEndDate!.month,
        _selectedEndDate!.day,
        _selectedEndTime!.hour,
        _selectedEndTime!.minute,
      );

      final formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
      final startDatetime = formatter.format(startDateTime);
      final endDatetime = formatter.format(endDateTime);

      final reservationData = {
        'roomId': _selectedRoomId,
        'reservedByUserId': widget.userId,
        'assignmentType': 'course',
        'startDatetime': startDatetime,
        'endDatetime': endDatetime,
        'purpose': _purposeController.text.trim(),
        'notes': _notesController.text.trim(),
        if (widget.offeredCourseId != null)
          'relatedOfferedCourseId': widget.offeredCourseId,
        if (widget.sectionId != null) 'relatedSectionId': widget.sectionId,
      };

      final response = await _apiService.createReservation(reservationData);

      if (response['status'] == 'success') {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Room reservation requested successfully. Waiting for admin approval.',
              ),
            ),
          );
          // Only pop if not embedded (i.e., navigated to via Navigator.push)
          if (!widget.isEmbedded) {
            Navigator.pop(context, true);
          } else {
            // Reset the form for embedded mode
            setState(() {
              _selectedRoomId = null;
              _selectedStartDate = null;
              _selectedStartTime = null;
              _selectedEndDate = null;
              _selectedEndTime = null;
              _selectedRoomType = null;
              _availableRooms = [];
              _purposeController.clear();
              _notesController.clear();
            });
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                response['message'] ?? 'Error creating reservation',
              ),
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
          _selectedStartDate = picked;
        } else {
          _selectedEndDate = picked;
        }
      });
    }
  }

  Future<void> _selectTime(BuildContext context, bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart
          ? TimeOfDay.now()
          : TimeOfDay.fromDateTime(
              DateTime.now().add(const Duration(hours: 2)),
            ),
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _selectedStartTime = picked;
        } else {
          _selectedEndTime = picked;
        }
      });
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

  @override
  Widget build(BuildContext context) {
    print('InstructorRoomBookingScreen: build called');
    try {
      final content = SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.courseName != null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Course: ${widget.courseName}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      if (widget.sectionNumber != null)
                        Text('Section: ${widget.sectionNumber}'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            // Date and Time Selection
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Select Date & Time',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Start Date'),
                              const SizedBox(height: 8),
                              OutlinedButton.icon(
                                icon: const Icon(Icons.calendar_today),
                                label: Text(
                                  _selectedStartDate != null
                                      ? DateFormat(
                                          'MMM dd, yyyy',
                                        ).format(_selectedStartDate!)
                                      : 'Select Date',
                                ),
                                onPressed: () => _selectDate(context, true),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Start Time'),
                              const SizedBox(height: 8),
                              OutlinedButton.icon(
                                icon: const Icon(Icons.access_time),
                                label: Text(
                                  _selectedStartTime != null
                                      ? _selectedStartTime!.format(context)
                                      : 'Select Time',
                                ),
                                onPressed: () => _selectTime(context, true),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('End Date'),
                              const SizedBox(height: 8),
                              OutlinedButton.icon(
                                icon: const Icon(Icons.calendar_today),
                                label: Text(
                                  _selectedEndDate != null
                                      ? DateFormat(
                                          'MMM dd, yyyy',
                                        ).format(_selectedEndDate!)
                                      : 'Select Date',
                                ),
                                onPressed: () => _selectDate(context, false),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('End Time'),
                              const SizedBox(height: 8),
                              OutlinedButton.icon(
                                icon: const Icon(Icons.access_time),
                                label: Text(
                                  _selectedEndTime != null
                                      ? _selectedEndTime!.format(context)
                                      : 'Select Time',
                                ),
                                onPressed: () => _selectTime(context, false),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedRoomType,
                      decoration: const InputDecoration(
                        labelText: 'Room Type (Optional)',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: null, child: Text('All Types')),
                        DropdownMenuItem(
                          value: 'classroom',
                          child: Text('Classroom'),
                        ),
                        DropdownMenuItem(
                          value: 'lab',
                          child: Text('Laboratory'),
                        ),
                        DropdownMenuItem(
                          value: 'auditorium',
                          child: Text('Auditorium'),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedRoomType = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.search),
                        label: const Text('Check Availability'),
                        onPressed: _isLoading ? null : _checkAvailability,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Available Rooms
            if (_availableRooms.isNotEmpty) ...[
              const Text(
                'Available Rooms',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ..._availableRooms.map(
                (room) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: RadioListTile<int>(
                    title: Text(
                      '${room['building'] ?? 'N/A'} - ${room['roomName'] ?? 'Unknown'}',
                    ),
                    subtitle: Text(
                      '${_getRoomTypeDisplay(room['roomType'] ?? '')} • Capacity: ${room['capacity'] ?? 0}',
                    ),
                    value: room['roomId'],
                    groupValue: _selectedRoomId,
                    onChanged: (value) {
                      setState(() {
                        _selectedRoomId = value;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            // Purpose and Notes
            if (_selectedRoomId != null) ...[
              TextField(
                controller: _purposeController,
                decoration: const InputDecoration(
                  labelText: 'Purpose *',
                  hintText: 'e.g., CS101 Lecture, Lab Session',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes (Optional)',
                  hintText: 'Special requirements, equipment needed, etc.',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitReservation,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: const Color(0xFF1E3A8A),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Text(
                          'Request Reservation',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                ),
              ),
            ],
          ],
        ),
      );

      // If embedded in parent scaffold, don't wrap in another Scaffold
      if (widget.isEmbedded) {
        print('InstructorRoomBookingScreen: returning embedded content');
        return SafeArea(child: content);
      }

      // When navigated to directly, wrap in Scaffold with AppBar
      print('InstructorRoomBookingScreen: returning Scaffold wrapped content');
      return Scaffold(
        appBar: AppBar(
          title: Text(
            widget.courseName != null
                ? 'Book Room - ${widget.courseName}'
                : 'Book Room',
          ),
        ),
        body: content,
      );
    } catch (e, stackTrace) {
      print('InstructorRoomBookingScreen: ERROR in build: $e');
      print('InstructorRoomBookingScreen: Stack trace: $stackTrace');
      return Center(child: Text('Error: $e'));
    }
  }
}
