package com.asu_lms.lms.Entities;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;

@Entity
@Table(name = "Course")
public class Course {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "course_id")
    private Integer courseId;
    
    @Column(name = "course_code", nullable = false, unique = true)
    private String courseCode;
    
    @Column(name = "title", nullable = false)
    private String title;
    
    @Column(name = "description")
    private String description;
    
    @Column(name = "credits", nullable = false)
    private Integer credits;
    
    @Column(name = "course_type")
    private String courseType; // 'core' or 'elective' - can be null for general courses
    
    @Column(name = "department_code", nullable = false, length = 20)
    private String departmentCode;
    
    @ManyToOne
    @JoinColumn(name = "department_code", referencedColumnName = "department_code", insertable = false, updatable = false)
    private Department department;
    
    // Constructors
    public Course() {}
    
    public Course(String courseCode, String title, String description, Integer credits, String departmentCode) {
        this.courseCode = courseCode;
        this.title = title;
        this.description = description;
        this.credits = credits;
        this.departmentCode = departmentCode;
    }
    
    public Course(String courseCode, String title, String description, Integer credits, String courseType, String departmentCode) {
        this.courseCode = courseCode;
        this.title = title;
        this.description = description;
        this.credits = credits;
        this.courseType = courseType;
        this.departmentCode = departmentCode;
    }
    
    // Getters and Setters
    public Integer getCourseId() {
        return courseId;
    }
    
    public void setCourseId(Integer courseId) {
        this.courseId = courseId;
    }
    
    public String getCourseCode() {
        return courseCode;
    }
    
    public void setCourseCode(String courseCode) {
        this.courseCode = courseCode;
    }
    
    public String getTitle() {
        return title;
    }
    
    public void setTitle(String title) {
        this.title = title;
    }
    
    public String getDescription() {
        return description;
    }
    
    public void setDescription(String description) {
        this.description = description;
    }
    
    public Integer getCredits() {
        return credits;
    }
    
    public void setCredits(Integer credits) {
        this.credits = credits;
    }
    
    public String getCourseType() {
        return courseType;
    }
    
    public void setCourseType(String courseType) {
        this.courseType = courseType;
    }
    
    public String getDepartmentCode() {
        return departmentCode;
    }
    
    public void setDepartmentCode(String departmentCode) {
        this.departmentCode = departmentCode;
    }
    
    public Department getDepartment() {
        return department;
    }
    
    public void setDepartment(Department department) {
        this.department = department;
    }
}

