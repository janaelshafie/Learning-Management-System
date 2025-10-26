package com.asu_lms.lms.Repositories;

import com.asu_lms.lms.Entities.Course;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;
import java.util.Optional;

@Repository
public interface CourseRepository extends JpaRepository<Course, Integer> {
    Optional<Course> findByCourseCode(String courseCode);
    List<Course> findByTitleContaining(String title);
    boolean existsByCourseCode(String courseCode);
}

