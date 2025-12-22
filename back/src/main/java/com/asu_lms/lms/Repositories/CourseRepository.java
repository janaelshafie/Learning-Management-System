package com.asu_lms.lms.Repositories;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.asu_lms.lms.Entities.Course;

@Repository
public interface CourseRepository extends JpaRepository<Course, Integer> {
    Optional<Course> findByCourseCode(String courseCode);
    List<Course> findByTitleContaining(String title);
    List<Course> findByDepartmentCode(String departmentCode);
    boolean existsByCourseCode(String courseCode);
}





