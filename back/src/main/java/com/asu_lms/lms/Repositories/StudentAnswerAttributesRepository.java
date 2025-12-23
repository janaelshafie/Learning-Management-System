package com.asu_lms.lms.Repositories;

import com.asu_lms.lms.Entities.StudentAnswerAttributes;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface StudentAnswerAttributesRepository extends JpaRepository<StudentAnswerAttributes, Integer> {
    Optional<StudentAnswerAttributes> findBySaAttributeName(String saAttributeName);
}

