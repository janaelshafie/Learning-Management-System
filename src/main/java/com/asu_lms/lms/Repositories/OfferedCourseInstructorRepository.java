package com.asu_lms.lms.Repositories;

import com.asu_lms.lms.Entities.OfferedCourseInstructor;
import com.asu_lms.lms.Entities.OfferedCourseInstructorId;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;
import java.util.Optional;

@Repository
public interface OfferedCourseInstructorRepository extends JpaRepository<OfferedCourseInstructor, OfferedCourseInstructorId> {
    List<OfferedCourseInstructor> findByOfferedCourseId(Integer offeredCourseId);
    List<OfferedCourseInstructor> findByInstructorId(Integer instructorId);
    Optional<OfferedCourseInstructor> findByOfferedCourseIdAndInstructorId(Integer offeredCourseId, Integer instructorId);
}
