package com.asu_lms.lms.Entities;

import jakarta.persistence.*;
import java.math.BigDecimal;

@Entity
@Table(name = "Grade")
public class Grade {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "grade_id")
    private Integer gradeId;

    @Column(name = "enrollment_id")
    private Integer enrollmentId;

    @Column(name = "midterm")
    private BigDecimal midterm;

    @Column(name = "project")
    private BigDecimal project;

    @Column(name = "assignments_total")
    private BigDecimal assignmentsTotal;

    @Column(name = "quizzes_total")
    private BigDecimal quizzesTotal;

    @Column(name = "attendance")
    private BigDecimal attendance;

    @Column(name = "final_exam_mark")
    private BigDecimal finalExamMark;

    @Column(name = "final_letter_grade")
    private String finalLetterGrade;

    // Constructors
    public Grade() {}

    public Grade(Integer enrollmentId, BigDecimal midterm, BigDecimal project, BigDecimal assignmentsTotal, 
                BigDecimal quizzesTotal, BigDecimal attendance, BigDecimal finalExamMark, String finalLetterGrade) {
        this.enrollmentId = enrollmentId;
        this.midterm = midterm;
        this.project = project;
        this.assignmentsTotal = assignmentsTotal;
        this.quizzesTotal = quizzesTotal;
        this.attendance = attendance;
        this.finalExamMark = finalExamMark;
        this.finalLetterGrade = finalLetterGrade;
    }

    // Getters and Setters
    public Integer getGradeId() { return gradeId; }
    public void setGradeId(Integer gradeId) { this.gradeId = gradeId; }

    public Integer getEnrollmentId() { return enrollmentId; }
    public void setEnrollmentId(Integer enrollmentId) { this.enrollmentId = enrollmentId; }

    public BigDecimal getMidterm() { return midterm; }
    public void setMidterm(BigDecimal midterm) { this.midterm = midterm; }

    public BigDecimal getProject() { return project; }
    public void setProject(BigDecimal project) { this.project = project; }

    public BigDecimal getAssignmentsTotal() { return assignmentsTotal; }
    public void setAssignmentsTotal(BigDecimal assignmentsTotal) { this.assignmentsTotal = assignmentsTotal; }

    public BigDecimal getQuizzesTotal() { return quizzesTotal; }
    public void setQuizzesTotal(BigDecimal quizzesTotal) { this.quizzesTotal = quizzesTotal; }

    public BigDecimal getAttendance() { return attendance; }
    public void setAttendance(BigDecimal attendance) { this.attendance = attendance; }

    public BigDecimal getFinalExamMark() { return finalExamMark; }
    public void setFinalExamMark(BigDecimal finalExamMark) { this.finalExamMark = finalExamMark; }

    public String getFinalLetterGrade() { return finalLetterGrade; }
    public void setFinalLetterGrade(String finalLetterGrade) { this.finalLetterGrade = finalLetterGrade; }
}





