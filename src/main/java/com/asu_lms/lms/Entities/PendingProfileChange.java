package com.asu_lms.lms.Entities;

import jakarta.persistence.*;

@Entity
@Table(name = "PendingProfileChanges")
public class PendingProfileChange {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "change_id")
    private Integer changeId;

    @Column(name = "user_id", nullable = false)
    private Integer userId;

    @Column(name = "field_name", nullable = false)
    private String fieldName;

    @Column(name = "old_value", columnDefinition = "TEXT")
    private String oldValue;

    @Column(name = "new_value", columnDefinition = "TEXT")
    private String newValue;

    @Enumerated(EnumType.STRING)
    @Column(name = "change_status")
    private ChangeStatus changeStatus;

    @Column(name = "requested_at")
    private java.sql.Timestamp requestedAt;

    @Column(name = "reviewed_at")
    private java.sql.Timestamp reviewedAt;

    @Column(name = "reviewed_by")
    private Integer reviewedBy;

    // Constructors
    public PendingProfileChange() {}

    public PendingProfileChange(Integer userId, String fieldName, String oldValue, String newValue) {
        this.userId = userId;
        this.fieldName = fieldName;
        this.oldValue = oldValue;
        this.newValue = newValue;
        this.changeStatus = ChangeStatus.pending;
        this.requestedAt = new java.sql.Timestamp(System.currentTimeMillis());
    }

    // Getters and Setters
    public Integer getChangeId() {
        return changeId;
    }

    public void setChangeId(Integer changeId) {
        this.changeId = changeId;
    }

    public Integer getUserId() {
        return userId;
    }

    public void setUserId(Integer userId) {
        this.userId = userId;
    }

    public String getFieldName() {
        return fieldName;
    }

    public void setFieldName(String fieldName) {
        this.fieldName = fieldName;
    }

    public String getOldValue() {
        return oldValue;
    }

    public void setOldValue(String oldValue) {
        this.oldValue = oldValue;
    }

    public String getNewValue() {
        return newValue;
    }

    public void setNewValue(String newValue) {
        this.newValue = newValue;
    }

    public ChangeStatus getChangeStatus() {
        return changeStatus;
    }

    public void setChangeStatus(ChangeStatus changeStatus) {
        this.changeStatus = changeStatus;
    }

    public java.sql.Timestamp getRequestedAt() {
        return requestedAt;
    }

    public void setRequestedAt(java.sql.Timestamp requestedAt) {
        this.requestedAt = requestedAt;
    }

    public java.sql.Timestamp getReviewedAt() {
        return reviewedAt;
    }

    public void setReviewedAt(java.sql.Timestamp reviewedAt) {
        this.reviewedAt = reviewedAt;
    }

    public Integer getReviewedBy() {
        return reviewedBy;
    }

    public void setReviewedBy(Integer reviewedBy) {
        this.reviewedBy = reviewedBy;
    }

    // Enum for change status
    public enum ChangeStatus {
        pending, approved, rejected
    }
}
