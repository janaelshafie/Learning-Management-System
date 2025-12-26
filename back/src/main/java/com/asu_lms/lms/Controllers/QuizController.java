package com.asu_lms.lms.Controllers;

import com.asu_lms.lms.Entities.Quiz;
import com.asu_lms.lms.Entities.OfferedCourse;
import com.asu_lms.lms.Repositories.QuizRepository;
import com.asu_lms.lms.Repositories.OfferedCourseRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.sql.Timestamp;
import java.util.*;

@RestController
@RequestMapping("/api/course/quizzes")
@CrossOrigin(origins = "*")
public class QuizController {

    @Autowired
    private QuizRepository quizRepository;

    @Autowired
    private OfferedCourseRepository offeredCourseRepository;

    @Autowired
    private com.asu_lms.lms.Services.EAVService eavService;

    /**
     * Create a new quiz
     * POST /api/course/quizzes/create
     */
    @PostMapping("/create")
    public Map<String, Object> createQuiz(@RequestBody Map<String, Object> request) {
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
            eavService.initializeQuizAttributes();

            // Create quiz
            Quiz quiz = new Quiz();
            quiz.setOfferedCourseId(offeredCourseId);
            quiz.setInstructorId(instructorId);
            quiz.setTitle(title.trim());
            quiz.setDescription(description != null ? description.trim() : null);
            quiz.setDueDate(dueDate);
            quiz.setMaxGrade(maxGrade);

            Quiz savedQuiz = quizRepository.save(quiz);

            // Handle EAV attributes if provided
            @SuppressWarnings("unchecked")
            Map<String, Object> attributes = (Map<String, Object>) request.get("attributes");
            if (attributes != null) {
                for (Map.Entry<String, Object> entry : attributes.entrySet()) {
                    String attrName = entry.getKey();
                    Object attrValue = entry.getValue();
                    if (attrValue != null) {
                        eavService.setQuizAttribute(savedQuiz, attrName, attrValue.toString());
                    }
                }
            }

            response.put("status", "success");
            response.put("message", "Quiz created successfully");
            response.put("quizId", savedQuiz.getQuizId());
            response.put("quiz", convertToMap(savedQuiz));

        } catch (Exception e) {
            response.put("status", "error");
            response.put("message", "Error creating quiz: " + e.getMessage());
        }

        return response;
    }

    /**
     * Get all quizzes for a course
     * GET /api/course/quizzes/{offeredCourseId}
     */
    @GetMapping("/{offeredCourseId}")
    public Map<String, Object> getCourseQuizzes(@PathVariable Integer offeredCourseId) {
        Map<String, Object> response = new HashMap<>();

        try {
            List<Quiz> quizzes = quizRepository.findByOfferedCourseId(offeredCourseId);
            List<Map<String, Object>> quizList = new ArrayList<>();

            for (Quiz quiz : quizzes) {
                quizList.add(convertToMap(quiz));
            }

            response.put("status", "success");
            response.put("data", quizList);

        } catch (Exception e) {
            response.put("status", "error");
            response.put("message", "Error fetching quizzes: " + e.getMessage());
        }

        return response;
    }

    /**
     * Delete a quiz
     * DELETE /api/course/quizzes/{quizId}
     */
    @DeleteMapping("/{quizId}")
    public Map<String, Object> deleteQuiz(@PathVariable Integer quizId) {
        Map<String, Object> response = new HashMap<>();

        try {
            Optional<Quiz> quizOpt = quizRepository.findById(quizId);
            if (quizOpt.isEmpty()) {
                response.put("status", "error");
                response.put("message", "Quiz not found");
                return response;
            }

            quizRepository.delete(quizOpt.get());
            response.put("status", "success");
            response.put("message", "Quiz deleted successfully");

        } catch (Exception e) {
            response.put("status", "error");
            response.put("message", "Error deleting quiz: " + e.getMessage());
        }

        return response;
    }

    private Map<String, Object> convertToMap(Quiz quiz) {
        Map<String, Object> map = new HashMap<>();
        map.put("quizId", quiz.getQuizId());
        map.put("offeredCourseId", quiz.getOfferedCourseId());
        map.put("instructorId", quiz.getInstructorId());
        map.put("title", quiz.getTitle());
        map.put("description", quiz.getDescription());
        map.put("dueDate", quiz.getDueDate());
        map.put("maxGrade", quiz.getMaxGrade());
        
        // Add EAV attributes
        Map<String, String> attributes = eavService.getQuizAttributes(quiz.getQuizId());
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
        if (obj instanceof String) {
            String str = ((String) obj).trim();
            return str.isEmpty() ? defaultValue : new BigDecimal(str);
        }
        return defaultValue;
    }
}

