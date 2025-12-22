package com.asu_lms.lms.Entities;

import jakarta.persistence.*;

@Entity
@Table(name = "Instructor")
public class Instructor {
    @Id
    @Column(name = "instructor_id")
    private Integer instructorId;
    
    @Column(name = "instructor_type")
    private String instructorType;
    
    @Column(name = "office_hours")
    private String officeHours;
    
    @Column(name = "department_id")
    private Integer departmentId;
    
    // Constructors
    public Instructor() {}
    
    public Instructor(Integer instructorId, String instructorType, String officeHours) {
        this.instructorId = instructorId;
        this.instructorType = instructorType;
        this.officeHours = officeHours;
    }
    
    public Instructor(Integer instructorId, String instructorType, String officeHours, Integer departmentId) {
        this.instructorId = instructorId;
        this.instructorType = instructorType;
        this.officeHours = officeHours;
        this.departmentId = departmentId;
    }
    
    // Getters and Setters
    public Integer getInstructorId() {
        return instructorId;
    }
    
    public void setInstructorId(Integer instructorId) {
        this.instructorId = instructorId;
    }
    
    public String getInstructorType() {
        return instructorType;
    }
    
    public void setInstructorType(String instructorType) {
        this.instructorType = instructorType;
    }
    
    public String getOfficeHours() {
        return officeHours;
    }
    
    public void setOfficeHours(String officeHours) {
        this.officeHours = officeHours;
    }
    
    public Integer getDepartmentId() {
        return departmentId;
    }
    
    public void setDepartmentId(Integer departmentId) {
        this.departmentId = departmentId;
    }
}





