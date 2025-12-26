package com.asu_lms.lms.Services;

import com.asu_lms.lms.Entities.*;
import com.asu_lms.lms.Repositories.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.sql.Timestamp;
import java.util.*;

import org.apache.pdfbox.pdmodel.PDDocument;
import org.apache.pdfbox.Loader;
import org.apache.poi.xslf.usermodel.XMLSlideShow;
import org.apache.poi.hslf.usermodel.HSLFSlideShow;

@Service
public class CourseMaterialService {

    @Autowired
    private CourseMaterialRepository courseMaterialRepository;

    @Autowired
    private OfferedCourseRepository offeredCourseRepository;

    @Autowired
    private CourseMaterialAttributesRepository courseMaterialAttributesRepository;

    @Autowired
    private CourseMaterialAttributeValuesRepository courseMaterialAttributeValuesRepository;

    // File storage base directory
    private String baseStoragePath;

    public CourseMaterialService(@Value("${file.upload.base-path:#{null}}") String configuredPath) {
        if (configuredPath == null || configuredPath.isEmpty()) {
            String userDir = System.getProperty("user.dir");
            Path currentPath = Paths.get(userDir);
            
            if (currentPath.getFileName().toString().equals("back")) {
                baseStoragePath = currentPath.getParent().getParent().toString() + 
                                  File.separator + "lms_course_material";
            } else {
                baseStoragePath = currentPath.toString() + File.separator + "lms_course_material";
            }
        } else {
            baseStoragePath = configuredPath;
        }
        
        File baseDir = new File(baseStoragePath);
        if (!baseDir.exists()) {
            baseDir.mkdirs();
        }
        System.out.println("Course material storage path: " + baseStoragePath);
    }

    /**
     * Initialize default course material attributes
     */
    @Transactional
    public void initializeDefaultAttributes() {
        String[][] defaultAttributes = {
            {"file_name", "text"},
            {"file_size", "int"},
            {"mime_type", "text"},
            {"link_url", "text"},
            {"link_description", "text"},
            {"duration_minutes", "decimal"},
            {"video_format", "text"},
            {"page_count", "int"},
            {"slide_count", "int"},
            {"language", "text"}
        };

        for (String[] attr : defaultAttributes) {
            courseMaterialAttributesRepository.findByAttributeName(attr[0])
                .orElseGet(() -> {
                    CourseMaterialAttributes cma = new CourseMaterialAttributes(attr[0], attr[1]);
                    return courseMaterialAttributesRepository.save(cma);
                });
        }
    }

    /**
     * Get material attributes as a map
     */
    public Map<String, String> getMaterialAttributes(CourseMaterial material) {
        Map<String, String> attributes = new HashMap<>();
        List<CourseMaterialAttributeValues> values = courseMaterialAttributeValuesRepository
            .findByMaterial_MaterialId(material.getMaterialId());
        for (CourseMaterialAttributeValues cmav : values) {
            attributes.put(cmav.getAttribute().getAttributeName(), cmav.getValue());
        }
        return attributes;
    }

    /**
     * Set a material attribute
     */
    @Transactional
    public void setMaterialAttribute(CourseMaterial material, String attributeName, String value) {
        CourseMaterialAttributes attribute = courseMaterialAttributesRepository.findByAttributeName(attributeName)
            .orElseGet(() -> {
                CourseMaterialAttributes cma = new CourseMaterialAttributes(attributeName, "text");
                return courseMaterialAttributesRepository.save(cma);
            });

        Optional<CourseMaterialAttributeValues> existing = courseMaterialAttributeValuesRepository
            .findByMaterial_MaterialIdAndAttribute_AttributeName(material.getMaterialId(), attributeName);

        if (existing.isPresent()) {
            existing.get().setValue(value);
            courseMaterialAttributeValuesRepository.save(existing.get());
        } else {
            CourseMaterialAttributeValues cmav = new CourseMaterialAttributeValues(material, attribute, value);
            courseMaterialAttributeValuesRepository.save(cmav);
        }
    }

    /**
     * Upload a course material (file upload)
     */
    @Transactional
    public Map<String, Object> uploadMaterial(Integer offeredCourseId, Integer instructorId, 
                                              MultipartFile file, String title) {
        Map<String, Object> response = new HashMap<>();

        try {
            initializeDefaultAttributes();

            Optional<OfferedCourse> offeredCourseOpt = offeredCourseRepository.findById(offeredCourseId);
            if (offeredCourseOpt.isEmpty()) {
                response.put("status", "error");
                response.put("message", "Offered course not found");
                return response;
            }

            OfferedCourse offeredCourse = offeredCourseOpt.get();

            if (file == null || file.isEmpty()) {
                response.put("status", "error");
                response.put("message", "File is empty");
                return response;
            }

            String originalFilename = file.getOriginalFilename();
            if (originalFilename == null || originalFilename.isEmpty()) {
                response.put("status", "error");
                response.put("message", "Invalid filename");
                return response;
            }

            String extension = getFileExtension(originalFilename);
            String materialType = determineFileType(extension);
            String mimeType = file.getContentType();

            // Save file to filesystem
            String semesterId = offeredCourse.getSemesterId().toString();
            String courseDirPath = baseStoragePath + File.separator + 
                                  "semester_" + semesterId + File.separator + 
                                  "course_" + offeredCourseId;

            File courseDir = new File(courseDirPath);
            if (!courseDir.exists()) {
                courseDir.mkdirs();
            }

            String timestamp = String.valueOf(System.currentTimeMillis());
            String safeFilename = sanitizeFilename(originalFilename);
            String storedFilename = timestamp + "_" + safeFilename;
            String fullPath = courseDirPath + File.separator + storedFilename;

            Path targetPath = Paths.get(fullPath);
            Files.copy(file.getInputStream(), targetPath, StandardCopyOption.REPLACE_EXISTING);

            // Create CourseMaterial entity
            CourseMaterial material = new CourseMaterial();
            material.setOfferedCourseId(offeredCourseId);
            material.setInstructorId(instructorId);
            material.setTitle(title != null && !title.isEmpty() ? title : originalFilename);
            material.setType(materialType);
            material.setUrlOrPath(fullPath);
            material.setUploadedAt(new Timestamp(System.currentTimeMillis()));

            CourseMaterial savedMaterial = courseMaterialRepository.save(material);

            // Store metadata in EAV
            setMaterialAttribute(savedMaterial, "file_name", originalFilename);
            setMaterialAttribute(savedMaterial, "file_size", String.valueOf(file.getSize()));
            if (mimeType != null) {
                setMaterialAttribute(savedMaterial, "mime_type", mimeType);
            }

            // Extract metadata based on file type
            try {
                if (materialType.equals("pdf")) {
                    int pageCount = extractPDFPageCount(fullPath);
                    if (pageCount > 0) {
                        setMaterialAttribute(savedMaterial, "page_count", String.valueOf(pageCount));
                    }
                } else if (materialType.equals("powerpoint")) {
                    int slideCount = extractPowerPointSlideCount(fullPath, extension);
                    if (slideCount > 0) {
                        setMaterialAttribute(savedMaterial, "slide_count", String.valueOf(slideCount));
                    }
                } else if (materialType.equals("video")) {
                    // Extract video format from extension
                    setMaterialAttribute(savedMaterial, "video_format", extension);
                }
            } catch (Exception e) {
                // Log but don't fail the upload if metadata extraction fails
                System.err.println("Warning: Failed to extract metadata: " + e.getMessage());
            }

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
     * Create a course material (for links, videos, etc. - no file upload)
     */
    @Transactional
    public Map<String, Object> createMaterial(Integer offeredCourseId, Integer instructorId, 
                                              String title, String type, String urlOrPath,
                                              Map<String, Object> attributes) {
        Map<String, Object> response = new HashMap<>();

        try {
            initializeDefaultAttributes();

            Optional<OfferedCourse> offeredCourseOpt = offeredCourseRepository.findById(offeredCourseId);
            if (offeredCourseOpt.isEmpty()) {
                response.put("status", "error");
                response.put("message", "Offered course not found");
                return response;
            }

            if (title == null || title.trim().isEmpty()) {
                response.put("status", "error");
                response.put("message", "Title is required");
                return response;
            }

            if (type == null || type.trim().isEmpty()) {
                response.put("status", "error");
                response.put("message", "Material type is required");
                return response;
            }

            if (urlOrPath == null || urlOrPath.trim().isEmpty()) {
                response.put("status", "error");
                response.put("message", "URL or path is required");
                return response;
            }

            // Create CourseMaterial entity
            CourseMaterial material = new CourseMaterial();
            material.setOfferedCourseId(offeredCourseId);
            material.setInstructorId(instructorId);
            material.setTitle(title.trim());
            material.setType(type.trim());
            material.setUrlOrPath(urlOrPath.trim());
            material.setUploadedAt(new Timestamp(System.currentTimeMillis()));

            CourseMaterial savedMaterial = courseMaterialRepository.save(material);

            // Store attributes in EAV
            if (attributes != null) {
                for (Map.Entry<String, Object> entry : attributes.entrySet()) {
                    String attrName = entry.getKey();
                    Object attrValue = entry.getValue();
                    if (attrValue != null && !attrValue.toString().trim().isEmpty()) {
                        setMaterialAttribute(savedMaterial, attrName, attrValue.toString());
                    }
                }
            }

            // For video type, extract format from URL if not provided
            if (type.equals("video") && attributes != null && !attributes.containsKey("video_format")) {
                String videoFormat = extractVideoFormatFromUrl(urlOrPath);
                if (videoFormat != null && !videoFormat.isEmpty()) {
                    setMaterialAttribute(savedMaterial, "video_format", videoFormat);
                }
            }

            response.put("status", "success");
            response.put("message", "Material created successfully");
            response.put("materialId", savedMaterial.getMaterialId());
            response.put("material", convertToMap(savedMaterial));

        } catch (Exception e) {
            response.put("status", "error");
            response.put("message", "Error creating material: " + e.getMessage());
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
    @Transactional
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

            // Delete file from filesystem if it's a file (not a link)
            if (!material.getType().equals("link") && !material.getType().equals("website")) {
                File file = new File(material.getUrlOrPath());
                if (file.exists()) {
                    file.delete();
                }
            }

            // Delete from database (EAV values will be deleted by cascade)
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
            CourseMaterial material = materialOpt.get();
            // Only return file if it's not a link/website
            if (!material.getType().equals("link") && !material.getType().equals("website")) {
                File file = new File(material.getUrlOrPath());
                if (file.exists()) {
                    return file;
                }
            }
        }
        return null;
    }

    /**
     * Convert CourseMaterial entity to Map for JSON response (with EAV attributes)
     */
    private Map<String, Object> convertToMap(CourseMaterial material) {
        Map<String, Object> map = new HashMap<>();
        map.put("materialId", material.getMaterialId());
        map.put("offeredCourseId", material.getOfferedCourseId());
        map.put("instructorId", material.getInstructorId());
        map.put("title", material.getTitle());
        map.put("type", material.getType());
        map.put("urlOrPath", material.getUrlOrPath());
        map.put("uploadedAt", material.getUploadedAt().toString());

        // Add EAV attributes
        Map<String, String> attributes = getMaterialAttributes(material);
        for (Map.Entry<String, String> entry : attributes.entrySet()) {
            map.put(entry.getKey(), entry.getValue());
        }

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
                return "powerpoint";
            case "xls":
            case "xlsx":
                return "file";
            case "txt":
                return "file";
            case "jpg":
            case "jpeg":
            case "png":
            case "gif":
            case "bmp":
            case "webp":
                return "image";
            case "mp4":
            case "avi":
            case "mov":
            case "wmv":
            case "flv":
            case "webm":
            case "mkv":
                return "video";
            case "mp3":
            case "wav":
            case "ogg":
            case "m4a":
                return "audio";
            default:
                return "file";
        }
    }

    /**
     * Sanitize filename to remove unsafe characters
     */
    private String sanitizeFilename(String filename) {
        return filename.replaceAll("[^a-zA-Z0-9._-]", "_");
    }

    /**
     * Extract page count from PDF file
     */
    private int extractPDFPageCount(String filePath) {
        PDDocument document = null;
        try {
            document = Loader.loadPDF(new File(filePath));
            return document.getNumberOfPages();
        } catch (IOException e) {
            System.err.println("Error extracting PDF page count: " + e.getMessage());
            return 0;
        } finally {
            if (document != null) {
                try {
                    document.close();
                } catch (IOException e) {
                    // Ignore close errors
                }
            }
        }
    }

    /**
     * Extract slide count from PowerPoint file
     */
    private int extractPowerPointSlideCount(String filePath, String extension) {
        FileInputStream fis = null;
        XMLSlideShow xmlSlideShow = null;
        HSLFSlideShow hslfSlideShow = null;
        try {
            if (extension.equalsIgnoreCase("pptx")) {
                // New format (PPTX)
                fis = new FileInputStream(filePath);
                xmlSlideShow = new XMLSlideShow(fis);
                return xmlSlideShow.getSlides().size();
            } else if (extension.equalsIgnoreCase("ppt")) {
                // Old format (PPT)
                fis = new FileInputStream(filePath);
                hslfSlideShow = new HSLFSlideShow(fis);
                return hslfSlideShow.getSlides().size();
            }
        } catch (IOException e) {
            System.err.println("Error extracting PowerPoint slide count: " + e.getMessage());
            return 0;
        } finally {
            try {
                if (fis != null) fis.close();
                if (xmlSlideShow != null) xmlSlideShow.close();
                if (hslfSlideShow != null) hslfSlideShow.close();
            } catch (IOException e) {
                // Ignore close errors
            }
        }
        return 0;
    }

    /**
     * Extract video format from URL (e.g., YouTube, Vimeo, or file extension)
     */
    private String extractVideoFormatFromUrl(String url) {
        if (url == null || url.isEmpty()) {
            return null;
        }

        // Check if it's a YouTube URL
        if (url.contains("youtube.com") || url.contains("youtu.be")) {
            return "youtube";
        }

        // Check if it's a Vimeo URL
        if (url.contains("vimeo.com")) {
            return "vimeo";
        }

        // Try to extract from file extension if it's a direct file URL
        int lastDot = url.lastIndexOf('.');
        int lastSlash = Math.max(url.lastIndexOf('/'), url.lastIndexOf('\\'));
        if (lastDot > lastSlash && lastDot < url.length() - 1) {
            String ext = url.substring(lastDot + 1).toLowerCase();
            if (ext.equals("mp4") || ext.equals("avi") || ext.equals("mov") || 
                ext.equals("wmv") || ext.equals("flv") || ext.equals("webm") || 
                ext.equals("mkv")) {
                return ext;
            }
        }

        return null;
    }
}
