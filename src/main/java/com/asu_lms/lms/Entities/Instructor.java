package com.asu_lms.lms.Entities;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "Instructor")
public class Instructor {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "InstructorID")
    private int instructorId;

    @Column(name = "InstructorName", nullable = false)
    private String instructorName;

    @Column(name = "InstructorMail", nullable = false, unique = true)
    private String instructorMail;

    @Column(name = "InstructorPassword", nullable = false)
    private String instructorPassword;

    // 🔹 Constructors
    public Instructor() {}

    public Instructor(String instructorName, String instructorMail, String instructorPassword) {
        this.instructorName = instructorName;
        this.instructorMail = instructorMail;
        this.instructorPassword = instructorPassword;
    }

    // 🔹 Getters and Setters
    public int getInstructorId() { return instructorId; }
    public void setInstructorId(int instructorId) { this.instructorId = instructorId; }

    public String getInstructorName() { return instructorName; }
    public void setInstructorName(String instructorName) { this.instructorName = instructorName; }

    public String getInstructorMail() { return instructorMail; }
    public void setInstructorMail(String instructorMail) { this.instructorMail = instructorMail; }

    public String getInstructorPassword() { return instructorPassword; }
    public void setInstructorPassword(String instructorPassword) { this.instructorPassword = instructorPassword; }
    
}
