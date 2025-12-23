package com.asu_lms.lms.Controllers;

import com.asu_lms.lms.Entities.Announcement;
import com.asu_lms.lms.Entities.OfferedCourse;
import com.asu_lms.lms.Repositories.AnnouncementRepository;
import com.asu_lms.lms.Repositories.OfferedCourseRepository;
import com.asu_lms.lms.Services.EAVService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.sql.Timestamp;
import java.util.*;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/course/announcements")
@CrossOrigin(origins = "*")
public class CourseAnnouncementController {

    @Autowired
    private AnnouncementRepository announcementRepository;

    @Autowired
    private OfferedCourseRepository offeredCourseRepository;

    @Autowired
    private EAVService eavService;

    /**
     * Create a course-specific announcement
     * POST /api/course/announcements/create
     */
    @PostMapping("/create")
    public Map<String, Object> createCourseAnnouncement(@RequestBody Map<String, Object> request) {
        Map<String, Object> response = new HashMap<>();

        try {
            Integer offeredCourseId = parseInteger(request.get("offeredCourseId"));
            Integer authorUserId = parseInteger(request.get("authorUserId"));
            String title = (String) request.get("title");
            String content = (String) request.get("content");
            String priority = request.get("priority") != null ? request.get("priority").toString() : null;

            // Validation
            if (offeredCourseId == null) {
                response.put("status", "error");
                response.put("message", "Offered course ID is required");
                return response;
            }

            if (authorUserId == null) {
                response.put("status", "error");
                response.put("message", "Author user ID is required");
                return response;
            }

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

            // Validate offered course exists
            Optional<OfferedCourse> offeredCourseOpt = offeredCourseRepository.findById(offeredCourseId);
            if (offeredCourseOpt.isEmpty()) {
                response.put("status", "error");
                response.put("message", "Offered course not found");
                return response;
            }

            // Create announcement
            Announcement announcement = new Announcement();
            announcement.setTitle(title.trim());
            announcement.setContent(content.trim());
            announcement.setAuthorUserId(authorUserId);
            announcementRepository.save(announcement);

            // Set EAV attributes for course-specific announcement
            eavService.setAnnouncementAttribute(announcement, "scope_type", "course");
            eavService.setAnnouncementAttribute(announcement, "offered_course_id", offeredCourseId.toString());
            eavService.setAnnouncementAttribute(announcement, "announcement_type", "students_only");
            eavService.setAnnouncementAttribute(announcement, "is_active", "true");
            
            if (priority != null && !priority.trim().isEmpty()) {
                eavService.setAnnouncementAttribute(announcement, "priority", priority.toLowerCase().trim());
            } else {
                eavService.setAnnouncementAttribute(announcement, "priority", "medium");
            }

            response.put("status", "success");
            response.put("message", "Announcement created successfully");
            response.put("announcementId", announcement.getAnnouncementId());

        } catch (Exception e) {
            response.put("status", "error");
            response.put("message", "Error creating announcement: " + e.getMessage());
        }

        return response;
    }

    /**
     * Get all announcements for a specific course
     * GET /api/course/announcements/{offeredCourseId}
     */
    @GetMapping("/{offeredCourseId}")
    public Map<String, Object> getCourseAnnouncements(@PathVariable Integer offeredCourseId) {
        Map<String, Object> response = new HashMap<>();

        try {
            List<Announcement> allAnnouncements = announcementRepository.findAll();
            Timestamp currentTime = new Timestamp(System.currentTimeMillis());

            List<Map<String, Object>> courseAnnouncements = allAnnouncements.stream()
                .filter(announcement -> {
                    Map<String, String> attrs = eavService.getAnnouncementAttributes(announcement.getAnnouncementId());
                    String scopeType = attrs.getOrDefault("scope_type", "global");
                    String offeredCourseIdStr = attrs.get("offered_course_id");
                    String isActive = attrs.getOrDefault("is_active", "true");
                    String expiresAtStr = attrs.get("expires_at");

                    // Must be course-specific and match the offered course
                    if (!"course".equals(scopeType)) {
                        return false;
                    }

                    if (offeredCourseIdStr == null || !offeredCourseIdStr.equals(offeredCourseId.toString())) {
                        return false;
                    }

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

                    return true;
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

            response.put("status", "success");
            response.put("data", courseAnnouncements);

        } catch (Exception e) {
            response.put("status", "error");
            response.put("message", "Error fetching announcements: " + e.getMessage());
        }

        return response;
    }

    /**
     * Delete a course announcement
     * DELETE /api/course/announcements/{announcementId}
     */
    @DeleteMapping("/{announcementId}")
    public Map<String, Object> deleteCourseAnnouncement(@PathVariable Integer announcementId) {
        Map<String, Object> response = new HashMap<>();

        try {
            Optional<Announcement> announcementOpt = announcementRepository.findById(announcementId);
            if (announcementOpt.isEmpty()) {
                response.put("status", "error");
                response.put("message", "Announcement not found");
                return response;
            }

            announcementRepository.delete(announcementOpt.get());
            response.put("status", "success");
            response.put("message", "Announcement deleted successfully");

        } catch (Exception e) {
            response.put("status", "error");
            response.put("message", "Error deleting announcement: " + e.getMessage());
        }

        return response;
    }

    private Integer parseInteger(Object obj) {
        if (obj == null) return null;
        if (obj instanceof Integer) return (Integer) obj;
        if (obj instanceof String) {
            String str = ((String) obj).trim();
            return str.isEmpty() ? null : Integer.parseInt(str);
        }
        return null;
    }
}

