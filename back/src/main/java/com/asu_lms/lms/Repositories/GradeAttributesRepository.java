package com.asu_lms.lms.Repositories;

import com.asu_lms.lms.Entities.GradeAttributes;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface GradeAttributesRepository extends JpaRepository<GradeAttributes, Integer> {
    Optional<GradeAttributes> findByAttributeName(String attributeName);
}

