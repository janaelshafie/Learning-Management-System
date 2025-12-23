package com.asu_lms.lms.Entities;

import jakarta.persistence.*;
import java.math.BigDecimal;
import java.sql.Timestamp;

@Entity
@Table(name = "AssignmentSubmission")
public class AssignmentSubmission {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "submission_id")
    private Integer submissionId;

    @Column(name = "assignment_id", nullable = false)
    private Integer assignmentId;

    @Column(name = "student_id", nullable = false)
    private Integer studentId;

    @Column(name = "submitted_at", nullable = false)
    private Timestamp submittedAt = new Timestamp(System.currentTimeMillis());

    @Column(name = "content", columnDefinition = "TEXT")
    private String content;

    @Column(name = "file_path", length = 1024)
    private String filePath;

    @Column(name = "grade", precision = 7, scale = 2)
    private BigDecimal grade;

    @Column(name = "feedback", columnDefinition = "TEXT")
    private String feedback;

    // Constructors
    public AssignmentSubmission() {}

    public AssignmentSubmission(Integer assignmentId, Integer studentId, String filePath) {
        this.assignmentId = assignmentId;
        this.studentId = studentId;
        this.filePath = filePath;
        this.submittedAt = new Timestamp(System.currentTimeMillis());
    }

    // Getters and Setters
    public Integer getSubmissionId() { return submissionId; }
    public void setSubmissionId(Integer submissionId) { this.submissionId = submissionId; }

    public Integer getAssignmentId() { return assignmentId; }
    public void setAssignmentId(Integer assignmentId) { this.assignmentId = assignmentId; }

    public Integer getStudentId() { return studentId; }
    public void setStudentId(Integer studentId) { this.studentId = studentId; }

    public Timestamp getSubmittedAt() { return submittedAt; }
    public void setSubmittedAt(Timestamp submittedAt) { this.submittedAt = submittedAt; }

    public String getContent() { return content; }
    public void setContent(String content) { this.content = content; }

    public String getFilePath() { return filePath; }
    public void setFilePath(String filePath) { this.filePath = filePath; }

    public BigDecimal getGrade() { return grade; }
    public void setGrade(BigDecimal grade) { this.grade = grade; }

    public String getFeedback() { return feedback; }
    public void setFeedback(String feedback) { this.feedback = feedback; }
}

