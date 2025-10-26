-- -----------------------------------------------------------------
-- --- Full University LMS Script (MySQL Compatible V3) ---
-- --- Fixes for Multiple Cascade Paths ---
-- -----------------------------------------------------------------

DROP DATABASE IF EXISTS university_lms_db;

CREATE DATABASE university_lms_db;

USE university_lms_db;

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
DROP TABLE IF EXISTS `User`;

-- Creating tables in order of dependency

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

CREATE TABLE Course (
    course_id INT AUTO_INCREMENT PRIMARY KEY,
    course_code VARCHAR(20) NOT NULL UNIQUE,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    credits INT NOT NULL
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
    FOREIGN KEY (created_by) REFERENCES User(user_id)
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
    FOREIGN KEY (user_id) REFERENCES User(user_id),
    FOREIGN KEY (reviewed_by) REFERENCES User(user_id)
);
-- -----------------------------------------------------
-- Section 2: Sample Data Insertion
-- -----------------------------------------------------

-- -----------------------------------------------------------------
-- --- Section 1: Add New Users (Admin, Instructors, Students, Parents)
-- -----------------------------------------------------------------

INSERT INTO `User` (user_id, national_id, name, email, official_mail, password_hash, role)
VALUES
-- 1 Admin User (The original script had '1', using '10' for this new one)
(10, '1000000010', 'New Admin', 'admin_new@mail.com', 'admin_new@uni.edu', 'hashed_password', 'admin'),

-- 10 Professor Users (IDs 101-110)
(101, '200000101', 'Prof. Ahmed Hassan', 'prof.hassan@mail.com', 'ahmed.hassan@uni.edu', 'hashed_password', 'instructor'),
(102, '200000102', 'Prof. Fatima Ali', 'prof.ali@mail.com', 'fatima.ali@uni.edu', 'hashed_password', 'instructor'),
(103, '200000103', 'Prof. Youssef Ibrahim', 'prof.ibrahim@mail.com', 'youssef.ibrahim@uni.edu', 'hashed_password', 'instructor'),
(104, '200000104', 'Prof. Mariam Omar', 'prof.omar@mail.com', 'mariam.omar@uni.edu', 'hashed_password', 'instructor'),
(105, '200000105', 'Prof. Khaled Mahmoud', 'prof.mahmoud@mail.com', 'khaled.mahmoud@uni.edu', 'hashed_password', 'instructor'),
(106, '200000106', 'Prof. Sara Adel', 'prof.adel@mail.com', 'sara.adel@uni.edu', 'hashed_password', 'instructor'),
(107, '200000107', 'Prof. David George', 'prof.george@mail.com', 'david.george@uni.edu', 'hashed_password', 'instructor'),
(108, '200000108', 'Prof. Hoda Zaki', 'prof.zaki@mail.com', 'hoda.zaki@uni.edu', 'hashed_password', 'instructor'),
(109, '200000109', 'Prof. Tarek Fathy', 'prof.fathy@mail.com', 'tarek.fathy@uni.edu', 'hashed_password', 'instructor'),
(110, '200000110', 'Prof. Mona Said', 'prof.said@mail.com', 'mona.said@uni.edu', 'hashed_password', 'instructor'),

-- 10 TA Users (IDs 201-210)
(201, '200000201', 'TA Amr Khalid', 'ta.amr@mail.com', 'amr.khalid@uni.edu', 'hashed_password', 'instructor'),
(202, '200000202', 'TA Laila Nader', 'ta.laila@mail.com', 'laila.nader@uni.edu', 'hashed_password', 'instructor'),
(203, '200000203', 'TA Mostafa Gaber', 'ta.mostafa@mail.com', 'mostafa.gaber@uni.edu', 'hashed_password', 'instructor'),
(204, '200000204', 'TA Reem Shawky', 'ta.reem@mail.com', 'reem.shawky@uni.edu', 'hashed_password', 'instructor'),
(205, '200000205', 'TA Omar Sherif', 'ta.omar@mail.com', 'omar.sherif@uni.edu', 'hashed_password', 'instructor'),
(206, '200000206', 'TA Salma Tamer', 'ta.salma@mail.com', 'salma.tamer@uni.edu', 'hashed_password', 'instructor'),
(207, '200000207', 'TA Karim Ehab', 'ta.karim@mail.com', 'karim.ehab@uni.edu', 'hashed_password', 'instructor'),
(208, '200000208', 'TA Dina Magdy', 'ta.dina@mail.com', 'dina.magdy@uni.edu', 'hashed_password', 'instructor'),
(209, '200000209', 'TA Fares Adel', 'ta.fares@mail.com', 'fares.adel@uni.edu', 'hashed_password', 'instructor'),
(210, '200000210', 'TA Hana Lotfy', 'ta.hana@mail.com', 'hana.lotfy@uni.edu', 'hashed_password', 'instructor'),

-- 10 Student Users (IDs 301-310)
(301, '300000301', 'Student Ali Ahmed', 'student.ali@mail.com', 'ali.ahmed@student.uni.edu', 'hashed_password', 'student' ),
(302, '300000302', 'Student Mona Kamal', 'student.mona@mail.com', 'mona.kamal@student.uni.edu', 'hashed_password', 'student'),
(303, '300000303', 'Student Omar Tarek', 'student.omar@mail.com', 'omar.tarek@student.uni.edu', 'hashed_password', 'student'),
(304, '300000304', 'Student Sara Emad', 'student.sara@mail.com', 'sara.emad@student.uni.edu', 'hashed_password', 'student'),
(305, '300000305', 'Student Youssef Hany', 'student.youssef@mail.com', 'youssef.hany@student.uni.edu', 'hashed_password', 'student'),
(306, '300000306', 'Student Farah Islam', 'student.farah@mail.com', 'farah.islam@student.uni.edu', 'hashed_password', 'student'),
(307, '300000307', 'Student Adam Sameh', 'student.adam@mail.com', 'adam.sameh@student.uni.edu', 'hashed_password', 'student'),
(308, '300000308', 'Student Lama Hesham', 'student.lama@mail.com', 'lama.hesham@student.uni.edu', 'hashed_password', 'student'),
(309, '300000309', 'Student Ziad Shady', 'student.ziad@mail.com', 'ziad.shady@student.uni.edu', 'hashed_password', 'student'),
(310, '300000310', 'Student Malak Rami', 'student.malak@mail.com', 'malak.rami@student.uni.edu', 'hashed_password', 'student'),

-- 10 Parent Users (IDs 401-410, linked to students 301-310)
(401, '400000401', 'Mr. Ahmed (Ali''s Father)', 'parent.ahmed@mail.com', 'ahmed.parent@uni.edu', 'hashed_password', 'parent'),
(402, '400000402', 'Mrs. Kamal (Mona''s Mother)', 'parent.kamal@mail.com', 'kamal.parent@uni.edu', 'hashed_password', 'parent'),
(403, '400000403', 'Mr. Tarek (Omar''s Father)', 'parent.tarek@mail.com', 'tarek.parent@uni.edu', 'hashed_password', 'parent'),
(404, '400000404', 'Mrs. Emad (Sara''s Mother)', 'parent.emad@mail.com', 'emad.parent@uni.edu', 'hashed_password', 'parent'),
(405, '400000405', 'Mr. Hany (Youssef''s Father)', 'parent.hany@mail.com', 'hany.parent@uni.edu', 'hashed_password', 'parent'),
(406, '400000406', 'Mrs. Islam (Farah''s Mother)', 'parent.islam@mail.com', 'islam.parent@uni.edu', 'hashed_password', 'parent'),
(407, '400000407', 'Mr. Sameh (Adam''s Father)', 'parent.sameh@mail.com', 'sameh.parent@uni.edu', 'hashed_password', 'parent'),
(408, '400000408', 'Mrs. Hesham (Lama''s Mother)', 'parent.hesham@mail.com', 'hesham.parent@uni.edu', 'hashed_password', 'parent'),
(409, '400000409', 'Mr. Shady (Ziad''s Father)', 'parent.shady@mail.com', 'shady.parent@uni.edu', 'hashed_password', 'parent'),
(410, '400000410', 'Mrs. Rami (Malak''s Mother)', 'parent.rami@mail.com', 'rami.parent@uni.edu', 'hashed_password', 'parent');

-- -----------------------------------------------------------------
-- --- Section 2: Add Instructors (from Users 101-110 and 201-210)
-- -----------------------------------------------------------------

INSERT INTO Instructor (instructor_id, instructor_type, office_hours)
VALUES
-- 10 Professors
(101, 'professor', 'Mon 10:00-12:00, Room A101'),
(102, 'professor', 'Tue 11:00-13:00, Room A102'),
(103, 'professor', 'Wed 09:00-11:00, Room B201'),
(104, 'professor', 'Thu 14:00-16:00, Room B202'),
(105, 'professor', 'Mon 13:00-15:00, Room C301'),
(106, 'professor', 'Tue 10:00-12:00, Room C302'),
(107, 'professor', 'Wed 12:00-14:00, Room D401'),
(108, 'professor', 'Thu 09:00-11:00, Room D402'),
(109, 'professor', 'Mon 14:00-16:00, Room E501'),
(110, 'professor', 'Tue 15:00-17:00, Room E502'),
-- 10 TAs
(201, 'ta', 'By Appointment, TA Room 1'),
(202, 'ta', 'By Appointment, TA Room 1'),
(203, 'ta', 'By Appointment, TA Room 2'),
(204, 'ta', 'By Appointment, TA Room 2'),
(205, 'ta', 'By Appointment, TA Room 3'),
(206, 'ta', 'By Appointment, TA Room 3'),
(207, 'ta', 'By Appointment, TA Room 4'),
(208, 'ta', 'By Appointment, TA Room 4'),
(209, 'ta', 'By Appointment, TA Room 5'),
(210, 'ta', 'By Appointment, TA Room 5');

-- -----------------------------------------------------------------
-- --- Section 3: Add Sample Departments (Required for Students)
-- -----------------------------------------------------------------

-- This adds a few departments and assigns professors as unit heads
INSERT INTO Department (department_id, name, unit_head_id)
VALUES
(1, 'Computer and Systems Engineering', 101),
(2, 'Architecture Engineering', 102),
(3, 'Mechanical Power Engineering', 103),
(4, 'Electronics and Communication Engineering', 104);

-- -----------------------------------------------------------------
-- --- Section 4: Add Students (from Users 301-310)
-- -----------------------------------------------------------------

INSERT INTO Student (student_id, student_uid, cumulative_gpa, department_id, advisor_id, parent_user_id)
VALUES
-- Linking students to parents (301 -> 401, 302 -> 402, etc.)
-- Linking students to advisors and departments
(301, 'S-301', 3.50, 1, 101, 401),
(302, 'S-302', 3.60, 2, 102, 402),
(303, 'S-303', 3.20, 3, 103, 403),
(304, 'S-304', 3.80, 4, 104, 404),
(305, 'S-305', 3.10, 1, 105, 405),
(306, 'S-306', 3.90, 2, 106, 406),
(307, 'S-307', 3.40, 3, 107, 407),
(308, 'S-308', 3.75, 4, 108, 408),
(309, 'S-309', 3.00, 1, 109, 409),
(310, 'S-310', 3.85, 2, 110, 410);
-- -----------------------------------------------------------------
-- --- Sample Course Data Insertion ---
-- --- Based on CHEP Bylaw 2018 PDF ---
-- -----------------------------------------------------------------
-- -----------------------------------------------------------------
-- --- Department Data Insertion ---
-- --- Based on CHEP Bylaw 2018 PDF (Table 2) ---
-- -----------------------------------------------------------------

INSERT INTO Department (name, unit_head_id) VALUES
('Engineering Physics and Mathematics Department', NULL), -- Acronym PHM [cite: 45]
('Design and Production Engineering Department', NULL), -- Acronym MDP [cite: 45]
('Mechanical Power Engineering Department', NULL), -- Acronym MEP [cite: 45]
('Automotive Engineering Department', NULL), -- Acronym MEA [cite: 45]
('Mechatronics Engineering Department', NULL), -- Acronym MCT [cite: 45]
('Architecture Engineering Department', NULL), -- Acronym ARC [cite: 45]
('Urban Design and Planning Department', NULL), -- Acronym UPL [cite: 45]
('Electrical Power and Machines Engineering Department', NULL), -- Acronym EPM [cite: 45]
('Electronics and Communication Engineering Department', NULL), -- Acronym ECE [cite: 45]
('Computer and Systems Engineering Department', NULL), -- Acronym CSE [cite: 45]
('Structural Engineering Department', NULL), -- Acronym CES [cite: 45]
('Irrigation and Hydraulics Engineering Department', NULL), -- Acronym CEI [cite: 45]
('Public Works Engineering Department', NULL); -- Acronym CEP [cite: 45]

-- -----------------------------------------------------------------
-- --- End of Department Data Insertion ---
-- -----------------------------------------------------------------
-- -----------------------------------------------------------------
-- --- Section 3: Full Course Catalog Insertion
-- --- REF: All courses from V3 script have been deduplicated and
-- --- organized by requirement type (Uni, Faculty, Department)
-- -----------------------------------------------------------------

INSERT INTO Course (course_code, title, credits) VALUES

-- --- University Requirements (ASU) ---
('ASU011', 'Technical English Language', 0),
('ASU111', 'Human Rights', 2),
('ASU112', 'Report Writing & Communication skills', 3),
('ASU113', 'Professional Ethics and Legislations', 3),
('ASU114', 'Selected Topics in Contemporary Issues', 2),
('ASU321', 'Innovation and Entrepreneurship', 2),
('ASU322', 'Language Course - can accept equivalent certificates', 3),
('ASU323', 'Introduction to Accounting', 2),
('ASU324', 'History of Engineering & Technology', 3),
('ASU331', 'Human Resource Management', 2),
('ASU332', 'History of Architecture', 2),
('ASU333', 'Introduction to Marketing', 2),
('ASU334', 'Building Safety and Fire Protection', 2),
('ASU335', 'Literature and Arts', 2),
('ASU336', 'Business Administration', 2),

-- --- Faculty Requirements (ENG) ---
('ENG111', 'Fundamentals of Engineering', 2),

-- --- Department: Architecture Engineering (ARC) ---
('ARC111', 'Principles of Architecture Design Studio', 3),
('ARC112', 'Creativity and Design Studio', 4),
('ARC131', 'History of Arts and Architecture (1): Ancient Civilizatio', 4),
('ARC132', 'History of Arts and Architecture (2): History of Islamic and Western Architecture', 5),
('ARC141', 'Architectural Representation', 3),
('ARC142', 'Digital Presentation of the Built Environment', 2),
('ARC143', 'Building Engineering Drawing', 3),
('ARC151', 'Building (1): Conventional Construction Systems', 3),
('ARC152', 'Building (2): Finishing Works', 5),
('ARC161', 'Introduction to Lighting Systems', 2),
('ARC211', 'Building Type Design Studio', 8),
('ARC221', 'Design Methods', 3),
('ARC241', 'Modeling of the Built Environment', 2),
('ARC251', 'Building (3): Advanced Construction and Finishing works', 3),
('ARC254', 'building (3): Landscape Construction', 2),
('ARC261', 'Control of Thermal Environment', 3),
('ARC262', 'Principles of Sustainable Architecture', 3),
('ARC263', 'Fundamentals of Building Acoustics', 2),
('ARC311', 'Smart Systems Design Studio', 4),
('ARC321', 'Theory and Philosophy of Contemporary Architecture', 5),
('ARC322', 'Architectural Criticism and Project Evaluation', 2),
('ARC323', 'Built Environment Accessibility', 2),
('ARC341', 'Photography and Architecture', 2),
('ARC351', 'Working Design (1): Execution Drawings Coordination, annotation and Coding', 3),
('ARC352', 'Working Design (2): Blow-Ups Detailing, items specifications and BOQS', 6),
('ARC361', 'Lighting in Architecture', 2),
('ARC362', 'Acoustics in Architecture', 2),
('ARC363', 'Renewable Energy and Buildings', 2),
('ARC364', 'Outdoor Lighting and Effects', 2),
('ARC366', 'Responsive Architecture Installations', 2),
('ARC368', 'Soundscape and Aural Architecture', 2),
('ARC411', 'Thematic design studio', 4),
('ARC412', 'Technological Design Studio', 4),
('ARC421', 'Ergonomics (Designing Livable Spaces) & Interior Design Principles', 2),
('ARC422', 'Human Aspects in Architecture', 3),
('ARC423', 'Identity and Contemporaneity in Middle East Architecture', 3),
('ARC424', 'Introduction to Modern Art Movements', 3),
('ARC425', 'Contemporary Vernacular Architecture', 2),
('ARC441', 'Building Information Modeling (BIM)', 3),
('ARC442', 'Principles of Parametric Design', 3),
('ARC443', 'Computer Applications in Environmental Engineering', 3),
('ARC451', 'Working Design (3): Execution Documents Complexity', 3),
('ARC452', 'Working Design (3): Residential Towers Execution Documents', 3),
('ARC453', 'Housing Maintenance, Post-occupancy Evaluation, and Value Engineering', 3),
('ARC461', 'Daylighting and Thermal Performance', 3),
('ARC462', 'Sustainable Building Rating Systems', 2),
('ARC463', 'Renewable Energy Systems and Economics', 2),
('ARC466', 'Building Envelope Design', 2),
('ARC467', 'Building Energy Conservation Technologies', 3),
('ARC468', 'Building Illumination and Day Lighting', 3),
('ARC469', 'Building Acoustics', 3),
('ARC471', 'Feasibility Studies', 2),
('ARC472', 'Maintenance of Buildings', 3),
('ARC473', 'Building Life Cycle Assessment', 3),
('ARC474', 'Building Commissioning', 3),
('ARC491', 'Architect. & Building Tech. Graduation Project (1)', 2),
('ARC492', 'Architect. & Building Tech. Graduation Project (2)', 6),

-- --- Department: Irrigation and Hydraulics Engineering (CEI) ---
('CEI111', 'Fluid Mechanics', 2),
('CEI112', 'Hydraulics (1)', 2),
('CEI113', 'Fluid Mechanics for Civil Engineers', 3),
('CEI131', 'Civil Drawings', 2),
('CEI132', 'Civil Engineering Drawing', 2),
('CEI211', 'Hydraulics (2)', 2),
('CEI212', 'Hydraulics', 3),
('CEI221', 'Irrigation and Drainage Engineering', 4),
('CEI222', 'Irrigation and Drainage', 3),
('CEI261', 'Engineering Economics and Management', 2),
('CEI262', 'Principles of Water Resources Engineering', 2),
('CEI311', 'Infrastructure Planning and landscape Irrigation', 2),
('CEI321', 'Modern Irrigation Systems', 2),
('CEI331', 'Design of Irrigation Works', 2),
('CEI332', 'Hydraulic Structures (1)', 2),
('CEI341', 'Coastal Engineering', 2),
('CEI351', 'Environmental Hydrology', 2),
('CEI352', 'Applied Hydrology', 2),
('CEI361', 'Water Resources Engineering', 2),
('CEI411', 'Hydraulics of Networks', 3),
('CEI412', 'Pump Station Engineering', 2),
('CEI413', 'Environmental Hydraulics', 2),
('CEI414', 'River Engineering', 2),
('CEI415', 'Lab and Field Measurements in Water Resources field', 2),
('CEI416', 'Hydraulic Modeling', 2),
('CEI417', 'Sustainable Urban Water Systems', 2),
('CEI421', 'Sustainable Drainage Systems', 2),
('CEI422', 'Advanced Irrigation Engineering', 2),
('CEI431', 'Hydraulic Structures (2)', 2),
('CEI432', 'Hydraulic Structures (3)', 2),
('CEI433', 'Dams Engineering', 2),
('CEI434', 'Advanced Hydraulic Structures', 2),
('CEI435', 'Hydraulic Structures', 2),
('CEI436', 'Topics in Hydraulic Structures', 2),
('CEI441', 'Port Engineering and Navigation', 2),
('CEI442', 'Coastal Environment Engineering', 2),
('CEI443', 'Inland Navigation', 2),
('CEI451', 'Ground Water Hydrology', 2),
('CEI461', 'Geographical Information Systems in Water Engineering', 2),
('CEI462', 'Water Quality', 2),
('CEI463', 'Environmental Impact Assessment for Water Engineering Projects', 2),
('CEI464', 'Climate Change Adaptation in Water Resources field', 2),
('CEI465', 'Non-Conventional Water Resources', 2),
('CEI466', 'Water Security and Governance', 2),
('CEI491', 'Graduation Project', 6),
('CEI492', 'Civil Engineering Design Graduation Project (1)', 3),
('CEI493', 'Civil Engineering Senior Seminar', 2),
('CEI494', 'Civil Engineering Design Graduation Project (2)', 3),

-- --- Department: Public Works Engineering (CEP) ---
('CEP011', 'Projection and Engineering Graphics', 3),
('CEP111', 'Plane Surveying (1)', 2),
('CEP112', 'Plane Surveying (2)', 3),
('CEP113', 'Surveying', 4),
('CEP151', 'Introduction to Environmental Engineering', 2),
('CEP211', 'Topographic Surveying (1)', 2),
('CEP212', 'Engineering Surveying', 3),
('CEP213', 'Surveying (1)', 4),
('CEP214', 'Surveying (2)', 4),
('CEP221', 'Introduction to Transportation & Traffic Engineering', 3),
('CEP251', 'Green Building Systems and Infrastructure', 2),
('CEP311', 'Topographic Surveying (2)', 2),
('CEP312', 'Surveying (3)', 2),
('CEP313', 'Photogrammetric Surveying', 2),
('CEP314', 'Infrastructure Network Planning', 2),
('CEP321', 'Transportation Planning', 3),
('CEP322', 'Transportation and Roads Engineering', 2),
('CEP323', 'Principles of Traffic Engineering', 2),
('CEP331', 'Roads and Airport Engineering', 3),
('CEP332', 'Highway Geometric and Structural Design', 3),
('CEP333', 'Road Construction Material', 2),
('CEP341', 'Railway Engineering (1)', 3),
('CEP342', 'Railway Engineering Principles', 2),
('CEP351', 'Water and Wastewater Networks', 3),
('CEP352', 'Sanitary Engineering', 3),
('CEP353', 'Principles of Water and Wastewater Treatment', 3),
('CEP354', 'Computer Applications in Sanitary Engineering', 2),
('CEP411', 'Geodetic Surveying', 3),
('CEP412', 'Hydrographic Surveying', 2),
('CEP413', 'Geographic Information Systems', 2),
('CEP415', 'Geodetic and GPS Surveying', 2),
('CEP416', 'Hydrographic Surveying and Harbor Engineering', 2),
('CEP417', 'GIS Applications in Civil Infrastructure Projects', 2),
('CEP421', 'Traffic Engineering', 3),
('CEP422', 'Traffic Management Systems', 2),
('CEP423', 'Traffic Studies and Analysis', 2),
('CEP424', 'Transportation Economics', 2),
('CEP425', 'Urban Transportation Planning', 2),
('CEP426', 'Intelligent Transportation Systems', 2),
('CEP431', 'Highway Construction Technology', 3),
('CEP432', 'Road and Airport Maintenance', 2),
('CEP433', 'Airport Planning and Design', 2),
('CEP434', 'Road Maintenance', 2),
('CEP435', 'Road Construction', 2),
('CEP436', 'Airport Engineering', 2),
('CEP441', 'Railway Engineering (2)', 2),
('CEP443', 'Railway Signaling Systems', 2),
('CEP451', 'Water and Wastewater Treatment', 3),
('CEP452', 'Environmental Engineering', 2),
('CEP453', 'Sludge Management', 2),
('CEP454', 'Solid Waste Management', 2),
('CEP455', 'Design of Water and Wastewater Networks', 2),
('CEP456', 'Water and Wastewater Supply', 2),
('CEP457', 'Reuse of Treated Wastewater', 2),
('CEP464', 'Geotechnical Engineering for Infrastructures', 2),
('CEP491', 'Utilities and Infrastructure Graduation Project', 6),
('CEP492', 'Civil Engineering Design Graduation Project (1)', 3),
('CEP493', 'Civil Engineering Senior Seminar', 2),
('CEP494', 'Civil Engineering Design Graduation Project (2)', 3),

-- --- Department: Structural Engineering (CES) ---
('CES111', 'Structural Mechanics (1)', 4),
('CES112', 'Structural Mechanics (2)', 4),
('CES113', 'Structural Mechanics', 3),
('CES114', 'Strength of Materials', 3),
('CES115', 'Structural Analysis for Architecture Engineering', 2),
('CES151', 'Structures and Properties of Construction Materials', 2),
('CES152', 'Properties and Testing of Materials', 2),
('CES171', 'Construction Management', 2),
('CES172', 'Engineering Economics and Finance', 2),
('CES211', 'Structural Analysis (1)', 3),
('CES212', 'Structural Analysis (2)', 3),
('CES213', 'Structural Analysis', 3),
('CES221', 'Concrete Design (1)', 2),
('CES222', 'Concrete Design (2)', 2),
('CES223', 'Design Principles', 1),
('CES225', 'Concrete and Steel Structures', 5),
('CES251', 'Concrete Technology (1)', 3),
('CES252', 'Concrete Technology (2)', 3),
('CES261', 'Geology and Geotechnical Engineering', 2),
('CES262', 'Geotechnical Engineering (1)', 2),
('CES263', 'Soil Mechanics (1)', 4),
('CES271', 'Project Management Essentials', 2),
('CES313', 'Computer Aided Structural Design', 2),
('CES314', 'Computer Applications in Structural Design', 3),
('CES315', 'Introduction to Structural Dynamics', 3),
('CES321', 'Design of Concrete Floors', 3),
('CES322', 'Design of Concrete Halls', 3),
('CES323', 'Construction Techniques', 2),
('CES325', 'Construction Engineering', 3),
('CES341', 'Design and Behavior of Steel Structures (1)', 3),
('CES342', 'Design and Behavior of Steel Structures (2)', 3),
('CES343', 'Behavior of Steel Structures', 2),
('CES351', 'Advanced Composite Materials', 2),
('CES361', 'Geotechnical Engineering (2)', 2),
('CES363', 'Geotechnical Site Characterization', 2),
('CES364', 'Soil Mechanics (2)', 3),
('CES365', 'Foundation Design (1)', 3),
('CES372', 'Construction Planning and Scheduling', 3),
('CES373', 'Construction Cost Management', 3),
('CES411', 'Advanced Structural Analysis', 2),
('CES412', 'Finite Element Method', 2),
('CES413', 'Earthquake Engineering', 2),
('CES414', 'Dynamic Floor Vibrations', 2),
('CES421', 'Design of Prestressed Concrete and Bridges', 3),
('CES423', 'Design of Concrete Bridges', 2),
('CES424', 'Masonry Structures', 2),
('CES426', 'Design of Water Concrete Structures', 2),
('CES428', 'Masonry', 3),
('CES429', 'Advanced Design of Reinforced Concrete Structures', 3),
('CES430', 'Construction Methods and Techniques', 2),
('CES441', 'Design of Steel Bridges (1)', 3),
('CES442', 'Design of Steel Bridges (2)', 2),
('CES443', 'Steel Plated Structures.', 2),
('CES444', 'Construction of Steel Structures', 2),
('CES446', 'Steel Structures Design (3)', 3),
('CES447', 'Advanced Design of Steel Structures', 3),
('CES451', 'Repair and Strengthening of Structures', 2),
('CES452', 'Special Types of Concrete', 2),
('CES453', 'Sustainability of Construction and Building Physics', 2),
('CES454', 'Modern Building Materials', 3),
('CES455', 'Materials and Technologies for Sustainable Construction', 3),
('CES461', 'Foundation Engineering (2)', 2),
('CES462', 'Ground Improvement', 2),
('CES463', 'Computer Applications in Geotechnical Engineering', 2),
('CES465', 'Foundation Engineering of Water Structures (1)', 3),
('CES466', 'Foundation Engineering of Water Structures (2)', 2),
('CES467', 'Foundation Design (2)', 3),
('CES472', 'Risk and Safety Management', 2),
('CES473', 'Construction Contracts and Cost Estimation', 2),
('CES474', 'Resources Management', 3),
('CES475', 'Risk and Safety Management', 3),
('CES476', 'Legal Issues in Construction', 3),
('CES477', 'Computer Applications in Construction Management', 3),
('CES478', 'Quantity Surveying and Estimating', 3),
('CES479', 'Planning and Scheduling of Repetitive Projects', 2),
('CES480', 'Environmental Risk Management', 3),
('CES491', 'Structural Engineering Graduation Project (1)', 2),
('CES492', 'Structural Engineering Graduation Project (2)', 4),
('CES493', 'Building Engineering Design Graduation Project (1)', 3),
('CES494', 'Senior Seminar', 2),
('CES495', 'Building Engineering Design Graduation Project (2)', 3),

-- --- Department: Computer and Systems Engineering (CSE) ---
('CSE031', 'Computing in Engineering', 2),
('CSE111', 'Logic Design', 3),
('CSE131', 'Computer Programming', 3),
('CSE211', 'Introduction to Embedded Systems', 3),
('CSE212', 'Computer Organization', 3),
('CSE231', 'Advanced Computer Programming', 3),
('CSE232', 'Advanced Software Engineering', 3),
('CSE233', 'Agile Software Engineering', 2),
('CSE271', 'System Dynamics and Control Components', 4),
('CSE314', 'Parallel and Cluster Computing', 2),
('CSE331', 'Data Structures and Algorithms', 3),
('CSE332', 'Design and Analysis of Algorithms', 3),
('CSE333', 'Database Systems', 3),
('CSE334', 'Software Engineering', 3),
('CSE335', 'Operating Systems', 3),
('CSE336', 'Software Design Patterns', 2),
('CSE338', 'Software Testing, Validation, and Verification', 3),
('CSE339', 'Software Formal Specifications', 2),
('CSE341', 'Internet Programming', 3),
('CSE342', 'Program Analysis', 2),
('CSE343', 'Software Engineering Process Management', 2),
('CSE344', 'Dependability and Reliability of Software Systems', 2),
('CSE345', 'Business Process Modeling', 2),
('CSE346', 'Advanced Database Systems', 2),
('CSE351', 'Computer Networks', 3),
('CSE353', 'Industrial Networks', 3),
('CSE354', 'Distributed Computing', 3),
('CSE355', 'Parallel and Distributed Algorithms', 2),
('CSE356', 'Internet of Things', 2),
('CSE371', 'Control Engineering', 3),
('CSE372', 'Simulation of Engineering Systems', 2),
('CSE373', 'Digital Control Systems', 2),
('CSE374', 'Digital Image Processing', 2),
('CSE376', 'Digital Signals Processing', 2),
('CSE377', 'Pattern Recognition', 2),
('CSE378', 'Computer Graphics', 2),
('CSE379', 'Human-Computer Interaction', 2),
('CSE381', 'Introduction to Machine Learning', 2),
('CSE411', 'Real-Time and Embedded Systems Design', 3),
('CSE412', 'Embedded Operating Systems', 3),
('CSE431', 'Mobile Programming', 3),
('CSE432', 'Automata and Computability', 3),
('CSE433', 'Software Performance Evaluation', 3),
('CSE434', 'Aspect- and Service-Oriented Software Systems', 3),
('CSE435', 'Secure Code Development', 3),
('CSE436', 'Software Quality Assurance', 3),
('CSE438', 'Selected Topics in Software Product Lines', 3),
('CSE439', 'Design of Compilers', 3),
('CSE441', 'Software Project Management', 2),
('CSE451', 'Computer and Network Security', 3),
('CSE455', 'High-Performance Computing', 2),
('CSE456', 'Cloud Computing', 3),
('CSE457', 'Mobile and Wireless Networks', 3),
('CSE458', 'Computer and Network Forensics', 3),
('CSE461', 'Selected Topics in Distributed & Mobile Computing', 3),
('CSE471', 'Robotic Systems', 2),
('CSE472', 'Artificial Intelligence', 3),
('CSE473', 'Computational Intelligence', 2),
('CSE474', 'Visualization', 3),
('CSE475', 'Biomedical Engineering', 2),
('CSE476', 'Fundamentals of Big-Data Analytics', 2),
('CSE477', 'Fundamentals of Deep Learning', 2),
('CSE478', 'Selected Topics in Systems and Artificial Intelligence', 2),
('CSE479', 'Multimedia Engineering', 3),
('CSE481', 'Computer Animation', 3),
('CSE482', 'Game Design and Development', 3),
('CSE483', 'Computer Vision', 3),
('CSE484', 'Big-Data Analytics', 3),
('CSE485', 'Deep Learning', 3),
('CSE486', 'Bioinformatics', 3),
('CSE487', 'Selected Topics in Multimedia & Computer Graphics', 3),
('CSE488', 'Ontologies and the Semantic Web', 3),
('CSE489', 'Selected Topics in Data Science', 3),
('CSE491', 'Computer Engineering Graduation Project (1)', 3),
('CSE492', 'Computer Engineering Graduation Project (2)', 3),

-- --- Department: Electronics and Communication Engineering (ECE) ---
('ECE111', 'Electronic Materials', 3),
('ECE131', 'Electrostatics and Magnetostatics', 3),
('ECE211', 'Electronics', 3),
('ECE212', 'Digital Circuits', 3),
('ECE213', 'Solid State Electronic Devices', 3),
('ECE214', 'Electronic Circuits (1)', 4),
('ECE215', 'Introduction to electronics', 2),
('ECE251', 'Signals and Systems Fundamentals', 4),
('ECE252', 'Fundamentals of Communication Systems', 3),
('ECE253', 'Signals and Systems', 4),
('ECE254', 'Analog Communications', 3),
('ECE255', 'Digital Signal Processing', 3),
('ECE311', 'Advanced Semiconductor Devices', 2),
('ECE312', 'Analog Circuits (1)', 3),
('ECE313', 'Analog Circuits (2)', 3),
('ECE314', 'VLSI Design', 3),
('ECE315', 'Electronic Circuits (2)', 3),
('ECE316', 'Digital Circuit Design', 3),
('ECE317', 'Modern VLSI Devices', 3),
('ECE318', 'Electronic Measurements and Instrumentation', 3),
('ECE331', 'Electromagnetic Waves', 3),
('ECE332', 'Waveguides', 3),
('ECE333', 'Microwave Engineering', 4),
('ECE334', 'Optical Fiber Communications', 4),
('ECE335', 'Microwave Measurements', 3),
('ECE336', 'Integrated Optics and Optical MEMS', 3),
('ECE337', 'Microwave Circuits', 3),
('ECE338', 'Optical Sensing and Instrumentation', 3),
('ECE351', 'Analog and Digital Communication Systems', 3),
('ECE352', 'Telecommunication networks', 3),
('ECE353', 'Wireless Communication Networks', 3),
('ECE354', 'Digital Communications', 3),
('ECE355', 'Communication Networks (1)', 3),
('ECE356', 'Electro-Acoustical Engineering', 3),
('ECE357', 'Statistical Signal Processing', 3),
('ECE358', 'Wireless Communications', 3),
('ECE359', 'Signal Processing for Multimedia', 3),
('ECE411', 'Integrated circuits technology', 3),
('ECE412', 'Analog integrated circuits design', 3),
('ECE413', 'ASIC Design and Automation', 3),
('ECE414', 'RF Design', 3),
('ECE415', 'Electronic Instrumentation', 3),
('ECE416', 'MEMS Design', 3),
('ECE417', 'Low Power Digital Design', 3),
('ECE418', 'Selected Topics in Electronics', 3),
('ECE419', 'Selected Topics in Circuits and Systems', 3),
('ECE431', 'Optoelectronics', 3),
('ECE432', 'Antenna Engineering and Propagation', 2),
('ECE433', 'Microwave Circuits and Systems', 3),
('ECE434', 'Optical Communication Systems', 3),
('ECE435', 'Fundamentals of Photonics', 3),
('ECE436', 'Micro Photonic Systems', 3),
('ECE437', 'Selected Topics in Electromagnetics', 3),
('ECE438', 'Microwave Devices', 3),
('ECE439', 'Optoelectronic Devices', 3),
('ECE440', 'RF and Microwave Systems', 3),
('ECE441', 'Selected Topics in Physical and Wave Electronics', 3),
('ECE451', 'Digital Signal Processing Basics', 2),
('ECE452', 'Information Theory and Coding', 3),
('ECE453', 'Modern Communication Systems', 3),
('ECE454', 'Satellite Communication Systems', 3),
('ECE455', 'Selected Topics in Communication Systems', 3),
('ECE456', 'Selected Topics in Signal Processing', 3),
('ECE457', 'Selected Topics in Telecommunication Networks', 3),
('ECE458', 'Communication Networks (2)', 3),
('ECE459', 'Mobile Communications', 3),
('ECE460', 'Machine Learning for Multimedia', 3),
('ECE461', 'Selected Topics in Signals & Communication Systems', 3),
('ECE491', 'Graduation Project (1)', 3),
('ECE492', 'Graduation Project (2)', 3),

-- --- Department: Electrical Power and Machines Engineering (EPM) ---
('EPM111', 'Electrical Circuits (1)', 4),
('EPM112', 'Electromagnetic Fields', 3),
('EPM113', 'Electrical measurements', 3),
('EPM114', 'Fundamentals of Electrical Circuits', 3),
('EPM115', 'Fundamentals of Electromagnetic Fields', 3),
('EPM116', 'Electrical Circuits and Machines', 4),
('EPM117', 'Energy Resources and Renewable Energy', 3),
('EPM118', 'Electrical and Electronic Circuits', 3),
('EPM151', 'Industrial Electronics', 3),
('EPM211', 'Properties of Electrical Materials', 2),
('EPM212', 'Electrical Circuits (2)', 3),
('EPM213', 'Energy and Renewable Energy', 3),
('EPM214', 'Electrical Systems Simulation', 3),
('EPM221', 'Electrical Machines (1)', 3),
('EPM222', 'Electrical Machines (2)', 3),
('EPM231', 'Electrical Power Engineering', 3),
('EPM232', 'Automatic Control Systems', 3),
('EPM251', 'Power Electronics for Energy Applications (1)', 3),
('EPM311', 'Fundamentals of Photovoltaic', 3),
('EPM321', 'Transformer and DC Machines', 3),
('EPM322', 'Alternating Current Machines', 3),
('EPM331', 'Electrical Transmission Systems', 3),
('EPM332', 'Power System Analysis (1)', 3),
('EPM333', 'Electrical Distribution Systems', 3),
('EPM334', 'Economics of Generation, Transmission & Operation', 3),
('EPM335', 'Fundamentals of Power System Analysis', 3),
('EPM336', 'Electrical Distribution Systems Installations', 3),
('EPM341', 'High Voltage Engineering', 3),
('EPM342', 'Switchgear Engineering and substations', 3),
('EPM351', 'Power Electronics (1)', 3),
('EPM352', 'Power Electronics (2)', 3),
('EPM353', 'Power Electronics and Motor Drives', 3),
('EPM354', 'Power Electronics for Energy Applications (2)', 3),
('EPM411', 'Project Management for Electrical Engineering', 2),
('EPM413', 'Energy Management Essentials', 3),
('EPM417', 'Microprocessor-Based Automated Systems', 3),
('EPM421', 'Special Machines', 2),
('EPM422', 'Industrial Automation Systems', 3),
('EPM423', 'Power Generating Stations', 2),
('EPM431', 'Operation and Control of Power Systems', 3),
('EPM432', 'Electrical Installation and Energy Utilization', 3),
('EPM433', 'Power Systems Stability', 2),
('EPM434', 'Planning of Electrical Networks', 3),
('EPM435', 'Advanced Control on Power Systems', 3),
('EPM436', 'Computer Application in Electrical Power Systems', 3),
('EPM451', 'Electrical Drives Systems', 3),
('EPM452', 'Advanced Applications in Power Electronics', 2),
('EPM453', 'Power Quality', 2),
('EPM454', 'Renewable Energy Resources Interfacing', 3),
('EPM456', 'Power Quality for Energy Applications', 3),
('EPM457', 'Electric Drives', 3),
('EPM461', 'Protection Engineering', 3),
('EPM462', 'Advanced Protection in Power Systems', 2),
('EPM463', 'Power System Protection', 4),
('EPM491', 'Electrical Power & Machines Graduation Project (1)', 3),
('EPM492', 'Electrical Power & Machines Graduation Project (2)', 3),
('EPM493', 'Energy Graduation Project (1)', 3),
('EPM494', 'Energy Graduation Project (2)', 3),

-- --- Department: Automotive Engineering (MEA) ---
('MEA211', 'Aerodynamics of Road Vehicles', 2),
('MEA221', 'Vehicle Design & Simulation (1)', 3),
('MEA241', 'Automotive Engines', 3),
('MEA261', 'Introduction to Automotive', 2),
('MEA311', 'Automotive Engineering', 3),
('MEA312', 'Road Vehicle Dynamics', 3),
('MEA313', 'Automotive Theory', 3),
('MEA321', 'Vehicle Design & Simulation (2)', 3),
('MEA322', 'Automotive Design', 2),
('MEA331', 'Automotive Maintenance Engineering', 3),
('MEA341', 'Automotive Fuel Systems', 3),
('MEA342', 'Design and Simulation of Automotive Engines', 3),
('MEA351', 'Automotive Mechatronic Systems', 3),
('MEA411', 'Earth Moving Equipment & Commercial Vehicle Technology', 3),
('MEA412', 'Race Car Technology', 3),
('MEA413', 'Motorcycle and Tricycle Technology', 3),
('MEA431', 'Automotive After Sales Services', 2),
('MEA432', 'Workshop Planning & Vehicle Repair Technologies', 3),
('MEA441', 'Engine Management Systems', 3),
('MEA442', 'Alternative Fuels and Emissions Control Systems', 3),
('MEA443', 'Powertrain Characterization & Measurement Systems', 3),
('MEA451', 'Vehicle Safety Systems and accident analysis', 2),
('MEA452', 'Automotive Control Systems', 3),
('MEA461', 'Vehicle Manufacturing and Assembly', 3),
('MEA491', 'Automotive Graduation Project (1)', 3),
('MEA492', 'Automotive Graduation Project (2)', 3),

-- --- Department: Mechatronics Engineering (MCT) ---
('MCT131', 'Introduction to Mechatronics', 3),
('MCT211', 'Automatic Control', 3),
('MCT231', 'Engineering Measurements', 3),
('MCT232', 'Industrial Electronics', 3),
('MCT233', 'Dynamic Modeling and Simulation', 3),
('MCT234', 'Modeling and Simulation of Mechatronics systems', 2),
('MCT311', 'Hydraulics and Pneumatics Control', 3),
('MCT312', 'Industrial Automation', 2),
('MCT313', 'Automation', 3),
('MCT331', 'Design of Mechatronic Systems (1)', 3),
('MCT332', 'Design of Mechatronic Systems (2)', 3),
('MCT333', 'Mechatronic Systems Design', 3),
('MCT334', 'Sensors and Measurement Systems', 3),
('MCT341', 'Introduction to Autotronics', 2),
('MCT342', 'Introduction to Nano-Mechatronics', 2),
('MCT343', 'Introduction to Bio-Mechatronics', 2),
('MCT344', 'Industrial Robotics', 3),
('MCT345', 'Industrial Mechanisms and Robotics', 3),
('MCT346', 'System Physiology', 2),
('MCT347', 'Locomotion and Gait Analysis', 3),
('MCT348', 'Introduction to Biomechanics', 3),
('MCT349', 'Material Properties and Characterization', 3),
('MCT350', 'MEMS/NEMS Characterization: Systems & Methods', 3),
('MCT411', 'Hybrid Control Systems', 3),
('MCT412', 'Motion Control', 3),
('MCT413', 'Modelling and Control of Electro-Hydraulic Systems', 2),
('MCT414', 'Automation & Communication Systems for Manufac.', 3),
('MCT421', 'Embedded systems for Automotive', 3),
('MCT422', 'Automotive Embedded Networking', 3),
('MCT431', 'Industrial Communications and Networks Systems', 3),
('MCT432', 'MEMS Devices', 3),
('MCT433', 'MEMS Design', 2),
('MCT434', 'Engineering Optimization', 2),
('MCT441', 'Rehabilitation Robots', 3),
('MCT442', 'Biomedical Engineering', 3),
('MCT443', 'Design of Autonomous Systems', 3),
('MCT444', 'Mechatronics in Rehabilitation Technology', 2),
('MCT445', 'Mechatronics in Automotive Application', 2),
('MCT446', 'Autotronics', 3),
('MCT447', 'MEMS Systems', 3),
('MCT448', 'MEMS/NEMS Fabrication and Packaging', 2),
('MCT449', 'Selected topics in Industrial Mechatronics', 2),
('MCT491', 'Mechatronics Graduation Project (1)', 3),
('MCT492', 'Mechatronics Graduation Project (2)', 3),

-- --- Department: Design and Production Engineering (MDP) ---
('MDP011', 'Engineering Drawing', 3),
('MDP081', 'Production Engineering', 3),
('MDP111', 'Mechanical Engineering Drawing', 3),
('MDP112', 'Machine Construction', 3),
('MDP151', 'Structures and Properties of Materials', 2),
('MDP152', 'Metallurgy and Material Testing', 3),
('MDP153', 'Crystalline Structures of Materials', 3),
('MDP181', 'Manufacturing Technology (1)', 3),
('MDP182', 'Metal Forming Theory & Processes', 3),
('MDP183', 'Manufacturing Technologies', 4),
('MDP211', 'Machine Elements Design', 4),
('MDP212', 'Mechanics of Machines', 4),
('MDP231', 'Engineering Economy', 2),
('MDP232', 'Industrial Project Management', 2),
('MDP233', 'Work Study & Plant layout', 4),
('MDP251', 'Casting and Welding (1)', 3),
('MDP254', 'Thermodynamics of Materials', 3),
('MDP255', 'Materials Testing and Behavior', 3),
('MDP256', 'Phase Transformation and Heat Treatment', 3),
('MDP257', 'Materials for Advanced Manufacturing Technology', 2),
('MDP281', 'Metal Cutting Theory and Technologies', 4),
('MDP282', 'Non-Conventional Processing', 2),
('MDP311', 'Mechanical Vibrations', 4),
('MDP312', 'Mechanical System Design', 3),
('MDP331', 'Maintenance Planning and Scheduling', 2),
('MDP332', 'Work Study', 3),
('MDP333', 'Operations Research', 3),
('MDP334', 'Principles of Operation Management', 3),
('MDP335', 'Production Planning and Scheduling', 3),
('MDP336', 'Facilities Layout and Design', 3),
('MDP351', 'Industrial Furnaces and Heat Treatment', 2),
('MDP353', 'Polymer Materials', 3),
('MDP354', 'Industrial Project', 3),
('MDP355', 'Modern Ferrous and Non-Ferrous Making', 2),
('MDP356', 'Glass, Ceramics, and Binding Materials', 3),
('MDP381', 'Theory of Metal Forming', 3),
('MDP382', 'Theory of Metal Cutting', 3),
('MDP383', 'Metal Forming Technology, Machines and Dies', 3),
('MDP384', 'Metal Cutting Machines and Technology', 3),
('MDP385', 'Manufacturing Processes', 2),
('MDP386', 'Computer Aided Manufacturing', 3),
('MDP387', 'Metrology', 3),
('MDP401', 'Mechanical Design & Production Graduation Project (1)', 3),
('MDP402', 'Mechanical Design & Production Graduation Project (2)', 3),
('MDP431', 'Operations Management', 3),
('MDP432', 'Facilities Planning', 3),
('MDP433', 'Quality Control', 3),
('MDP434', 'Quality Systems and Assurance', 3),
('MDP435', 'Industrial Systems Modelling and Simulation', 3),
('MDP436', 'Production Planning & Control', 3),
('MDP437', 'Ergonomics', 3),
('MDP438', 'Simulation of Manufacturing Systems', 3),
('MDP439', 'Lean Manufacturing Systems', 3),
('MDP440', 'Quality Assurance and Six Sigma', 3),
('MDP451', 'Failure Analysis', 3),
('MDP452', 'Material and Process Selection', 2),
('MDP453', 'Composites Technology', 3),
('MDP454', 'Corrosion', 3),
('MDP455', 'Renewable Materials', 3),
('MDP456', 'Petrochemicals and Polymer Products', 2),
('MDP457', 'Extractive Metallurgy', 3),
('MDP459', 'Corrosion Control and Cathodic Protection', 3),
('MDP460', 'Non-destructive Testing of Materials (1)', 3),
('MDP461', 'Non-destructive Testing of Materials (2)', 3),
('MDP462', 'Polymer Processing Techniques', 2),
('MDP463', 'Materials for Energy Solution', 3),
('MDP464', 'Surfactants and lubricating Materials', 3),
('MDP465', 'Rubber and Sealing Materials', 3),
('MDP467', 'Polymer Testing', 3),
('MDP468', 'Materials Characterization', 3),
('MDP469', 'Glasses Materials and Technology', 3),
('MDP470', 'Ceramic Materials and Technology', 3),
('MDP471', 'Binding Materials and Technology', 3),
('MDP472', 'Biomedical Materials', 3),
('MDP473', 'Introduction to Nano technology', 3),
('MDP481', 'Design of Tools & Production Facilities', 3),
('MDP482', 'Metrology & Measuring Instruments', 4),
('MDP483', 'Computerized Numerical Controlled Machines', 2),
('MDP484', 'Product Life Cycle Management', 3),
('MDP485', 'Advanced Topics in CNC Machine Tools', 3),
('MDP486', 'Selected Topics in Manufacturing', 3),
('MDP487', 'Computer Integrated Manufacturing', 3),
('MDP488', 'Advanced Manufacturing Technology', 3),
('MDP489', 'Selected Topics in Forming', 3),
('MDP490', 'Die Design', 3),
('MDP491', 'Design of Jigs and Fixtures', 3),
('MDP492', 'Advanced Manufacturing Systems', 3),
('MDP493', 'Additive Manufacturing', 3),
('MDP494', 'Advanced Manufacturing Technology & Prototyping', 3),

-- --- Department: Mechanical Power Engineering (MEP) ---
('MEP111', 'Thermal Physics', 2),
('MEP211', 'Thermodynamics', 4),
('MEP212', 'Heat Transfer', 4),
('MEP214', 'Thermal Power Engineering', 3),
('MEP221', 'Fluid Mechanics and Turbo-Machinery', 4),
('MEP222', 'Introduction to Fluid Mechanics', 3),
('MEP231', 'Measurement and Instrumentation', 2),
('MEP241', 'Technical Installations', 3),
('MEP311', 'Combustion', 3),
('MEP312', 'Fundamentals of Internal Combustion Engines', 3),
('MEP313', 'Thermal Power Plants', 3),
('MEP331', 'Digital Control', 2),
('MEP332', 'Process Control', 3),
('MEP341', 'Refrigeration and Air Conditioning', 3),
('MEP346', 'Refrigerators and AC Systems and Equipment', 3),
('MEP411', 'Control Systems of Internal Combustion Engines', 3),
('MEP412', 'Heat Engines', 3),
('MEP413', 'Gas Fueled Engines', 3),
('MEP414', 'Biomass and waste Conversion Technology', 3),
('MEP421', 'Sustainable Energy', 3),
('MEP422', 'Energy Storage Technology', 3),
('MEP423', 'Hydro-Tidal and Wave Energy', 3),
('MEP425', 'Aircraft Propulsion', 3),
('MEP426', 'Solar Energy', 3),
('MEP427', 'Wind Energy', 3),
('MEP428', 'Hydraulic Transmission', 3),
('MEP431', 'Fire Fighting', 3),
('MEP432', 'Computational Fluid Dynamics', 3),
('MEP433', 'Management of Mechanical Power Projects', 3),
('MEP434', 'Water Desalination and Distillation', 3),
('MEP435', 'Design of Mechanical Power Units', 3),
('MEP441', 'Applied Building Services Technology', 3),
('MEP442', 'Thermodynamics of Materials', 3),
('MEP443', 'Petroleum Pipelines', 3),
('MEP444', 'Economics of Energy Conversion', 3),
('MEP445', 'Environmental Impact of Mechanical Power Projects', 3),
('MEP451', 'Nuclear Energy', 3),
('MEP452', 'Thermal Aspects of Nuclear Reactors', 3),
('MEP453', 'Nuclear Reactions and Interaction with Matter', 3),
('MEP454', 'Radioactive Waste Management', 3),
('MEP455', 'Methods of Nuclear Risk Analysis', 3),
('MEP491', 'Mechanical Power Graduation Project (1)', 3),
('MEP492', 'Mechanical Power Graduation Project (2)', 3),

-- --- Department: Engineering Physics and Mathematics (PHM) ---
('PHM011', 'Basic Mathematics', 0),
('PHM012', 'Mathematics (1)', 3),
('PHM013', 'Mathematics (2)', 3),
('PHM021', 'Vibration and Waves', 3),
('PHM022', 'Electricity and Magnetism', 3),
('PHM031', 'Statics', 3),
('PHM032', 'Dynamics', 3),
('PHM041', 'Engineering Chemistry', 3),
('PHM111', 'Probability and Statistics', 2),
('PHM112', 'Differential Equations and Numerical Analysis', 4),
('PHM113', 'Differential and Partial Differential Equations', 3),
('PHM114', 'Numerical Analysis', 3),
('PHM115', 'Engineering Mathematics', 3),
('PHM121', 'Modern Physics and Quantum Mechanics', 3),
('PHM122', 'Physics of Semiconductors and Dielectrics', 3),
('PHM131', 'Rigid body dynamics', 2),
('PHM141', 'Introduction to Organic Chemistry', 2),
('PHM142', 'Reaction Kinetics and Chemical Analysis', 3),
('PHM211', 'Discrete Mathematics', 2),
('PHM212', 'Complex, Special Functions and Numerical Analysis', 3),
('PHM213', 'Complex, Special Functions and Fourier Analysis', 3),
('PHM241', 'Electrochemistry', 3),
('PHM242', 'Polymer Chemistry', 3),

-- --- Department: Urban Design and Planning (UPL) ---
('UPL161', 'Environmental Studies and passive energy systems', 2),
('UPL211', 'Context and Place Design Studio', 8),
('UPL212', 'Principles of Urban Design and Landscape', 4),
('UPL213', 'Mixed-use design studio', 4),
('UPL221', 'History and Theory of Urbanism', 3),
('UPL241', 'Principles of Residential Urban Spaces and Landscape', 3),
('UPL251', 'Residential Complex Design Studio', 4),
('UPL271', 'Society and Housing Economics', 2),
('UPL311', 'Urban and Landscape Design Studio', 8),
('UPL313', 'Eco Urban Design', 3),
('UPL321', 'Participatory Planning and Community', 2),
('UPL331', 'Planning and Urban Upgrading', 3),
('UPL333', 'Urban Infrastructure', 3),
('UPL334', 'Site Analysis (Spatial Analysis and Land Mapping)', 2),
('UPL341', 'Horticulture and Garden Design', 2),
('UPL342', 'Arid Landscape Architecture Design Studio', 4),
('UPL343', 'Landscape Working Design (1): Landscape Detailed Working Documents', 3),
('UPL344', 'Landscape for Dwellings and Public Buildings', 2),
('UPL351', 'Housing Studies', 3),
('UPL352', 'Neighborhood Planning and Design Studio', 4),
('UPL353', 'Housing Policies and Programs', 2),
('UPL361', 'Outdoor Noise Propagation in Built Environment', 2),
('UPL371', 'Human Behavior and the Built Environment', 2),
('UPL372', 'Equity and urban Justice', 2),
('UPL381', 'Introduction to Geographic Information Systems', 2),
('UPL411', 'Mega Projects Urban Design Studio', 4),
('UPL421', 'Town and Regional Planning', 2),
('UPL422', 'Smart Cities and Intelligent Residential Buildings', 3),
('UPL423', 'City Governance & Land Management', 3),
('UPL431', 'Strategic Action Planning Studio', 4),
('UPL432', 'Urban Engineering', 3),
('UPL433', 'Land Management and Land Subdivision', 3),
('UPL434', 'Sustainable Urban Mobility', 2),
('UPL435', 'Urban and Architectural Heritage', 3),
('UPL436', 'Urban Renewal', 3),
('UPL441', 'Landscape Working Design (2): Landscape Execution Documents Complexity', 3),
('UPL442', 'Ecological Landscape', 3),
('UPL451', 'Housing Studies & Real Estate Development', 3),
('UPL461', 'Contemporary Environmental Issues', 3),
('UPL462', 'Urban Ecology and Environmental Studies', 2),
('UPL463', 'Environmental Impact Assessment', 3),
('UPL464', 'Environmental Planning', 3),
('UPL472', 'Urban Economics', 2),
('UPL481', 'Urban Informatics', 3),
('UPL482', 'Introduction to Geo Design', 3),
('UPL491', 'Urban Design Graduation Project (1)', 2),
('UPL492', 'Urban Design Graduation Project (2)', 6),
('UPL493', 'Urban Planning Graduation Project (1)', 2),
('UPL494', 'Urban Planning Graduation Project (2)', 6),
('UPL495', 'Landscape Architecture Graduation Project (1)', 2),
('UPL496', 'Landscape Architecture Graduation Project (2)', 6),
('UPL497', 'Housing & Urban Development Graduation Proj. (1)', 2),
('UPL498', 'Housing & Urban Development Graduation Proj. (2)', 6);

-- -----------------------------------------------------------------
-- --- Section 5: Academic History - Semesters, Enrollments, Grades
-- -----------------------------------------------------------------

-- Insert Past Semesters
INSERT INTO Semester (semester_id, name, start_date, end_date, registration_open) VALUES
(1, 'Fall 2022', '2022-09-01', '2022-12-31', 0),
(2, 'Spring 2023', '2023-02-01', '2023-05-31', 0),
(3, 'Fall 2023', '2023-09-01', '2023-12-31', 0),
(4, 'Spring 2024', '2024-02-01', '2024-05-31', 0),
(5, 'Fall 2024', '2024-09-01', '2024-12-31', 1);  -- Current semester

-- Insert Offered Courses for Fall 2022 (Some engineering courses)
INSERT INTO OfferedCourse (offered_course_id, course_id, semester_id) VALUES
(1, 1, 1),   -- ASU111 - Human Rights, Fall 2022
(2, 2, 1),   -- ASU112 - Report Writing, Fall 2022
(3, 14, 1),  -- ENG111 - Fundamentals of Engineering, Fall 2022
(4, 20, 1),  -- CSE111 - Logic Design, Fall 2022
(5, 21, 1),  -- CSE131 - Computer Programming, Fall 2022
(6, 30, 1),  -- CES111 - Structural Mechanics, Fall 2022
(7, 80, 1);  -- EPM111 - Electrical Circuits, Fall 2022

-- Insert Offered Courses for Spring 2023
INSERT INTO OfferedCourse (offered_course_id, course_id, semester_id) VALUES
(8, 3, 2),   -- ASU113 - Professional Ethics, Spring 2023
(9, 22, 2),  -- CSE211 - Intro to Embedded Systems, Spring 2023
(10, 31, 2), -- CES112 - Structural Mechanics (2), Spring 2023
(11, 81, 2), -- EPM112 - Electromagnetic Fields, Spring 2023
(12, 90, 2); -- MEP211 - Thermodynamics, Spring 2023

-- Insert Offered Courses for Fall 2023
INSERT INTO OfferedCourse (offered_course_id, course_id, semester_id) VALUES
(13, 23, 3), -- CSE231 - Advanced Programming, Fall 2023
(14, 32, 3), -- CES211 - Structural Analysis (1), Fall 2023
(15, 82, 3), -- EPM211 - Properties of Materials, Fall 2023
(16, 91, 3), -- MEP212 - Heat Transfer, Fall 2023
(17, 50, 3); -- ARC111 - Principles of Architecture, Fall 2023

-- Insert Offered Courses for Spring 2024
INSERT INTO OfferedCourse (offered_course_id, course_id, semester_id) VALUES
(18, 33, 4), -- CSE331 - Data Structures, Spring 2024
(19, 34, 4), -- CSE333 - Database Systems, Spring 2024
(20, 83, 4), -- EPM221 - Electrical Machines (1), Spring 2024
(21, 51, 4), -- ARC112 - Creativity and Design, Spring 2024
(22, 92, 4); -- MEP221 - Fluid Mechanics, Spring 2024

-- Insert Sections for each Offered Course
INSERT INTO Section (section_id, offered_course_id, ta_instructor_id, section_number, capacity, current_enrollment) VALUES
-- Fall 2022 Sections
(1, 1, 201, 'A', 40, 35),   -- ASU111 Section A
(2, 2, 202, 'A', 40, 38),   -- ASU112 Section A
(3, 3, 203, 'A', 40, 40),   -- ENG111 Section A
(4, 4, 204, 'A', 35, 30),   -- CSE111 Section A
(5, 5, 205, 'A', 35, 32),   -- CSE131 Section A
(6, 6, 206, 'A', 40, 25),   -- CES111 Section A
(7, 7, 207, 'A', 40, 28),   -- EPM111 Section A
-- Spring 2023 Sections
(8, 8, 201, 'A', 40, 35),   -- ASU113 Section A
(9, 9, 203, 'A', 35, 28),   -- CSE211 Section A
(10, 10, 206, 'A', 40, 30), -- CES112 Section A
(11, 11, 207, 'A', 40, 32), -- EPM112 Section A
(12, 12, 208, 'A', 40, 26), -- MEP211 Section A
-- Fall 2023 Sections
(13, 13, 204, 'A', 35, 30), -- CSE231 Section A
(14, 14, 206, 'A', 40, 28), -- CES211 Section A
(15, 15, 207, 'A', 40, 32), -- EPM211 Section A
(16, 16, 208, 'A', 40, 30), -- MEP212 Section A
(17, 17, 209, 'A', 35, 25), -- ARC111 Section A
-- Spring 2024 Sections
(18, 18, 205, 'A', 35, 32), -- CSE331 Section A
(19, 19, 204, 'A', 35, 30), -- CSE333 Section A
(20, 20, 207, 'A', 40, 28), -- EPM221 Section A
(21, 21, 209, 'A', 35, 27), -- ARC112 Section A
(22, 22, 208, 'A', 40, 26); -- MEP221 Section A

-- Link Instructors to OfferedCourses
INSERT INTO OfferedCourse_Instructor (offered_course_id, instructor_id) VALUES
(1, 101), (2, 102), (3, 103), (4, 104), (5, 105), (6, 106), (7, 107),  -- Fall 2022
(8, 101), (9, 104), (10, 106), (11, 107), (12, 108),                     -- Spring 2023
(13, 104), (14, 106), (15, 107), (16, 108), (17, 102),                   -- Fall 2023
(18, 104), (19, 104), (20, 107), (21, 102), (22, 108);                    -- Spring 2024

-- Insert Enrollments for Students - Fall 2022
INSERT INTO Enrollment (enrollment_id, student_id, section_id, status) VALUES
(1, 301, 1, 'approved'), (2, 301, 2, 'approved'), (3, 301, 3, 'approved'), (4, 301, 4, 'approved'), (5, 301, 5, 'approved'),
(6, 302, 1, 'approved'), (7, 302, 2, 'approved'), (8, 302, 6, 'approved'), (9, 302, 7, 'approved'),
(10, 303, 1, 'approved'), (11, 303, 3, 'approved'), (12, 303, 7, 'approved'),
(13, 304, 2, 'approved'), (14, 304, 4, 'approved'), (15, 304, 5, 'approved'),
(16, 305, 1, 'approved'), (17, 305, 3, 'approved'), (18, 305, 4, 'approved'), (19, 305, 5, 'approved'),
(20, 306, 1, 'approved'), (21, 306, 2, 'approved'), (22, 306, 6, 'approved'),
(23, 307, 2, 'approved'), (24, 307, 3, 'approved'), (25, 307, 7, 'approved'), (26, 307, 1, 'approved'),
(27, 308, 1, 'approved'), (28, 308, 3, 'approved'), (29, 308, 4, 'approved'),
(30, 309, 1, 'approved'), (31, 309, 2, 'approved'), (32, 309, 5, 'approved'),
(33, 310, 1, 'approved'), (34, 310, 2, 'approved'), (35, 310, 6, 'approved');

-- Insert Enrollments for Students - Spring 2023
INSERT INTO Enrollment (enrollment_id, student_id, section_id, status) VALUES
(36, 301, 8, 'approved'), (37, 301, 9, 'approved'), (38, 301, 10, 'approved'), (39, 301, 11, 'approved'),
(40, 302, 8, 'approved'), (41, 302, 9, 'approved'), (42, 302, 11, 'approved'),
(43, 303, 8, 'approved'), (44, 303, 12, 'approved'),
(45, 304, 8, 'approved'), (46, 304, 9, 'approved'), (47, 304, 10, 'approved'),
(48, 305, 8, 'approved'), (49, 305, 9, 'approved'), (50, 305, 10, 'approved'),
(51, 306, 8, 'approved'), (52, 306, 11, 'approved'), (53, 306, 12, 'approved'),
(54, 307, 8, 'approved'), (55, 307, 10, 'approved'), (56, 307, 12, 'approved'),
(57, 308, 8, 'approved'), (58, 308, 9, 'approved'), (59, 308, 11, 'approved'),
(60, 309, 8, 'approved'), (61, 309, 10, 'approved'),
(62, 310, 8, 'approved'), (63, 310, 11, 'approved'), (64, 310, 12, 'approved');

-- Insert Enrollments for Students - Fall 2023
INSERT INTO Enrollment (enrollment_id, student_id, section_id, status) VALUES
(65, 301, 13, 'approved'), (66, 301, 14, 'approved'), (67, 301, 15, 'approved'),
(68, 302, 13, 'approved'), (69, 302, 16, 'approved'), (70, 302, 17, 'approved'),
(71, 303, 15, 'approved'), (72, 303, 16, 'approved'),
(73, 304, 13, 'approved'), (74, 304, 14, 'approved'), (75, 304, 15, 'approved'),
(76, 305, 13, 'approved'), (77, 305, 14, 'approved'), (78, 305, 15, 'approved'),
(79, 306, 15, 'approved'), (80, 306, 16, 'approved'), (81, 306, 17, 'approved'),
(82, 307, 14, 'approved'), (83, 307, 15, 'approved'), (84, 307, 16, 'approved'),
(85, 308, 13, 'approved'), (86, 308, 14, 'approved'),
(87, 309, 13, 'approved'), (88, 309, 15, 'approved'), (89, 309, 16, 'approved'),
(90, 310, 14, 'approved'), (91, 310, 17, 'approved');

-- Insert Enrollments for Students - Spring 2024
INSERT INTO Enrollment (enrollment_id, student_id, section_id, status) VALUES
(92, 301, 18, 'approved'), (93, 301, 19, 'approved'), (94, 301, 20, 'approved'),
(95, 302, 19, 'approved'), (96, 302, 21, 'approved'), (97, 302, 22, 'approved'),
(98, 303, 20, 'approved'), (99, 303, 22, 'approved'),
(100, 304, 18, 'approved'), (101, 304, 19, 'approved'), (102, 304, 20, 'approved'),
(103, 305, 18, 'approved'), (104, 305, 19, 'approved'), (105, 305, 20, 'approved'),
(106, 306, 20, 'approved'), (107, 306, 21, 'approved'), (108, 306, 22, 'approved'),
(109, 307, 18, 'approved'), (110, 307, 20, 'approved'), (111, 307, 22, 'approved'),
(112, 308, 18, 'approved'), (113, 308, 19, 'approved'),
(114, 309, 19, 'approved'), (115, 309, 20, 'approved'), (116, 309, 21, 'approved'),
(117, 310, 18, 'approved'), (118, 310, 21, 'approved');

-- Insert Grades for Fall 2022 Enrollments
INSERT INTO Grade (enrollment_id, midterm, project, assignments_total, quizzes_total, attendance, final_exam_mark, final_letter_grade) VALUES
-- Student 301 - Fall 2022
(1, 17.5, 18.0, 9.0, 4.5, 5.0, 85.0, 'A+'),
(2, 16.0, 17.0, 8.5, 4.0, 5.0, 78.0, 'A'),
(3, 18.0, 16.0, 9.0, 4.5, 5.0, 82.0, 'A'),
(4, 15.0, 15.5, 8.0, 3.5, 4.5, 75.0, 'B+'),
(5, 16.5, 17.5, 9.0, 4.0, 5.0, 80.0, 'A'),
-- Student 302 - Fall 2022
(6, 18.0, 18.5, 9.5, 5.0, 5.0, 88.0, 'A+'),
(7, 17.0, 17.5, 9.0, 4.5, 5.0, 82.0, 'A'),
(8, 19.0, 19.0, 10.0, 5.0, 5.0, 92.0, 'A+'),
(9, 16.5, 16.0, 8.5, 4.0, 4.5, 76.0, 'A-'),
-- Student 303 - Fall 2022
(10, 14.0, 15.0, 7.5, 3.0, 4.0, 68.0, 'B'),
(11, 16.0, 14.5, 8.0, 3.5, 4.5, 72.0, 'B+'),
(12, 13.5, 13.0, 7.0, 2.5, 3.5, 65.0, 'C+'),
-- Student 304 - Fall 2022
(13, 19.5, 19.0, 10.0, 5.0, 5.0, 95.0, 'A+'),
(14, 18.0, 18.5, 9.5, 4.5, 5.0, 88.0, 'A+'),
(15, 17.5, 17.0, 9.0, 4.5, 5.0, 84.0, 'A'),
-- Student 305 - Fall 2022
(16, 12.0, 14.0, 7.0, 3.0, 3.5, 62.0, 'C'),
(17, 13.0, 12.5, 7.5, 3.5, 4.0, 66.0, 'C+'),
(18, 14.5, 13.5, 8.0, 3.5, 4.0, 69.0, 'B-'),
(19, 15.0, 14.5, 8.5, 4.0, 4.5, 73.0, 'B+'),
-- Student 306 - Fall 2022
(20, 17.5, 17.0, 9.0, 4.5, 5.0, 85.0, 'A'),
(21, 16.5, 16.5, 8.5, 4.0, 5.0, 80.0, 'A'),
(22, 15.5, 15.0, 8.0, 3.5, 4.5, 75.0, 'B+'),
-- Student 307 - Fall 2022
(23, 14.0, 14.5, 7.5, 3.5, 4.0, 71.0, 'B'),
(24, 15.0, 15.0, 8.0, 3.5, 4.5, 76.0, 'A-'),
(25, 16.5, 16.0, 8.5, 4.0, 4.5, 81.0, 'A'),
(26, 13.0, 13.5, 7.0, 3.0, 3.5, 66.0, 'C+'),
-- Student 308 - Fall 2022
(27, 18.5, 18.0, 9.5, 4.5, 5.0, 92.0, 'A+'),
(28, 17.0, 17.5, 9.0, 4.5, 5.0, 86.0, 'A'),
(29, 16.5, 16.5, 8.5, 4.0, 5.0, 83.0, 'A'),
-- Student 309 - Fall 2022
(30, 12.5, 13.5, 7.0, 2.5, 3.5, 60.0, 'C'),
(31, 13.5, 14.0, 7.5, 3.0, 4.0, 69.0, 'B-'),
(32, 14.0, 15.5, 8.0, 3.5, 4.5, 76.0, 'A-'),
-- Student 310 - Fall 2022
(33, 19.0, 18.5, 9.5, 4.5, 5.0, 94.0, 'A+'),
(34, 18.5, 18.0, 9.0, 4.5, 5.0, 90.0, 'A+'),
(35, 17.5, 17.0, 8.5, 4.0, 5.0, 86.0, 'A');

-- Insert Grades for Spring 2023 Enrollments
INSERT INTO Grade (enrollment_id, midterm, project, assignments_total, quizzes_total, attendance, final_exam_mark, final_letter_grade) VALUES
(36, 18.0, 18.5, 9.5, 4.5, 5.0, 90.0, 'A+'),
(37, 16.5, 17.0, 9.0, 4.0, 5.0, 82.0, 'A'),
(38, 17.5, 16.0, 8.5, 4.5, 5.0, 79.0, 'A-'),
(39, 15.5, 16.5, 8.0, 3.5, 4.5, 76.0, 'A-'),
(40, 19.0, 18.0, 9.5, 5.0, 5.0, 92.0, 'A+'),
(41, 17.0, 17.5, 9.0, 4.5, 5.0, 85.0, 'A'),
(42, 14.5, 15.0, 7.5, 3.5, 4.0, 70.0, 'B'),
(43, 13.0, 14.5, 7.0, 3.0, 3.5, 65.0, 'C+'),
(44, 15.0, 13.5, 8.0, 3.5, 4.5, 72.0, 'B+'),
(45, 20.0, 19.5, 10.0, 5.0, 5.0, 98.0, 'A+'),
(46, 18.5, 18.0, 9.5, 4.5, 5.0, 90.0, 'A+'),
(47, 19.0, 19.0, 10.0, 5.0, 5.0, 93.0, 'A+'),
(48, 12.5, 13.0, 7.0, 2.5, 3.5, 60.0, 'C'),
(49, 14.0, 14.5, 8.0, 3.5, 4.0, 68.0, 'B'),
(50, 15.0, 15.5, 8.5, 4.0, 4.5, 74.0, 'B+'),
(51, 17.5, 16.5, 8.5, 4.0, 4.5, 78.0, 'A'),
(52, 16.0, 15.5, 8.0, 3.5, 4.0, 75.0, 'B+'),
(53, 18.0, 17.0, 9.0, 4.5, 5.0, 84.0, 'A'),
(54, 14.5, 15.5, 7.5, 3.5, 4.0, 71.0, 'B'),
(55, 13.5, 14.0, 7.0, 3.0, 3.5, 66.0, 'C+'),
(56, 15.5, 14.5, 8.0, 3.5, 4.5, 73.0, 'B+'),
(57, 19.5, 18.5, 9.5, 5.0, 5.0, 94.0, 'A+'),
(58, 17.0, 17.5, 9.0, 4.5, 5.0, 86.0, 'A'),
(59, 16.5, 16.0, 8.5, 4.0, 4.5, 80.0, 'A'),
(60, 11.5, 12.0, 6.5, 2.5, 3.0, 57.0, 'C-'),
(61, 13.0, 13.5, 7.5, 3.5, 4.0, 69.0, 'B-'),
(62, 16.5, 15.5, 8.0, 3.5, 4.0, 76.0, 'A-'),
(63, 15.0, 16.0, 8.5, 4.0, 4.5, 78.0, 'A'),
(64, 18.5, 17.5, 9.0, 4.5, 5.0, 89.0, 'A+');

-- Insert Grades for Fall 2023 Enrollments
INSERT INTO Grade (enrollment_id, midterm, project, assignments_total, quizzes_total, attendance, final_exam_mark, final_letter_grade) VALUES
(65, 18.5, 19.0, 9.5, 4.5, 5.0, 92.0, 'A+'),
(66, 17.0, 16.5, 9.0, 4.0, 5.0, 83.0, 'A'),
(67, 16.5, 17.5, 8.5, 4.5, 5.0, 81.0, 'A'),
(68, 20.0, 19.5, 10.0, 5.0, 5.0, 97.0, 'A+'),
(69, 18.0, 18.5, 9.5, 4.5, 5.0, 89.0, 'A+'),
(70, 19.5, 19.0, 10.0, 5.0, 5.0, 94.0, 'A+'),
(71, 14.0, 15.5, 7.5, 3.5, 4.5, 73.0, 'B+'),
(72, 13.5, 14.0, 7.0, 3.0, 3.5, 67.0, 'C+'),
(73, 19.0, 18.5, 9.5, 4.5, 5.0, 91.0, 'A+'),
(74, 18.5, 18.0, 9.0, 4.5, 5.0, 88.0, 'A+'),
(75, 17.5, 17.0, 9.0, 4.0, 5.0, 85.0, 'A'),
(76, 12.0, 13.5, 7.0, 2.5, 3.5, 61.0, 'C'),
(77, 13.5, 14.5, 8.0, 3.5, 4.0, 70.0, 'B'),
(78, 14.0, 15.0, 8.5, 4.0, 4.5, 73.0, 'B+'),
(79, 17.0, 16.5, 8.5, 4.0, 4.5, 80.0, 'A'),
(80, 15.5, 16.0, 8.0, 3.5, 4.0, 77.0, 'A-'),
(81, 18.5, 17.5, 9.0, 4.5, 5.0, 87.0, 'A'),
(82, 15.0, 16.5, 8.5, 4.0, 4.5, 79.0, 'A-'),
(83, 14.5, 15.5, 8.0, 3.5, 4.0, 75.0, 'B+'),
(84, 16.0, 15.0, 8.5, 4.0, 4.5, 78.0, 'A'),
(85, 19.0, 18.0, 9.5, 4.5, 5.0, 90.0, 'A+'),
(86, 17.5, 17.0, 9.0, 4.5, 5.0, 85.0, 'A'),
(87, 11.0, 12.5, 6.5, 2.5, 3.0, 58.0, 'C-'),
(88, 12.5, 13.0, 7.0, 3.0, 3.5, 64.0, 'C+'),
(89, 13.0, 14.0, 7.5, 3.5, 4.0, 70.0, 'B'),
(90, 16.5, 15.5, 8.0, 3.5, 4.0, 76.0, 'A-'),
(91, 18.0, 17.5, 9.0, 4.5, 5.0, 86.0, 'A');

-- Insert Grades for Spring 2024 Enrollments
INSERT INTO Grade (enrollment_id, midterm, project, assignments_total, quizzes_total, attendance, final_exam_mark, final_letter_grade) VALUES
(92, 17.5, 18.0, 9.0, 4.5, 5.0, 88.0, 'A+'),
(93, 18.0, 17.5, 9.5, 4.5, 5.0, 91.0, 'A+'),
(94, 16.5, 16.0, 8.5, 4.0, 4.5, 82.0, 'A'),
(95, 19.5, 19.0, 10.0, 5.0, 5.0, 96.0, 'A+'),
(96, 18.5, 18.0, 9.5, 4.5, 5.0, 90.0, 'A+'),
(97, 20.0, 19.5, 10.0, 5.0, 5.0, 98.0, 'A+'),
(98, 14.5, 15.0, 7.5, 3.5, 4.0, 71.0, 'B'),
(99, 15.0, 14.5, 8.0, 3.5, 4.5, 75.0, 'B+'),
(100, 18.5, 18.5, 9.5, 4.5, 5.0, 92.0, 'A+'),
(101, 19.0, 19.0, 10.0, 5.0, 5.0, 95.0, 'A+'),
(102, 17.0, 17.5, 9.0, 4.0, 5.0, 85.0, 'A'),
(103, 11.5, 13.0, 7.0, 2.5, 3.0, 59.0, 'C-'),
(104, 12.5, 14.0, 7.5, 3.0, 3.5, 65.0, 'C+'),
(105, 13.5, 15.0, 8.0, 3.5, 4.0, 72.0, 'B+'),
(106, 18.0, 17.0, 9.0, 4.5, 5.0, 87.0, 'A'),
(107, 17.5, 16.5, 8.5, 4.0, 4.5, 84.0, 'A'),
(108, 19.0, 18.5, 9.5, 4.5, 5.0, 93.0, 'A+'),
(109, 15.5, 16.0, 8.5, 4.0, 4.5, 80.0, 'A'),
(110, 14.0, 15.5, 8.0, 3.5, 4.0, 74.0, 'B+'),
(111, 16.0, 15.0, 8.5, 3.5, 4.5, 78.0, 'A'),
(112, 19.5, 19.0, 9.5, 5.0, 5.0, 95.0, 'A+'),
(113, 18.0, 18.5, 9.5, 4.5, 5.0, 91.0, 'A+'),
(114, 12.0, 13.5, 7.0, 3.0, 3.5, 63.0, 'C+'),
(115, 13.0, 14.5, 7.5, 3.5, 4.0, 71.0, 'B'),
(116, 14.5, 15.5, 8.0, 3.5, 4.5, 76.0, 'A-'),
(117, 17.5, 17.0, 9.0, 4.5, 5.0, 86.0, 'A'),
(118, 18.5, 18.0, 9.5, 4.5, 5.0, 90.0, 'A+');

-- -----------------------------------------------------
-- Script End
-- -----------------------------------------------------
-- -----------------------------------------------------
-- Script End
-- -----------------------------------------------------