package com.asu_lms.lms.Entities;

import java.io.Serializable;
import java.util.Objects;

public class OfferedCourseInstructorId implements Serializable {
    private Integer offeredCourseId;
    private Integer instructorId;
    
    // Constructors
    public OfferedCourseInstructorId() {}
    
    public OfferedCourseInstructorId(Integer offeredCourseId, Integer instructorId) {
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
    
    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        OfferedCourseInstructorId that = (OfferedCourseInstructorId) o;
        return Objects.equals(offeredCourseId, that.offeredCourseId) &&
               Objects.equals(instructorId, that.instructorId);
    }
    
    @Override
    public int hashCode() {
        return Objects.hash(offeredCourseId, instructorId);
    }
}
