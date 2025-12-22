package com.asu_lms.lms.Entities;

import java.sql.Timestamp;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

@Entity
@Table(name = "Rooms")
public class Rooms {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "room_id")
    private Integer roomId;

    @Column(name = "building")
    private String building;

    @Column(name = "room_name", nullable = false)
    private String roomName;

    @Column(name = "room_type", nullable = false)
    private String roomType;

    @Column(name = "capacity")
    private Integer capacity;

    @Column(name = "description", columnDefinition = "TEXT")
    private String description;

    @Column(name = "status", nullable = false)
    private String status = "available";

    @Column(name = "status_notes", columnDefinition = "TEXT")
    private String statusNotes;

    @Column(name = "status_updated_at")
    private Timestamp statusUpdatedAt;

    @Column(name = "status_updated_by_user_id")
    private Integer statusUpdatedByUserId;

    // Constructors
    public Rooms() {}

    public Rooms(String building, String roomName, String roomType, Integer capacity, String description) {
        this.building = building;
        this.roomName = roomName;
        this.roomType = roomType;
        this.capacity = capacity;
        this.description = description;
        this.status = "available";
    }

    // Getters and Setters
    public Integer getRoomId() { return roomId; }
    public void setRoomId(Integer roomId) { this.roomId = roomId; }

    public String getBuilding() { return building; }
    public void setBuilding(String building) { this.building = building; }

    public String getRoomName() { return roomName; }
    public void setRoomName(String roomName) { this.roomName = roomName; }

    public String getRoomType() { return roomType; }
    public void setRoomType(String roomType) { this.roomType = roomType; }

    public Integer getCapacity() { return capacity; }
    public void setCapacity(Integer capacity) { this.capacity = capacity; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public String getStatusNotes() { return statusNotes; }
    public void setStatusNotes(String statusNotes) { this.statusNotes = statusNotes; }

    public Timestamp getStatusUpdatedAt() { return statusUpdatedAt; }
    public void setStatusUpdatedAt(Timestamp statusUpdatedAt) { this.statusUpdatedAt = statusUpdatedAt; }

    public Integer getStatusUpdatedByUserId() { return statusUpdatedByUserId; }
    public void setStatusUpdatedByUserId(Integer statusUpdatedByUserId) { this.statusUpdatedByUserId = statusUpdatedByUserId; }
}
