package com.asu_lms.lms.Entities;

import jakarta.persistence.*;

@Entity
@Table(name = "QuizAttributeValues")
public class QuizAttributeValues {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "qav_id")
    private Integer qavId;

    @ManyToOne
    @JoinColumn(name = "quiz_id", nullable = false)
    private Quiz quiz;

    @ManyToOne
    @JoinColumn(name = "attribute_id", nullable = false)
    private QuizAttributes attribute;

    @Column(name = "value", columnDefinition = "TEXT")
    private String value;

    // Constructors
    public QuizAttributeValues() {}

    public QuizAttributeValues(Quiz quiz, QuizAttributes attribute, String value) {
        this.quiz = quiz;
        this.attribute = attribute;
        this.value = value;
    }

    // Getters and Setters
    public Integer getQavId() { return qavId; }
    public void setQavId(Integer qavId) { this.qavId = qavId; }

    public Quiz getQuiz() { return quiz; }
    public void setQuiz(Quiz quiz) { this.quiz = quiz; }

    public QuizAttributes getAttribute() { return attribute; }
    public void setAttribute(QuizAttributes attribute) { this.attribute = attribute; }

    public String getValue() { return value; }
    public void setValue(String value) { this.value = value; }
}

