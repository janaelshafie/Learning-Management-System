package com.asu_lms.lms.Repositories;

import com.asu_lms.lms.Entities.AssignmentSubmission;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface AssignmentSubmissionRepository extends JpaRepository<AssignmentSubmission, Integer> {
    Optional<AssignmentSubmission> findByAssignmentIdAndStudentId(Integer assignmentId, Integer studentId);
    List<AssignmentSubmission> findByAssignmentId(Integer assignmentId);
    List<AssignmentSubmission> findByStudentId(Integer studentId);
}

