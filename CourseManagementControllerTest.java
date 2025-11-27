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


@WebMvcTest(CourseManagementController.class)
class CourseManagementControllerTest {


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
    @Autowired
    private PrerequisiteRepository prerequisiteRepository;
    @InjectMocks
    private CourseManagementController courseManagementController; // class containing getPendingRequests()

    @Autowired
    private AdminController InstructorController;
    @Autowired
    private DepartmentCourseRepository departmentCourseRepository;

    @Test
    void getPrerequisitesFail() {
        Course course = new Course();
        course.setCourseId(88);

        when(courseRepository.findById(88)).thenReturn(Optional.empty());
        Map<String,Object> response = courseManagementController.getPrerequisites(88);
        assertEquals("error", response.get("status"));
        assertEquals("Course not found", response.get("message"));


    }

    @Test
    void getPrerequisitesSuccess() {
        Course course = new Course();
        course.setCourseId(999);
        when(courseRepository.findById(999)).thenReturn(Optional.of(course));
        Map<String,Object> response = courseManagementController.getPrerequisites(999);
        assertEquals("success", response.get("status"));
        assertEquals("prerequisites", response.get("message"));
    }
    private Map<String, String> createRequest(String courseId, String prereqCourseId) {
        Map<String, String> request = new HashMap<>();
        request.put("courseId", courseId);
        request.put("prereqCourseId", prereqCourseId);
        return request;
    }
    private Map<String, String> createDepartmentRequest(String courseId, String departmentId) {
        Map<String, String> request = new HashMap<>();
        request.put("courseId", courseId);
        request.put("departmentId", departmentId);
        return request;
    }

    @Test
    void addPrerequisite_success() {
        // Given
        Map<String, String> request = createRequest("101", "100");

        Course course = new Course();
        course.setCourseId(101);
        when(courseRepository.findById(101)).thenReturn(Optional.of(course));

        Course prereqCourse = new Course();
        prereqCourse.setCourseId(100);
        when(courseRepository.findById(100)).thenReturn(Optional.of(prereqCourse));

        when(prerequisiteRepository.existsByCourseIdAndPrereqCourseId(101, 100)).thenReturn(false);
        doReturn(false).when(courseManagementController).hasCircularDependency(101, 100);

        // When
        Map<String, String> response = courseManagementController.addPrerequisite(request);

        // Then
        assertEquals("success", response.get("status"));
        assertEquals("Prerequisite added successfully", response.get("message"));
        verify(prerequisiteRepository).save(argThat(prereq ->
                prereq.getCourseId().equals(101) && prereq.getPrereqCourseId().equals(100)));
    }

    @Test
    void addPrerequisite_courseNotFound() {
        Map<String, String> request = createRequest("999", "100");
        when(courseRepository.findById(999)).thenReturn(Optional.empty());
        when(courseRepository.findById(100)).thenReturn(Optional.of(new Course()));

        Map<String, String> response = courseManagementController.addPrerequisite(request);
        Course course = new Course();
        assertEquals("error", response.get("status"));
        assertEquals("Course or prerequisite course not found", response.get("message"));

    }

    @Test
    void addPrerequisite_prereqCourseNotFound() {
        Map<String, String> request = createRequest("101", "999");
        when(courseRepository.findById(101)).thenReturn(Optional.of(new Course()));
        when(courseRepository.findById(999)).thenReturn(Optional.empty());

        Map<String, String> response = courseManagementController.addPrerequisite(request);

        assertEquals("error", response.get("status"));
        assertEquals("Course or prerequisite course not found", response.get("message"));
    }

    @Test
    void addPrerequisite_selfReference() {
        Map<String, String> request = createRequest("101", "101");
        Course course = new Course();
        course.setCourseId(101);
        when(courseRepository.findById(101)).thenReturn(Optional.of(course));

        Map<String, String> response = courseManagementController.addPrerequisite(request);

        assertEquals("error", response.get("status"));
        assertEquals("A course cannot be a prerequisite of itself", response.get("message"));
        verify(prerequisiteRepository, never()).existsByCourseIdAndPrereqCourseId(anyInt(), anyInt());
        verify(prerequisiteRepository, never());
    }

    @Test
    void addPrerequisite_alreadyExists() {
        Map<String, String> request = createRequest("101", "100");
        Course course = new Course();
        course.setCourseId(101);
        Course prereqCourse = new Course();
        prereqCourse.setCourseId(100);
        when(courseRepository.findById(101)).thenReturn(Optional.of(course));
        when(courseRepository.findById(100)).thenReturn(Optional.of(prereqCourse));
        when(prerequisiteRepository.existsByCourseIdAndPrereqCourseId(101, 100)).thenReturn(true);

        Map<String, String> response = courseManagementController.addPrerequisite(request);

        assertEquals("error", response.get("status"));
        assertEquals("This prerequisite already exists", response.get("message"));
        verify(courseManagementController, never()).hasCircularDependency(anyInt(), anyInt());
        verify(prerequisiteRepository, never());
    }

    @Test
    void addPrerequisite_circularDependency() {
        Map<String, String> request = createRequest("101", "100");
        Course course = new Course();
        course.setCourseId(101);
        Course prereqCourse = new Course();
        prereqCourse.setCourseId(100);
        when(courseRepository.findById(101)).thenReturn(Optional.of(course));
        when(courseRepository.findById(100)).thenReturn(Optional.of(prereqCourse));
        when(prerequisiteRepository.existsByCourseIdAndPrereqCourseId(101, 100)).thenReturn(false);
        doReturn(true).when(courseManagementController).hasCircularDependency(101, 100);

        Map<String, String> response = courseManagementController.addPrerequisite(request);

        assertEquals("error", response.get("status"));
        assertEquals("Adding this prerequisite would create a circular dependency", response.get("message"));
        verify(prerequisiteRepository, never());
    }

    @Test
    void addPrerequisite_invalidCourseIdFormat() {
        Map<String, String> request = createRequest("abc", "100");

        Map<String, String> response = courseManagementController.addPrerequisite(request);

        assertEquals("error", response.get("status"));
        assertTrue(response.get("message").startsWith("Error adding prerequisite:"));
        verify(courseRepository, never()).findById(anyInt());
    }

    @Test
    void addPrerequisite_invalidPrereqCourseIdFormat() {
        Map<String, String> request = createRequest("101", "xyz");

        Map<String, String> response = courseManagementController.addPrerequisite(request);

        assertEquals("error", response.get("status"));
        assertTrue(response.get("message").startsWith("Error adding prerequisite:"));
        verify(courseRepository, never()).findById(anyInt());
    }

    @Test
    void addPrerequisite_missingParameters() {
        Map<String, String> request = new HashMap<>();
        // Missing both courseId and prereqCourseId

        Map<String, String> response = courseManagementController.addPrerequisite(request);

        assertEquals("error", response.get("status"));
        assertTrue(response.get("message").startsWith("Error adding prerequisite:"));
        verify(courseRepository, never()).findById(anyInt());
    }

    @Test
    void removePrerequisiteNotFound() {
        Map<String, String> request = createRequest("101", "100");

        when(courseRepository.findById(100)).thenReturn(Optional.empty());
        Map<String, String> response = courseManagementController.removePrerequisite(request);
        assertEquals("error", response.get("status"));
        assertEquals("Prerequisite not found", response.get("message"));

    }


    private Map<String, String> createCourseRequest(String departmentId,String courseId, String courseType ,String capacity ,String eligibilityRequirements) {
        Map<String, String> request = new HashMap<>();
        request.put("courseId", courseId);
        request.put("departmentId", departmentId);
        request.put("courseType", courseType);
        request.put("capacity", capacity);
        request.put("eligibilityRequirements", eligibilityRequirements);

        return request;
    }

    @Test
    void linkCourseToDepartmentWrongtype() {
        Map<String, String> request = createCourseRequest("21", "100","Asu","100","eligible");
        Map<String, String> response = courseManagementController.linkCourseToDepartment(request);
        assertEquals("error", response.get("status"));
        assertEquals("Course type must be 'core' or 'elective'", response.get("message"));
        verify(courseRepository, never()).findById(anyInt());
    }
    @Test
    void linkCourseToDepartmentNullcourseid() {
        Map<String, String> request = createCourseRequest("21", null,"core",null,"eligible");
        Map<String, String> response = courseManagementController.linkCourseToDepartment(request);
        assertEquals("error", response.get("status"));
        assertEquals("Department or course not found", response.get("message"));
    }
    @Test
    void linkCourseToDepartmentNulldepartment() {
        Map<String, String> request = createCourseRequest(null, "100","elective","100","eligible");
        Map<String, String> response = courseManagementController.linkCourseToDepartment(request);
        assertEquals("error", response.get("status"));
        assertEquals("Department or course not found", response.get("message"));
    }

    @Test
    void linkCourseToDepartmentAlreadyLinked() {
        Map<String, String> request = createCourseRequest("21", "100","elective","100","eligible");
        Map<String, String> response = courseManagementController.linkCourseToDepartment(request);
        when(departmentCourseRepository.existsByDepartmentIdAndCourseId(21,100)).thenReturn(true);
        assertEquals("error", response.get("status"));
        assertEquals("Course is already linked to this department", response.get("message"));

    }

    @Test
    void updateDepartmentCourseLinkNotFound() {
        Map<String, String> request = createCourseRequest("21", "100","elective","100","eligible");
        Map<String, String> response = courseManagementController.updateDepartmentCourseLink(request);
        when(departmentCourseRepository.findByDepartmentId(21)).thenReturn(null);
        assertEquals("error", response.get("status"));
        assertEquals("Department-course link not found", response.get("message"));

    }

    @Test
    void updateDepartmentCourseLinkInvalidCoursetype() {
        Map<String, String> request = createCourseRequest("21", "100","core","100","eligible");
        Map<String, String> response = courseManagementController.linkCourseToDepartment(request);
        assertEquals("error", response.get("status"));
        assertEquals("Course type must be 'core' or 'elective'", response.get("message"));
        verify(courseRepository, never()).findById(anyInt());
    }

    @Test
    void unlinkCourseFromDepartmentfail() {
        Map<String,String> request = createDepartmentRequest("100","21");
        Map<String, String> response = courseManagementController.unlinkCourseFromDepartment(request);
        when(departmentCourseRepository.findByDepartmentId(21)).thenReturn(null);
        assertEquals("error", response.get("status"));
        assertEquals("Department-course link not found", response.get("message"));
    }

    @Test
    void getCoreCourses() {
        Map<String, String> request = createCourseRequest("21", "100","Asu","100","eligible");
        Map<String, Object> response = courseManagementController.getCoreCourses(100);
        assertEquals("error", response.get("status"));

    }

    @Test
    void getCoreCoursesFound() {
        Map<String, String> request = createCourseRequest("21", "100","core","100","eligible");
        Map<String, Object> response = courseManagementController.getCoreCourses(100);
        assertEquals("success", response.get("status"));
    }


    @Test
    void getInstructorsByDepartmentNotfound() {
        Map<String,Object> response = courseManagementController.getInstructorsByDepartment(21);
        when(departmentCourseRepository.findByDepartmentId(21)).thenReturn(null);
        assertEquals("error", response.get("status"));
        assertEquals("Department not found", response.get("message"));

    }

    @Test
    void getInstructorsByDepartment() {
        Map<String,Object> response = courseManagementController.getInstructorsByDepartment(21);
        when(departmentCourseRepository.findByDepartmentId(21)).thenReturn(notNull());
        assertEquals("success", response.get("status"));

    }

    @Test
    void getOfferedCourses() {
        Map<String,Object> response = courseManagementController.getOfferedCourses(5,21);
        doReturn(true).when(courseManagementController.getOfferedCourses(5,21));
        assertEquals("success", response.get("status"));
    }

    @Test
    void getOfferedCoursesNotFound() {
        Map<String,Object> response = courseManagementController.getOfferedCourses(5,21);
        doReturn(true).when(courseManagementController.getOfferedCourses(5,21)).isEmpty();
        assertEquals("error", response.get("status"));
    }



    private Map<String, Object> createRequest2(Object courseId, Object semesterId) {
        Map<String, Object> request = new HashMap<>();
        if (courseId != null) {
            request.put("courseId", courseId);
        }
        if (semesterId != null) {
            request.put("semesterId", semesterId);
        }
        return request;
    }

    @Test
    void createOfferedCourse_successWithIntegerValues() {
        // Given
        Map<String, Object> request = createRequest2(101, 200);

        Map<String, Object> serviceResponse = new HashMap<>();
        serviceResponse.put("status", "success");
        serviceResponse.put("message", "Offered course created successfully");
        serviceResponse.put("offeredCourseId", 1000);

        when(courseManagementController.createOfferedCourse(request)).thenReturn(serviceResponse);

        // When
        Map<String, Object> response = courseManagementController.createOfferedCourse(request);

        // Then
        assertEquals("success", response.get("status"));
        assertEquals("Offered course created successfully", response.get("message"));
        assertEquals(1000, response.get("offeredCourseId"));
        verify(courseManagementController).createOfferedCourse(request);
    }

    @Test
    void createOfferedCourse_successWithStringValues() {
        // Given
        Map<String, Object> request = createRequest2("101", "200");

        Map<String, Object> serviceResponse = new HashMap<>();
        serviceResponse.put("status", "success");
        serviceResponse.put("message", "Offered course created successfully");

        when(courseManagementController.createOfferedCourse(request)).thenReturn(serviceResponse);

        // When
        Map<String, Object> response = courseManagementController.createOfferedCourse(request);

        // Then
        assertEquals("success", response.get("status"));
        verify(courseManagementController).createOfferedCourse(request);
    }

    @Test
    void createOfferedCourse_invalidStringNumberFormat() {
        // Given
        Map<String, Object> request = createRequest2("abc", "200");

        // When
        Map<String, Object> response = courseManagementController.createOfferedCourse(request);

        // Then
        assertEquals("error", response.get("status"));
        assertTrue(((String) response.get("message")).startsWith("Error creating offered course:"));
        verify(courseManagementController, never()).createOfferedCourse(request);
    }

    @Test
    void createOfferedCourse_missingCourseId() {
        // Given
        Map<String, Object> request = createRequest2(null, 200);

        // When
        Map<String, Object> response = courseManagementController.createOfferedCourse(request);

        // Then
        assertEquals("error", response.get("status"));
        assertTrue(((String) response.get("message")).startsWith("Error creating offered course:"));
        verify(courseManagementController, never()).createOfferedCourse(request);
    }

    @Test
    void createOfferedCourse_missingSemesterId() {
        // Given
        Map<String, Object> request = createRequest2(101, null);

        // When
        Map<String, Object> response = courseManagementController.createOfferedCourse(request);

        // Then
        assertEquals("error", response.get("status"));
        assertTrue(((String) response.get("message")).startsWith("Error creating offered course:"));
        verify(courseManagementController, never()).createOfferedCourse(request);
    }

    @Test
    void removeOfferedCourse() {
        Map<String , Object> response = courseManagementController.removeOfferedCourse(10);
        when(courseManagementController.removeOfferedCourse(10)).thenReturn(response);
        assertEquals("success", response.get("status"));
    }

    @Test
    void removeOfferedCourseNotFound() {
        Map<String , Object> response = courseManagementController.removeOfferedCourse(10);
        when(courseRepository.existsByCourseCode("10")).thenReturn(false);
        assertEquals("error", response.get("status"));
    }
}