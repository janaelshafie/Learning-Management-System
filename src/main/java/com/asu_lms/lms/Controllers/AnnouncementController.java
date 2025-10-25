package com.asu_lms.lms.Controllers;

import com.asu_lms.lms.Entities.Announcement;
import com.asu_lms.lms.Repositories.AnnouncementRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.sql.Timestamp;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/api/admin")
@CrossOrigin(origins = "*")
public class AnnouncementController {

    @Autowired
    private AnnouncementRepository announcementRepository;

    // Create new announcement
    @PostMapping("/create-announcement")
    public Map<String, String> createAnnouncement(@RequestBody Map<String, String> request) {
        Map<String, String> response = new HashMap<>();

        try {
            String title = request.get("title");
            String content = request.get("content");
            String announcementType = request.get("announcementType");
            String priority = request.get("priority");
            String createdByStr = request.get("createdBy");
            String expiresAtStr = request.get("expiresAt");

            if (title == null || title.trim().isEmpty()) {
                response.put("status", "error");
                response.put("message", "Title is required");
                return response;
            }

            if (content == null || content.trim().isEmpty()) {
                response.put("status", "error");
                response.put("message", "Content is required");
                return response;
            }

            if (createdByStr == null || createdByStr.trim().isEmpty()) {
                response.put("status", "error");
                response.put("message", "Created by user ID is required");
                return response;
            }

            Announcement announcement = new Announcement();
            announcement.setTitle(title.trim());
            announcement.setContent(content.trim());
            announcement.setCreatedBy(Integer.parseInt(createdByStr));

            // Set announcement type
            if (announcementType != null && !announcementType.trim().isEmpty()) {
                try {
                    announcement.setAnnouncementType(Announcement.AnnouncementType.valueOf(announcementType.toLowerCase()));
                } catch (IllegalArgumentException e) {
                    response.put("status", "error");
                    response.put("message", "Invalid announcement type");
                    return response;
                }
            }

            // Set priority
            if (priority != null && !priority.trim().isEmpty()) {
                try {
                    announcement.setPriority(Announcement.Priority.valueOf(priority.toLowerCase()));
                } catch (IllegalArgumentException e) {
                    response.put("status", "error");
                    response.put("message", "Invalid priority level");
                    return response;
                }
            }

            // Set expiration date if provided
            if (expiresAtStr != null && !expiresAtStr.trim().isEmpty()) {
                try {
                    announcement.setExpiresAt(Timestamp.valueOf(expiresAtStr));
                } catch (IllegalArgumentException e) {
                    response.put("status", "error");
                    response.put("message", "Invalid expiration date format");
                    return response;
                }
            }

            announcementRepository.save(announcement);

            response.put("status", "success");
            response.put("message", "Announcement created successfully");
            return response;

        } catch (NumberFormatException e) {
            response.put("status", "error");
            response.put("message", "Invalid user ID format");
            return response;
        } catch (Exception e) {
            response.put("status", "error");
            response.put("message", "Error creating announcement: " + e.getMessage());
            return response;
        }
    }

    // Get all announcements
    @GetMapping("/announcements")
    public List<Announcement> getAllAnnouncements() {
        return announcementRepository.findAll();
    }

    // Get announcements for specific user type
    @GetMapping("/announcements/{userType}")
    public List<Announcement> getAnnouncementsForUserType(@PathVariable String userType) {
        Timestamp currentTime = new Timestamp(System.currentTimeMillis());
        
        try {
            Announcement.AnnouncementType type = Announcement.AnnouncementType.valueOf(userType.toLowerCase());
            return announcementRepository.findActiveForUserType(type, currentTime);
        } catch (IllegalArgumentException e) {
            return announcementRepository.findActiveAndNotExpired(currentTime);
        }
    }

    // Update announcement
    @PostMapping("/update-announcement")
    public Map<String, String> updateAnnouncement(@RequestBody Map<String, String> request) {
        Map<String, String> response = new HashMap<>();

        try {
            String announcementIdStr = request.get("announcementId");
            if (announcementIdStr == null || announcementIdStr.trim().isEmpty()) {
                response.put("status", "error");
                response.put("message", "Announcement ID is required");
                return response;
            }

            Integer announcementId = Integer.parseInt(announcementIdStr);
            Optional<Announcement> announcementOpt = announcementRepository.findById(announcementId);

            if (announcementOpt.isEmpty()) {
                response.put("status", "error");
                response.put("message", "Announcement not found");
                return response;
            }

            Announcement announcement = announcementOpt.get();

            // Update fields if provided
            if (request.get("title") != null && !request.get("title").trim().isEmpty()) {
                announcement.setTitle(request.get("title").trim());
            }

            if (request.get("content") != null && !request.get("content").trim().isEmpty()) {
                announcement.setContent(request.get("content").trim());
            }

            if (request.get("announcementType") != null && !request.get("announcementType").trim().isEmpty()) {
                try {
                    announcement.setAnnouncementType(Announcement.AnnouncementType.valueOf(request.get("announcementType").toLowerCase()));
                } catch (IllegalArgumentException e) {
                    response.put("status", "error");
                    response.put("message", "Invalid announcement type");
                    return response;
                }
            }

            if (request.get("priority") != null && !request.get("priority").trim().isEmpty()) {
                try {
                    announcement.setPriority(Announcement.Priority.valueOf(request.get("priority").toLowerCase()));
                } catch (IllegalArgumentException e) {
                    response.put("status", "error");
                    response.put("message", "Invalid priority level");
                    return response;
                }
            }

            if (request.get("isActive") != null) {
                announcement.setIsActive(Boolean.parseBoolean(request.get("isActive")));
            }

            if (request.get("expiresAt") != null && !request.get("expiresAt").trim().isEmpty()) {
                try {
                    announcement.setExpiresAt(Timestamp.valueOf(request.get("expiresAt")));
                } catch (IllegalArgumentException e) {
                    response.put("status", "error");
                    response.put("message", "Invalid expiration date format");
                    return response;
                }
            }

            announcementRepository.save(announcement);

            response.put("status", "success");
            response.put("message", "Announcement updated successfully");
            return response;

        } catch (NumberFormatException e) {
            response.put("status", "error");
            response.put("message", "Invalid announcement ID format");
            return response;
        } catch (Exception e) {
            response.put("status", "error");
            response.put("message", "Error updating announcement: " + e.getMessage());
            return response;
        }
    }

    // Delete announcement
    @PostMapping("/delete-announcement")
    public Map<String, String> deleteAnnouncement(@RequestBody Map<String, String> request) {
        Map<String, String> response = new HashMap<>();

        try {
            String announcementIdStr = request.get("announcementId");
            if (announcementIdStr == null || announcementIdStr.trim().isEmpty()) {
                response.put("status", "error");
                response.put("message", "Announcement ID is required");
                return response;
            }

            Integer announcementId = Integer.parseInt(announcementIdStr);
            Optional<Announcement> announcementOpt = announcementRepository.findById(announcementId);

            if (announcementOpt.isEmpty()) {
                response.put("status", "error");
                response.put("message", "Announcement not found");
                return response;
            }

            announcementRepository.deleteById(announcementId);

            response.put("status", "success");
            response.put("message", "Announcement deleted successfully");
            return response;

        } catch (NumberFormatException e) {
            response.put("status", "error");
            response.put("message", "Invalid announcement ID format");
            return response;
        } catch (Exception e) {
            response.put("status", "error");
            response.put("message", "Error deleting announcement: " + e.getMessage());
            return response;
        }
    }
}
