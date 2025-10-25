package com.asu_lms.lms.Repositories;

import com.asu_lms.lms.Entities.OfferedCourse;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface OfferedCourseRepository extends JpaRepository<OfferedCourse, Integer> {
    List<OfferedCourse> findByCourseId(Integer courseId);
    Optional<OfferedCourse> findByOfferedCourseId(Integer offeredCourseId);
}
