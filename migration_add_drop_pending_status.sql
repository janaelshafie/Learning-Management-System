-- Migration Script: Add 'drop_pending' status to Enrollment table
-- Run this script on your existing database to support drop request functionality
-- Date: 2025

USE university_lms_db;

-- Step 1: Modify the status column to allow longer values (to accommodate 'drop_pending')
ALTER TABLE Enrollment 
MODIFY COLUMN status VARCHAR(20) NOT NULL DEFAULT 'pending';

-- Step 2: Drop the existing CHECK constraint
-- Note: MySQL constraint names may vary. If this fails, check the actual constraint name with:
-- SHOW CREATE TABLE Enrollment;
-- Then use: ALTER TABLE Enrollment DROP CHECK <actual_constraint_name>;

-- For MySQL 8.0.19+, try dropping by constraint name pattern
-- If the constraint name is different, you may need to check with SHOW CREATE TABLE Enrollment
SET @constraint_name = (
    SELECT CONSTRAINT_NAME 
    FROM information_schema.TABLE_CONSTRAINTS 
    WHERE TABLE_SCHEMA = 'university_lms_db' 
    AND TABLE_NAME = 'Enrollment' 
    AND CONSTRAINT_TYPE = 'CHECK'
    LIMIT 1
);

SET @sql = IF(@constraint_name IS NOT NULL, 
    CONCAT('ALTER TABLE Enrollment DROP CHECK ', @constraint_name),
    'SELECT "No CHECK constraint found or already dropped" AS message'
);

PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Step 3: Add the new CHECK constraint with 'drop_pending' included
ALTER TABLE Enrollment 
ADD CONSTRAINT enrollment_status_check 
CHECK (status IN ('pending', 'approved', 'rejected', 'drop_pending'));




