package com.asu_lms.lms.Controllers;

import com.asu_lms.lms.Services.CourseMaterialService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.io.FileSystemResource;
import org.springframework.core.io.Resource;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/course/materials")
@CrossOrigin(origins = "*")
public class CourseMaterialController {

    @Autowired
    private CourseMaterialService courseMaterialService;

    /**
     * Upload a course material file
     * POST /api/course/materials/upload
     */
    @PostMapping("/upload")
    public Map<String, Object> uploadMaterial(
            @RequestParam("file") MultipartFile file,
            @RequestParam("offeredCourseId") Integer offeredCourseId,
            @RequestParam(value = "instructorId", required = false) Integer instructorId,
            @RequestParam(value = "title", required = false) String title) {

        return courseMaterialService.uploadMaterial(offeredCourseId, instructorId, file, title);
    }

    /**
     * Create a course material (for links, videos, websites - no file upload)
     * POST /api/course/materials/create
     */
    @PostMapping("/create")
    public Map<String, Object> createMaterial(@RequestBody Map<String, Object> request) {
        try {
            Integer offeredCourseId = parseInteger(request.get("offeredCourseId"));
            Integer instructorId = parseInteger(request.get("instructorId"));
            String title = (String) request.get("title");
            String type = (String) request.get("type"); // 'link', 'website', 'video', etc.
            String urlOrPath = (String) request.get("urlOrPath");
            
            @SuppressWarnings("unchecked")
            Map<String, Object> attributes = (Map<String, Object>) request.get("attributes");

            if (offeredCourseId == null) {
                Map<String, Object> response = new HashMap<>();
                response.put("status", "error");
                response.put("message", "Offered course ID is required");
                return response;
            }

            if (title == null || title.trim().isEmpty()) {
                Map<String, Object> response = new HashMap<>();
                response.put("status", "error");
                response.put("message", "Title is required");
                return response;
            }

            if (type == null || type.trim().isEmpty()) {
                Map<String, Object> response = new HashMap<>();
                response.put("status", "error");
                response.put("message", "Material type is required");
                return response;
            }

            if (urlOrPath == null || urlOrPath.trim().isEmpty()) {
                Map<String, Object> response = new HashMap<>();
                response.put("status", "error");
                response.put("message", "URL or path is required");
                return response;
            }

            return courseMaterialService.createMaterial(offeredCourseId, instructorId, title, type, urlOrPath, attributes);

        } catch (Exception e) {
            Map<String, Object> response = new HashMap<>();
            response.put("status", "error");
            response.put("message", "Error creating material: " + e.getMessage());
            return response;
        }
    }

    /**
     * Helper method to parse Integer from Object
     */
    private Integer parseInteger(Object obj) {
        if (obj == null) return null;
        if (obj instanceof Integer) return (Integer) obj;
        if (obj instanceof String) {
            try {
                return Integer.parseInt((String) obj);
            } catch (NumberFormatException e) {
                return null;
            }
        }
        if (obj instanceof Number) return ((Number) obj).intValue();
        return null;
    }

    /**
     * Get all materials for a course
     * GET /api/course/materials/{offeredCourseId}
     */
    @GetMapping("/{offeredCourseId}")
    public Map<String, Object> getCourseMaterials(@PathVariable Integer offeredCourseId) {
        return courseMaterialService.getCourseMaterials(offeredCourseId);
    }

    /**
     * Download a course material file
     * GET /api/course/materials/download/{materialId}
     */
    @GetMapping("/download/{materialId}")
    public ResponseEntity<Resource> downloadMaterial(@PathVariable Integer materialId) {
        try {
            File file = courseMaterialService.getMaterialFile(materialId);
            
            if (file == null || !file.exists()) {
                return ResponseEntity.notFound().build();
            }

            Resource resource = new FileSystemResource(file);
            String contentType = "application/octet-stream";

            // Try to determine content type from file extension
            String filename = file.getName();
            if (filename.endsWith(".pdf")) {
                contentType = "application/pdf";
            } else if (filename.endsWith(".doc") || filename.endsWith(".docx")) {
                contentType = "application/msword";
            } else if (filename.endsWith(".ppt") || filename.endsWith(".pptx")) {
                contentType = "application/vnd.ms-powerpoint";
            } else if (filename.endsWith(".xls") || filename.endsWith(".xlsx")) {
                contentType = "application/vnd.ms-excel";
            }

            return ResponseEntity.ok()
                    .contentType(MediaType.parseMediaType(contentType))
                    .header(HttpHeaders.CONTENT_DISPOSITION, 
                            "attachment; filename=\"" + file.getName() + "\"")
                    .body(resource);

        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    /**
     * Delete a course material
     * DELETE /api/course/materials/{materialId}
     */
    @DeleteMapping("/{materialId}")
    public Map<String, Object> deleteMaterial(@PathVariable Integer materialId) {
        return courseMaterialService.deleteMaterial(materialId);
    }

}

