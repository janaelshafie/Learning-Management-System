package com.asu_lms.lms.Entities;

import jakarta.persistence.*;
import java.math.BigDecimal;
import java.sql.Timestamp;

@Entity
@Table(name = "Quiz")
public class Quiz {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "quiz_id")
    private Integer quizId;

    @Column(name = "offered_course_id", nullable = false)
    private Integer offeredCourseId;

    @Column(name = "instructor_id")
    private Integer instructorId;

    @Column(name = "title", nullable = false)
    private String title;

    @Column(name = "description", columnDefinition = "TEXT")
    private String description;

    @Column(name = "due_date", nullable = false)
    private Timestamp dueDate;

    @Column(name = "max_grade", nullable = false, precision = 7, scale = 2)
    private BigDecimal maxGrade = new BigDecimal("100.00");

    // Constructors
    public Quiz() {}

    public Quiz(Integer offeredCourseId, Integer instructorId, String title, 
               String description, Timestamp dueDate, BigDecimal maxGrade) {
        this.offeredCourseId = offeredCourseId;
        this.instructorId = instructorId;
        this.title = title;
        this.description = description;
        this.dueDate = dueDate;
        this.maxGrade = maxGrade;
    }

    // Getters and Setters
    public Integer getQuizId() { return quizId; }
    public void setQuizId(Integer quizId) { this.quizId = quizId; }

    public Integer getOfferedCourseId() { return offeredCourseId; }
    public void setOfferedCourseId(Integer offeredCourseId) { this.offeredCourseId = offeredCourseId; }

    public Integer getInstructorId() { return instructorId; }
    public void setInstructorId(Integer instructorId) { this.instructorId = instructorId; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public Timestamp getDueDate() { return dueDate; }
    public void setDueDate(Timestamp dueDate) { this.dueDate = dueDate; }

    public BigDecimal getMaxGrade() { return maxGrade; }
    public void setMaxGrade(BigDecimal maxGrade) { this.maxGrade = maxGrade; }
}

