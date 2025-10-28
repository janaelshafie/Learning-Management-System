package com.asu_lms.lms.Controllers;

import com.asu_lms.lms.Entities.Course;
import org.junit.jupiter.api.Assertions;
import org.junit.jupiter.api.Test;

import java.util.*;

import static org.mockito.Mockito.*;
import com.asu_lms.lms.Services.AuthService;
import com.asu_lms.lms.Repositories.UserRepository;
import com.asu_lms.lms.Entities.User;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.test.web.servlet.MockMvc;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.junit.jupiter.api.extension.ExtendWith;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.asu_lms.lms.Entities.Announcement;
import com.asu_lms.lms.Repositories.AnnouncementRepository;
import com.asu_lms.lms.Entities.Department;
import com.asu_lms.lms.Repositories.DepartmentRepository;
import com.asu_lms.lms.Repositories.CourseRepository;
import com.asu_lms.lms.Repositories.UserRepository;
import static org.junit.jupiter.api.Assertions.*;

class DepartmentControllerTest {


    @Mock
    private DepartmentRepository departmentRepository;

    @Mock
    private UserRepository userRepository;

    @Mock
    private CourseRepository courseRepository;

    @InjectMocks
    private DepartmentController departmentController;

    @Test
    public void testGetAllDepartments_Success() {
        Department dep1 = new Department("CS", 1);
        Department dep2 = new Department("Energy", 2);
        List<Department> departments = Arrays.asList(dep1, dep2);

        when(departmentRepository.findAll()).thenReturn(departments);

        Map<String, Object> result = departmentController.getAllDepartments();

        assertEquals("success", result.get("status"));
        assertEquals(departments, result.get("departments"));
        assertEquals(2, result.get("count"));
    }

    @Test
    public void testCreateDepartment_DuplicateName() {
        Map<String, String> request = new HashMap<>();
        request.put("name", "CS");
        when(departmentRepository.existsByName("CS")).thenReturn(true);

        Map<String, String> response = departmentController.createDepartment(request);

        assertEquals("error", response.get("status"));
        assertEquals("Department with this name already exists", response.get("message"));
    }

    @Test
    public void testCreateDepartment_UnitHeadNotInstructor() {
        Map<String, String> request = new HashMap<>();
        request.put("name", "Physics");
        request.put("unitHeadId", "3");
        when(departmentRepository.existsByName("Physics")).thenReturn(false);

        User user = new User();
        user.setRole("student"); // Not instructor
        when(userRepository.findById(3)).thenReturn(Optional.of(user));

        Map<String, String> response = departmentController.createDepartment(request);

        assertEquals("error", response.get("status"));
        assertEquals("Unit head must be an instructor", response.get("message"));
    }

    @Test
    public void testCreateDepartment_UnitHeadNotFound() {
        Map<String, String> request = new HashMap<>();
        request.put("name", "Artificial Intelligence");
        request.put("unitHeadId", "5");
        when(departmentRepository.existsByName("Artificial Intelligence")).thenReturn(false);

        when(userRepository.findById(5)).thenReturn(Optional.empty());

        Map<String, String> response = departmentController.createDepartment(request);

        assertEquals("error", response.get("status"));
        assertEquals("Unit head must be an instructor", response.get("message"));
    }

    @Test
    public void testCreateDepartment_Success_WithUnitHead() {
        Map<String, String> request = new HashMap<>();
        request.put("name", "Software Engineering");
        request.put("unitHeadId", "9");
        when(departmentRepository.existsByName("Software Engineering")).thenReturn(false);

        User user = new User();
        user.setRole("instructor");
        when(userRepository.findById(9)).thenReturn(Optional.of(user));

        Department newDepartment = new Department("Software Engineering", 9);
        when(departmentRepository.save(any(Department.class))).thenReturn(newDepartment);

        Map<String, String> response = departmentController.createDepartment(request);

        assertEquals("success", response.get("status"));
        assertEquals("Department created successfully", response.get("message"));
    }

    @Test
    public void testCreateDepartment_Success_WithoutUnitHead() {
        Map<String, String> request = new HashMap<>();
        request.put("name", "Architecture");
        // unitHeadId not given
        when(departmentRepository.existsByName("Architecture")).thenReturn(false);

        Department newDepartment = new Department("Architecture", null);
        when(departmentRepository.save(any(Department.class))).thenReturn(newDepartment);

        Map<String, String> response = departmentController.createDepartment(request);

        assertEquals("success", response.get("status"));
        assertEquals("Department created successfully", response.get("message"));
    }

    @Test
    public void testCreateDepartment_Exception() {
        Map<String, String> request = new HashMap<>();
        request.put("name", "Chemistry");
        when(departmentRepository.existsByName("Chemistry")).thenReturn(false);

        when(departmentRepository.save(any(Department.class))).thenThrow(new RuntimeException("DB error"));

        Map<String, String> response = departmentController.createDepartment(request);

        assertEquals("error", response.get("status"));
        assertTrue(response.get("message").contains("Error creating department:"));
    }

    @Test
    public void testUpdateDepartment_Success() {
        Department dep = new Department("CS", 1);
        dep.setDepartmentId(101);

        Map<String, String> request = new HashMap<>();
        request.put("departmentId", "101");
        request.put("name", "Software Engineering");
        request.put("unitHeadId", "5");

        when(departmentRepository.findById(101)).thenReturn(Optional.of(dep));
        when(departmentRepository.existsByName("Software Engineering")).thenReturn(false);

        User head = new User();
        head.setRole("instructor");
        when(userRepository.findById(5)).thenReturn(Optional.of(head));
        when(departmentRepository.save(any(Department.class))).thenReturn(dep);

        Map<String, String> response = departmentController.updateDepartment(request);

        assertEquals("success", response.get("status"));
        assertEquals("Department updated successfully", response.get("message"));
        assertEquals("Software Engineering", dep.getName());
        assertEquals(5, dep.getUnitHeadId());
    }

    @Test
    public void testUpdateDepartment_DepartmentNotFound() {
        Map<String, String> request = new HashMap<>();
        request.put("departmentId", "222");
        request.put("name", "Physics");
        when(departmentRepository.findById(222)).thenReturn(Optional.empty());

        Map<String, String> response = departmentController.updateDepartment(request);

        assertEquals("error", response.get("status"));
        assertEquals("Department not found", response.get("message"));
    }

    @Test
    public void testUpdateDepartment_DuplicateName() {
        Department dep = new Department("CS", 1);
        dep.setDepartmentId(101);

        Map<String, String> request = new HashMap<>();
        request.put("departmentId", "101");
        request.put("name", "Math"); // new name
        request.put("unitHeadId", "1");

        when(departmentRepository.findById(101)).thenReturn(Optional.of(dep));
        when(departmentRepository.existsByName("Math")).thenReturn(true);

        Map<String, String> response = departmentController.updateDepartment(request);

        assertEquals("error", response.get("status"));
        assertEquals("Department with this name already exists", response.get("message"));
    }

    @Test
    public void testUpdateDepartment_WrongUnitHeadRole() {
        Department dep = new Department("CS", 1);
        dep.setDepartmentId(101);

        Map<String, String> request = new HashMap<>();
        request.put("departmentId", "101");
        request.put("name", "CS");
        request.put("unitHeadId", "7");

        when(departmentRepository.findById(101)).thenReturn(Optional.of(dep));
        when(departmentRepository.existsByName("CS")).thenReturn(false);

        User user = new User();
        user.setRole("student"); // Not instructor
        when(userRepository.findById(7)).thenReturn(Optional.of(user));

        Map<String, String> response = departmentController.updateDepartment(request);

        assertEquals("error", response.get("status"));
        assertEquals("Unit head must be an instructor", response.get("message"));
    }

    @Test
    public void testUpdateDepartment_UnitHeadNotFound() {
        Department dep = new Department("CS", 1);
        dep.setDepartmentId(101);

        Map<String, String> request = new HashMap<>();
        request.put("departmentId", "101");
        request.put("name", "CS");
        request.put("unitHeadId", "8");

        when(departmentRepository.findById(101)).thenReturn(Optional.of(dep));
        when(departmentRepository.existsByName("CS")).thenReturn(false);
        when(userRepository.findById(8)).thenReturn(Optional.empty());

        Map<String, String> response = departmentController.updateDepartment(request);

        assertEquals("error", response.get("status"));
        assertEquals("Unit head must be an instructor", response.get("message"));
    }

    @Test
    public void testUpdateDepartment_Exception() {
        Department dep = new Department("CS", 1);
        dep.setDepartmentId(101);
        Map<String, String> request = new HashMap<>();
        request.put("departmentId", "101");
        request.put("name", "CS");

        when(departmentRepository.findById(101)).thenThrow(new RuntimeException("DB error"));

        Map<String, String> response = departmentController.updateDepartment(request);

        assertEquals("error", response.get("status"));
        assertTrue(response.get("message").contains("Error updating department:"));
    }

    // --- Delete Department Tests ---
    @Test
    public void testDeleteDepartment_Success() {
        Department dep = new Department("Math", 3);
        dep.setDepartmentId(301);

        Map<String, String> request = new HashMap<>();
        request.put("departmentId", "301");

        when(departmentRepository.findById(301)).thenReturn(Optional.of(dep));
        doNothing().when(departmentRepository).delete(dep);

        Map<String, String> response = departmentController.deleteDepartment(request);

        assertEquals("success", response.get("status"));
        assertEquals("Department 'Math' deleted successfully", response.get("message"));
    }

    @Test
    public void testDeleteDepartment_NotFound() {
        Map<String, String> request = new HashMap<>();
        request.put("departmentId", "302");

        when(departmentRepository.findById(302)).thenReturn(Optional.empty());

        Map<String, String> response = departmentController.deleteDepartment(request);

        assertEquals("error", response.get("status"));
        assertEquals("Department not found", response.get("message"));
    }

    @Test
    public void testDeleteDepartment_Exception() {
        Department dep = new Department("Physics", 2);
        dep.setDepartmentId(303);

        Map<String, String> request = new HashMap<>();
        request.put("departmentId", "303");

        when(departmentRepository.findById(303)).thenReturn(Optional.of(dep));
        doThrow(new RuntimeException("Delete error")).when(departmentRepository).delete(dep);

        Map<String, String> response = departmentController.deleteDepartment(request);

        assertEquals("error", response.get("status"));
        assertTrue(response.get("message").contains("Error deleting department:"));
    }

    @Test
    public void testGetAllcourses(){
        Course course1 = new Course();
        course1.setCourseId(1);
        course1.setCredits(2);
        course1.setTitle("Agile Software Development");
        course1.setCourseCode("CSE233");

        Course course2 = new Course();
        course2.setCourseId(2);
        course2.setCredits(3);
        course2.setTitle("Computer Organization and networks");
        course2.setCourseCode("CSE112");

        Course course3 = new Course();
        course3.setCourseId(3);
        course3.setCredits(2);
        course3.setTitle("Engineering Economy and Investment");
        course3.setCourseCode("EPM119");

        Course course4 = new Course();
        course4.setCourseId(4);
        course4.setCredits(3);
        course4.setTitle("Introduction to Embedded systems");
        course4.setCourseCode("CSE322");

        List<Course> courses = Arrays.asList(course1, course2, course3, course4);
        when(courseRepository.findAll()).thenReturn(courses);
        Map<String, Object> result = departmentController.getAllCourses();
        assertEquals("success", result.get("status"));
        // Cast the returned field to List and check its size
        List<Course> returnedCourses = (List<Course>) result.get("courses");
        assertEquals(4, returnedCourses.size());
        assertEquals(4, result.get("count"));

    }

    @Test
    public void testCreateCourse_Success() {
        Map<String, String> request = new HashMap<>();
        request.put("courseCode", "CSE233");
        request.put("title", "Agile Software Development");
        request.put("description", "Course on Agile");
        request.put("credits", "3");

        when(courseRepository.existsByCourseCode("CSE233")).thenReturn(false);

        Course course = new Course("CSE233", "Agile Software Development", "Course on Agile", 3);
        when(courseRepository.save(any(Course.class))).thenReturn(course);

        Map<String, String> response = departmentController.createCourse(request);

        assertEquals("success", response.get("status"));
        assertEquals("Course created successfully", response.get("message"));
    }

    @Test
    public void testCreateCourse_DuplicateCode() {
        Map<String, String> request = new HashMap<>();
        request.put("courseCode", "CSE233");
        when(courseRepository.existsByCourseCode("CSE233")).thenReturn(true);

        Map<String, String> response = departmentController.createCourse(request);

        assertEquals("error", response.get("status"));
        assertEquals("Course with this code already exists", response.get("message"));
    }

    @Test
    public void testCreateCourse_Exception() {
        Map<String, String> request = new HashMap<>();
        request.put("courseCode", "CSE233");
        request.put("credits", "notANumber");
        when(courseRepository.existsByCourseCode("CSE233")).thenReturn(false);

        Map<String, String> response = departmentController.createCourse(request);

        assertEquals("error", response.get("status"));
        assertTrue(response.get("message").startsWith("Error creating course:"));
    }

    // --- Update Course ---
    @Test
    public void testUpdateCourse_Success() {
        Map<String, String> request = new HashMap<>();
        request.put("courseId", "1");
        request.put("courseCode", "CSE322");
        request.put("title", "Intro to Embedded");
        request.put("description", "New description");
        request.put("credits", "4");

        Course course = new Course("CSE233", "Agile", "Old Desc", 2);
        course.setCourseId(1);

        when(courseRepository.findById(1)).thenReturn(Optional.of(course));
        when(courseRepository.existsByCourseCode("CSE322")).thenReturn(false);

        when(courseRepository.save(any(Course.class))).thenReturn(course);

        Map<String, String> response = departmentController.updateCourse(request);

        assertEquals("success", response.get("status"));
        assertEquals("Course updated successfully", response.get("message"));
        assertEquals("CSE322", course.getCourseCode());
        assertEquals("Intro to Embedded", course.getTitle());
        assertEquals(4, course.getCredits());
    }

    @Test
    public void testUpdateCourse_NotFound() {
        Map<String, String> request = new HashMap<>();
        request.put("courseId", "55");
        when(courseRepository.findById(55)).thenReturn(Optional.empty());

        Map<String, String> response = departmentController.updateCourse(request);

        assertEquals("error", response.get("status"));
        assertEquals("Course not found", response.get("message"));
    }

    @Test
    public void testUpdateCourse_DuplicateCode() {
        Map<String, String> request = new HashMap<>();
        request.put("courseId", "2");
        request.put("courseCode", "CSE233");
        Course course = new Course("OTHER", "Title", "Desc", 3);
        course.setCourseId(2);

        when(courseRepository.findById(2)).thenReturn(Optional.of(course));
        when(courseRepository.existsByCourseCode("CSE233")).thenReturn(true);

        Map<String, String> response = departmentController.updateCourse(request);

        assertEquals("error", response.get("status"));
        assertEquals("Course with this code already exists", response.get("message"));
    }

    @Test
    public void testUpdateCourse_Exception() {
        Map<String, String> request = new HashMap<>();
        request.put("courseId", "badId");
        Map<String, String> response = departmentController.updateCourse(request);

        assertEquals("error", response.get("status"));
        assertTrue(response.get("message").startsWith("Error updating course:"));
    }

    // --- Delete Course ---
    @Test
    public void testDeleteCourse_Success() {
        Map<String, String> request = new HashMap<>();
        request.put("courseId", "3");
        Course course = new Course("CSE112", "Org", "Desc", 2);
        course.setCourseId(3);

        when(courseRepository.findById(3)).thenReturn(Optional.of(course));
        doNothing().when(courseRepository).delete(course);

        Map<String, String> response = departmentController.deleteCourse(request);

        assertEquals("success", response.get("status"));
        assertEquals("Course 'CSE112' deleted successfully", response.get("message"));
    }

    @Test
    public void testDeleteCourse_NotFound() {
        Map<String, String> request = new HashMap<>();
        request.put("courseId", "77");
        when(courseRepository.findById(77)).thenReturn(Optional.empty());

        Map<String, String> response = departmentController.deleteCourse(request);

        assertEquals("error", response.get("status"));
        assertEquals("Course not found", response.get("message"));
    }

    @Test
    public void testDeleteCourse_Exception() {
        Map<String, String> request = new HashMap<>();
        request.put("courseId", "badid");
        Map<String, String> response = departmentController.deleteCourse(request);

        assertEquals("error", response.get("status"));
        assertTrue(response.get("message").startsWith("Error deleting course:"));
    }

    @Test
    public void testGetAllInstructors_Success() {
        User instructor1 = new User();
        instructor1.setUserId(1);
        instructor1.setRole("instructor");
        User instructor2 = new User();
        instructor2.setUserId(2);
        instructor2.setRole("instructor");
        List<User> instructors = Arrays.asList(instructor1, instructor2);

        when(userRepository.findByRole("instructor")).thenReturn(instructors);

        Map<String, Object> response = departmentController.getAllInstructors();

        assertEquals("success", response.get("status"));
        List<User> resultInstructors = (List<User>) response.get("instructors");
        assertEquals(2, resultInstructors.size());
        assertEquals(2, response.get("count"));
    }


}