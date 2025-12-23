package com.asu_lms.lms.Entities;

import jakarta.persistence.*;

@Entity
@Table(name = "StudentAnswerAttributeValues")
public class StudentAnswerAttributeValues {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "sa_value_id")
    private Integer saValueId;

    @ManyToOne
    @JoinColumn(name = "student_answer_id", nullable = false)
    private StudentAnswer studentAnswer;

    @ManyToOne
    @JoinColumn(name = "sa_attribute_id", nullable = false)
    private StudentAnswerAttributes saAttribute;

    @Column(name = "value", columnDefinition = "TEXT")
    private String value;

    // Constructors
    public StudentAnswerAttributeValues() {}

    public StudentAnswerAttributeValues(StudentAnswer studentAnswer, StudentAnswerAttributes saAttribute, String value) {
        this.studentAnswer = studentAnswer;
        this.saAttribute = saAttribute;
        this.value = value;
    }

    // Getters and Setters
    public Integer getSaValueId() {
        return saValueId;
    }

    public void setSaValueId(Integer saValueId) {
        this.saValueId = saValueId;
    }

    public StudentAnswer getStudentAnswer() {
        return studentAnswer;
    }

    public void setStudentAnswer(StudentAnswer studentAnswer) {
        this.studentAnswer = studentAnswer;
    }

    public StudentAnswerAttributes getSaAttribute() {
        return saAttribute;
    }

    public void setSaAttribute(StudentAnswerAttributes saAttribute) {
        this.saAttribute = saAttribute;
    }

    public String getValue() {
        return value;
    }

    public void setValue(String value) {
        this.value = value;
    }
}

