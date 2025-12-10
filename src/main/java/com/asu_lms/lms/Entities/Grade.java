package com.asu_lms.lms.Entities;

import jakarta.persistence.*;
import java.util.List;

@Entity
@Table(name = "Grade")
public class Grade {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "grade_id")
    private Integer gradeId;

    @Column(name = "enrollment_id", nullable = false, unique = true)
    private Integer enrollmentId;

    @Column(name = "final_letter_grade")
    private String finalLetterGrade;

    @OneToMany(mappedBy = "grade", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<GradeAttributeValues> attributeValues;

    // Constructors
    public Grade() {}

    public Grade(Integer enrollmentId, String finalLetterGrade) {
        this.enrollmentId = enrollmentId;
        this.finalLetterGrade = finalLetterGrade;
    }

    // Getters and Setters
    public Integer getGradeId() { return gradeId; }
    public void setGradeId(Integer gradeId) { this.gradeId = gradeId; }

    public Integer getEnrollmentId() { return enrollmentId; }
    public void setEnrollmentId(Integer enrollmentId) { this.enrollmentId = enrollmentId; }

    public String getFinalLetterGrade() { return finalLetterGrade; }
    public void setFinalLetterGrade(String finalLetterGrade) { this.finalLetterGrade = finalLetterGrade; }

    public List<GradeAttributeValues> getAttributeValues() { return attributeValues; }
    public void setAttributeValues(List<GradeAttributeValues> attributeValues) { this.attributeValues = attributeValues; }
}





