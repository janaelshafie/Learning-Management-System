package com.asu_lms.lms.Repositories;

import com.asu_lms.lms.Entities.AssignmentAttributes;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface AssignmentAttributesRepository extends JpaRepository<AssignmentAttributes, Integer> {
    Optional<AssignmentAttributes> findByAttributeName(String attributeName);
}

