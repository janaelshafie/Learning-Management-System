package com.asu_lms.lms.Controllers;

import java.math.BigDecimal;
import java.sql.Timestamp;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.asu_lms.lms.Entities.Course;
import com.asu_lms.lms.Entities.Department;
import com.asu_lms.lms.Entities.Instructor;
import com.asu_lms.lms.Entities.OfferedCourse;
import com.asu_lms.lms.Entities.RoomAttributes;
import com.asu_lms.lms.Entities.RoomAttributeValues;
import com.asu_lms.lms.Entities.RoomMaintenanceIssue;
import com.asu_lms.lms.Entities.RoomReservation;
import com.asu_lms.lms.Entities.Rooms;
import com.asu_lms.lms.Entities.User;
import com.asu_lms.lms.Repositories.CourseRepository;
import com.asu_lms.lms.Repositories.DepartmentRepository;
import com.asu_lms.lms.Repositories.InstructorRepository;
import com.asu_lms.lms.Repositories.OfferedCourseRepository;
import com.asu_lms.lms.Repositories.RoomAttributesRepository;
import com.asu_lms.lms.Repositories.RoomAttributeValuesRepository;
import com.asu_lms.lms.Repositories.RoomMaintenanceIssueRepository;
import com.asu_lms.lms.Repositories.RoomReservationRepository;
import com.asu_lms.lms.Repositories.RoomsRepository;
import com.asu_lms.lms.Repositories.UserRepository;

@RestController
@RequestMapping("/api/rooms")
@CrossOrigin(origins = "*")
public class RoomController {

    private final RoomsRepository roomsRepository;
    private final RoomReservationRepository roomReservationRepository;
    private final RoomMaintenanceIssueRepository roomMaintenanceIssueRepository;
    private final RoomAttributesRepository roomAttributesRepository;
    private final RoomAttributeValuesRepository roomAttributeValuesRepository;
    private final UserRepository userRepository;
    private final DepartmentRepository departmentRepository;
    private final InstructorRepository instructorRepository;
    private final OfferedCourseRepository offeredCourseRepository;
    private final CourseRepository courseRepository;

    public RoomController(
            RoomsRepository roomsRepository,
            RoomReservationRepository roomReservationRepository,
            RoomMaintenanceIssueRepository roomMaintenanceIssueRepository,
            RoomAttributesRepository roomAttributesRepository,
            RoomAttributeValuesRepository roomAttributeValuesRepository,
            UserRepository userRepository,
            DepartmentRepository departmentRepository,
            InstructorRepository instructorRepository,
            OfferedCourseRepository offeredCourseRepository,
            CourseRepository courseRepository
    ) {
        this.roomsRepository = roomsRepository;
        this.roomReservationRepository = roomReservationRepository;
        this.roomMaintenanceIssueRepository = roomMaintenanceIssueRepository;
        this.roomAttributesRepository = roomAttributesRepository;
        this.roomAttributeValuesRepository = roomAttributeValuesRepository;
        this.userRepository = userRepository;
        this.departmentRepository = departmentRepository;
        this.instructorRepository = instructorRepository;
        this.offeredCourseRepository = offeredCourseRepository;
        this.courseRepository = courseRepository;
    }

    // ==================== ROOM MANAGEMENT ====================

    /**
     * Get all rooms with optional filters
     */
    @GetMapping("/list")
    public Map<String, Object> getAllRooms(
            @RequestParam(required = false) String roomType,
            @RequestParam(required = false) String building,
            @RequestParam(required = false) String status
    ) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            List<Rooms> rooms;
            
            if (building != null && roomType != null) {
                rooms = roomsRepository.findByBuildingAndRoomType(building, roomType);
            } else if (roomType != null) {
                rooms = roomsRepository.findByRoomType(roomType);
            } else if (building != null) {
                rooms = roomsRepository.findByBuilding(building);
            } else if (status != null) {
                rooms = roomsRepository.findByStatus(status);
            } else {
                rooms = roomsRepository.findAll();
            }
            
            List<Map<String, Object>> roomList = new ArrayList<>();
            for (Rooms room : rooms) {
                Map<String, Object> roomData = new HashMap<>();
                roomData.put("roomId", room.getRoomId());
                roomData.put("building", room.getBuilding());
                roomData.put("roomName", room.getRoomName());
                roomData.put("roomType", room.getRoomType());
                roomData.put("capacity", room.getCapacity());
                roomData.put("description", room.getDescription());
                roomData.put("status", room.getStatus());
                roomData.put("statusNotes", room.getStatusNotes());
                
                // Include EAV attributes
                Map<String, Object> attributes = getRoomAttributesMap(room.getRoomId());
                roomData.put("attributes", attributes);
                
                roomList.add(roomData);
            }
            
            response.put("status", "success");
            response.put("rooms", roomList);
            response.put("count", roomList.size());
            
        } catch (Exception e) {
            response.put("status", "error");
            response.put("message", "Error fetching rooms: " + e.getMessage());
        }
        
        return response;
    }

    /**
     * Get all offered courses (for room assignment dropdown)
     */
    @GetMapping("/offered-courses")
    public Map<String, Object> getAllOfferedCourses() {
        Map<String, Object> response = new HashMap<>();
        
        try {
            List<OfferedCourse> offeredCourses = offeredCourseRepository.findAll();
            List<Map<String, Object>> courseList = new ArrayList<>();
            
            for (OfferedCourse oc : offeredCourses) {
                Map<String, Object> courseData = new HashMap<>();
                courseData.put("offeredCourseId", oc.getOfferedCourseId());
                
                // Get course details
                Optional<Course> courseOpt = courseRepository.findById(oc.getCourseId());
                if (courseOpt.isPresent()) {
                    Course course = courseOpt.get();
                    courseData.put("courseId", course.getCourseId());
                    courseData.put("courseName", course.getTitle());
                    courseData.put("courseCode", course.getCourseCode());
                }
                
                courseList.add(courseData);
            }
            
            response.put("status", "success");
            response.put("offeredCourses", courseList);
            
        } catch (Exception e) {
            response.put("status", "error");
            response.put("message", "Error fetching offered courses: " + e.getMessage());
        }
        
        return response;
    }

    /**
     * Get room details by ID
     */
    @GetMapping("/{roomId}")
    public Map<String, Object> getRoomById(@PathVariable Integer roomId) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            Optional<Rooms> roomOpt = roomsRepository.findById(roomId);
            if (roomOpt.isEmpty()) {
                response.put("status", "error");
                response.put("message", "Room not found");
                return response;
            }
            
            Rooms room = roomOpt.get();
            Map<String, Object> roomData = new HashMap<>();
            roomData.put("roomId", room.getRoomId());
            roomData.put("building", room.getBuilding());
            roomData.put("roomName", room.getRoomName());
            roomData.put("roomType", room.getRoomType());
            roomData.put("capacity", room.getCapacity());
            roomData.put("description", room.getDescription());
            roomData.put("status", room.getStatus());
            roomData.put("statusNotes", room.getStatusNotes());
            
            // Include EAV attributes
            Map<String, Object> attributes = getRoomAttributesMap(room.getRoomId());
            roomData.put("attributes", attributes);
            
            response.put("status", "success");
            response.put("room", roomData);
            
        } catch (Exception e) {
            response.put("status", "error");
            response.put("message", "Error fetching room: " + e.getMessage());
        }
        
        return response;
    }

    /**
     * Create a new room
     */
    @PostMapping
    public Map<String, Object> createRoom(@RequestBody Map<String, Object> request) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            String building = request.containsKey("building") ? request.get("building").toString() : null;
            String roomName = request.get("roomName").toString();
            String roomType = request.get("roomType").toString();
            Integer capacity = request.containsKey("capacity") ? Integer.parseInt(request.get("capacity").toString()) : 0;
            String description = request.containsKey("description") ? request.get("description").toString() : null;
            
            Rooms room = new Rooms(building, roomName, roomType, capacity, description);
            room.setStatus("available");
            roomsRepository.save(room);
            
            response.put("status", "success");
            response.put("message", "Room created successfully");
            response.put("roomId", room.getRoomId());
            
        } catch (Exception e) {
            response.put("status", "error");
            response.put("message", "Error creating room: " + e.getMessage());
        }
        
        return response;
    }

    /**
     * Delete a room
     */
    @DeleteMapping("/{roomId}")
    public Map<String, Object> deleteRoom(@PathVariable Integer roomId) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            Optional<Rooms> roomOpt = roomsRepository.findById(roomId);
            if (roomOpt.isEmpty()) {
                response.put("status", "error");
                response.put("message", "Room not found");
                return response;
            }
            
            // Check if room has active reservations
            List<RoomReservation> activeReservations = roomReservationRepository.findByRoomId(roomId);
            activeReservations = activeReservations.stream()
                .filter(r -> "pending".equals(r.getStatus()) || "approved".equals(r.getStatus()))
                .collect(java.util.stream.Collectors.toList());
            
            if (!activeReservations.isEmpty()) {
                response.put("status", "error");
                response.put("message", "Cannot delete room with active reservations");
                return response;
            }
            
            roomsRepository.deleteById(roomId);
            
            response.put("status", "success");
            response.put("message", "Room deleted successfully");
            
        } catch (Exception e) {
            response.put("status", "error");
            response.put("message", "Error deleting room: " + e.getMessage());
        }
        
        return response;
    }

    /**
     * Update room status
     */
    @PutMapping("/{roomId}/status")
    public Map<String, Object> updateRoomStatus(
            @PathVariable Integer roomId,
            @RequestBody Map<String, Object> request
    ) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            Optional<Rooms> roomOpt = roomsRepository.findById(roomId);
            if (roomOpt.isEmpty()) {
                response.put("status", "error");
                response.put("message", "Room not found");
                return response;
            }
            
            Rooms room = roomOpt.get();
            String status = request.get("status").toString();
            String statusNotes = request.containsKey("statusNotes") ? request.get("statusNotes").toString() : null;
            Integer updatedByUserId = request.containsKey("updatedByUserId") ? 
                Integer.parseInt(request.get("updatedByUserId").toString()) : null;
            
            room.setStatus(status);
            room.setStatusNotes(statusNotes);
            room.setStatusUpdatedAt(new Timestamp(System.currentTimeMillis()));
            room.setStatusUpdatedByUserId(updatedByUserId);
            
            roomsRepository.save(room);
            
            response.put("status", "success");
            response.put("message", "Room status updated successfully");
            
        } catch (Exception e) {
            response.put("status", "error");
            response.put("message", "Error updating room status: " + e.getMessage());
        }
        
        return response;
    }

    /**
     * Update room (full update including all fields)
     */
    @PutMapping("/{roomId}")
    public Map<String, Object> updateRoom(
            @PathVariable Integer roomId,
            @RequestBody Map<String, Object> request
    ) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            Optional<Rooms> roomOpt = roomsRepository.findById(roomId);
            if (roomOpt.isEmpty()) {
                response.put("status", "error");
                response.put("message", "Room not found");
                return response;
            }
            
            Rooms room = roomOpt.get();
            
            // Update basic info if provided
            if (request.containsKey("building")) {
                room.setBuilding(request.get("building").toString());
            }
            if (request.containsKey("roomName")) {
                room.setRoomName(request.get("roomName").toString());
            }
            if (request.containsKey("roomType")) {
                room.setRoomType(request.get("roomType").toString());
            }
            if (request.containsKey("capacity")) {
                room.setCapacity(Integer.parseInt(request.get("capacity").toString()));
            }
            if (request.containsKey("description")) {
                room.setDescription(request.get("description").toString());
            }
            
            // Update status if provided
            if (request.containsKey("status")) {
                room.setStatus(request.get("status").toString());
                room.setStatusUpdatedAt(new Timestamp(System.currentTimeMillis()));
                if (request.containsKey("updatedByUserId")) {
                    room.setStatusUpdatedByUserId(Integer.parseInt(request.get("updatedByUserId").toString()));
                }
            }
            if (request.containsKey("statusNotes")) {
                room.setStatusNotes(request.get("statusNotes").toString());
            }
            
            roomsRepository.save(room);
            
            response.put("status", "success");
            response.put("message", "Room updated successfully");
            
        } catch (Exception e) {
            response.put("status", "error");
            response.put("message", "Error updating room: " + e.getMessage());
        }
        
        return response;
    }

    // ==================== ROOM RESERVATIONS ====================

    /**
     * Get available rooms for a time slot
     */
    @GetMapping("/available")
    public Map<String, Object> getAvailableRooms(
            @RequestParam String startDatetime,
            @RequestParam String endDatetime,
            @RequestParam(required = false) String roomType,
            @RequestParam(required = false) Integer minCapacity
    ) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");
            Timestamp startTime = Timestamp.valueOf(LocalDateTime.parse(startDatetime, formatter));
            Timestamp endTime = Timestamp.valueOf(LocalDateTime.parse(endDatetime, formatter));
            
            List<Rooms> allRooms;
            if (roomType != null) {
                allRooms = roomsRepository.findByRoomType(roomType);
            } else {
                allRooms = roomsRepository.findAll();
            }
            
            List<Map<String, Object>> availableRooms = new ArrayList<>();
            
            for (Rooms room : allRooms) {
                // Check if room is available (status)
                if (!"available".equals(room.getStatus()) && !"reserved".equals(room.getStatus())) {
                    continue;
                }
                
                // Check capacity
                if (minCapacity != null && (room.getCapacity() == null || room.getCapacity() < minCapacity)) {
                    continue;
                }
                
                // Check for conflicting reservations
                List<RoomReservation> conflicts = roomReservationRepository.findConflictingReservations(
                    room.getRoomId(), startTime, endTime
                );
                
                if (conflicts.isEmpty()) {
                    Map<String, Object> roomData = new HashMap<>();
                    roomData.put("roomId", room.getRoomId());
                    roomData.put("building", room.getBuilding());
                    roomData.put("roomName", room.getRoomName());
                    roomData.put("roomType", room.getRoomType());
                    roomData.put("capacity", room.getCapacity());
                    availableRooms.add(roomData);
                }
            }
            
            response.put("status", "success");
            response.put("availableRooms", availableRooms);
            response.put("count", availableRooms.size());
            
        } catch (Exception e) {
            response.put("status", "error");
            response.put("message", "Error fetching available rooms: " + e.getMessage());
        }
        
        return response;
    }

    /**
     * Create a room reservation
     */
    @PostMapping("/reservations")
    public Map<String, Object> createReservation(@RequestBody Map<String, Object> request) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            Integer roomId = Integer.parseInt(request.get("roomId").toString());
            Integer reservedByUserId = Integer.parseInt(request.get("reservedByUserId").toString());
            String assignmentType = request.containsKey("assignmentType") 
                ? request.get("assignmentType").toString() 
                : request.get("reservationType").toString(); // backward compatibility
            String startDatetime = request.get("startDatetime").toString();
            String endDatetime = request.get("endDatetime").toString();
            
            DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");
            Timestamp startTime = Timestamp.valueOf(LocalDateTime.parse(startDatetime, formatter));
            Timestamp endTime = Timestamp.valueOf(LocalDateTime.parse(endDatetime, formatter));
            
            // Validate time
            if (endTime.before(startTime) || endTime.equals(startTime)) {
                response.put("status", "error");
                response.put("message", "End time must be after start time");
                return response;
            }
            
            // Check for conflicts
            List<RoomReservation> conflicts = roomReservationRepository.findConflictingReservations(
                roomId, startTime, endTime
            );
            
            if (!conflicts.isEmpty()) {
                response.put("status", "error");
                response.put("message", "Room is already reserved for this time slot");
                response.put("conflicts", conflicts.size());
                return response;
            }
            
            RoomReservation reservation = new RoomReservation(roomId, reservedByUserId, assignmentType, startTime, endTime);
            
            // Optional fields
            if (request.containsKey("purpose")) {
                reservation.setPurpose(request.get("purpose").toString());
            }
            if (request.containsKey("relatedOfferedCourseId")) {
                reservation.setRelatedOfferedCourseId(Integer.parseInt(request.get("relatedOfferedCourseId").toString()));
            }
            if (request.containsKey("relatedSectionId")) {
                reservation.setRelatedSectionId(Integer.parseInt(request.get("relatedSectionId").toString()));
            }
            if (request.containsKey("notes")) {
                reservation.setNotes(request.get("notes").toString());
            }
            if (request.containsKey("isRecurring")) {
                reservation.setIsRecurring(Boolean.parseBoolean(request.get("isRecurring").toString()));
            }
            if (request.containsKey("recurrencePattern")) {
                reservation.setRecurrencePattern(request.get("recurrencePattern").toString());
            }
            
            roomReservationRepository.save(reservation);
            
            response.put("status", "success");
            response.put("message", "Reservation created successfully");
            response.put("reservationId", reservation.getReservationId());
            
        } catch (Exception e) {
            response.put("status", "error");
            response.put("message", "Error creating reservation: " + e.getMessage());
        }
        
        return response;
    }

    /**
     * Admin: Assign room to course/instructor/department
     */
    @PostMapping("/admin/assign")
    public Map<String, Object> adminAssignRoom(@RequestBody Map<String, Object> request) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            Integer roomId = Integer.parseInt(request.get("roomId").toString());
            Integer assignedByUserId = Integer.parseInt(request.get("assignedByUserId").toString());
            String assignmentType = request.get("assignmentType").toString(); // course, instructor, department, event
            String startDatetime = request.get("startDatetime").toString();
            String endDatetime = request.get("endDatetime").toString();
            
            // Validate room exists
            Optional<Rooms> roomOpt = roomsRepository.findById(roomId);
            if (roomOpt.isEmpty()) {
                response.put("status", "error");
                response.put("message", "Room not found");
                return response;
            }
            
            DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");
            Timestamp startTime = Timestamp.valueOf(LocalDateTime.parse(startDatetime, formatter));
            Timestamp endTime = Timestamp.valueOf(LocalDateTime.parse(endDatetime, formatter));
            
            // Validate time
            if (endTime.before(startTime) || endTime.equals(startTime)) {
                response.put("status", "error");
                response.put("message", "End time must be after start time");
                return response;
            }
            
            // Check for conflicts
            List<RoomReservation> conflicts = roomReservationRepository.findConflictingReservations(
                roomId, startTime, endTime
            );
            
            if (!conflicts.isEmpty()) {
                response.put("status", "error");
                response.put("message", "Room is already reserved for this time slot");
                response.put("conflicts", conflicts.size());
                return response;
            }
            
            // Create reservation - auto-approved since admin is assigning
            // Valid assignment types: 'course', 'instructor', 'department', 'event', 'exam', 'maintenance'
            RoomReservation reservation = new RoomReservation(roomId, assignedByUserId, assignmentType, startTime, endTime);
            reservation.setStatus("approved");
            reservation.setApprovedByUserId(assignedByUserId);
            reservation.setApprovedAt(new Timestamp(System.currentTimeMillis()));
            
            // Set related entities based on assignment type
            if (request.containsKey("relatedOfferedCourseId")) {
                Integer offeredCourseId = Integer.parseInt(request.get("relatedOfferedCourseId").toString());
                reservation.setRelatedOfferedCourseId(offeredCourseId);
                
                // Get course name for purpose
                Optional<OfferedCourse> ocOpt = offeredCourseRepository.findByOfferedCourseId(offeredCourseId);
                if (ocOpt.isPresent()) {
                    Optional<Course> courseOpt = courseRepository.findById(ocOpt.get().getCourseId());
                    if (courseOpt.isPresent()) {
                        reservation.setPurpose("Course: " + courseOpt.get().getTitle());
                    }
                }
            }
            
            if (request.containsKey("relatedInstructorId")) {
                Integer instructorId = Integer.parseInt(request.get("relatedInstructorId").toString());
                reservation.setRelatedInstructorId(instructorId);
                
                // Get instructor name for purpose
                Optional<Instructor> instOpt = instructorRepository.findByInstructorId(instructorId);
                if (instOpt.isPresent()) {
                    Optional<User> userOpt = userRepository.findById(instOpt.get().getInstructorId());
                    if (userOpt.isPresent()) {
                        String purpose = reservation.getPurpose() != null ? reservation.getPurpose() + " - " : "";
                        reservation.setPurpose(purpose + "Instructor: " + userOpt.get().getName());
                    }
                }
            }
            
            if (request.containsKey("relatedDepartmentId")) {
                Integer departmentId = Integer.parseInt(request.get("relatedDepartmentId").toString());
                reservation.setRelatedDepartmentId(departmentId);
                
                // Get department name for purpose
                Optional<Department> deptOpt = departmentRepository.findById(departmentId);
                if (deptOpt.isPresent()) {
                    String purpose = reservation.getPurpose() != null ? reservation.getPurpose() + " - " : "";
                    reservation.setPurpose(purpose + "Department: " + deptOpt.get().getName());
                }
            }
            
            if (request.containsKey("relatedSectionId")) {
                reservation.setRelatedSectionId(Integer.parseInt(request.get("relatedSectionId").toString()));
            }
            
            if (request.containsKey("purpose")) {
                reservation.setPurpose(request.get("purpose").toString());
            }
            
            if (request.containsKey("notes")) {
                reservation.setNotes(request.get("notes").toString());
            }
            
            // Handle recurring assignments
            if (request.containsKey("isRecurring") && Boolean.parseBoolean(request.get("isRecurring").toString())) {
                reservation.setIsRecurring(true);
                if (request.containsKey("recurrencePattern")) {
                    reservation.setRecurrencePattern(request.get("recurrencePattern").toString());
                }
                if (request.containsKey("recurrenceEndDate")) {
                    reservation.setRecurrenceEndDate(java.sql.Date.valueOf(request.get("recurrenceEndDate").toString()));
                }
            }
            
            roomReservationRepository.save(reservation);
            
            response.put("status", "success");
            response.put("message", "Room assigned successfully");
            response.put("reservationId", reservation.getReservationId());
            
        } catch (Exception e) {
            response.put("status", "error");
            response.put("message", "Error assigning room: " + e.getMessage());
        }
        
        return response;
    }

    /**
     * Get all room assignments (for instructors to view schedule)
     */
    @GetMapping("/assignments")
    public Map<String, Object> getAllRoomAssignments(
            @RequestParam(required = false) String startDate,
            @RequestParam(required = false) String endDate,
            @RequestParam(required = false) Integer roomId,
            @RequestParam(required = false) Integer departmentId,
            @RequestParam(required = false) Integer instructorId
    ) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            List<RoomReservation> reservations;
            
            if (startDate != null && endDate != null) {
                DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd");
                Timestamp start = Timestamp.valueOf(LocalDate.parse(startDate, formatter).atStartOfDay());
                Timestamp end = Timestamp.valueOf(LocalDate.parse(endDate, formatter).atTime(23, 59, 59));
                reservations = roomReservationRepository.findApprovedReservationsByDateRange(start, end);
            } else {
                reservations = roomReservationRepository.findAllActiveReservations();
            }
            
            // Apply additional filters
            if (roomId != null) {
                reservations = reservations.stream()
                    .filter(r -> roomId.equals(r.getRoomId()))
                    .collect(java.util.stream.Collectors.toList());
            }
            if (departmentId != null) {
                reservations = reservations.stream()
                    .filter(r -> departmentId.equals(r.getRelatedDepartmentId()))
                    .collect(java.util.stream.Collectors.toList());
            }
            if (instructorId != null) {
                reservations = reservations.stream()
                    .filter(r -> instructorId.equals(r.getRelatedInstructorId()) || instructorId.equals(r.getReservedByUserId()))
                    .collect(java.util.stream.Collectors.toList());
            }
            
            List<Map<String, Object>> assignmentList = new ArrayList<>();
            for (RoomReservation res : reservations) {
                Map<String, Object> resData = buildReservationData(res);
                
                // Add room details
                Optional<Rooms> roomOpt = roomsRepository.findById(res.getRoomId());
                if (roomOpt.isPresent()) {
                    Rooms room = roomOpt.get();
                    resData.put("roomName", room.getRoomName());
                    resData.put("building", room.getBuilding());
                    resData.put("roomType", room.getRoomType());
                    resData.put("capacity", room.getCapacity());
                }
                
                // Add course details if available
                if (res.getRelatedOfferedCourseId() != null) {
                    Optional<OfferedCourse> ocOpt = offeredCourseRepository.findByOfferedCourseId(res.getRelatedOfferedCourseId());
                    if (ocOpt.isPresent()) {
                        Optional<Course> courseOpt = courseRepository.findById(ocOpt.get().getCourseId());
                        if (courseOpt.isPresent()) {
                            resData.put("courseName", courseOpt.get().getTitle());
                            resData.put("courseCode", courseOpt.get().getCourseCode());
                        }
                    }
                }
                
                // Add instructor details if available
                if (res.getRelatedInstructorId() != null) {
                    Optional<Instructor> instOpt = instructorRepository.findByInstructorId(res.getRelatedInstructorId());
                    if (instOpt.isPresent()) {
                        Optional<User> userOpt = userRepository.findById(instOpt.get().getInstructorId());
                        if (userOpt.isPresent()) {
                            resData.put("instructorName", userOpt.get().getName());
                        }
                    }
                }
                
                // Add department details if available
                if (res.getRelatedDepartmentId() != null) {
                    Optional<Department> deptOpt = departmentRepository.findById(res.getRelatedDepartmentId());
                    if (deptOpt.isPresent()) {
                        resData.put("departmentName", deptOpt.get().getName());
                    }
                }
                
                assignmentList.add(resData);
            }
            
            response.put("status", "success");
            response.put("assignments", assignmentList);
            response.put("count", assignmentList.size());
            
        } catch (Exception e) {
            response.put("status", "error");
            response.put("message", "Error fetching room assignments: " + e.getMessage());
        }
        
        return response;
    }

    /**
     * Get reservations for a room
     */
    @GetMapping("/{roomId}/reservations")
    public Map<String, Object> getRoomReservations(
            @PathVariable Integer roomId,
            @RequestParam(required = false) String startDate,
            @RequestParam(required = false) String endDate
    ) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            List<RoomReservation> reservations;
            
            if (startDate != null && endDate != null) {
                DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd");
                Timestamp start = Timestamp.valueOf(LocalDate.parse(startDate, formatter).atStartOfDay());
                Timestamp end = Timestamp.valueOf(LocalDate.parse(endDate, formatter).atTime(23, 59, 59));
                reservations = roomReservationRepository.findByRoomIdAndDateRange(roomId, start, end);
            } else {
                reservations = roomReservationRepository.findByRoomId(roomId);
            }
            
            List<Map<String, Object>> reservationList = new ArrayList<>();
            for (RoomReservation res : reservations) {
                Map<String, Object> resData = buildReservationData(res);
                reservationList.add(resData);
            }
            
            response.put("status", "success");
            response.put("reservations", reservationList);
            
        } catch (Exception e) {
            response.put("status", "error");
            response.put("message", "Error fetching reservations: " + e.getMessage());
        }
        
        return response;
    }

    /**
     * Get user's reservations
     */
    @GetMapping("/reservations/user/{userId}")
    public Map<String, Object> getUserReservations(@PathVariable Integer userId) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            List<RoomReservation> reservations = roomReservationRepository.findByReservedByUserId(userId);
            List<Map<String, Object>> reservationList = new ArrayList<>();
            
            for (RoomReservation res : reservations) {
                Map<String, Object> resData = buildReservationData(res);
                reservationList.add(resData);
            }
            
            response.put("status", "success");
            response.put("reservations", reservationList);
            
        } catch (Exception e) {
            response.put("status", "error");
            response.put("message", "Error fetching reservations: " + e.getMessage());
        }
        
        return response;
    }

    /**
     * Get pending reservations (for admin approval)
     */
    @GetMapping("/reservations/pending")
    public Map<String, Object> getPendingReservations() {
        Map<String, Object> response = new HashMap<>();
        
        try {
            List<RoomReservation> reservations = roomReservationRepository.findByStatus("pending");
            List<Map<String, Object>> reservationList = new ArrayList<>();
            
            // Group by room and time to find conflicts
            Map<String, List<RoomReservation>> conflictsByRoomAndTime = new HashMap<>();
            
            for (RoomReservation res : reservations) {
                Map<String, Object> resData = buildReservationData(res);
                
                // Check for conflicts with other pending reservations
                String conflictKey = res.getRoomId() + "_" + res.getStartDatetime().toString() + "_" + res.getEndDatetime().toString();
                if (!conflictsByRoomAndTime.containsKey(conflictKey)) {
                    conflictsByRoomAndTime.put(conflictKey, new ArrayList<>());
                }
                conflictsByRoomAndTime.get(conflictKey).add(res);
                
                // Get room details
                Optional<Rooms> roomOpt = roomsRepository.findById(res.getRoomId());
                if (roomOpt.isPresent()) {
                    Rooms room = roomOpt.get();
                    resData.put("roomName", room.getRoomName());
                    resData.put("building", room.getBuilding());
                    resData.put("roomType", room.getRoomType());
                }
                
                reservationList.add(resData);
            }
            
            // Mark conflicts
            for (Map<String, Object> resData : reservationList) {
                Integer roomId = (Integer) resData.get("roomId");
                String startTime = resData.get("startDatetime").toString();
                String endTime = resData.get("endDatetime").toString();
                String conflictKey = roomId + "_" + startTime + "_" + endTime;
                
                List<RoomReservation> conflicts = conflictsByRoomAndTime.get(conflictKey);
                if (conflicts != null && conflicts.size() > 1) {
                    resData.put("hasConflict", true);
                    resData.put("conflictCount", conflicts.size());
                } else {
                    resData.put("hasConflict", false);
                }
            }
            
            response.put("status", "success");
            response.put("reservations", reservationList);
            response.put("count", reservationList.size());
            
        } catch (Exception e) {
            response.put("status", "error");
            response.put("message", "Error fetching pending reservations: " + e.getMessage());
        }
        
        return response;
    }

    /**
     * Update reservation status (approve/reject/cancel)
     */
    @PutMapping("/reservations/{reservationId}/status")
    public Map<String, Object> updateReservationStatus(
            @PathVariable Integer reservationId,
            @RequestBody Map<String, Object> request
    ) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            Optional<RoomReservation> resOpt = roomReservationRepository.findById(reservationId);
            if (resOpt.isEmpty()) {
                response.put("status", "error");
                response.put("message", "Reservation not found");
                return response;
            }
            
            RoomReservation reservation = resOpt.get();
            String status = request.get("status").toString();
            Integer approvedByUserId = request.containsKey("approvedByUserId") ? 
                Integer.parseInt(request.get("approvedByUserId").toString()) : null;
            
            reservation.setStatus(status);
            if ("approved".equals(status) && approvedByUserId != null) {
                reservation.setApprovedByUserId(approvedByUserId);
                reservation.setApprovedAt(new Timestamp(System.currentTimeMillis()));
            }
            
            roomReservationRepository.save(reservation);
            
            response.put("status", "success");
            response.put("message", "Reservation status updated successfully");
            
        } catch (Exception e) {
            response.put("status", "error");
            response.put("message", "Error updating reservation: " + e.getMessage());
        }
        
        return response;
    }

    // ==================== MAINTENANCE ISSUES ====================

    /**
     * Report a maintenance issue
     */
    @PostMapping("/maintenance/issues")
    public Map<String, Object> reportMaintenanceIssue(@RequestBody Map<String, Object> request) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            Integer roomId = Integer.parseInt(request.get("roomId").toString());
            Integer reportedByUserId = Integer.parseInt(request.get("reportedByUserId").toString());
            String issueType = request.get("issueType").toString();
            String title = request.get("title").toString();
            String description = request.get("description").toString();
            
            RoomMaintenanceIssue issue = new RoomMaintenanceIssue(roomId, reportedByUserId, issueType, title, description);
            
            if (request.containsKey("priority")) {
                issue.setPriority(request.get("priority").toString());
            }
            if (request.containsKey("attachmentsJson")) {
                issue.setAttachmentsJson(request.get("attachmentsJson").toString());
            }
            
            roomMaintenanceIssueRepository.save(issue);
            
            // Update room status if needed
            Optional<Rooms> roomOpt = roomsRepository.findById(roomId);
            if (roomOpt.isPresent()) {
                Rooms room = roomOpt.get();
                if ("urgent".equals(issue.getPriority()) || "high".equals(issue.getPriority())) {
                    room.setStatus("maintenance");
                    room.setStatusNotes("Maintenance issue reported: " + title);
                    room.setStatusUpdatedAt(new Timestamp(System.currentTimeMillis()));
                    roomsRepository.save(room);
                }
            }
            
            response.put("status", "success");
            response.put("message", "Maintenance issue reported successfully");
            response.put("issueId", issue.getIssueId());
            
        } catch (Exception e) {
            response.put("status", "error");
            response.put("message", "Error reporting issue: " + e.getMessage());
        }
        
        return response;
    }

    /**
     * Get maintenance issues
     */
    @GetMapping("/maintenance/issues")
    public Map<String, Object> getMaintenanceIssues(
            @RequestParam(required = false) Integer roomId,
            @RequestParam(required = false) String status,
            @RequestParam(required = false) String priority
    ) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            List<RoomMaintenanceIssue> issues;
            
            if (roomId != null && status != null) {
                issues = roomMaintenanceIssueRepository.findByRoomIdAndStatus(roomId, status);
            } else if (roomId != null) {
                issues = roomMaintenanceIssueRepository.findByRoomId(roomId);
            } else if (status != null) {
                issues = roomMaintenanceIssueRepository.findByStatus(status);
            } else if (priority != null) {
                issues = roomMaintenanceIssueRepository.findByPriority(priority);
            } else {
                issues = roomMaintenanceIssueRepository.findAll();
            }
            
            List<Map<String, Object>> issueList = new ArrayList<>();
            for (RoomMaintenanceIssue issue : issues) {
                Map<String, Object> issueData = buildMaintenanceIssueData(issue);
                issueList.add(issueData);
            }
            
            response.put("status", "success");
            response.put("issues", issueList);
            response.put("count", issueList.size());
            
        } catch (Exception e) {
            response.put("status", "error");
            response.put("message", "Error fetching maintenance issues: " + e.getMessage());
        }
        
        return response;
    }

    /**
     * Update maintenance issue status
     */
    @PutMapping("/maintenance/issues/{issueId}")
    public Map<String, Object> updateMaintenanceIssue(
            @PathVariable Integer issueId,
            @RequestBody Map<String, Object> request
    ) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            Optional<RoomMaintenanceIssue> issueOpt = roomMaintenanceIssueRepository.findById(issueId);
            if (issueOpt.isEmpty()) {
                response.put("status", "error");
                response.put("message", "Issue not found");
                return response;
            }
            
            RoomMaintenanceIssue issue = issueOpt.get();
            
            if (request.containsKey("status")) {
                String status = request.get("status").toString();
                issue.setStatus(status);
                
                if ("assigned".equals(status) && request.containsKey("assignedToUserId")) {
                    issue.setAssignedToUserId(Integer.parseInt(request.get("assignedToUserId").toString()));
                    issue.setAssignedAt(new Timestamp(System.currentTimeMillis()));
                }
                
                if ("resolved".equals(status) || "closed".equals(status)) {
                    issue.setResolvedAt(new Timestamp(System.currentTimeMillis()));
                    if (request.containsKey("resolvedByUserId")) {
                        issue.setResolvedByUserId(Integer.parseInt(request.get("resolvedByUserId").toString()));
                    }
                }
            }
            
            if (request.containsKey("priority")) {
                issue.setPriority(request.get("priority").toString());
            }
            if (request.containsKey("resolutionNotes")) {
                issue.setResolutionNotes(request.get("resolutionNotes").toString());
            }
            if (request.containsKey("estimatedCost")) {
                issue.setEstimatedCost(new BigDecimal(request.get("estimatedCost").toString()));
            }
            if (request.containsKey("actualCost")) {
                issue.setActualCost(new BigDecimal(request.get("actualCost").toString()));
            }
            
            roomMaintenanceIssueRepository.save(issue);
            
            response.put("status", "success");
            response.put("message", "Maintenance issue updated successfully");
            
        } catch (Exception e) {
            response.put("status", "error");
            response.put("message", "Error updating issue: " + e.getMessage());
        }
        
        return response;
    }

    // ==================== HELPER METHODS ====================

    private Map<String, Object> buildReservationData(RoomReservation res) {
        Map<String, Object> resData = new HashMap<>();
        resData.put("reservationId", res.getReservationId());
        resData.put("roomId", res.getRoomId());
        resData.put("reservedByUserId", res.getReservedByUserId());
        resData.put("assignmentType", res.getAssignmentType());
        resData.put("reservationType", res.getAssignmentType()); // backward compatibility
        resData.put("startDatetime", res.getStartDatetime().toString());
        resData.put("endDatetime", res.getEndDatetime().toString());
        resData.put("status", res.getStatus());
        resData.put("purpose", res.getPurpose());
        resData.put("requestedAt", res.getRequestedAt().toString());
        resData.put("approvedByUserId", res.getApprovedByUserId());
        resData.put("approvedAt", res.getApprovedAt() != null ? res.getApprovedAt().toString() : null);
        resData.put("notes", res.getNotes());
        resData.put("isRecurring", res.getIsRecurring());
        resData.put("recurrencePattern", res.getRecurrencePattern());
        resData.put("assignmentType", res.getAssignmentType());
        resData.put("relatedDepartmentId", res.getRelatedDepartmentId());
        resData.put("relatedInstructorId", res.getRelatedInstructorId());
        resData.put("relatedOfferedCourseId", res.getRelatedOfferedCourseId());
        resData.put("relatedSectionId", res.getRelatedSectionId());
        
        // Get user name
        Optional<User> userOpt = userRepository.findById(res.getReservedByUserId());
        if (userOpt.isPresent()) {
            resData.put("reservedByName", userOpt.get().getName());
        }
        
        return resData;
    }

    private Map<String, Object> buildMaintenanceIssueData(RoomMaintenanceIssue issue) {
        Map<String, Object> issueData = new HashMap<>();
        issueData.put("issueId", issue.getIssueId());
        issueData.put("roomId", issue.getRoomId());
        issueData.put("reportedByUserId", issue.getReportedByUserId());
        issueData.put("issueType", issue.getIssueType());
        issueData.put("priority", issue.getPriority());
        issueData.put("title", issue.getTitle());
        issueData.put("description", issue.getDescription());
        issueData.put("status", issue.getStatus());
        issueData.put("reportedAt", issue.getReportedAt().toString());
        issueData.put("assignedToUserId", issue.getAssignedToUserId());
        issueData.put("assignedAt", issue.getAssignedAt() != null ? issue.getAssignedAt().toString() : null);
        issueData.put("resolvedAt", issue.getResolvedAt() != null ? issue.getResolvedAt().toString() : null);
        issueData.put("resolvedByUserId", issue.getResolvedByUserId());
        issueData.put("resolutionNotes", issue.getResolutionNotes());
        issueData.put("estimatedCost", issue.getEstimatedCost());
        issueData.put("actualCost", issue.getActualCost());
        
        // Get user names
        Optional<User> reporterOpt = userRepository.findById(issue.getReportedByUserId());
        if (reporterOpt.isPresent()) {
            issueData.put("reportedByName", reporterOpt.get().getName());
        }
        
        if (issue.getAssignedToUserId() != null) {
            Optional<User> assigneeOpt = userRepository.findById(issue.getAssignedToUserId());
            if (assigneeOpt.isPresent()) {
                issueData.put("assignedToName", assigneeOpt.get().getName());
            }
        }
        
        return issueData;
    }

    // ==================== EAV HELPER METHODS ====================

    /**
     * Helper method to get room attributes as a map
     */
    private Map<String, Object> getRoomAttributesMap(Integer roomId) {
        Map<String, Object> attributes = new HashMap<>();
        List<RoomAttributeValues> attrValues = roomAttributeValuesRepository.findByRoom_RoomId(roomId);
        
        for (RoomAttributeValues rav : attrValues) {
            String attrName = rav.getAttribute().getAttributeName();
            String valueType = rav.getAttribute().getValueType();
            String value = rav.getValue();
            
            // Convert value based on type
            Object typedValue = convertAttributeValue(value, valueType);
            attributes.put(attrName, typedValue);
        }
        
        return attributes;
    }
    
    /**
     * Convert attribute value to appropriate type
     */
    private Object convertAttributeValue(String value, String valueType) {
        if (value == null || value.isEmpty()) {
            return null;
        }
        
        try {
            switch (valueType.toLowerCase()) {
                case "boolean":
                    return Boolean.parseBoolean(value);
                case "integer":
                    return Integer.parseInt(value);
                case "decimal":
                    return Double.parseDouble(value);
                default:
                    return value;
            }
        } catch (Exception e) {
            return value; // Return as string if conversion fails
        }
    }

    // ==================== EAV ATTRIBUTE ENDPOINTS ====================

    /**
     * Get all available room attributes (definitions)
     */
    @GetMapping("/attributes")
    public Map<String, Object> getAllRoomAttributes() {
        Map<String, Object> response = new HashMap<>();
        
        try {
            List<RoomAttributes> attributes = roomAttributesRepository.findAll();
            List<Map<String, Object>> attrList = new ArrayList<>();
            
            for (RoomAttributes attr : attributes) {
                Map<String, Object> attrData = new HashMap<>();
                attrData.put("attributeId", attr.getAttributeId());
                attrData.put("attributeName", attr.getAttributeName());
                attrData.put("valueType", attr.getValueType());
                attrList.add(attrData);
            }
            
            response.put("status", "success");
            response.put("attributes", attrList);
            response.put("count", attrList.size());
            
        } catch (Exception e) {
            response.put("status", "error");
            response.put("message", "Error fetching attributes: " + e.getMessage());
        }
        
        return response;
    }

    /**
     * Get all attribute values for a specific room
     */
    @GetMapping("/{roomId}/attributes")
    public Map<String, Object> getRoomAttributes(@PathVariable Integer roomId) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            Optional<Rooms> roomOpt = roomsRepository.findById(roomId);
            if (roomOpt.isEmpty()) {
                response.put("status", "error");
                response.put("message", "Room not found");
                return response;
            }
            
            Map<String, Object> attributes = getRoomAttributesMap(roomId);
            
            response.put("status", "success");
            response.put("roomId", roomId);
            response.put("attributes", attributes);
            
        } catch (Exception e) {
            response.put("status", "error");
            response.put("message", "Error fetching room attributes: " + e.getMessage());
        }
        
        return response;
    }

    /**
     * Set/update attribute values for a room
     * Request body: { "attributes": { "has_projector": "true", "computer_count": "30", ... } }
     */
    @PostMapping("/{roomId}/attributes")
    public Map<String, Object> setRoomAttributes(
            @PathVariable Integer roomId,
            @RequestBody Map<String, Object> request
    ) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            Optional<Rooms> roomOpt = roomsRepository.findById(roomId);
            if (roomOpt.isEmpty()) {
                response.put("status", "error");
                response.put("message", "Room not found");
                return response;
            }
            
            Rooms room = roomOpt.get();
            
            @SuppressWarnings("unchecked")
            Map<String, Object> attributesToSet = (Map<String, Object>) request.get("attributes");
            
            if (attributesToSet == null || attributesToSet.isEmpty()) {
                response.put("status", "error");
                response.put("message", "No attributes provided");
                return response;
            }
            
            List<String> updatedAttributes = new ArrayList<>();
            List<String> failedAttributes = new ArrayList<>();
            
            for (Map.Entry<String, Object> entry : attributesToSet.entrySet()) {
                String attrName = entry.getKey();
                String attrValue = String.valueOf(entry.getValue());
                
                // Find the attribute definition
                Optional<RoomAttributes> attrOpt = roomAttributesRepository.findByAttributeName(attrName);
                if (attrOpt.isEmpty()) {
                    failedAttributes.add(attrName + " (attribute not found)");
                    continue;
                }
                
                RoomAttributes attr = attrOpt.get();
                
                // Find existing value or create new
                List<RoomAttributeValues> existingValues = roomAttributeValuesRepository
                        .findByRoom_RoomId(roomId);
                
                RoomAttributeValues rav = null;
                for (RoomAttributeValues existing : existingValues) {
                    if (existing.getAttribute().getAttributeId().equals(attr.getAttributeId())) {
                        rav = existing;
                        break;
                    }
                }
                
                if (rav == null) {
                    // Create new attribute value
                    rav = new RoomAttributeValues();
                    rav.setRoom(room);
                    rav.setAttribute(attr);
                }
                
                rav.setValue(attrValue);
                roomAttributeValuesRepository.save(rav);
                updatedAttributes.add(attrName);
            }
            
            response.put("status", "success");
            response.put("message", "Attributes updated successfully");
            response.put("updatedAttributes", updatedAttributes);
            if (!failedAttributes.isEmpty()) {
                response.put("failedAttributes", failedAttributes);
            }
            
        } catch (Exception e) {
            response.put("status", "error");
            response.put("message", "Error updating room attributes: " + e.getMessage());
        }
        
        return response;
    }

    /**
     * Search rooms by attributes
     * Query params: ?has_projector=true&computer_count_min=20&room_type=lab
     */
    @GetMapping("/search")
    public Map<String, Object> searchRoomsByAttributes(
            @RequestParam Map<String, String> params
    ) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            // Start with all rooms
            List<Rooms> candidateRooms = roomsRepository.findAll();
            List<Rooms> matchingRooms = new ArrayList<>();
            
            for (Rooms room : candidateRooms) {
                boolean matches = true;
                Map<String, Object> roomAttrs = getRoomAttributesMap(room.getRoomId());
                
                for (Map.Entry<String, String> param : params.entrySet()) {
                    String key = param.getKey();
                    String value = param.getValue();
                    
                    // Skip standard query params
                    if (key.equals("page") || key.equals("size") || key.equals("sort")) {
                        continue;
                    }
                    
                    // Handle basic room fields
                    if (key.equals("room_type") || key.equals("roomType")) {
                        if (!room.getRoomType().equalsIgnoreCase(value)) {
                            matches = false;
                            break;
                        }
                        continue;
                    }
                    if (key.equals("building")) {
                        if (!room.getBuilding().equalsIgnoreCase(value)) {
                            matches = false;
                            break;
                        }
                        continue;
                    }
                    if (key.equals("status")) {
                        if (!room.getStatus().equalsIgnoreCase(value)) {
                            matches = false;
                            break;
                        }
                        continue;
                    }
                    if (key.equals("capacity_min")) {
                        int minCap = Integer.parseInt(value);
                        if (room.getCapacity() < minCap) {
                            matches = false;
                            break;
                        }
                        continue;
                    }
                    if (key.equals("capacity_max")) {
                        int maxCap = Integer.parseInt(value);
                        if (room.getCapacity() > maxCap) {
                            matches = false;
                            break;
                        }
                        continue;
                    }
                    
                    // Handle EAV attributes
                    // Check for _min suffix (e.g., computer_count_min)
                    if (key.endsWith("_min")) {
                        String attrName = key.substring(0, key.length() - 4);
                        Object attrValue = roomAttrs.get(attrName);
                        if (attrValue == null) {
                            matches = false;
                            break;
                        }
                        double minVal = Double.parseDouble(value);
                        double actualVal = Double.parseDouble(attrValue.toString());
                        if (actualVal < minVal) {
                            matches = false;
                            break;
                        }
                        continue;
                    }
                    
                    // Check for _max suffix (e.g., computer_count_max)
                    if (key.endsWith("_max")) {
                        String attrName = key.substring(0, key.length() - 4);
                        Object attrValue = roomAttrs.get(attrName);
                        if (attrValue == null) {
                            matches = false;
                            break;
                        }
                        double maxVal = Double.parseDouble(value);
                        double actualVal = Double.parseDouble(attrValue.toString());
                        if (actualVal > maxVal) {
                            matches = false;
                            break;
                        }
                        continue;
                    }
                    
                    // Direct attribute match
                    Object attrValue = roomAttrs.get(key);
                    if (attrValue == null) {
                        matches = false;
                        break;
                    }
                    
                    // Handle boolean comparison
                    if (attrValue instanceof Boolean) {
                        boolean expected = Boolean.parseBoolean(value);
                        if (!attrValue.equals(expected)) {
                            matches = false;
                            break;
                        }
                    } else if (!attrValue.toString().equalsIgnoreCase(value)) {
                        matches = false;
                        break;
                    }
                }
                
                if (matches) {
                    matchingRooms.add(room);
                }
            }
            
            // Build response
            List<Map<String, Object>> roomList = new ArrayList<>();
            for (Rooms room : matchingRooms) {
                Map<String, Object> roomData = new HashMap<>();
                roomData.put("roomId", room.getRoomId());
                roomData.put("building", room.getBuilding());
                roomData.put("roomName", room.getRoomName());
                roomData.put("roomType", room.getRoomType());
                roomData.put("capacity", room.getCapacity());
                roomData.put("description", room.getDescription());
                roomData.put("status", room.getStatus());
                roomData.put("attributes", getRoomAttributesMap(room.getRoomId()));
                roomList.add(roomData);
            }
            
            response.put("status", "success");
            response.put("rooms", roomList);
            response.put("count", roomList.size());
            
        } catch (Exception e) {
            response.put("status", "error");
            response.put("message", "Error searching rooms: " + e.getMessage());
        }
        
        return response;
    }

    /**
     * Delete an attribute value from a room
     */
    @DeleteMapping("/{roomId}/attributes/{attributeName}")
    public Map<String, Object> deleteRoomAttribute(
            @PathVariable Integer roomId,
            @PathVariable String attributeName
    ) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            Optional<Rooms> roomOpt = roomsRepository.findById(roomId);
            if (roomOpt.isEmpty()) {
                response.put("status", "error");
                response.put("message", "Room not found");
                return response;
            }
            
            Optional<RoomAttributes> attrOpt = roomAttributesRepository.findByAttributeName(attributeName);
            if (attrOpt.isEmpty()) {
                response.put("status", "error");
                response.put("message", "Attribute not found");
                return response;
            }
            
            List<RoomAttributeValues> values = roomAttributeValuesRepository.findByRoom_RoomId(roomId);
            RoomAttributeValues toDelete = null;
            
            for (RoomAttributeValues rav : values) {
                if (rav.getAttribute().getAttributeName().equals(attributeName)) {
                    toDelete = rav;
                    break;
                }
            }
            
            if (toDelete != null) {
                roomAttributeValuesRepository.delete(toDelete);
                response.put("status", "success");
                response.put("message", "Attribute deleted successfully");
            } else {
                response.put("status", "error");
                response.put("message", "Attribute value not found for this room");
            }
            
        } catch (Exception e) {
            response.put("status", "error");
            response.put("message", "Error deleting attribute: " + e.getMessage());
        }
        
        return response;
    }
}
