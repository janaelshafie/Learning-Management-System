package com.asu_lms.lms.Entities;

import jakarta.persistence.*;

@Entity
@Table(name = "Section")
public class Section {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "section_id")
    private Integer sectionId;

    @Column(name = "offered_course_id")
    private Integer offeredCourseId;

    @Column(name = "ta_instructor_id")
    private Integer taInstructorId;

    @Column(name = "section_number")
    private String sectionNumber;

    @Column(name = "capacity")
    private Integer capacity;

    @Column(name = "current_enrollment")
    private Integer currentEnrollment;

    // Constructors
    public Section() {}

    public Section(Integer offeredCourseId, Integer taInstructorId, String sectionNumber, Integer capacity, Integer currentEnrollment) {
        this.offeredCourseId = offeredCourseId;
        this.taInstructorId = taInstructorId;
        this.sectionNumber = sectionNumber;
        this.capacity = capacity;
        this.currentEnrollment = currentEnrollment;
    }

    // Getters and Setters
    public Integer getSectionId() { return sectionId; }
    public void setSectionId(Integer sectionId) { this.sectionId = sectionId; }

    public Integer getOfferedCourseId() { return offeredCourseId; }
    public void setOfferedCourseId(Integer offeredCourseId) { this.offeredCourseId = offeredCourseId; }

    public Integer getTaInstructorId() { return taInstructorId; }
    public void setTaInstructorId(Integer taInstructorId) { this.taInstructorId = taInstructorId; }

    public String getSectionNumber() { return sectionNumber; }
    public void setSectionNumber(String sectionNumber) { this.sectionNumber = sectionNumber; }

    public Integer getCapacity() { return capacity; }
    public void setCapacity(Integer capacity) { this.capacity = capacity; }

    public Integer getCurrentEnrollment() { return currentEnrollment; }
    public void setCurrentEnrollment(Integer currentEnrollment) { this.currentEnrollment = currentEnrollment; }
}
