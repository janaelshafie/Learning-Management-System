package com.asu_lms.lms.Repositories;

import com.asu_lms.lms.Entities.DepartmentCourse;
import com.asu_lms.lms.Entities.DepartmentCourseId;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface DepartmentCourseRepository extends JpaRepository<DepartmentCourse, DepartmentCourseId> {
    List<DepartmentCourse> findByDepartmentId(Integer departmentId);
    List<DepartmentCourse> findByCourseId(Integer courseId);
    List<DepartmentCourse> findByDepartmentIdAndCourseType(Integer departmentId, String courseType);
    
    @Query("SELECT dc FROM DepartmentCourse dc WHERE dc.departmentId = :departmentId AND dc.courseType = 'core'")
    List<DepartmentCourse> findCoreCoursesByDepartmentId(Integer departmentId);
    
    @Query("SELECT dc FROM DepartmentCourse dc WHERE dc.departmentId = :departmentId AND dc.courseType = 'elective'")
    List<DepartmentCourse> findElectiveCoursesByDepartmentId(Integer departmentId);
    
    boolean existsByDepartmentIdAndCourseId(Integer departmentId, Integer courseId);
}

