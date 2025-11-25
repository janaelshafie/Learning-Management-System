package com.asu_lms.lms.Entities;

import jakarta.persistence.*;

@Entity
@Table(name = "Prerequisite")
@IdClass(PrerequisiteId.class)
public class Prerequisite {
    @Id
    @Column(name = "course_id")
    private Integer courseId;
    
    @Id
    @Column(name = "prereq_course_id")
    private Integer prereqCourseId;
    
    @ManyToOne
    @JoinColumn(name = "course_id", insertable = false, updatable = false)
    private Course course;
    
    @ManyToOne
    @JoinColumn(name = "prereq_course_id", insertable = false, updatable = false)
    private Course prereqCourse;
    
    // Constructors
    public Prerequisite() {}
    
    public Prerequisite(Integer courseId, Integer prereqCourseId) {
        this.courseId = courseId;
        this.prereqCourseId = prereqCourseId;
    }
    
    // Getters and Setters
    public Integer getCourseId() {
        return courseId;
    }
    
    public void setCourseId(Integer courseId) {
        this.courseId = courseId;
    }
    
    public Integer getPrereqCourseId() {
        return prereqCourseId;
    }
    
    public void setPrereqCourseId(Integer prereqCourseId) {
        this.prereqCourseId = prereqCourseId;
    }
    
    public Course getCourse() {
        return course;
    }
    
    public void setCourse(Course course) {
        this.course = course;
    }
    
    public Course getPrereqCourse() {
        return prereqCourse;
    }
    
    public void setPrereqCourse(Course prereqCourse) {
        this.prereqCourse = prereqCourse;
    }
}



