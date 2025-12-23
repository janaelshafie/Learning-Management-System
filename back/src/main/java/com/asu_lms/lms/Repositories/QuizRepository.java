package com.asu_lms.lms.Repositories;

import com.asu_lms.lms.Entities.Quiz;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface QuizRepository extends JpaRepository<Quiz, Integer> {
    List<Quiz> findByOfferedCourseId(Integer offeredCourseId);
    Optional<Quiz> findByQuizId(Integer quizId);
    void deleteByQuizId(Integer quizId);
}

