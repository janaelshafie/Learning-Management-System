package com.asu_lms.lms.Controllers;

import com.asu_lms.lms.Services.StudentAnswerService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.util.*;

@RestController
@RequestMapping("/api/student-answers")
@CrossOrigin(origins = "*")
public class StudentAnswerController {

    @Autowired
    private StudentAnswerService studentAnswerService;

    /**
     * Submit an answer for a question
     * POST /api/student-answers/submit
     */
    @PostMapping("/submit")
    public Map<String, Object> submitAnswer(@RequestBody Map<String, Object> request) {
        Map<String, Object> response = new HashMap<>();

        try {
            Integer studentId = parseInteger(request.get("studentId"));
            Integer questionId = parseInteger(request.get("questionId"));
            String questionType = (String) request.get("questionType");

            // Validation
            if (studentId == null) {
                response.put("status", "error");
                response.put("message", "Student ID is required");
                return response;
            }

            if (questionId == null) {
                response.put("status", "error");
                response.put("message", "Question ID is required");
                return response;
            }

            if (questionType == null) {
                response.put("status", "error");
                response.put("message", "Question type is required");
                return response;
            }

            // Extract answer data
            Map<String, Object> answerData = new HashMap<>();
            if (request.containsKey("selectedOption")) {
                answerData.put("selectedOption", request.get("selectedOption"));
            }
            if (request.containsKey("answer")) {
                answerData.put("answer", request.get("answer"));
            }

            var studentAnswer = studentAnswerService.submitAnswer(studentId, questionId, questionType, answerData);

            // Get full answer data with attributes
            Map<String, Object> answerDataFull = studentAnswerService.getStudentAnswerWithAttributes(
                studentAnswer.getStudentAnswerId());

            response.put("status", "success");
            response.put("message", "Answer submitted successfully");
            response.put("studentAnswer", answerDataFull);

        } catch (Exception e) {
            response.put("status", "error");
            response.put("message", "Error submitting answer: " + e.getMessage());
        }

        return response;
    }

    /**
     * Grade a student answer (instructor reviews and sets grade/feedback)
     * PUT /api/student-answers/{studentAnswerId}/grade
     */
    @PutMapping("/{studentAnswerId}/grade")
    public Map<String, Object> gradeAnswer(@PathVariable Integer studentAnswerId,
                                           @RequestBody Map<String, Object> request) {
        Map<String, Object> response = new HashMap<>();

        try {
            BigDecimal grade = parseBigDecimal(request.get("grade"));
            String feedback = (String) request.get("feedback");

            if (grade == null) {
                response.put("status", "error");
                response.put("message", "Grade is required");
                return response;
            }

            var studentAnswer = studentAnswerService.gradeAnswer(studentAnswerId, grade, feedback);

            // Get full answer data
            Map<String, Object> answerData = studentAnswerService.getStudentAnswerWithAttributes(
                studentAnswer.getStudentAnswerId());

            response.put("status", "success");
            response.put("message", "Answer graded successfully");
            response.put("studentAnswer", answerData);

        } catch (Exception e) {
            response.put("status", "error");
            response.put("message", "Error grading answer: " + e.getMessage());
        }

        return response;
    }

    /**
     * Get a student answer by ID
     * GET /api/student-answers/{studentAnswerId}
     */
    @GetMapping("/{studentAnswerId}")
    public Map<String, Object> getStudentAnswer(@PathVariable Integer studentAnswerId) {
        Map<String, Object> response = new HashMap<>();

        try {
            Map<String, Object> answerData = studentAnswerService.getStudentAnswerWithAttributes(studentAnswerId);
            if (answerData == null) {
                response.put("status", "error");
                response.put("message", "Student answer not found");
            } else {
                response.put("status", "success");
                response.put("studentAnswer", answerData);
            }
        } catch (Exception e) {
            response.put("status", "error");
            response.put("message", "Error getting student answer: " + e.getMessage());
        }

        return response;
    }

    /**
     * Get all answers for a quiz/assignment (for instructor to review)
     * GET /api/student-answers/assessment/{assessmentType}/{assessmentId}
     */
    @GetMapping("/assessment/{assessmentType}/{assessmentId}")
    public Map<String, Object> getAnswersForAssessment(@PathVariable String assessmentType,
                                                       @PathVariable Integer assessmentId) {
        Map<String, Object> response = new HashMap<>();

        try {
            List<Map<String, Object>> answers = studentAnswerService.getAnswersForAssessment(
                assessmentId, assessmentType);
            response.put("status", "success");
            response.put("answers", answers);
        } catch (Exception e) {
            response.put("status", "error");
            response.put("message", "Error getting answers: " + e.getMessage());
        }

        return response;
    }

    /**
     * Get all answers for a student for a quiz/assignment
     * GET /api/student-answers/student/{studentId}/assessment/{assessmentType}/{assessmentId}
     */
    @GetMapping("/student/{studentId}/assessment/{assessmentType}/{assessmentId}")
    public Map<String, Object> getStudentAnswersForAssessment(@PathVariable Integer studentId,
                                                              @PathVariable String assessmentType,
                                                              @PathVariable Integer assessmentId) {
        Map<String, Object> response = new HashMap<>();

        try {
            List<Map<String, Object>> answers = studentAnswerService.getStudentAnswersForAssessment(
                studentId, assessmentId, assessmentType);
            response.put("status", "success");
            response.put("answers", answers);
        } catch (Exception e) {
            response.put("status", "error");
            response.put("message", "Error getting student answers: " + e.getMessage());
        }

        return response;
    }

    /**
     * Get all answers for a specific question (for instructor to review)
     * GET /api/student-answers/question/{questionId}
     */
    @GetMapping("/question/{questionId}")
    public Map<String, Object> getAnswersForQuestion(@PathVariable Integer questionId) {
        Map<String, Object> response = new HashMap<>();

        try {
            List<Map<String, Object>> answers = studentAnswerService.getAnswersForQuestion(questionId);
            response.put("status", "success");
            response.put("answers", answers);
        } catch (Exception e) {
            response.put("status", "error");
            response.put("message", "Error getting answers: " + e.getMessage());
        }

        return response;
    }

    // Helper methods
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

    private BigDecimal parseBigDecimal(Object obj) {
        if (obj == null) return null;
        if (obj instanceof BigDecimal) return (BigDecimal) obj;
        if (obj instanceof Number) return BigDecimal.valueOf(((Number) obj).doubleValue());
        try {
            return new BigDecimal(obj.toString());
        } catch (NumberFormatException e) {
            return null;
        }
    }
}

