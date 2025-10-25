package com.asu_lms.lms.Entities;

import jakarta.persistence.*;

@Entity
@Table(name = "Department")
public class Department {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "department_id")
    private Integer departmentId;
    
    @Column(name = "name", nullable = false)
    private String name;
    
    @Column(name = "unit_head_id")
    private Integer unitHeadId;
    
    // Constructors
    public Department() {}
    
    public Department(String name, Integer unitHeadId) {
        this.name = name;
        this.unitHeadId = unitHeadId;
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
}
