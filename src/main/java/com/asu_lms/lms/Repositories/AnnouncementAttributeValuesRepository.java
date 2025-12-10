package com.asu_lms.lms.Repositories;

import com.asu_lms.lms.Entities.AnnouncementAttributeValues;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface AnnouncementAttributeValuesRepository extends JpaRepository<AnnouncementAttributeValues, Integer> {
    List<AnnouncementAttributeValues> findByAnnouncement_AnnouncementId(Integer announcementId);
    Optional<AnnouncementAttributeValues> findByAnnouncement_AnnouncementIdAndAttribute_AttributeName(Integer announcementId, String attributeName);
}

