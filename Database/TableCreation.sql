-- -----------------------------------------------------------------
-- --- University LMS Schema Script (MySQL Compatible) - EAV Model ---
-- --- Schema Only - No Data ---
-- -----------------------------------------------------------------

DROP DATABASE IF EXISTS university_lms_db;
CREATE DATABASE university_lms_db;
USE university_lms_db;

-- -----------------------------------------------------
-- Drop all tables (reverse dependency order)
-- -----------------------------------------------------
DROP TABLE IF EXISTS RoomMaintenanceIssue;
DROP TABLE IF EXISTS RoomReservation;
DROP TABLE IF EXISTS PendingProfileChanges;
DROP TABLE IF EXISTS Message;
DROP TABLE IF EXISTS AnnouncementAttributeValues;
DROP TABLE IF EXISTS AnnouncementAttributes;
DROP TABLE IF EXISTS Announcement;
DROP TABLE IF EXISTS QuizAttributeValues;
DROP TABLE IF EXISTS QuizAttributes;
DROP TABLE IF EXISTS Quiz;
DROP TABLE IF EXISTS AssignmentAttributeValues;
DROP TABLE IF EXISTS AssignmentAttributes;
DROP TABLE IF EXISTS AssignmentSubmission;
DROP TABLE IF EXISTS Assignment;
DROP TABLE IF EXISTS CourseMaterialAttributeValues;
DROP TABLE IF EXISTS CourseMaterialAttributes;
DROP TABLE IF EXISTS CourseMaterial;
DROP TABLE IF EXISTS GradeAttributeValues;
DROP TABLE IF EXISTS GradeAttributes;
DROP TABLE IF EXISTS Grade;
DROP TABLE IF EXISTS StudentAnswerAttributeValues;
DROP TABLE IF EXISTS StudentAnswerAttributes;
DROP TABLE IF EXISTS StudentAnswers;
DROP TABLE IF EXISTS QuestionAttributeValues;
DROP TABLE IF EXISTS QuestionAttributes;
DROP TABLE IF EXISTS Questions;
DROP TABLE IF EXISTS EnrollmentAttributeValues;
DROP TABLE IF EXISTS EnrollmentAttributes;
DROP TABLE IF EXISTS Enrollment;
DROP TABLE IF EXISTS OfferedCourse_Instructor;
DROP TABLE IF EXISTS Section;
DROP TABLE IF EXISTS OfferedCourse;
DROP TABLE IF EXISTS DepartmentCourse;
DROP TABLE IF EXISTS Prerequisite;
DROP TABLE IF EXISTS Semester;
DROP TABLE IF EXISTS Course;
DROP TABLE IF EXISTS Student;
DROP TABLE IF EXISTS RoomAttributeValues;
DROP TABLE IF EXISTS RoomAttributes;
DROP TABLE IF EXISTS Rooms;
DROP TABLE IF EXISTS Department;
DROP TABLE IF EXISTS Instructor;
DROP TABLE IF EXISTS `User`;

-- =================================================================
-- SECTION 1: FIXED SCHEMA TABLES
-- =================================================================
-- These tables use traditional relational design with fixed columns.
-- They represent core entities with stable, well-defined attributes.
-- =================================================================

-- -----------------------------------------------------
-- 1.1 Core User & Role Tables
-- -----------------------------------------------------
CREATE TABLE `User` (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    national_id VARCHAR(255) NOT NULL UNIQUE,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    official_mail VARCHAR(255) NOT NULL UNIQUE,
    phone VARCHAR(20),
    location VARCHAR(255),
    password_hash VARCHAR(255) NOT NULL,
    role VARCHAR(10) NOT NULL CHECK (role IN ('student', 'instructor', 'admin', 'parent')),
    account_status VARCHAR(10) NOT NULL DEFAULT 'active'
) ENGINE=InnoDB;

-- -----------------------------------------------------
-- 1.2 Departments & Instructors
-- -----------------------------------------------------
CREATE TABLE Department (
    department_id INT AUTO_INCREMENT PRIMARY KEY,
    department_code VARCHAR(20) NOT NULL UNIQUE,
    name VARCHAR(255) NOT NULL,
    unit_head_id INT NULL
) ENGINE=InnoDB;

CREATE TABLE Instructor (
    instructor_id INT PRIMARY KEY,
    instructor_type VARCHAR(10) NOT NULL CHECK (instructor_type IN ('professor', 'ta')),
    office_hours VARCHAR(255),
    department_id INT,
    FOREIGN KEY (instructor_id) REFERENCES `User`(user_id)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION
) ENGINE=InnoDB;

ALTER TABLE Department
ADD CONSTRAINT fk_department_unit_head
FOREIGN KEY (unit_head_id) REFERENCES Instructor(instructor_id)
    ON DELETE SET NULL
    ON UPDATE NO ACTION;

ALTER TABLE Instructor
ADD CONSTRAINT fk_instructor_department
FOREIGN KEY (department_id) REFERENCES Department(department_id)
    ON DELETE SET NULL
    ON UPDATE NO ACTION;

-- -----------------------------------------------------
-- 1.3 Students
-- -----------------------------------------------------
CREATE TABLE Student (
    student_id INT PRIMARY KEY,
    student_uid VARCHAR(100) NOT NULL UNIQUE,
    cumulative_gpa DECIMAL(3, 2),
    department_id INT,
    advisor_id INT,
    -- Keep optional link to parent user account if parent has a user account
    parent_user_id INT NULL,
    FOREIGN KEY (student_id) REFERENCES `User`(user_id)
        ON DELETE CASCADE
        ON UPDATE NO ACTION,
    FOREIGN KEY (department_id) REFERENCES Department(department_id)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION,
    FOREIGN KEY (advisor_id) REFERENCES Instructor(instructor_id)
        ON DELETE SET NULL
        ON UPDATE NO ACTION,
    FOREIGN KEY (parent_user_id) REFERENCES `User`(user_id)
        ON DELETE SET NULL
        ON UPDATE NO ACTION
) ENGINE=InnoDB;

-- -----------------------------------------------------
-- 1.4 Academic Entities (Fixed Schema)
-- -----------------------------------------------------
CREATE TABLE Course (
    course_id INT AUTO_INCREMENT PRIMARY KEY,
    course_code VARCHAR(20) NOT NULL UNIQUE,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    credits INT NOT NULL,
    course_type VARCHAR(10) CHECK (course_type IN ('core', 'elective')),
    department_code VARCHAR(20) NOT NULL,
    FOREIGN KEY (department_code) REFERENCES Department(department_code)
        ON DELETE NO ACTION
        ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE Semester (
    semester_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    registration_open TINYINT(1) NOT NULL DEFAULT 0
) ENGINE=InnoDB;

CREATE TABLE Prerequisite (
    course_id INT NOT NULL,
    prereq_course_id INT NOT NULL,
    PRIMARY KEY (course_id, prereq_course_id),
    FOREIGN KEY (course_id) REFERENCES Course(course_id)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION,
    FOREIGN KEY (prereq_course_id) REFERENCES Course(course_id)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION,
    CHECK (course_id != prereq_course_id)
) ENGINE=InnoDB;

-- DepartmentCourse: Many-to-many relationship for courses that can be taken by multiple departments
-- Note: Each Course has a primary department via department_code in the Course table.
-- This table allows courses to be available to additional departments beyond their primary department.
CREATE TABLE DepartmentCourse (
    department_id INT NOT NULL,
    course_id INT NOT NULL,
    course_type VARCHAR(10) NOT NULL CHECK (course_type IN ('core', 'elective')),
    capacity INT,
    eligibility_requirements TEXT,
    PRIMARY KEY (department_id, course_id),
    FOREIGN KEY (department_id) REFERENCES Department(department_id)
        ON DELETE CASCADE
        ON UPDATE NO ACTION,
    FOREIGN KEY (course_id) REFERENCES Course(course_id)
        ON DELETE CASCADE
        ON UPDATE NO ACTION
) ENGINE=InnoDB;

CREATE TABLE OfferedCourse (
    offered_course_id INT AUTO_INCREMENT PRIMARY KEY,
    course_id INT NOT NULL,
    semester_id INT NOT NULL,
    FOREIGN KEY (course_id) REFERENCES Course(course_id)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION,
    FOREIGN KEY (semester_id) REFERENCES Semester(semester_id)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION,
    UNIQUE(course_id, semester_id)
) ENGINE=InnoDB;

CREATE TABLE Section (
    section_id INT AUTO_INCREMENT PRIMARY KEY,
    offered_course_id INT NOT NULL,
    ta_instructor_id INT,
    section_number VARCHAR(20) NOT NULL,
    capacity INT NOT NULL DEFAULT 40,
    current_enrollment INT NOT NULL DEFAULT 0,
    FOREIGN KEY (offered_course_id) REFERENCES OfferedCourse(offered_course_id)
        ON DELETE CASCADE
        ON UPDATE NO ACTION,
    FOREIGN KEY (ta_instructor_id) REFERENCES Instructor(instructor_id)
        ON DELETE SET NULL
        ON UPDATE NO ACTION
) ENGINE=InnoDB;

CREATE TABLE OfferedCourse_Instructor (
    offered_course_id INT NOT NULL,
    instructor_id INT NOT NULL,
    PRIMARY KEY (offered_course_id, instructor_id),
    FOREIGN KEY (offered_course_id) REFERENCES OfferedCourse(offered_course_id)
        ON DELETE CASCADE
        ON UPDATE NO ACTION,
    FOREIGN KEY (instructor_id) REFERENCES Instructor(instructor_id)
        ON DELETE CASCADE
        ON UPDATE NO ACTION
) ENGINE=InnoDB;

-- -----------------------------------------------------
-- 1.5 Enrollment (Moved to EAV Model section)
-- -----------------------------------------------------
-- Note: Enrollment moved to EAV Model section for flexible enrollment metadata

-- -----------------------------------------------------
-- 1.6 Communication & Misc Tables (Fixed Schema)
-- -----------------------------------------------------
-- Note: AssignmentSubmission moved after Assignment table (references Assignment)
-- Note: Announcement moved to EAV Model section (unified for admin and instructor)

CREATE TABLE Message (
    message_id INT AUTO_INCREMENT PRIMARY KEY,
    sender_user_id INT NOT NULL,
    recipient_user_id INT NOT NULL,
    content TEXT NOT NULL,
    sent_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    read_at DATETIME,
    FOREIGN KEY (sender_user_id) REFERENCES `User`(user_id)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION,
    FOREIGN KEY (recipient_user_id) REFERENCES `User`(user_id)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION
) ENGINE=InnoDB;

CREATE TABLE PendingProfileChanges (
    change_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    field_name VARCHAR(50) NOT NULL,
    old_value TEXT,
    new_value TEXT,
    change_status ENUM('pending', 'approved', 'rejected') DEFAULT 'pending',
    requested_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    reviewed_at TIMESTAMP NULL,
    reviewed_by INT NULL,
    FOREIGN KEY (user_id) REFERENCES `User`(user_id),
    FOREIGN KEY (reviewed_by) REFERENCES `User`(user_id)
) ENGINE=InnoDB;

-- =================================================================
-- SECTION 2: EAV MODEL TABLES
-- =================================================================
-- These tables use Entity-Attribute-Value (EAV) design pattern.
-- EAV allows flexible, extensible attributes without schema changes.
-- Each EAV model consists of:
--   1. Base table (entity) - stores core, stable attributes
--   2. Attributes table - defines available attributes
--   3. AttributeValues table - stores actual attribute values
-- =================================================================

-- -----------------------------------------------------
-- 2.1 Enrollment EAV Model
-- -----------------------------------------------------
-- WHY EAV: Enrollments have variable metadata:
-- - Enrollment tracking: enrollment_date, approval_date, withdrawal_date
-- - Status management: status, withdrawal_reason, rejection_reason
-- - Financial: financial_aid_status, scholarship_info, payment_status
-- - Administrative: waitlist_position, special_notes, advisor_notes, approval_notes
-- - Academic: prerequisite_waivers, special_permissions
-- EAV allows flexible enrollment tracking without schema changes.
-- 
-- Base table stores: student_id, section_id (core enrollment relationship)
-- EAV stores: status, enrollment_date, withdrawal_date, withdrawal_reason,
--             financial_aid_status, scholarship_info_json, waitlist_position,
--             special_notes, advisor_notes, approval_notes, payment_status, etc.
-- -----------------------------------------------------
CREATE TABLE Enrollment (
    enrollment_id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,
    section_id INT NOT NULL,
    FOREIGN KEY (student_id) REFERENCES Student(student_id)
        ON DELETE CASCADE
        ON UPDATE NO ACTION,
    FOREIGN KEY (section_id) REFERENCES Section(section_id)
        ON DELETE CASCADE
        ON UPDATE NO ACTION,
    UNIQUE(student_id, section_id)
) ENGINE=InnoDB;

CREATE TABLE EnrollmentAttributes (
    attribute_id INT AUTO_INCREMENT PRIMARY KEY,
    attribute_name VARCHAR(255) NOT NULL UNIQUE,
    value_type VARCHAR(20) NOT NULL DEFAULT 'text' -- 'text','int','bool','datetime','decimal','json'
) ENGINE=InnoDB;

CREATE TABLE EnrollmentAttributeValues (
    eav_id INT AUTO_INCREMENT PRIMARY KEY,
    enrollment_id INT NOT NULL,
    attribute_id INT NOT NULL,
    value TEXT,
    FOREIGN KEY (enrollment_id) REFERENCES Enrollment(enrollment_id)
        ON DELETE CASCADE
        ON UPDATE NO ACTION,
    FOREIGN KEY (attribute_id) REFERENCES EnrollmentAttributes(attribute_id)
        ON DELETE CASCADE
        ON UPDATE NO ACTION,
    UNIQUE(enrollment_id, attribute_id)
) ENGINE=InnoDB;

-- Enrollment attributes are created dynamically as needed through the EAV service

-- -----------------------------------------------------
-- 2.2 Grade EAV Model
-- -----------------------------------------------------
-- WHY EAV: Different courses have different grading schemes.
-- Some courses have labs, presentations, peer reviews, etc.
-- EAV allows flexible grade components per course without schema changes.
-- 
-- Base table stores: enrollment reference, final letter grade
-- EAV stores: midterm, project, assignments, quizzes, attendance, 
--             labs, presentations, participation, custom components
-- -----------------------------------------------------
CREATE TABLE Grade (
    grade_id INT AUTO_INCREMENT PRIMARY KEY,
    enrollment_id INT NOT NULL UNIQUE,
    final_letter_grade VARCHAR(2),
    FOREIGN KEY (enrollment_id) REFERENCES Enrollment(enrollment_id)
        ON DELETE CASCADE
        ON UPDATE NO ACTION
) ENGINE=InnoDB;

CREATE TABLE GradeAttributes (
    attribute_id INT AUTO_INCREMENT PRIMARY KEY,
    attribute_name VARCHAR(255) NOT NULL UNIQUE,
    value_type VARCHAR(20) NOT NULL DEFAULT 'decimal', -- 'decimal','int','text'
    max_value DECIMAL(5, 2) NULL, -- Optional max value for validation
    description TEXT -- Optional description of the attribute
) ENGINE=InnoDB;

CREATE TABLE GradeAttributeValues (
    gav_id INT AUTO_INCREMENT PRIMARY KEY,
    grade_id INT NOT NULL,
    attribute_id INT NOT NULL,
    value TEXT, -- Store as TEXT, convert based on value_type
    FOREIGN KEY (grade_id) REFERENCES Grade(grade_id)
        ON DELETE CASCADE
        ON UPDATE NO ACTION,
    FOREIGN KEY (attribute_id) REFERENCES GradeAttributes(attribute_id)
        ON DELETE CASCADE
        ON UPDATE NO ACTION,
    UNIQUE(grade_id, attribute_id)
) ENGINE=InnoDB;

-- Grade attributes are created dynamically as needed through the EAV service and course grade configuration

-- -----------------------------------------------------
-- 2.3 CourseMaterial EAV Model
-- -----------------------------------------------------
-- WHY EAV: Different material types need different metadata.
-- PDFs: page count, file size, file_name, mime_type
-- Videos: duration, resolution, subtitles, file_size
-- Links/Websites: description, preview image, link_url
-- Powerpoints: file_size, slide_count, file_name, mime_type
-- Documents: file_size, file_name, mime_type, page_count
-- Interactive: tool name, configuration
-- EAV allows extensible metadata without schema changes.
-- 
-- Base table stores ONLY: course reference, title, type, url/path, upload date
-- ALL metadata (file_name, file_size, mime_type, duration, language, difficulty, 
-- tags, version, download_count, preview_image, etc.) is stored in EAV tables.
-- -----------------------------------------------------
CREATE TABLE CourseMaterial (
    material_id INT AUTO_INCREMENT PRIMARY KEY,
    offered_course_id INT NOT NULL,
    instructor_id INT,
    title VARCHAR(255) NOT NULL,
    type VARCHAR(30) NOT NULL CHECK (type IN ('pdf', 'link', 'website', 'file', 'video', 'interactive', 'document', 'powerpoint', 'presentation', 'image', 'audio', 'other')),
    url_or_path VARCHAR(1024) NOT NULL,
    uploaded_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (offered_course_id) REFERENCES OfferedCourse(offered_course_id)
        ON DELETE CASCADE
        ON UPDATE NO ACTION,
    FOREIGN KEY (instructor_id) REFERENCES Instructor(instructor_id)
        ON DELETE SET NULL
        ON UPDATE NO ACTION
) ENGINE=InnoDB;

CREATE TABLE CourseMaterialAttributes (
    attribute_id INT AUTO_INCREMENT PRIMARY KEY,
    attribute_name VARCHAR(255) NOT NULL UNIQUE,
    value_type VARCHAR(20) NOT NULL DEFAULT 'text' -- 'text','int','decimal','bool','json'
) ENGINE=InnoDB;

CREATE TABLE CourseMaterialAttributeValues (
    cmav_id INT AUTO_INCREMENT PRIMARY KEY,
    material_id INT NOT NULL,
    attribute_id INT NOT NULL,
    value TEXT,
    FOREIGN KEY (material_id) REFERENCES CourseMaterial(material_id)
        ON DELETE CASCADE
        ON UPDATE NO ACTION,
    FOREIGN KEY (attribute_id) REFERENCES CourseMaterialAttributes(attribute_id)
        ON DELETE CASCADE
        ON UPDATE NO ACTION,
    UNIQUE(material_id, attribute_id)
) ENGINE=InnoDB;

-- CourseMaterial Attributes (initialized by backend, stored in EAV):
-- Common for files (PDF, PowerPoint, Document, Image, etc.):
--   'file_name' (text) - Original filename
--   'file_size' (int, bytes) - File size in bytes
--   'mime_type' (text) - MIME type (e.g., 'application/pdf', 'application/vnd.ms-powerpoint')
--   'page_count' (int) - Number of pages (for PDFs, auto-extracted)
--   'slide_count' (int) - Number of slides (for PowerPoints, auto-extracted)
-- For videos:
--   'duration_minutes' (decimal) - Video duration
--   'video_format' (text) - Video format (e.g., 'mp4', 'avi', 'youtube', auto-detected)
-- For links/websites:
--   'link_url' (text) - The actual URL if type is 'link', 'video', or 'website'
--   'link_description' (text) - Description of the link
-- General metadata:
--   'language' (text) - Language of the material

-- -----------------------------------------------------
-- 2.3.1 Rooms EAV Model
-- -----------------------------------------------------
-- WHY EAV: Rooms have variable attributes:
-- - Labs: equipment_list, software_installed, safety_requirements
-- - Classrooms: projector_type, whiteboard_count, seating_arrangement
-- - Offices: occupant_capacity, shared_status
-- EAV allows flexible room metadata without schema changes.
-- -----------------------------------------------------
CREATE TABLE Rooms (
    room_id INT AUTO_INCREMENT PRIMARY KEY,
    building VARCHAR(255),
    room_name VARCHAR(100) NOT NULL,
    room_type VARCHAR(20) NOT NULL CHECK (room_type IN ('classroom','lab','office','auditorium')),
    capacity INT DEFAULT 0,
    description TEXT,
    status VARCHAR(20) NOT NULL DEFAULT 'available' CHECK (status IN ('available', 'maintenance', 'out_of_service', 'reserved', 'in_use')),
    status_notes TEXT,
    status_updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    status_updated_by_user_id INT NULL,
    FOREIGN KEY (status_updated_by_user_id) REFERENCES `User`(user_id)
        ON DELETE SET NULL
        ON UPDATE NO ACTION
) ENGINE=InnoDB;

CREATE TABLE RoomAttributes (
    attribute_id INT AUTO_INCREMENT PRIMARY KEY,
    attribute_name VARCHAR(255) NOT NULL UNIQUE,
    value_type VARCHAR(20) NOT NULL DEFAULT 'text' -- e.g. 'text','int','bool','json'
) ENGINE=InnoDB;

CREATE TABLE RoomAttributeValues (
    rav_id INT AUTO_INCREMENT PRIMARY KEY,
    room_id INT NOT NULL,
    attribute_id INT NOT NULL,
    value TEXT,
    FOREIGN KEY (room_id) REFERENCES Rooms(room_id)
        ON DELETE CASCADE
        ON UPDATE NO ACTION,
    FOREIGN KEY (attribute_id) REFERENCES RoomAttributes(attribute_id)
        ON DELETE CASCADE
        ON UPDATE NO ACTION,
    UNIQUE(room_id, attribute_id)
) ENGINE=InnoDB;

-- Room attributes are created dynamically as needed through the RoomController API

-- -----------------------------------------------------
-- 2.5 Assignment EAV Model
-- -----------------------------------------------------
-- WHY EAV: Assignments have variable settings:
-- - Submission policies: late_submission_allowed, late_penalty, max_attempts
-- - Grading: plagiarism_check_enabled
-- - File restrictions: allowed_file_types, file_size_limit_mb
-- EAV allows flexible assignment configuration without schema changes.
-- 
-- Base table stores: course reference, title, description, due_date, max_grade
-- EAV stores: late_submission_allowed, late_penalty_percent, max_attempts,
--             plagiarism_check_enabled, allowed_file_types, file_size_limit_mb
-- -----------------------------------------------------
CREATE TABLE Assignment (
    assignment_id INT AUTO_INCREMENT PRIMARY KEY,
    offered_course_id INT NOT NULL,
    instructor_id INT,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    due_date DATETIME NOT NULL,
    max_grade DECIMAL(7, 2) NOT NULL DEFAULT 100.00,
    FOREIGN KEY (offered_course_id) REFERENCES OfferedCourse(offered_course_id)
        ON DELETE CASCADE
        ON UPDATE NO ACTION,
    FOREIGN KEY (instructor_id) REFERENCES Instructor(instructor_id)
        ON DELETE SET NULL
        ON UPDATE NO ACTION
) ENGINE=InnoDB;

CREATE TABLE AssignmentAttributes (
    attribute_id INT AUTO_INCREMENT PRIMARY KEY,
    attribute_name VARCHAR(255) NOT NULL UNIQUE,
    value_type VARCHAR(20) NOT NULL DEFAULT 'text' -- 'text','int','decimal','bool','json'
) ENGINE=InnoDB;

CREATE TABLE AssignmentAttributeValues (
    aav_id INT AUTO_INCREMENT PRIMARY KEY,
    assignment_id INT NOT NULL,
    attribute_id INT NOT NULL,
    value TEXT,
    FOREIGN KEY (assignment_id) REFERENCES Assignment(assignment_id)
        ON DELETE CASCADE
        ON UPDATE NO ACTION,
    FOREIGN KEY (attribute_id) REFERENCES AssignmentAttributes(attribute_id)
        ON DELETE CASCADE
        ON UPDATE NO ACTION,
    UNIQUE(assignment_id, attribute_id)
) ENGINE=InnoDB;

-- Example Assignment Attributes to insert:
-- 'late_submission_allowed' (bool), 'late_penalty_percent' (decimal),
-- 'max_attempts' (int), 'group_size' (int), 'group_formation_method' (text),
-- 'plagiarism_check_enabled' (bool), 'auto_grade_enabled' (bool),
-- 'rubric_json' (json), 'allowed_file_types' (text/json),
-- 'file_size_limit_mb' (int), 'submission_type' (text)

-- -----------------------------------------------------
-- 2.6 Quiz EAV Model
-- -----------------------------------------------------
-- WHY EAV: Quizzes have variable settings:
-- - Timing: time_limit_minutes, show_results_immediately
-- - Attempts: max_attempts, attempt_penalty
-- - Question order: randomize_questions, randomize_options
-- - Feedback: show_correct_answers, show_feedback_after
-- EAV allows flexible quiz configuration without schema changes.
-- 
-- Base table stores: course reference, title, description, due_date, max_grade
-- EAV stores: time_limit_minutes, max_attempts, randomize_questions, randomize_options,
--             show_results_immediately, show_correct_answers,
--             show_feedback_after, attempt_penalty_percent
-- -----------------------------------------------------
CREATE TABLE Quiz (
    quiz_id INT AUTO_INCREMENT PRIMARY KEY,
    offered_course_id INT NOT NULL,
    instructor_id INT,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    due_date DATETIME NOT NULL,
    max_grade DECIMAL(7, 2) NOT NULL DEFAULT 100.00,
    FOREIGN KEY (offered_course_id) REFERENCES OfferedCourse(offered_course_id)
        ON DELETE CASCADE
        ON UPDATE NO ACTION,
    FOREIGN KEY (instructor_id) REFERENCES Instructor(instructor_id)
        ON DELETE SET NULL
        ON UPDATE NO ACTION
) ENGINE=InnoDB;

CREATE TABLE QuizAttributes (
    attribute_id INT AUTO_INCREMENT PRIMARY KEY,
    attribute_name VARCHAR(255) NOT NULL UNIQUE,
    value_type VARCHAR(20) NOT NULL DEFAULT 'text' -- 'text','int','decimal','bool','json'
) ENGINE=InnoDB;

CREATE TABLE QuizAttributeValues (
    qav_id INT AUTO_INCREMENT PRIMARY KEY,
    quiz_id INT NOT NULL,
    attribute_id INT NOT NULL,
    value TEXT,
    FOREIGN KEY (quiz_id) REFERENCES Quiz(quiz_id)
        ON DELETE CASCADE
        ON UPDATE NO ACTION,
    FOREIGN KEY (attribute_id) REFERENCES QuizAttributes(attribute_id)
        ON DELETE CASCADE
        ON UPDATE NO ACTION,
    UNIQUE(quiz_id, attribute_id)
) ENGINE=InnoDB;

-- Quiz Attributes (initialized by backend, stored in EAV):
-- 'time_limit_minutes' (int), 'max_attempts' (int),
-- 'randomize_questions' (bool), 'randomize_options' (bool),
-- 'show_results_immediately' (bool), 'show_correct_answers' (bool),
-- 'show_feedback_after' (text: 'immediately', 'after_submission', 'after_due_date'),
-- 'attempt_penalty_percent' (decimal)

-- -----------------------------------------------------
-- 2.6.1 Assignment Submission Table (Fixed Schema - Moved here after Assignment)
-- -----------------------------------------------------
-- This table references Assignment, so it must be created after it
CREATE TABLE AssignmentSubmission (
    submission_id INT AUTO_INCREMENT PRIMARY KEY,
    assignment_id INT NOT NULL,
    student_id INT NOT NULL,
    submitted_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    -- keep content/file_path for simple file-only submissions as convenience
    content TEXT,
    file_path VARCHAR(1024),
    grade DECIMAL(7, 2),
    feedback TEXT,
    FOREIGN KEY (assignment_id) REFERENCES Assignment(assignment_id)
        ON DELETE CASCADE
        ON UPDATE NO ACTION,
    FOREIGN KEY (student_id) REFERENCES Student(student_id)
        ON DELETE CASCADE
        ON UPDATE NO ACTION,
    UNIQUE(assignment_id, student_id)
) ENGINE=InnoDB;

-- -----------------------------------------------------
-- 2.7.1 Room Reservations/Bookings
-- -----------------------------------------------------
CREATE TABLE RoomReservation (
    reservation_id INT AUTO_INCREMENT PRIMARY KEY,
    room_id INT NOT NULL,
    reserved_by_user_id INT NOT NULL,
    assignment_type VARCHAR(20) NOT NULL CHECK (assignment_type IN ('course', 'instructor', 'department', 'event', 'exam', 'maintenance')),
    related_offered_course_id INT NULL,
    related_section_id INT NULL,
    related_department_id INT NULL,
    related_instructor_id INT NULL,
    start_datetime DATETIME NOT NULL,
    end_datetime DATETIME NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected', 'cancelled', 'completed')),
    purpose TEXT,
    requested_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    approved_by_user_id INT NULL,
    approved_at DATETIME NULL,
    notes TEXT,
    is_recurring BOOLEAN NOT NULL DEFAULT FALSE,
    recurrence_pattern VARCHAR(50) NULL,
    recurrence_end_date DATE NULL,
    parent_reservation_id INT NULL,
    FOREIGN KEY (room_id) REFERENCES Rooms(room_id)
        ON DELETE CASCADE
        ON UPDATE NO ACTION,
    FOREIGN KEY (reserved_by_user_id) REFERENCES `User`(user_id)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION,
    FOREIGN KEY (related_offered_course_id) REFERENCES OfferedCourse(offered_course_id)
        ON DELETE SET NULL
        ON UPDATE NO ACTION,
    FOREIGN KEY (related_section_id) REFERENCES Section(section_id)
        ON DELETE SET NULL
        ON UPDATE NO ACTION,
    FOREIGN KEY (related_department_id) REFERENCES Department(department_id)
        ON DELETE SET NULL
        ON UPDATE NO ACTION,
    FOREIGN KEY (related_instructor_id) REFERENCES Instructor(instructor_id)
        ON DELETE SET NULL
        ON UPDATE NO ACTION,
    FOREIGN KEY (approved_by_user_id) REFERENCES `User`(user_id)
        ON DELETE SET NULL
        ON UPDATE NO ACTION,
    FOREIGN KEY (parent_reservation_id) REFERENCES RoomReservation(reservation_id)
        ON DELETE CASCADE
        ON UPDATE NO ACTION,
    CHECK (end_datetime > start_datetime)
) ENGINE=InnoDB;

CREATE INDEX idx_room_reservation_room_datetime ON RoomReservation(room_id, start_datetime, end_datetime);
CREATE INDEX idx_room_reservation_status ON RoomReservation(status);
CREATE INDEX idx_room_reservation_user ON RoomReservation(reserved_by_user_id);

-- -----------------------------------------------------
-- 2.7.2 Room Maintenance Issues
-- -----------------------------------------------------
CREATE TABLE RoomMaintenanceIssue (
    issue_id INT AUTO_INCREMENT PRIMARY KEY,
    room_id INT NOT NULL,
    reported_by_user_id INT NOT NULL,
    issue_type VARCHAR(50) NOT NULL CHECK (issue_type IN ('equipment', 'furniture', 'electrical', 'plumbing', 'heating_cooling', 'cleaning', 'safety', 'other')),
    priority VARCHAR(20) NOT NULL DEFAULT 'medium' CHECK (priority IN ('low', 'medium', 'high', 'urgent')),
    title VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'reported' CHECK (status IN ('reported', 'assigned', 'in_progress', 'resolved', 'closed', 'cancelled')),
    reported_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    assigned_to_user_id INT NULL,
    assigned_at DATETIME NULL,
    resolved_at DATETIME NULL,
    resolved_by_user_id INT NULL,
    resolution_notes TEXT,
    estimated_cost DECIMAL(10, 2),
    actual_cost DECIMAL(10, 2),
    attachments_json JSON,
    FOREIGN KEY (room_id) REFERENCES Rooms(room_id)
        ON DELETE CASCADE
        ON UPDATE NO ACTION,
    FOREIGN KEY (reported_by_user_id) REFERENCES `User`(user_id)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION,
    FOREIGN KEY (assigned_to_user_id) REFERENCES `User`(user_id)
        ON DELETE SET NULL
        ON UPDATE NO ACTION,
    FOREIGN KEY (resolved_by_user_id) REFERENCES `User`(user_id)
        ON DELETE SET NULL
        ON UPDATE NO ACTION
) ENGINE=InnoDB;

CREATE INDEX idx_maintenance_room ON RoomMaintenanceIssue(room_id);
CREATE INDEX idx_maintenance_status ON RoomMaintenanceIssue(status);
CREATE INDEX idx_maintenance_priority ON RoomMaintenanceIssue(priority);
CREATE INDEX idx_maintenance_reported_at ON RoomMaintenanceIssue(reported_at);

-- -----------------------------------------------------
-- 2.8 Questions EAV Model (Already EAV)
-- -----------------------------------------------------
-- WHY EAV: Questions have variable attributes based on type:
-- - MCQ: options, correct_answer, points_per_option
-- - Short Text: max_length, expected_keywords
-- - File Upload: allowed_types, max_size
-- - Code: language, test_cases_json, runtime_limits
-- EAV allows flexible question types without schema changes.
-- -----------------------------------------------------
CREATE TABLE Questions (
    question_id INT AUTO_INCREMENT PRIMARY KEY,
    parent_question_id INT NULL, -- for multi-part questions
    assessment_type VARCHAR(10) NOT NULL CHECK (assessment_type IN ('assignment','quiz')),
    assessment_id INT NOT NULL,   -- points to assignment_id or quiz_id per assessment_type
    question_text TEXT,
    question_order INT DEFAULT 0,
    FOREIGN KEY (parent_question_id) REFERENCES Questions(question_id)
        ON DELETE SET NULL
        ON UPDATE NO ACTION
) ENGINE=InnoDB;

-- Index for performance
CREATE INDEX idx_questions_assessment ON Questions(assessment_type(10), assessment_id);

CREATE TABLE QuestionAttributes (
    attribute_id INT AUTO_INCREMENT PRIMARY KEY,
    attribute_name VARCHAR(255) NOT NULL UNIQUE,
    value_type VARCHAR(20) NOT NULL DEFAULT 'text' -- 'text','int','decimal','bool','json'
) ENGINE=InnoDB;

CREATE TABLE QuestionAttributeValues (
    qav_id INT AUTO_INCREMENT PRIMARY KEY,
    question_id INT NOT NULL,
    attribute_id INT NOT NULL,
    value TEXT,
    FOREIGN KEY (question_id) REFERENCES Questions(question_id)
        ON DELETE CASCADE
        ON UPDATE NO ACTION,
    FOREIGN KEY (attribute_id) REFERENCES QuestionAttributes(attribute_id)
        ON DELETE CASCADE
        ON UPDATE NO ACTION,
    UNIQUE(question_id, attribute_id)
) ENGINE=InnoDB;

-- Core Question Attributes (initialized by QuestionService):
-- 'question_type' (text: 'MCQ', 'SHORT_TEXT', 'TRUE_FALSE')
-- 'mcq_options' (json) - JSON array of options for MCQ
-- 'correct_answer' (text)
-- 'max_marks' (decimal)
-- Additional attributes can be created dynamically as needed

-- -----------------------------------------------------
-- 2.9 Student Answers EAV Model (Already EAV)
-- -----------------------------------------------------
-- WHY EAV: Student answers vary by question type:
-- - MCQ: selected_option
-- - Short Text: text_answer
-- - File Upload: file_path, file_name
-- - Code: code_submission, runtime_output_json
-- EAV allows flexible answer storage without schema changes.
-- -----------------------------------------------------
CREATE TABLE StudentAnswers (
    student_answer_id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,
    question_id INT NOT NULL,
    submission_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    grade DECIMAL(7,2),
    feedback TEXT,
    FOREIGN KEY (student_id) REFERENCES Student(student_id)
        ON DELETE CASCADE
        ON UPDATE NO ACTION,
    FOREIGN KEY (question_id) REFERENCES Questions(question_id)
        ON DELETE CASCADE
        ON UPDATE NO ACTION,
    UNIQUE(student_id, question_id)
) ENGINE=InnoDB;

CREATE TABLE StudentAnswerAttributes (
    sa_attribute_id INT AUTO_INCREMENT PRIMARY KEY,
    sa_attribute_name VARCHAR(255) NOT NULL UNIQUE,
    value_type VARCHAR(20) NOT NULL DEFAULT 'text' -- e.g. 'text','file','json','code'
) ENGINE=InnoDB;

CREATE TABLE StudentAnswerAttributeValues (
    sa_value_id INT AUTO_INCREMENT PRIMARY KEY,
    student_answer_id INT NOT NULL,
    sa_attribute_id INT NOT NULL,
    value TEXT,
    FOREIGN KEY (student_answer_id) REFERENCES StudentAnswers(student_answer_id)
        ON DELETE CASCADE
        ON UPDATE NO ACTION,
    FOREIGN KEY (sa_attribute_id) REFERENCES StudentAnswerAttributes(sa_attribute_id)
        ON DELETE CASCADE
        ON UPDATE NO ACTION,
    UNIQUE(student_answer_id, sa_attribute_id)
) ENGINE=InnoDB;

-- Core Student Answer Attributes (initialized by StudentAnswerService):
-- 'mcq_selected_option' (text)
-- 'short_text_answer' (text)
-- 'true_false_answer' (text)
-- Additional attributes can be created dynamically as needed

-- -----------------------------------------------------
-- 2.10 Announcement EAV Model (Unified for Admin & Instructor)
-- -----------------------------------------------------
-- WHY EAV: Unified announcement system for both admin and instructor announcements.
-- Supports flexible attributes:
-- - Scope: course-specific (instructor) vs global (admin)
-- - Target audience: all_users, students_only, instructors_only, admins_only
-- - Course linking: offered_course_id (for course announcements)
-- - Section targeting: section_id (optional, for section-specific announcements)
-- - Priority, expiration, attachments, tags, etc.
-- EAV allows extensible announcement features without schema changes.
-- 
-- Base table stores: author, title, content, created_at
-- EAV stores: scope_type, offered_course_id, section_id, announcement_type,
--             priority, is_active, expires_at, tags_json, attachments_json, etc.
-- -----------------------------------------------------
CREATE TABLE Announcement (
    announcement_id INT AUTO_INCREMENT PRIMARY KEY,
    author_user_id INT NOT NULL, -- Instructor or Admin who created it
    title VARCHAR(255) NOT NULL,
    content TEXT NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (author_user_id) REFERENCES `User`(user_id)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION
) ENGINE=InnoDB;

CREATE TABLE AnnouncementAttributes (
    attribute_id INT AUTO_INCREMENT PRIMARY KEY,
    attribute_name VARCHAR(255) NOT NULL UNIQUE,
    value_type VARCHAR(20) NOT NULL DEFAULT 'text' -- 'text','int','bool','datetime','json'
) ENGINE=InnoDB;

CREATE TABLE AnnouncementAttributeValues (
    aav_id INT AUTO_INCREMENT PRIMARY KEY,
    announcement_id INT NOT NULL,
    attribute_id INT NOT NULL,
    value TEXT,
    FOREIGN KEY (announcement_id) REFERENCES Announcement(announcement_id)
        ON DELETE CASCADE
        ON UPDATE NO ACTION,
    FOREIGN KEY (attribute_id) REFERENCES AnnouncementAttributes(attribute_id)
        ON DELETE CASCADE
        ON UPDATE NO ACTION,
    UNIQUE(announcement_id, attribute_id)
) ENGINE=InnoDB;

-- Announcement attributes are created dynamically as needed through the AnnouncementController API

-- =================================================================
-- NOTE: EAV ATTRIBUTE INITIALIZATION
-- =================================================================
-- EAV attributes for all entities are automatically initialized by the backend code:
-- 
-- - AssignmentAttributes: Initialized by EAVService.initializeAssignmentAttributes()
-- - QuizAttributes: Initialized by EAVService.initializeQuizAttributes()
-- - CourseMaterialAttributes: Initialized by CourseMaterialService.initializeDefaultAttributes()
-- - QuestionAttributes: Initialized by QuestionService.initializeDefaultAttributes()
-- - StudentAnswerAttributes: Initialized by StudentAnswerService.initializeDefaultAttributes()
-- - EnrollmentAttributes, GradeAttributes, AnnouncementAttributes, RoomAttributes:
--   These are created dynamically as needed through their respective controllers/services
--
-- No manual INSERT statements are required. The backend services handle all attribute
-- initialization automatically when they are first used.
-- =================================================================

-- End of schema
