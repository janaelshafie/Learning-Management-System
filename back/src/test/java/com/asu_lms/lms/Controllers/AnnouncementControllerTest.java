// package com.asu_lms.lms.Controllers;

// import org.junit.jupiter.api.Assertions;
// import org.junit.jupiter.api.Test;

// import java.util.*;

// import static org.mockito.Mockito.*;
// import com.asu_lms.lms.Services.AuthService;
// import com.asu_lms.lms.Repositories.UserRepository;
// import com.asu_lms.lms.Entities.User;
// import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;
// import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
// import org.springframework.beans.factory.annotation.Autowired;
// import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
// import org.springframework.test.web.servlet.MockMvc;
// import org.mockito.InjectMocks;
// import org.mockito.Mock;
// import org.mockito.junit.jupiter.MockitoExtension;
// import org.junit.jupiter.api.extension.ExtendWith;
// import com.fasterxml.jackson.databind.ObjectMapper;
// import com.asu_lms.lms.Entities.Announcement;
// import com.asu_lms.lms.Repositories.AnnouncementRepository;

// import static org.junit.jupiter.api.Assertions.*;

// class AnnouncementControllerTest {
//     @Mock
//     private AnnouncementRepository announcementRepository;

//     @InjectMocks
//     private AnnouncementController announcementController;

//     @Test
//     public void testCreateAnnouncement_Success() {
//         Map<String,String> request = new HashMap<>();
//         request.put("title", "New Event");
//         request.put("content", "Join us for a workshop.");
//         request.put("announcementType", "general");
//         request.put("priority", "high");
//         request.put("createdBy", "1");
//         request.put("expiresAt", "2025-12-30 10:00:00");

//         doNothing().when(announcementRepository).save(any(Announcement.class));

//         Map<String, String> response = announcementController.createAnnouncement(request);

//         assertEquals("success", response.get("status"));
//         assertEquals("Announcement created successfully", response.get("message"));
//     }

//     @Test
//     public void testCreateAnnouncement_TitleMissing() {
//         Map<String,String> request = new HashMap<>();
//         request.put("content", "Join us for a workshop.");
//         request.put("createdBy", "1");

//         Map<String, String> response = announcementController.createAnnouncement(request);

//         assertEquals("error", response.get("status"));
//         assertEquals("Title is required", response.get("message"));
//     }

//     @Test
//     public void testCreateAnnouncement_ContentMissing() {
//         Map<String,String> request = new HashMap<>();
//         request.put("title", "New Event");
//         request.put("createdBy", "1");

//         Map<String, String> response = announcementController.createAnnouncement(request);

//         assertEquals("error", response.get("status"));
//         assertEquals("Content is required", response.get("message"));
//     }

//     @Test
//     public void testCreateAnnouncement_CreatedByMissing() {
//         Map<String,String> request = new HashMap<>();
//         request.put("title", "New Event");
//         request.put("content", "Details.");

//         Map<String, String> response = announcementController.createAnnouncement(request);

//         assertEquals("error", response.get("status"));
//         assertEquals("Created by user ID is required", response.get("message"));
//     }

//     @Test
//     public void testCreateAnnouncement_InvalidAnnouncementType() {
//         Map<String,String> request = new HashMap<>();
//         request.put("title", "Title");
//         request.put("content", "Content");
//         request.put("createdBy", "1");
//         request.put("announcementType", "UNKNOWN_TYPE");

//         Map<String, String> response = announcementController.createAnnouncement(request);

//         assertEquals("error", response.get("status"));
//         assertEquals("Invalid announcement type", response.get("message"));
//     }

//     @Test
//     public void testCreateAnnouncement_InvalidPriority() {
//         Map<String,String> request = new HashMap<>();
//         request.put("title", "Title");
//         request.put("content", "Content");
//         request.put("createdBy", "1");
//         request.put("priority", "BAD_PRIORITY");

//         Map<String, String> response = announcementController.createAnnouncement(request);

//         assertEquals("error", response.get("status"));
//         assertEquals("Invalid priority level", response.get("message"));
//     }

//     @Test
//     public void testCreateAnnouncement_InvalidExpirationDate() {
//         Map<String,String> request = new HashMap<>();
//         request.put("title", "Title");
//         request.put("content", "Content");
//         request.put("createdBy", "1");
//         request.put("expiresAt", "not a timestamp");

//         Map<String, String> response = announcementController.createAnnouncement(request);

//         assertEquals("error", response.get("status"));
//         assertEquals("Invalid expiration date format", response.get("message"));
//     }

//     @Test
//     public void testCreateAnnouncement_InvalidUserIdFormat() {
//         Map<String,String> request = new HashMap<>();
//         request.put("title", "Title");
//         request.put("content", "Content");
//         request.put("createdBy", "notANumber");

//         Map<String, String> response = announcementController.createAnnouncement(request);

//         assertEquals("error", response.get("status"));
//         assertEquals("Invalid user ID format", response.get("message"));
//     }
//     @Test
//     public void testgetAllAnnouncements() {
//         Announcement announcement1 = new Announcement();
//         announcement1.setTitle("Event1");
//         announcement1.setContent("Join us for a workshop.");
//         announcement1.setAnnouncementId(11);
//         announcement1.setPriority(Announcement.Priority.high);
//         announcement1.setAnnouncementType(Announcement.AnnouncementType.admins_only);

//         Announcement announcement2 = new Announcement();
//         announcement2.setTitle("Event2");
//         announcement2.setContent("Join us for a workshop.");
//         announcement2.setAnnouncementId(22);
//         announcement2.setPriority(Announcement.Priority.medium);
//         announcement2.setAnnouncementType(Announcement.AnnouncementType.all_users);

//         Announcement announcement3 = new Announcement();
//         announcement3.setTitle("Event3");
//         announcement3.setContent("Join us for a workshop.");
//         announcement3.setAnnouncementId(33);
//         announcement3.setPriority(Announcement.Priority.urgent);
//         announcement3.setAnnouncementType(Announcement.AnnouncementType.students_only);

//         Announcement announcement4 = new Announcement();
//         announcement4.setTitle("Event4");
//         announcement4.setContent("Join us for a workshop.");
//         announcement4.setAnnouncementId(44);
//         announcement4.setPriority(Announcement.Priority.low);
//         announcement4.setAnnouncementType(Announcement.AnnouncementType.instructors_only);

//         List<Announcement> announcementList = Arrays.asList(
//                 announcement1, announcement2, announcement3, announcement4
//         );

//         when(announcementRepository.findAll()).thenReturn(announcementList);

//         List<Announcement> result = announcementController.getAllAnnouncements();

//         assertEquals(4, result.size());

//         assertEquals("Event1", result.get(0).getTitle());
//         assertEquals(Announcement.Priority.high, result.get(0).getPriority());
//         assertEquals(Announcement.AnnouncementType.admins_only, result.get(0).getAnnouncementType());

//         assertEquals("Event2", result.get(1).getTitle());
//         assertEquals(Announcement.Priority.medium, result.get(1).getPriority());
//         assertEquals(Announcement.AnnouncementType.all_users, result.get(1).getAnnouncementType());

//         assertEquals("Event3", result.get(2).getTitle());
//         assertEquals(Announcement.Priority.urgent, result.get(2).getPriority());
//         assertEquals("Join us for a workshop.", result.get(2).getContent());
//         assertEquals(Announcement.AnnouncementType.students_only, result.get(2).getAnnouncementType());

//         assertEquals("Event4", result.get(3).getTitle());
//         assertEquals(Announcement.Priority.low, result.get(3).getPriority());
//         assertEquals("Join us for a workshop.", result.get(3).getContent());
//         assertEquals(Announcement.AnnouncementType.instructors_only, result.get(3).getAnnouncementType());
//     }

//     @Test
//     public void testUpdateAnnouncement_Success() {
//         Map<String, String> request = new HashMap<>();
//         request.put("announcementId", "1");
//         request.put("title", "Updated Title");
//         request.put("content", "Updated content");
//         request.put("announcementType", "general");
//         request.put("priority", "high");
//         request.put("isActive", "true");
//         request.put("expiresAt", "2025-12-30 10:00:00");

//         Announcement announcement = new Announcement();
//         announcement.setAnnouncementId(1);
//         announcement.setTitle("Old Title");

//         when(announcementRepository.findById(1)).thenReturn(Optional.of(announcement));
//         when(announcementRepository.save(any(Announcement.class))).thenReturn(announcement);

//         Map<String, String> response = announcementController.updateAnnouncement(request);

//         assertEquals("success", response.get("status"));
//         assertEquals("Announcement updated successfully", response.get("message"));
//         assertEquals("Updated Title", announcement.getTitle());
//     }

//     @Test
//     public void testUpdateAnnouncement_AnnouncementIdMissing() {
//         Map<String, String> request = new HashMap<>();
//         Map<String, String> response = announcementController.updateAnnouncement(request);
//         assertEquals("error", response.get("status"));
//         assertEquals("Announcement ID is required", response.get("message"));
//     }

//     @Test
//     public void testUpdateAnnouncement_AnnouncementNotFound() {
//         Map<String, String> request = new HashMap<>();
//         request.put("announcementId", "123");
//         when(announcementRepository.findById(123)).thenReturn(Optional.empty());
//         Map<String, String> response = announcementController.updateAnnouncement(request);
//         assertEquals("error", response.get("status"));
//         assertEquals("Announcement not found", response.get("message"));
//     }

//     @Test
//     public void testUpdateAnnouncement_InvalidAnnouncementId() {
//         Map<String, String> request = new HashMap<>();
//         request.put("announcementId", "notANumber");
//         Map<String, String> response = announcementController.updateAnnouncement(request);
//         assertEquals("error", response.get("status"));
//         assertEquals("Invalid announcement ID format", response.get("message"));
//     }

//     @Test
//     public void testUpdateAnnouncement_InvalidType() {
//         Map<String, String> request = new HashMap<>();
//         request.put("announcementId", "1");
//         request.put("announcementType", "BADTYPE");
//         Announcement announcement = new Announcement();
//         when(announcementRepository.findById(1)).thenReturn(Optional.of(announcement));
//         Map<String, String> response = announcementController.updateAnnouncement(request);
//         assertEquals("error", response.get("status"));
//         assertEquals("Invalid announcement type", response.get("message"));
//     }

//     @Test
//     public void testUpdateAnnouncement_InvalidPriority() {
//         Map<String, String> request = new HashMap<>();
//         request.put("announcementId", "1");
//         request.put("priority", "BADPRIORITY");
//         Announcement announcement = new Announcement();
//         when(announcementRepository.findById(1)).thenReturn(Optional.of(announcement));
//         Map<String, String> response = announcementController.updateAnnouncement(request);
//         assertEquals("error", response.get("status"));
//         assertEquals("Invalid priority level", response.get("message"));
//     }

//     @Test
//     public void testUpdateAnnouncement_InvalidExpiresAt() {
//         Map<String, String> request = new HashMap<>();
//         request.put("announcementId", "1");
//         request.put("expiresAt", "not-a-timestamp");
//         Announcement announcement = new Announcement();
//         when(announcementRepository.findById(1)).thenReturn(Optional.of(announcement));
//         Map<String, String> response = announcementController.updateAnnouncement(request);
//         assertEquals("error", response.get("status"));
//         assertEquals("Invalid expiration date format", response.get("message"));
//     }

//     // -------- deleteAnnouncement tests --------

//     @Test
//     public void testDeleteAnnouncement_Success() {
//         Map<String, String> request = new HashMap<>();
//         request.put("announcementId", "2");
//         Announcement announcement = new Announcement();
//         when(announcementRepository.findById(2)).thenReturn(Optional.of(announcement));
//         doNothing().when(announcementRepository).deleteById(2);
//         Map<String, String> response = announcementController.deleteAnnouncement(request);
//         assertEquals("success", response.get("status"));
//         assertEquals("Announcement deleted successfully", response.get("message"));
//     }

//     @Test
//     public void testDeleteAnnouncement_AnnouncementIdMissing() {
//         Map<String, String> request = new HashMap<>();
//         Map<String, String> response = announcementController.deleteAnnouncement(request);
//         assertEquals("error", response.get("status"));
//         assertEquals("Announcement ID is required", response.get("message"));
//     }

//     @Test
//     public void testDeleteAnnouncement_AnnouncementNotFound() {
//         Map<String, String> request = new HashMap<>();
//         request.put("announcementId", "2");
//         when(announcementRepository.findById(2)).thenReturn(Optional.empty());
//         Map<String, String> response = announcementController.deleteAnnouncement(request);
//         assertEquals("error", response.get("status"));
//         assertEquals("Announcement not found", response.get("message"));
//     }

//     @Test
//     public void testDeleteAnnouncement_InvalidAnnouncementId() {
//         Map<String, String> request = new HashMap<>();
//         request.put("announcementId", "notanumber");
//         Map<String, String> response = announcementController.deleteAnnouncement(request);
//         assertEquals("error", response.get("status"));
//         assertEquals("Invalid announcement ID format", response.get("message"));
//     }

// }