package com.asu_lms.lms.Repositories;

import com.asu_lms.lms.Entities.Assignment;
import com.asu_lms.lms.Entities.AssignmentAttributes;
import com.asu_lms.lms.Entities.AssignmentAttributeValues;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface AssignmentAttributeValuesRepository extends JpaRepository<AssignmentAttributeValues, Integer> {
    List<AssignmentAttributeValues> findByAssignment_AssignmentId(Integer assignmentId);
    
    Optional<AssignmentAttributeValues> findByAssignment_AssignmentIdAndAttribute_AttributeName(
        Integer assignmentId, String attributeName
    );
    
    @Query("SELECT aav FROM AssignmentAttributeValues aav WHERE aav.assignment = :assignment AND aav.attribute = :attribute")
    Optional<AssignmentAttributeValues> findByAssignmentAndAttribute(
        @Param("assignment") Assignment assignment,
        @Param("attribute") AssignmentAttributes attribute
    );
    
    void deleteByAssignment_AssignmentId(Integer assignmentId);
}

