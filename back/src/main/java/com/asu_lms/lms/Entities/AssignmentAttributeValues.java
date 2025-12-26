package com.asu_lms.lms.Entities;

import jakarta.persistence.*;

@Entity
@Table(name = "AssignmentAttributeValues")
public class AssignmentAttributeValues {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "aav_id")
    private Integer aavId;

    @ManyToOne
    @JoinColumn(name = "assignment_id", nullable = false)
    private Assignment assignment;

    @ManyToOne
    @JoinColumn(name = "attribute_id", nullable = false)
    private AssignmentAttributes attribute;

    @Column(name = "value", columnDefinition = "TEXT")
    private String value;

    // Constructors
    public AssignmentAttributeValues() {}

    public AssignmentAttributeValues(Assignment assignment, AssignmentAttributes attribute, String value) {
        this.assignment = assignment;
        this.attribute = attribute;
        this.value = value;
    }

    // Getters and Setters
    public Integer getAavId() { return aavId; }
    public void setAavId(Integer aavId) { this.aavId = aavId; }

    public Assignment getAssignment() { return assignment; }
    public void setAssignment(Assignment assignment) { this.assignment = assignment; }

    public AssignmentAttributes getAttribute() { return attribute; }
    public void setAttribute(AssignmentAttributes attribute) { this.attribute = attribute; }

    public String getValue() { return value; }
    public void setValue(String value) { this.value = value; }
}

