package com.asu_lms.lms.Controllers;

import com.asu_lms.lms.Services.QuestionService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.util.*;

@RestController
@RequestMapping("/api/questions")
@CrossOrigin(origins = "*")
public class QuestionController {

    @Autowired
    private QuestionService questionService;

    /**
     * Create a question
     * POST /api/questions/create
     */
    @PostMapping("/create")
    public Map<String, Object> createQuestion(@RequestBody Map<String, Object> request) {
        Map<String, Object> response = new HashMap<>();

        try {
            String assessmentType = (String) request.get("assessmentType"); // "quiz" or "assignment"
            Integer assessmentId = parseInteger(request.get("assessmentId"));
            String questionText = (String) request.get("questionText");
            String questionType = (String) request.get("questionType"); // "MCQ", "TRUE_FALSE", "SHORT_TEXT"
            Integer questionOrder = parseInteger(request.get("questionOrder"));

            // Validation
            if (assessmentType == null || (!assessmentType.equals("quiz") && !assessmentType.equals("assignment"))) {
                response.put("status", "error");
                response.put("message", "Invalid assessment type. Must be 'quiz' or 'assignment'");
                return response;
            }

            if (assessmentId == null) {
                response.put("status", "error");
                response.put("message", "Assessment ID is required");
                return response;
            }

            if (questionText == null || questionText.trim().isEmpty()) {
                response.put("status", "error");
                response.put("message", "Question text is required");
                return response;
            }

            if (questionType == null || (!questionType.equals("MCQ") && !questionType.equals("TRUE_FALSE") 
                    && !questionType.equals("SHORT_TEXT"))) {
                response.put("status", "error");
                response.put("message", "Invalid question type. Must be 'MCQ', 'TRUE_FALSE', or 'SHORT_TEXT'");
                return response;
            }

            // Extract attributes
            Map<String, Object> attributes = new HashMap<>();
            if (request.containsKey("maxMarks")) {
                attributes.put("maxMarks", request.get("maxMarks"));
            }

            // Question type specific attributes
            if ("MCQ".equals(questionType)) {
                if (request.containsKey("options") && request.get("options") instanceof List) {
                    attributes.put("options", request.get("options"));
                }
                if (request.containsKey("correctAnswer")) {
                    attributes.put("correctAnswer", request.get("correctAnswer"));
                }
            } else if ("TRUE_FALSE".equals(questionType) || "SHORT_TEXT".equals(questionType)) {
                if (request.containsKey("correctAnswer")) {
                    attributes.put("correctAnswer", request.get("correctAnswer"));
                }
            }

            // Create question
            var question = questionService.createQuestion(
                assessmentType, assessmentId, questionText, questionType, questionOrder, attributes
            );

            // Get full question data with attributes
            Map<String, Object> questionData = questionService.getQuestionWithAttributes(question.getQuestionId());

            response.put("status", "success");
            response.put("message", "Question created successfully");
            response.put("question", questionData);

        } catch (Exception e) {
            response.put("status", "error");
            response.put("message", "Error creating question: " + e.getMessage());
        }

        return response;
    }

    /**
     * Update a question
     * PUT /api/questions/{questionId}
     */
    @PutMapping("/{questionId}")
    public Map<String, Object> updateQuestion(@PathVariable Integer questionId,
                                              @RequestBody Map<String, Object> request) {
        Map<String, Object> response = new HashMap<>();

        try {
            String questionText = (String) request.get("questionText");
            Integer questionOrder = parseInteger(request.get("questionOrder"));

            // Extract attributes
            Map<String, Object> attributes = new HashMap<>();
            if (request.containsKey("maxMarks")) {
                attributes.put("maxMarks", request.get("maxMarks"));
            }
            if (request.containsKey("options") && request.get("options") instanceof List) {
                attributes.put("options", request.get("options"));
            }
            if (request.containsKey("correctAnswer")) {
                attributes.put("correctAnswer", request.get("correctAnswer"));
            }

            var question = questionService.updateQuestion(questionId, questionText, questionOrder, attributes);

            // Get full question data with attributes
            Map<String, Object> questionData = questionService.getQuestionWithAttributes(question.getQuestionId());

            response.put("status", "success");
            response.put("message", "Question updated successfully");
            response.put("question", questionData);

        } catch (Exception e) {
            response.put("status", "error");
            response.put("message", "Error updating question: " + e.getMessage());
        }

        return response;
    }

    /**
     * Get a question by ID
     * GET /api/questions/{questionId}
     */
    @GetMapping("/{questionId}")
    public Map<String, Object> getQuestion(@PathVariable Integer questionId) {
        Map<String, Object> response = new HashMap<>();

        try {
            Map<String, Object> questionData = questionService.getQuestionWithAttributes(questionId);
            if (questionData == null) {
                response.put("status", "error");
                response.put("message", "Question not found");
            } else {
                response.put("status", "success");
                response.put("question", questionData);
            }
        } catch (Exception e) {
            response.put("status", "error");
            response.put("message", "Error getting question: " + e.getMessage());
        }

        return response;
    }

    /**
     * Get all questions for a quiz/assignment
     * GET /api/questions/assessment/{assessmentType}/{assessmentId}
     */
    @GetMapping("/assessment/{assessmentType}/{assessmentId}")
    public Map<String, Object> getQuestionsForAssessment(@PathVariable String assessmentType,
                                                         @PathVariable Integer assessmentId) {
        Map<String, Object> response = new HashMap<>();

        try {
            List<Map<String, Object>> questions = questionService.getQuestionsForAssessment(assessmentType, assessmentId);
            response.put("status", "success");
            response.put("questions", questions);
        } catch (Exception e) {
            response.put("status", "error");
            response.put("message", "Error getting questions: " + e.getMessage());
        }

        return response;
    }

    /**
     * Delete a question
     * DELETE /api/questions/{questionId}
     */
    @DeleteMapping("/{questionId}")
    public Map<String, Object> deleteQuestion(@PathVariable Integer questionId) {
        Map<String, Object> response = new HashMap<>();

        try {
            questionService.deleteQuestion(questionId);
            response.put("status", "success");
            response.put("message", "Question deleted successfully");
        } catch (Exception e) {
            response.put("status", "error");
            response.put("message", "Error deleting question: " + e.getMessage());
        }

        return response;
    }

    // Helper method
    private Integer parseInteger(Object obj) {
        if (obj == null) return null;
        if (obj instanceof Integer) return (Integer) obj;
        if (obj instanceof Number) return ((Number) obj).intValue();
        try {
            return Integer.parseInt(obj.toString());
        } catch (NumberFormatException e) {
            return null;
        }
    }
}

