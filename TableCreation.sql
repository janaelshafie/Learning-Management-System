-- -----------------------------------------------------------------
-- --- University LMS Schema Script (MySQL Compatible) ---
-- --- Schema Only - No Data ---
-- -----------------------------------------------------------------

DROP DATABASE IF EXISTS university_lms_db;

CREATE DATABASE university_lms_db;

USE university_lms_db;

-- -----------------------------------------------------
-- Table Schema Creation
-- -----------------------------------------------------

-- Drop tables in reverse order of dependency to avoid foreign key errors
DROP TABLE IF EXISTS PendingProfileChanges;
DROP TABLE IF EXISTS FacultyResearch;
DROP TABLE IF EXISTS Message;
DROP TABLE IF EXISTS global_announcements;
DROP TABLE IF EXISTS Announcement;
DROP TABLE IF EXISTS QuizSubmission;
DROP TABLE IF EXISTS Quiz;
DROP TABLE IF EXISTS AssignmentSubmission;
DROP TABLE IF EXISTS Assignment;
DROP TABLE IF EXISTS CourseMaterial;
DROP TABLE IF EXISTS Grade;
DROP TABLE IF EXISTS Enrollment;
DROP TABLE IF EXISTS Schedule;
DROP TABLE IF EXISTS OfferedCourse_Instructor;
DROP TABLE IF EXISTS Section;
DROP TABLE IF EXISTS OfferedCourse;
DROP TABLE IF EXISTS DepartmentCourse;
DROP TABLE IF EXISTS Prerequisite;
DROP TABLE IF EXISTS Semester;
DROP TABLE IF EXISTS Course;
DROP TABLE IF EXISTS Student;
DROP TABLE IF EXISTS Department;
DROP TABLE IF EXISTS Instructor;
DROP TABLE IF EXISTS `User`;

-- -----------------------------------------------------
-- Core User & Role Tables
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
    
    -- 'active' = Can log in (default for non-parents)
    -- 'pending' = Parent waiting for approval
    -- 'rejected' = Admin denied
    account_status VARCHAR(10) NOT NULL DEFAULT 'active'
);

CREATE TABLE Instructor (
    instructor_id INT PRIMARY KEY,
    instructor_type VARCHAR(10) NOT NULL CHECK (instructor_type IN ('professor', 'ta')),
    office_hours VARCHAR(255),
    FOREIGN KEY (instructor_id) REFERENCES `User`(user_id)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION
);

CREATE TABLE Department (
    department_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    unit_head_id INT,
    FOREIGN KEY (unit_head_id) REFERENCES Instructor(instructor_id)
        ON DELETE SET NULL
        ON UPDATE NO ACTION
);

CREATE TABLE Student (
    student_id INT PRIMARY KEY,
    student_uid VARCHAR(100) NOT NULL UNIQUE,
    cumulative_gpa DECIMAL(3, 2),
    department_id INT,
    advisor_id INT,
    parent_user_id INT,
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
        ON DELETE NO ACTION
        ON UPDATE NO ACTION
);

-- -----------------------------------------------------
-- Course & Academic Tables
-- -----------------------------------------------------

CREATE TABLE Course (
    course_id INT AUTO_INCREMENT PRIMARY KEY,
    course_code VARCHAR(20) NOT NULL UNIQUE,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    credits INT NOT NULL,
    -- Merged from migration script: course_type definition
    course_type VARCHAR(10) CHECK (course_type IN ('core', 'elective'))
);

CREATE TABLE Semester (
    semester_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    registration_open TINYINT(1) NOT NULL DEFAULT 0
);

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
    -- Merged from migration script: Self-reference check
    CHECK (course_id != prereq_course_id)
);

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
);

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
);

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
);

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
);

CREATE TABLE Schedule (
    schedule_id INT AUTO_INCREMENT PRIMARY KEY,
    offered_course_id INT,
    section_id INT,
    type VARCHAR(10) NOT NULL CHECK (type IN ('lecture', 'section', 'exam')),
    day_of_week VARCHAR(10) NOT NULL CHECK (day_of_week IN ('Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday')),
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    location VARCHAR(100),
    FOREIGN KEY (offered_course_id) REFERENCES OfferedCourse(offered_course_id)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION,
    FOREIGN KEY (section_id) REFERENCES Section(section_id)
        ON DELETE CASCADE
        ON UPDATE NO ACTION,
    CHECK (offered_course_id IS NOT NULL OR section_id IS NOT NULL)
);

CREATE TABLE Enrollment (
    enrollment_id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,
    section_id INT NOT NULL,
    status VARCHAR(10) NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected')),
    FOREIGN KEY (student_id) REFERENCES Student(student_id)
        ON DELETE CASCADE
        ON UPDATE NO ACTION,
    FOREIGN KEY (section_id) REFERENCES Section(section_id)
        ON DELETE CASCADE
        ON UPDATE NO ACTION,
    UNIQUE(student_id, section_id)
);

CREATE TABLE Grade (
    grade_id INT AUTO_INCREMENT PRIMARY KEY,
    enrollment_id INT NOT NULL UNIQUE,
    midterm DECIMAL(5, 2) DEFAULT 0.00,
    project DECIMAL(5, 2) DEFAULT 0.00,
    assignments_total DECIMAL(5, 2) DEFAULT 0.00,
    quizzes_total DECIMAL(5, 2) DEFAULT 0.00,
    attendance DECIMAL(5, 2) DEFAULT 0.00,
    final_exam_mark DECIMAL(5, 2) DEFAULT 0.00,
    final_letter_grade VARCHAR(2),
    FOREIGN KEY (enrollment_id) REFERENCES Enrollment(enrollment_id)
        ON DELETE CASCADE
        ON UPDATE NO ACTION,
    CHECK (midterm <= 20 AND project <= 20 AND assignments_total <= 10 AND quizzes_total <= 5 AND attendance <= 5)
);

-- -----------------------------------------------------
-- Course Content & Interaction Tables
-- -----------------------------------------------------

CREATE TABLE CourseMaterial (
    material_id INT AUTO_INCREMENT PRIMARY KEY,
    offered_course_id INT NOT NULL,
    instructor_id INT,
    title VARCHAR(255) NOT NULL,
    type VARCHAR(10) NOT NULL CHECK (type IN ('pdf', 'link', 'file')),
    url_or_path VARCHAR(1024) NOT NULL,
    uploaded_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (offered_course_id) REFERENCES OfferedCourse(offered_course_id)
        ON DELETE CASCADE
        ON UPDATE NO ACTION,
    FOREIGN KEY (instructor_id) REFERENCES Instructor(instructor_id)
        ON DELETE SET NULL
        ON UPDATE NO ACTION
);

CREATE TABLE Assignment (
    assignment_id INT AUTO_INCREMENT PRIMARY KEY,
    offered_course_id INT NOT NULL,
    instructor_id INT,
    title VARCHAR(255) NOT NULL,
    questions TEXT,
    due_date DATETIME NOT NULL,
    max_grade DECIMAL(5, 2) NOT NULL DEFAULT 100.00,
    FOREIGN KEY (offered_course_id) REFERENCES OfferedCourse(offered_course_id)
        ON DELETE CASCADE
        ON UPDATE NO ACTION,
    FOREIGN KEY (instructor_id) REFERENCES Instructor(instructor_id)
        ON DELETE SET NULL
        ON UPDATE NO ACTION
);

CREATE TABLE AssignmentSubmission (
    submission_id INT AUTO_INCREMENT PRIMARY KEY,
    assignment_id INT NOT NULL,
    student_id INT NOT NULL,
    submitted_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    content TEXT,
    file_path VARCHAR(1024),
    grade DECIMAL(5, 2),
    feedback TEXT,
    FOREIGN KEY (assignment_id) REFERENCES Assignment(assignment_id)
        ON DELETE CASCADE
        ON UPDATE NO ACTION,
    FOREIGN KEY (student_id) REFERENCES Student(student_id)
        ON DELETE CASCADE
        ON UPDATE NO ACTION,
    UNIQUE(assignment_id, student_id)
);

CREATE TABLE Quiz (
    quiz_id INT AUTO_INCREMENT PRIMARY KEY,
    offered_course_id INT NOT NULL,
    instructor_id INT,
    title VARCHAR(255) NOT NULL,
    questions TEXT,
    due_date DATETIME NOT NULL,
    max_grade DECIMAL(5, 2) NOT NULL DEFAULT 100.00,
    FOREIGN KEY (offered_course_id) REFERENCES OfferedCourse(offered_course_id)
        ON DELETE CASCADE
        ON UPDATE NO ACTION,
    FOREIGN KEY (instructor_id) REFERENCES Instructor(instructor_id)
        ON DELETE SET NULL
        ON UPDATE NO ACTION
);

CREATE TABLE QuizSubmission (
    quiz_sub_id INT AUTO_INCREMENT PRIMARY KEY,
    quiz_id INT NOT NULL,
    student_id INT NOT NULL,
    submitted_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    content TEXT,
    file_path VARCHAR(1024),
    grade DECIMAL(5, 2),
    FOREIGN KEY (quiz_id) REFERENCES Quiz(quiz_id)
        ON DELETE CASCADE
        ON UPDATE NO ACTION,
    FOREIGN KEY (student_id) REFERENCES Student(student_id)
        ON DELETE CASCADE
        ON UPDATE NO ACTION,
    UNIQUE(quiz_id, student_id)
);

-- -----------------------------------------------------
-- Communication & Misc Tables
-- -----------------------------------------------------

CREATE TABLE Announcement (
    announcement_id INT AUTO_INCREMENT PRIMARY KEY,
    offered_course_id INT NOT NULL,
    author_user_id INT,
    title VARCHAR(255) NOT NULL,
    content TEXT NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (offered_course_id) REFERENCES OfferedCourse(offered_course_id)
        ON DELETE CASCADE
        ON UPDATE NO ACTION,
    FOREIGN KEY (author_user_id) REFERENCES `User`(user_id)
        ON DELETE SET NULL
        ON UPDATE NO ACTION
);

CREATE TABLE global_announcements (
    announcement_id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(200) NOT NULL,
    content TEXT NOT NULL,
    announcement_type ENUM('all_users', 'students_only', 'instructors_only', 'admins_only') DEFAULT 'all_users',
    priority ENUM('low', 'medium', 'high', 'urgent') DEFAULT 'medium',
    is_active BOOLEAN DEFAULT TRUE,
    created_by INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP NULL,
    FOREIGN KEY (created_by) REFERENCES `User`(user_id)
);

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
);

CREATE TABLE FacultyResearch (
    research_id INT AUTO_INCREMENT PRIMARY KEY,
    instructor_id INT NOT NULL,
    publication_title VARCHAR(1024) NOT NULL,
    journal_or_conference VARCHAR(255),
    publish_date DATE NOT NULL,
    FOREIGN KEY (instructor_id) REFERENCES Instructor(instructor_id)
        ON DELETE CASCADE
        ON UPDATE NO ACTION
);

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
);