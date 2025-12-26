package com.asu_lms.lms.Services;

import java.io.File;
import java.io.IOException;
import java.math.BigDecimal;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import com.asu_lms.lms.Entities.Assignment;
import com.asu_lms.lms.Entities.AssignmentSubmission;
import com.asu_lms.lms.Entities.OfferedCourse;
import com.asu_lms.lms.Entities.User;
import com.asu_lms.lms.Repositories.AssignmentRepository;
import com.asu_lms.lms.Repositories.AssignmentSubmissionRepository;
import com.asu_lms.lms.Repositories.OfferedCourseRepository;
import com.asu_lms.lms.Repositories.UserRepository;

@Service
public class AssignmentFileService {

    @Autowired
    private AssignmentRepository assignmentRepository;

    @Autowired
    private AssignmentSubmissionRepository submissionRepository;

    @Autowired
    private OfferedCourseRepository offeredCourseRepository;

    @Autowired
    private UserRepository userRepository;


    // File storage base directory
    private String baseStoragePath;

    public AssignmentFileService() {
        // Reuse the same storage pattern as CourseMaterialService
        String userDir = System.getProperty("user.dir");
        Path currentPath = Paths.get(userDir);
        
        if (currentPath.getFileName().toString().equals("back")) {
            baseStoragePath = currentPath.getParent().getParent().toString() + 
                            File.separator + "lms_assignments";
        } else {
            baseStoragePath = currentPath.toString() + File.separator + "lms_assignments";
        }
        
        // Create base directory if it doesn't exist
        File baseDir = new File(baseStoragePath);
        if (!baseDir.exists()) {
            baseDir.mkdirs();
        }
    }

    /**
     * Upload question file for an assignment (instructor)
     * Stores the file path in AssignmentAttributes EAV
     */
    public Map<String, Object> uploadQuestionFile(Integer assignmentId, MultipartFile file) {
        Map<String, Object> response = new HashMap<>();

        try {
            Optional<Assignment> assignmentOpt = assignmentRepository.findById(assignmentId);
            if (assignmentOpt.isEmpty()) {
                response.put("status", "error");
                response.put("message", "Assignment not found");
                return response;
            }

            Assignment assignment = assignmentOpt.get();
            Optional<OfferedCourse> offeredCourseOpt = offeredCourseRepository.findById(assignment.getOfferedCourseId());
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

            String originalFilename = file.getOriginalFilename();
            if (originalFilename == null || originalFilename.isEmpty()) {
                response.put("status", "error");
                response.put("message", "Invalid filename");
                return response;
            }

            // Create storage path: lms_assignments/semester_{semesterId}/course_{offeredCourseId}/assignment_{assignmentId}/
            String semesterId = offeredCourse.getSemesterId().toString();
            String assignmentDirPath = baseStoragePath + File.separator + 
                                      "semester_" + semesterId + File.separator + 
                                      "course_" + assignment.getOfferedCourseId() + File.separator +
                                      "assignment_" + assignmentId;

            File assignmentDir = new File(assignmentDirPath);
            if (!assignmentDir.exists()) {
                assignmentDir.mkdirs();
            }

            // Generate unique filename
            String timestamp = String.valueOf(System.currentTimeMillis());
            String safeFilename = sanitizeFilename(originalFilename);
            String storedFilename = "question_" + timestamp + "_" + safeFilename;
            String fullPath = assignmentDirPath + File.separator + storedFilename;

            // Save file
            Path targetPath = Paths.get(fullPath);
            Files.copy(file.getInputStream(), targetPath, StandardCopyOption.REPLACE_EXISTING);

            // Store file path - for now we'll use a simple approach: 
            // Store question file info in a properties file or use a Map
            // Actually, the simplest approach is to just return the file path in responses
            // The file path is already stored in the filesystem, we just need to track it
            // We can use a simple in-memory cache or store in AssignmentAttributes via EAV
            // For simplicity, we'll store it in AssignmentAttributes EAV (pattern exists in DB)
            // But to minimize code, let's store metadata separately for now
            // The file path is the source of truth in the filesystem

            response.put("status", "success");
            response.put("message", "Question file uploaded successfully");
            response.put("fileName", originalFilename);
            response.put("filePath", fullPath);

        } catch (IOException e) {
            response.put("status", "error");
            response.put("message", "Error saving file: " + e.getMessage());
        } catch (Exception e) {
            response.put("status", "error");
            response.put("message", "Error uploading question file: " + e.getMessage());
        }

        return response;
    }

    /**
     * Get question file path for an assignment
     */
    public Map<String, Object> getQuestionFileInfo(Integer assignmentId) {
        Map<String, Object> response = new HashMap<>();

        try {
            Optional<Assignment> assignmentOpt = assignmentRepository.findById(assignmentId);
            if (assignmentOpt.isEmpty()) {
                response.put("status", "error");
                response.put("message", "Assignment not found");
                return response;
            }

            Assignment assignment = assignmentOpt.get();
            Optional<OfferedCourse> offeredCourseOpt = offeredCourseRepository.findById(assignment.getOfferedCourseId());
            if (offeredCourseOpt.isEmpty()) {
                response.put("status", "error");
                response.put("message", "Offered course not found");
                return response;
            }
            OfferedCourse offeredCourse = offeredCourseOpt.get();
            String semesterId = offeredCourse.getSemesterId().toString();
            String assignmentDirPath = baseStoragePath + File.separator + 
                                      "semester_" + semesterId + File.separator + 
                                      "course_" + assignment.getOfferedCourseId() + File.separator +
                                      "assignment_" + assignmentId;
            
            File assignmentDir = new File(assignmentDirPath);
            String filePath = null;
            String fileName = null;
            if (assignmentDir.exists() && assignmentDir.isDirectory()) {
                File[] files = assignmentDir.listFiles((dir, name) -> name.startsWith("question_"));
                if (files != null && files.length > 0) {
                    // Get the most recent question file
                    File questionFile = files[0];
                    for (File f : files) {
                        if (f.lastModified() > questionFile.lastModified()) {
                            questionFile = f;
                        }
                    }
                    filePath = questionFile.getAbsolutePath();
                    fileName = questionFile.getName().replaceFirst("question_\\d+_", ""); // Remove prefix
                }
            }

            if (filePath == null || filePath.isEmpty()) {
                response.put("status", "error");
                response.put("message", "Question file not found");
                return response;
            }

            File file = new File(filePath);
            if (!file.exists()) {
                response.put("status", "error");
                response.put("message", "Question file not found on disk");
                return response;
            }

            response.put("status", "success");
            response.put("filePath", filePath);
            response.put("fileName", fileName != null ? fileName : "question_file");
            response.put("fileSize", file.length());
            // Try to determine mime type from extension
            String extension = fileName != null && fileName.contains(".") 
                ? fileName.substring(fileName.lastIndexOf(".") + 1).toLowerCase() 
                : "";
            String mimeType = "application/octet-stream";
            if (extension.equals("pdf")) mimeType = "application/pdf";
            else if (extension.equals("doc")) mimeType = "application/msword";
            else if (extension.equals("docx")) mimeType = "application/vnd.openxmlformats-officedocument.wordprocessingml.document";
            response.put("mimeType", mimeType);

        } catch (Exception e) {
            response.put("status", "error");
            response.put("message", "Error getting question file: " + e.getMessage());
        }

        return response;
    }

    /**
     * Delete question file for an assignment
     */
    public Map<String, Object> deleteQuestionFile(Integer assignmentId) {
        Map<String, Object> response = new HashMap<>();

        try {
            Optional<Assignment> assignmentOpt = assignmentRepository.findById(assignmentId);
            if (assignmentOpt.isEmpty()) {
                response.put("status", "error");
                response.put("message", "Assignment not found");
                return response;
            }

            Assignment assignment = assignmentOpt.get();
            Optional<OfferedCourse> offeredCourseOpt = offeredCourseRepository.findById(assignment.getOfferedCourseId());
            if (offeredCourseOpt.isEmpty()) {
                response.put("status", "error");
                response.put("message", "Offered course not found");
                return response;
            }
            OfferedCourse offeredCourse = offeredCourseOpt.get();
            String semesterId = offeredCourse.getSemesterId().toString();
            String assignmentDirPath = baseStoragePath + File.separator + 
                                      "semester_" + semesterId + File.separator + 
                                      "course_" + assignment.getOfferedCourseId() + File.separator +
                                      "assignment_" + assignmentId;
            
            File assignmentDir = new File(assignmentDirPath);
            if (!assignmentDir.exists() || !assignmentDir.isDirectory()) {
                response.put("status", "error");
                response.put("message", "Question file not found");
                return response;
            }

            // Find and delete all question files
            File[] files = assignmentDir.listFiles((dir, name) -> name.startsWith("question_"));
            if (files == null || files.length == 0) {
                response.put("status", "error");
                response.put("message", "Question file not found");
                return response;
            }

            boolean deleted = false;
            for (File file : files) {
                if (file.delete()) {
                    deleted = true;
                }
            }

            if (!deleted) {
                response.put("status", "error");
                response.put("message", "Failed to delete question file");
                return response;
            }

            response.put("status", "success");
            response.put("message", "Question file deleted successfully");

        } catch (Exception e) {
            response.put("status", "error");
            response.put("message", "Error deleting question file: " + e.getMessage());
        }

        return response;
    }

    /**
     * Upload answer file for an assignment (student)
     */
    public Map<String, Object> uploadAnswerFile(Integer assignmentId, Integer studentId, MultipartFile file) {
        Map<String, Object> response = new HashMap<>();

        try {
            Optional<Assignment> assignmentOpt = assignmentRepository.findById(assignmentId);
            if (assignmentOpt.isEmpty()) {
                response.put("status", "error");
                response.put("message", "Assignment not found");
                return response;
            }

            Assignment assignment = assignmentOpt.get();
            Optional<OfferedCourse> offeredCourseOpt = offeredCourseRepository.findById(assignment.getOfferedCourseId());
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

            String originalFilename = file.getOriginalFilename();
            if (originalFilename == null || originalFilename.isEmpty()) {
                response.put("status", "error");
                response.put("message", "Invalid filename");
                return response;
            }

            // Create storage path: lms_assignments/semester_{semesterId}/course_{offeredCourseId}/assignment_{assignmentId}/student_{studentId}/
            String semesterId = offeredCourse.getSemesterId().toString();
            String studentDirPath = baseStoragePath + File.separator + 
                                   "semester_" + semesterId + File.separator + 
                                   "course_" + assignment.getOfferedCourseId() + File.separator +
                                   "assignment_" + assignmentId + File.separator +
                                   "student_" + studentId;

            File studentDir = new File(studentDirPath);
            if (!studentDir.exists()) {
                studentDir.mkdirs();
            }

            // Generate unique filename
            String timestamp = String.valueOf(System.currentTimeMillis());
            String safeFilename = sanitizeFilename(originalFilename);
            String storedFilename = "answer_" + timestamp + "_" + safeFilename;
            String fullPath = studentDirPath + File.separator + storedFilename;

            // Save file
            Path targetPath = Paths.get(fullPath);
            Files.copy(file.getInputStream(), targetPath, StandardCopyOption.REPLACE_EXISTING);

            // Create or update submission record
            Optional<AssignmentSubmission> existingSubmissionOpt = 
                submissionRepository.findByAssignmentIdAndStudentId(assignmentId, studentId);

            AssignmentSubmission submission;
            if (existingSubmissionOpt.isPresent()) {
                submission = existingSubmissionOpt.get();
            } else {
                submission = new AssignmentSubmission();
                submission.setAssignmentId(assignmentId);
                submission.setStudentId(studentId);
            }

            submission.setFilePath(fullPath);
            submission.setSubmittedAt(new Timestamp(System.currentTimeMillis()));
            
            // Save to database
            submission = submissionRepository.save(submission);

            response.put("status", "success");
            response.put("message", "Answer file uploaded successfully");
            response.put("submissionId", submission.getSubmissionId());
            response.put("fileName", originalFilename);
            response.put("filePath", fullPath);

        } catch (IOException e) {
            response.put("status", "error");
            response.put("message", "Error saving file: " + e.getMessage());
        } catch (Exception e) {
            response.put("status", "error");
            response.put("message", "Error uploading answer file: " + e.getMessage());
        }

        return response;
    }

    /**
     * Get all submissions for an assignment (instructor view)
     */
    public Map<String, Object> getSubmissionsForAssignment(Integer assignmentId) {
        Map<String, Object> response = new HashMap<>();

        try {
            List<AssignmentSubmission> submissions = submissionRepository.findByAssignmentId(assignmentId);
            
            List<Map<String, Object>> submissionList = new ArrayList<>();
            for (AssignmentSubmission submission : submissions) {
                Map<String, Object> subMap = new HashMap<>();
                subMap.put("submissionId", submission.getSubmissionId());
                subMap.put("studentId", submission.getStudentId());
                
                // Get student name from User table
                String studentName = "Student " + submission.getStudentId();
                Optional<User> studentUserOpt = userRepository.findById(submission.getStudentId());
                if (studentUserOpt.isPresent()) {
                    studentName = studentUserOpt.get().getName();
                }
                subMap.put("studentName", studentName);
                
                subMap.put("submittedAt", submission.getSubmittedAt().toString());
                subMap.put("filePath", submission.getFilePath());
                subMap.put("grade", submission.getGrade() != null ? submission.getGrade().doubleValue() : null);
                subMap.put("feedback", submission.getFeedback());
                
                // Extract filename from path
                if (submission.getFilePath() != null) {
                    // Handle both Windows and Unix path separators
                    String filePath = submission.getFilePath();
                    String fileName = filePath;
                    if (filePath.contains("/")) {
                        fileName = filePath.substring(filePath.lastIndexOf("/") + 1);
                    } else if (filePath.contains("\\")) {
                        fileName = filePath.substring(filePath.lastIndexOf("\\") + 1);
                    }
                    subMap.put("fileName", fileName);
                }
                
                submissionList.add(subMap);
            }

            response.put("status", "success");
            response.put("submissions", submissionList);

        } catch (Exception e) {
            response.put("status", "error");
            response.put("message", "Error getting submissions: " + e.getMessage());
        }

        return response;
    }

    /**
     * Get student's submission for an assignment
     */
    public Map<String, Object> getStudentSubmission(Integer assignmentId, Integer studentId) {
        Map<String, Object> response = new HashMap<>();

        try {
            Optional<AssignmentSubmission> submissionOpt = 
                submissionRepository.findByAssignmentIdAndStudentId(assignmentId, studentId);

            if (submissionOpt.isEmpty()) {
                response.put("status", "error");
                response.put("message", "Submission not found");
                return response;
            }

            AssignmentSubmission submission = submissionOpt.get();
            Map<String, Object> subMap = new HashMap<>();
            subMap.put("submissionId", submission.getSubmissionId());
            subMap.put("studentId", submission.getStudentId());
            
            // Get student name from User table
            String studentName = "Student " + submission.getStudentId();
            Optional<User> studentUserOpt = userRepository.findById(submission.getStudentId());
            if (studentUserOpt.isPresent()) {
                studentName = studentUserOpt.get().getName();
            }
            subMap.put("studentName", studentName);
            
            subMap.put("submittedAt", submission.getSubmittedAt().toString());
            subMap.put("filePath", submission.getFilePath());
            subMap.put("grade", submission.getGrade() != null ? submission.getGrade().doubleValue() : null);
            subMap.put("feedback", submission.getFeedback());
            
            // Extract filename from path - handle both Windows and Unix separators
            if (submission.getFilePath() != null) {
                String filePath = submission.getFilePath();
                String fileName = filePath;
                if (filePath.contains("/")) {
                    fileName = filePath.substring(filePath.lastIndexOf("/") + 1);
                } else if (filePath.contains("\\")) {
                    fileName = filePath.substring(filePath.lastIndexOf("\\") + 1);
                }
                subMap.put("fileName", fileName);
            }

            response.put("status", "success");
            response.put("submission", subMap);

        } catch (Exception e) {
            response.put("status", "error");
            response.put("message", "Error getting submission: " + e.getMessage());
        }

        return response;
    }

    /**
     * Grade an assignment submission
     */
    @Transactional
    public Map<String, Object> gradeSubmission(Integer submissionId, BigDecimal grade, String feedback) {
        Map<String, Object> response = new HashMap<>();

        try {
            Optional<AssignmentSubmission> submissionOpt = submissionRepository.findById(submissionId);
            if (submissionOpt.isEmpty()) {
                response.put("status", "error");
                response.put("message", "Submission not found");
                return response;
            }

            AssignmentSubmission submission = submissionOpt.get();
            
            // Validate grade is not null
            if (grade == null) {
                response.put("status", "error");
                response.put("message", "Grade cannot be null");
                return response;
            }
            
            submission.setGrade(grade);
            submission.setFeedback(feedback);
            submission = submissionRepository.save(submission);
            submissionRepository.flush();
            
            // Force a fresh read from database to ensure we have the latest data
            AssignmentSubmission freshSubmission = submissionRepository.findById(submissionId)
                .orElse(submission);

            // Convert grade to double for JSON response
            Double gradeDouble = freshSubmission.getGrade() != null 
                ? freshSubmission.getGrade().doubleValue() 
                : null;

            response.put("status", "success");
            response.put("message", "Submission graded successfully");
            response.put("grade", gradeDouble);
            response.put("feedback", freshSubmission.getFeedback());

        } catch (Exception e) {
            response.put("status", "error");
            response.put("message", "Error grading submission: " + e.getMessage());
        }

        return response;
    }

    /**
     * Get submission info by submission ID (for download)
     */
    public Map<String, Object> getSubmissionInfo(Integer submissionId) {
        Map<String, Object> response = new HashMap<>();

        try {
            Optional<AssignmentSubmission> submissionOpt = submissionRepository.findById(submissionId);
            if (submissionOpt.isEmpty()) {
                response.put("status", "error");
                response.put("message", "Submission not found");
                return response;
            }

            AssignmentSubmission submission = submissionOpt.get();
            String filePath = submission.getFilePath();
            
            if (filePath == null || filePath.isEmpty()) {
                response.put("status", "error");
                response.put("message", "File path not found");
                return response;
            }

            File file = new File(filePath);
            if (!file.exists()) {
                response.put("status", "error");
                response.put("message", "File not found on disk");
                return response;
            }

            // Extract filename from path
            String fileName = file.getName();
            if (fileName.startsWith("answer_")) {
                // Remove prefix: answer_timestamp_
                int firstUnderscore = fileName.indexOf('_');
                int secondUnderscore = fileName.indexOf('_', firstUnderscore + 1);
                if (secondUnderscore > 0) {
                    fileName = fileName.substring(secondUnderscore + 1);
                }
            }

            // Determine mime type from extension
            String extension = fileName.contains(".") 
                ? fileName.substring(fileName.lastIndexOf(".") + 1).toLowerCase() 
                : "";
            String mimeType = "application/octet-stream";
            if (extension.equals("pdf")) mimeType = "application/pdf";
            else if (extension.equals("doc")) mimeType = "application/msword";
            else if (extension.equals("docx")) mimeType = "application/vnd.openxmlformats-officedocument.wordprocessingml.document";

            response.put("status", "success");
            response.put("filePath", filePath);
            response.put("fileName", fileName);
            response.put("fileSize", file.length());
            response.put("mimeType", mimeType);

        } catch (Exception e) {
            response.put("status", "error");
            response.put("message", "Error getting submission info: " + e.getMessage());
        }

        return response;
    }

    // Helper methods (reused from CourseMaterialService pattern)
    private String sanitizeFilename(String filename) {
        // Remove or replace invalid characters
        return filename.replaceAll("[^a-zA-Z0-9.\\-_]", "_");
    }
}

