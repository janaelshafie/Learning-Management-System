package com.asu_lms.lms.Entities;

import jakarta.persistence.*;

@Entity
@Table(name = "OfferedCourse_Instructor")
@IdClass(OfferedCourseInstructorId.class)
public class OfferedCourseInstructor {
    @Id
    @Column(name = "offered_course_id")
    private Integer offeredCourseId;
    
    @Id
    @Column(name = "instructor_id")
    private Integer instructorId;
    
    @ManyToOne
    @JoinColumn(name = "offered_course_id", insertable = false, updatable = false)
    private OfferedCourse offeredCourse;
    
    @ManyToOne
    @JoinColumn(name = "instructor_id", insertable = false, updatable = false)
    private Instructor instructor;
    
    // Constructors
    public OfferedCourseInstructor() {}
    
    public OfferedCourseInstructor(Integer offeredCourseId, Integer instructorId) {
        this.offeredCourseId = offeredCourseId;
        this.instructorId = instructorId;
    }
    
    // Getters and Setters
    public Integer getOfferedCourseId() {
        return offeredCourseId;
    }
    
    public void setOfferedCourseId(Integer offeredCourseId) {
        this.offeredCourseId = offeredCourseId;
    }
    
    public Integer getInstructorId() {
        return instructorId;
    }
    
    public void setInstructorId(Integer instructorId) {
        this.instructorId = instructorId;
    }
    
    public OfferedCourse getOfferedCourse() {
        return offeredCourse;
    }
    
    public void setOfferedCourse(OfferedCourse offeredCourse) {
        this.offeredCourse = offeredCourse;
    }
    
    public Instructor getInstructor() {
        return instructor;
    }
    
    public void setInstructor(Instructor instructor) {
        this.instructor = instructor;
    }
}
