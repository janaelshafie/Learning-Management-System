package com.asu_lms.lms.Entities;

import jakarta.persistence.*;

@Entity
@Table(name = "GradeAttributeValues")
public class GradeAttributeValues {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "gav_id")
    private Integer gavId;

    @ManyToOne
    @JoinColumn(name = "grade_id", nullable = false)
    private Grade grade;

    @ManyToOne
    @JoinColumn(name = "attribute_id", nullable = false)
    private GradeAttributes attribute;

    @Column(name = "value", columnDefinition = "TEXT")
    private String value;

    // Constructors
    public GradeAttributeValues() {}

    public GradeAttributeValues(Grade grade, GradeAttributes attribute, String value) {
        this.grade = grade;
        this.attribute = attribute;
        this.value = value;
    }

    // Getters and Setters
    public Integer getGavId() { return gavId; }
    public void setGavId(Integer gavId) { this.gavId = gavId; }

    public Grade getGrade() { return grade; }
    public void setGrade(Grade grade) { this.grade = grade; }

    public GradeAttributes getAttribute() { return attribute; }
    public void setAttribute(GradeAttributes attribute) { this.attribute = attribute; }

    public String getValue() { return value; }
    public void setValue(String value) { this.value = value; }
}

