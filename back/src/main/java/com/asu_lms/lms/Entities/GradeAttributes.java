package com.asu_lms.lms.Entities;

import jakarta.persistence.*;
import java.math.BigDecimal;

@Entity
@Table(name = "GradeAttributes")
public class GradeAttributes {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "attribute_id")
    private Integer attributeId;

    @Column(name = "attribute_name", nullable = false, unique = true)
    private String attributeName;

    @Column(name = "value_type", nullable = false)
    private String valueType = "decimal";

    @Column(name = "max_value", precision = 5, scale = 2)
    private BigDecimal maxValue;

    @Column(name = "description", columnDefinition = "TEXT")
    private String description;

    // Constructors
    public GradeAttributes() {}

    public GradeAttributes(String attributeName, String valueType, BigDecimal maxValue, String description) {
        this.attributeName = attributeName;
        this.valueType = valueType;
        this.maxValue = maxValue;
        this.description = description;
    }

    // Getters and Setters
    public Integer getAttributeId() { return attributeId; }
    public void setAttributeId(Integer attributeId) { this.attributeId = attributeId; }

    public String getAttributeName() { return attributeName; }
    public void setAttributeName(String attributeName) { this.attributeName = attributeName; }

    public String getValueType() { return valueType; }
    public void setValueType(String valueType) { this.valueType = valueType; }

    public BigDecimal getMaxValue() { return maxValue; }
    public void setMaxValue(BigDecimal maxValue) { this.maxValue = maxValue; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
}

