# Database Migration Guide

## Summary of Changes

The following features have been implemented:

### ✅ Feature 1 — Course Catalog Management
- ✅ Create courses (with optional course_type)
- ✅ Edit courses (with optional course_type)
- ✅ Delete courses
- ✅ View all courses
- ✅ Search for a course (by title)
- ✅ Categorize courses as Core or Elective

### ✅ Feature 2 — Core Courses Management
- ✅ Define core courses (via DepartmentCourse table)
- ✅ Link core courses to departments
- ✅ Display core courses to students (via API endpoints)

### ✅ Feature 3 — Elective Courses Management
- ✅ Define elective courses (via DepartmentCourse table)
- ✅ Display elective courses available to students (via API endpoints)
- ✅ Add optional properties (capacity, eligibility requirements)

### ✅ Feature 4 — Prerequisite System
- ✅ Add prerequisites
- ✅ Edit prerequisites (add/remove)
- ✅ Prevent circular dependencies (with DFS algorithm)

### ✅ Feature 5 — Department–Course Relationships
- ✅ Link courses to departments
- ✅ Each department defines its own core and elective courses

## Database Changes Required

You need to run the following SQL commands on your MySQL database:

```sql
-- 1. Add course_type column to Course table
ALTER TABLE Course 
ADD COLUMN course_type VARCHAR(10) CHECK (course_type IN ('core', 'elective'));

-- 2. Add check constraint to Prerequisite table to prevent self-reference
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
```

## New API Endpoints

### Prerequisite Management
- `GET /api/admin/courses/{courseId}/prerequisites` - Get all prerequisites for a course
- `POST /api/admin/courses/prerequisites/add` - Add a prerequisite
- `POST /api/admin/courses/prerequisites/remove` - Remove a prerequisite

### Department-Course Relationships
- `POST /api/admin/courses/departments/link` - Link course to department (as core/elective)
- `POST /api/admin/courses/departments/update-link` - Update department-course link
- `POST /api/admin/courses/departments/unlink` - Unlink course from department
- `GET /api/admin/courses/departments/{departmentId}/courses` - Get all courses for a department
- `GET /api/admin/courses/departments/{departmentId}/core-courses` - Get core courses for a department
- `GET /api/admin/courses/departments/{departmentId}/elective-courses` - Get elective courses for a department

### Updated Endpoints
- `GET /api/admin/departments/courses/all?search={query}&courseType={type}` - Search courses with optional filters
- `POST /api/admin/departments/courses/create` - Now accepts optional `courseType` parameter
- `POST /api/admin/departments/courses/update` - Now accepts optional `courseType` parameter

## Example API Requests

### Create a course with type
```json
POST /api/admin/departments/courses/create
{
  "courseCode": "CSE401",
  "title": "Advanced Software Engineering",
  "description": "Advanced topics in software engineering",
  "credits": "3",
  "courseType": "core"
}
```

### Link course to department as core
```json
POST /api/admin/courses/departments/link
{
  "departmentId": "1",
  "courseId": "10",
  "courseType": "core",
  "capacity": "40",
  "eligibilityRequirements": "Must have completed CSE331"
}
```

### Add prerequisite
```json
POST /api/admin/courses/prerequisites/add
{
  "courseId": "10",
  "prereqCourseId": "5"
}
```

## Notes

- The `course_type` field in the `Course` table is optional and can be null for general courses
- The `DepartmentCourse` table stores department-specific course relationships with type (core/elective)
- Prerequisites are validated to prevent circular dependencies (e.g., A → B → C → A)
- Self-referencing prerequisites are prevented (a course cannot be a prerequisite of itself)






