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

import com.asu_lms.lms.Entities.RoomMaintenanceIssue;
import com.asu_lms.lms.Entities.RoomReservation;
import com.asu_lms.lms.Entities.Rooms;
import com.asu_lms.lms.Entities.User;
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
    private final UserRepository userRepository;

    public RoomController(
            RoomsRepository roomsRepository,
            RoomReservationRepository roomReservationRepository,
            RoomMaintenanceIssueRepository roomMaintenanceIssueRepository,
            UserRepository userRepository
    ) {
        this.roomsRepository = roomsRepository;
        this.roomReservationRepository = roomReservationRepository;
        this.roomMaintenanceIssueRepository = roomMaintenanceIssueRepository;
        this.userRepository = userRepository;
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
            String reservationType = request.get("reservationType").toString();
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
            
            RoomReservation reservation = new RoomReservation(roomId, reservedByUserId, reservationType, startTime, endTime);
            
            // Optional fields
            if (request.containsKey("purpose")) {
                reservation.setPurpose(request.get("purpose").toString());
            }
            if (request.containsKey("relatedScheduleId")) {
                reservation.setRelatedScheduleId(Integer.parseInt(request.get("relatedScheduleId").toString()));
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
        resData.put("reservationType", res.getReservationType());
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
}
