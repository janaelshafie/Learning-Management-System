package com.asu_lms.lms.Entities;

import jakarta.persistence.*;

@Entity
@Table(name = "StudentAnswerAttributes")
public class StudentAnswerAttributes {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "sa_attribute_id")
    private Integer saAttributeId;

    @Column(name = "sa_attribute_name", nullable = false, unique = true)
    private String saAttributeName;

    @Column(name = "value_type", nullable = false)
    private String valueType = "text"; // 'text', 'file', 'json', 'code'

    // Constructors
    public StudentAnswerAttributes() {}

    public StudentAnswerAttributes(String saAttributeName, String valueType) {
        this.saAttributeName = saAttributeName;
        this.valueType = valueType;
    }

    // Getters and Setters
    public Integer getSaAttributeId() {
        return saAttributeId;
    }

    public void setSaAttributeId(Integer saAttributeId) {
        this.saAttributeId = saAttributeId;
    }

    public String getSaAttributeName() {
        return saAttributeName;
    }

    public void setSaAttributeName(String saAttributeName) {
        this.saAttributeName = saAttributeName;
    }

    public String getValueType() {
        return valueType;
    }

    public void setValueType(String valueType) {
        this.valueType = valueType;
    }
}

