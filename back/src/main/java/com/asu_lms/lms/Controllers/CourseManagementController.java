package com.asu_lms.lms.Controllers;

import com.asu_lms.lms.Entities.*;
import com.asu_lms.lms.Repositories.*;
import com.asu_lms.lms.Services.CourseManagementService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import java.util.*;

@RestController
@RequestMapping("/api/admin/courses")
@CrossOrigin(origins = "*")
public class CourseManagementController {

    @Autowired
    private CourseRepository courseRepository;
    
    @Autowired
    private PrerequisiteRepository prerequisiteRepository;
    
    @Autowired
    private DepartmentCourseRepository departmentCourseRepository;
    
    @Autowired
    private DepartmentRepository departmentRepository;
    
    @Autowired
    private CourseManagementService courseManagementService;
    
    @Autowired
    private OfferedCourseRepository offeredCourseRepository;
    
    @Autowired
    private OfferedCourseInstructorRepository offeredCourseInstructorRepository;
    
    @Autowired
    private SemesterRepository semesterRepository;
    
    @Autowired
    private InstructorRepository instructorRepository;
    
    @Autowired
    private UserRepository userRepository;

    // ========== PREREQUISITE MANAGEMENT ==========
    
    // Get all prerequisites for a course
    @GetMapping("/{courseId}/prerequisites")
    public Map<String, Object> getPrerequisites(@PathVariable Integer courseId) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            Optional<Course> courseOpt = courseRepository.findById(courseId);
            if (courseOpt.isEmpty()) {
                response.put("status", "error");
                response.put("message", "Course not found");
                return response;
            }
            
            List<Prerequisite> prerequisites = prerequisiteRepository.findByCourseId(courseId);
            
            // Enrich prerequisites with course details
            List<Map<String, Object>> enrichedPrerequisites = new ArrayList<>();
            for (Prerequisite prereq : prerequisites) {
                Map<String, Object> prereqData = new HashMap<>();
                prereqData.put("courseId", prereq.getCourseId());
                prereqData.put("prereqCourseId", prereq.getPrereqCourseId());
                
                // Get prerequisite course details
                Optional<Course> prereqCourseOpt = courseRepository.findById(prereq.getPrereqCourseId());
                if (prereqCourseOpt.isPresent()) {
                    Course prereqCourse = prereqCourseOpt.get();
                    Map<String, Object> courseData = new HashMap<>();
                    courseData.put("courseId", prereqCourse.getCourseId());
                    courseData.put("courseCode", prereqCourse.getCourseCode());
                    courseData.put("title", prereqCourse.getTitle());
                    courseData.put("description", prereqCourse.getDescription());
                    courseData.put("credits", prereqCourse.getCredits());
                    courseData.put("courseType", prereqCourse.getCourseType());
                    prereqData.put("prereqCourse", courseData);
                }
                
                enrichedPrerequisites.add(prereqData);
            }
            
            response.put("status", "success");
            response.put("prerequisites", enrichedPrerequisites);
            response.put("count", enrichedPrerequisites.size());
            
        } catch (Exception e) {
            response.put("status", "error");
            response.put("message", "Error fetching prerequisites: " + e.getMessage());
        }
        
        return response;
    }
    
    // Add prerequisite
    @PostMapping("/prerequisites/add")
    public Map<String, String> addPrerequisite(@RequestBody Map<String, String> request) {
        String courseIdStr = request.get("courseId");
        String prereqCourseIdStr = request.get("prereqCourseId");
        
        Map<String, String> response = new HashMap<>();
        
        try {
            Integer courseId = Integer.parseInt(courseIdStr);
            Integer prereqCourseId = Integer.parseInt(prereqCourseIdStr);
            
            // Check if course and prerequisite course exist
            Optional<Course> courseOpt = courseRepository.findById(courseId);
            Optional<Course> prereqOpt = courseRepository.findById(prereqCourseId);
            
            if (courseOpt.isEmpty() || prereqOpt.isEmpty()) {
                response.put("status", "error");
                response.put("message", "Course or prerequisite course not found");
                return response;
            }
            
            // Prevent self-reference
            if (courseId.equals(prereqCourseId)) {
                response.put("status", "error");
                response.put("message", "A course cannot be a prerequisite of itself");
                return response;
            }
            
            // Check if prerequisite already exists
            if (prerequisiteRepository.existsByCourseIdAndPrereqCourseId(courseId, prereqCourseId)) {
                response.put("status", "error");
                response.put("message", "This prerequisite already exists");
                return response;
            }
            
            // Check for circular dependency
            if (hasCircularDependency(courseId, prereqCourseId)) {
                response.put("status", "error");
                response.put("message", "Adding this prerequisite would create a circular dependency");
                return response;
            }
            
            Prerequisite prerequisite = new Prerequisite(courseId, prereqCourseId);
            prerequisiteRepository.save(prerequisite);
            
            response.put("status", "success");
            response.put("message", "Prerequisite added successfully");
            
        } catch (Exception e) {
            response.put("status", "error");
            response.put("message", "Error adding prerequisite: " + e.getMessage());
        }
        
        return response;
    }
    
    // Remove prerequisite
    @PostMapping("/prerequisites/remove")
    public Map<String, String> removePrerequisite(@RequestBody Map<String, String> request) {
        String courseIdStr = request.get("courseId");
        String prereqCourseIdStr = request.get("prereqCourseId");
        
        Map<String, String> response = new HashMap<>();
        
        try {
            Integer courseId = Integer.parseInt(courseIdStr);
            Integer prereqCourseId = Integer.parseInt(prereqCourseIdStr);
            
            PrerequisiteId id = new PrerequisiteId(courseId, prereqCourseId);
            Optional<Prerequisite> prereqOpt = prerequisiteRepository.findById(id);
            
            if (prereqOpt.isEmpty()) {
                response.put("status", "error");
                response.put("message", "Prerequisite not found");
                return response;
            }
            
            prerequisiteRepository.delete(prereqOpt.get());
            
            response.put("status", "success");
            response.put("message", "Prerequisite removed successfully");
            
        } catch (Exception e) {
            response.put("status", "error");
            response.put("message", "Error removing prerequisite: " + e.getMessage());
        }
        
        return response;
    }
    
    // Helper method to check for circular dependencies using DFS
    private boolean hasCircularDependency(Integer courseId, Integer prereqCourseId) {
        Set<Integer> visited = new HashSet<>();
        return dfsCheckCycle(prereqCourseId, courseId, visited);
    }
    
    private boolean dfsCheckCycle(Integer current, Integer target, Set<Integer> visited) {
        if (current.equals(target)) {
            return true; // Cycle detected
        }
        
        if (visited.contains(current)) {
            return false; // Already visited, no cycle through this path
        }
        
        visited.add(current);
        
        // Get all prerequisites of current course
        List<Prerequisite> prerequisites = prerequisiteRepository.findByCourseId(current);
        for (Prerequisite prereq : prerequisites) {
            if (dfsCheckCycle(prereq.getPrereqCourseId(), target, visited)) {
                return true;
            }
        }
        
        visited.remove(current);
        return false;
    }
    
    // ========== DEPARTMENT-COURSE RELATIONSHIPS ==========
    
    // Link course to department (as core or elective)
    @PostMapping("/departments/link")
    public Map<String, String> linkCourseToDepartment(@RequestBody Map<String, String> request) {
        String departmentIdStr = request.get("departmentId");
        String courseIdStr = request.get("courseId");
        String courseType = request.get("courseType"); // 'core' or 'elective'
        String capacityStr = request.get("capacity");
        String eligibilityRequirements = request.get("eligibilityRequirements");
        
        Map<String, String> response = new HashMap<>();
        
        try {
            Integer departmentId = Integer.parseInt(departmentIdStr);
            Integer courseId = Integer.parseInt(courseIdStr);
            
            // Validate course type
            if (!"core".equals(courseType) && !"elective".equals(courseType)) {
                response.put("status", "error");
                response.put("message", "Course type must be 'core' or 'elective'");
                return response;
            }
            
            // Check if department and course exist
            Optional<Department> deptOpt = departmentRepository.findById(departmentId);
            Optional<Course> courseOpt = courseRepository.findById(courseId);
            
            if (deptOpt.isEmpty() || courseOpt.isEmpty()) {
                response.put("status", "error");
                response.put("message", "Department or course not found");
                return response;
            }
            
            // Check if link already exists
            if (departmentCourseRepository.existsByDepartmentIdAndCourseId(departmentId, courseId)) {
                response.put("status", "error");
                response.put("message", "Course is already linked to this department");
                return response;
            }
            
            DepartmentCourse departmentCourse = new DepartmentCourse(departmentId, courseId, courseType);
            
            if (capacityStr != null && !capacityStr.trim().isEmpty()) {
                departmentCourse.setCapacity(Integer.parseInt(capacityStr));
            }
            
            if (eligibilityRequirements != null && !eligibilityRequirements.trim().isEmpty()) {
                departmentCourse.setEligibilityRequirements(eligibilityRequirements);
            }
            
            departmentCourseRepository.save(departmentCourse);
            
            response.put("status", "success");
            response.put("message", "Course linked to department successfully");
            
        } catch (Exception e) {
            response.put("status", "error");
            response.put("message", "Error linking course to department: " + e.getMessage());
        }
        
        return response;
    }
    
    // Update department-course relationship
    @PostMapping("/departments/update-link")
    public Map<String, String> updateDepartmentCourseLink(@RequestBody Map<String, String> request) {
        String departmentIdStr = request.get("departmentId");
        String courseIdStr = request.get("courseId");
        String courseType = request.get("courseType");
        String capacityStr = request.get("capacity");
        String eligibilityRequirements = request.get("eligibilityRequirements");
        
        Map<String, String> response = new HashMap<>();
        
        try {
            Integer departmentId = Integer.parseInt(departmentIdStr);
            Integer courseId = Integer.parseInt(courseIdStr);
            
            DepartmentCourseId id = new DepartmentCourseId(departmentId, courseId);
            Optional<DepartmentCourse> dcOpt = departmentCourseRepository.findById(id);
            
            if (dcOpt.isEmpty()) {
                response.put("status", "error");
                response.put("message", "Department-course link not found");
                return response;
            }
            
            DepartmentCourse departmentCourse = dcOpt.get();
            
            if (courseType != null && !courseType.trim().isEmpty()) {
                if (!"core".equals(courseType) && !"elective".equals(courseType)) {
                    response.put("status", "error");
                    response.put("message", "Course type must be 'core' or 'elective'");
                    return response;
                }
                departmentCourse.setCourseType(courseType);
            }
            
            if (capacityStr != null && !capacityStr.trim().isEmpty()) {
                departmentCourse.setCapacity(Integer.parseInt(capacityStr));
            }
            
            if (eligibilityRequirements != null) {
                departmentCourse.setEligibilityRequirements(eligibilityRequirements);
            }
            
            departmentCourseRepository.save(departmentCourse);
            
            response.put("status", "success");
            response.put("message", "Department-course link updated successfully");
            
        } catch (Exception e) {
            response.put("status", "error");
            response.put("message", "Error updating link: " + e.getMessage());
        }
        
        return response;
    }
    
    // Remove course from department
    @PostMapping("/departments/unlink")
    public Map<String, String> unlinkCourseFromDepartment(@RequestBody Map<String, String> request) {
        String departmentIdStr = request.get("departmentId");
        String courseIdStr = request.get("courseId");
        
        Map<String, String> response = new HashMap<>();
        
        try {
            Integer departmentId = Integer.parseInt(departmentIdStr);
            Integer courseId = Integer.parseInt(courseIdStr);
            
            DepartmentCourseId id = new DepartmentCourseId(departmentId, courseId);
            Optional<DepartmentCourse> dcOpt = departmentCourseRepository.findById(id);
            
            if (dcOpt.isEmpty()) {
                response.put("status", "error");
                response.put("message", "Department-course link not found");
                return response;
            }
            
            departmentCourseRepository.delete(dcOpt.get());
            
            response.put("status", "success");
            response.put("message", "Course unlinked from department successfully");
            
        } catch (Exception e) {
            response.put("status", "error");
            response.put("message", "Error unlinking course: " + e.getMessage());
        }
        
        return response;
    }
    
    // Get all courses for a department (with type filter)
    @GetMapping("/departments/{departmentId}/courses")
    public Map<String, Object> getDepartmentCourses(
            @PathVariable Integer departmentId,
            @RequestParam(required = false) String courseType) {
        
        Map<String, Object> response = new HashMap<>();
        
        try {
            Optional<Department> deptOpt = departmentRepository.findById(departmentId);
            if (deptOpt.isEmpty()) {
                response.put("status", "error");
                response.put("message", "Department not found");
                return response;
            }
            
            List<Map<String, Object>> coursesList = new ArrayList<>();
            
            List<DepartmentCourse> departmentCourses;
            if (courseType != null && !courseType.trim().isEmpty()) {
                if ("core".equals(courseType)) {
                    departmentCourses = departmentCourseRepository.findCoreCoursesByDepartmentId(departmentId);
                } else if ("elective".equals(courseType)) {
                    departmentCourses = departmentCourseRepository.findElectiveCoursesByDepartmentId(departmentId);
                } else {
                    departmentCourses = departmentCourseRepository.findByDepartmentIdAndCourseType(departmentId, courseType);
                }
            } else {
                departmentCourses = departmentCourseRepository.findByDepartmentId(departmentId);
            }
            
            // Convert to course objects
            for (DepartmentCourse dc : departmentCourses) {
                Optional<Course> courseOpt = courseRepository.findById(dc.getCourseId());
                if (courseOpt.isPresent()) {
                    Course course = courseOpt.get();
                    Map<String, Object> courseData = new HashMap<>();
                    courseData.put("courseId", course.getCourseId());
                    courseData.put("courseCode", course.getCourseCode());
                    courseData.put("title", course.getTitle());
                    courseData.put("description", course.getDescription());
                    courseData.put("credits", course.getCredits());
                    courseData.put("courseType", dc.getCourseType());
                    coursesList.add(courseData);
                }
            }
            
            response.put("status", "success");
            response.put("courses", coursesList);
            response.put("count", coursesList.size());
            
        } catch (Exception e) {
            response.put("status", "error");
            response.put("message", "Error fetching department courses: " + e.getMessage());
        }
        
        return response;
    }
    
    // Get all core courses for a department
    @GetMapping("/departments/{departmentId}/core-courses")
    public Map<String, Object> getCoreCourses(@PathVariable Integer departmentId) {
        return getDepartmentCourses(departmentId, "core");
    }
    
    // Get all elective courses for a department
    @GetMapping("/departments/{departmentId}/elective-courses")
    public Map<String, Object> getElectiveCourses(@PathVariable Integer departmentId) {
        return getDepartmentCourses(departmentId, "elective");
    }
    
    // ========== COURSE OFFERING MANAGEMENT (NEW) ==========
    
    // Get all departments
    @GetMapping("/departments")
    public Map<String, Object> getAllDepartments() {
        Map<String, Object> response = new HashMap<>();
        try {
            List<Map<String, Object>> departments = courseManagementService.getAllDepartments();
            response.put("status", "success");
            response.put("departments", departments);
            response.put("count", departments.size());
        } catch (Exception e) {
            response.put("status", "error");
            response.put("message", "Error fetching departments: " + e.getMessage());
        }
        return response;
    }
    
    // Get all semesters
    @GetMapping("/semesters")
    public Map<String, Object> getSemesters() {
        Map<String, Object> response = new HashMap<>();
        try {
            List<Semester> semesters = semesterRepository.findAll();
            List<Map<String, Object>> semesterList = new ArrayList<>();
            
            for (Semester sem : semesters) {
                Map<String, Object> semData = new HashMap<>();
                semData.put("semesterId", sem.getSemesterId());
                semData.put("name", sem.getName());
                semData.put("startDate", sem.getStartDate());
                semData.put("endDate", sem.getEndDate());
                semData.put("registrationOpen", sem.getRegistrationOpen());
                semesterList.add(semData);
            }
            
            response.put("status", "success");
            response.put("semesters", semesterList);
            response.put("count", semesterList.size());
        } catch (Exception e) {
            response.put("status", "error");
            response.put("message", "Error fetching semesters: " + e.getMessage());
        }
        return response;
    }
    
    // Get all instructors (for course assignment)
    @GetMapping("/instructors/all")
    public Map<String, Object> getAllInstructors() {
        Map<String, Object> response = new HashMap<>();
        try {
            List<Map<String, Object>> instructors = courseManagementService.getAllInstructors();
            response.put("status", "success");
            response.put("instructors", instructors);
            response.put("count", instructors.size());
        } catch (Exception e) {
            response.put("status", "error");
            response.put("message", "Error fetching instructors: " + e.getMessage());
        }
        return response;
    }
    
    // Get instructors for a specific department (filtered by department)
    @GetMapping("/departments/{departmentId}/instructors")
    public Map<String, Object> getInstructorsByDepartment(@PathVariable Integer departmentId) {
        Map<String, Object> response = new HashMap<>();
        try {
            Optional<Department> deptOpt = departmentRepository.findById(departmentId);
            if (!deptOpt.isPresent()) {
                response.put("status", "error");
                response.put("message", "Department not found");
                return response;
            }
            
            List<Map<String, Object>> instructors = courseManagementService.getInstructorsByDepartment(departmentId);
            response.put("status", "success");
            response.put("instructors", instructors);
            response.put("count", instructors.size());
        } catch (Exception e) {
            response.put("status", "error");
            response.put("message", "Error fetching instructors: " + e.getMessage());
        }
        return response;
    }
    
    // Get offered courses for a specific semester and department
    @GetMapping("/semesters/{semesterId}/departments/{departmentId}/offered-courses")
    public Map<String, Object> getOfferedCourses(
            @PathVariable Integer semesterId, 
            @PathVariable Integer departmentId) {
        Map<String, Object> response = new HashMap<>();
        try {
            List<Map<String, Object>> offeredCourses = courseManagementService
                .getOfferedCoursesBySemester(semesterId, departmentId);
            response.put("status", "success");
            response.put("offeredCourses", offeredCourses);
            response.put("count", offeredCourses.size());
        } catch (Exception e) {
            response.put("status", "error");
            response.put("message", "Error fetching offered courses: " + e.getMessage());
        }
        return response;
    }
    
    // Create an offered course (make a course available in a semester)
    @PostMapping("/offered-courses/create")
    public Map<String, Object> createOfferedCourse(@RequestBody Map<String, Object> request) {
        Map<String, Object> response = new HashMap<>();
        try {
            Object courseIdObj = request.get("courseId");
            Object semesterIdObj = request.get("semesterId");
            
            Integer courseId = null;
            Integer semesterId = null;
            
            if (courseIdObj instanceof String) {
                courseId = Integer.parseInt((String) courseIdObj);
            } else {
                courseId = (Integer) courseIdObj;
            }
            
            if (semesterIdObj instanceof String) {
                semesterId = Integer.parseInt((String) semesterIdObj);
            } else {
                semesterId = (Integer) semesterIdObj;
            }
            
            return courseManagementService.createOfferedCourse(courseId, semesterId);
            
        } catch (Exception e) {
            response.put("status", "error");
            response.put("message", "Error creating offered course: " + e.getMessage());
        }
        return response;
    }
    
    // Assign an instructor to an offered course
    // This validates that the instructor is compatible with the course's department
    @PostMapping("/offered-courses/{offeredCourseId}/assign-instructor")
    public Map<String, Object> assignInstructor(
        @PathVariable Integer offeredCourseId,
        @RequestBody Map<String, Object> request
    ) {
        Map<String, Object> response = new HashMap<>();
        try {
            Object instructorIdObj = request.get("instructorId");
            Object departmentIdObj = request.get("departmentId");
            
            Integer instructorId = null;
            Integer departmentId = null;
            
            if (instructorIdObj instanceof String) {
                instructorId = Integer.parseInt((String) instructorIdObj);
            } else {
                instructorId = (Integer) instructorIdObj;
            }
            
            if (departmentIdObj instanceof String) {
                departmentId = Integer.parseInt((String) departmentIdObj);
            } else {
                departmentId = (Integer) departmentIdObj;
            }
            
            return courseManagementService.assignInstructorToCourse(offeredCourseId, instructorId, departmentId);
            
        } catch (Exception e) {
            response.put("status", "error");
            response.put("message", "Error assigning instructor: " + e.getMessage());
        }
        return response;
    }
    
    // Remove an offered course
    @DeleteMapping("/offered-courses/{offeredCourseId}")
    public Map<String, Object> removeOfferedCourse(@PathVariable Integer offeredCourseId) {
        Map<String, Object> response = new HashMap<>();
        try {
            return courseManagementService.removeOfferedCourse(offeredCourseId);
        } catch (Exception e) {
            response.put("status", "error");
            response.put("message", "Error removing offered course: " + e.getMessage());
        }
        return response;
    }
}

