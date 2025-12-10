package com.asu_lms.lms.Entities;

import jakarta.persistence.*;

@Entity
@Table(name = "AnnouncementAttributes")
public class AnnouncementAttributes {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "attribute_id")
    private Integer attributeId;

    @Column(name = "attribute_name", nullable = false, unique = true)
    private String attributeName;

    @Column(name = "value_type", nullable = false)
    private String valueType = "text";

    // Constructors
    public AnnouncementAttributes() {}

    public AnnouncementAttributes(String attributeName, String valueType) {
        this.attributeName = attributeName;
        this.valueType = valueType;
    }

    // Getters and Setters
    public Integer getAttributeId() { return attributeId; }
    public void setAttributeId(Integer attributeId) { this.attributeId = attributeId; }

    public String getAttributeName() { return attributeName; }
    public void setAttributeName(String attributeName) { this.attributeName = attributeName; }

    public String getValueType() { return valueType; }
    public void setValueType(String valueType) { this.valueType = valueType; }
}

