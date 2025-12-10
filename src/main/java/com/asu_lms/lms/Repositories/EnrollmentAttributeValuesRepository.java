package com.asu_lms.lms.Repositories;

import com.asu_lms.lms.Entities.EnrollmentAttributeValues;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface EnrollmentAttributeValuesRepository extends JpaRepository<EnrollmentAttributeValues, Integer> {
    List<EnrollmentAttributeValues> findByEnrollment_EnrollmentId(Integer enrollmentId);
    Optional<EnrollmentAttributeValues> findByEnrollment_EnrollmentIdAndAttribute_AttributeName(Integer enrollmentId, String attributeName);
}

