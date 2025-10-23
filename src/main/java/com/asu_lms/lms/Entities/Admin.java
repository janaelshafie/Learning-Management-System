package com.asu_lms.lms.Entities;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "Admin")
public class Admin {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "AdminID")
    private int adminId;

    @Column(name = "AdminName", nullable = false)
    private String adminName;

    @Column(name = "AdminMail", nullable = false, unique = true)
    private String adminMail;

    @Column(name = "AdminPassword", nullable = false)
    private String adminPassword;

    @Column(name = "CreatedAt", columnDefinition = "TIMESTAMP DEFAULT CURRENT_TIMESTAMP")
    private LocalDateTime createdAt;

    // 🔹 Constructors
    public Admin() {}

    public Admin(String adminName, String adminMail, String adminPassword) {
        this.adminName = adminName;
        this.adminMail = adminMail;
        this.adminPassword = adminPassword;
        this.createdAt = LocalDateTime.now();
    }

    // 🔹 Getters and Setters
    public int getAdminId() { return adminId; }
    public void setAdminId(int adminId) { this.adminId = adminId; }

    public String getAdminName() { return adminName; }
    public void setAdminName(String adminName) { this.adminName = adminName; }

    public String getAdminMail() { return adminMail; }
    public void setAdminMail(String adminMail) { this.adminMail = adminMail; }

    public String getAdminPassword() { return adminPassword; }
    public void setAdminPassword(String adminPassword) { this.adminPassword = adminPassword; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
}
