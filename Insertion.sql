-- -----------------------------------------------------------------
-- --- University LMS Data Insertion Script ---
-- --- Data Only - Run after Schema Script ---
-- -----------------------------------------------------------------

USE university_lms_db;

-- Disable FK checks for bulk insertion
SET FOREIGN_KEY_CHECKS = 0;

-- -----------------------------------------------------
-- 1. Insert Users & Instructors
-- -----------------------------------------------------

-- 1 Admin
INSERT INTO `User` (user_id, national_id, name, email, official_mail, password_hash, role) VALUES 
(1, '1000000001', 'System Admin', 'admin@lms.edu', 'admin@uni.edu', '$2a$10$gXiUrze2SeHjoQnMu01LPuaMA..6hshvYEF82Bc7ackAL5NQdjIO6', 'admin');

-- 6 Professors (5 Dept Heads + 1 ASU Courses Coordinator)
INSERT INTO `User` (user_id, national_id, name, email, official_mail, password_hash, role) VALUES 
(101, '2000000101', 'Prof. Ahmed CSE', 'ahmed.cse@uni.edu', 'head.cse@uni.edu', '$2a$10$gXiUrze2SeHjoQnMu01LPuaMA..6hshvYEF82Bc7ackAL5NQdjIO6', 'instructor'),
(102, '2000000102', 'Prof. Sarah ARC', 'sarah.arc@uni.edu', 'head.arc@uni.edu', '$2a$10$gXiUrze2SeHjoQnMu01LPuaMA..6hshvYEF82Bc7ackAL5NQdjIO6', 'instructor'),
(103, '2000000103', 'Prof. Mohamed MEP', 'mohamed.mep@uni.edu', 'head.mep@uni.edu', '$2a$10$gXiUrze2SeHjoQnMu01LPuaMA..6hshvYEF82Bc7ackAL5NQdjIO6', 'instructor'),
(104, '2000000104', 'Prof. Laila ECE', 'laila.ece@uni.edu', 'head.ece@uni.edu', '$2a$10$gXiUrze2SeHjoQnMu01LPuaMA..6hshvYEF82Bc7ackAL5NQdjIO6', 'instructor'),
(105, '2000000105', 'Prof. Omar CES', 'omar.ces@uni.edu', 'head.ces@uni.edu', '$2a$10$gXiUrze2SeHjoQnMu01LPuaMA..6hshvYEF82Bc7ackAL5NQdjIO6', 'instructor'),
(106, '2000000106', 'Dr. Amira ASU', 'amira.asu@uni.edu', 'coordinator.asu@uni.edu', '$2a$10$gXiUrze2SeHjoQnMu01LPuaMA..6hshvYEF82Bc7ackAL5NQdjIO6', 'instructor');

INSERT INTO Instructor (instructor_id, instructor_type, office_hours, department_id) VALUES
(101, 'professor', 'Sun/Tue 10-12', 1),   -- Prof. Ahmed -> CSE (Dept 1)
(102, 'professor', 'Mon/Wed 10-12', 2),   -- Prof. Sarah -> ARC (Dept 2)
(103, 'professor', 'Sun/Thu 12-2', 3),    -- Prof. Mohamed -> MEP (Dept 3)
(104, 'professor', 'Tue/Thu 9-11', 4),    -- Prof. Laila -> ECE (Dept 4)
(105, 'professor', 'Mon/Wed 1-3', 5),     -- Prof. Omar -> CES (Dept 5)
(106, 'professor', 'Tue/Thu 2-4', 6);     -- Dr. Amira -> ASU Courses (Dept 6)

-- -----------------------------------------------------
-- 2. Insert Departments (5 Selected)
-- -----------------------------------------------------

-- Insert Departments (5 Selected + ASU Courses)
INSERT INTO Department (department_id, name, unit_head_id) VALUES
(1, 'Computer and Systems Engineering', 101),
(2, 'Architecture Engineering', 102),
(3, 'Mechanical Power Engineering', 103),
(4, 'Electronics and Communication Engineering', 104),
(5, 'Structural Engineering', 105),
(6, 'ASU Courses', 106);

-- -----------------------------------------------------
-- 3. Insert Students (2 Per Dept)
-- -----------------------------------------------------

-- Users for Students
INSERT INTO `User` (user_id, national_id, name, email, official_mail, password_hash, role) VALUES 
-- CSE Students
(201, '3000000201', 'CSE Senior Student', 'cse.sen@mail.com', 'cse.sen@uni.edu', '$2a$10$4vDPjIFF.AQuOCbqQYJkFeAyy9AsHw5QRQEPpgVbnLAjQNuruIEUm', 'student'),
(202, '3000000202', 'CSE Junior Student', 'cse.jun@mail.com', 'cse.jun@uni.edu', '$2a$10$4vDPjIFF.AQuOCbqQYJkFeAyy9AsHw5QRQEPpgVbnLAjQNuruIEUm', 'student'),
-- ARC Students
(203, '3000000203', 'ARC Senior Student', 'arc.sen@mail.com', 'arc.sen@uni.edu', '$2a$10$4vDPjIFF.AQuOCbqQYJkFeAyy9AsHw5QRQEPpgVbnLAjQNuruIEUm', 'student'),
(204, '3000000204', 'ARC Junior Student', 'arc.jun@mail.com', 'arc.jun@uni.edu', '$2a$10$4vDPjIFF.AQuOCbqQYJkFeAyy9AsHw5QRQEPpgVbnLAjQNuruIEUm', 'student'),
-- MEP Students
(205, '3000000205', 'MEP Senior Student', 'mep.sen@mail.com', 'mep.sen@uni.edu', '$2a$10$4vDPjIFF.AQuOCbqQYJkFeAyy9AsHw5QRQEPpgVbnLAjQNuruIEUm', 'student'),
(206, '3000000206', 'MEP Junior Student', 'mep.jun@mail.com', 'mep.jun@uni.edu', '$2a$10$4vDPjIFF.AQuOCbqQYJkFeAyy9AsHw5QRQEPpgVbnLAjQNuruIEUm', 'student'),
-- ECE Students
(207, '3000000207', 'ECE Senior Student', 'ece.sen@mail.com', 'ece.sen@uni.edu', '$2a$10$4vDPjIFF.AQuOCbqQYJkFeAyy9AsHw5QRQEPpgVbnLAjQNuruIEUm', 'student'),
(208, '3000000208', 'ECE Junior Student', 'ece.jun@mail.com', 'ece.jun@uni.edu', '$2a$10$4vDPjIFF.AQuOCbqQYJkFeAyy9AsHw5QRQEPpgVbnLAjQNuruIEUm', 'student'),
-- CES Students
(209, '3000000209', 'CES Senior Student', 'ces.sen@mail.com', 'ces.sen@uni.edu', '$2a$10$4vDPjIFF.AQuOCbqQYJkFeAyy9AsHw5QRQEPpgVbnLAjQNuruIEUm', 'student'),
(210, '3000000210', 'CES Junior Student', 'ces.jun@mail.com', 'ces.jun@uni.edu', '$2a$10$4vDPjIFF.AQuOCbqQYJkFeAyy9AsHw5QRQEPpgVbnLAjQNuruIEUm', 'student');

INSERT INTO Student (student_id, student_uid, cumulative_gpa, department_id, advisor_id) VALUES
(201, 'S-201', 3.2, 1, 101), (202, 'S-202', 2.8, 1, 101),
(203, 'S-203', 3.5, 2, 102), (204, 'S-204', 3.0, 2, 102),
(205, 'S-205', 2.9, 3, 103), (206, 'S-206', 3.1, 3, 103),
(207, 'S-207', 3.8, 4, 104), (208, 'S-208', 3.4, 4, 104),
(209, 'S-209', 2.5, 5, 105), (210, 'S-210', 2.7, 5, 105);

-- -----------------------------------------------------
-- 4. Insert Semesters
-- -----------------------------------------------------

INSERT INTO Semester (semester_id, name, start_date, end_date, registration_open) VALUES
(1, 'Fall 2022',   '2022-09-01', '2022-12-31', 0), -- Old 1
(2, 'Spring 2023', '2023-02-01', '2023-05-31', 0), -- Old 2
(3, 'Fall 2023',   '2023-09-01', '2023-12-31', 0), -- Old 3
(4, 'Spring 2024', '2024-02-01', '2024-05-31', 0), -- Old 4
(5, 'Fall 2024',   '2024-09-01', '2024-12-31', 1); -- Current

-- -----------------------------------------------------
-- 5. Insert Courses (10 ASU + 25 per Dept)
--    Total Credits per semester: 5 dept (3cr) + 1 ASU (2cr) = 17 credits.
-- -----------------------------------------------------

-- A. ASU Courses (IDs 1-10)
INSERT INTO Course (course_id, course_code, title, credits, course_type) VALUES
(1,  'ASU101', 'Human Rights', 2, 'core'),
(2,  'ASU102', 'English 1', 2, 'core'),
(3,  'ASU103', 'English 2', 2, 'core'),
(4,  'ASU104', 'History of Science', 2, 'core'),
(5,  'ASU105', 'Technical Writing', 2, 'core'),
(6,  'ASU106', 'Ethics', 2, 'core'),
(7,  'ASU107', 'Marketing', 2, 'core'),
(8,  'ASU108', 'Psychology', 2, 'core'),
(9,  'ASU109', 'Communication Skills', 2, 'core'),
(10, 'ASU110', 'Critical Thinking', 2, 'core');

-- B. Department Courses (25 per dept)
-- Logic: ID = DeptID * 100 + Number (e.g., CSE starts at 101, ARC at 201)
-- All are 3 credits to fit requirements

-- Dept 1: CSE (IDs 101-125)
INSERT INTO Course (course_id, course_code, title, credits, course_type) VALUES
(101, 'CSE101', 'Prog 1', 3, 'core'), (102, 'CSE102', 'Discrete Math', 3, 'core'), (103, 'CSE103', 'Digital Logic', 3, 'core'), (104, 'CSE104', 'Circuits', 3, 'core'), (105, 'CSE105', 'Web Dev', 3, 'core'),
(106, 'CSE106', 'Prog 2', 3, 'core'), (107, 'CSE107', 'Data Struct', 3, 'core'), (108, 'CSE108', 'Comp Org', 3, 'core'), (109, 'CSE109', 'Signals', 3, 'core'), (110, 'CSE110', 'DB Systems', 3, 'core'),
(111, 'CSE111', 'Algorithms', 3, 'core'), (112, 'CSE112', 'OS', 3, 'core'), (113, 'CSE113', 'Networks', 3, 'core'), (114, 'CSE114', 'Software Eng', 3, 'core'), (115, 'CSE115', 'AI Basics', 3, 'core'),
(116, 'CSE116', 'Comp Arch', 3, 'core'), (117, 'CSE117', 'Embedded', 3, 'core'), (118, 'CSE118', 'Graphics', 3, 'core'), (119, 'CSE119', 'Security', 3, 'core'), (120, 'CSE120', 'Cloud', 3, 'core'),
(121, 'CSE121', 'Adv AI', 3, 'core'), (122, 'CSE122', 'Machine Learning', 3, 'core'), (123, 'CSE123', 'Image Proc', 3, 'core'), (124, 'CSE124', 'Big Data', 3, 'core'), (125, 'CSE125', 'Project', 3, 'core');

-- Dept 2: ARC (IDs 201-225)
INSERT INTO Course (course_id, course_code, title, credits, course_type) VALUES
(201, 'ARC101', 'Design 1', 3, 'core'), (202, 'ARC102', 'Visual Arts', 3, 'core'), (203, 'ARC103', 'History 1', 3, 'core'), (204, 'ARC104', 'Materials', 3, 'core'), (205, 'ARC105', 'Drawing', 3, 'core'),
(206, 'ARC106', 'Design 2', 3, 'core'), (207, 'ARC107', 'History 2', 3, 'core'), (208, 'ARC108', 'Construction 1', 3, 'core'), (209, 'ARC109', 'Physics', 3, 'core'), (210, 'ARC110', 'Theory 1', 3, 'core'),
(211, 'ARC111', 'Design 3', 3, 'core'), (212, 'ARC112', 'Urban Plan', 3, 'core'), (213, 'ARC113', 'Construction 2', 3, 'core'), (214, 'ARC114', 'Environmental', 3, 'core'), (215, 'ARC115', 'Theory 2', 3, 'core'),
(216, 'ARC116', 'Design 4', 3, 'core'), (217, 'ARC117', 'Housing', 3, 'core'), (218, 'ARC118', 'Landscape', 3, 'core'), (219, 'ARC119', 'Acoustics', 3, 'core'), (220, 'ARC120', 'Interior', 3, 'core'),
(221, 'ARC121', 'Design 5', 3, 'core'), (222, 'ARC122', 'Heritage', 3, 'core'), (223, 'ARC123', 'City Plan', 3, 'core'), (224, 'ARC124', 'Sustainability', 3, 'core'), (225, 'ARC125', 'Grad Project', 3, 'core');

-- Dept 3: MEP (IDs 301-325)
INSERT INTO Course (course_id, course_code, title, credits, course_type) VALUES
(301, 'MEP101', 'Thermo 1', 3, 'core'), (302, 'MEP102', 'Fluids 1', 3, 'core'), (303, 'MEP103', 'Drawing', 3, 'core'), (304, 'MEP104', 'Materials', 3, 'core'), (305, 'MEP105', 'Statics', 3, 'core'),
(306, 'MEP106', 'Thermo 2', 3, 'core'), (307, 'MEP107', 'Fluids 2', 3, 'core'), (308, 'MEP108', 'Dynamics', 3, 'core'), (309, 'MEP109', 'Manufacturing', 3, 'core'), (310, 'MEP110', 'Mechanics', 3, 'core'),
(311, 'MEP111', 'Heat Transfer', 3, 'core'), (312, 'MEP112', 'Machine Des', 3, 'core'), (313, 'MEP113', 'Measurement', 3, 'core'), (314, 'MEP114', 'Combustion', 3, 'core'), (315, 'MEP115', 'Control', 3, 'core'),
(316, 'MEP116', 'Power Plants', 3, 'core'), (317, 'MEP117', 'Hydraulics', 3, 'core'), (318, 'MEP118', 'HVAC', 3, 'core'), (319, 'MEP119', 'Turbo', 3, 'core'), (320, 'MEP120', 'Solar', 3, 'core'),
(321, 'MEP121', 'ICE Engines', 3, 'core'), (322, 'MEP122', 'Gas Turbines', 3, 'core'), (323, 'MEP123', 'Desalination', 3, 'core'), (324, 'MEP124', 'Refrig', 3, 'core'), (325, 'MEP125', 'Grad Project', 3, 'core');

-- Dept 4: ECE (IDs 401-425)
INSERT INTO Course (course_id, course_code, title, credits, course_type) VALUES
(401, 'ECE101', 'Circuits 1', 3, 'core'), (402, 'ECE102', 'Electronics 1', 3, 'core'), (403, 'ECE103', 'Fields 1', 3, 'core'), (404, 'ECE104', 'Logic', 3, 'core'), (405, 'ECE105', 'Math 1', 3, 'core'),
(406, 'ECE106', 'Circuits 2', 3, 'core'), (407, 'ECE107', 'Electronics 2', 3, 'core'), (408, 'ECE108', 'Fields 2', 3, 'core'), (409, 'ECE109', 'Signals', 3, 'core'), (410, 'ECE110', 'Measurements', 3, 'core'),
(411, 'ECE111', 'Comm Systems', 3, 'core'), (412, 'ECE112', 'Control', 3, 'core'), (413, 'ECE113', 'Waves', 3, 'core'), (414, 'ECE114', 'Microproc', 3, 'core'), (415, 'ECE115', 'Digital Comm', 3, 'core'),
(416, 'ECE116', 'Antennas', 3, 'core'), (417, 'ECE117', 'DSP', 3, 'core'), (418, 'ECE118', 'Microwave', 3, 'core'), (419, 'ECE119', 'Optical', 3, 'core'), (420, 'ECE120', 'Networks', 3, 'core'),
(421, 'ECE121', 'Mobile Comm', 3, 'core'), (422, 'ECE122', 'Satellite', 3, 'core'), (423, 'ECE123', 'VLSI', 3, 'core'), (424, 'ECE124', 'Radar', 3, 'core'), (425, 'ECE125', 'Grad Project', 3, 'core');

-- Dept 5: CES (IDs 501-525)
INSERT INTO Course (course_id, course_code, title, credits, course_type) VALUES
(501, 'CES101', 'Struct Mech 1', 3, 'core'), (502, 'CES102', 'Drawing', 3, 'core'), (503, 'CES103', 'Materials 1', 3, 'core'), (504, 'CES104', 'Surveying', 3, 'core'), (505, 'CES105', 'Math', 3, 'core'),
(506, 'CES106', 'Struct Mech 2', 3, 'core'), (507, 'CES107', 'Concrete 1', 3, 'core'), (508, 'CES108', 'Materials 2', 3, 'core'), (509, 'CES109', 'Geology', 3, 'core'), (510, 'CES110', 'Fluid Mech', 3, 'core'),
(511, 'CES111', 'Struct Anal 1', 3, 'core'), (512, 'CES112', 'Concrete 2', 3, 'core'), (513, 'CES113', 'Steel 1', 3, 'core'), (514, 'CES114', 'Soil Mech 1', 3, 'core'), (515, 'CES115', 'Hydrology', 3, 'core'),
(516, 'CES116', 'Struct Anal 2', 3, 'core'), (517, 'CES117', 'Concrete 3', 3, 'core'), (518, 'CES118', 'Steel 2', 3, 'core'), (519, 'CES119', 'Soil Mech 2', 3, 'core'), (520, 'CES120', 'Management', 3, 'core'),
(521, 'CES121', 'Bridges', 3, 'core'), (522, 'CES122', 'High Rise', 3, 'core'), (523, 'CES123', 'Foundations', 3, 'core'), (524, 'CES124', 'Earthquake', 3, 'core'), (525, 'CES125', 'Grad Project', 3, 'core');

-- Link Courses to Departments
INSERT INTO DepartmentCourse (department_id, course_id, course_type)
SELECT 1, course_id, 'core' FROM Course WHERE course_id BETWEEN 101 AND 125 UNION ALL
SELECT 2, course_id, 'core' FROM Course WHERE course_id BETWEEN 201 AND 225 UNION ALL
SELECT 3, course_id, 'core' FROM Course WHERE course_id BETWEEN 301 AND 325 UNION ALL
SELECT 4, course_id, 'core' FROM Course WHERE course_id BETWEEN 401 AND 425 UNION ALL
SELECT 5, course_id, 'core' FROM Course WHERE course_id BETWEEN 501 AND 525 UNION ALL
SELECT 6, course_id, 'core' FROM Course WHERE course_id BETWEEN 1 AND 10;

-- -----------------------------------------------------
-- 6. OFFERED COURSES & SECTIONS GENERATION
-- -----------------------------------------------------
-- Logic:
-- Sem 1: Dept Courses 1-5 + ASU 1
-- Sem 2: Dept Courses 6-10 + ASU 2
-- Sem 3: Dept Courses 11-15 + ASU 3
-- Sem 4: Dept Courses 16-20 + ASU 4
-- Sem 5 (Current): Dept Courses 21-25 + (Repeat Course 1 to make it 6 courses)

-- Helper Procedure to Generate offerings
DELIMITER //
CREATE PROCEDURE GenerateSemesterData(
    IN sem_id INT, 
    IN asu_id INT, 
    IN dept_start_offset INT -- 0 for 1-5, 5 for 6-10, etc.
)
BEGIN
    DECLARE d INT DEFAULT 1;
    DECLARE c_base INT;
    DECLARE off_id INT;
    
    -- 1. Insert ASU Course Offering for this semester
    INSERT INTO OfferedCourse (course_id, semester_id) VALUES (asu_id, sem_id);
    SET off_id = LAST_INSERT_ID();
    INSERT INTO Section (offered_course_id, ta_instructor_id, section_number) VALUES (off_id, 101, 'A');
    
    -- 2. Loop through 5 Departments
    WHILE d <= 5 DO
        -- Calculate base course ID for this dept (e.g., CSE starts 101)
        SET c_base = d * 100 + 1; 
        
        -- Insert 5 Dept Courses for this semester
        INSERT INTO OfferedCourse (course_id, semester_id) VALUES 
        (c_base + dept_start_offset, sem_id),
        (c_base + dept_start_offset + 1, sem_id),
        (c_base + dept_start_offset + 2, sem_id),
        (c_base + dept_start_offset + 3, sem_id),
        (c_base + dept_start_offset + 4, sem_id);
        
        -- Create Sections for these 5 courses (using bulk insert trick with subquery)
        INSERT INTO Section (offered_course_id, ta_instructor_id, section_number)
        SELECT offered_course_id, (100+d), 'A' 
        FROM OfferedCourse 
        WHERE semester_id = sem_id 
        AND course_id BETWEEN (c_base + dept_start_offset) AND (c_base + dept_start_offset + 4);
        
        SET d = d + 1;
    END WHILE;
END //

CREATE PROCEDURE GenerateCurrentSemester(IN sem_id INT)
BEGIN
    DECLARE d INT DEFAULT 1;
    DECLARE c_base INT;
    
    -- Loop through 5 Departments
    WHILE d <= 5 DO
        SET c_base = d * 100 + 1; 
        
        -- Insert Courses 21-25
        INSERT INTO OfferedCourse (course_id, semester_id) VALUES 
        (c_base + 20, sem_id), (c_base + 21, sem_id), (c_base + 22, sem_id), (c_base + 23, sem_id), (c_base + 24, sem_id);
        
        -- Insert Course 1 (Repetition/Elective to reach 6 courses)
        INSERT INTO OfferedCourse (course_id, semester_id) VALUES (c_base, sem_id);

        -- Sections for 21-25
        INSERT INTO Section (offered_course_id, ta_instructor_id, section_number)
        SELECT offered_course_id, (100+d), 'A' FROM OfferedCourse WHERE semester_id = sem_id AND course_id BETWEEN (c_base + 20) AND (c_base + 24);
        
        -- Section for Course 1
        INSERT INTO Section (offered_course_id, ta_instructor_id, section_number)
        SELECT offered_course_id, (100+d), 'A' FROM OfferedCourse WHERE semester_id = sem_id AND course_id = c_base;

        SET d = d + 1;
    END WHILE;
END //
DELIMITER ;

-- Execute Procedures
CALL GenerateSemesterData(1, 1, 0);  -- Sem 1: ASU1 + Dept Courses 1-5
CALL GenerateSemesterData(2, 2, 5);  -- Sem 2: ASU2 + Dept Courses 6-10
CALL GenerateSemesterData(3, 3, 10); -- Sem 3: ASU3 + Dept Courses 11-15
CALL GenerateSemesterData(4, 4, 15); -- Sem 4: ASU4 + Dept Courses 16-20
CALL GenerateCurrentSemester(5);     -- Sem 5: Dept Courses 21-25 + Course 1

-- -----------------------------------------------------
-- 7. ENROLLMENTS & GRADES
-- -----------------------------------------------------

-- Helper to Enroll Student in specific semester offerings linked to their dept
DELIMITER //
CREATE PROCEDURE EnrollStudent(
    IN stud_id INT, 
    IN dept_id INT, 
    IN sem_id INT, 
    IN is_current BOOL
)
BEGIN
    -- Enroll in all Dept sections for this semester
    INSERT INTO Enrollment (student_id, section_id, status)
    SELECT stud_id, s.section_id, 'approved'
    FROM Section s
    JOIN OfferedCourse oc ON s.offered_course_id = oc.offered_course_id
    JOIN Course c ON oc.course_id = c.course_id
    WHERE oc.semester_id = sem_id
    AND (
        -- If Dept Course: ID matches Dept Pattern
        (c.course_id >= (dept_id * 100) AND c.course_id < ((dept_id + 1) * 100))
        OR
        -- If ASU Course (Only for non-current semesters)
        (is_current = FALSE AND c.course_id <= 10)
    );
END //
DELIMITER ;

-- Enroll Seniors (Odd IDs: 201, 203, 205, 207, 209) -> 4 Old Sems + Current
-- Enroll Juniors (Even IDs: 202, 204, 206, 208, 210) -> 2 Old Sems (Sem 3,4) + Current

-- CSE (Dept 1)
CALL EnrollStudent(201, 1, 1, FALSE); CALL EnrollStudent(201, 1, 2, FALSE); CALL EnrollStudent(201, 1, 3, FALSE); CALL EnrollStudent(201, 1, 4, FALSE); CALL EnrollStudent(201, 1, 5, TRUE);
CALL EnrollStudent(202, 1, 3, FALSE); CALL EnrollStudent(202, 1, 4, FALSE); CALL EnrollStudent(202, 1, 5, TRUE);

-- ARC (Dept 2)
CALL EnrollStudent(203, 2, 1, FALSE); CALL EnrollStudent(203, 2, 2, FALSE); CALL EnrollStudent(203, 2, 3, FALSE); CALL EnrollStudent(203, 2, 4, FALSE); CALL EnrollStudent(203, 2, 5, TRUE);
CALL EnrollStudent(204, 2, 3, FALSE); CALL EnrollStudent(204, 2, 4, FALSE); CALL EnrollStudent(204, 2, 5, TRUE);

-- MEP (Dept 3)
CALL EnrollStudent(205, 3, 1, FALSE); CALL EnrollStudent(205, 3, 2, FALSE); CALL EnrollStudent(205, 3, 3, FALSE); CALL EnrollStudent(205, 3, 4, FALSE); CALL EnrollStudent(205, 3, 5, TRUE);
CALL EnrollStudent(206, 3, 3, FALSE); CALL EnrollStudent(206, 3, 4, FALSE); CALL EnrollStudent(206, 3, 5, TRUE);

-- ECE (Dept 4)
CALL EnrollStudent(207, 4, 1, FALSE); CALL EnrollStudent(207, 4, 2, FALSE); CALL EnrollStudent(207, 4, 3, FALSE); CALL EnrollStudent(207, 4, 4, FALSE); CALL EnrollStudent(207, 4, 5, TRUE);
CALL EnrollStudent(208, 4, 3, FALSE); CALL EnrollStudent(208, 4, 4, FALSE); CALL EnrollStudent(208, 4, 5, TRUE);

-- CES (Dept 5)
CALL EnrollStudent(209, 5, 1, FALSE); CALL EnrollStudent(209, 5, 2, FALSE); CALL EnrollStudent(209, 5, 3, FALSE); CALL EnrollStudent(209, 5, 4, FALSE); CALL EnrollStudent(209, 5, 5, TRUE);
CALL EnrollStudent(210, 5, 3, FALSE); CALL EnrollStudent(210, 5, 4, FALSE); CALL EnrollStudent(210, 5, 5, TRUE);

-- -----------------------------------------------------
-- 8. INSERT GRADES
-- -----------------------------------------------------

-- A. Old Semesters (Full Grades)
INSERT INTO Grade (enrollment_id, midterm, project, assignments_total, quizzes_total, attendance, final_exam_mark, final_letter_grade)
SELECT 
    enrollment_id,
    15 + (RAND() * 5), -- Midterm (15-20)
    15 + (RAND() * 5), -- Project (15-20)
    8 + (RAND() * 2),  -- Assign (8-10)
    4 + (RAND() * 1),  -- Quiz (4-5)
    4 + (RAND() * 1),  -- Attendance (4-5)
    30 + (RAND() * 10),-- Final (30-40, scaled to fit whatever remains or just nominal)
    ELT(FLOOR(1 + (RAND() * 3)), 'A', 'B', 'A-') -- Random Letter
FROM Enrollment e
JOIN Section s ON e.section_id = s.section_id
JOIN OfferedCourse oc ON s.offered_course_id = oc.offered_course_id
WHERE oc.semester_id < 5;

-- B. Current Semester (Only Midterm, others NULL)
INSERT INTO Grade (enrollment_id, midterm, project, assignments_total, quizzes_total, attendance, final_exam_mark, final_letter_grade)
SELECT 
    enrollment_id,
    10 + (RAND() * 10), -- Midterm (10-20)
    NULL, NULL, NULL, NULL, NULL, NULL
FROM Enrollment e
JOIN Section s ON e.section_id = s.section_id
JOIN OfferedCourse oc ON s.offered_course_id = oc.offered_course_id
WHERE oc.semester_id = 5;

-- Cleanup Procedures
DROP PROCEDURE IF EXISTS GenerateSemesterData;
DROP PROCEDURE IF EXISTS GenerateCurrentSemester;
DROP PROCEDURE IF EXISTS EnrollStudent;
SET FOREIGN_KEY_CHECKS = 1;

SELECT 'Data Insertion Complete' AS Status;