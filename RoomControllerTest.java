package com.asu_lms.lms.Controllers;

import com.asu_lms.lms.Entities.RoomMaintenanceIssue;
import com.asu_lms.lms.Entities.RoomReservation;
import com.asu_lms.lms.Entities.Rooms;
import com.asu_lms.lms.Entities.User;
import com.asu_lms.lms.Repositories.RoomMaintenanceIssueRepository;
import com.asu_lms.lms.Repositories.RoomReservationRepository;
import com.asu_lms.lms.Repositories.RoomsRepository;
import com.asu_lms.lms.Repositories.UserRepository;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;

import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import java.util.Optional;

import static org.hamcrest.Matchers.*;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.ArgumentMatchers.any;

@WebMvcTest(RoomController.class)
class RoomControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private RoomsRepository roomsRepository;

    @Autowired
    private RoomReservationRepository roomReservationRepository;

    @Autowired
    private RoomMaintenanceIssueRepository roomMaintenanceIssueRepository;

    @Autowired
    private UserRepository userRepository;

    // ========== ROOM MANAGEMENT TESTS ==========

    @Test
    void getAllRooms_success() throws Exception {
        Rooms r = new Rooms("Building A", "A-101", "lecture", 50, "Nice room");
        r.setRoomId(1);
        r.setStatus("available");

        when(roomsRepository.findAll()).thenReturn(List.of(r));

        mockMvc.perform(get("/api/rooms/list"))
                .andExpect(status().isOk())                       // [web:1][web:2]
                .andExpect(jsonPath("$.status").value("success"))
                .andExpect(jsonPath("$.count").value(1))
                .andExpect(jsonPath("$.rooms[0].roomId").value(1))
                .andExpect(jsonPath("$.rooms[0].roomName").value("A-101"));
    }

    @Test
    void getRoomById_notFound() throws Exception {
        when(roomsRepository.findById(99)).thenReturn(Optional.empty());

        mockMvc.perform(get("/api/rooms/{roomId}", 99))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.status").value("error"))
                .andExpect(jsonPath("$.message").value("Room not found"));
    }

    @Test
    void createRoom_success() throws Exception {
        Rooms saved = new Rooms("B", "B-201", "lab", 25, "Lab room");
        saved.setRoomId(5);
        saved.setStatus("available");
        when(roomsRepository.findById(5)).thenReturn(Optional.of(saved));  // [web:9][web:15]

        String body = """
            {
              "building": "B",
              "roomName": "B-201",
              "roomType": "lab",
              "capacity": 25,
              "description": "Lab room"
            }
            """;

        mockMvc.perform(post("/api/rooms")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(body))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.status").value("success"))
                .andExpect(jsonPath("$.message").value("Room created successfully"))
                .andExpect(jsonPath("$.roomId").isNumber());
    }

    @Test
    void deleteRoom_withActiveReservations_error() throws Exception {
        Rooms room = new Rooms("C", "C-301", "lecture", 60, null);
        room.setRoomId(10);
        when(roomsRepository.findById(10)).thenReturn(Optional.of(room));

        RoomReservation res = new RoomReservation();
        res.setReservationId(1);
        res.setRoomId(10);
        res.setStatus("approved");
        when(roomReservationRepository.findByRoomId(10)).thenReturn(List.of(res));  // [web:11]

        mockMvc.perform(delete("/api/rooms/{roomId}", 10))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.status").value("error"))
                .andExpect(jsonPath("$.message").value("Cannot delete room with active reservations"));
    }

    @Test
    void updateRoomStatus_success() throws Exception {
        Rooms room = new Rooms("D", "D-101", "lecture", 40, null);
        room.setRoomId(3);
        when(roomsRepository.findById(3)).thenReturn(Optional.of(room));

        String body = """
            {
              "status": "maintenance",
              "statusNotes": "AC broken",
              "updatedByUserId": 7
            }
            """;

        mockMvc.perform(put("/api/rooms/{roomId}/status", 3)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(body))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.status").value("success"))
                .andExpect(jsonPath("$.message").value("Room status updated successfully"));
    }

    // ========== AVAILABLE ROOMS / RESERVATIONS ==========

    @Test
    void getAvailableRooms_success() throws Exception {
        Rooms room = new Rooms("A", "A-101", "lecture", 50, null);
        room.setRoomId(1);
        room.setStatus("available");
        when(roomsRepository.findAll()).thenReturn(List.of(room));

        when(roomReservationRepository.findConflictingReservations(
                eq(1), any(Timestamp.class), any(Timestamp.class)))
                .thenReturn(List.of());                             // no conflicts

        mockMvc.perform(get("/api/rooms/available")
                        .param("startDatetime", "2025-12-20 10:00:00")
                        .param("endDatetime", "2025-12-20 12:00:00"))
                .andExpect(status().isOk())                        // [web:1][web:5]
                .andExpect(jsonPath("$.status").value("success"))
                .andExpect(jsonPath("$.count").value(1))
                .andExpect(jsonPath("$.availableRooms[0].roomId").value(1));
    }

    @Test
    void createReservation_timeValidation_error() throws Exception {
        String body = """
            {
              "roomId": 1,
              "reservedByUserId": 2,
              "reservationType": "manual",
              "startDatetime": "2025-12-20 12:00:00",
              "endDatetime": "2025-12-20 11:00:00"
            }
            """;

        mockMvc.perform(post("/api/rooms/reservations")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(body))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.status").value("error"))
                .andExpect(jsonPath("$.message").value("End time must be after start time"));
    }

    @Test
    void getRoomReservations_basic() throws Exception {
        RoomReservation r = new RoomReservation();
        r.setReservationId(1);
        r.setRoomId(5);
        r.setReservedByUserId(2);
        r.setReservationType("manual");
        r.setStartDatetime(Timestamp.valueOf(LocalDateTime.of(2025, 12, 20, 10, 0)));
        r.setEndDatetime(Timestamp.valueOf(LocalDateTime.of(2025, 12, 20, 12, 0)));
        r.setStatus("approved");
        r.setRequestedAt(Timestamp.valueOf(LocalDateTime.of(2025, 12, 18, 9, 0)));

        User u = new User();
        u.setUserId(2);
        u.setName("Alice");

        when(roomReservationRepository.findByRoomId(5)).thenReturn(List.of(r));
        when(userRepository.findById(2)).thenReturn(Optional.of(u));

        mockMvc.perform(get("/api/rooms/{roomId}/reservations", 5))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.status").value("success"))
                .andExpect(jsonPath("$.reservations[0].reservationId").value(1))
                .andExpect(jsonPath("$.reservations[0].reservedByName").value("Alice"));
    }

    @Test
    void updateReservationStatus_approved() throws Exception {
        RoomReservation r = new RoomReservation();
        r.setReservationId(1);
        r.setStatus("pending");
        when(roomReservationRepository.findById(1)).thenReturn(Optional.of(r));

        String body = """
            { "status": "approved", "approvedByUserId": 10 }
            """;

        mockMvc.perform(put("/api/rooms/reservations/{reservationId}/status", 1)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(body))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.status").value("success"))
                .andExpect(jsonPath("$.message").value("Reservation status updated successfully"));
    }

    // ========== MAINTENANCE ISSUES ==========

    @Test
    void reportMaintenanceIssue_setsRoomToMaintenanceForHighPriority() throws Exception {
        Rooms room = new Rooms("A", "A-101", "lecture", 50, null);
        room.setRoomId(1);
        when(roomsRepository.findById(1)).thenReturn(Optional.of(room));
        when(roomMaintenanceIssueRepository.save(any(RoomMaintenanceIssue.class)))
                .thenAnswer(inv -> {
                    RoomMaintenanceIssue i = inv.getArgument(0);
                    i.setIssueId(100);
                    return i;
                });

        String body = """
            {
              "roomId": 1,
              "reportedByUserId": 2,
              "issueType": "electrical",
              "title": "Lights not working",
              "description": "All lights are off",
              "priority": "high"
            }
            """;

        mockMvc.perform(post("/api/rooms/maintenance/issues")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(body))
                .andExpect(status().isOk())                         // [web:3][web:14]
                .andExpect(jsonPath("$.status").value("success"))
                .andExpect(jsonPath("$.issueId").value(100));
    }

    @Test
    void getMaintenanceIssues_all() throws Exception {
        RoomMaintenanceIssue issue = new RoomMaintenanceIssue(1, 2, "electrical",
                "Broken socket", "Socket near door broken");
        issue.setIssueId(5);
        issue.setPriority("medium");
        issue.setStatus("open");
        issue.setReportedAt(Timestamp.valueOf(LocalDateTime.of(2025, 12, 20, 9, 0)));

        User reporter = new User();
        reporter.setUserId(2);
        reporter.setName("Bob");

        when(roomMaintenanceIssueRepository.findAll()).thenReturn(List.of(issue));
        when(userRepository.findById(2)).thenReturn(Optional.of(reporter));

        mockMvc.perform(get("/api/rooms/maintenance/issues"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.status").value("success"))
                .andExpect(jsonPath("$.count").value(1))
                .andExpect(jsonPath("$.issues[0].issueId").value(5))
                .andExpect(jsonPath("$.issues[0].reportedByName").value("Bob"));
    }

    @Test
    void updateMaintenanceIssue_resolved() throws Exception {
        RoomMaintenanceIssue issue = new RoomMaintenanceIssue(1, 2, "electrical",
                "Broken lamp", "Lamp broken");
        issue.setIssueId(7);
        issue.setStatus("open");
        issue.setReportedAt(Timestamp.from(java.time.Instant.now()));

        when(roomMaintenanceIssueRepository.findById(7)).thenReturn(Optional.of(issue));

        String body = """
            {
              "status": "resolved",
              "resolvedByUserId": 3,
              "resolutionNotes": "Replaced lamp",
              "estimatedCost": 100,
              "actualCost": 80
            }
            """;

        mockMvc.perform(put("/api/rooms/maintenance/issues/{issueId}", 7)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(body))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.status").value("success"))
                .andExpect(jsonPath("$.message").value("Maintenance issue updated successfully"));
    }
}
