package com.asu_lms.lms.Controllers;

import com.asu_lms.lms.Services.AuthService;
import com.asu_lms.lms.Services.EAVService;
import com.asu_lms.lms.Repositories.*;
import com.asu_lms.lms.Entities.*;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.Mockito;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;


import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

import java.math.BigDecimal;
import java.sql.Date;
import java.time.LocalDate;
import java.util.*;

import static org.hamcrest.Matchers.*;
import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@WebMvcTest(ParentController.class)
class ParentControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ParentController parentController;

    // All repositories needed for ParentController
    @Autowired
    private StudentRepository studentRepository;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private EnrollmentRepository enrollmentRepository;

    @Autowired
    private SectionRepository sectionRepository;

    @Autowired
    private OfferedCourseRepository offeredCourseRepository;

    @Autowired
    private CourseRepository courseRepository;

    @Autowired
    private SemesterRepository semesterRepository;

    @Autowired
    private GradeRepository gradeRepository;

    @Autowired
    private DepartmentRepository departmentRepository;

    @Autowired
    private EAVService eavService;

    // Test data setup
    private User parentUser;
    private Student testStudent;
    private Department testDepartment;
    private Semester currentSemester;

    @BeforeEach
    void setUp() {
        // Setup test parent user
        parentUser = new User();
        parentUser.setUserId(1);
        parentUser.setRole("parent");
        parentUser.setName("Test Parent");

        // Setup test student
        testStudent = new Student();
        testStudent.setStudentId(100);
        testStudent.setStudentUid("STU001");
        testStudent.setCumulativeGpa(BigDecimal.valueOf(3.5));
        testStudent.setDepartmentId(1);
        testStudent.setParentUserId(1);

        // Setup test department
        testDepartment = new Department();
        testDepartment.setDepartmentId(1);
        testDepartment.setName("Computer Science");

        // Setup current semester
        currentSemester = new Semester();
        currentSemester.setSemesterId(1);
        currentSemester.setName("Fall 2025");
        // Fix for currentSemester setup in @BeforeEach
        currentSemester.setStartDate(Date.valueOf(LocalDate.of(2025, 8, 25)));
        currentSemester.setEndDate(Date.valueOf(LocalDate.of(2025, 12, 20)));

    }

    @Test
    void testGetParentStudents_SuccessWithStudents() throws Exception {
        // Arrange
        Integer parentId = 1;
        when(userRepository.findById(parentId)).thenReturn(Optional.of(parentUser));
        when(studentRepository.findByParentUserId(parentId)).thenReturn(List.of(testStudent));

        User studentUser = new User();
        studentUser.setUserId(100);
        studentUser.setName("John Doe");
        studentUser.setEmail("john@example.com");
        studentUser.setOfficialMail("john@asu.edu.eg");

        when(userRepository.findById(100)).thenReturn(Optional.of(studentUser));
        when(departmentRepository.findById(1)).thenReturn(Optional.of(testDepartment));

        // Act & Assert
        mockMvc.perform(get("/api/parent/{parentId}/students", parentId))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.status").value("success"))
                .andExpect(jsonPath("$.count").value(1))
                .andExpect(jsonPath("$.students[0].studentId").value(100))
                .andExpect(jsonPath("$.students[0].name").value("John Doe"))
                .andExpect(jsonPath("$.students[0].email").value("john@example.com"))
                .andExpect(jsonPath("$.students[0].officialMail").value("john@asu.edu.eg"))
                .andExpect(jsonPath("$.students[0].studentUid").value("STU001"))
                .andExpect(jsonPath("$.students[0].cumulativeGpa").value(3.5))
                .andExpect(jsonPath("$.students[0].departmentName").value("Computer Science"));
    }

    @Test
    void testGetParentStudents_ParentNotFound() throws Exception {
        // Arrange
        Integer parentId = 999;
        when(userRepository.findById(parentId)).thenReturn(Optional.empty());

        // Act & Assert
        mockMvc.perform(get("/api/parent/{parentId}/students", parentId))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.status").value("error"))
                .andExpect(jsonPath("$.message").value("Parent not found"));
    }

    @Test
    void testGetParentStudents_WrongRole() throws Exception {
        // Arrange
        Integer parentId = 2;
        User studentUser = new User();
        studentUser.setUserId(2);
        studentUser.setRole("student"); // Wrong role

        when(userRepository.findById(parentId)).thenReturn(Optional.of(studentUser));

        // Act & Assert
        mockMvc.perform(get("/api/parent/{parentId}/students", parentId))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.status").value("error"))
                .andExpect(jsonPath("$.message").value("Parent not found"));
    }

    @Test
    void testGetParentStudents_NoStudents() throws Exception {
        // Arrange
        Integer parentId = 1;
        when(userRepository.findById(parentId)).thenReturn(Optional.of(parentUser));
        when(studentRepository.findByParentUserId(parentId)).thenReturn(Collections.emptyList());

        // Act & Assert
        mockMvc.perform(get("/api/parent/{parentId}/students", parentId))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.status").value("success"))
                .andExpect(jsonPath("$.count").value(0))
                .andExpect(jsonPath("$.students").isArray())
                .andExpect(jsonPath("$.students.length()").value(0));
    }

    @Test
    void testGetParentStudents_StudentUserNotFound() throws Exception {
        // Arrange
        Integer parentId = 1;
        when(userRepository.findById(parentId)).thenReturn(Optional.of(parentUser));
        when(studentRepository.findByParentUserId(parentId)).thenReturn(List.of(testStudent));
        when(userRepository.findById(100)).thenReturn(Optional.empty()); // Student user not found

        // Act & Assert
        mockMvc.perform(get("/api/parent/{parentId}/students", parentId))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.status").value("success"))
                .andExpect(jsonPath("$.count").value(0)); // No students in response
    }

    @Test
    void testGetParentStudents_DepartmentNotFound() throws Exception {
        // Arrange
        Integer parentId = 1;
        when(userRepository.findById(parentId)).thenReturn(Optional.of(parentUser));
        when(studentRepository.findByParentUserId(parentId)).thenReturn(List.of(testStudent));

        User studentUser = new User();
        studentUser.setUserId(100);
        studentUser.setName("John Doe");
        studentUser.setEmail("john@example.com");

        when(userRepository.findById(100)).thenReturn(Optional.of(studentUser));
        when(departmentRepository.findById(1)).thenReturn(Optional.empty()); // Department not found

        // Act & Assert
        mockMvc.perform(get("/api/parent/{parentId}/students", parentId))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.status").value("success"))
                .andExpect(jsonPath("$.count").value(1))
                .andExpect(jsonPath("$.students[0].departmentName").value("Unknown Department"));
    }

    @Test
    void testGetParentStudents_NoDepartment() throws Exception {
        // Arrange
        Student studentNoDept = new Student();
        studentNoDept.setStudentId(101);
        studentNoDept.setStudentUid("STU002");
        studentNoDept.setCumulativeGpa(BigDecimal.valueOf(3.8));
        studentNoDept.setDepartmentId(null); // No department
        studentNoDept.setParentUserId(1);

        when(userRepository.findById(1)).thenReturn(Optional.of(parentUser));
        when(studentRepository.findByParentUserId(1)).thenReturn(List.of(studentNoDept));

        User studentUser = new User();
        studentUser.setUserId(101);
        studentUser.setName("Jane Doe");

        when(userRepository.findById(101)).thenReturn(Optional.of(studentUser));

        // Act & Assert
        mockMvc.perform(get("/api/parent/{parentId}/students", 1))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.status").value("success"))
                .andExpect(jsonPath("$.count").value(1))
                .andExpect(jsonPath("$.students[0].departmentName").value("No Department"));
    }

    @Test
    void testGetParentStudents_ExceptionHandling() throws Exception {
        // Arrange
        Integer parentId = 1;
        when(userRepository.findById(parentId)).thenThrow(new RuntimeException("Database error"));

        // Act & Assert
        mockMvc.perform(get("/api/parent/{parentId}/students", parentId))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.status").value("error"))
                .andExpect(jsonPath("$.message").value("Error fetching students: Database error"));
    }

    @Test
    void testGetParentStudents_MultipleStudents() throws Exception {
        // Arrange
        Integer parentId = 1;
        Student student2 = new Student();
        student2.setStudentId(101);
        student2.setStudentUid("STU002");
        student2.setCumulativeGpa(BigDecimal.valueOf(3.2));
        student2.setDepartmentId(2);
        student2.setParentUserId(1);

        when(userRepository.findById(parentId)).thenReturn(Optional.of(parentUser));
        when(studentRepository.findByParentUserId(parentId)).thenReturn(List.of(testStudent, student2));

        User student1User = new User();
        student1User.setUserId(100);
        student1User.setName("John Doe");
        when(userRepository.findById(100)).thenReturn(Optional.of(student1User));

        User student2User = new User();
        student2User.setUserId(101);
        student2User.setName("Jane Doe");
        when(userRepository.findById(101)).thenReturn(Optional.of(student2User));

        when(departmentRepository.findById(1)).thenReturn(Optional.of(testDepartment));

        // Act & Assert
        mockMvc.perform(get("/api/parent/{parentId}/students", parentId))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.status").value("success"))
                .andExpect(jsonPath("$.count").value(2))
                .andExpect(jsonPath("$.students.length()").value(2));
    }

    @Test
    void TestGetstudentrecordsNotfound() throws Exception {
        Integer parentId = 1;
        Integer studentId = 999;

        when(userRepository.findById(parentId)).thenReturn(Optional.of(parentUser));
        when(studentRepository.findByParentUserId(parentId)).thenReturn(List.of(testStudent));

        when(userRepository.findById(studentId)).thenReturn(Optional.empty());

        mockMvc.perform(get("/api/parent/{parentId}/students", studentId))
                .andExpect(jsonPath("$.status").value("error"))
                .andExpect(jsonPath("$.message").value("Student not found"));

    }

    private List<Enrollment> createTestEnrollments(int count, Integer studentId) {
        List<Enrollment> enrollments = new ArrayList<>();
        for (int i = 0; i < count; i++) {
            Enrollment enrollment = new Enrollment();
            enrollment.setEnrollmentId(i + 1);
            enrollment.setStudentId(studentId);
            enrollment.setSectionId(i + 1);
            enrollments.add(enrollment);
        }
        return enrollments;
    }

    private List<Enrollment> createCurrentSemesterEnrollments(int count, Integer studentId) {
        List<Enrollment> enrollments = new ArrayList<>();
        for (int i = 0; i < count; i++) {
            Enrollment enrollment = new Enrollment();
            enrollment.setEnrollmentId(i + 1);
            enrollment.setStudentId(studentId);
            enrollment.setSectionId(i + 1);
            enrollments.add(enrollment);
        }
        return enrollments;
    }

    @Test
    void testUnknownSemesterEnrollment() throws Exception {
        // Arrange
        Integer studentId = 100;
        when(studentRepository.findByStudentId(studentId)).thenReturn(Optional.of(testStudent));

        // Create enrollment with unknown semester
        Enrollment enrollment = new Enrollment();
        enrollment.setEnrollmentId(1);
        enrollment.setStudentId(100);
        enrollment.setSectionId(1);

        when(enrollmentRepository.findByStudentId(studentId)).thenReturn(List.of(enrollment));
        when(eavService.getEnrollmentStatus(1)).thenReturn("approved"); // Approved enrollment

        Section testSection = new Section();
        testSection.setSectionId(1);
        OfferedCourse testOfferedCourse = new OfferedCourse();
        testOfferedCourse.setOfferedCourseId(1);
        Course testCourse = new Course();
        testCourse.setCourseId(1);
        // Section chain

        when(sectionRepository.findBySectionId(1)).thenReturn(Optional.of(testSection));
        when(offeredCourseRepository.findByOfferedCourseId(1)).thenReturn(Optional.of(testOfferedCourse));
        when(courseRepository.findById(1)).thenReturn(Optional.of(testCourse));

        // UNKNOWN SEMESTER - key test case
        Integer unknownSemesterId = 999;
        testOfferedCourse.setSemesterId(unknownSemesterId); // Set to unknown semester
        when(semesterRepository.findById(unknownSemesterId)).thenReturn(Optional.empty());

        // Act & Assert - testing /academic-records endpoint
        mockMvc.perform(get("/api/parent/student/{studentId}/academic-records", studentId))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.status").value("success"))
                .andExpect(jsonPath("$.data.courses.length()").value(1))
                .andExpect(jsonPath("$.data.courses[0].semester").value("Unknown Semester")) // ✅ Test passes
                .andExpect(jsonPath("$.data.courses[0].semesterStartDate").isEmpty())
                .andExpect(jsonPath("$.data.courses[0].semesterEndDate").isEmpty());
    }

    @Test
    void testSuccessEnrollment() throws Exception {
        // Arrange
        Integer studentId = 100;
        Integer enrollmentId = 1;
        Integer parentId = 1;

        // Setup entities
        Enrollment enrollment = new Enrollment();
        enrollment.setEnrollmentId(enrollmentId);
        enrollment.setStudentId(studentId);
        enrollment.setSectionId(1);

        Student student = new Student();
        student.setStudentId(studentId);
        student.setParentUserId(parentId);
        student.setCumulativeGpa(BigDecimal.valueOf(3.8));
        student.setStudentUid("STU001");
        student.setDepartmentId(1);

        parentUser.setUserId(parentId); // Fix: use setId() not setUserId()
        parentUser.setRole("parent");

        Section section = new Section();
        section.setSectionId(1);
        OfferedCourse offeredCourse = new OfferedCourse();
        offeredCourse.setOfferedCourseId(1);
        Course course = new Course();
        course.setCourseId(1);
        Grade testGrade = new Grade();
        testGrade.setFinalLetterGrade("A");
        testGrade.setGradeId(1);

        // Mock repository calls
        when(studentRepository.findByStudentId(studentId)).thenReturn(Optional.of(student));
        when(enrollmentRepository.findByStudentId(studentId)).thenReturn(List.of(enrollment));
        when(eavService.getEnrollmentStatus(enrollmentId)).thenReturn("approved");

        // Complete entity chain for academic records
        when(sectionRepository.findBySectionId(1)).thenReturn(Optional.of(section));
        when(offeredCourseRepository.findByOfferedCourseId(1)).thenReturn(Optional.of(offeredCourse));
        when(courseRepository.findById(1)).thenReturn(Optional.of(course));
        when(semesterRepository.findById(1)).thenReturn(Optional.of(currentSemester));

        // Grade with EAV attributes
        when(gradeRepository.findByEnrollmentId(enrollmentId)).thenReturn(Optional.of(testGrade));
        when(eavService.getGradeAttributes(1)).thenReturn(Map.of(
                "midterm", "25.0",
                "project", "20.0",
                "assignments_total", "15.0",
                "quizzes_total", "10.0",
                "attendance", "8.0",
                "final_exam_mark", "40.0"
        ));

        // Act & Assert - Test academic-records endpoint
        mockMvc.perform(get("/api/parent/student/{studentId}/academic-records", studentId))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.status").value("success"))
                .andExpect(jsonPath("$.data.courses.length()").value(1))
                .andExpect(jsonPath("$.data.courses[0].code").value("CS101"))
                .andExpect(jsonPath("$.data.courses[0].name").value("Introduction to Programming"))
                .andExpect(jsonPath("$.data.courses[0].credits").value(3))
                .andExpect(jsonPath("$.data.courses[0].semester").value("Fall 2025"))
                .andExpect(jsonPath("$.data.courses[0].grade").value("A"))
                .andExpect(jsonPath("$.data.courses[0].marks.midterm").value("25.0"))
                .andExpect(jsonPath("$.data.cumulativeGpa").value(3.8))
                .andExpect(jsonPath("$.data.courses[0].section").value("01"));
    }



    @Test
    void testGetStudentCurrentCourses_SuccessWithCurrentSemesterCourses() throws Exception {
        // Arrange
        Integer studentId = 100;
        when(studentRepository.findByStudentId(studentId)).thenReturn(Optional.of(testStudent));

        // Mock findAll to return current semester (Dec 20, 2025 is within dates)
        when(semesterRepository.findAll()).thenReturn(List.of(currentSemester));

        // Create current semester enrollment
        Enrollment currentEnrollment = new Enrollment();
        currentEnrollment.setEnrollmentId(1);
        currentEnrollment.setStudentId(100);
        currentEnrollment.setSectionId(1);
        Section testSection = new Section();
        testSection.setSectionId(1);
        OfferedCourse testOfferedCourse = new OfferedCourse();
        testOfferedCourse.setOfferedCourseId(1);
        Course testCourse = new Course();
        testCourse.setCourseId(1);


        when(enrollmentRepository.findByStudentId(studentId)).thenReturn(List.of(currentEnrollment));
        when(eavService.getEnrollmentStatus(1)).thenReturn("approved");

        // Complete entity chain for current semester
        when(sectionRepository.findBySectionId(1)).thenReturn(Optional.of(testSection));
        when(offeredCourseRepository.findByOfferedCourseId(1)).thenReturn(Optional.of(testOfferedCourse));
        when(courseRepository.findById(1)).thenReturn(Optional.of(testCourse));

        // Grade (optional)
        when(gradeRepository.findByEnrollmentId(1)).thenReturn(Optional.empty());

        // Act & Assert
        mockMvc.perform(get("/api/parent/student/{studentId}/current-courses", studentId))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.status").value("success"))
                .andExpect(jsonPath("$.count").value(1))
                .andExpect(jsonPath("$.courses[0].courseCode").value("CS101"))
                .andExpect(jsonPath("$.courses[0].enrollmentStatus").value("approved"))
                .andExpect(jsonPath("$.courses[0].grade").value("N/A"))
                .andExpect(jsonPath("$.currentSemester.name").value("Fall 2025"));
    }

    @Test
    void testGetStudentCurrentCourses_StudentNotFound() throws Exception {
        // Arrange
        Integer studentId = 999;
        when(studentRepository.findByStudentId(studentId)).thenReturn(Optional.empty());

        // Act & Assert
        mockMvc.perform(get("/api/parent/student/{studentId}/current-courses", studentId))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.status").value("error"))
                .andExpect(jsonPath("$.message").value("Student not found"));
    }

    @Test
    void testGetStudentCurrentCourses_NoActiveSemester() throws Exception {
        // Arrange
        Integer studentId = 100;
        when(studentRepository.findByStudentId(studentId)).thenReturn(Optional.of(testStudent));

        // No active semester - semester dates don't include today
        Semester pastSemester = new Semester();
        pastSemester.setSemesterId(2);
        pastSemester.setName("Spring 2025");
        pastSemester.setStartDate(Date.valueOf(LocalDate.of(2025, 1, 15)));
        pastSemester.setEndDate(Date.valueOf(LocalDate.of(2025, 5, 15)));

        when(semesterRepository.findAll()).thenReturn(List.of(pastSemester));

        // Act & Assert
        mockMvc.perform(get("/api/parent/student/{studentId}/current-courses", studentId))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.status").value("success"))
                .andExpect(jsonPath("$.message").value("No active semester at this time."))
                .andExpect(jsonPath("$.courses").isArray())
                .andExpect(jsonPath("$.courses.length()").value(0))
                .andExpect(jsonPath("$.currentSemester").isEmpty());
    }

    @Test
    void testGetStudentCurrentCourses_NoCurrentSemesterEnrollments() throws Exception {
        // Arrange
        Integer studentId = 100;
        when(studentRepository.findByStudentId(studentId)).thenReturn(Optional.of(testStudent));
        when(semesterRepository.findAll()).thenReturn(List.of(currentSemester));

        // Enrollment from PAST semester only
        Enrollment pastEnrollment = new Enrollment();
        pastEnrollment.setEnrollmentId(1);
        pastEnrollment.setStudentId(100);
        pastEnrollment.setSectionId(1);
        Section testSection = new Section();
        testSection.setSectionId(1);
        when(enrollmentRepository.findByStudentId(studentId)).thenReturn(List.of(pastEnrollment));
        when(eavService.getEnrollmentStatus(1)).thenReturn("approved");

        // Past offered course (different semester ID)
        OfferedCourse pastOfferedCourse = new OfferedCourse();
        pastOfferedCourse.setOfferedCourseId(2);
        pastOfferedCourse.setSemesterId(999); // Not current semester

        when(sectionRepository.findBySectionId(1)).thenReturn(Optional.of(testSection));
        testSection.setOfferedCourseId(2); // Point to past offered course
        when(offeredCourseRepository.findByOfferedCourseId(2)).thenReturn(Optional.of(pastOfferedCourse));

        // Act & Assert - No courses returned (filtered by semester)
        mockMvc.perform(get("/api/parent/student/{studentId}/current-courses", studentId))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.status").value("success"))
                .andExpect(jsonPath("$.count").value(0))
                .andExpect(jsonPath("$.courses.length()").value(0));
    }

    @Test
    void testGetStudentCurrentCourses_OnlyPendingEnrollments() throws Exception {
        // Arrange
        Integer studentId = 100;
        when(studentRepository.findByStudentId(studentId)).thenReturn(Optional.of(testStudent));
        when(semesterRepository.findAll()).thenReturn(List.of(currentSemester));

        Enrollment pendingEnrollment = new Enrollment();
        pendingEnrollment.setEnrollmentId(1);
        pendingEnrollment.setStudentId(100);
        pendingEnrollment.setSectionId(1);
        Section testSection = new Section();
        testSection.setSectionId(1);
        OfferedCourse testOfferedCourse = new OfferedCourse();
        testOfferedCourse.setOfferedCourseId(1);
        Course testCourse = new Course();
        testCourse.setCourseId(1);

        when(enrollmentRepository.findByStudentId(studentId)).thenReturn(List.of(pendingEnrollment));
        when(eavService.getEnrollmentStatus(1)).thenReturn("pending"); // Only pending included

        // Entity chain
        when(sectionRepository.findBySectionId(1)).thenReturn(Optional.of(testSection));
        when(offeredCourseRepository.findByOfferedCourseId(1)).thenReturn(Optional.of(testOfferedCourse));
        when(courseRepository.findById(1)).thenReturn(Optional.of(testCourse));

        // Act & Assert
        mockMvc.perform(get("/api/parent/student/{studentId}/current-courses", studentId))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.status").value("success"))
                .andExpect(jsonPath("$.count").value(1))
                .andExpect(jsonPath("$.courses[0].enrollmentStatus").value("pending"));
    }

    @Test
    void testGetStudentCurrentCourses_MultipleStatusEnrollments() throws Exception {
        // Arrange
        Integer studentId = 100;
        when(studentRepository.findByStudentId(studentId)).thenReturn(Optional.of(testStudent));
        when(semesterRepository.findAll()).thenReturn(List.of(currentSemester));

        // Multiple enrollments with different statuses
        List<Enrollment> enrollments = Arrays.asList(
                createEnrollment(1, 100, 1), // approved
                createEnrollment(2, 100, 2), // pending
                createEnrollment(3, 100, 3)  // drop_pending
        );

        when(enrollmentRepository.findByStudentId(studentId)).thenReturn(enrollments);
        when(eavService.getEnrollmentStatus(1)).thenReturn("approved");
        when(eavService.getEnrollmentStatus(2)).thenReturn("pending");
        when(eavService.getEnrollmentStatus(3)).thenReturn("drop_pending");

        // Mock sections, offered courses for all 3
        for (int i = 1; i <= 3; i++) {
            when(sectionRepository.findBySectionId(i)).thenReturn(Optional.of(createTestSection(i)));
            when(offeredCourseRepository.findByOfferedCourseId(i)).thenReturn(Optional.of(createTestOfferedCourse(i)));
            when(courseRepository.findById(i)).thenReturn(Optional.of(createTestCourse(i)));
        }

        // Act & Assert - All 3 enrollments included
        mockMvc.perform(get("/api/parent/student/{studentId}/current-courses", studentId))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.count").value(3));
    }

    @Test
    void testGetStudentCurrentCourses_MissingSection() throws Exception {
        // Arrange
        Integer studentId = 100;
        when(studentRepository.findByStudentId(studentId)).thenReturn(Optional.of(testStudent));
        when(semesterRepository.findAll()).thenReturn(List.of(currentSemester));

        Enrollment enrollment = new Enrollment();
        enrollment.setEnrollmentId(1);
        enrollment.setStudentId(100);
        enrollment.setSectionId(999); // Missing section

        when(enrollmentRepository.findByStudentId(studentId)).thenReturn(List.of(enrollment));
        when(eavService.getEnrollmentStatus(1)).thenReturn("approved");
        when(sectionRepository.findBySectionId(999)).thenReturn(Optional.empty()); // Missing!

        // Act & Assert - No courses returned (section missing)
        mockMvc.perform(get("/api/parent/student/{studentId}/current-courses", studentId))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.count").value(0));
    }

    @Test
    void testGetStudentCurrentCourses_ExceptionHandling() throws Exception {
        // Arrange
        Integer studentId = 100;
        when(studentRepository.findByStudentId(studentId)).thenThrow(new RuntimeException("DB Error"));

        // Act & Assert
        mockMvc.perform(get("/api/parent/student/{studentId}/current-courses", studentId))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.status").value("error"))
                .andExpect(jsonPath("$.message").value("Error fetching current courses: DB Error"));
    }

    // Helper methods for cleaner tests
    private Enrollment createEnrollment(int id, int studentId, int sectionId) {
        Enrollment e = new Enrollment();
        e.setEnrollmentId(id);
        e.setStudentId(studentId);
        e.setSectionId(sectionId);
        return e;
    }

    private Section createTestSection(int id) {
        Section s = new Section();
        s.setSectionId(id);
        s.setSectionNumber(String.format("%02d", id));
        s.setOfferedCourseId(id);
        return s;
    }

    private OfferedCourse createTestOfferedCourse(int id) {
        OfferedCourse oc = new OfferedCourse();
        oc.setOfferedCourseId(id);
        oc.setCourseId(id);
        oc.setSemesterId(1); // Current semester
        return oc;
    }

    private Course createTestCourse(int id) {
        Course c = new Course();
        c.setCourseId(id);
        c.setCourseCode("CS" + id);
        c.setTitle("Course " + id);
        c.setCredits(3);
        return c;
    }


}
