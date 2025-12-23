package com.asu_lms.lms.Repositories;

import com.asu_lms.lms.Entities.StudentAnswer;
import com.asu_lms.lms.Entities.StudentAnswerAttributeValues;
import com.asu_lms.lms.Entities.StudentAnswerAttributes;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface StudentAnswerAttributeValuesRepository extends JpaRepository<StudentAnswerAttributeValues, Integer> {
    List<StudentAnswerAttributeValues> findByStudentAnswer(StudentAnswer studentAnswer);
    
    Optional<StudentAnswerAttributeValues> findByStudentAnswerAndSaAttribute(
        StudentAnswer studentAnswer, StudentAnswerAttributes saAttribute
    );
    
    void deleteByStudentAnswer(StudentAnswer studentAnswer);
}

