package com.asu_lms.lms.Controllers;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.stream.Collectors;

import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.asu_lms.lms.Entities.Course;
import com.asu_lms.lms.Entities.Department;
import com.asu_lms.lms.Entities.Enrollment;
import com.asu_lms.lms.Entities.Grade;
import com.asu_lms.lms.Entities.OfferedCourse;
import com.asu_lms.lms.Entities.Section;
import com.asu_lms.lms.Entities.Semester;
import com.asu_lms.lms.Entities.Student;
import com.asu_lms.lms.Entities.User;
import com.asu_lms.lms.Repositories.CourseRepository;
import com.asu_lms.lms.Repositories.DepartmentRepository;
import com.asu_lms.lms.Repositories.EnrollmentRepository;
import com.asu_lms.lms.Repositories.GradeRepository;
import com.asu_lms.lms.Repositories.OfferedCourseRepository;
import com.asu_lms.lms.Repositories.SectionRepository;
import com.asu_lms.lms.Repositories.SemesterRepository;
import com.asu_lms.lms.Repositories.StudentRepository;
import com.asu_lms.lms.Repositories.UserRepository;
import com.asu_lms.lms.Services.EAVService;

@RestController
@RequestMapping("/api/parent")
@CrossOrigin(origins = "*")
public class ParentController {

    private final StudentRepository studentRepository;
    private final UserRepository userRepository;
    private final EnrollmentRepository enrollmentRepository;
    private final SectionRepository sectionRepository;
    private final OfferedCourseRepository offeredCourseRepository;
    private final CourseRepository courseRepository;
    private final SemesterRepository semesterRepository;
    private final GradeRepository gradeRepository;
    private final DepartmentRepository departmentRepository;
    private final EAVService eavService;

    public ParentController(
            StudentRepository studentRepository,
            UserRepository userRepository,
            EnrollmentRepository enrollmentRepository,
            SectionRepository sectionRepository,
            OfferedCourseRepository offeredCourseRepository,
            CourseRepository courseRepository,
            SemesterRepository semesterRepository,
            GradeRepository gradeRepository,
            DepartmentRepository departmentRepository,
            EAVService eavService
    ) {
        this.studentRepository = studentRepository;
        this.userRepository = userRepository;
        this.enrollmentRepository = enrollmentRepository;
        this.sectionRepository = sectionRepository;
        this.offeredCourseRepository = offeredCourseRepository;
        this.courseRepository = courseRepository;
        this.semesterRepository = semesterRepository;
        this.gradeRepository = gradeRepository;
        this.departmentRepository = departmentRepository;
        this.eavService = eavService;
    }

    /**
     * Get all students for a parent
     */
    @GetMapping("/{parentId}/students")
    public Map<String, Object> getParentStudents(@PathVariable Integer parentId) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            // Verify parent exists
            Optional<User> parentOpt = userRepository.findById(parentId);
            if (parentOpt.isEmpty() || !"parent".equals(parentOpt.get().getRole())) {
                response.put("status", "error");
                response.put("message", "Parent not found");
                return response;
            }
            
            // Get all students linked to this parent
            List<Student> students = studentRepository.findByParentUserId(parentId);
            
            List<Map<String, Object>> studentList = new ArrayList<>();
            for (Student student : students) {
                Optional<User> studentUserOpt = userRepository.findById(student.getStudentId());
                if (studentUserOpt.isEmpty()) continue;
                
                User studentUser = studentUserOpt.get();
                Map<String, Object> studentData = new HashMap<>();
                studentData.put("studentId", student.getStudentId());
                studentData.put("name", studentUser.getName());
                studentData.put("email", studentUser.getEmail());
                studentData.put("officialMail", studentUser.getOfficialMail());
                studentData.put("studentUid", student.getStudentUid());
                studentData.put("cumulativeGpa", student.getCumulativeGpa() != null ? student.getCumulativeGpa().doubleValue() : 0.0);
                
                // Add department information
                if (student.getDepartmentId() != null) {
                    Optional<Department> departmentOpt = departmentRepository.findById(student.getDepartmentId());
                    if (departmentOpt.isPresent()) {
                        studentData.put("departmentName", departmentOpt.get().getName());
                    } else {
                        studentData.put("departmentName", "Unknown Department");
                    }
                } else {
                    studentData.put("departmentName", "No Department");
                }
                
                studentList.add(studentData);
            }
            
            response.put("status", "success");
            response.put("students", studentList);
            response.put("count", studentList.size());
            
        } catch (Exception e) {
            response.put("status", "error");
            response.put("message", "Error fetching students: " + e.getMessage());
        }
        
        return response;
    }

    /**
     * Get academic records for a specific student (all courses with grades)
     */
    @GetMapping("/student/{studentId}/academic-records")
    public Map<String, Object> getStudentAcademicRecords(@PathVariable Integer studentId) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            // Get student record
            Optional<Student> studentOpt = studentRepository.findByStudentId(studentId);
            if (studentOpt.isEmpty()) {
                response.put("status", "error");
                response.put("message", "Student not found");
                return response;
            }
            
            Student student = studentOpt.get();
            
            // Get all enrollments for this student (only approved with grades)
            List<Enrollment> allEnrollments = enrollmentRepository.findByStudentId(studentId);
            List<Enrollment> enrollments = allEnrollments.stream()
                    .filter(e -> {
                        String status = eavService.getEnrollmentStatus(e.getEnrollmentId());
                        return "approved".equals(status);
                    })
                    .collect(Collectors.toList());
            
            List<Map<String, Object>> courses = new ArrayList<>();
            
            for (Enrollment enrollment : enrollments) {
                // Get section details
                Optional<Section> sectionOpt = sectionRepository.findBySectionId(enrollment.getSectionId());
                if (!sectionOpt.isPresent()) continue;
                
                Section section = sectionOpt.get();
                
                // Get offered course details
                Optional<OfferedCourse> offeredCourseOpt = offeredCourseRepository.findByOfferedCourseId(section.getOfferedCourseId());
                if (!offeredCourseOpt.isPresent()) continue;
                
                OfferedCourse offeredCourse = offeredCourseOpt.get();
                
                // Get course details
                Optional<Course> courseOpt = courseRepository.findById(offeredCourse.getCourseId());
                if (!courseOpt.isPresent()) continue;
                
                Course course = courseOpt.get();
                
                // Get semester details
                Optional<Semester> semesterOpt = semesterRepository.findById(offeredCourse.getSemesterId());
                String semesterName = "Unknown Semester";
                String semesterStartDate = null;
                String semesterEndDate = null;
                
                if (semesterOpt.isPresent()) {
                    Semester semester = semesterOpt.get();
                    semesterName = semester.getName();
                    semesterStartDate = semester.getStartDate() != null ? semester.getStartDate().toString() : null;
                    semesterEndDate = semester.getEndDate() != null ? semester.getEndDate().toString() : null;
                }
                
                // Get grade for this enrollment
                Optional<Grade> gradeOpt = gradeRepository.findByEnrollmentId(enrollment.getEnrollmentId());
                
                Map<String, Object> courseData = new HashMap<>();
                courseData.put("code", course.getCourseCode());
                courseData.put("name", course.getTitle());
                courseData.put("credits", course.getCredits());
                courseData.put("semester", semesterName);
                courseData.put("semesterStartDate", semesterStartDate);
                courseData.put("semesterEndDate", semesterEndDate);
                courseData.put("section", section.getSectionNumber());
                
                if (gradeOpt.isPresent()) {
                    Grade grade = gradeOpt.get();
                    String letterGrade = grade.getFinalLetterGrade();
                    courseData.put("grade", letterGrade != null ? letterGrade : "N/A");
                    
                    // Add detailed marks from EAV
                    Map<String, String> gradeAttributes = eavService.getGradeAttributes(grade.getGradeId());
                    Map<String, Object> marks = new HashMap<>();
                    marks.put("midterm", gradeAttributes.get("midterm"));
                    marks.put("project", gradeAttributes.get("project"));
                    marks.put("assignments_total", gradeAttributes.get("assignments_total"));
                    marks.put("quizzes_total", gradeAttributes.get("quizzes_total"));
                    marks.put("attendance", gradeAttributes.get("attendance"));
                    marks.put("final_exam_mark", gradeAttributes.get("final_exam_mark"));
                    marks.put("final_letter_grade", letterGrade);
                    courseData.put("marks", marks);
                } else {
                    courseData.put("grade", "N/A");
                    courseData.put("marks", new HashMap<>());
                }
                
                courses.add(courseData);
            }
            
            // Sort by semester (most recent first)
            courses.sort((a, b) -> {
                String semesterA = (String) a.get("semester");
                String semesterB = (String) b.get("semester");
                if (semesterA == null) semesterA = "";
                if (semesterB == null) semesterB = "";
                return semesterB.compareTo(semesterA);
            });
            
            Map<String, Object> studentData = new HashMap<>();
            studentData.put("courses", courses);
            studentData.put("cumulativeGpa", student.getCumulativeGpa() != null ? student.getCumulativeGpa().doubleValue() : 0.0);
            
            response.put("status", "success");
            response.put("data", studentData);
            
        } catch (Exception e) {
            response.put("status", "error");
            response.put("message", "Error fetching academic records: " + e.getMessage());
        }
        
        return response;
    }

    /**
     * Get current semester courses for a specific student
     */
    @GetMapping("/student/{studentId}/current-courses")
    public Map<String, Object> getStudentCurrentCourses(@PathVariable Integer studentId) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            // Get student record
            Optional<Student> studentOpt = studentRepository.findByStudentId(studentId);
            if (studentOpt.isEmpty()) {
                response.put("status", "error");
                response.put("message", "Student not found");
                return response;
            }
            
            // Find current semester
            LocalDate today = LocalDate.now();
            Semester currentSemester = findCurrentSemester(today);
            
            if (currentSemester == null) {
                response.put("status", "success");
                response.put("message", "No active semester at this time.");
                response.put("courses", Collections.emptyList());
                response.put("currentSemester", null);
                return response;
            }
            
            // Get enrollments for current semester
            List<Enrollment> allEnrollments = enrollmentRepository.findByStudentId(studentId);
            List<Enrollment> enrollments = allEnrollments.stream()
                    .filter(e -> {
                        String status = eavService.getEnrollmentStatus(e.getEnrollmentId());
                        return "approved".equals(status) || "pending".equals(status) || "drop_pending".equals(status);
                    })
                    .collect(Collectors.toList());
            
            List<Map<String, Object>> courses = new ArrayList<>();
            
            for (Enrollment enrollment : enrollments) {
                Optional<Section> sectionOpt = sectionRepository.findBySectionId(enrollment.getSectionId());
                if (!sectionOpt.isPresent()) continue;
                
                Section section = sectionOpt.get();
                
                Optional<OfferedCourse> offeredCourseOpt = offeredCourseRepository.findByOfferedCourseId(section.getOfferedCourseId());
                if (!offeredCourseOpt.isPresent()) continue;
                
                OfferedCourse offeredCourse = offeredCourseOpt.get();
                
                // Only include courses from current semester
                if (!offeredCourse.getSemesterId().equals(currentSemester.getSemesterId())) {
                    continue;
                }
                
                Optional<Course> courseOpt = courseRepository.findById(offeredCourse.getCourseId());
                if (!courseOpt.isPresent()) continue;
                
                Course course = courseOpt.get();
                String enrollmentStatus = eavService.getEnrollmentStatus(enrollment.getEnrollmentId());
                
                Map<String, Object> courseData = new HashMap<>();
                courseData.put("courseId", course.getCourseId());
                courseData.put("courseCode", course.getCourseCode());
                courseData.put("courseTitle", course.getTitle());
                courseData.put("credits", course.getCredits());
                courseData.put("sectionId", section.getSectionId());
                courseData.put("sectionNumber", section.getSectionNumber());
                courseData.put("enrollmentStatus", enrollmentStatus);
                courseData.put("semester", currentSemester.getName());
                
                // Get grade if available
                Optional<Grade> gradeOpt = gradeRepository.findByEnrollmentId(enrollment.getEnrollmentId());
                if (gradeOpt.isPresent()) {
                    Grade grade = gradeOpt.get();
                    String letterGrade = grade.getFinalLetterGrade();
                    courseData.put("grade", letterGrade != null ? letterGrade : "N/A");
                } else {
                    courseData.put("grade", "N/A");
                }
                
                courses.add(courseData);
            }
            
            Map<String, Object> semesterInfo = new HashMap<>();
            semesterInfo.put("semesterId", currentSemester.getSemesterId());
            semesterInfo.put("name", currentSemester.getName());
            semesterInfo.put("startDate", currentSemester.getStartDate() != null ? currentSemester.getStartDate().toString() : null);
            semesterInfo.put("endDate", currentSemester.getEndDate() != null ? currentSemester.getEndDate().toString() : null);
            
            response.put("status", "success");
            response.put("courses", courses);
            response.put("currentSemester", semesterInfo);
            response.put("count", courses.size());
            
        } catch (Exception e) {
            response.put("status", "error");
            response.put("message", "Error fetching current courses: " + e.getMessage());
        }
        
        return response;
    }

    /**
     * Helper method to find current semester
     */
    private Semester findCurrentSemester(LocalDate date) {
        List<Semester> allSemesters = semesterRepository.findAll();
        for (Semester semester : allSemesters) {
            if (isWithinSemester(semester, date)) {
                return semester;
            }
        }
        return null;
    }

    /**
     * Helper method to check if a date is within a semester
     */
    private boolean isWithinSemester(Semester semester, LocalDate date) {
        if (semester.getStartDate() == null || semester.getEndDate() == null) {
            return false;
        }

        LocalDate start = semester.getStartDate().toLocalDate();
        LocalDate end = semester.getEndDate().toLocalDate();

        return (date.isEqual(start) || date.isAfter(start)) &&
                (date.isEqual(end) || date.isBefore(end));
    }
}
