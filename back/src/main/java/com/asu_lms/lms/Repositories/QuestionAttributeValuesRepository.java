package com.asu_lms.lms.Repositories;

import com.asu_lms.lms.Entities.Question;
import com.asu_lms.lms.Entities.QuestionAttributeValues;
import com.asu_lms.lms.Entities.QuestionAttributes;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface QuestionAttributeValuesRepository extends JpaRepository<QuestionAttributeValues, Integer> {
    List<QuestionAttributeValues> findByQuestion(Question question);
    
    Optional<QuestionAttributeValues> findByQuestionAndAttribute(Question question, QuestionAttributes attribute);
    
    void deleteByQuestion(Question question);
}

