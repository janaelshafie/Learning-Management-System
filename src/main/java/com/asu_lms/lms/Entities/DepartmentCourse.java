package com.asu_lms.lms.Entities;

import jakarta.persistence.*;

@Entity
@Table(name = "DepartmentCourse")
@IdClass(DepartmentCourseId.class)
public class DepartmentCourse {
    @Id
    @Column(name = "department_id")
    private Integer departmentId;
    
    @Id
    @Column(name = "course_id")
    private Integer courseId;
    
    @Column(name = "course_type", nullable = false)
    private String courseType; // 'core' or 'elective'
    
    @Column(name = "capacity")
    private Integer capacity;
    
    @Column(name = "eligibility_requirements")
    private String eligibilityRequirements;
    
    @ManyToOne
    @JoinColumn(name = "department_id", insertable = false, updatable = false)
    private Department department;
    
    @ManyToOne
    @JoinColumn(name = "course_id", insertable = false, updatable = false)
    private Course course;
    
    // Constructors
    public DepartmentCourse() {}
    
    public DepartmentCourse(Integer departmentId, Integer courseId, String courseType) {
        this.departmentId = departmentId;
        this.courseId = courseId;
        this.courseType = courseType;
    }
    
    // Getters and Setters
    public Integer getDepartmentId() {
        return departmentId;
    }
    
    public void setDepartmentId(Integer departmentId) {
        this.departmentId = departmentId;
    }
    
    public Integer getCourseId() {
        return courseId;
    }
    
    public void setCourseId(Integer courseId) {
        this.courseId = courseId;
    }
    
    public String getCourseType() {
        return courseType;
    }
    
    public void setCourseType(String courseType) {
        this.courseType = courseType;
    }
    
    public Integer getCapacity() {
        return capacity;
    }
    
    public void setCapacity(Integer capacity) {
        this.capacity = capacity;
    }
    
    public String getEligibilityRequirements() {
        return eligibilityRequirements;
    }
    
    public void setEligibilityRequirements(String eligibilityRequirements) {
        this.eligibilityRequirements = eligibilityRequirements;
    }
    
    public Department getDepartment() {
        return department;
    }
    
    public void setDepartment(Department department) {
        this.department = department;
    }
    
    public Course getCourse() {
        return course;
    }
    
    public void setCourse(Course course) {
        this.course = course;
    }
}



