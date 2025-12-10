package com.asu_lms.lms.Repositories;

import com.asu_lms.lms.Entities.GradeAttributeValues;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface GradeAttributeValuesRepository extends JpaRepository<GradeAttributeValues, Integer> {
    List<GradeAttributeValues> findByGrade_GradeId(Integer gradeId);
    Optional<GradeAttributeValues> findByGrade_GradeIdAndAttribute_AttributeName(Integer gradeId, String attributeName);
}

