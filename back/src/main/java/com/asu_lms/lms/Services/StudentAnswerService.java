package com.asu_lms.lms.Services;

import com.asu_lms.lms.Entities.*;
import com.asu_lms.lms.Repositories.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.sql.Timestamp;
import java.util.*;

@Service
public class StudentAnswerService {

    @Autowired
    private StudentAnswerRepository studentAnswerRepository;

    @Autowired
    private StudentAnswerAttributesRepository studentAnswerAttributesRepository;

    @Autowired
    private StudentAnswerAttributeValuesRepository studentAnswerAttributeValuesRepository;

    @Autowired
    private QuestionRepository questionRepository;

    @Autowired
    private QuestionService questionService;

    /**
     * Initialize default student answer attributes if they don't exist
     */
    @Transactional
    public void initializeDefaultAttributes() {
        String[][] defaultAttributes = {
            {"mcq_selected_option", "text"},  // For MCQ: selected option index or text
            {"short_text_answer", "text"},    // For SHORT_TEXT/COMPLETE: student's answer
            {"true_false_answer", "text"}     // For TRUE_FALSE: "true" or "false"
        };

        for (String[] attr : defaultAttributes) {
            studentAnswerAttributesRepository.findBySaAttributeName(attr[0])
                .orElseGet(() -> {
                    StudentAnswerAttributes saa = new StudentAnswerAttributes(attr[0], attr[1]);
                    return studentAnswerAttributesRepository.save(saa);
                });
        }
    }

    /**
     * Get student answer attributes as a map
     */
    public Map<String, String> getStudentAnswerAttributes(StudentAnswer studentAnswer) {
        Map<String, String> attributes = new HashMap<>();
        List<StudentAnswerAttributeValues> values = studentAnswerAttributeValuesRepository
            .findByStudentAnswer(studentAnswer);
        for (StudentAnswerAttributeValues saav : values) {
            attributes.put(saav.getSaAttribute().getSaAttributeName(), saav.getValue());
        }
        return attributes;
    }

    /**
     * Set a student answer attribute
     */
    @Transactional
    public void setStudentAnswerAttribute(StudentAnswer studentAnswer, String attributeName, String value) {
        StudentAnswerAttributes attribute = studentAnswerAttributesRepository.findBySaAttributeName(attributeName)
            .orElseGet(() -> {
                StudentAnswerAttributes saa = new StudentAnswerAttributes(attributeName, "text");
                return studentAnswerAttributesRepository.save(saa);
            });

        Optional<StudentAnswerAttributeValues> existing = studentAnswerAttributeValuesRepository
            .findByStudentAnswerAndSaAttribute(studentAnswer, attribute);

        if (existing.isPresent()) {
            existing.get().setValue(value);
            studentAnswerAttributeValuesRepository.save(existing.get());
        } else {
            StudentAnswerAttributeValues saav = new StudentAnswerAttributeValues(studentAnswer, attribute, value);
            studentAnswerAttributeValuesRepository.save(saav);
        }
    }

    /**
     * Submit an answer for a question
     */
    @Transactional
    public StudentAnswer submitAnswer(Integer studentId, Integer questionId, String questionType, 
                                     Map<String, Object> answerData) {
        // Initialize default attributes if needed
        initializeDefaultAttributes();

        Question question = questionRepository.findByQuestionId(questionId);
        if (question == null) {
            throw new RuntimeException("Question not found");
        }

        // Check if answer already exists
        Optional<StudentAnswer> existingAnswerOpt = studentAnswerRepository
            .findByStudentIdAndQuestion(studentId, question);

        StudentAnswer studentAnswer;
        if (existingAnswerOpt.isPresent()) {
            studentAnswer = existingAnswerOpt.get();
        } else {
            studentAnswer = new StudentAnswer();
            studentAnswer.setStudentId(studentId);
            studentAnswer.setQuestion(question);
            studentAnswer.setSubmissionTime(new Timestamp(System.currentTimeMillis()));
        }

        // Update submission time
        studentAnswer.setSubmissionTime(new Timestamp(System.currentTimeMillis()));

        studentAnswer = studentAnswerRepository.save(studentAnswer);

        // Store answer based on question type
        if ("MCQ".equals(questionType)) {
            if (answerData.containsKey("selectedOption")) {
                setStudentAnswerAttribute(studentAnswer, "mcq_selected_option", 
                    answerData.get("selectedOption").toString());
            }
        } else if ("TRUE_FALSE".equals(questionType)) {
            if (answerData.containsKey("answer")) {
                setStudentAnswerAttribute(studentAnswer, "true_false_answer", 
                    answerData.get("answer").toString());
            }
        } else if ("SHORT_TEXT".equals(questionType)) {
            if (answerData.containsKey("answer")) {
                setStudentAnswerAttribute(studentAnswer, "short_text_answer", 
                    answerData.get("answer").toString());
            }
        }

        return studentAnswer;
    }

    /**
     * Grade a student answer (instructor reviews and sets grade/feedback)
     */
    @Transactional
    public StudentAnswer gradeAnswer(Integer studentAnswerId, BigDecimal grade, String feedback) {
        Optional<StudentAnswer> answerOpt = studentAnswerRepository.findById(studentAnswerId);
        if (answerOpt.isEmpty()) {
            throw new RuntimeException("Student answer not found");
        }

        StudentAnswer studentAnswer = answerOpt.get();
        studentAnswer.setGrade(grade);
        studentAnswer.setFeedback(feedback);

        return studentAnswerRepository.save(studentAnswer);
    }

    /**
     * Get student answer with attributes
     */
    public Map<String, Object> getStudentAnswerWithAttributes(Integer studentAnswerId) {
        Optional<StudentAnswer> answerOpt = studentAnswerRepository.findById(studentAnswerId);
        if (answerOpt.isEmpty()) {
            return null;
        }

        StudentAnswer studentAnswer = answerOpt.get();
        Map<String, Object> result = new HashMap<>();
        result.put("studentAnswerId", studentAnswer.getStudentAnswerId());
        result.put("studentId", studentAnswer.getStudentId());
        result.put("questionId", studentAnswer.getQuestion().getQuestionId());
        result.put("submissionTime", studentAnswer.getSubmissionTime().toString());
        result.put("grade", studentAnswer.getGrade());
        result.put("feedback", studentAnswer.getFeedback());

        Map<String, String> attributes = getStudentAnswerAttributes(studentAnswer);
        
        // Get question type to determine which attribute to use
        Map<String, Object> questionData = questionService.getQuestionWithAttributes(
            studentAnswer.getQuestion().getQuestionId());
        String questionType = questionData != null ? 
            (String) questionData.getOrDefault("questionType", "") : "";

        if ("MCQ".equals(questionType)) {
            result.put("selectedOption", attributes.getOrDefault("mcq_selected_option", ""));
        } else if ("TRUE_FALSE".equals(questionType)) {
            result.put("answer", attributes.getOrDefault("true_false_answer", ""));
        } else if ("SHORT_TEXT".equals(questionType)) {
            result.put("answer", attributes.getOrDefault("short_text_answer", ""));
        }

        return result;
    }

    /**
     * Get all answers for a quiz/assignment (for instructor to review)
     */
    public List<Map<String, Object>> getAnswersForAssessment(Integer assessmentId, String assessmentType) {
        List<StudentAnswer> answers = studentAnswerRepository
            .findByQuestion_AssessmentIdAndQuestion_AssessmentType(assessmentId, assessmentType);

        List<Map<String, Object>> result = new ArrayList<>();
        for (StudentAnswer answer : answers) {
            Map<String, Object> answerData = getStudentAnswerWithAttributes(answer.getStudentAnswerId());
            if (answerData != null) {
                result.add(answerData);
            }
        }

        return result;
    }

    /**
     * Get all answers for a student for a quiz/assignment
     */
    public List<Map<String, Object>> getStudentAnswersForAssessment(Integer studentId, Integer assessmentId, 
                                                                    String assessmentType) {
        List<StudentAnswer> answers = studentAnswerRepository
            .findByStudentIdAndQuestion_AssessmentIdAndQuestion_AssessmentType(studentId, assessmentId, assessmentType);

        List<Map<String, Object>> result = new ArrayList<>();
        for (StudentAnswer answer : answers) {
            Map<String, Object> answerData = getStudentAnswerWithAttributes(answer.getStudentAnswerId());
            if (answerData != null) {
                result.add(answerData);
            }
        }

        return result;
    }

    /**
     * Get all answers for a specific question (for instructor to review all student answers for one question)
     */
    public List<Map<String, Object>> getAnswersForQuestion(Integer questionId) {
        Question question = questionRepository.findByQuestionId(questionId);
        if (question == null) {
            return Collections.emptyList();
        }

        List<StudentAnswer> answers = studentAnswerRepository.findByQuestion(question);
        List<Map<String, Object>> result = new ArrayList<>();
        for (StudentAnswer answer : answers) {
            Map<String, Object> answerData = getStudentAnswerWithAttributes(answer.getStudentAnswerId());
            if (answerData != null) {
                result.add(answerData);
            }
        }

        return result;
    }
}

