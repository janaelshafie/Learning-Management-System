package com.asu_lms.lms.Services;

import com.asu_lms.lms.Entities.*;
import com.asu_lms.lms.Repositories.*;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.*;

@Service
public class QuestionService {

    @Autowired
    private QuestionRepository questionRepository;

    @Autowired
    private QuestionAttributesRepository questionAttributesRepository;

    @Autowired
    private QuestionAttributeValuesRepository questionAttributeValuesRepository;

    private final ObjectMapper objectMapper = new ObjectMapper();

    /**
     * Initialize default question attributes if they don't exist
     */
    @Transactional
    public void initializeDefaultAttributes() {
        String[][] defaultAttributes = {
            {"question_type", "text"}, // MCQ, TRUE_FALSE, SHORT_TEXT
            {"mcq_options", "json"},   // JSON array of options
            {"correct_answer", "text"}, // For MCQ: index (0,1,2...), For TRUE_FALSE: "true"/"false", For SHORT_TEXT: expected answer
            {"max_marks", "decimal"}   // Points for this question
        };

        for (String[] attr : defaultAttributes) {
            questionAttributesRepository.findByAttributeName(attr[0])
                .orElseGet(() -> {
                    QuestionAttributes qa = new QuestionAttributes(attr[0], attr[1]);
                    return questionAttributesRepository.save(qa);
                });
        }
    }

    /**
     * Get question attributes as a map
     */
    public Map<String, String> getQuestionAttributes(Question question) {
        Map<String, String> attributes = new HashMap<>();
        List<QuestionAttributeValues> values = questionAttributeValuesRepository.findByQuestion(question);
        for (QuestionAttributeValues qav : values) {
            attributes.put(qav.getAttribute().getAttributeName(), qav.getValue());
        }
        return attributes;
    }

    /**
     * Set a question attribute
     */
    @Transactional
    public void setQuestionAttribute(Question question, String attributeName, String value) {
        QuestionAttributes attribute = questionAttributesRepository.findByAttributeName(attributeName)
            .orElseGet(() -> {
                QuestionAttributes qa = new QuestionAttributes(attributeName, "text");
                return questionAttributesRepository.save(qa);
            });

        Optional<QuestionAttributeValues> existing = questionAttributeValuesRepository
            .findByQuestionAndAttribute(question, attribute);

        if (existing.isPresent()) {
            existing.get().setValue(value);
            questionAttributeValuesRepository.save(existing.get());
        } else {
            QuestionAttributeValues qav = new QuestionAttributeValues(question, attribute, value);
            questionAttributeValuesRepository.save(qav);
        }
    }

    /**
     * Create a question with attributes
     */
    @Transactional
    public Question createQuestion(String assessmentType, Integer assessmentId, String questionText,
                                   String questionType, Integer questionOrder, Map<String, Object> attributes) {
        // Initialize default attributes if needed
        initializeDefaultAttributes();

        Question question = new Question();
        question.setAssessmentType(assessmentType);
        question.setAssessmentId(assessmentId);
        question.setQuestionText(questionText);
        question.setQuestionOrder(questionOrder != null ? questionOrder : 0);

        question = questionRepository.save(question);

        // Set question type
        setQuestionAttribute(question, "question_type", questionType);

        // Set max marks if provided
        if (attributes.containsKey("maxMarks")) {
            setQuestionAttribute(question, "max_marks", attributes.get("maxMarks").toString());
        }

        // Handle question type specific attributes
        if ("MCQ".equals(questionType)) {
            // Store MCQ options as JSON array
            if (attributes.containsKey("options") && attributes.get("options") instanceof List) {
                try {
                    String optionsJson = objectMapper.writeValueAsString(attributes.get("options"));
                    setQuestionAttribute(question, "mcq_options", optionsJson);
                } catch (JsonProcessingException e) {
                    throw new RuntimeException("Error serializing MCQ options", e);
                }
            }

            // Store correct answer (index)
            if (attributes.containsKey("correctAnswer")) {
                setQuestionAttribute(question, "correct_answer", attributes.get("correctAnswer").toString());
            }
        } else if ("TRUE_FALSE".equals(questionType)) {
            // Store correct answer (true/false)
            if (attributes.containsKey("correctAnswer")) {
                setQuestionAttribute(question, "correct_answer", attributes.get("correctAnswer").toString());
            }
        } else if ("SHORT_TEXT".equals(questionType)) {
            // Store expected answer for fill-in-the-blank
            if (attributes.containsKey("correctAnswer")) {
                setQuestionAttribute(question, "correct_answer", attributes.get("correctAnswer").toString());
            }
        }

        return question;
    }

    /**
     * Update a question
     */
    @Transactional
    public Question updateQuestion(Integer questionId, String questionText, Integer questionOrder,
                                   Map<String, Object> attributes) {
        Question question = questionRepository.findByQuestionId(questionId);
        if (question == null) {
            throw new RuntimeException("Question not found");
        }

        if (questionText != null) {
            question.setQuestionText(questionText);
        }
        if (questionOrder != null) {
            question.setQuestionOrder(questionOrder);
        }

        question = questionRepository.save(question);

        // Update attributes
        Map<String, String> currentAttributes = getQuestionAttributes(question);
        String questionType = currentAttributes.getOrDefault("question_type", "");

        // Update max marks if provided
        if (attributes.containsKey("maxMarks")) {
            setQuestionAttribute(question, "max_marks", attributes.get("maxMarks").toString());
        }

        // Update question type specific attributes
        if ("MCQ".equals(questionType)) {
            if (attributes.containsKey("options") && attributes.get("options") instanceof List) {
                try {
                    String optionsJson = objectMapper.writeValueAsString(attributes.get("options"));
                    setQuestionAttribute(question, "mcq_options", optionsJson);
                } catch (JsonProcessingException e) {
                    throw new RuntimeException("Error serializing MCQ options", e);
                }
            }
            if (attributes.containsKey("correctAnswer")) {
                setQuestionAttribute(question, "correct_answer", attributes.get("correctAnswer").toString());
            }
        } else if ("TRUE_FALSE".equals(questionType)) {
            if (attributes.containsKey("correctAnswer")) {
                setQuestionAttribute(question, "correct_answer", attributes.get("correctAnswer").toString());
            }
        } else if ("SHORT_TEXT".equals(questionType)) {
            if (attributes.containsKey("correctAnswer")) {
                setQuestionAttribute(question, "correct_answer", attributes.get("correctAnswer").toString());
            }
        }

        return question;
    }

    /**
     * Get question with all attributes as a map
     */
    public Map<String, Object> getQuestionWithAttributes(Integer questionId) {
        Question question = questionRepository.findByQuestionId(questionId);
        if (question == null) {
            return null;
        }

        Map<String, Object> result = new HashMap<>();
        result.put("questionId", question.getQuestionId());
        result.put("assessmentType", question.getAssessmentType());
        result.put("assessmentId", question.getAssessmentId());
        result.put("questionText", question.getQuestionText());
        result.put("questionOrder", question.getQuestionOrder());
        result.put("parentQuestionId", question.getParentQuestionId());

        Map<String, String> attributes = getQuestionAttributes(question);
        String questionType = attributes.getOrDefault("question_type", "");

        result.put("questionType", questionType);

        if (attributes.containsKey("max_marks")) {
            result.put("maxMarks", new BigDecimal(attributes.get("max_marks")));
        }

        // Parse question type specific attributes
        if ("MCQ".equals(questionType)) {
            if (attributes.containsKey("mcq_options")) {
                try {
                    List<String> options = objectMapper.readValue(
                        attributes.get("mcq_options"),
                        objectMapper.getTypeFactory().constructCollectionType(List.class, String.class)
                    );
                    result.put("options", options);
                } catch (JsonProcessingException e) {
                    result.put("options", Collections.emptyList());
                }
            }
            if (attributes.containsKey("correct_answer")) {
                result.put("correctAnswer", attributes.get("correct_answer"));
            }
        } else if ("TRUE_FALSE".equals(questionType) || "SHORT_TEXT".equals(questionType)) {
            if (attributes.containsKey("correct_answer")) {
                result.put("correctAnswer", attributes.get("correct_answer"));
            }
        }

        return result;
    }

    /**
     * Get all questions for a quiz/assignment
     */
    public List<Map<String, Object>> getQuestionsForAssessment(String assessmentType, Integer assessmentId) {
        List<Question> questions = questionRepository
            .findByAssessmentTypeAndAssessmentIdOrderByQuestionOrderAsc(assessmentType, assessmentId);

        List<Map<String, Object>> result = new ArrayList<>();
        for (Question question : questions) {
            Map<String, Object> questionData = getQuestionWithAttributes(question.getQuestionId());
            if (questionData != null) {
                result.add(questionData);
            }
        }

        return result;
    }

    /**
     * Delete a question
     */
    @Transactional
    public void deleteQuestion(Integer questionId) {
        Question question = questionRepository.findByQuestionId(questionId);
        if (question != null) {
            // Delete attribute values (cascade should handle this, but explicit is better)
            questionAttributeValuesRepository.deleteByQuestion(question);
            questionRepository.delete(question);
        }
    }
}

