package com.asu_lms.lms.Entities;

import jakarta.persistence.*;

@Entity
@Table(name = "OfficeHours")
public class OfficeHours {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "office_hours_id")
    private Integer officeHoursId;
    
    @Column(name = "instructor_id", nullable = false)
    private Integer instructorId;
    
    @Column(name = "day_of_week", nullable = false, length = 20)
    private String dayOfWeek;
    
    @Column(name = "start_time", nullable = false, length = 10)
    private String startTime; // Format: "HH:MM" (e.g., "09:00")
    
    @Column(name = "end_time", nullable = false, length = 10)
    private String endTime; // Format: "HH:MM" (e.g., "11:00")
    
    @Column(name = "location", length = 255)
    private String location; // e.g., "Building A, Room 201"
    
    // Constructors
    public OfficeHours() {}
    
    public OfficeHours(Integer instructorId, String dayOfWeek, String startTime, String endTime, String location) {
        this.instructorId = instructorId;
        this.dayOfWeek = dayOfWeek;
        this.startTime = startTime;
        this.endTime = endTime;
        this.location = location;
    }
    
    // Getters and Setters
    public Integer getOfficeHoursId() {
        return officeHoursId;
    }
    
    public void setOfficeHoursId(Integer officeHoursId) {
        this.officeHoursId = officeHoursId;
    }
    
    public Integer getInstructorId() {
        return instructorId;
    }
    
    public void setInstructorId(Integer instructorId) {
        this.instructorId = instructorId;
    }
    
    public String getDayOfWeek() {
        return dayOfWeek;
    }
    
    public void setDayOfWeek(String dayOfWeek) {
        this.dayOfWeek = dayOfWeek;
    }
    
    public String getStartTime() {
        return startTime;
    }
    
    public void setStartTime(String startTime) {
        this.startTime = startTime;
    }
    
    public String getEndTime() {
        return endTime;
    }
    
    public void setEndTime(String endTime) {
        this.endTime = endTime;
    }
    
    public String getLocation() {
        return location;
    }
    
    public void setLocation(String location) {
        this.location = location;
    }
}

