package com.asu_lms.lms.Entities;

import java.io.Serializable;
import java.util.Objects;

public class PrerequisiteId implements Serializable {
    private Integer courseId;
    private Integer prereqCourseId;
    
    public PrerequisiteId() {}
    
    public PrerequisiteId(Integer courseId, Integer prereqCourseId) {
        this.courseId = courseId;
        this.prereqCourseId = prereqCourseId;
    }
    
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
    
    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        PrerequisiteId that = (PrerequisiteId) o;
        return Objects.equals(courseId, that.courseId) &&
               Objects.equals(prereqCourseId, that.prereqCourseId);
    }
    
    @Override
    public int hashCode() {
        return Objects.hash(courseId, prereqCourseId);
    }
}

