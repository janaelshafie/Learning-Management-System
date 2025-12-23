package com.asu_lms.lms.Repositories;

import com.asu_lms.lms.Entities.Question;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface QuestionRepository extends JpaRepository<Question, Integer> {
    List<Question> findByAssessmentTypeAndAssessmentIdOrderByQuestionOrderAsc(String assessmentType, Integer assessmentId);
    
    List<Question> findByAssessmentTypeAndAssessmentId(String assessmentType, Integer assessmentId);
    
    Question findByQuestionId(Integer questionId);
}

