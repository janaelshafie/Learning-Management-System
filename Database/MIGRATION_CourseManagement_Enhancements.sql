-- =================================================================
-- Migration Script: Course Management UI Enhancements
-- Purpose: Add file metadata fields to CourseMaterial table and
--          ensure required EAV attributes exist
-- =================================================================

USE university_lms_db;

-- =================================================================
-- 1. ENHANCE CourseMaterial TABLE
-- =================================================================
-- Add file metadata columns for better file management

-- Add file_name column (store original filename)
ALTER TABLE CourseMaterial
ADD COLUMN file_name VARCHAR(255) NULL AFTER title;

-- Add file_size column (store file size in bytes for quick access)
ALTER TABLE CourseMaterial
ADD COLUMN file_size BIGINT NULL AFTER file_name;

-- Add mime_type column (store MIME type for proper file serving)
ALTER TABLE CourseMaterial
ADD COLUMN mime_type VARCHAR(100) NULL AFTER file_size;

-- Expand type CHECK constraint to support specific file extensions
-- Note: MySQL doesn't support DROP CHECK directly, so we need to drop and recreate
-- This is optional - you can skip if you prefer using generic 'file' or 'document' types

-- First, drop the existing constraint (if possible)
-- ALTER TABLE CourseMaterial DROP CHECK coursematerial_chk_1;

-- For MySQL 8.0.19+, you can modify the check constraint
-- Otherwise, you may need to recreate the table or use a trigger for validation
-- For now, we'll add a comment and handle validation in application code

-- Add comment for documentation
ALTER TABLE CourseMaterial 
MODIFY COLUMN type VARCHAR(20) NOT NULL 
COMMENT 'File type: pdf, doc, docx, ppt, pptx, xls, xlsx, video, link, file, document, interactive';

-- =================================================================
-- 2. INSERT REQUIRED EAV ATTRIBUTES FOR ANNOUNCEMENT
-- =================================================================
-- Ensure these attributes exist in AnnouncementAttributes table

INSERT INTO AnnouncementAttributes (attribute_name, value_type) 
SELECT 'scope_type', 'text'
WHERE NOT EXISTS (
    SELECT 1 FROM AnnouncementAttributes WHERE attribute_name = 'scope_type'
);

INSERT INTO AnnouncementAttributes (attribute_name, value_type) 
SELECT 'offered_course_id', 'int'
WHERE NOT EXISTS (
    SELECT 1 FROM AnnouncementAttributes WHERE attribute_name = 'offered_course_id'
);

INSERT INTO AnnouncementAttributes (attribute_name, value_type) 
SELECT 'section_id', 'int'
WHERE NOT EXISTS (
    SELECT 1 FROM AnnouncementAttributes WHERE attribute_name = 'section_id'
);

INSERT INTO AnnouncementAttributes (attribute_name, value_type) 
SELECT 'announcement_type', 'text'
WHERE NOT EXISTS (
    SELECT 1 FROM AnnouncementAttributes WHERE attribute_name = 'announcement_type'
);

INSERT INTO AnnouncementAttributes (attribute_name, value_type) 
SELECT 'is_active', 'bool'
WHERE NOT EXISTS (
    SELECT 1 FROM AnnouncementAttributes WHERE attribute_name = 'is_active'
);

INSERT INTO AnnouncementAttributes (attribute_name, value_type) 
SELECT 'expires_at', 'datetime'
WHERE NOT EXISTS (
    SELECT 1 FROM AnnouncementAttributes WHERE attribute_name = 'expires_at'
);

INSERT INTO AnnouncementAttributes (attribute_name, value_type) 
SELECT 'priority', 'text'
WHERE NOT EXISTS (
    SELECT 1 FROM AnnouncementAttributes WHERE attribute_name = 'priority'
);

-- =================================================================
-- 3. INSERT REQUIRED EAV ATTRIBUTES FOR COURSE MATERIAL
-- =================================================================
-- Ensure these attributes exist in CourseMaterialAttributes table

INSERT INTO CourseMaterialAttributes (attribute_name, value_type) 
SELECT 'file_size', 'int'
WHERE NOT EXISTS (
    SELECT 1 FROM CourseMaterialAttributes WHERE attribute_name = 'file_size'
);

INSERT INTO CourseMaterialAttributes (attribute_name, value_type) 
SELECT 'download_count', 'int'
WHERE NOT EXISTS (
    SELECT 1 FROM CourseMaterialAttributes WHERE attribute_name = 'download_count'
);

INSERT INTO CourseMaterialAttributes (attribute_name, value_type) 
SELECT 'file_extension', 'text'
WHERE NOT EXISTS (
    SELECT 1 FROM CourseMaterialAttributes WHERE attribute_name = 'file_extension'
);

INSERT INTO CourseMaterialAttributes (attribute_name, value_type) 
SELECT 'description', 'text'
WHERE NOT EXISTS (
    SELECT 1 FROM CourseMaterialAttributes WHERE attribute_name = 'description'
);

INSERT INTO CourseMaterialAttributes (attribute_name, value_type) 
SELECT 'version', 'text'
WHERE NOT EXISTS (
    SELECT 1 FROM CourseMaterialAttributes WHERE attribute_name = 'version'
);

INSERT INTO CourseMaterialAttributes (attribute_name, value_type) 
SELECT 'tags_json', 'json'
WHERE NOT EXISTS (
    SELECT 1 FROM CourseMaterialAttributes WHERE attribute_name = 'tags_json'
);

-- =================================================================
-- 4. VERIFY ASSIGNMENT AND QUIZ EAV ATTRIBUTES (Optional)
-- =================================================================
-- These are likely already set up, but verify they exist

-- Common Assignment attributes
INSERT INTO AssignmentAttributes (attribute_name, value_type) 
SELECT 'late_submission_allowed', 'bool'
WHERE NOT EXISTS (
    SELECT 1 FROM AssignmentAttributes WHERE attribute_name = 'late_submission_allowed'
);

INSERT INTO AssignmentAttributes (attribute_name, value_type) 
SELECT 'late_penalty_percent', 'decimal'
WHERE NOT EXISTS (
    SELECT 1 FROM AssignmentAttributes WHERE attribute_name = 'late_penalty_percent'
);

INSERT INTO AssignmentAttributes (attribute_name, value_type) 
SELECT 'max_attempts', 'int'
WHERE NOT EXISTS (
    SELECT 1 FROM AssignmentAttributes WHERE attribute_name = 'max_attempts'
);

-- Common Quiz attributes
INSERT INTO QuizAttributes (attribute_name, value_type) 
SELECT 'time_limit_minutes', 'int'
WHERE NOT EXISTS (
    SELECT 1 FROM QuizAttributes WHERE attribute_name = 'time_limit_minutes'
);

INSERT INTO QuizAttributes (attribute_name, value_type) 
SELECT 'max_attempts', 'int'
WHERE NOT EXISTS (
    SELECT 1 FROM QuizAttributes WHERE attribute_name = 'max_attempts'
);

INSERT INTO QuizAttributes (attribute_name, value_type) 
SELECT 'randomize_questions', 'bool'
WHERE NOT EXISTS (
    SELECT 1 FROM QuizAttributes WHERE attribute_name = 'randomize_questions'
);

-- =================================================================
-- VERIFICATION QUERIES (Run these to verify the changes)
-- =================================================================

-- Check CourseMaterial table structure
DESCRIBE CourseMaterial;

-- Check AnnouncementAttributes
SELECT * FROM AnnouncementAttributes WHERE attribute_name IN (
    'scope_type', 'offered_course_id', 'section_id', 'announcement_type', 
    'is_active', 'expires_at', 'priority'
);

-- Check CourseMaterialAttributes
SELECT * FROM CourseMaterialAttributes WHERE attribute_name IN (
    'file_size', 'download_count', 'file_extension', 'description', 
    'version', 'tags_json'
);

-- =================================================================
-- ROLLBACK SCRIPT (If needed)
-- =================================================================

-- To rollback the CourseMaterial changes:
-- ALTER TABLE CourseMaterial DROP COLUMN file_name;
-- ALTER TABLE CourseMaterial DROP COLUMN file_size;
-- ALTER TABLE CourseMaterial DROP COLUMN mime_type;

-- Note: EAV attributes can remain as they don't interfere with existing functionality

