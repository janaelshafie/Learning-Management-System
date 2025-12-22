package com.asu_lms.lms.Entities;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

@Entity
@Table(name = "Department")
public class Department {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "department_id")
    private Integer departmentId;
    
    @Column(name = "department_code", nullable = false, unique = true, length = 20)
    private String departmentCode;
    
    @Column(name = "name", nullable = false)
    private String name;
    
    @Column(name = "unit_head_id")
    private Integer unitHeadId;
    
    // Constructors
    public Department() {}
    
    public Department(String departmentCode, String name, Integer unitHeadId) {
        this.departmentCode = departmentCode;
        this.name = name;
        this.unitHeadId = unitHeadId;
    }
    
    // Deprecated: Use constructor with departmentCode instead
    // This constructor is kept for backward compatibility but departmentCode must be set before saving
    @Deprecated
    public Department(String name, Integer unitHeadId) {
        this.name = name;
        this.unitHeadId = unitHeadId;
        // Note: departmentCode must be set before saving to database
    }
    
    // Getters and Setters
    public Integer getDepartmentId() {
        return departmentId;
    }
    
    public void setDepartmentId(Integer departmentId) {
        this.departmentId = departmentId;
    }
    
    public String getName() {
        return name;
    }
    
    public void setName(String name) {
        this.name = name;
    }
    
    public Integer getUnitHeadId() {
        return unitHeadId;
    }
    
    public void setUnitHeadId(Integer unitHeadId) {
        this.unitHeadId = unitHeadId;
    }
    
    public String getDepartmentCode() {
        return departmentCode;
    }
    
    public void setDepartmentCode(String departmentCode) {
        this.departmentCode = departmentCode;
    }
}

