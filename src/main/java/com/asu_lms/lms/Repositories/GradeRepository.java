package com.asu_lms.lms.Repositories;

import com.asu_lms.lms.Entities.Grade;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface GradeRepository extends JpaRepository<Grade, Integer> {
    Optional<Grade> findByEnrollmentId(Integer enrollmentId);
}



