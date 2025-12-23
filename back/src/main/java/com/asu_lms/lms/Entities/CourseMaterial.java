package com.asu_lms.lms.Entities;

import jakarta.persistence.*;
import java.sql.Timestamp;

@Entity
@Table(name = "CourseMaterial")
public class CourseMaterial {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "material_id")
    private Integer materialId;

    @Column(name = "offered_course_id", nullable = false)
    private Integer offeredCourseId;

    @Column(name = "instructor_id")
    private Integer instructorId;

    @Column(name = "title", nullable = false)
    private String title;

    @Column(name = "file_name")
    private String fileName;

    @Column(name = "file_size")
    private Long fileSize;

    @Column(name = "mime_type")
    private String mimeType;

    @Column(name = "type", nullable = false, length = 20)
    private String type;

    @Column(name = "url_or_path", nullable = false, length = 1024)
    private String urlOrPath;

    @Column(name = "uploaded_at", nullable = false)
    private Timestamp uploadedAt = new Timestamp(System.currentTimeMillis());

    // Constructors
    public CourseMaterial() {}

    public CourseMaterial(Integer offeredCourseId, Integer instructorId, String title, 
                         String fileName, Long fileSize, String mimeType, String type, String urlOrPath) {
        this.offeredCourseId = offeredCourseId;
        this.instructorId = instructorId;
        this.title = title;
        this.fileName = fileName;
        this.fileSize = fileSize;
        this.mimeType = mimeType;
        this.type = type;
        this.urlOrPath = urlOrPath;
    }

    // Getters and Setters
    public Integer getMaterialId() { return materialId; }
    public void setMaterialId(Integer materialId) { this.materialId = materialId; }

    public Integer getOfferedCourseId() { return offeredCourseId; }
    public void setOfferedCourseId(Integer offeredCourseId) { this.offeredCourseId = offeredCourseId; }

    public Integer getInstructorId() { return instructorId; }
    public void setInstructorId(Integer instructorId) { this.instructorId = instructorId; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getFileName() { return fileName; }
    public void setFileName(String fileName) { this.fileName = fileName; }

    public Long getFileSize() { return fileSize; }
    public void setFileSize(Long fileSize) { this.fileSize = fileSize; }

    public String getMimeType() { return mimeType; }
    public void setMimeType(String mimeType) { this.mimeType = mimeType; }

    public String getType() { return type; }
    public void setType(String type) { this.type = type; }

    public String getUrlOrPath() { return urlOrPath; }
    public void setUrlOrPath(String urlOrPath) { this.urlOrPath = urlOrPath; }

    public Timestamp getUploadedAt() { return uploadedAt; }
    public void setUploadedAt(Timestamp uploadedAt) { this.uploadedAt = uploadedAt; }
}

