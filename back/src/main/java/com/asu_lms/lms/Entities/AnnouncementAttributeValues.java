package com.asu_lms.lms.Entities;

import jakarta.persistence.*;

@Entity
@Table(name = "AnnouncementAttributeValues")
public class AnnouncementAttributeValues {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "aav_id")
    private Integer aavId;

    @ManyToOne
    @JoinColumn(name = "announcement_id", nullable = false)
    private Announcement announcement;

    @ManyToOne
    @JoinColumn(name = "attribute_id", nullable = false)
    private AnnouncementAttributes attribute;

    @Column(name = "value", columnDefinition = "TEXT")
    private String value;

    // Constructors
    public AnnouncementAttributeValues() {}

    public AnnouncementAttributeValues(Announcement announcement, AnnouncementAttributes attribute, String value) {
        this.announcement = announcement;
        this.attribute = attribute;
        this.value = value;
    }

    // Getters and Setters
    public Integer getAavId() { return aavId; }
    public void setAavId(Integer aavId) { this.aavId = aavId; }

    public Announcement getAnnouncement() { return announcement; }
    public void setAnnouncement(Announcement announcement) { this.announcement = announcement; }

    public AnnouncementAttributes getAttribute() { return attribute; }
    public void setAttribute(AnnouncementAttributes attribute) { this.attribute = attribute; }

    public String getValue() { return value; }
    public void setValue(String value) { this.value = value; }
}

