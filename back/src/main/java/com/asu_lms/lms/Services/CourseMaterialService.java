package com.asu_lms.lms.Services;

import com.asu_lms.lms.Entities.CourseMaterial;
import com.asu_lms.lms.Entities.OfferedCourse;
import com.asu_lms.lms.Repositories.CourseMaterialRepository;
import com.asu_lms.lms.Repositories.OfferedCourseRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.sql.Timestamp;
import java.util.*;

@Service
public class CourseMaterialService {

    @Autowired
    private CourseMaterialRepository courseMaterialRepository;

    @Autowired
    private OfferedCourseRepository offeredCourseRepository;

    // File storage base directory - will be set relative to project folder
    private String baseStoragePath;

    public CourseMaterialService(@Value("${file.upload.base-path:#{null}}") String configuredPath) {
        if (configuredPath == null || configuredPath.isEmpty()) {
            // Default: create lms_course_material folder next to Learning-Management-System
            String userDir = System.getProperty("user.dir");
            Path currentPath = Paths.get(userDir);
            
            // If running from back folder, go up to project root (next to Learning-Management-System)
            if (currentPath.getFileName().toString().equals("back")) {
                // Go up: back -> Learning-Management-System -> Project root
                baseStoragePath = currentPath.getParent().getParent().toString() + 
                                  File.separator + "lms_course_material";
            } else {
                // If running from project root or Learning-Management-System
                baseStoragePath = currentPath.toString() + File.separator + "lms_course_material";
            }
        } else {
            baseStoragePath = configuredPath;
        }
        
        // Create base directory if it doesn't exist
        File baseDir = new File(baseStoragePath);
        if (!baseDir.exists()) {
            boolean created = baseDir.mkdirs();
            if (created) {
                System.out.println("Created course material storage directory: " + baseStoragePath);
            }
        }
        System.out.println("Course material storage path: " + baseStoragePath);
    }

    public String getBaseStoragePath() {
        return baseStoragePath;
    }

    /**
     * Upload a course material file
     */
    public Map<String, Object> uploadMaterial(Integer offeredCourseId, Integer instructorId, 
                                              MultipartFile file, String title) {
        Map<String, Object> response = new HashMap<>();

        try {
            // Validate offered course exists
            Optional<OfferedCourse> offeredCourseOpt = offeredCourseRepository.findById(offeredCourseId);
            if (offeredCourseOpt.isEmpty()) {
                response.put("status", "error");
                response.put("message", "Offered course not found");
                return response;
            }

            OfferedCourse offeredCourse = offeredCourseOpt.get();

            // Validate file
            if (file == null || file.isEmpty()) {
                response.put("status", "error");
                response.put("message", "File is empty");
                return response;
            }

            // Get file extension and determine type
            String originalFilename = file.getOriginalFilename();
            if (originalFilename == null || originalFilename.isEmpty()) {
                response.put("status", "error");
                response.put("message", "Invalid filename");
                return response;
            }

            String extension = getFileExtension(originalFilename);
            String fileType = determineFileType(extension);
            String mimeType = file.getContentType();

            // Create storage path: lms_course_material/semester_{semesterId}/course_{offeredCourseId}/
            String semesterId = offeredCourse.getSemesterId().toString();
            String courseDirPath = baseStoragePath + File.separator + 
                                  "semester_" + semesterId + File.separator + 
                                  "course_" + offeredCourseId;

            File courseDir = new File(courseDirPath);
            if (!courseDir.exists()) {
                courseDir.mkdirs();
            }

            // Generate unique filename to avoid conflicts
            String timestamp = String.valueOf(System.currentTimeMillis());
            String safeFilename = sanitizeFilename(originalFilename);
            String storedFilename = timestamp + "_" + safeFilename;
            String fullPath = courseDirPath + File.separator + storedFilename;

            // Save file
            Path targetPath = Paths.get(fullPath);
            Files.copy(file.getInputStream(), targetPath, StandardCopyOption.REPLACE_EXISTING);

            // Create CourseMaterial entity
            CourseMaterial material = new CourseMaterial();
            material.setOfferedCourseId(offeredCourseId);
            material.setInstructorId(instructorId);
            material.setTitle(title != null && !title.isEmpty() ? title : originalFilename);
            material.setFileName(originalFilename);
            material.setFileSize(file.getSize());
            material.setMimeType(mimeType);
            material.setType(fileType);
            material.setUrlOrPath(fullPath);
            material.setUploadedAt(new Timestamp(System.currentTimeMillis()));

            CourseMaterial savedMaterial = courseMaterialRepository.save(material);

            response.put("status", "success");
            response.put("message", "File uploaded successfully");
            response.put("materialId", savedMaterial.getMaterialId());
            response.put("material", convertToMap(savedMaterial));

        } catch (IOException e) {
            response.put("status", "error");
            response.put("message", "Error saving file: " + e.getMessage());
        } catch (Exception e) {
            response.put("status", "error");
            response.put("message", "Error uploading material: " + e.getMessage());
        }

        return response;
    }

    /**
     * Get all materials for a course
     */
    public Map<String, Object> getCourseMaterials(Integer offeredCourseId) {
        Map<String, Object> response = new HashMap<>();

        try {
            List<CourseMaterial> materials = courseMaterialRepository.findByOfferedCourseId(offeredCourseId);
            List<Map<String, Object>> materialList = new ArrayList<>();

            for (CourseMaterial material : materials) {
                materialList.add(convertToMap(material));
            }

            response.put("status", "success");
            response.put("data", materialList);

        } catch (Exception e) {
            response.put("status", "error");
            response.put("message", "Error fetching materials: " + e.getMessage());
        }

        return response;
    }

    /**
     * Delete a course material
     */
    public Map<String, Object> deleteMaterial(Integer materialId) {
        Map<String, Object> response = new HashMap<>();

        try {
            Optional<CourseMaterial> materialOpt = courseMaterialRepository.findById(materialId);
            if (materialOpt.isEmpty()) {
                response.put("status", "error");
                response.put("message", "Material not found");
                return response;
            }

            CourseMaterial material = materialOpt.get();

            // Delete file from filesystem
            File file = new File(material.getUrlOrPath());
            if (file.exists()) {
                file.delete();
            }

            // Delete from database
            courseMaterialRepository.delete(material);

            response.put("status", "success");
            response.put("message", "Material deleted successfully");

        } catch (Exception e) {
            response.put("status", "error");
            response.put("message", "Error deleting material: " + e.getMessage());
        }

        return response;
    }

    /**
     * Get material file for download
     */
    public File getMaterialFile(Integer materialId) {
        Optional<CourseMaterial> materialOpt = courseMaterialRepository.findById(materialId);
        if (materialOpt.isPresent()) {
            File file = new File(materialOpt.get().getUrlOrPath());
            if (file.exists()) {
                return file;
            }
        }
        return null;
    }

    /**
     * Convert CourseMaterial entity to Map for JSON response
     */
    private Map<String, Object> convertToMap(CourseMaterial material) {
        Map<String, Object> map = new HashMap<>();
        map.put("materialId", material.getMaterialId());
        map.put("offeredCourseId", material.getOfferedCourseId());
        map.put("instructorId", material.getInstructorId());
        map.put("title", material.getTitle());
        map.put("fileName", material.getFileName());
        map.put("fileSize", material.getFileSize());
        map.put("mimeType", material.getMimeType());
        map.put("type", material.getType());
        map.put("urlOrPath", material.getUrlOrPath());
        map.put("uploadedAt", material.getUploadedAt());
        return map;
    }

    /**
     * Get file extension from filename
     */
    private String getFileExtension(String filename) {
        int lastDot = filename.lastIndexOf('.');
        if (lastDot > 0 && lastDot < filename.length() - 1) {
            return filename.substring(lastDot + 1).toLowerCase();
        }
        return "";
    }

    /**
     * Determine file type based on extension
     */
    private String determineFileType(String extension) {
        switch (extension.toLowerCase()) {
            case "pdf":
                return "pdf";
            case "doc":
            case "docx":
                return "document";
            case "ppt":
            case "pptx":
                return "file";
            case "xls":
            case "xlsx":
                return "file";
            case "txt":
                return "file";
            case "jpg":
            case "jpeg":
            case "png":
            case "gif":
                return "file";
            default:
                return "file";
        }
    }

    /**
     * Sanitize filename to remove unsafe characters
     */
    private String sanitizeFilename(String filename) {
        // Remove or replace unsafe characters
        return filename.replaceAll("[^a-zA-Z0-9._-]", "_");
    }
}

