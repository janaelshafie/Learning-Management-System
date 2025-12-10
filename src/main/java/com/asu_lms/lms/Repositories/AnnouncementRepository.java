package com.asu_lms.lms.Repositories;

import com.asu_lms.lms.Entities.Announcement;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface AnnouncementRepository extends JpaRepository<Announcement, Integer> {
    // Find announcements by author
    List<Announcement> findByAuthorUserId(Integer authorUserId);
    
    // Note: Filtering by announcement_type, priority, is_active, expires_at is now done via EAV attributes
    // Use EAVService.getAnnouncementAttributes() and filter in service/controller layer
}
