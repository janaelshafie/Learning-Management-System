package com.asu_lms.lms.Entities;

import java.sql.Timestamp;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

@Entity
@Table(name = "RoomReservation")
public class RoomReservation {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "reservation_id")
    private Integer reservationId;

    @Column(name = "room_id", nullable = false)
    private Integer roomId;

    @Column(name = "reserved_by_user_id", nullable = false)
    private Integer reservedByUserId;

    @Column(name = "assignment_type", nullable = false)
    private String assignmentType; // 'course', 'instructor', 'department', 'event', 'exam', 'maintenance'

    @Column(name = "related_offered_course_id")
    private Integer relatedOfferedCourseId;

    @Column(name = "related_section_id")
    private Integer relatedSectionId;

    @Column(name = "start_datetime", nullable = false)
    private Timestamp startDatetime;

    @Column(name = "end_datetime", nullable = false)
    private Timestamp endDatetime;

    @Column(name = "status", nullable = false)
    private String status = "pending";

    @Column(name = "purpose", columnDefinition = "TEXT")
    private String purpose;

    @Column(name = "requested_at", nullable = false)
    private Timestamp requestedAt = new Timestamp(System.currentTimeMillis());

    @Column(name = "approved_by_user_id")
    private Integer approvedByUserId;

    @Column(name = "approved_at")
    private Timestamp approvedAt;

    @Column(name = "notes", columnDefinition = "TEXT")
    private String notes;

    @Column(name = "is_recurring", nullable = false)
    private Boolean isRecurring = false;

    @Column(name = "recurrence_pattern")
    private String recurrencePattern;

    @Column(name = "recurrence_end_date")
    private java.sql.Date recurrenceEndDate;

    @Column(name = "parent_reservation_id")
    private Integer parentReservationId;

    @Column(name = "related_department_id")
    private Integer relatedDepartmentId;

    @Column(name = "related_instructor_id")
    private Integer relatedInstructorId;

    // Constructors
    public RoomReservation() {}

    public RoomReservation(Integer roomId, Integer reservedByUserId, String assignmentType, 
                          Timestamp startDatetime, Timestamp endDatetime) {
        this.roomId = roomId;
        this.reservedByUserId = reservedByUserId;
        this.assignmentType = assignmentType;
        this.startDatetime = startDatetime;
        this.endDatetime = endDatetime;
        this.status = "pending";
        this.requestedAt = new Timestamp(System.currentTimeMillis());
    }

    // Getters and Setters
    public Integer getReservationId() { return reservationId; }
    public void setReservationId(Integer reservationId) { this.reservationId = reservationId; }

    public Integer getRoomId() { return roomId; }
    public void setRoomId(Integer roomId) { this.roomId = roomId; }

    public Integer getReservedByUserId() { return reservedByUserId; }
    public void setReservedByUserId(Integer reservedByUserId) { this.reservedByUserId = reservedByUserId; }

    public Integer getRelatedOfferedCourseId() { return relatedOfferedCourseId; }
    public void setRelatedOfferedCourseId(Integer relatedOfferedCourseId) { this.relatedOfferedCourseId = relatedOfferedCourseId; }

    public Integer getRelatedSectionId() { return relatedSectionId; }
    public void setRelatedSectionId(Integer relatedSectionId) { this.relatedSectionId = relatedSectionId; }

    public Timestamp getStartDatetime() { return startDatetime; }
    public void setStartDatetime(Timestamp startDatetime) { this.startDatetime = startDatetime; }

    public Timestamp getEndDatetime() { return endDatetime; }
    public void setEndDatetime(Timestamp endDatetime) { this.endDatetime = endDatetime; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public String getPurpose() { return purpose; }
    public void setPurpose(String purpose) { this.purpose = purpose; }

    public Timestamp getRequestedAt() { return requestedAt; }
    public void setRequestedAt(Timestamp requestedAt) { this.requestedAt = requestedAt; }

    public Integer getApprovedByUserId() { return approvedByUserId; }
    public void setApprovedByUserId(Integer approvedByUserId) { this.approvedByUserId = approvedByUserId; }

    public Timestamp getApprovedAt() { return approvedAt; }
    public void setApprovedAt(Timestamp approvedAt) { this.approvedAt = approvedAt; }

    public String getNotes() { return notes; }
    public void setNotes(String notes) { this.notes = notes; }

    public Boolean getIsRecurring() { return isRecurring; }
    public void setIsRecurring(Boolean isRecurring) { this.isRecurring = isRecurring; }

    public String getRecurrencePattern() { return recurrencePattern; }
    public void setRecurrencePattern(String recurrencePattern) { this.recurrencePattern = recurrencePattern; }

    public java.sql.Date getRecurrenceEndDate() { return recurrenceEndDate; }
    public void setRecurrenceEndDate(java.sql.Date recurrenceEndDate) { this.recurrenceEndDate = recurrenceEndDate; }

    public Integer getParentReservationId() { return parentReservationId; }
    public void setParentReservationId(Integer parentReservationId) { this.parentReservationId = parentReservationId; }

    public Integer getRelatedDepartmentId() { return relatedDepartmentId; }
    public void setRelatedDepartmentId(Integer relatedDepartmentId) { this.relatedDepartmentId = relatedDepartmentId; }

    public Integer getRelatedInstructorId() { return relatedInstructorId; }
    public void setRelatedInstructorId(Integer relatedInstructorId) { this.relatedInstructorId = relatedInstructorId; }

    public String getAssignmentType() { return assignmentType; }
    public void setAssignmentType(String assignmentType) { this.assignmentType = assignmentType; }
}
