package com.asu_lms.lms.Repositories;

import com.asu_lms.lms.Entities.QuizAttributes;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface QuizAttributesRepository extends JpaRepository<QuizAttributes, Integer> {
    Optional<QuizAttributes> findByAttributeName(String attributeName);
}

