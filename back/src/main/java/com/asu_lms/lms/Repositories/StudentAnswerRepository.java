package com.asu_lms.lms.Repositories;

import com.asu_lms.lms.Entities.Question;
import com.asu_lms.lms.Entities.StudentAnswer;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface StudentAnswerRepository extends JpaRepository<StudentAnswer, Integer> {
    @Query("SELECT sa FROM StudentAnswer sa WHERE sa.studentId = :studentId AND sa.question.assessmentId = :assessmentId AND sa.question.assessmentType = :assessmentType")
    List<StudentAnswer> findByStudentIdAndQuestion_AssessmentIdAndQuestion_AssessmentType(
        @Param("studentId") Integer studentId, 
        @Param("assessmentId") Integer assessmentId, 
        @Param("assessmentType") String assessmentType
    );
    
    Optional<StudentAnswer> findByStudentIdAndQuestion(Integer studentId, Question question);
    
    List<StudentAnswer> findByQuestion(Question question);
    
    @Query("SELECT sa FROM StudentAnswer sa WHERE sa.question.assessmentId = :assessmentId AND sa.question.assessmentType = :assessmentType")
    List<StudentAnswer> findByQuestion_AssessmentIdAndQuestion_AssessmentType(
        @Param("assessmentId") Integer assessmentId, 
        @Param("assessmentType") String assessmentType
    );
}

