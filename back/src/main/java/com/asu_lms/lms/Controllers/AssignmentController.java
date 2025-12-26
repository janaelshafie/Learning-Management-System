package com.asu_lms.lms.Controllers;

import java.io.File;
import java.math.BigDecimal;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.io.FileSystemResource;
import org.springframework.core.io.Resource;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import com.asu_lms.lms.Entities.Assignment;
import com.asu_lms.lms.Entities.OfferedCourse;
import com.asu_lms.lms.Repositories.AssignmentRepository;
import com.asu_lms.lms.Repositories.OfferedCourseRepository;
import com.asu_lms.lms.Services.AssignmentFileService;

@RestController
@RequestMapping("/api/course/assignments")
@CrossOrigin(origins = "*")
public class AssignmentController {

    @Autowired
    private AssignmentRepository assignmentRepository;

    @Autowired
    private OfferedCourseRepository offeredCourseRepository;

    @Autowired
    private AssignmentFileService assignmentFileService;

    @Autowired
    private com.asu_lms.lms.Services.EAVService eavService;

    /**
     * Create a new assignment
     * POST /api/course/assignments/create
     */
    @PostMapping("/create")
    public Map<String, Object> createAssignment(@RequestBody Map<String, Object> request) {
        Map<String, Object> response = new HashMap<>();

        try {
            Integer offeredCourseId = parseInteger(request.get("offeredCourseId"));
            Integer instructorId = parseInteger(request.get("instructorId"));
            String title = (String) request.get("title");
            String description = (String) request.get("description");
            String dueDateStr = (String) request.get("dueDate");
            BigDecimal maxGrade = parseBigDecimal(request.get("maxGrade"), new BigDecimal("100.00"));

            // Validation
            if (offeredCourseId == null) {
                response.put("status", "error");
                response.put("message", "Offered course ID is required");
                return response;
            }

            if (title == null || title.trim().isEmpty()) {
                response.put("status", "error");
                response.put("message", "Title is required");
                return response;
            }

            if (dueDateStr == null || dueDateStr.trim().isEmpty()) {
                response.put("status", "error");
                response.put("message", "Due date is required");
                return response;
            }

            // Validate offered course exists
            Optional<OfferedCourse> offeredCourseOpt = offeredCourseRepository.findById(offeredCourseId);
            if (offeredCourseOpt.isEmpty()) {
                response.put("status", "error");
                response.put("message", "Offered course not found");
                return response;
            }

            // Parse due date
            Timestamp dueDate;
            try {
                // Handle both "yyyy-MM-dd HH:mm:ss" and "yyyy-MM-ddTHH:mm:ss" formats
                String normalizedDate = dueDateStr.replace('T', ' ');
                if (!normalizedDate.contains(":")) {
                    normalizedDate += " 23:59:59"; // Default to end of day if only date provided
                }
                dueDate = Timestamp.valueOf(normalizedDate);
            } catch (Exception e) {
                response.put("status", "error");
                response.put("message", "Invalid date format. Use yyyy-MM-dd HH:mm:ss or yyyy-MM-ddTHH:mm:ss");
                return response;
            }

            // Initialize default attributes
            eavService.initializeAssignmentAttributes();

            // Create assignment
            Assignment assignment = new Assignment();
            assignment.setOfferedCourseId(offeredCourseId);
            assignment.setInstructorId(instructorId);
            assignment.setTitle(title.trim());
            assignment.setDescription(description != null ? description.trim() : null);
            assignment.setDueDate(dueDate);
            assignment.setMaxGrade(maxGrade);

            Assignment savedAssignment = assignmentRepository.save(assignment);

            // Handle EAV attributes if provided
            @SuppressWarnings("unchecked")
            Map<String, Object> attributes = (Map<String, Object>) request.get("attributes");
            if (attributes != null) {
                for (Map.Entry<String, Object> entry : attributes.entrySet()) {
                    String attrName = entry.getKey();
                    Object attrValue = entry.getValue();
                    if (attrValue != null) {
                        eavService.setAssignmentAttribute(savedAssignment, attrName, attrValue.toString());
                    }
                }
            }

            response.put("status", "success");
            response.put("message", "Assignment created successfully");
            response.put("assignmentId", savedAssignment.getAssignmentId());
            response.put("assignment", convertToMap(savedAssignment));

        } catch (Exception e) {
            response.put("status", "error");
            response.put("message", "Error creating assignment: " + e.getMessage());
        }

        return response;
    }

    /**
     * Get all assignments for a course
     * GET /api/course/assignments/{offeredCourseId}
     */
    @GetMapping("/{offeredCourseId}")
    public Map<String, Object> getCourseAssignments(@PathVariable Integer offeredCourseId) {
        Map<String, Object> response = new HashMap<>();

        try {
            List<Assignment> assignments = assignmentRepository.findByOfferedCourseId(offeredCourseId);
            List<Map<String, Object>> assignmentList = new ArrayList<>();

            for (Assignment assignment : assignments) {
                assignmentList.add(convertToMap(assignment));
            }

            response.put("status", "success");
            response.put("data", assignmentList);

        } catch (Exception e) {
            response.put("status", "error");
            response.put("message", "Error fetching assignments: " + e.getMessage());
        }

        return response;
    }

    /**
     * Delete an assignment
     * DELETE /api/course/assignments/{assignmentId}
     */
    @DeleteMapping("/{assignmentId}")
    public Map<String, Object> deleteAssignment(@PathVariable Integer assignmentId) {
        Map<String, Object> response = new HashMap<>();

        try {
            Optional<Assignment> assignmentOpt = assignmentRepository.findById(assignmentId);
            if (assignmentOpt.isEmpty()) {
                response.put("status", "error");
                response.put("message", "Assignment not found");
                return response;
            }

            assignmentRepository.delete(assignmentOpt.get());
            response.put("status", "success");
            response.put("message", "Assignment deleted successfully");

        } catch (Exception e) {
            response.put("status", "error");
            response.put("message", "Error deleting assignment: " + e.getMessage());
        }

        return response;
    }

    private Map<String, Object> convertToMap(Assignment assignment) {
        Map<String, Object> map = new HashMap<>();
        map.put("assignmentId", assignment.getAssignmentId());
        map.put("offeredCourseId", assignment.getOfferedCourseId());
        map.put("instructorId", assignment.getInstructorId());
        map.put("title", assignment.getTitle());
        map.put("description", assignment.getDescription());
        map.put("dueDate", assignment.getDueDate());
        map.put("maxGrade", assignment.getMaxGrade());
        
        // Add EAV attributes
        Map<String, String> attributes = eavService.getAssignmentAttributes(assignment.getAssignmentId());
        for (Map.Entry<String, String> entry : attributes.entrySet()) {
            map.put(entry.getKey(), entry.getValue());
        }
        
        return map;
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

    private BigDecimal parseBigDecimal(Object obj, BigDecimal defaultValue) {
        if (obj == null) return defaultValue;
        if (obj instanceof BigDecimal) return (BigDecimal) obj;
        if (obj instanceof Double) return BigDecimal.valueOf((Double) obj);
        if (obj instanceof Integer) return BigDecimal.valueOf((Integer) obj);
        if (obj instanceof Number) return BigDecimal.valueOf(((Number) obj).doubleValue());
        if (obj instanceof String) {
            String str = ((String) obj).trim();
            return str.isEmpty() ? defaultValue : new BigDecimal(str);
        }
        return defaultValue;
    }

    /**
     * Upload question file for an assignment (instructor)
     * POST /api/course/assignments/{assignmentId}/question-file/upload
     */
    @PostMapping("/{assignmentId}/question-file/upload")
    public Map<String, Object> uploadQuestionFile(
            @PathVariable Integer assignmentId,
            @RequestParam("file") MultipartFile file) {
        return assignmentFileService.uploadQuestionFile(assignmentId, file);
    }

    /**
     * Get question file info for an assignment
     * GET /api/course/assignments/{assignmentId}/question-file
     */
    @GetMapping("/{assignmentId}/question-file")
    public Map<String, Object> getQuestionFileInfo(@PathVariable Integer assignmentId) {
        return assignmentFileService.getQuestionFileInfo(assignmentId);
    }

    /**
     * Delete question file for an assignment
     * DELETE /api/course/assignments/{assignmentId}/question-file
     */
    @DeleteMapping("/{assignmentId}/question-file")
    public Map<String, Object> deleteQuestionFile(@PathVariable Integer assignmentId) {
        return assignmentFileService.deleteQuestionFile(assignmentId);
    }

    /**
     * Download question file for an assignment
     * GET /api/course/assignments/{assignmentId}/question-file/download
     */
    @GetMapping("/{assignmentId}/question-file/download")
    public ResponseEntity<Resource> downloadQuestionFile(@PathVariable Integer assignmentId) {
        Map<String, Object> fileInfo = assignmentFileService.getQuestionFileInfo(assignmentId);
        
        if (!"success".equals(fileInfo.get("status"))) {
            return ResponseEntity.notFound().build();
        }

        String filePath = (String) fileInfo.get("filePath");
        String fileName = (String) fileInfo.get("fileName");
        
        if (filePath == null) {
            return ResponseEntity.notFound().build();
        }

        File file = new File(filePath);
        if (!file.exists()) {
            return ResponseEntity.notFound().build();
        }

        Resource resource = new FileSystemResource(file);
        String mimeType = (String) fileInfo.get("mimeType");
        if (mimeType == null) {
            mimeType = "application/octet-stream";
        }

        return ResponseEntity.ok()
                .contentType(MediaType.parseMediaType(mimeType))
                .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=\"" + fileName + "\"")
                .body(resource);
    }

    /**
     * Upload answer file for an assignment (student)
     * POST /api/course/assignments/{assignmentId}/submit
     */
    @PostMapping("/{assignmentId}/submit")
    public Map<String, Object> submitAnswerFile(
            @PathVariable Integer assignmentId,
            @RequestParam("file") MultipartFile file,
            @RequestParam("studentId") Integer studentId) {
        return assignmentFileService.uploadAnswerFile(assignmentId, studentId, file);
    }

    /**
     * Get all submissions for an assignment (instructor view)
     * GET /api/course/assignments/{assignmentId}/submissions
     */
    @GetMapping("/{assignmentId}/submissions")
    public Map<String, Object> getSubmissions(@PathVariable Integer assignmentId) {
        return assignmentFileService.getSubmissionsForAssignment(assignmentId);
    }

    /**
     * Get student's submission for an assignment
     * GET /api/course/assignments/{assignmentId}/submissions/{studentId}
     */
    @GetMapping("/{assignmentId}/submissions/{studentId}")
    public Map<String, Object> getStudentSubmission(
            @PathVariable Integer assignmentId,
            @PathVariable Integer studentId) {
        return assignmentFileService.getStudentSubmission(assignmentId, studentId);
    }

    /**
     * Download student answer file
     * GET /api/course/assignments/submissions/{submissionId}/download
     */
    @GetMapping("/submissions/{submissionId}/download")
    public ResponseEntity<Resource> downloadAnswerFile(@PathVariable Integer submissionId) {
        // We need to get submission from repository - for now return placeholder
        // This will be implemented after we check the service method
        return ResponseEntity.notFound().build();
    }

    /**
     * Grade an assignment submission
     * POST /api/course/assignments/submissions/{submissionId}/grade
     */
    @PostMapping("/submissions/{submissionId}/grade")
    public Map<String, Object> gradeSubmission(
            @PathVariable Integer submissionId,
            @RequestBody Map<String, Object> request) {
        BigDecimal grade = parseBigDecimal(request.get("grade"), null);
        String feedback = (String) request.get("feedback");
        return assignmentFileService.gradeSubmission(submissionId, grade, feedback);
    }
}

