package com.asu_lms.lms.Controllers;

import com.asu_lms.lms.Entities.Department;
import com.asu_lms.lms.Entities.Course;
import com.asu_lms.lms.Entities.User;
import com.asu_lms.lms.Repositories.DepartmentRepository;
import com.asu_lms.lms.Repositories.CourseRepository;
import com.asu_lms.lms.Repositories.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import java.util.*;

@RestController
@RequestMapping("/api/admin/departments")
@CrossOrigin(origins = "*")
public class DepartmentController {

    @Autowired
    private DepartmentRepository departmentRepository;
    
    @Autowired
    private CourseRepository courseRepository;
    
    @Autowired
    private UserRepository userRepository;

    // Get all departments
    @GetMapping("/all")
    public Map<String, Object> getAllDepartments() {
        List<Department> departments = departmentRepository.findAll();
        
        Map<String, Object> response = new HashMap<>();
        response.put("status", "success");
        response.put("departments", departments);
        response.put("count", departments.size());
        
        return response;
    }

    // Create new department
    @PostMapping("/create")
    public Map<String, String> createDepartment(@RequestBody Map<String, String> request) {
        String name = request.get("name");
        String unitHeadIdStr = request.get("unitHeadId");
        
        Map<String, String> response = new HashMap<>();
        
        try {
            // Check if department name already exists
            if (departmentRepository.existsByName(name)) {
                response.put("status", "error");
                response.put("message", "Department with this name already exists");
                return response;
            }
            
            Integer unitHeadId = null;
            if (unitHeadIdStr != null && !unitHeadIdStr.trim().isEmpty()) {
                unitHeadId = Integer.parseInt(unitHeadIdStr);
                
                // Verify the user exists and is an instructor
                Optional<User> userOpt = userRepository.findById(unitHeadId);
                if (userOpt.isEmpty() || !"instructor".equals(userOpt.get().getRole())) {
                    response.put("status", "error");
                    response.put("message", "Unit head must be an instructor");
                    return response;
                }
            }
            
            Department department = new Department(name, unitHeadId);
            departmentRepository.save(department);
            
            response.put("status", "success");
            response.put("message", "Department created successfully");
            
        } catch (Exception e) {
            response.put("status", "error");
            response.put("message", "Error creating department: " + e.getMessage());
        }
        
        return response;
    }

    // Update department
    @PostMapping("/update")
    public Map<String, String> updateDepartment(@RequestBody Map<String, String> request) {
        String departmentIdStr = request.get("departmentId");
        String name = request.get("name");
        String unitHeadIdStr = request.get("unitHeadId");
        
        Map<String, String> response = new HashMap<>();
        
        try {
            Integer departmentId = Integer.parseInt(departmentIdStr);
            Optional<Department> departmentOpt = departmentRepository.findById(departmentId);
            
            if (departmentOpt.isEmpty()) {
                response.put("status", "error");
                response.put("message", "Department not found");
                return response;
            }
            
            Department department = departmentOpt.get();
            
            // Check if new name conflicts with existing departments
            if (!department.getName().equals(name) && departmentRepository.existsByName(name)) {
                response.put("status", "error");
                response.put("message", "Department with this name already exists");
                return response;
            }
            
            department.setName(name);
            
            Integer unitHeadId = null;
            if (unitHeadIdStr != null && !unitHeadIdStr.trim().isEmpty()) {
                unitHeadId = Integer.parseInt(unitHeadIdStr);
                
                // Verify the user exists and is an instructor
                Optional<User> userOpt = userRepository.findById(unitHeadId);
                if (userOpt.isEmpty() || !"instructor".equals(userOpt.get().getRole())) {
                    response.put("status", "error");
                    response.put("message", "Unit head must be an instructor");
                    return response;
                }
            }
            
            department.setUnitHeadId(unitHeadId);
            departmentRepository.save(department);
            
            response.put("status", "success");
            response.put("message", "Department updated successfully");
            
        } catch (Exception e) {
            response.put("status", "error");
            response.put("message", "Error updating department: " + e.getMessage());
        }
        
        return response;
    }

    // Delete department
    @PostMapping("/delete")
    public Map<String, String> deleteDepartment(@RequestBody Map<String, String> request) {
        String departmentIdStr = request.get("departmentId");
        
        Map<String, String> response = new HashMap<>();
        
        try {
            Integer departmentId = Integer.parseInt(departmentIdStr);
            Optional<Department> departmentOpt = departmentRepository.findById(departmentId);
            
            if (departmentOpt.isEmpty()) {
                response.put("status", "error");
                response.put("message", "Department not found");
                return response;
            }
            
            Department department = departmentOpt.get();
            String departmentName = department.getName();
            
            departmentRepository.delete(department);
            
            response.put("status", "success");
            response.put("message", "Department '" + departmentName + "' deleted successfully");
            
        } catch (Exception e) {
            response.put("status", "error");
            response.put("message", "Error deleting department: " + e.getMessage());
        }
        
        return response;
    }

    // Get all courses
    @GetMapping("/courses/all")
    public Map<String, Object> getAllCourses(@RequestParam(required = false) String search,
                                             @RequestParam(required = false) String courseType) {
        List<Course> courses;
        
        if (search != null && !search.trim().isEmpty()) {
            // Search by title
            courses = courseRepository.findByTitleContaining(search);
        } else {
            courses = courseRepository.findAll();
        }
        
        // Filter by course type if provided
        if (courseType != null && !courseType.trim().isEmpty()) {
            courses = courses.stream()
                .filter(c -> courseType.equalsIgnoreCase(c.getCourseType()))
                .collect(java.util.stream.Collectors.toList());
        }
        
        Map<String, Object> response = new HashMap<>();
        response.put("status", "success");
        response.put("courses", courses);
        response.put("count", courses.size());
        
        return response;
    }

    // Create new course
    @PostMapping("/courses/create")
    public Map<String, String> createCourse(@RequestBody Map<String, String> request) {
        String courseCode = request.get("courseCode");
        String title = request.get("title");
        String description = request.get("description");
        String creditsStr = request.get("credits");
        String courseType = request.get("courseType"); // Optional: 'core' or 'elective'
        
        Map<String, String> response = new HashMap<>();
        
        try {
            // Check if course code already exists
            if (courseRepository.existsByCourseCode(courseCode)) {
                response.put("status", "error");
                response.put("message", "Course with this code already exists");
                return response;
            }
            
            Integer credits = Integer.parseInt(creditsStr);
            
            Course course;
            if (courseType != null && !courseType.trim().isEmpty()) {
                course = new Course(courseCode, title, description, credits, courseType);
            } else {
                course = new Course(courseCode, title, description, credits);
            }
            courseRepository.save(course);
            
            response.put("status", "success");
            response.put("message", "Course created successfully");
            
        } catch (Exception e) {
            response.put("status", "error");
            response.put("message", "Error creating course: " + e.getMessage());
        }
        
        return response;
    }

    // Update course
    @PostMapping("/courses/update")
    public Map<String, String> updateCourse(@RequestBody Map<String, String> request) {
        String courseIdStr = request.get("courseId");
        String courseCode = request.get("courseCode");
        String title = request.get("title");
        String description = request.get("description");
        String creditsStr = request.get("credits");
        String courseType = request.get("courseType"); // Optional: 'core' or 'elective'
        
        Map<String, String> response = new HashMap<>();
        
        try {
            Integer courseId = Integer.parseInt(courseIdStr);
            Optional<Course> courseOpt = courseRepository.findById(courseId);
            
            if (courseOpt.isEmpty()) {
                response.put("status", "error");
                response.put("message", "Course not found");
                return response;
            }
            
            Course course = courseOpt.get();
            
            // Check if new course code conflicts with existing courses
            if (!course.getCourseCode().equals(courseCode) && courseRepository.existsByCourseCode(courseCode)) {
                response.put("status", "error");
                response.put("message", "Course with this code already exists");
                return response;
            }
            
            course.setCourseCode(courseCode);
            course.setTitle(title);
            course.setDescription(description);
            course.setCredits(Integer.parseInt(creditsStr));
            
            if (courseType != null) {
                course.setCourseType(courseType.isEmpty() ? null : courseType);
            }
            
            courseRepository.save(course);
            
            response.put("status", "success");
            response.put("message", "Course updated successfully");
            
        } catch (Exception e) {
            response.put("status", "error");
            response.put("message", "Error updating course: " + e.getMessage());
        }
        
        return response;
    }

    // Delete course
    @PostMapping("/courses/delete")
    public Map<String, String> deleteCourse(@RequestBody Map<String, String> request) {
        String courseIdStr = request.get("courseId");
        
        Map<String, String> response = new HashMap<>();
        
        try {
            Integer courseId = Integer.parseInt(courseIdStr);
            Optional<Course> courseOpt = courseRepository.findById(courseId);
            
            if (courseOpt.isEmpty()) {
                response.put("status", "error");
                response.put("message", "Course not found");
                return response;
            }
            
            Course course = courseOpt.get();
            String courseCode = course.getCourseCode();
            
            courseRepository.delete(course);
            
            response.put("status", "success");
            response.put("message", "Course '" + courseCode + "' deleted successfully");
            
        } catch (Exception e) {
            response.put("status", "error");
            response.put("message", "Error deleting course: " + e.getMessage());
        }
        
        return response;
    }

    // Get all instructors (for unit head selection)
    @GetMapping("/instructors")
    public Map<String, Object> getAllInstructors() {
        List<User> instructors = userRepository.findByRole("instructor");
        
        Map<String, Object> response = new HashMap<>();
        response.put("status", "success");
        response.put("instructors", instructors);
        response.put("count", instructors.size());
        
        return response;
    }
}



