package com.asu_lms.lms.Entities;

import jakarta.persistence.*;
import java.sql.Timestamp;
import java.util.List;

@Entity
@Table(name = "Announcement")
public class Announcement {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "announcement_id")
    private Integer announcementId;

    @Column(name = "author_user_id", nullable = false)
    private Integer authorUserId;

    @Column(name = "title", nullable = false)
    private String title;

    @Column(name = "content", columnDefinition = "TEXT", nullable = false)
    private String content;

    @Column(name = "created_at", nullable = false)
    private Timestamp createdAt = new Timestamp(System.currentTimeMillis());

    @OneToMany(mappedBy = "announcement", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<AnnouncementAttributeValues> attributeValues;

    // Constructors
    public Announcement() {}

    public Announcement(Integer authorUserId, String title, String content) {
        this.authorUserId = authorUserId;
        this.title = title;
        this.content = content;
    }

    // Getters and Setters
    public Integer getAnnouncementId() { return announcementId; }
    public void setAnnouncementId(Integer announcementId) { this.announcementId = announcementId; }

    public Integer getAuthorUserId() { return authorUserId; }
    public void setAuthorUserId(Integer authorUserId) { this.authorUserId = authorUserId; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getContent() { return content; }
    public void setContent(String content) { this.content = content; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public List<AnnouncementAttributeValues> getAttributeValues() { return attributeValues; }
    public void setAttributeValues(List<AnnouncementAttributeValues> attributeValues) { this.attributeValues = attributeValues; }
}
