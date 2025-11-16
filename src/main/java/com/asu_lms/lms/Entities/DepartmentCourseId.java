package com.asu_lms.lms.Entities;

import java.io.Serializable;
import java.util.Objects;

public class DepartmentCourseId implements Serializable {
    private Integer departmentId;
    private Integer courseId;
    
    public DepartmentCourseId() {}
    
    public DepartmentCourseId(Integer departmentId, Integer courseId) {
        this.departmentId = departmentId;
        this.courseId = courseId;
    }
    
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
    
    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        DepartmentCourseId that = (DepartmentCourseId) o;
        return Objects.equals(departmentId, that.departmentId) &&
               Objects.equals(courseId, that.courseId);
    }
    
    @Override
    public int hashCode() {
        return Objects.hash(departmentId, courseId);
    }
}

