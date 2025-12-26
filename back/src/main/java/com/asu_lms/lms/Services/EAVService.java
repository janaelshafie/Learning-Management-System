package com.asu_lms.lms.Services;

import com.asu_lms.lms.Entities.*;
import com.asu_lms.lms.Repositories.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@Service
public class EAVService {

    @Autowired
    private GradeAttributesRepository gradeAttributesRepository;
    
    @Autowired
    private GradeAttributeValuesRepository gradeAttributeValuesRepository;
    
    @Autowired
    private EnrollmentAttributesRepository enrollmentAttributesRepository;
    
    @Autowired
    private EnrollmentAttributeValuesRepository enrollmentAttributeValuesRepository;
    
    @Autowired
    private AnnouncementAttributesRepository announcementAttributesRepository;
    
    @Autowired
    private AnnouncementAttributeValuesRepository announcementAttributeValuesRepository;

    @Autowired
    private AssignmentAttributesRepository assignmentAttributesRepository;

    @Autowired
    private AssignmentAttributeValuesRepository assignmentAttributeValuesRepository;

    @Autowired
    private QuizAttributesRepository quizAttributesRepository;

    @Autowired
    private QuizAttributeValuesRepository quizAttributeValuesRepository;

    // ========== Grade EAV Methods ==========
    
    public Map<String, String> getGradeAttributes(Integer gradeId) {
        Map<String, String> attributes = new HashMap<>();
        List<GradeAttributeValues> values = gradeAttributeValuesRepository.findByGrade_GradeId(gradeId);
        for (GradeAttributeValues gav : values) {
            attributes.put(gav.getAttribute().getAttributeName(), gav.getValue());
        }
        return attributes;
    }

    @Transactional
    public void setGradeAttribute(Integer gradeId, String attributeName, String value) {
        Optional<GradeAttributeValues> existing = gradeAttributeValuesRepository
            .findByGrade_GradeIdAndAttribute_AttributeName(gradeId, attributeName);
        
        if (existing.isPresent()) {
            existing.get().setValue(value);
            gradeAttributeValuesRepository.save(existing.get());
        } else {
            // Need to get Grade entity - this will be handled by the caller
            throw new RuntimeException("Grade not found. Please ensure grade exists before setting attributes.");
        }
    }

    @Transactional
    public void setGradeAttribute(Grade grade, String attributeName, String value) {
        GradeAttributes attribute = gradeAttributesRepository.findByAttributeName(attributeName)
            .orElseThrow(() -> new RuntimeException("Grade attribute not found: " + attributeName));
        
        Optional<GradeAttributeValues> existing = gradeAttributeValuesRepository
            .findByGrade_GradeIdAndAttribute_AttributeName(grade.getGradeId(), attributeName);
        
        if (existing.isPresent()) {
            existing.get().setValue(value);
            gradeAttributeValuesRepository.save(existing.get());
        } else {
            GradeAttributeValues gav = new GradeAttributeValues(grade, attribute, value);
            gradeAttributeValuesRepository.save(gav);
        }
    }

    // ========== Enrollment EAV Methods ==========
    
    public Map<String, String> getEnrollmentAttributes(Integer enrollmentId) {
        Map<String, String> attributes = new HashMap<>();
        List<EnrollmentAttributeValues> values = enrollmentAttributeValuesRepository
            .findByEnrollment_EnrollmentId(enrollmentId);
        for (EnrollmentAttributeValues eav : values) {
            attributes.put(eav.getAttribute().getAttributeName(), eav.getValue());
        }
        return attributes;
    }

    public String getEnrollmentStatus(Integer enrollmentId) {
        return getEnrollmentAttributes(enrollmentId).getOrDefault("status", "pending");
    }

    @Transactional
    public void setEnrollmentAttribute(Enrollment enrollment, String attributeName, String value) {
        EnrollmentAttributes attribute = enrollmentAttributesRepository.findByAttributeName(attributeName)
            .orElseThrow(() -> new RuntimeException("Enrollment attribute not found: " + attributeName));
        
        Optional<EnrollmentAttributeValues> existing = enrollmentAttributeValuesRepository
            .findByEnrollment_EnrollmentIdAndAttribute_AttributeName(enrollment.getEnrollmentId(), attributeName);
        
        if (existing.isPresent()) {
            existing.get().setValue(value);
            enrollmentAttributeValuesRepository.save(existing.get());
        } else {
            EnrollmentAttributeValues eav = new EnrollmentAttributeValues(enrollment, attribute, value);
            enrollmentAttributeValuesRepository.save(eav);
        }
    }

    // ========== Announcement EAV Methods ==========
    
    public Map<String, String> getAnnouncementAttributes(Integer announcementId) {
        Map<String, String> attributes = new HashMap<>();
        List<AnnouncementAttributeValues> values = announcementAttributeValuesRepository
            .findByAnnouncement_AnnouncementId(announcementId);
        for (AnnouncementAttributeValues aav : values) {
            attributes.put(aav.getAttribute().getAttributeName(), aav.getValue());
        }
        return attributes;
    }

    @Transactional
    public void setAnnouncementAttribute(Announcement announcement, String attributeName, String value) {
        AnnouncementAttributes attribute = announcementAttributesRepository.findByAttributeName(attributeName)
            .orElseThrow(() -> new RuntimeException("Announcement attribute not found: " + attributeName));
        
        Optional<AnnouncementAttributeValues> existing = announcementAttributeValuesRepository
            .findByAnnouncement_AnnouncementIdAndAttribute_AttributeName(announcement.getAnnouncementId(), attributeName);
        
        if (existing.isPresent()) {
            existing.get().setValue(value);
            announcementAttributeValuesRepository.save(existing.get());
        } else {
            AnnouncementAttributeValues aav = new AnnouncementAttributeValues(announcement, attribute, value);
            announcementAttributeValuesRepository.save(aav);
        }
    }

    // ========== Assignment EAV Methods ==========
    
    @Transactional
    public void initializeAssignmentAttributes() {
        String[][] defaultAttributes = {
            {"late_submission_allowed", "bool"},
            {"late_penalty_percent", "decimal"},
            {"max_attempts", "int"},
            {"plagiarism_check_enabled", "bool"},
            {"allowed_file_types", "text"},
            {"file_size_limit_mb", "int"}
        };

        for (String[] attr : defaultAttributes) {
            assignmentAttributesRepository.findByAttributeName(attr[0])
                .orElseGet(() -> {
                    AssignmentAttributes aa = new AssignmentAttributes(attr[0], attr[1]);
                    return assignmentAttributesRepository.save(aa);
                });
        }
    }

    public Map<String, String> getAssignmentAttributes(Integer assignmentId) {
        Map<String, String> attributes = new HashMap<>();
        List<AssignmentAttributeValues> values = assignmentAttributeValuesRepository
            .findByAssignment_AssignmentId(assignmentId);
        for (AssignmentAttributeValues aav : values) {
            attributes.put(aav.getAttribute().getAttributeName(), aav.getValue());
        }
        return attributes;
    }

    @Transactional
    public void setAssignmentAttribute(Assignment assignment, String attributeName, String value) {
        AssignmentAttributes attribute = assignmentAttributesRepository.findByAttributeName(attributeName)
            .orElseGet(() -> {
                AssignmentAttributes aa = new AssignmentAttributes(attributeName, "text");
                return assignmentAttributesRepository.save(aa);
            });

        Optional<AssignmentAttributeValues> existing = assignmentAttributeValuesRepository
            .findByAssignment_AssignmentIdAndAttribute_AttributeName(assignment.getAssignmentId(), attributeName);

        if (existing.isPresent()) {
            existing.get().setValue(value);
            assignmentAttributeValuesRepository.save(existing.get());
        } else {
            AssignmentAttributeValues aav = new AssignmentAttributeValues(assignment, attribute, value);
            assignmentAttributeValuesRepository.save(aav);
        }
    }

    // ========== Quiz EAV Methods ==========
    
    @Transactional
    public void initializeQuizAttributes() {
        String[][] defaultAttributes = {
            {"time_limit_minutes", "int"},
            {"max_attempts", "int"},
            {"randomize_questions", "bool"},
            {"randomize_options", "bool"},
            {"show_results_immediately", "bool"},
            {"show_correct_answers", "bool"},
            {"show_feedback_after", "text"},
            {"attempt_penalty_percent", "decimal"}
        };

        for (String[] attr : defaultAttributes) {
            quizAttributesRepository.findByAttributeName(attr[0])
                .orElseGet(() -> {
                    QuizAttributes qa = new QuizAttributes(attr[0], attr[1]);
                    return quizAttributesRepository.save(qa);
                });
        }
    }

    public Map<String, String> getQuizAttributes(Integer quizId) {
        Map<String, String> attributes = new HashMap<>();
        List<QuizAttributeValues> values = quizAttributeValuesRepository
            .findByQuiz_QuizId(quizId);
        for (QuizAttributeValues qav : values) {
            attributes.put(qav.getAttribute().getAttributeName(), qav.getValue());
        }
        return attributes;
    }

    @Transactional
    public void setQuizAttribute(Quiz quiz, String attributeName, String value) {
        QuizAttributes attribute = quizAttributesRepository.findByAttributeName(attributeName)
            .orElseGet(() -> {
                QuizAttributes qa = new QuizAttributes(attributeName, "text");
                return quizAttributesRepository.save(qa);
            });

        Optional<QuizAttributeValues> existing = quizAttributeValuesRepository
            .findByQuiz_QuizIdAndAttribute_AttributeName(quiz.getQuizId(), attributeName);

        if (existing.isPresent()) {
            existing.get().setValue(value);
            quizAttributeValuesRepository.save(existing.get());
        } else {
            QuizAttributeValues qav = new QuizAttributeValues(quiz, attribute, value);
            quizAttributeValuesRepository.save(qav);
        }
    }
}

