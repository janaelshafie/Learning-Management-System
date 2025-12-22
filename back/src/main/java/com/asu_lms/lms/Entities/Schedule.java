package com.asu_lms.lms.Entities;

import java.sql.Time;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

@Entity
@Table(name = "Schedule")
public class Schedule {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "schedule_id")
    private Integer scheduleId;

    @Column(name = "offered_course_id")
    private Integer offeredCourseId;

    @Column(name = "section_id")
    private Integer sectionId;

    @Column(name = "type", nullable = false)
    private String type;

    @Column(name = "day_of_week", nullable = false)
    private String dayOfWeek;

    @Column(name = "start_time", nullable = false)
    private Time startTime;

    @Column(name = "end_time", nullable = false)
    private Time endTime;

    @Column(name = "location")
    private String location;

    @Column(name = "room_id")
    private Integer roomId;

    // Constructors
    public Schedule() {}

    public Schedule(Integer offeredCourseId, Integer sectionId, String type, 
                   String dayOfWeek, Time startTime, Time endTime, String location) {
        this.offeredCourseId = offeredCourseId;
        this.sectionId = sectionId;
        this.type = type;
        this.dayOfWeek = dayOfWeek;
        this.startTime = startTime;
        this.endTime = endTime;
        this.location = location;
    }

    // Getters and Setters
    public Integer getScheduleId() { return scheduleId; }
    public void setScheduleId(Integer scheduleId) { this.scheduleId = scheduleId; }

    public Integer getOfferedCourseId() { return offeredCourseId; }
    public void setOfferedCourseId(Integer offeredCourseId) { this.offeredCourseId = offeredCourseId; }

    public Integer getSectionId() { return sectionId; }
    public void setSectionId(Integer sectionId) { this.sectionId = sectionId; }

    public String getType() { return type; }
    public void setType(String type) { this.type = type; }

    public String getDayOfWeek() { return dayOfWeek; }
    public void setDayOfWeek(String dayOfWeek) { this.dayOfWeek = dayOfWeek; }

    public Time getStartTime() { return startTime; }
    public void setStartTime(Time startTime) { this.startTime = startTime; }

    public Time getEndTime() { return endTime; }
    public void setEndTime(Time endTime) { this.endTime = endTime; }

    public String getLocation() { return location; }
    public void setLocation(String location) { this.location = location; }

    public Integer getRoomId() { return roomId; }
    public void setRoomId(Integer roomId) { this.roomId = roomId; }
}
