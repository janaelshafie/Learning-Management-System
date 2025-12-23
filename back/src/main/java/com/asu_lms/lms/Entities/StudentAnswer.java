package com.asu_lms.lms.Entities;

import jakarta.persistence.*;
import java.math.BigDecimal;
import java.sql.Timestamp;

@Entity
@Table(name = "StudentAnswers")
public class StudentAnswer {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "student_answer_id")
    private Integer studentAnswerId;

    @Column(name = "student_id", nullable = false)
    private Integer studentId;

    @ManyToOne
    @JoinColumn(name = "question_id", nullable = false)
    private Question question;

    @Column(name = "submission_time", nullable = false)
    private Timestamp submissionTime;

    @Column(name = "grade", precision = 7, scale = 2)
    private BigDecimal grade;

    @Column(name = "feedback", columnDefinition = "TEXT")
    private String feedback;

    // Constructors
    public StudentAnswer() {}

    public StudentAnswer(Integer studentId, Question question, Timestamp submissionTime) {
        this.studentId = studentId;
        this.question = question;
        this.submissionTime = submissionTime;
    }

    // Getters and Setters
    public Integer getStudentAnswerId() {
        return studentAnswerId;
    }

    public void setStudentAnswerId(Integer studentAnswerId) {
        this.studentAnswerId = studentAnswerId;
    }

    public Integer getStudentId() {
        return studentId;
    }

    public void setStudentId(Integer studentId) {
        this.studentId = studentId;
    }

    public Question getQuestion() {
        return question;
    }

    public void setQuestion(Question question) {
        this.question = question;
    }

    public Timestamp getSubmissionTime() {
        return submissionTime;
    }

    public void setSubmissionTime(Timestamp submissionTime) {
        this.submissionTime = submissionTime;
    }

    public BigDecimal getGrade() {
        return grade;
    }

    public void setGrade(BigDecimal grade) {
        this.grade = grade;
    }

    public String getFeedback() {
        return feedback;
    }

    public void setFeedback(String feedback) {
        this.feedback = feedback;
    }
}

