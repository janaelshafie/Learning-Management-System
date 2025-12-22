package com.asu_lms.lms.Repositories;

import com.asu_lms.lms.Entities.EnrollmentAttributes;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface EnrollmentAttributesRepository extends JpaRepository<EnrollmentAttributes, Integer> {
    Optional<EnrollmentAttributes> findByAttributeName(String attributeName);
}

