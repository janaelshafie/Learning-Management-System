package com.asu_lms.lms.Repositories;

import com.asu_lms.lms.Entities.Announcement;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.sql.Timestamp;
import java.util.List;

@Repository
public interface AnnouncementRepository extends JpaRepository<Announcement, Integer> {
    
    // Find announcements by type and active status
    List<Announcement> findByAnnouncementTypeAndIsActiveTrue(Announcement.AnnouncementType announcementType);
    
    // Find all active announcements
    List<Announcement> findByIsActiveTrue();
    
    // Find announcements that haven't expired
    @Query("SELECT a FROM Announcement a WHERE a.isActive = true AND (a.expiresAt IS NULL OR a.expiresAt > :currentTime)")
    List<Announcement> findActiveAndNotExpired(@Param("currentTime") Timestamp currentTime);
    
    // Find announcements for specific user type that haven't expired
    @Query("SELECT a FROM Announcement a WHERE a.isActive = true AND (a.announcementType = :type OR a.announcementType = 'all_users') AND (a.expiresAt IS NULL OR a.expiresAt > :currentTime)")
    List<Announcement> findActiveForUserType(@Param("type") Announcement.AnnouncementType type, @Param("currentTime") Timestamp currentTime);
    
    // Find announcements created by specific user
    List<Announcement> findByCreatedBy(Integer createdBy);
}
