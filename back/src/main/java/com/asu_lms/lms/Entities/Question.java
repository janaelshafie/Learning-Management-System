package com.asu_lms.lms.Entities;

import jakarta.persistence.*;

@Entity
@Table(name = "Questions")
public class Question {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "question_id")
    private Integer questionId;

    @Column(name = "parent_question_id")
    private Integer parentQuestionId;

    @Column(name = "assessment_type", nullable = false, length = 10)
    private String assessmentType; // 'assignment' or 'quiz'

    @Column(name = "assessment_id", nullable = false)
    private Integer assessmentId; // points to assignment_id or quiz_id

    @Column(name = "question_text", columnDefinition = "TEXT")
    private String questionText;

    @Column(name = "question_order")
    private Integer questionOrder = 0;

    // Constructors
    public Question() {}

    public Question(String assessmentType, Integer assessmentId, String questionText, Integer questionOrder) {
        this.assessmentType = assessmentType;
        this.assessmentId = assessmentId;
        this.questionText = questionText;
        this.questionOrder = questionOrder;
    }

    // Getters and Setters
    public Integer getQuestionId() {
        return questionId;
    }

    public void setQuestionId(Integer questionId) {
        this.questionId = questionId;
    }

    public Integer getParentQuestionId() {
        return parentQuestionId;
    }

    public void setParentQuestionId(Integer parentQuestionId) {
        this.parentQuestionId = parentQuestionId;
    }

    public String getAssessmentType() {
        return assessmentType;
    }

    public void setAssessmentType(String assessmentType) {
        this.assessmentType = assessmentType;
    }

    public Integer getAssessmentId() {
        return assessmentId;
    }

    public void setAssessmentId(Integer assessmentId) {
        this.assessmentId = assessmentId;
    }

    public String getQuestionText() {
        return questionText;
    }

    public void setQuestionText(String questionText) {
        this.questionText = questionText;
    }

    public Integer getQuestionOrder() {
        return questionOrder;
    }

    public void setQuestionOrder(Integer questionOrder) {
        this.questionOrder = questionOrder;
    }
}

