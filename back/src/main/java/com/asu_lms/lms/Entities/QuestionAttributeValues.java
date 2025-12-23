package com.asu_lms.lms.Entities;

import jakarta.persistence.*;

@Entity
@Table(name = "QuestionAttributeValues")
public class QuestionAttributeValues {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "qav_id")
    private Integer qavId;

    @ManyToOne
    @JoinColumn(name = "question_id", nullable = false)
    private Question question;

    @ManyToOne
    @JoinColumn(name = "attribute_id", nullable = false)
    private QuestionAttributes attribute;

    @Column(name = "value", columnDefinition = "TEXT")
    private String value;

    // Constructors
    public QuestionAttributeValues() {}

    public QuestionAttributeValues(Question question, QuestionAttributes attribute, String value) {
        this.question = question;
        this.attribute = attribute;
        this.value = value;
    }

    // Getters and Setters
    public Integer getQavId() {
        return qavId;
    }

    public void setQavId(Integer qavId) {
        this.qavId = qavId;
    }

    public Question getQuestion() {
        return question;
    }

    public void setQuestion(Question question) {
        this.question = question;
    }

    public QuestionAttributes getAttribute() {
        return attribute;
    }

    public void setAttribute(QuestionAttributes attribute) {
        this.attribute = attribute;
    }

    public String getValue() {
        return value;
    }

    public void setValue(String value) {
        this.value = value;
    }
}

