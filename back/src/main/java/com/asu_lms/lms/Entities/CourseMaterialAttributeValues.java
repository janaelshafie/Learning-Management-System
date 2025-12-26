package com.asu_lms.lms.Entities;

import jakarta.persistence.*;

@Entity
@Table(name = "CourseMaterialAttributeValues")
public class CourseMaterialAttributeValues {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "cmav_id")
    private Integer cmavId;

    @ManyToOne
    @JoinColumn(name = "material_id", nullable = false)
    private CourseMaterial material;

    @ManyToOne
    @JoinColumn(name = "attribute_id", nullable = false)
    private CourseMaterialAttributes attribute;

    @Column(name = "value", columnDefinition = "TEXT")
    private String value;

    // Constructors
    public CourseMaterialAttributeValues() {}

    public CourseMaterialAttributeValues(CourseMaterial material, CourseMaterialAttributes attribute, String value) {
        this.material = material;
        this.attribute = attribute;
        this.value = value;
    }

    // Getters and Setters
    public Integer getCmavId() { return cmavId; }
    public void setCmavId(Integer cmavId) { this.cmavId = cmavId; }

    public CourseMaterial getMaterial() { return material; }
    public void setMaterial(CourseMaterial material) { this.material = material; }

    public CourseMaterialAttributes getAttribute() { return attribute; }
    public void setAttribute(CourseMaterialAttributes attribute) { this.attribute = attribute; }

    public String getValue() { return value; }
    public void setValue(String value) { this.value = value; }
}

