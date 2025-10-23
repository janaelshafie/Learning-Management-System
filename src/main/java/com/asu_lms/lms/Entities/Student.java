package com.asu_lms.lms.Entities;

import jakarta.persistence.*;

import java.math.BigDecimal;

@Entity
@Table(name = "student")
public class Student {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "StudentID")
    private int studentId;

    @Column(name = "UserName", nullable = false)
    private String userName;

    @Column(name = "Studentmail", nullable = false, unique = true)
    private String studentMail;

    @Column(name = "StudentGpa", precision = 3, scale = 2)
    private BigDecimal studentGpa;

    @Column(name = "HighestGpa", precision = 3, scale = 2)
    private BigDecimal highestGpa;

    @Column(name = "LowestGpa", precision = 3, scale = 2)
    private BigDecimal lowestGpa;

    @Column(name = "CourseGpa", precision = 3, scale = 2)
    private BigDecimal courseGpa;

    @Column(name = "StudentPassword", nullable = false)
    private String studentPassword;

    // Constructors
    public Student() {}

    public Student(String userName, String studentMail, BigDecimal studentGpa,
                   BigDecimal highestGpa, BigDecimal lowestGpa, BigDecimal courseGpa,
                   String studentPassword) {
        this.userName = userName;
        this.studentMail = studentMail;
        this.studentGpa = studentGpa;
        this.highestGpa = highestGpa;
        this.lowestGpa = lowestGpa;
        this.courseGpa = courseGpa;
        this.studentPassword = studentPassword;
    }

    // Getters and Setters
    public int getStudentId() { return studentId; }
    public void setStudentId(int studentId) { this.studentId = studentId; }

    public String getUserName() { return userName; }
    public void setUserName(String userName) { this.userName = userName; }

    public String getStudentMail() { return studentMail; }
    public void setStudentMail(String studentMail) { this.studentMail = studentMail; }

    public BigDecimal getStudentGpa() { return studentGpa; }
    public void setStudentGpa(BigDecimal studentGpa) { this.studentGpa = studentGpa; }

    public BigDecimal getHighestGpa() { return highestGpa; }
    public void setHighestGpa(BigDecimal highestGpa) { this.highestGpa = highestGpa; }

    public BigDecimal getLowestGpa() { return lowestGpa; }
    public void setLowestGpa(BigDecimal lowestGpa) { this.lowestGpa = lowestGpa; }

    public BigDecimal getCourseGpa() { return courseGpa; }
    public void setCourseGpa(BigDecimal courseGpa) { this.courseGpa = courseGpa; }

    public String getStudentPassword() { return studentPassword; }
    public void setStudentPassword(String studentPassword) { this.studentPassword = studentPassword; }

}