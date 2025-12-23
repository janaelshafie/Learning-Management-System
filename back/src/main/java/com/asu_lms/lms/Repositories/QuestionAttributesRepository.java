package com.asu_lms.lms.Repositories;

import com.asu_lms.lms.Entities.QuestionAttributes;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface QuestionAttributesRepository extends JpaRepository<QuestionAttributes, Integer> {
    Optional<QuestionAttributes> findByAttributeName(String attributeName);
}

