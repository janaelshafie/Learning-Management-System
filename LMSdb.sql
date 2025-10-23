-- -----------------------------------------------------------------
-- --- Full University LMS Script (MS SQL Server Compatible V3) ---
-- --- Fixes for Multiple Cascade Paths ---
-- -----------------------------------------------------------------

IF DB_ID('university_lms_db') IS NOT NULL
BEGIN
    USE master;
    DROP DATABASE university_lms_db;
END
GO

CREATE DATABASE university_lms_db;
GO

USE university_lms_db;
GO

-- -----------------------------------------------------
-- Section 1: Table Schema Creation
-- -----------------------------------------------------

DROP TABLE IF EXISTS FacultyResearch;
DROP TABLE IF EXISTS Message;
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
DROP TABLE IF EXISTS Prerequisite;
DROP TABLE IF EXISTS Semester;
DROP TABLE IF EXISTS Course;
DROP TABLE IF EXISTS Student;
DROP TABLE IF EXISTS Department;
DROP TABLE IF EXISTS Instructor;
DROP TABLE IF EXISTS [User];
GO

-- Creating tables in order of dependency

CREATE TABLE [User] (
    user_id INT IDENTITY(1,1) PRIMARY KEY,
    national_id VARCHAR(255) NOT NULL UNIQUE,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    official_mail VARCHAR(255) NOT NULL UNIQUE,
    phone VARCHAR(20),
    location VARCHAR(255),
    password_hash VARCHAR(255) NOT NULL,
    role VARCHAR(10) NOT NULL CHECK (role IN ('student', 'instructor', 'admin', 'parent'))
);
GO

CREATE TABLE Instructor (
    instructor_id INT PRIMARY KEY,
    instructor_type VARCHAR(10) NOT NULL CHECK (instructor_type IN ('professor', 'ta')),
    office_hours VARCHAR(255),
    FOREIGN KEY (instructor_id) REFERENCES [User](user_id)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION
);
GO

CREATE TABLE Department (
    department_id INT IDENTITY(1,1) PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    unit_head_id INT,
    FOREIGN KEY (unit_head_id) REFERENCES Instructor(instructor_id)
        ON DELETE SET NULL
        ON UPDATE NO ACTION
);
GO

CREATE TABLE Student (
    student_id INT PRIMARY KEY,
    student_uid VARCHAR(100) NOT NULL UNIQUE,
    cumulative_gpa DECIMAL(3, 2),
    department_id INT,
    advisor_id INT,
    parent_user_id INT,
    FOREIGN KEY (student_id) REFERENCES [User](user_id)
        ON DELETE CASCADE
        ON UPDATE NO ACTION,
    FOREIGN KEY (department_id) REFERENCES Department(department_id)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION,
    FOREIGN KEY (advisor_id) REFERENCES Instructor(instructor_id)
        ON DELETE SET NULL
        ON UPDATE NO ACTION,
    -- FIXED: Changed ON DELETE SET NULL to NO ACTION to prevent multiple cascade paths from [User]
    FOREIGN KEY (parent_user_id) REFERENCES [User](user_id)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION
);
GO

CREATE TABLE Course (
    course_id INT IDENTITY(1,1) PRIMARY KEY,
    course_code VARCHAR(20) NOT NULL UNIQUE,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    credits INT NOT NULL
);
GO

CREATE TABLE Semester (
    semester_id INT IDENTITY(1,1) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    registration_open BIT NOT NULL DEFAULT 0
);
GO

CREATE TABLE Prerequisite (
    course_id INT NOT NULL,
    prereq_course_id INT NOT NULL,
    PRIMARY KEY (course_id, prereq_course_id),
    -- FIXED: Changed ON DELETE CASCADE to NO ACTION to prevent multiple cascade paths from Course
    FOREIGN KEY (course_id) REFERENCES Course(course_id)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION,
    -- FIXED: Changed ON DELETE CASCADE to NO ACTION
    FOREIGN KEY (prereq_course_id) REFERENCES Course(course_id)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION
);
GO

CREATE TABLE OfferedCourse (
    offered_course_id INT IDENTITY(1,1) PRIMARY KEY,
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
GO

CREATE TABLE Section (
    section_id INT IDENTITY(1,1) PRIMARY KEY,
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
GO

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
GO

CREATE TABLE Schedule (
    schedule_id INT IDENTITY(1,1) PRIMARY KEY,
    offered_course_id INT,
    section_id INT,
    type VARCHAR(10) NOT NULL CHECK (type IN ('lecture', 'section', 'exam')),
    day_of_week VARCHAR(10) NOT NULL CHECK (day_of_week IN ('Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday')),
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    location VARCHAR(100),
    -- FIXED: Changed ON DELETE CASCADE to NO ACTION to prevent multiple cascade paths from OfferedCourse
    FOREIGN KEY (offered_course_id) REFERENCES OfferedCourse(offered_course_id)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION,
    FOREIGN KEY (section_id) REFERENCES Section(section_id)
        ON DELETE CASCADE
        ON UPDATE NO ACTION,
    CHECK (offered_course_id IS NOT NULL OR section_id IS NOT NULL)
);
GO

CREATE TABLE Enrollment (
    enrollment_id INT IDENTITY(1,1) PRIMARY KEY,
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
GO

CREATE TABLE Grade (
    grade_id INT IDENTITY(1,1) PRIMARY KEY,
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
GO

CREATE TABLE CourseMaterial (
    material_id INT IDENTITY(1,1) PRIMARY KEY,
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
GO

CREATE TABLE Assignment (
    assignment_id INT IDENTITY(1,1) PRIMARY KEY,
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
GO

CREATE TABLE AssignmentSubmission (
    submission_id INT IDENTITY(1,1) PRIMARY KEY,
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
GO

CREATE TABLE Quiz (
    quiz_id INT IDENTITY(1,1) PRIMARY KEY,
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
GO

CREATE TABLE QuizSubmission (
    quiz_sub_id INT IDENTITY(1,1) PRIMARY KEY,
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
GO

CREATE TABLE Announcement (
    announcement_id INT IDENTITY(1,1) PRIMARY KEY,
    offered_course_id INT NOT NULL,
    author_user_id INT,
    title VARCHAR(255) NOT NULL,
    content TEXT NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (offered_course_id) REFERENCES OfferedCourse(offered_course_id)
        ON DELETE CASCADE
        ON UPDATE NO ACTION,
    FOREIGN KEY (author_user_id) REFERENCES [User](user_id)
        ON DELETE SET NULL
        ON UPDATE NO ACTION
);
GO

CREATE TABLE Message (
    message_id INT IDENTITY(1,1) PRIMARY KEY,
    sender_user_id INT NOT NULL,
    recipient_user_id INT NOT NULL,
    content TEXT NOT NULL,
    sent_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    read_at DATETIME,
    FOREIGN KEY (sender_user_id) REFERENCES [User](user_id)
        ON DELETE NO ACTION
        -- FIXED: Changed ON UPDATE CASCADE to NO ACTION
        ON UPDATE NO ACTION,
    FOREIGN KEY (recipient_user_id) REFERENCES [User](user_id)
        ON DELETE NO ACTION
        -- FIXED: Changed ON UPDATE CASCADE to NO ACTION
        ON UPDATE NO ACTION
);
GO

CREATE TABLE FacultyResearch (
    research_id INT IDENTITY(1,1) PRIMARY KEY,
    instructor_id INT NOT NULL,
    publication_title VARCHAR(1024) NOT NULL,
    journal_or_conference VARCHAR(255),
    publish_date DATE NOT NULL,
    FOREIGN KEY (instructor_id) REFERENCES Instructor(instructor_id)
        ON DELETE CASCADE
        ON UPDATE NO ACTION
);
GO

-- -----------------------------------------------------
-- Section 2: Sample Data Insertion
-- -----------------------------------------------------

SET IDENTITY_INSERT [User] ON;
INSERT INTO [User] (user_id, national_id, name, email, official_mail, password_hash, role)
VALUES
(1, '100000001', 'Admin User', 'admin@mail.com', 'admin@uni.edu', 'hash_pw', 'admin'),
(101, '200000001', 'Dr. Aris', 'aris@mail.com', 'aris.prof@uni.edu', 'hash_pw', 'instructor'),
(102, '200000002', 'TA Ahmed', 'ahmed@mail.com', 'ahmed.ta@uni.edu', 'hash_pw', 'instructor'),
(103, '200000003', 'TA Mohamed', 'mohamed@mail.com', 'mohamed.ta@uni.edu', 'hash_pw', 'instructor'),
(104, '200000004', 'Dr. Fatima', 'fatima@mail.com', 'fatima.prof@uni.edu', 'hash_pw', 'instructor'),
(105, '200000005', 'TA Youssef', 'youssef@mail.com', 'youssef.ta@uni.edu', 'hash_pw', 'instructor'),
(201, '300000001', 'Student Ali', 'ali@mail.com', 'ali.student@uni.edu', 'hash_pw', 'student'),
(202, '300000002', 'Student Mona', 'mona@mail.com', 'mona.student@uni.edu', 'hash_pw', 'student'),
(203, '300000003', 'Student Omar', 'omar@mail.com', 'omar.student@uni.edu', 'hash_pw', 'student'),
(204, '300000004', 'Student Sara', 'sara@mail.com', 'sara.student@uni.edu', 'hash_pw', 'student'),
(301, '400000001', 'Mr. Ibrahim (Ali''s Father)', 'ibrahim@mail.com', 'ibrahim.parent@uni.edu', 'hash_pw', 'parent'),
(302, '400000002', 'Mrs. Nadia (Sara''s Mother)', 'nadia@mail.com', 'nadia.parent@uni.edu', 'hash_pw', 'parent');
SET IDENTITY_INSERT [User] OFF;
GO

INSERT INTO Instructor (instructor_id, instructor_type, office_hours)
VALUES
(101, 'professor', 'Monday 10-12am, Room C101'),
(102, 'ta', 'Tuesday 1-2pm, Room C102'),
(103, 'ta', 'Wednesday 3-4pm, Room C103'),
(104, 'professor', 'Friday 11-1pm, Room E201'),
(105, 'ta', 'Thursday 10-11am, Room E202');
GO

SET IDENTITY_INSERT Department ON;
INSERT INTO Department (department_id, name, unit_head_id)
VALUES
(1, 'Computer Science', 101),
(2, 'Software Engineering', 104);
SET IDENTITY_INSERT Department OFF;
GO

INSERT INTO Student (student_id, student_uid, cumulative_gpa, department_id, advisor_id, parent_user_id)
VALUES
(201, '1900101', 3.5, 1, 101, 301),
(202, '1900202', 3.8, 1, 101, NULL),
(203, '1900303', 3.2, 2, 104, NULL),
(204, '1900404', 3.9, 2, 104, 302);
GO

SET IDENTITY_INSERT Course ON;
INSERT INTO Course (course_id, course_code, title, description, credits)
VALUES
(1, 'CSE112', 'Intro to Programming', 'Learn the basics of programming.', 3),
(2, 'CSE221', 'Data Structures', 'Advanced data structures.', 3),
(3, 'SWE311', 'Software Engineering', 'Software lifecycle and design patterns.', 3);
SET IDENTITY_INSERT Course OFF;
GO

INSERT INTO Prerequisite (course_id, prereq_course_id)
VALUES
(2, 1),
(3, 2);
GO

SET IDENTITY_INSERT Semester ON;
INSERT INTO Semester (semester_id, name, start_date, end_date, registration_open)
VALUES
(1, 'Fall 2025', '2025-09-01', '2025-12-20', 1);
SET IDENTITY_INSERT Semester OFF;
GO

SET IDENTITY_INSERT OfferedCourse ON;
INSERT INTO OfferedCourse (offered_course_id, course_id, semester_id)
VALUES
(1, 1, 1),
(2, 2, 1),
(3, 3, 1);
SET IDENTITY_INSERT OfferedCourse OFF;
GO

INSERT INTO OfferedCourse_Instructor (offered_course_id, instructor_id)
VALUES
(1, 101),
(2, 101),
(3, 104);
GO

SET IDENTITY_INSERT Section ON;
INSERT INTO Section (section_id, offered_course_id, ta_instructor_id, section_number, capacity)
VALUES
(1, 1, 102, 'S1', 40),
(2, 1, 103, 'S2', 40),
(3, 2, 102, 'S1', 40),
(4, 3, 105, 'S1', 40);
SET IDENTITY_INSERT Section OFF;
GO

SET IDENTITY_INSERT Schedule ON;
INSERT INTO Schedule (schedule_id, offered_course_id, section_id, type, day_of_week, start_time, end_time, location)
VALUES
(1, 1, NULL, 'lecture', 'Monday', '09:00:00', '11:00:00', 'Hall A'),
(2, NULL, 1, 'section', 'Tuesday', '10:00:00', '12:00:00', 'Room 301'),
(3, NULL, 2, 'section', 'Wednesday', '10:00:00', '12:00:00', 'Room 302'),
(4, 2, NULL, 'lecture', 'Wednesday', '09:00:00', '11:00:00', 'Hall B'),
(5, NULL, 3, 'section', 'Thursday', '13:00:00', '15:00:00', 'Room 301'),
(6, 3, NULL, 'lecture', 'Monday', '13:00:00', '15:00:00', 'Hall C'),
(7, NULL, 4, 'section', 'Tuesday', '14:00:00', '16:00:00', 'Room 401');
SET IDENTITY_INSERT Schedule OFF;
GO

SET IDENTITY_INSERT Enrollment ON;
INSERT INTO Enrollment (enrollment_id, student_id, section_id, status)
VALUES
(1, 201, 1, 'approved'),
(2, 202, 2, 'approved'),
(3, 201, 3, 'approved'),
(4, 203, 4, 'approved'),
(5, 204, 4, 'approved');
SET IDENTITY_INSERT Enrollment OFF;
GO

INSERT INTO Grade (enrollment_id)
VALUES
(1), (2), (3), (4), (5);
GO

SET IDENTITY_INSERT CourseMaterial ON;
INSERT INTO CourseMaterial (material_id, offered_course_id, instructor_id, title, type, url_or_path)
VALUES
(1, 1, 101, 'Lecture 1 Slides', 'pdf', 'path/to/cse112_lec1.pdf'),
(2, 1, 101, 'Syllabus', 'pdf', 'path/to/cse112_syllabus.pdf');
SET IDENTITY_INSERT CourseMaterial OFF;
GO

SET IDENTITY_INSERT Assignment ON;
INSERT INTO Assignment (assignment_id, offered_course_id, instructor_id, title, questions, due_date, max_grade)
VALUES
(1, 1, 101, 'Assignment 1: Variables', 'Write a program that...', '2025-09-30 23:59:59', 100),
(2, 3, 104, 'Assignment 1: Requirements Doc', 'Write a PDD...', '2025-10-15 23:59:59', 100);
SET IDENTITY_INSERT Assignment OFF;
GO

SET IDENTITY_INSERT AssignmentSubmission ON;
INSERT INTO AssignmentSubmission (submission_id, assignment_id, student_id, content, file_path, grade, feedback)
VALUES
(1, 1, 201, 'Here is my submission text.', 'path/to/ali_submission.zip', 90.00, 'Good job, Ali.'),
(2, 1, 202, 'My code is attached.', 'path/to/mona_submission.zip', 95.00, 'Excellent work.'),
(3, 2, 203, NULL, 'path/to/omar_pdd.pdf', 88.00, 'Well-structured document.');
SET IDENTITY_INSERT AssignmentSubmission OFF;
GO

SET IDENTITY_INSERT Quiz ON;
INSERT INTO Quiz (quiz_id, offered_course_id, instructor_id, title, questions, due_date, max_grade)
VALUES
(1, 1, 102, 'Quiz 1: Loops', 'What is a for loop?', '2025-10-05 23:59:59', 100);
SET IDENTITY_INSERT Quiz OFF;
GO

SET IDENTITY_INSERT QuizSubmission ON;
INSERT INTO QuizSubmission (quiz_sub_id, quiz_id, student_id, content, grade)
VALUES
(1, 1, 201, 'A for loop is a control flow statement...', 9.00);
SET IDENTITY_INSERT QuizSubmission OFF;
GO

UPDATE g
SET g.assignments_total = (s.grade / 100.0) * 10
FROM Grade g
JOIN Enrollment e ON g.enrollment_id = e.enrollment_id
JOIN AssignmentSubmission s ON e.student_id = s.student_id
WHERE e.student_id = 201 AND s.assignment_id = 1;
GO

UPDATE g
SET g.quizzes_total = (q.grade / 100.0) * 5
FROM Grade g
JOIN Enrollment e ON g.enrollment_id = e.enrollment_id
JOIN QuizSubmission q ON e.student_id = q.student_id
WHERE e.student_id = 201 AND q.quiz_id = 1;
GO

SET IDENTITY_INSERT Announcement ON;
INSERT INTO Announcement (announcement_id, offered_course_id, author_user_id, title, content)
VALUES
(1, 1, 101, 'Welcome to CSE112', 'The course material is now available.'),
(2, 1, 102, 'Quiz 1 Graded', 'Your grades for Quiz 1 are now posted.'),
(3, 3, 104, 'Project Teams', 'Please form your project teams by next week.');
SET IDENTITY_INSERT Announcement OFF;
GO

SET IDENTITY_INSERT Message ON;
INSERT INTO Message (message_id, sender_user_id, recipient_user_id, content)
VALUES
(1, 301, 101, 'Dear Dr. Aris, I would like to check on my son Ali''s progress.'),
(2, 101, 301, 'Mr. Ibrahim, Ali is doing very well. His first assignment was great.'),
(3, 201, 102, 'Hi TA Ahmed, I have a question about Assignment 1.'),
(4, 204, 104, 'Dr. Fatima, when are your office hours this week?');
SET IDENTITY_INSERT Message OFF;
GO

SET IDENTITY_INSERT FacultyResearch ON;
INSERT INTO FacultyResearch (research_id, instructor_id, publication_title, journal_or_conference, publish_date)
VALUES
(1, 101, 'New Algorithms in Graph Theory', 'IEEE Transactions', '2024-05-15'),
(2, 104, 'Agile Methodologies in Large Teams', 'ICSE Conference', '2025-01-20');
SET IDENTITY_INSERT FacultyResearch OFF;
GO

-- -----------------------------------------------------
-- Script End
-- -----------------------------------------------------