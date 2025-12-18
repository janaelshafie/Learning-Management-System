package com.asu_lms.lms.Entities;

import java.math.BigDecimal;
import java.sql.Timestamp;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

@Entity
@Table(name = "RoomMaintenanceIssue")
public class RoomMaintenanceIssue {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "issue_id")
    private Integer issueId;

    @Column(name = "room_id", nullable = false)
    private Integer roomId;

    @Column(name = "reported_by_user_id", nullable = false)
    private Integer reportedByUserId;

    @Column(name = "issue_type", nullable = false)
    private String issueType;

    @Column(name = "priority", nullable = false)
    private String priority = "medium";

    @Column(name = "title", nullable = false)
    private String title;

    @Column(name = "description", columnDefinition = "TEXT", nullable = false)
    private String description;

    @Column(name = "status", nullable = false)
    private String status = "reported";

    @Column(name = "reported_at", nullable = false)
    private Timestamp reportedAt = new Timestamp(System.currentTimeMillis());

    @Column(name = "assigned_to_user_id")
    private Integer assignedToUserId;

    @Column(name = "assigned_at")
    private Timestamp assignedAt;

    @Column(name = "resolved_at")
    private Timestamp resolvedAt;

    @Column(name = "resolved_by_user_id")
    private Integer resolvedByUserId;

    @Column(name = "resolution_notes", columnDefinition = "TEXT")
    private String resolutionNotes;

    @Column(name = "estimated_cost", precision = 10, scale = 2)
    private BigDecimal estimatedCost;

    @Column(name = "actual_cost", precision = 10, scale = 2)
    private BigDecimal actualCost;

    @Column(name = "attachments_json", columnDefinition = "JSON")
    private String attachmentsJson;

    // Constructors
    public RoomMaintenanceIssue() {}

    public RoomMaintenanceIssue(Integer roomId, Integer reportedByUserId, String issueType, 
                               String title, String description) {
        this.roomId = roomId;
        this.reportedByUserId = reportedByUserId;
        this.issueType = issueType;
        this.title = title;
        this.description = description;
        this.status = "reported";
        this.priority = "medium";
        this.reportedAt = new Timestamp(System.currentTimeMillis());
    }

    // Getters and Setters
    public Integer getIssueId() { return issueId; }
    public void setIssueId(Integer issueId) { this.issueId = issueId; }

    public Integer getRoomId() { return roomId; }
    public void setRoomId(Integer roomId) { this.roomId = roomId; }

    public Integer getReportedByUserId() { return reportedByUserId; }
    public void setReportedByUserId(Integer reportedByUserId) { this.reportedByUserId = reportedByUserId; }

    public String getIssueType() { return issueType; }
    public void setIssueType(String issueType) { this.issueType = issueType; }

    public String getPriority() { return priority; }
    public void setPriority(String priority) { this.priority = priority; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public Timestamp getReportedAt() { return reportedAt; }
    public void setReportedAt(Timestamp reportedAt) { this.reportedAt = reportedAt; }

    public Integer getAssignedToUserId() { return assignedToUserId; }
    public void setAssignedToUserId(Integer assignedToUserId) { this.assignedToUserId = assignedToUserId; }

    public Timestamp getAssignedAt() { return assignedAt; }
    public void setAssignedAt(Timestamp assignedAt) { this.assignedAt = assignedAt; }

    public Timestamp getResolvedAt() { return resolvedAt; }
    public void setResolvedAt(Timestamp resolvedAt) { this.resolvedAt = resolvedAt; }

    public Integer getResolvedByUserId() { return resolvedByUserId; }
    public void setResolvedByUserId(Integer resolvedByUserId) { this.resolvedByUserId = resolvedByUserId; }

    public String getResolutionNotes() { return resolutionNotes; }
    public void setResolutionNotes(String resolutionNotes) { this.resolutionNotes = resolutionNotes; }

    public BigDecimal getEstimatedCost() { return estimatedCost; }
    public void setEstimatedCost(BigDecimal estimatedCost) { this.estimatedCost = estimatedCost; }

    public BigDecimal getActualCost() { return actualCost; }
    public void setActualCost(BigDecimal actualCost) { this.actualCost = actualCost; }

    public String getAttachmentsJson() { return attachmentsJson; }
    public void setAttachmentsJson(String attachmentsJson) { this.attachmentsJson = attachmentsJson; }
}
