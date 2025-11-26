package com.asu_lms.lms.Services;

import com.asu_lms.lms.Entities.*;
import com.asu_lms.lms.Repositories.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.*;

@Service
public class CourseManagementService {
    
    @Autowired
    private OfferedCourseRepository offeredCourseRepository;
    
    @Autowired
    private OfferedCourseInstructorRepository offeredCourseInstructorRepository;
    
    @Autowired
    private CourseRepository courseRepository;
    
    @Autowired
    private InstructorRepository instructorRepository;
    
    @Autowired
    private DepartmentCourseRepository departmentCourseRepository;
    
    @Autowired
    private DepartmentRepository departmentRepository;
    
    @Autowired
    private StudentRepository studentRepository;
    
    @Autowired
    private UserRepository userRepository;
    
    /**
     * Get all departments
     */
    public List<Map<String, Object>> getAllDepartments() {
        List<Department> departments = departmentRepository.findAll();
        List<Map<String, Object>> result = new ArrayList<>();
        
        for (Department dept : departments) {
            Map<String, Object> deptData = new HashMap<>();
            deptData.put("departmentId", dept.getDepartmentId());
            deptData.put("name", dept.getName());
            deptData.put("unitHeadId", dept.getUnitHeadId());
            result.add(deptData);
        }
        
        return result;
    }
    
    /**
     * Get courses for a specific department
     */
    public List<Map<String, Object>> getCoursesByDepartment(Integer departmentId) {
        List<DepartmentCourse> departmentCourses = departmentCourseRepository.findByDepartmentId(departmentId);
        List<Map<String, Object>> result = new ArrayList<>();
        
        for (DepartmentCourse dc : departmentCourses) {
            Optional<Course> courseOpt = courseRepository.findById(dc.getCourseId());
            if (courseOpt.isPresent()) {
                Course course = courseOpt.get();
                Map<String, Object> courseData = new HashMap<>();
                courseData.put("courseId", course.getCourseId());
                courseData.put("courseCode", course.getCourseCode());
                courseData.put("title", course.getTitle());
                courseData.put("credits", course.getCredits());
                courseData.put("courseType", dc.getCourseType());
                courseData.put("description", course.getDescription());
                result.add(courseData);
            }
        }
        
        return result;
    }
    
    /**
     * Get instructors for a specific department
     * Filters instructors to only show those who belong to the department
     */
    public List<Map<String, Object>> getInstructorsByDepartment(Integer departmentId) {
        Optional<Department> deptOpt = departmentRepository.findById(departmentId);
        if (!deptOpt.isPresent()) {
            return new ArrayList<>();
        }
        
        Department department = deptOpt.get();
        List<Map<String, Object>> result = new ArrayList<>();
        
        // Get all instructors and filter by department
        List<Instructor> allInstructors = instructorRepository.findAll();
        
        for (Instructor instructor : allInstructors) {
            // Only include instructors that belong to this department
            if (instructor.getDepartmentId() != null && 
                instructor.getDepartmentId().equals(departmentId)) {
                
                // Get the user info
                Optional<User> userOpt = userRepository.findById(instructor.getInstructorId());
                if (userOpt.isPresent()) {
                    User user = userOpt.get();
                    Map<String, Object> instructorData = new HashMap<>();
                    instructorData.put("instructorId", instructor.getInstructorId());
                    instructorData.put("name", user.getName());
                    instructorData.put("email", user.getEmail());
                    instructorData.put("instructorType", instructor.getInstructorType());
                    instructorData.put("officeHours", instructor.getOfficeHours());
                    instructorData.put("departmentId", instructor.getDepartmentId());
                    result.add(instructorData);
                }
            }
        }
        
        return result;
    }
    
    /**
     * Get offered courses for a specific semester
     */
    public List<Map<String, Object>> getOfferedCoursesBySemester(Integer semesterId, Integer departmentId) {
        List<Map<String, Object>> result = new ArrayList<>();
        
        // Get all offered courses for this semester
        for (OfferedCourse oc : offeredCourseRepository.findAll()) {
            if (!oc.getSemesterId().equals(semesterId)) continue;
            
            Optional<Course> courseOpt = courseRepository.findById(oc.getCourseId());
            if (!courseOpt.isPresent()) continue;
            
            Course course = courseOpt.get();
            
            // Check if course belongs to this department
            if (!departmentCourseRepository.existsByDepartmentIdAndCourseId(departmentId, oc.getCourseId())) {
                continue;
            }
            
            Map<String, Object> courseData = new HashMap<>();
            courseData.put("offeredCourseId", oc.getOfferedCourseId());
            courseData.put("courseId", course.getCourseId());
            courseData.put("courseCode", course.getCourseCode());
            courseData.put("title", course.getTitle());
            courseData.put("credits", course.getCredits());
            courseData.put("semesterId", oc.getSemesterId());
            
            // Get assigned instructor
            List<OfferedCourseInstructor> instructors = offeredCourseInstructorRepository
                .findByOfferedCourseId(oc.getOfferedCourseId());
            
            if (!instructors.isEmpty()) {
                OfferedCourseInstructor oci = instructors.get(0);
                Optional<Instructor> instOpt = instructorRepository.findByInstructorId(oci.getInstructorId());
                if (instOpt.isPresent()) {
                    Instructor instructor = instOpt.get();
                    Optional<User> userOpt = userRepository.findById(instructor.getInstructorId());
                    if (userOpt.isPresent()) {
                        Map<String, Object> instData = new HashMap<>();
                        instData.put("instructorId", instructor.getInstructorId());
                        instData.put("name", userOpt.get().getName());
                        courseData.put("instructor", instData);
                    }
                }
            } else {
                courseData.put("instructor", null);
            }
            
            result.add(courseData);
        }
        
        return result;
    }
    
    /**
     * Create an offered course (mark a course as offered in a semester)
     */
    public Map<String, Object> createOfferedCourse(Integer courseId, Integer semesterId) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            // Check if course exists
            Optional<Course> courseOpt = courseRepository.findById(courseId);
            if (!courseOpt.isPresent()) {
                response.put("status", "error");
                response.put("message", "Course not found");
                return response;
            }
            
            // Check if course is already offered in this semester
            List<OfferedCourse> existing = offeredCourseRepository.findByCourseId(courseId);
            for (OfferedCourse oc : existing) {
                if (oc.getSemesterId().equals(semesterId)) {
                    response.put("status", "error");
                    response.put("message", "Course is already offered in this semester");
                    return response;
                }
            }
            
            // Create offered course
            OfferedCourse offeredCourse = new OfferedCourse(courseId, semesterId);
            OfferedCourse saved = offeredCourseRepository.save(offeredCourse);
            
            response.put("status", "success");
            response.put("message", "Course offered successfully");
            response.put("offeredCourseId", saved.getOfferedCourseId());
            
        } catch (Exception e) {
            response.put("status", "error");
            response.put("message", "Error creating offered course: " + e.getMessage());
        }
        
        return response;
    }
    
    /**
     * Assign an instructor to an offered course
     * Validates that:
     * 1. For Department Courses: Course belongs to department and Instructor belongs to same department
     * 2. For ASU Courses: Any instructor can teach (no department restriction)
     * This ensures department instructors cannot teach courses outside their department
     */
    public Map<String, Object> assignInstructorToCourse(Integer offeredCourseId, Integer instructorId, Integer departmentId) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            // Check if offered course exists
            Optional<OfferedCourse> offeredCourseOpt = offeredCourseRepository.findById(offeredCourseId);
            if (!offeredCourseOpt.isPresent()) {
                response.put("status", "error");
                response.put("message", "Offered course not found");
                return response;
            }
            
            OfferedCourse offeredCourse = offeredCourseOpt.get();
            
            // Get the course to check if it's ASU or department course
            Optional<Course> courseOpt = courseRepository.findById(offeredCourse.getCourseId());
            if (!courseOpt.isPresent()) {
                response.put("status", "error");
                response.put("message", "Course not found");
                return response;
            }
            
            Course course = courseOpt.get();
            
            // Validate course belongs to the department
            boolean belongsToDepartment = departmentCourseRepository
                .existsByDepartmentIdAndCourseId(departmentId, offeredCourse.getCourseId());
            
            if (!belongsToDepartment) {
                response.put("status", "error");
                response.put("message", "Course does not belong to the specified department");
                return response;
            }
            
            // Check if instructor exists
            Optional<Instructor> instructorOpt = instructorRepository.findByInstructorId(instructorId);
            if (!instructorOpt.isPresent()) {
                response.put("status", "error");
                response.put("message", "Instructor not found");
                return response;
            }
            
            Instructor instructor = instructorOpt.get();
            
            // Validate instructor belongs to the selected department
            if (instructor.getDepartmentId() == null) {
                response.put("status", "error");
                response.put("message", "Instructor has no department assigned");
                return response;
            }
            
            if (!instructor.getDepartmentId().equals(departmentId)) {
                // Get department names for error message
                Optional<Department> selectedDeptOpt = departmentRepository.findById(departmentId);
                Optional<Department> instructorDeptOpt = departmentRepository.findById(instructor.getDepartmentId());
                
                String selectedDeptName = selectedDeptOpt.isPresent() ? selectedDeptOpt.get().getName() : "Unknown";
                String instructorDeptName = instructorDeptOpt.isPresent() ? instructorDeptOpt.get().getName() : "Unknown";
                String instructorName = userRepository.findById(instructorId)
                    .map(User::getName)
                    .orElse("Unknown");
                
                response.put("status", "error");
                response.put("message", 
                    "Instructor '" + instructorName + "' from '" + instructorDeptName + 
                    "' cannot teach courses in '" + selectedDeptName + "' department. " +
                    "Instructors can only teach courses from their own department.");
                return response;
            }
            
            // Check if instructor is already assigned to this course
            Optional<OfferedCourseInstructor> existing = offeredCourseInstructorRepository
                .findByOfferedCourseIdAndInstructorId(offeredCourseId, instructorId);
            
            if (existing.isPresent()) {
                response.put("status", "error");
                response.put("message", "Instructor is already assigned to this course");
                return response;
            }
            
            // Remove any existing instructors for this course (one instructor per course)
            List<OfferedCourseInstructor> existingInstructors = offeredCourseInstructorRepository
                .findByOfferedCourseId(offeredCourseId);
            for (OfferedCourseInstructor oci : existingInstructors) {
                offeredCourseInstructorRepository.delete(oci);
            }
            
            // Assign instructor
            OfferedCourseInstructor oci = new OfferedCourseInstructor(offeredCourseId, instructorId);
            offeredCourseInstructorRepository.save(oci);
            
            response.put("status", "success");
            response.put("message", "Instructor assigned successfully");
            
        } catch (Exception e) {
            response.put("status", "error");
            response.put("message", "Error assigning instructor: " + e.getMessage());
        }
        
        return response;
    }
    
    /**
     * Remove an offered course
     */
    public Map<String, Object> removeOfferedCourse(Integer offeredCourseId) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            Optional<OfferedCourse> offeredCourseOpt = offeredCourseRepository.findById(offeredCourseId);
            if (!offeredCourseOpt.isPresent()) {
                response.put("status", "error");
                response.put("message", "Offered course not found");
                return response;
            }
            
            // Remove all instructor assignments
            List<OfferedCourseInstructor> instructors = offeredCourseInstructorRepository
                .findByOfferedCourseId(offeredCourseId);
            for (OfferedCourseInstructor oci : instructors) {
                offeredCourseInstructorRepository.delete(oci);
            }
            
            // Remove offered course
            offeredCourseRepository.delete(offeredCourseOpt.get());
            
            response.put("status", "success");
            response.put("message", "Offered course removed successfully");
            
        } catch (Exception e) {
            response.put("status", "error");
            response.put("message", "Error removing offered course: " + e.getMessage());
        }
        
        return response;
    }
}
