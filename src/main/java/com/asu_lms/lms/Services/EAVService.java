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
}

