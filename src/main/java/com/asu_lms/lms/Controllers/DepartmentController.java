package com.asu_lms.lms.Controllers;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.asu_lms.lms.Entities.Course;
import com.asu_lms.lms.Entities.Department;
import com.asu_lms.lms.Entities.Instructor;
import com.asu_lms.lms.Entities.User;
import com.asu_lms.lms.Repositories.CourseRepository;
import com.asu_lms.lms.Repositories.DepartmentRepository;
import com.asu_lms.lms.Repositories.InstructorRepository;
import com.asu_lms.lms.Repositories.UserRepository;

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
    
    @Autowired
    private InstructorRepository instructorRepository;

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
        String departmentCode = request.get("departmentCode");
        String unitHeadIdStr = request.get("unitHeadId");
        
        Map<String, String> response = new HashMap<>();
        
        try {
            // Validate required fields
            if (name == null || name.trim().isEmpty()) {
                response.put("status", "error");
                response.put("message", "Department name is required");
                return response;
            }
            
            if (departmentCode == null || departmentCode.trim().isEmpty()) {
                response.put("status", "error");
                response.put("message", "Department code is required");
                return response;
            }
            
            // Check if department name already exists
            if (departmentRepository.existsByName(name)) {
                response.put("status", "error");
                response.put("message", "Department with this name already exists");
                return response;
            }
            
            // Check if department code already exists
            if (departmentRepository.existsByDepartmentCode(departmentCode)) {
                response.put("status", "error");
                response.put("message", "Department with this code already exists");
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
            
            Department department = new Department(departmentCode.trim().toUpperCase(), name, unitHeadId);
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
        String departmentCode = request.get("departmentCode");
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
            if (name != null && !name.trim().isEmpty() && 
                !department.getName().equals(name) && departmentRepository.existsByName(name)) {
                response.put("status", "error");
                response.put("message", "Department with this name already exists");
                return response;
            }
            
            // Check if new department code conflicts with existing departments
            if (departmentCode != null && !departmentCode.trim().isEmpty() &&
                !department.getDepartmentCode().equals(departmentCode) && 
                departmentRepository.existsByDepartmentCode(departmentCode)) {
                response.put("status", "error");
                response.put("message", "Department with this code already exists");
                return response;
            }
            
            if (name != null && !name.trim().isEmpty()) {
                department.setName(name);
            }
            
            if (departmentCode != null && !departmentCode.trim().isEmpty()) {
                department.setDepartmentCode(departmentCode.trim().toUpperCase());
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
        String departmentCode = request.get("departmentCode"); // Required: primary department code
        
        Map<String, String> response = new HashMap<>();
        
        try {
            // Validate required fields
            if (courseCode == null || courseCode.trim().isEmpty()) {
                response.put("status", "error");
                response.put("message", "Course code is required");
                return response;
            }
            
            if (departmentCode == null || departmentCode.trim().isEmpty()) {
                response.put("status", "error");
                response.put("message", "Department code is required");
                return response;
            }
            
            // Check if course code already exists
            if (courseRepository.existsByCourseCode(courseCode)) {
                response.put("status", "error");
                response.put("message", "Course with this code already exists");
                return response;
            }
            
            // Verify department exists
            Optional<Department> deptOpt = departmentRepository.findByDepartmentCode(departmentCode.trim().toUpperCase());
            if (deptOpt.isEmpty()) {
                response.put("status", "error");
                response.put("message", "Department with code '" + departmentCode + "' not found");
                return response;
            }
            
            Integer credits = Integer.parseInt(creditsStr);
            
            Course course;
            if (courseType != null && !courseType.trim().isEmpty()) {
                course = new Course(courseCode, title, description, credits, courseType, departmentCode.trim().toUpperCase());
            } else {
                course = new Course(courseCode, title, description, credits, departmentCode.trim().toUpperCase());
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
        String departmentCode = request.get("departmentCode"); // Optional: primary department code
        
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
            if (courseCode != null && !courseCode.trim().isEmpty() &&
                !course.getCourseCode().equals(courseCode) && courseRepository.existsByCourseCode(courseCode)) {
                response.put("status", "error");
                response.put("message", "Course with this code already exists");
                return response;
            }
            
            // Verify department exists if department code is being updated
            if (departmentCode != null && !departmentCode.trim().isEmpty()) {
                Optional<Department> deptOpt = departmentRepository.findByDepartmentCode(departmentCode.trim().toUpperCase());
                if (deptOpt.isEmpty()) {
                    response.put("status", "error");
                    response.put("message", "Department with code '" + departmentCode + "' not found");
                    return response;
                }
                course.setDepartmentCode(departmentCode.trim().toUpperCase());
            }
            
            if (courseCode != null && !courseCode.trim().isEmpty()) {
                course.setCourseCode(courseCode);
            }
            if (title != null) {
                course.setTitle(title);
            }
            if (description != null) {
                course.setDescription(description);
            }
            if (creditsStr != null && !creditsStr.trim().isEmpty()) {
                course.setCredits(Integer.parseInt(creditsStr));
            }
            
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

    // Get courses by department code (from Course table, not DepartmentCourse)
    @GetMapping("/{departmentId}/courses-by-code")
    public Map<String, Object> getCoursesByDepartmentCode(@PathVariable Integer departmentId) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            Optional<Department> deptOpt = departmentRepository.findById(departmentId);
            if (deptOpt.isEmpty()) {
                response.put("status", "error");
                response.put("message", "Department not found");
                return response;
            }
            
            Department department = deptOpt.get();
            String departmentCode = department.getDepartmentCode();
            
            // Get all courses where department_code matches
            List<Course> courses = courseRepository.findByDepartmentCode(departmentCode);
            
            // Convert to response format
            List<Map<String, Object>> coursesList = new ArrayList<>();
            for (Course course : courses) {
                Map<String, Object> courseData = new HashMap<>();
                courseData.put("courseId", course.getCourseId());
                courseData.put("courseCode", course.getCourseCode());
                courseData.put("title", course.getTitle());
                courseData.put("description", course.getDescription());
                courseData.put("credits", course.getCredits());
                courseData.put("courseType", course.getCourseType());
                courseData.put("departmentCode", course.getDepartmentCode());
                coursesList.add(courseData);
            }
            
            response.put("status", "success");
            response.put("courses", coursesList);
            response.put("count", coursesList.size());
            
        } catch (Exception e) {
            response.put("status", "error");
            response.put("message", "Error fetching courses: " + e.getMessage());
        }
        
        return response;
    }

    // Get all instructors (for unit head selection)
    @GetMapping("/instructors")
    public Map<String, Object> getAllInstructors() {
        List<User> instructorUsers = userRepository.findByRole("instructor");
        
        // Enhance with instructor details
        List<Map<String, Object>> enhancedInstructors = new ArrayList<>();
        for (User user : instructorUsers) {
            Map<String, Object> instructorData = new HashMap<>();
            instructorData.put("userId", user.getUserId());
            instructorData.put("name", user.getName());
            instructorData.put("email", user.getEmail());
            instructorData.put("officialMail", user.getOfficialMail());
            instructorData.put("phone", user.getPhone());
            instructorData.put("location", user.getLocation());
            instructorData.put("nationalId", user.getNationalId());
            instructorData.put("role", user.getRole());
            
            // Get instructor-specific data
            Optional<Instructor> instructorOpt = instructorRepository.findByInstructorId(user.getUserId());
            if (instructorOpt.isPresent()) {
                Instructor instructor = instructorOpt.get();
                instructorData.put("instructorType", instructor.getInstructorType());
                instructorData.put("officeHours", instructor.getOfficeHours());
                instructorData.put("departmentId", instructor.getDepartmentId());
            }
            
            enhancedInstructors.add(instructorData);
        }
        
        Map<String, Object> response = new HashMap<>();
        response.put("status", "success");
        response.put("instructors", enhancedInstructors);
        response.put("count", enhancedInstructors.size());
        
        return response;
    }
}



