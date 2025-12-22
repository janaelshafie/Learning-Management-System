package com.asu_lms.lms.Entities;

import jakarta.persistence.*;
import java.math.BigDecimal;

@Entity
@Table(name = "Student")
public class Student {
    @Id
    @Column(name = "student_id")
    private Integer studentId;

    @Column(name = "student_uid")
    private String studentUid;

    @Column(name = "cumulative_gpa", precision = 3, scale = 2)
    private BigDecimal cumulativeGpa;

    @Column(name = "department_id")
    private Integer departmentId;

    @Column(name = "advisor_id")
    private Integer advisorId;

    @Column(name = "parent_user_id")
    private Integer parentUserId;

    // Constructors
    public Student() {}

    public Student(Integer studentId, String studentUid, BigDecimal cumulativeGpa, Integer departmentId, Integer advisorId, Integer parentUserId) {
        this.studentId = studentId;
        this.studentUid = studentUid;
        this.cumulativeGpa = cumulativeGpa;
        this.departmentId = departmentId;
        this.advisorId = advisorId;
        this.parentUserId = parentUserId;
    }

    // Getters and Setters
    public Integer getStudentId() { return studentId; }
    public void setStudentId(Integer studentId) { this.studentId = studentId; }

    public String getStudentUid() { return studentUid; }
    public void setStudentUid(String studentUid) { this.studentUid = studentUid; }

    public BigDecimal getCumulativeGpa() { return cumulativeGpa; }
    public void setCumulativeGpa(BigDecimal cumulativeGpa) { this.cumulativeGpa = cumulativeGpa; }

    public Integer getDepartmentId() { return departmentId; }
    public void setDepartmentId(Integer departmentId) { this.departmentId = departmentId; }

    public Integer getAdvisorId() { return advisorId; }
    public void setAdvisorId(Integer advisorId) { this.advisorId = advisorId; }

    public Integer getParentUserId() { return parentUserId; }
    public void setParentUserId(Integer parentUserId) { this.parentUserId = parentUserId; }
}
