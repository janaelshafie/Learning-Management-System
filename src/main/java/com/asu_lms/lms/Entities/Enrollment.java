package com.asu_lms.lms.Entities;

import jakarta.persistence.*;
import java.util.List;

@Entity
@Table(name = "Enrollment")
public class Enrollment {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "enrollment_id")
    private Integer enrollmentId;

    @Column(name = "student_id", nullable = false)
    private Integer studentId;

    @Column(name = "section_id", nullable = false)
    private Integer sectionId;

    @OneToMany(mappedBy = "enrollment", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<EnrollmentAttributeValues> attributeValues;

    // Constructors
    public Enrollment() {}

    public Enrollment(Integer studentId, Integer sectionId) {
        this.studentId = studentId;
        this.sectionId = sectionId;
    }

    // Getters and Setters
    public Integer getEnrollmentId() { return enrollmentId; }
    public void setEnrollmentId(Integer enrollmentId) { this.enrollmentId = enrollmentId; }

    public Integer getStudentId() { return studentId; }
    public void setStudentId(Integer studentId) { this.studentId = studentId; }

    public Integer getSectionId() { return sectionId; }
    public void setSectionId(Integer sectionId) { this.sectionId = sectionId; }

    public List<EnrollmentAttributeValues> getAttributeValues() { return attributeValues; }
    public void setAttributeValues(List<EnrollmentAttributeValues> attributeValues) { this.attributeValues = attributeValues; }
}





