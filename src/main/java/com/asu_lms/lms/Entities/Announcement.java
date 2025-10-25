package com.asu_lms.lms.Entities;

import jakarta.persistence.*;
import java.sql.Timestamp;

@Entity
@Table(name = "global_announcements")
public class Announcement {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "announcement_id")
    private Integer announcementId;

    @Column(name = "title", nullable = false)
    private String title;

    @Column(name = "content", columnDefinition = "TEXT", nullable = false)
    private String content;

    @Enumerated(EnumType.STRING)
    @Column(name = "announcement_type", nullable = false)
    private AnnouncementType announcementType = AnnouncementType.all_users;

    @Enumerated(EnumType.STRING)
    @Column(name = "priority", nullable = false)
    private Priority priority = Priority.medium;

    @Column(name = "is_active", nullable = false)
    private Boolean isActive = true;

    @Column(name = "created_by", nullable = false)
    private Integer createdBy;

    @Column(name = "created_at", nullable = false)
    private Timestamp createdAt = new Timestamp(System.currentTimeMillis());

    @Column(name = "expires_at")
    private Timestamp expiresAt;

    public enum AnnouncementType {
        all_users, students_only, instructors_only, admins_only
    }

    public enum Priority {
        low, medium, high, urgent
    }

    // Constructors
    public Announcement() {}

    public Announcement(String title, String content, AnnouncementType announcementType, Priority priority, Integer createdBy) {
        this.title = title;
        this.content = content;
        this.announcementType = announcementType;
        this.priority = priority;
        this.createdBy = createdBy;
    }

    // Getters and Setters
    public Integer getAnnouncementId() { return announcementId; }
    public void setAnnouncementId(Integer announcementId) { this.announcementId = announcementId; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getContent() { return content; }
    public void setContent(String content) { this.content = content; }

    public AnnouncementType getAnnouncementType() { return announcementType; }
    public void setAnnouncementType(AnnouncementType announcementType) { this.announcementType = announcementType; }

    public Priority getPriority() { return priority; }
    public void setPriority(Priority priority) { this.priority = priority; }

    public Boolean getIsActive() { return isActive; }
    public void setIsActive(Boolean isActive) { this.isActive = isActive; }

    public Integer getCreatedBy() { return createdBy; }
    public void setCreatedBy(Integer createdBy) { this.createdBy = createdBy; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public Timestamp getExpiresAt() { return expiresAt; }
    public void setExpiresAt(Timestamp expiresAt) { this.expiresAt = expiresAt; }
}
