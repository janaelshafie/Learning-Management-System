package com.asu_lms.lms.Entities;

import jakarta.persistence.*;

@Entity
@Table(name = "OfferedCourse")
public class OfferedCourse {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "offered_course_id")
    private Integer offeredCourseId;

    @Column(name = "course_id")
    private Integer courseId;

    @Column(name = "semester_id")
    private Integer semesterId;

    // Constructors
    public OfferedCourse() {}

    public OfferedCourse(Integer courseId, Integer semesterId) {
        this.courseId = courseId;
        this.semesterId = semesterId;
    }

    // Getters and Setters
    public Integer getOfferedCourseId() { return offeredCourseId; }
    public void setOfferedCourseId(Integer offeredCourseId) { this.offeredCourseId = offeredCourseId; }

    public Integer getCourseId() { return courseId; }
    public void setCourseId(Integer courseId) { this.courseId = courseId; }

    public Integer getSemesterId() { return semesterId; }
    public void setSemesterId(Integer semesterId) { this.semesterId = semesterId; }
}
