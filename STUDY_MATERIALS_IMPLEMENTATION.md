# Study Materials Implementation

## Overview
Implemented the Study Materials feature for students to view their current courses, course announcements, and course materials.

## Files Modified/Created

### 1. `lib/screens/student/study_materials_screen.dart` (NEW)
- Created new screen for study materials
- Contains two tabs: Announcements and Course Materials
- Displays current semester courses
- Allows students to click on a course to view its materials

### 2. `lib/screens/student/student_dashboard_screen.dart` (MODIFIED)
- Added "Study Materials" navigation item in sidebar
- Added Study Materials quick access card in dashboard
- Added `_buildStudyMaterials()` method
- Updated navigation indices for all tabs

### 3. `lib/services/api_services.dart` (MODIFIED)
- Added `getCourseAnnouncements()` method
- Added `getCourseMaterials()` method  
- Added `getOfferedCourseId()` method

### 4. `pubspec.yaml` (MODIFIED)
- Added `url_launcher: ^6.3.0` dependency

## Features Implemented

### Study Materials Main Screen
- Lists all current semester courses
- Each course card shows:
  - Course code
  - Course name
  - Instructor name
  - Click to navigate to course details

### Course Materials Screen (Tabbed)
**Announcements Tab:**
- Displays course-specific announcements
- Shows announcement title, content, and date
- Empty state if no announcements

**Course Materials Tab:**
- Displays uploaded course materials
- Shows material type (PDF, Link, File)
- Material title and upload date
- Download button for each material
- Empty state if no materials uploaded

### Backend API Endpoints Required
The following backend endpoints need to be implemented:

1. `GET /api/course/announcements/{offeredCourseId}`
   - Returns announcements for a specific course

2. `GET /api/course/materials/{offeredCourseId}`
   - Returns materials for a specific course

3. `POST /api/course/offered-course-id`
   - Body: `{ "courseId": int, "semesterId": int }`
   - Returns the offered course ID for a course and semester

## How to Use

1. Student logs in and navigates to "Study Materials" in the sidebar or clicks the "Study Materials" card in the dashboard
2. Student sees list of current courses
3. Student clicks on a course to view:
   - Announcements from the instructor
   - Course materials (PDFs, links, files)
4. Student can click download button to open materials in external browser/app

## Empty State Handling
- If no courses for current semester: Shows "No courses for current semester"
- If no announcements: Shows "No announcements yet"
- If no materials: Shows "No course materials uploaded yet"

## Material Types Supported
- **PDF**: Red PDF icon
- **Link**: Blue link icon  
- **File**: Grey document icon

## Notes
- All data is fetched from the database via API calls
- Empty states are handled gracefully
- Materials open in external browser/app using `url_launcher`
- The implementation assumes backend APIs are available
