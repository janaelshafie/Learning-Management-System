package com.asu_lms.lms.Repositories;

import com.asu_lms.lms.Entities.CourseMaterialAttributes;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface CourseMaterialAttributesRepository extends JpaRepository<CourseMaterialAttributes, Integer> {
    Optional<CourseMaterialAttributes> findByAttributeName(String attributeName);
}

