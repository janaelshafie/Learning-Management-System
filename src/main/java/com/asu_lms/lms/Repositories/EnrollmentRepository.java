package com.asu_lms.lms.Repositories;

import com.asu_lms.lms.Entities.Enrollment;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface EnrollmentRepository extends JpaRepository<Enrollment, Integer> {
    List<Enrollment> findByStudentId(Integer studentId);
    List<Enrollment> findBySectionId(Integer sectionId);
    // Note: Status queries removed - status is now in EAV model
    // Use EAVService.getEnrollmentStatus() or filter by attribute values instead
}





