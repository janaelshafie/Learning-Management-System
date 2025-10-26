package com.asu_lms.lms.Entities;

import jakarta.persistence.*;

@Entity
@Table(name = "Enrollment")
public class Enrollment {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "enrollment_id")
    private Integer enrollmentId;

    @Column(name = "student_id")
    private Integer studentId;

    @Column(name = "section_id")
    private Integer sectionId;

    @Column(name = "status")
    private String status;

    // Constructors
    public Enrollment() {}

    public Enrollment(Integer studentId, Integer sectionId, String status) {
        this.studentId = studentId;
        this.sectionId = sectionId;
        this.status = status;
    }

    // Getters and Setters
    public Integer getEnrollmentId() { return enrollmentId; }
    public void setEnrollmentId(Integer enrollmentId) { this.enrollmentId = enrollmentId; }

    public Integer getStudentId() { return studentId; }
    public void setStudentId(Integer studentId) { this.studentId = studentId; }

    public Integer getSectionId() { return sectionId; }
    public void setSectionId(Integer sectionId) { this.sectionId = sectionId; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
}

