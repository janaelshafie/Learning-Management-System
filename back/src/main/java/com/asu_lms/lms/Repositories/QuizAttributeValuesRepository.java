package com.asu_lms.lms.Repositories;

import com.asu_lms.lms.Entities.Quiz;
import com.asu_lms.lms.Entities.QuizAttributes;
import com.asu_lms.lms.Entities.QuizAttributeValues;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface QuizAttributeValuesRepository extends JpaRepository<QuizAttributeValues, Integer> {
    List<QuizAttributeValues> findByQuiz_QuizId(Integer quizId);
    
    Optional<QuizAttributeValues> findByQuiz_QuizIdAndAttribute_AttributeName(
        Integer quizId, String attributeName
    );
    
    @Query("SELECT qav FROM QuizAttributeValues qav WHERE qav.quiz = :quiz AND qav.attribute = :attribute")
    Optional<QuizAttributeValues> findByQuizAndAttribute(
        @Param("quiz") Quiz quiz,
        @Param("attribute") QuizAttributes attribute
    );
    
    void deleteByQuiz_QuizId(Integer quizId);
}

