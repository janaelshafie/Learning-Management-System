package com.asu_lms.lms.Repositories;

import com.asu_lms.lms.Entities.Assignment;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface AssignmentRepository extends JpaRepository<Assignment, Integer> {
    List<Assignment> findByOfferedCourseId(Integer offeredCourseId);
    Optional<Assignment> findByAssignmentId(Integer assignmentId);
    void deleteByAssignmentId(Integer assignmentId);
}

