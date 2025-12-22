-- -----------------------------------------------------------------
-- --- University LMS Data Insertion Script ---
-- --- Data Only - Run after Schema Script AND CourseInsertion.sql ---
-- --- Note: CourseInsertion.sql must be run first to create departments and courses
-- -----------------------------------------------------------------

USE university_lms_db;

-- Disable FK checks for bulk insertion
SET FOREIGN_KEY_CHECKS = 0;

-- -----------------------------------------------------
-- 1. Insert Users & Instructors (Unit Heads for all 7 departments)
-- -----------------------------------------------------

-- 1 Admin
INSERT INTO `User` (user_id, national_id, name, email, official_mail, password_hash, role) VALUES 
(1, '1000000001', 'System Admin', 'admin@lms.edu', 'admin@uni.edu', '$2a$10$6ccfmPKMJBX0fxgOt9efqunlSwIdEL7qFVbUnl3y0b.3Y2jO6mnye', 'admin');

-- 7 Unit Heads (one for each department: PHM, ASU, MCT, ARC, ECE, CSE, EPM)
INSERT INTO `User` (user_id, national_id, name, email, official_mail, password_hash, role) VALUES 
(101, '2000000101', 'Prof. Ahmed CSE', 'ahmed.cse@uni.edu', 'head.cse@uni.edu', '$2a$10$6ccfmPKMJBX0fxgOt9efqunlSwIdEL7qFVbUnl3y0b.3Y2jO6mnye', 'instructor'),
(102, '2000000102', 'Prof. Sarah ARC', 'sarah.arc@uni.edu', 'head.arc@uni.edu', '$2a$10$6ccfmPKMJBX0fxgOt9efqunlSwIdEL7qFVbUnl3y0b.3Y2jO6mnye', 'instructor'),
(103, '2000000103', 'Prof. Mohamed EPM', 'mohamed.epm@uni.edu', 'head.epm@uni.edu', '$2a$10$6ccfmPKMJBX0fxgOt9efqunlSwIdEL7qFVbUnl3y0b.3Y2jO6mnye', 'instructor'),
(104, '2000000104', 'Prof. Laila ECE', 'laila.ece@uni.edu', 'head.ece@uni.edu', '$2a$10$6ccfmPKMJBX0fxgOt9efqunlSwIdEL7qFVbUnl3y0b.3Y2jO6mnye', 'instructor'),
(105, '2000000105', 'Prof. Omar MCT', 'omar.mct@uni.edu', 'head.mct@uni.edu', '$2a$10$6ccfmPKMJBX0fxgOt9efqunlSwIdEL7qFVbUnl3y0b.3Y2jO6mnye', 'instructor'),
(106, '2000000106', 'Dr. Amira ASU', 'amira.asu@uni.edu', 'coordinator.asu@uni.edu', '$2a$10$6ccfmPKMJBX0fxgOt9efqunlSwIdEL7qFVbUnl3y0b.3Y2jO6mnye', 'instructor'),
(107, '2000000107', 'Prof. Khaled PHM', 'khaled.phm@uni.edu', 'head.phm@uni.edu', '$2a$10$6ccfmPKMJBX0fxgOt9efqunlSwIdEL7qFVbUnl3y0b.3Y2jO6mnye', 'instructor');

-- Create instructors (department_id will be updated after departments are linked)
INSERT INTO Instructor (instructor_id, instructor_type, office_hours, department_id) VALUES
(101, 'professor', 'Sun/Tue 10-12', NULL),   -- Prof. Ahmed -> CSE
(102, 'professor', 'Mon/Wed 10-12', NULL),   -- Prof. Sarah -> ARC
(103, 'professor', 'Sun/Thu 12-2', NULL),    -- Prof. Mohamed -> EPM
(104, 'professor', 'Tue/Thu 9-11', NULL),    -- Prof. Laila -> ECE
(105, 'professor', 'Mon/Wed 1-3', NULL),     -- Prof. Omar -> MCT
(106, 'professor', 'Tue/Thu 2-4', NULL),     -- Dr. Amira -> ASU
(107, 'professor', 'Mon/Fri 11-1', NULL);    -- Prof. Khaled -> PHM

-- -----------------------------------------------------
-- 2. Update Departments with Unit Heads
-- -----------------------------------------------------
-- Note: Departments should already exist from CourseInsertion.sql
-- We just need to update them with unit_head_id

UPDATE Department SET unit_head_id = 101 WHERE department_code = 'CSE';
UPDATE Department SET unit_head_id = 102 WHERE department_code = 'ARC';
UPDATE Department SET unit_head_id = 103 WHERE department_code = 'EPM';
UPDATE Department SET unit_head_id = 104 WHERE department_code = 'ECE';
UPDATE Department SET unit_head_id = 105 WHERE department_code = 'MCT';
UPDATE Department SET unit_head_id = 106 WHERE department_code = 'ASU';
UPDATE Department SET unit_head_id = 107 WHERE department_code = 'PHM';

-- Update instructor department_id now that departments exist
UPDATE Instructor SET department_id = (SELECT department_id FROM Department WHERE department_code = 'CSE') WHERE instructor_id = 101;
UPDATE Instructor SET department_id = (SELECT department_id FROM Department WHERE department_code = 'ARC') WHERE instructor_id = 102;
UPDATE Instructor SET department_id = (SELECT department_id FROM Department WHERE department_code = 'EPM') WHERE instructor_id = 103;
UPDATE Instructor SET department_id = (SELECT department_id FROM Department WHERE department_code = 'ECE') WHERE instructor_id = 104;
UPDATE Instructor SET department_id = (SELECT department_id FROM Department WHERE department_code = 'MCT') WHERE instructor_id = 105;
UPDATE Instructor SET department_id = (SELECT department_id FROM Department WHERE department_code = 'ASU') WHERE instructor_id = 106;
UPDATE Instructor SET department_id = (SELECT department_id FROM Department WHERE department_code = 'PHM') WHERE instructor_id = 107;

-- -----------------------------------------------------
-- 3. Insert Students (2 per student department: MCT, ARC, ECE, CSE, EPM)
-- -----------------------------------------------------
-- Note: ASU and PHM have NO students (they are service departments)

-- Users for Students (10 students total: 2 per student department)
INSERT INTO `User` (user_id, national_id, name, email, official_mail, password_hash, role) VALUES 
-- CSE Students
(201, '3000000201', 'CSE Senior Student', 'cse.sen@mail.com', 'cse.sen@uni.edu', '$2a$10$6ccfmPKMJBX0fxgOt9efqunlSwIdEL7qFVbUnl3y0b.3Y2jO6mnye', 'student'),
(202, '3000000202', 'CSE Junior Student', 'cse.jun@mail.com', 'cse.jun@uni.edu', '$2a$10$6ccfmPKMJBX0fxgOt9efqunlSwIdEL7qFVbUnl3y0b.3Y2jO6mnye', 'student'),
-- ARC Students
(203, '3000000203', 'ARC Senior Student', 'arc.sen@mail.com', 'arc.sen@uni.edu', '$2a$10$6ccfmPKMJBX0fxgOt9efqunlSwIdEL7qFVbUnl3y0b.3Y2jO6mnye', 'student'),
(204, '3000000204', 'ARC Junior Student', 'arc.jun@mail.com', 'arc.jun@uni.edu', '$2a$10$6ccfmPKMJBX0fxgOt9efqunlSwIdEL7qFVbUnl3y0b.3Y2jO6mnye', 'student'),
-- ECE Students
(205, '3000000205', 'ECE Senior Student', 'ece.sen@mail.com', 'ece.sen@uni.edu', '$2a$10$6ccfmPKMJBX0fxgOt9efqunlSwIdEL7qFVbUnl3y0b.3Y2jO6mnye', 'student'),
(206, '3000000206', 'ECE Junior Student', 'ece.jun@mail.com', 'ece.jun@uni.edu', '$2a$10$6ccfmPKMJBX0fxgOt9efqunlSwIdEL7qFVbUnl3y0b.3Y2jO6mnye', 'student'),
-- MCT Students
(207, '3000000207', 'MCT Senior Student', 'mct.sen@mail.com', 'mct.sen@uni.edu', '$2a$10$6ccfmPKMJBX0fxgOt9efqunlSwIdEL7qFVbUnl3y0b.3Y2jO6mnye', 'student'),
(208, '3000000208', 'MCT Junior Student', 'mct.jun@mail.com', 'mct.jun@uni.edu', '$2a$10$6ccfmPKMJBX0fxgOt9efqunlSwIdEL7qFVbUnl3y0b.3Y2jO6mnye', 'student'),
-- EPM Students
(209, '3000000209', 'EPM Senior Student', 'epm.sen@mail.com', 'epm.sen@uni.edu', '$2a$10$6ccfmPKMJBX0fxgOt9efqunlSwIdEL7qFVbUnl3y0b.3Y2jO6mnye', 'student'),
(210, '3000000210', 'EPM Junior Student', 'epm.jun@mail.com', 'epm.jun@uni.edu', '$2a$10$6ccfmPKMJBX0fxgOt9efqunlSwIdEL7qFVbUnl3y0b.3Y2jO6mnye', 'student');

-- -----------------------------------------------------
-- 3.1. Insert Parent Users (10 parents, one for each student)
-- -----------------------------------------------------

-- Users for Parents (10 parents total: one per student)
INSERT INTO `User` (user_id, national_id, name, email, official_mail, password_hash, role) VALUES 
-- Parents for CSE Students
(301, 'PN-201', 'Parent of CSE Senior', 'parent201@mail.com', 'parent201@mail.com', '$2a$10$6ccfmPKMJBX0fxgOt9efqunlSwIdEL7qFVbUnl3y0b.3Y2jO6mnye', 'parent'),
(302, 'PN-202', 'Parent of CSE Junior', 'parent202@mail.com', 'parent202@mail.com', '$2a$10$6ccfmPKMJBX0fxgOt9efqunlSwIdEL7qFVbUnl3y0b.3Y2jO6mnye', 'parent'),
-- Parents for ARC Students
(303, 'PN-203', 'Parent of ARC Senior', 'parent203@mail.com', 'parent203@mail.com', '$2a$10$6ccfmPKMJBX0fxgOt9efqunlSwIdEL7qFVbUnl3y0b.3Y2jO6mnye', 'parent'),
(304, 'PN-204', 'Parent of ARC Junior', 'parent204@mail.com', 'parent204@mail.com', '$2a$10$6ccfmPKMJBX0fxgOt9efqunlSwIdEL7qFVbUnl3y0b.3Y2jO6mnye', 'parent'),
-- Parents for ECE Students
(305, 'PN-205', 'Parent of ECE Senior', 'parent205@mail.com', 'parent205@mail.com', '$2a$10$6ccfmPKMJBX0fxgOt9efqunlSwIdEL7qFVbUnl3y0b.3Y2jO6mnye', 'parent'),
(306, 'PN-206', 'Parent of ECE Junior', 'parent206@mail.com', 'parent206@mail.com', '$2a$10$6ccfmPKMJBX0fxgOt9efqunlSwIdEL7qFVbUnl3y0b.3Y2jO6mnye', 'parent'),
-- Parents for MCT Students
(307, 'PN-207', 'Parent of MCT Senior', 'parent207@mail.com', 'parent207@mail.com', '$2a$10$6ccfmPKMJBX0fxgOt9efqunlSwIdEL7qFVbUnl3y0b.3Y2jO6mnye', 'parent'),
(308, 'PN-208', 'Parent of MCT Junior', 'parent208@mail.com', 'parent208@mail.com', '$2a$10$6ccfmPKMJBX0fxgOt9efqunlSwIdEL7qFVbUnl3y0b.3Y2jO6mnye', 'parent'),
-- Parents for EPM Students
(309, 'PN-209', 'Parent of EPM Senior', 'parent209@mail.com', 'parent209@mail.com', '$2a$10$6ccfmPKMJBX0fxgOt9efqunlSwIdEL7qFVbUnl3y0b.3Y2jO6mnye', 'parent'),
(310, 'PN-210', 'Parent of EPM Junior', 'parent210@mail.com', 'parent210@mail.com', '$2a$10$6ccfmPKMJBX0fxgOt9efqunlSwIdEL7qFVbUnl3y0b.3Y2jO6mnye', 'parent');

-- Insert Student records (using department_id from Department table and linking to parent users)
INSERT INTO Student (
    student_id, student_uid, cumulative_gpa, department_id, advisor_id,
    parent_national_id, parent_phone, parent_email, parent_user_id
) 
SELECT 
    201, 'S-201', 3.2, d.department_id, 101, 'PN-201', '0100000201', 'parent201@mail.com', 301
FROM Department d WHERE d.department_code = 'CSE'
UNION ALL
SELECT 
    202, 'S-202', 2.8, d.department_id, 101, 'PN-202', '0100000202', 'parent202@mail.com', 302
FROM Department d WHERE d.department_code = 'CSE'
UNION ALL
SELECT 
    203, 'S-203', 3.5, d.department_id, 102, 'PN-203', '0100000203', 'parent203@mail.com', 303
FROM Department d WHERE d.department_code = 'ARC'
UNION ALL
SELECT 
    204, 'S-204', 3.0, d.department_id, 102, 'PN-204', '0100000204', 'parent204@mail.com', 304
FROM Department d WHERE d.department_code = 'ARC'
UNION ALL
SELECT 
    205, 'S-205', 2.9, d.department_id, 104, 'PN-205', '0100000205', 'parent205@mail.com', 305
FROM Department d WHERE d.department_code = 'ECE'
UNION ALL
SELECT 
    206, 'S-206', 3.1, d.department_id, 104, 'PN-206', '0100000206', 'parent206@mail.com', 306
FROM Department d WHERE d.department_code = 'ECE'
UNION ALL
SELECT 
    207, 'S-207', 3.8, d.department_id, 105, 'PN-207', '0100000207', 'parent207@mail.com', 307
FROM Department d WHERE d.department_code = 'MCT'
UNION ALL
SELECT 
    208, 'S-208', 3.4, d.department_id, 105, 'PN-208', '0100000208', 'parent208@mail.com', 308
FROM Department d WHERE d.department_code = 'MCT'
UNION ALL
SELECT 
    209, 'S-209', 2.5, d.department_id, 103, 'PN-209', '0100000209', 'parent209@mail.com', 309
FROM Department d WHERE d.department_code = 'EPM'
UNION ALL
SELECT 
    210, 'S-210', 2.7, d.department_id, 103, 'PN-210', '0100000210', 'parent210@mail.com', 310
FROM Department d WHERE d.department_code = 'EPM';

-- -----------------------------------------------------
-- 4. Insert Semesters (5 semesters: Fall 2023, Spring 2024, Fall 2024, Spring 2025, Fall 2025)
-- -----------------------------------------------------

INSERT INTO Semester (semester_id, name, start_date, end_date, registration_open) VALUES
(1, 'Fall 2023',   '2023-09-01', '2023-12-31', 0),
(2, 'Spring 2024', '2024-02-01', '2024-05-31', 0),
(3, 'Fall 2024',   '2024-09-01', '2024-12-31', 0),
(4, 'Spring 2025', '2025-02-01', '2025-05-31', 0),
(5, 'Fall 2025',   '2025-09-01', '2025-12-31', 1); -- Current semester

-- -----------------------------------------------------
-- 5. Create Offered Courses for Each Semester
-- -----------------------------------------------------
-- Strategy: Offer courses from CourseInsertion.sql based on course codes
-- We'll offer foundational courses in early semesters and advanced courses later

-- Helper procedure to offer courses by course code for a semester
-- This procedure takes a comma-separated list of course codes and offers them for the semester
DELIMITER //

CREATE PROCEDURE OfferCoursesByCode(
    IN sem_id INT,
    IN course_codes_list TEXT
)
BEGIN
    DECLARE pos INT DEFAULT 1;
    DECLARE next_pos INT;
    DECLARE course_code_val VARCHAR(20);
    DECLARE course_codes_remaining TEXT;
    
    SET course_codes_remaining = CONCAT(course_codes_list, ',');
    
    -- Loop through comma-separated course codes
    parse_loop: WHILE pos <= CHAR_LENGTH(course_codes_remaining) DO
        SET next_pos = LOCATE(',', course_codes_remaining, pos);
        IF next_pos = 0 THEN
            LEAVE parse_loop;
        END IF;
        
        SET course_code_val = TRIM(SUBSTRING(course_codes_remaining, pos, next_pos - pos));
        
        IF course_code_val != '' THEN
            -- Insert OfferedCourse if course exists and not already offered this semester
            INSERT INTO OfferedCourse (course_id, semester_id)
            SELECT c.course_id, sem_id
            FROM Course c
            WHERE c.course_code = course_code_val
            AND NOT EXISTS (
                SELECT 1 FROM OfferedCourse oc 
                WHERE oc.course_id = c.course_id AND oc.semester_id = sem_id
            )
            LIMIT 1;
            
            -- Create section for the offered course
            INSERT INTO Section (offered_course_id, ta_instructor_id, section_number, capacity, current_enrollment)
            SELECT 
                oc.offered_course_id, 
                CASE c.department_code
                    WHEN 'CSE' THEN 101
                    WHEN 'ARC' THEN 102
                    WHEN 'EPM' THEN 103
                    WHEN 'ECE' THEN 104
                    WHEN 'MCT' THEN 105
                    WHEN 'ASU' THEN 106
                    WHEN 'PHM' THEN 107
                    ELSE 101
                END AS ta_instructor_id,
                'A', 50, 0
            FROM OfferedCourse oc
            JOIN Course c ON oc.course_id = c.course_id
            WHERE oc.semester_id = sem_id
            AND c.course_code = course_code_val
            AND NOT EXISTS (
                SELECT 1 FROM Section s WHERE s.offered_course_id = oc.offered_course_id
            )
            LIMIT 1;
        END IF;
        
        SET pos = next_pos + 1;
    END WHILE parse_loop;
END //

DELIMITER ;

-- Fall 2023: Offer foundational courses (first year courses)
-- ASU courses: ASU011, ASU111
-- PHM courses: PHM011, PHM012, PHM013, PHM021, PHM022, PHM031, PHM032, PHM041
CALL OfferCoursesByCode(1, 'ASU011,ASU111,PHM011,PHM012,PHM013,PHM021,PHM022,PHM031,PHM032,PHM041');
-- CSE first year courses
CALL OfferCoursesByCode(1, 'CSE031,CSE111,CSE112,CSE131');
-- ARC first year courses
CALL OfferCoursesByCode(1, 'ARC111,ARC112,ARC131,ARC141,ARC151');
-- ECE first year courses  
CALL OfferCoursesByCode(1, 'ECE111,ECE131,ECE211,ECE215');
-- MCT first year courses
CALL OfferCoursesByCode(1, 'MCT131,MCT211,MCT231,MCT232,MCT233');
-- EPM first year courses
CALL OfferCoursesByCode(1, 'EPM111,EPM112,EPM114,EPM116,EPM118');

-- Spring 2024: Continue with second semester courses
CALL OfferCoursesByCode(2, 'ASU112,PHM111,PHM112,PHM121,PHM122,PHM131,PHM141');
-- Add more department courses for semester 2
CALL OfferCoursesByCode(2, 'CSE211,CSE212,CSE231,CSE232,CSE233');
CALL OfferCoursesByCode(2, 'ARC113,ARC132,ARC142,ARC152,ARC211');
CALL OfferCoursesByCode(2, 'ECE212,ECE213,ECE214,ECE251,ECE252');
CALL OfferCoursesByCode(2, 'MCT234,MCT311,MCT312,MCT333,MCT334');
CALL OfferCoursesByCode(2, 'EPM151,EPM211,EPM212,EPM221,EPM222');

-- Fall 2024: Third semester courses
CALL OfferCoursesByCode(3, 'ASU113,PHM123,PHM211,PHM212,PHM213');
-- Add more department courses
CALL OfferCoursesByCode(3, 'CSE311,CSE331,CSE332,CSE333,CSE334');
CALL OfferCoursesByCode(3, 'ARC212,ARC213,ARC221,ARC241,ARC251');
CALL OfferCoursesByCode(3, 'ECE253,ECE254,ECE255,ECE312,ECE313');
CALL OfferCoursesByCode(3, 'MCT313,MCT341,MCT344,MCT411,MCT412');
CALL OfferCoursesByCode(3, 'EPM231,EPM232,EPM251,EPM311,EPM312');

-- Spring 2025: Fourth semester courses
CALL OfferCoursesByCode(4, 'ASU114,PHM142,PHM241,PHM242');
-- Add more department courses
CALL OfferCoursesByCode(4, 'CSE335,CSE351,CSE352,CSE411,CSE431');
CALL OfferCoursesByCode(4, 'ARC214,ARC252,ARC253,ARC254,ARC321');
CALL OfferCoursesByCode(4, 'ECE314,ECE315,ECE316,ECE331,ECE332');
CALL OfferCoursesByCode(4, 'MCT421,MCT422,MCT443,MCT446,MCT491');
CALL OfferCoursesByCode(4, 'EPM321,EPM322,EPM331,EPM332,EPM341');

-- Fall 2025 (Current): Fifth semester courses - include ASU electives
CALL OfferCoursesByCode(5, 'ASU321,ASU322,ASU323,ASU324,ASU331,ASU332,ASU333,ASU334,ASU335,ASU336');
-- Add more advanced department courses
CALL OfferCoursesByCode(5, 'CSE432,CSE439,CSE441,CSE451,CSE491');
CALL OfferCoursesByCode(5, 'ARC311,ARC312,ARC313,ARC351,ARC352');
CALL OfferCoursesByCode(5, 'ECE333,ECE334,ECE351,ECE352,ECE353');
CALL OfferCoursesByCode(5, 'MCT492');
CALL OfferCoursesByCode(5, 'EPM351,EPM352,EPM353,EPM354,EPM411');

-- -----------------------------------------------------
-- 6. ENROLLMENTS (EAV Model)
-- -----------------------------------------------------

-- Step 1: Insert Enrollment Attributes
INSERT INTO EnrollmentAttributes (attribute_id, attribute_name, value_type) VALUES
(1, 'status', 'text'),
(2, 'enrollment_date', 'datetime'),
(3, 'approval_date', 'datetime')
ON DUPLICATE KEY UPDATE attribute_name = VALUES(attribute_name);

-- Helper procedure to enroll students
DELIMITER //

CREATE PROCEDURE EnrollStudentInSemester(
    IN stud_id INT,
    IN dept_code VARCHAR(10),
    IN sem_id INT
)
BEGIN
    DECLARE dept_id_val INT;
    DECLARE sem_start_date DATE;
    
    -- Get department ID
    SELECT department_id INTO dept_id_val FROM Department WHERE department_code = dept_code;
    
    -- Get semester start date
    SELECT start_date INTO sem_start_date FROM Semester WHERE semester_id = sem_id;
    
    -- Insert enrollments for courses available to this student's department
    -- Include: 1) Courses where student's dept is primary, 2) Courses from DepartmentCourse, 3) ASU/PHM courses
    INSERT INTO Enrollment (student_id, section_id)
    SELECT DISTINCT stud_id, s.section_id
    FROM Section s
    JOIN OfferedCourse oc ON s.offered_course_id = oc.offered_course_id
    JOIN Course c ON oc.course_id = c.course_id
    WHERE oc.semester_id = sem_id
    AND (
        -- Primary department match
        c.department_code = dept_code
        OR
        -- Available through DepartmentCourse
        EXISTS (
            SELECT 1 FROM DepartmentCourse dc 
            WHERE dc.course_id = c.course_id AND dc.department_id = dept_id_val
        )
        OR
        -- ASU or PHM courses (available to all students)
        c.department_code IN ('ASU', 'PHM')
    )
    AND NOT EXISTS (
        SELECT 1 FROM Enrollment e WHERE e.student_id = stud_id AND e.section_id = s.section_id
    );
    
    -- Insert enrollment status attributes
    INSERT INTO EnrollmentAttributeValues (enrollment_id, attribute_id, value)
    SELECT 
        e.enrollment_id,
        1, -- status
        'approved'
    FROM Enrollment e
    JOIN Section s ON e.section_id = s.section_id
    JOIN OfferedCourse oc ON s.offered_course_id = oc.offered_course_id
    WHERE e.student_id = stud_id
    AND oc.semester_id = sem_id
    AND NOT EXISTS (
        SELECT 1 FROM EnrollmentAttributeValues eav 
        WHERE eav.enrollment_id = e.enrollment_id AND eav.attribute_id = 1
    );
    
    -- Insert enrollment date
    INSERT INTO EnrollmentAttributeValues (enrollment_id, attribute_id, value)
    SELECT 
        e.enrollment_id,
        2, -- enrollment_date
        DATE_FORMAT(sem_start_date, '%Y-%m-%d %H:%i:%s')
    FROM Enrollment e
    JOIN Section s ON e.section_id = s.section_id
    JOIN OfferedCourse oc ON s.offered_course_id = oc.offered_course_id
    WHERE e.student_id = stud_id
    AND oc.semester_id = sem_id
    AND NOT EXISTS (
        SELECT 1 FROM EnrollmentAttributeValues eav 
        WHERE eav.enrollment_id = e.enrollment_id AND eav.attribute_id = 2
    );
    
    -- Insert approval date
    INSERT INTO EnrollmentAttributeValues (enrollment_id, attribute_id, value)
    SELECT 
        e.enrollment_id,
        3, -- approval_date
        DATE_FORMAT(sem_start_date, '%Y-%m-%d %H:%i:%s')
    FROM Enrollment e
    JOIN Section s ON e.section_id = s.section_id
    JOIN OfferedCourse oc ON s.offered_course_id = oc.offered_course_id
    WHERE e.student_id = stud_id
    AND oc.semester_id = sem_id
    AND NOT EXISTS (
        SELECT 1 FROM EnrollmentAttributeValues eav 
        WHERE eav.enrollment_id = e.enrollment_id AND eav.attribute_id = 3
    );
END //

DELIMITER ;

-- Enroll Seniors (Odd IDs: 201, 203, 205, 207, 209) in all 5 semesters
CALL EnrollStudentInSemester(201, 'CSE', 1);
CALL EnrollStudentInSemester(201, 'CSE', 2);
CALL EnrollStudentInSemester(201, 'CSE', 3);
CALL EnrollStudentInSemester(201, 'CSE', 4);
CALL EnrollStudentInSemester(201, 'CSE', 5);

CALL EnrollStudentInSemester(203, 'ARC', 1);
CALL EnrollStudentInSemester(203, 'ARC', 2);
CALL EnrollStudentInSemester(203, 'ARC', 3);
CALL EnrollStudentInSemester(203, 'ARC', 4);
CALL EnrollStudentInSemester(203, 'ARC', 5);

CALL EnrollStudentInSemester(205, 'ECE', 1);
CALL EnrollStudentInSemester(205, 'ECE', 2);
CALL EnrollStudentInSemester(205, 'ECE', 3);
CALL EnrollStudentInSemester(205, 'ECE', 4);
CALL EnrollStudentInSemester(205, 'ECE', 5);

CALL EnrollStudentInSemester(207, 'MCT', 1);
CALL EnrollStudentInSemester(207, 'MCT', 2);
CALL EnrollStudentInSemester(207, 'MCT', 3);
CALL EnrollStudentInSemester(207, 'MCT', 4);
CALL EnrollStudentInSemester(207, 'MCT', 5);

CALL EnrollStudentInSemester(209, 'EPM', 1);
CALL EnrollStudentInSemester(209, 'EPM', 2);
CALL EnrollStudentInSemester(209, 'EPM', 3);
CALL EnrollStudentInSemester(209, 'EPM', 4);
CALL EnrollStudentInSemester(209, 'EPM', 5);

-- Enroll Juniors (Even IDs: 202, 204, 206, 208, 210) in semesters 3, 4, and 5
CALL EnrollStudentInSemester(202, 'CSE', 3);
CALL EnrollStudentInSemester(202, 'CSE', 4);
CALL EnrollStudentInSemester(202, 'CSE', 5);

CALL EnrollStudentInSemester(204, 'ARC', 3);
CALL EnrollStudentInSemester(204, 'ARC', 4);
CALL EnrollStudentInSemester(204, 'ARC', 5);

CALL EnrollStudentInSemester(206, 'ECE', 3);
CALL EnrollStudentInSemester(206, 'ECE', 4);
CALL EnrollStudentInSemester(206, 'ECE', 5);

CALL EnrollStudentInSemester(208, 'MCT', 3);
CALL EnrollStudentInSemester(208, 'MCT', 4);
CALL EnrollStudentInSemester(208, 'MCT', 5);

CALL EnrollStudentInSemester(210, 'EPM', 3);
CALL EnrollStudentInSemester(210, 'EPM', 4);
CALL EnrollStudentInSemester(210, 'EPM', 5);

-- -----------------------------------------------------
-- 7. INSERT GRADES (EAV Model)
-- -----------------------------------------------------

-- Step 1: Insert Grade Attributes
INSERT INTO GradeAttributes (attribute_id, attribute_name, value_type, max_value, description) VALUES
(1, 'midterm', 'decimal', 20.00, 'Midterm exam grade (max 20)'),
(2, 'project', 'decimal', 20.00, 'Project grade (max 20)'),
(3, 'assignments_total', 'decimal', 10.00, 'Total assignments grade (max 10)'),
(4, 'quizzes_total', 'decimal', 5.00, 'Total quizzes grade (max 5)'),
(5, 'attendance', 'decimal', 5.00, 'Attendance grade (max 5)'),
(6, 'final_exam_mark', 'decimal', 40.00, 'Final exam mark (max 40)')
ON DUPLICATE KEY UPDATE attribute_name = VALUES(attribute_name);

-- Step 2: Insert Grade records for old semesters (1-4) with final grades
INSERT INTO Grade (enrollment_id, final_letter_grade)
SELECT 
    e.enrollment_id,
    ELT(FLOOR(1 + (RAND() * 4)), 'A', 'A-', 'B+', 'B') -- Random good grades
FROM Enrollment e
JOIN Section s ON e.section_id = s.section_id
JOIN OfferedCourse oc ON s.offered_course_id = oc.offered_course_id
WHERE oc.semester_id < 5
AND NOT EXISTS (
    SELECT 1 FROM Grade g WHERE g.enrollment_id = e.enrollment_id
);

-- Step 3: Insert Grade records for current semester (5) without final grades
INSERT INTO Grade (enrollment_id, final_letter_grade)
SELECT 
    e.enrollment_id,
    NULL -- No final grade yet for current semester
FROM Enrollment e
JOIN Section s ON e.section_id = s.section_id
JOIN OfferedCourse oc ON s.offered_course_id = oc.offered_course_id
WHERE oc.semester_id = 5
AND NOT EXISTS (
    SELECT 1 FROM Grade g WHERE g.enrollment_id = e.enrollment_id
);

-- Step 4: Insert Grade Attribute Values for old semesters (all components)
INSERT INTO GradeAttributeValues (grade_id, attribute_id, value)
SELECT 
    g.grade_id,
    1, -- midterm
    CAST(15 + (RAND() * 5) AS DECIMAL(5,2))
FROM Grade g
JOIN Enrollment e ON g.enrollment_id = e.enrollment_id
JOIN Section s ON e.section_id = s.section_id
JOIN OfferedCourse oc ON s.offered_course_id = oc.offered_course_id
WHERE oc.semester_id < 5
AND NOT EXISTS (
    SELECT 1 FROM GradeAttributeValues gav 
    WHERE gav.grade_id = g.grade_id AND gav.attribute_id = 1
);

INSERT INTO GradeAttributeValues (grade_id, attribute_id, value)
SELECT 
    g.grade_id,
    2, -- project
    CAST(15 + (RAND() * 5) AS DECIMAL(5,2))
FROM Grade g
JOIN Enrollment e ON g.enrollment_id = e.enrollment_id
JOIN Section s ON e.section_id = s.section_id
JOIN OfferedCourse oc ON s.offered_course_id = oc.offered_course_id
WHERE oc.semester_id < 5
AND NOT EXISTS (
    SELECT 1 FROM GradeAttributeValues gav 
    WHERE gav.grade_id = g.grade_id AND gav.attribute_id = 2
);

INSERT INTO GradeAttributeValues (grade_id, attribute_id, value)
SELECT 
    g.grade_id,
    3, -- assignments_total
    CAST(8 + (RAND() * 2) AS DECIMAL(5,2))
FROM Grade g
JOIN Enrollment e ON g.enrollment_id = e.enrollment_id
JOIN Section s ON e.section_id = s.section_id
JOIN OfferedCourse oc ON s.offered_course_id = oc.offered_course_id
WHERE oc.semester_id < 5
AND NOT EXISTS (
    SELECT 1 FROM GradeAttributeValues gav 
    WHERE gav.grade_id = g.grade_id AND gav.attribute_id = 3
);

INSERT INTO GradeAttributeValues (grade_id, attribute_id, value)
SELECT 
    g.grade_id,
    4, -- quizzes_total
    CAST(4 + (RAND() * 1) AS DECIMAL(5,2))
FROM Grade g
JOIN Enrollment e ON g.enrollment_id = e.enrollment_id
JOIN Section s ON e.section_id = s.section_id
JOIN OfferedCourse oc ON s.offered_course_id = oc.offered_course_id
WHERE oc.semester_id < 5
AND NOT EXISTS (
    SELECT 1 FROM GradeAttributeValues gav 
    WHERE gav.grade_id = g.grade_id AND gav.attribute_id = 4
);

INSERT INTO GradeAttributeValues (grade_id, attribute_id, value)
SELECT 
    g.grade_id,
    5, -- attendance
    CAST(4 + (RAND() * 1) AS DECIMAL(5,2))
FROM Grade g
JOIN Enrollment e ON g.enrollment_id = e.enrollment_id
JOIN Section s ON e.section_id = s.section_id
JOIN OfferedCourse oc ON s.offered_course_id = oc.offered_course_id
WHERE oc.semester_id < 5
AND NOT EXISTS (
    SELECT 1 FROM GradeAttributeValues gav 
    WHERE gav.grade_id = g.grade_id AND gav.attribute_id = 5
);

INSERT INTO GradeAttributeValues (grade_id, attribute_id, value)
SELECT 
    g.grade_id,
    6, -- final_exam_mark
    CAST(30 + (RAND() * 10) AS DECIMAL(5,2))
FROM Grade g
JOIN Enrollment e ON g.enrollment_id = e.enrollment_id
JOIN Section s ON e.section_id = s.section_id
JOIN OfferedCourse oc ON s.offered_course_id = oc.offered_course_id
WHERE oc.semester_id < 5
AND NOT EXISTS (
    SELECT 1 FROM GradeAttributeValues gav 
    WHERE gav.grade_id = g.grade_id AND gav.attribute_id = 6
);

-- Step 5: Insert Grade Attribute Values for current semester (only midterm)
INSERT INTO GradeAttributeValues (grade_id, attribute_id, value)
SELECT 
    g.grade_id,
    1, -- midterm
    CAST(10 + (RAND() * 10) AS DECIMAL(5,2))
FROM Grade g
JOIN Enrollment e ON g.enrollment_id = e.enrollment_id
JOIN Section s ON e.section_id = s.section_id
JOIN OfferedCourse oc ON s.offered_course_id = oc.offered_course_id
WHERE oc.semester_id = 5
AND NOT EXISTS (
    SELECT 1 FROM GradeAttributeValues gav 
    WHERE gav.grade_id = g.grade_id AND gav.attribute_id = 1
);

-- Cleanup Procedures
DROP PROCEDURE IF EXISTS OfferCoursesByCode;
DROP PROCEDURE IF EXISTS EnrollStudentInSemester;

SET FOREIGN_KEY_CHECKS = 1;

SELECT 'Data Insertion Complete' AS Status;
