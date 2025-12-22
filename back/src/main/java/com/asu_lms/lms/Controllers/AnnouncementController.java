package com.asu_lms.lms.Controllers;

import com.asu_lms.lms.Entities.Announcement;
import com.asu_lms.lms.Repositories.AnnouncementRepository;
import com.asu_lms.lms.Services.EAVService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.sql.Timestamp;
import java.util.*;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/admin")
@CrossOrigin(origins = "*")
public class AnnouncementController {

    @Autowired
    private AnnouncementRepository announcementRepository;

    @Autowired
    private EAVService eavService;

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
            announcement.setAuthorUserId(Integer.parseInt(createdByStr));
            announcementRepository.save(announcement);

            // Set announcement attributes using EAV
            // Set scope_type (default to 'global' for admin announcements)
            eavService.setAnnouncementAttribute(announcement, "scope_type", "global");

            // Set announcement type
            if (announcementType != null && !announcementType.trim().isEmpty()) {
                String typeLower = announcementType.toLowerCase().trim();
                String enumValue;
                switch (typeLower) {
                    case "all":
                        enumValue = "all_users";
                        break;
                    case "student":
                        enumValue = "students_only";
                        break;
                    case "instructor":
                        enumValue = "instructors_only";
                        break;
                    case "admin":
                        enumValue = "admins_only";
                        break;
                    default:
                        enumValue = typeLower;
                        break;
                }
                eavService.setAnnouncementAttribute(announcement, "announcement_type", enumValue);
            } else {
                eavService.setAnnouncementAttribute(announcement, "announcement_type", "all_users");
            }

            // Set priority
            if (priority != null && !priority.trim().isEmpty()) {
                eavService.setAnnouncementAttribute(announcement, "priority", priority.toLowerCase());
            } else {
                eavService.setAnnouncementAttribute(announcement, "priority", "medium");
            }

            // Set is_active (default to true)
            eavService.setAnnouncementAttribute(announcement, "is_active", "true");

            // Set expiration date if provided
            if (expiresAtStr != null && !expiresAtStr.trim().isEmpty()) {
                try {
                    Timestamp expiresAt = Timestamp.valueOf(expiresAtStr);
                    eavService.setAnnouncementAttribute(announcement, "expires_at", expiresAt.toString());
                } catch (IllegalArgumentException e) {
                    response.put("status", "error");
                    response.put("message", "Invalid expiration date format");
                    return response;
                }
            }

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

    // Get all announcements with their attributes
    @GetMapping("/announcements")
    public List<Map<String, Object>> getAllAnnouncements() {
        List<Announcement> announcements = announcementRepository.findAll();
        return announcements.stream().map(announcement -> {
            Map<String, Object> announcementData = new HashMap<>();
            announcementData.put("announcementId", announcement.getAnnouncementId());
            announcementData.put("authorUserId", announcement.getAuthorUserId());
            announcementData.put("title", announcement.getTitle());
            announcementData.put("content", announcement.getContent());
            announcementData.put("createdAt", announcement.getCreatedAt());
            
            // Add EAV attributes
            Map<String, String> attributes = eavService.getAnnouncementAttributes(announcement.getAnnouncementId());
            announcementData.putAll(attributes);
            
            return announcementData;
        }).collect(Collectors.toList());
    }

    // Get announcements for specific user type
    @GetMapping("/announcements/{userType}")
    public List<Map<String, Object>> getAnnouncementsForUserType(@PathVariable String userType) {
        Timestamp currentTime = new Timestamp(System.currentTimeMillis());
        List<Announcement> allAnnouncements = announcementRepository.findAll();
        
        String targetType = userType.toLowerCase();
        if (!targetType.equals("all_users") && !targetType.equals("students_only") && 
            !targetType.equals("instructors_only") && !targetType.equals("admins_only")) {
            // Map common values
            switch (targetType) {
                case "all":
                    targetType = "all_users";
                    break;
                case "student":
                    targetType = "students_only";
                    break;
                case "instructor":
                    targetType = "instructors_only";
                    break;
                case "admin":
                    targetType = "admins_only";
                    break;
            }
        }
        
        final String finalTargetType = targetType;
        return allAnnouncements.stream()
            .filter(announcement -> {
                Map<String, String> attrs = eavService.getAnnouncementAttributes(announcement.getAnnouncementId());
                String isActive = attrs.getOrDefault("is_active", "true");
                String announcementType = attrs.getOrDefault("announcement_type", "all_users");
                String expiresAtStr = attrs.get("expires_at");
                
                // Check if active
                if (!"true".equalsIgnoreCase(isActive)) {
                    return false;
                }
                
                // Check expiration
                if (expiresAtStr != null && !expiresAtStr.isEmpty()) {
                    try {
                        Timestamp expiresAt = Timestamp.valueOf(expiresAtStr);
                        if (expiresAt.before(currentTime)) {
                            return false;
                        }
                    } catch (Exception e) {
                        // Ignore invalid date format
                    }
                }
                
                // Check user type match
                return announcementType.equals(finalTargetType) || announcementType.equals("all_users");
            })
            .map(announcement -> {
                Map<String, Object> announcementData = new HashMap<>();
                announcementData.put("announcementId", announcement.getAnnouncementId());
                announcementData.put("authorUserId", announcement.getAuthorUserId());
                announcementData.put("title", announcement.getTitle());
                announcementData.put("content", announcement.getContent());
                announcementData.put("createdAt", announcement.getCreatedAt());
                
                // Add EAV attributes
                Map<String, String> attributes = eavService.getAnnouncementAttributes(announcement.getAnnouncementId());
                announcementData.putAll(attributes);
                
                return announcementData;
            })
            .collect(Collectors.toList());
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

            // Update base fields if provided
            if (request.get("title") != null && !request.get("title").trim().isEmpty()) {
                announcement.setTitle(request.get("title").trim());
            }

            if (request.get("content") != null && !request.get("content").trim().isEmpty()) {
                announcement.setContent(request.get("content").trim());
            }

            announcementRepository.save(announcement);

            // Update EAV attributes if provided
            if (request.get("announcementType") != null && !request.get("announcementType").trim().isEmpty()) {
                String typeLower = request.get("announcementType").toLowerCase().trim();
                String enumValue;
                switch (typeLower) {
                    case "all":
                        enumValue = "all_users";
                        break;
                    case "student":
                        enumValue = "students_only";
                        break;
                    case "instructor":
                        enumValue = "instructors_only";
                        break;
                    case "admin":
                        enumValue = "admins_only";
                        break;
                    default:
                        enumValue = typeLower;
                        break;
                }
                eavService.setAnnouncementAttribute(announcement, "announcement_type", enumValue);
            }

            if (request.get("priority") != null && !request.get("priority").trim().isEmpty()) {
                eavService.setAnnouncementAttribute(announcement, "priority", request.get("priority").toLowerCase());
            }

            if (request.get("isActive") != null) {
                eavService.setAnnouncementAttribute(announcement, "is_active", 
                    Boolean.parseBoolean(request.get("isActive")) ? "true" : "false");
            }

            if (request.get("expiresAt") != null && !request.get("expiresAt").trim().isEmpty()) {
                try {
                    Timestamp expiresAt = Timestamp.valueOf(request.get("expiresAt"));
                    eavService.setAnnouncementAttribute(announcement, "expires_at", expiresAt.toString());
                } catch (IllegalArgumentException e) {
                    response.put("status", "error");
                    response.put("message", "Invalid expiration date format");
                    return response;
                }
            }

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
