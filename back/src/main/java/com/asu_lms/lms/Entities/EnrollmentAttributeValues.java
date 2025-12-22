package com.asu_lms.lms.Entities;

import jakarta.persistence.*;

@Entity
@Table(name = "EnrollmentAttributeValues")
public class EnrollmentAttributeValues {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "eav_id")
    private Integer eavId;

    @ManyToOne
    @JoinColumn(name = "enrollment_id", nullable = false)
    private Enrollment enrollment;

    @ManyToOne
    @JoinColumn(name = "attribute_id", nullable = false)
    private EnrollmentAttributes attribute;

    @Column(name = "value", columnDefinition = "TEXT")
    private String value;

    // Constructors
    public EnrollmentAttributeValues() {}

    public EnrollmentAttributeValues(Enrollment enrollment, EnrollmentAttributes attribute, String value) {
        this.enrollment = enrollment;
        this.attribute = attribute;
        this.value = value;
    }

    // Getters and Setters
    public Integer getEavId() { return eavId; }
    public void setEavId(Integer eavId) { this.eavId = eavId; }

    public Enrollment getEnrollment() { return enrollment; }
    public void setEnrollment(Enrollment enrollment) { this.enrollment = enrollment; }

    public EnrollmentAttributes getAttribute() { return attribute; }
    public void setAttribute(EnrollmentAttributes attribute) { this.attribute = attribute; }

    public String getValue() { return value; }
    public void setValue(String value) { this.value = value; }
}

