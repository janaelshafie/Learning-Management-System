package com.asu_lms.lms.Entities;

import jakarta.persistence.*;
import java.sql.Date;

@Entity
@Table(name = "Semester")
public class Semester {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "semester_id")
    private Integer semesterId;
    
    @Column(name = "name", nullable = false)
    private String name;
    
    @Column(name = "start_date", nullable = false)
    private Date startDate;
    
    @Column(name = "end_date", nullable = false)
    private Date endDate;
    
    @Column(name = "registration_open", nullable = false)
    private Boolean registrationOpen;
    
    // Constructors
    public Semester() {}
    
    public Semester(String name, Date startDate, Date endDate, Boolean registrationOpen) {
        this.name = name;
        this.startDate = startDate;
        this.endDate = endDate;
        this.registrationOpen = registrationOpen;
    }
    
    // Getters and Setters
    public Integer getSemesterId() {
        return semesterId;
    }
    
    public void setSemesterId(Integer semesterId) {
        this.semesterId = semesterId;
    }
    
    public String getName() {
        return name;
    }
    
    public void setName(String name) {
        this.name = name;
    }
    
    public Date getStartDate() {
        return startDate;
    }
    
    public void setStartDate(Date startDate) {
        this.startDate = startDate;
    }
    
    public Date getEndDate() {
        return endDate;
    }
    
    public void setEndDate(Date endDate) {
        this.endDate = endDate;
    }
    
    public Boolean getRegistrationOpen() {
        return registrationOpen;
    }
    
    public void setRegistrationOpen(Boolean registrationOpen) {
        this.registrationOpen = registrationOpen;
    }
}



