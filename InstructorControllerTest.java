package com.asu_lms.lms.Controllers;

import com.asu_lms.lms.Entities.*;
import com.asu_lms.lms.Repositories.*;
import com.asu_lms.lms.Services.AuthService;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.InjectMocks;
import org.mockito.Mockito;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestBody;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

import static org.hamcrest.Matchers.any;
import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;
@WebMvcTest(InstructorController.class)
class InstructorControllerTest {

    @Autowired
    private StudentRepository studentRepository;

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
    private MockMvc mockMvc;
    @Autowired
    private UserRepository userRepository;

    @InjectMocks
    private InstructorController instructorController; // class containing getPendingRequests()

    @Autowired
    private AdminController InstructorController;


    @Test
    void getInstructorDashboard_professor_success() {
        // Given
        Integer instructorId = 215;
        Instructor instructor = new Instructor();
        instructor.setInstructorId(instructorId);
        instructor.setInstructorType("professor");
        instructor.setOfficeHours("Mon 10-12, Wed 2-4");

        when(InstructorRepository.findByInstructorId(instructorId))
                .thenReturn(Optional.of(instructor));

        // Mock helper methods (you'll need to implement these mocks based on your actual implementation)
        doReturn(List.of(
                Map.of("courseCode", "CS101", "totalStudents", 25),
                Map.of("courseCode", "CS201", "totalStudents", 30)
        )).when(instructorController).buildCourseAssignments(instructor);

        doReturn(List.of(Map.of("studentId", 1, "name", "John Doe"))).when(instructorController).buildAdviseeList(instructor);

        doReturn(Map.of("schedule", "Mon 10-12, Wed 2-4")).when(instructorController).buildOfficeHours("Mon 10-12, Wed 2-4");

        // When
        Map<String, Object> response = instructorController.getInstructorDashboard(instructorId);

        // Then
        assertEquals("success", response.get("status"));

        @SuppressWarnings("unchecked")
        Map<String, Object> data = (Map<String, Object>) response.get("data");
        assertEquals("professor", data.get("instructorType"));
        assertEquals(55, data.get("studentsCount")); // 25 + 30
        assertEquals(0, data.get("pendingRequests"));

        @SuppressWarnings("unchecked")
        List<Map<String, Object>> courses = (List<Map<String, Object>>) data.get("courses");
        assertEquals(2, courses.size());

        @SuppressWarnings("unchecked")
        List<Map<String, Object>> advisees = (List<Map<String, Object>>) data.get("advisees");
        assertEquals(1, advisees.size());
    }

    @Test
    void getInstructorDashboard_ta_success() {
        // Given
        Integer instructorId = 216;
        Instructor instructor = new Instructor();
        instructor.setInstructorId(instructorId);
        instructor.setInstructorType("ta");
        instructor.setOfficeHours("Tue 1-3");

        when(InstructorRepository.findByInstructorId(instructorId))
                .thenReturn(Optional.of(instructor));

        doReturn(List.of(Map.of("courseCode", "CS101", "totalStudents", 25)))
                .when(instructorController).buildCourseAssignments(instructor);

        doReturn(Map.of("schedule", "Tue 1-3")).when(instructorController).buildOfficeHours("Tue 1-3");

        // When
        Map<String, Object> response = instructorController.getInstructorDashboard(instructorId);

        // Then
        assertEquals("success", response.get("status"));

        @SuppressWarnings("unchecked")
        Map<String, Object> data = (Map<String, Object>) response.get("data");
        assertEquals("ta", data.get("instructorType"));
        assertEquals(25, data.get("studentsCount"));

        @SuppressWarnings("unchecked")
        List<Map<String, Object>> advisees = (List<Map<String, Object>>) data.get("advisees");
        assertTrue(advisees.isEmpty());
    }

    @Test
    void getInstructorDashboard_instructorNotFound() {
        // Given
        Integer instructorId = 999;
        when(InstructorRepository.findByInstructorId(instructorId))
                .thenReturn(Optional.empty());

        // When
        Map<String, Object> response = instructorController.getInstructorDashboard(instructorId);
        Instructor instructor = new Instructor();
        // Then
        assertEquals("error", response.get("status"));
        assertEquals("Instructor not found", response.get("message"));
        verify(instructorController, never()).buildCourseAssignments(instructor);
    }

    @Test
    void updateGradeError() {

        Enrollment enrollment = new Enrollment();
        enrollment.setEnrollmentId(111);

        Map<String, Object> payload = new HashMap<>();
        payload.put("midterm", 90.0);
        payload.put("project", 88.5);
        payload.put("assignmentsTotal", 85.0);
        payload.put("quizzesTotal", 92.0);
        payload.put("attendance", 98.0);
        payload.put("finalExamMark", 87.5);

        Map<String, Object> response = instructorController.updateGrade(20, payload);

        assertEquals(response.get("message"), "Enrollment not found");
        assertEquals(response.get("status"), "error");





    }
    @Test
    void updateGradeSuccess() {
        Enrollment enrollment = new Enrollment();
        enrollment.setEnrollmentId(111);
        Map<String, Object> payload = new HashMap<>();
        payload.put("midterm", 90.0);
        payload.put("project", 88.5);
        payload.put("assignmentsTotal", 85.0);
        payload.put("quizzesTotal", 92.0);
        payload.put("attendance", 98.0);
        payload.put("finalExamMark", 87.5);
        Map<String, Object> response = instructorController.updateGrade(111, payload);
        assertEquals(response.get("message"), "Enrollment successfully updated");
        assertEquals(response.get("status"), "success");
    }

    @Test
    void getPendingRequestsEmpty() {
        // Call method
        Map<String, Object> response = instructorController.getPendingRequests(215);

        Instructor instructor = new Instructor();
        instructor.setInstructorType("Teacher");
        instructor.setInstructorId(215);
        assertEquals("error", response.get("error")); //check that it will return error

        assertEquals("Only professors can view registration requests",response.get("message"));


    }

    @Test
    void getPendingRequestsSuccess() {
        Instructor instructor = new Instructor();
        instructor.setInstructorId(215);
        instructor.setInstructorType("professor");

        Student student = new Student();
        student.setStudentId(1);
        student.setAdvisorId(215);
        student.setStudentUid("20250001");

        Enrollment e1 = new Enrollment();
        e1.setEnrollmentId(10);
        e1.setStudentId(1);
        e1.setSectionId(100);
        e1.setStatus("pending");

        Enrollment e2 = new Enrollment();
        e2.setEnrollmentId(11);
        e2.setStudentId(1);
        e2.setSectionId(101);
        e2.setStatus("drop_pending");

        Section s1 = new Section();
        s1.setSectionId(100);
        s1.setOfferedCourseId(1000);
        s1.setSectionNumber("01");

        Section s2 = new Section();
        s2.setSectionId(101);
        s2.setOfferedCourseId(1001);
        s2.setSectionNumber("02");

        OfferedCourse oc1 = new OfferedCourse();
        oc1.setOfferedCourseId(1000);
        oc1.setCourseId(200);
        oc1.setSemesterId(300);

        OfferedCourse oc2 = new OfferedCourse();
        oc2.setOfferedCourseId(1001);
        oc2.setCourseId(201);
        oc2.setSemesterId(300);

        // Courses
        Course c1 = new Course();
        c1.setCourseId(200);
        c1.setCourseCode("CS101");
        c1.setTitle("Intro to CS");
        c1.setCredits(3);

        Course c2 = new Course();
        c2.setCourseId(201);
        c2.setCourseCode("CS102");
        c2.setTitle("Data Structures");
        c2.setCredits(4);

        Semester semester = new Semester();
        semester.setSemesterId(300);
        semester.setName("Fall 2025");
        when(semesterRepository.findById(300))
                .thenReturn(Optional.of(semester));

        Map<String, Object> response = instructorController.getPendingRequests(215);

        // Assertions on response
        assertEquals("success", response.get("status"));


    }

    private Map<String, Object> createRequest(Integer instructorId, Integer enrollmentId, String action) {
        Map<String, Object> request = new HashMap<>();
        request.put("instructorId", instructorId);
        request.put("enrollmentId", enrollmentId);
        request.put("action", action);
        return request;
    }

    private Map<String, Object> createRequest2(Integer instructorId, Integer enrollmentId, String action,String instructorType) {
        Map<String, Object> request = new HashMap<>();
        request.put("instructorId", instructorId);
        request.put("enrollmentId", enrollmentId);
        request.put("action", action);
        request.put("instructorType", instructorType);
        return request;
    }


    @Test
    void approveRequest_invalidAction_error() {
        Map<String, Object> request = Map.of(
                "instructorId", 215,
                "enrollmentId", 10,
                "action", "invalid"
        );

        Instructor instructor = new Instructor();
        instructor.setInstructorId(215);
        instructor.setInstructorType("professor");
        when(InstructorRepository.findByInstructorId(215)).thenReturn(Optional.of(instructor));

        Enrollment enrollment = new Enrollment();
        enrollment.setEnrollmentId(10);
        enrollment.setStudentId(1);
        enrollment.setSectionId(100);
        enrollment.setStatus("pending");
        when(enrollmentRepository.findById(10)).thenReturn(Optional.of(enrollment));

        Student student = new Student();
        student.setStudentId(1);
        student.setAdvisorId(215);
        when(studentRepository.findByStudentId(1)).thenReturn(Optional.of(student));

        Map<String, Object> response = instructorController.approveRequest(request);

        assertEquals("error", response.get("status"));
        assertEquals("Invalid action. Use 'approve' or 'reject'", response.get("message"));
    }

    @Test
    void approveRequest_notAdvisee_error() {
        Map<String, Object> request = createRequest(215, 10, "approve");

        Instructor instructor = new Instructor();
        instructor.setInstructorId(215);
        instructor.setInstructorType("professor");
        when(InstructorRepository.findByInstructorId(215)).thenReturn(Optional.of(instructor));

        Enrollment enrollment = new Enrollment();
        enrollment.setEnrollmentId(10);
        enrollment.setStudentId(1);
        enrollment.setSectionId(100);
        enrollment.setStatus("pending");
        when(enrollmentRepository.findById(10)).thenReturn(Optional.of(enrollment));

        Student student = new Student();
        student.setStudentId(1);
        student.setAdvisorId(999); // Different advisor
        when(studentRepository.findByStudentId(1)).thenReturn(Optional.of(student));

        Map<String, Object> response = instructorController.approveRequest(request);

        assertEquals("error", response.get("status"));
        assertEquals("This enrollment does not belong to your advisee", response.get("message"));
    }


    @Test
    void approveRequest_approvePendingRegistration_success() {
        // Given
        Map<String, Object> request = createRequest(215, 10, "approve");

        Instructor instructor = new Instructor();
        instructor.setInstructorId(215);
        instructor.setInstructorType("professor");


        Enrollment enrollment = new Enrollment();
        enrollment.setEnrollmentId(10);
        enrollment.setStudentId(1);
        enrollment.setSectionId(100);
        enrollment.setStatus("pending");
        when(enrollmentRepository.findById(10)).thenReturn(Optional.of(enrollment));

        Student student = new Student();
        student.setStudentId(1);
        student.setAdvisorId(215);
        when(studentRepository.findByStudentId(1)).thenReturn(Optional.of(student));

        Section section = new Section();
        section.setSectionId(100);
        section.setCurrentEnrollment(5);
        when(sectionRepository.findBySectionId(100)).thenReturn(Optional.of(section));

        // When
        Map<String, Object> response = instructorController.approveRequest(request);

        // Then
        assertEquals("success", response.get("status"));
        assertEquals("Registration approved successfully", response.get("message"));

        verify(enrollmentRepository).save(enrollment);
        verify(sectionRepository).save(section);
        verify(enrollmentRepository, never()).delete(enrollment);
    }

    @Test
    void approveRequest_approvePendingRegistration_failure() {
        Map<String, Object> request = createRequest(null, 10, "approve");
        Map<String, Object> response = instructorController.approveRequest(request);

        assertEquals("error", response.get("status"));
        assertEquals("Invalid request parameters",response.get("message"));
    }

    @Test
    void approveRequest_failureMissingenrollmentId() {
        Map<String, Object> request = createRequest(215, null, "approve");
        Map<String, Object> response = instructorController.approveRequest(request);
        assertEquals("error", response.get("status"));
        assertEquals("Invalid request parameters",response.get("message"));
    }

    @Test
    void approveRequest_failureMissingAction() {
        Map<String, Object> request = createRequest(215, 10, null);
        Map<String, Object> response = instructorController.approveRequest(request);
        assertEquals("error", response.get("status"));
        assertEquals("Invalid request parameters",response.get("message"));
    }

    @Test
    void approveRequest_failureCantApprove() {
        Map<String, Object> request = createRequest2(215, 10, "approve","Teacher");
        Map<String, Object> response = instructorController.approveRequest(request);
        assertEquals("error", response.get("status"));
        assertEquals("Only professors can approve requests",response.get("message"));
    }

}