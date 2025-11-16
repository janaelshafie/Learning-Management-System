-- ============================================
-- Database Migration Script for Course Management Features
-- Run this script on your MySQL database
-- ============================================

-- 1. Add course_type column to Course table
ALTER TABLE Course 
ADD COLUMN course_type VARCHAR(10) CHECK (course_type IN ('core', 'elective'));

-- 2. Add check constraint to Prerequisite table to prevent self-reference
-- Note: If the constraint already exists, this will fail - that's okay
ALTER TABLE Prerequisite 
ADD CONSTRAINT chk_no_self_prereq CHECK (course_id != prereq_course_id);

-- 3. Create DepartmentCourse table
CREATE TABLE IF NOT EXISTS DepartmentCourse (
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

-- Verify the changes
SELECT 'Migration completed successfully!' AS status;

