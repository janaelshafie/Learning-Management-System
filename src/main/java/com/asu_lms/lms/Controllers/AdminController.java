package com.asu_lms.lms.Controllers;

import com.asu_lms.lms.Entities.User;
import com.asu_lms.lms.Entities.Instructor;
import com.asu_lms.lms.Entities.PendingProfileChange;
import com.asu_lms.lms.Entities.Student;
import com.asu_lms.lms.Entities.Enrollment;
import com.asu_lms.lms.Entities.Grade;
import com.asu_lms.lms.Entities.Section;
import com.asu_lms.lms.Entities.OfferedCourse;
import com.asu_lms.lms.Entities.Course;
import com.asu_lms.lms.Entities.Department;
import com.asu_lms.lms.Entities.Semester;
import com.asu_lms.lms.Repositories.UserRepository;
import com.asu_lms.lms.Repositories.InstructorRepository;
import com.asu_lms.lms.Repositories.PendingProfileChangeRepository;
import com.asu_lms.lms.Repositories.StudentRepository;
import com.asu_lms.lms.Repositories.EnrollmentRepository;
import com.asu_lms.lms.Repositories.GradeRepository;
import com.asu_lms.lms.Repositories.SectionRepository;
import com.asu_lms.lms.Repositories.OfferedCourseRepository;
import com.asu_lms.lms.Repositories.CourseRepository;
import com.asu_lms.lms.Repositories.DepartmentRepository;
import com.asu_lms.lms.Repositories.SemesterRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.ArrayList;

@RestController
@RequestMapping("/api/admin")
@CrossOrigin(origins = "*")
public class AdminController {

    @Autowired
    private UserRepository userRepository;
    
    @Autowired
    private InstructorRepository instructorRepository;
    
    @Autowired
    private PendingProfileChangeRepository pendingProfileChangeRepository;

    @Autowired
    private StudentRepository studentRepository;

    @Autowired
    private EnrollmentRepository enrollmentRepository;

    @Autowired
    private GradeRepository gradeRepository;

    @Autowired
    private SectionRepository sectionRepository;

    @Autowired
    private OfferedCourseRepository offeredCourseRepository;

    @Autowired
    private CourseRepository courseRepository;

    @Autowired
    private DepartmentRepository departmentRepository;

    @Autowired
    private SemesterRepository semesterRepository;

    // Get all pending accounts
    @GetMapping("/pending-accounts")
    public Map<String, Object> getPendingAccounts() {
        List<User> pendingUsers = userRepository.findByAccountStatus("pending");
        
        Map<String, Object> response = new HashMap<>();
        response.put("status", "success");
        response.put("pendingAccounts", pendingUsers);
        response.put("count", pendingUsers.size());
        
        return response;
    }

    // Approve an account
    @PostMapping("/approve-account")
    public Map<String, String> approveAccount(@RequestBody Map<String, String> request) {
        String userId = request.get("userId");
        
        Map<String, String> response = new HashMap<>();
        
        try {
            Optional<User> userOpt = userRepository.findById(Integer.parseInt(userId));
            if (userOpt.isPresent()) {
                User user = userOpt.get();
                if ("pending".equals(user.getAccountStatus())) {
                    user.setAccountStatus("active");
                    userRepository.save(user);
                    
                    response.put("status", "success");
                    response.put("message", "Account approved successfully");
                } else {
                    response.put("status", "error");
                    response.put("message", "Account is not in pending status");
                }
            } else {
                response.put("status", "error");
                response.put("message", "User not found");
            }
        } catch (Exception e) {
            response.put("status", "error");
            response.put("message", "Error approving account: " + e.getMessage());
        }
        
        return response;
    }

    // Reject an account
    @PostMapping("/reject-account")
    public Map<String, String> rejectAccount(@RequestBody Map<String, String> request) {
        String userId = request.get("userId");
        
        Map<String, String> response = new HashMap<>();
        
        try {
            Optional<User> userOpt = userRepository.findById(Integer.parseInt(userId));
            if (userOpt.isPresent()) {
                User user = userOpt.get();
                if ("pending".equals(user.getAccountStatus())) {
                    user.setAccountStatus("rejected");
                    userRepository.save(user);
                    
                    response.put("status", "success");
                    response.put("message", "Account rejected successfully");
                } else {
                    response.put("status", "error");
                    response.put("message", "Account is not in pending status");
                }
            } else {
                response.put("status", "error");
                response.put("message", "User not found");
            }
        } catch (Exception e) {
            response.put("status", "error");
            response.put("message", "Error rejecting account: " + e.getMessage());
        }
        
        return response;
    }

    // Get account status for a user
    @GetMapping("/account-status/{email}")
    public Map<String, String> getAccountStatus(@PathVariable String email) {
        Map<String, String> response = new HashMap<>();
        
        Optional<User> userOpt = userRepository.findByEmail(email);
        if (userOpt.isEmpty()) {
            userOpt = userRepository.findByOfficialMail(email);
        }
        
        if (userOpt.isPresent()) {
            User user = userOpt.get();
            response.put("status", "success");
            response.put("accountStatus", user.getAccountStatus());
            response.put("message", getStatusMessage(user.getAccountStatus()));
        } else {
            response.put("status", "error");
            response.put("message", "User not found");
        }
        
        return response;
    }
    
    // Get all users
    @GetMapping("/all-users")
    public Map<String, Object> getAllUsers() {
        List<User> allUsers = userRepository.findAll();
        
        // Create enhanced user data with instructor type
        List<Map<String, Object>> enhancedUsers = new ArrayList<>();
        
        for (User user : allUsers) {
            Map<String, Object> userData = new HashMap<>();
            userData.put("userId", user.getUserId());
            userData.put("nationalId", user.getNationalId());
            userData.put("name", user.getName());
            userData.put("email", user.getEmail());
            userData.put("officialMail", user.getOfficialMail());
            userData.put("phone", user.getPhone());
            userData.put("location", user.getLocation());
            userData.put("role", user.getRole());
            userData.put("accountStatus", user.getAccountStatus());
            
            // Add instructor type for instructors
            if ("instructor".equals(user.getRole())) {
                Optional<Instructor> instructorOpt = instructorRepository.findByInstructorId(user.getUserId());
                if (instructorOpt.isPresent()) {
                    userData.put("instructorType", instructorOpt.get().getInstructorType());
                } else {
                    userData.put("instructorType", "unknown");
                }
            }
            
            // Add department information for students
            if ("student".equals(user.getRole())) {
                Optional<Student> studentOpt = studentRepository.findByStudentId(user.getUserId());
                if (studentOpt.isPresent()) {
                    Student student = studentOpt.get();
                    if (student.getDepartmentId() != null) {
                        Optional<Department> departmentOpt = departmentRepository.findById(student.getDepartmentId());
                        if (departmentOpt.isPresent()) {
                            userData.put("departmentName", departmentOpt.get().getName());
                        } else {
                            userData.put("departmentName", "Unknown Department");
                        }
                    } else {
                        userData.put("departmentName", "No Department");
                    }
                } else {
                    userData.put("departmentName", "No Department");
                }
            }
            
            // Add student information for parents
            if ("parent".equals(user.getRole())) {
                List<Student> students = studentRepository.findByParentUserId(user.getUserId());
                if (!students.isEmpty()) {
                    StringBuilder studentNames = new StringBuilder();
                    for (int i = 0; i < students.size(); i++) {
                        if (i > 0) studentNames.append(", ");
                        // Get student name from User table
                        Optional<User> studentUserOpt = userRepository.findById(students.get(i).getStudentId());
                        if (studentUserOpt.isPresent()) {
                            studentNames.append(studentUserOpt.get().getName());
                        } else {
                            studentNames.append("Unknown Student");
                        }
                    }
                    userData.put("studentNames", studentNames.toString());
                } else {
                    userData.put("studentNames", "No Students");
                }
            }
            
            enhancedUsers.add(userData);
        }
        
        Map<String, Object> response = new HashMap<>();
        response.put("status", "success");
        response.put("users", enhancedUsers);
        response.put("count", enhancedUsers.size());
        
        return response;
    }

    // Delete a user
    @PostMapping("/delete-user")
    public Map<String, String> deleteUser(@RequestBody Map<String, String> request) {
        String userId = request.get("userId");
        
        Map<String, String> response = new HashMap<>();
        
        try {
            Optional<User> userOpt = userRepository.findById(Integer.parseInt(userId));
            if (userOpt.isPresent()) {
                User user = userOpt.get();
                String userName = user.getName();
                
                userRepository.delete(user);
                
                response.put("status", "success");
                response.put("message", "User '" + userName + "' deleted successfully");
            } else {
                response.put("status", "error");
                response.put("message", "User not found");
            }
        } catch (Exception e) {
            response.put("status", "error");
            response.put("message", "Error deleting user: " + e.getMessage());
        }
        
        return response;
    }

    // Update user information
    @PostMapping("/update-user")
    public Map<String, String> updateUser(@RequestBody Map<String, String> request) {
        String userIdStr = request.get("userId");
        String name = request.get("name");
        String email = request.get("email");
        String phone = request.get("phone");
        String location = request.get("location");
        String password = request.get("password");

        Map<String, String> response = new HashMap<>();

        if (userIdStr == null || userIdStr.trim().isEmpty()) {
            response.put("status", "error");
            response.put("message", "User ID is required");
            return response;
        }

        try {
            Integer userId = Integer.parseInt(userIdStr);
            Optional<User> userOpt = userRepository.findById(userId);
            
            if (userOpt.isEmpty()) {
                response.put("status", "error");
                response.put("message", "User not found");
                return response;
            }

            User user = userOpt.get();

            // Check if user is student or parent - they need approval for profile changes
            if ("student".equals(user.getRole()) || "parent".equals(user.getRole())) {
                return handleStudentParentUpdate(user, request);
            } else {
                // Admin and instructor can update immediately
                return handleImmediateUpdate(user, request);
            }

        } catch (NumberFormatException e) {
            response.put("status", "error");
            response.put("message", "Invalid user ID format");
            return response;
        } catch (Exception e) {
            response.put("status", "error");
            response.put("message", "Error updating user: " + e.getMessage());
            return response;
        }
    }

    private Map<String, String> handleStudentParentUpdate(User user, Map<String, String> request) {
        Map<String, String> response = new HashMap<>();
        
        try {
            // Password changes are allowed immediately for all users
            if (request.get("password") != null && !request.get("password").trim().isEmpty()) {
                user.setPasswordHash(request.get("password").trim());
                userRepository.save(user);
            }

            // Store other changes as pending
            boolean hasChanges = false;
            
            if (request.get("name") != null && !request.get("name").trim().isEmpty() && 
                !request.get("name").trim().equals(user.getName())) {
                PendingProfileChange change = new PendingProfileChange(
                    Integer.valueOf(user.getUserId()), "name", user.getName(), request.get("name").trim());
                pendingProfileChangeRepository.save(change);
                hasChanges = true;
            }

            if (request.get("email") != null && !request.get("email").trim().isEmpty() && 
                !request.get("email").trim().equals(user.getEmail())) {
                // Check if email already exists for another user
                Optional<User> existingUser = userRepository.findByEmail(request.get("email").trim());
                if (existingUser.isPresent() && existingUser.get().getUserId() != user.getUserId()) {
                    response.put("status", "error");
                    response.put("message", "Email already exists for another user");
                    return response;
                }
                PendingProfileChange change = new PendingProfileChange(
                    Integer.valueOf(user.getUserId()), "email", user.getEmail(), request.get("email").trim());
                pendingProfileChangeRepository.save(change);
                hasChanges = true;
            }

            if (request.get("phone") != null && !request.get("phone").trim().equals(user.getPhone())) {
                PendingProfileChange change = new PendingProfileChange(
                    Integer.valueOf(user.getUserId()), "phone", user.getPhone(), request.get("phone").trim());
                pendingProfileChangeRepository.save(change);
                hasChanges = true;
            }

            if (request.get("location") != null && !request.get("location").trim().equals(user.getLocation())) {
                PendingProfileChange change = new PendingProfileChange(
                    Integer.valueOf(user.getUserId()), "location", user.getLocation(), request.get("location").trim());
                pendingProfileChangeRepository.save(change);
                hasChanges = true;
            }

            if (request.get("nationalId") != null && !request.get("nationalId").trim().equals(user.getNationalId())) {
                // Check if national ID already exists for another user
                Optional<User> existingUser = userRepository.findByNationalId(request.get("nationalId").trim());
                if (existingUser.isPresent() && existingUser.get().getUserId() != user.getUserId()) {
                    response.put("status", "error");
                    response.put("message", "National ID already exists for another user");
                    return response;
                }
                PendingProfileChange change = new PendingProfileChange(
                    Integer.valueOf(user.getUserId()), "nationalId", user.getNationalId(), request.get("nationalId").trim());
                pendingProfileChangeRepository.save(change);
                hasChanges = true;
            }

            if (hasChanges) {
                response.put("status", "success");
                response.put("message", "Profile changes submitted for admin approval. Password updated immediately.");
            } else {
                response.put("status", "success");
                response.put("message", "Password updated successfully.");
            }
            
            return response;

        } catch (Exception e) {
            response.put("status", "error");
            response.put("message", "Error processing changes: " + e.getMessage());
            return response;
        }
    }

    private Map<String, String> handleImmediateUpdate(User user, Map<String, String> request) {
        Map<String, String> response = new HashMap<>();
        
        try {
            // Update fields if provided
            if (request.get("name") != null && !request.get("name").trim().isEmpty()) {
                user.setName(request.get("name").trim());
            }

            if (request.get("email") != null && !request.get("email").trim().isEmpty()) {
                // Check if email already exists for another user
                Optional<User> existingUser = userRepository.findByEmail(request.get("email").trim());
                if (existingUser.isPresent() && existingUser.get().getUserId() != user.getUserId()) {
                    response.put("status", "error");
                    response.put("message", "Email already exists for another user");
                    return response;
                }
                user.setEmail(request.get("email").trim());
            }

            if (request.get("phone") != null) {
                user.setPhone(request.get("phone").trim());
            }

            if (request.get("location") != null) {
                user.setLocation(request.get("location").trim());
            }

            if (request.get("nationalId") != null && !request.get("nationalId").trim().isEmpty()) {
                // Check if national ID already exists for another user
                Optional<User> existingUser = userRepository.findByNationalId(request.get("nationalId").trim());
                if (existingUser.isPresent() && existingUser.get().getUserId() != user.getUserId()) {
                    response.put("status", "error");
                    response.put("message", "National ID already exists for another user");
                    return response;
                }
                user.setNationalId(request.get("nationalId").trim());
            }

            if (request.get("password") != null && !request.get("password").trim().isEmpty()) {
                user.setPasswordHash(request.get("password").trim());
            }

            userRepository.save(user);
            response.put("status", "success");
            response.put("message", "User updated successfully");
            return response;

        } catch (Exception e) {
            response.put("status", "error");
            response.put("message", "Error updating user: " + e.getMessage());
            return response;
        }
    }

    // Get all pending profile changes
    @GetMapping("/pending-profile-changes")
    public Map<String, Object> getPendingProfileChanges() {
        List<PendingProfileChange> pendingChanges = pendingProfileChangeRepository.findByChangeStatus(PendingProfileChange.ChangeStatus.pending);
        
        // Create enhanced data with user names
        List<Map<String, Object>> enhancedChanges = new ArrayList<>();
        
        for (PendingProfileChange change : pendingChanges) {
            Map<String, Object> changeData = new HashMap<>();
            changeData.put("changeId", change.getChangeId());
            changeData.put("userId", change.getUserId());
            changeData.put("fieldName", change.getFieldName());
            changeData.put("oldValue", change.getOldValue());
            changeData.put("newValue", change.getNewValue());
            changeData.put("requestedAt", change.getRequestedAt());
            
            // Get user name
            Optional<User> userOpt = userRepository.findById(change.getUserId());
            if (userOpt.isPresent()) {
                changeData.put("userName", userOpt.get().getName());
                changeData.put("userRole", userOpt.get().getRole());
            }
            
            enhancedChanges.add(changeData);
        }
        
        Map<String, Object> response = new HashMap<>();
        response.put("status", "success");
        response.put("pendingChanges", enhancedChanges);
        response.put("count", enhancedChanges.size());
        
        return response;
    }

    // Get pending profile changes for a specific user
    @GetMapping("/pending-profile-changes/{userId}")
    public List<PendingProfileChange> getPendingProfileChangesForUser(@PathVariable Integer userId) {
        return pendingProfileChangeRepository.findByUserIdAndChangeStatus(userId, PendingProfileChange.ChangeStatus.pending);
    }

    // Approve a profile change
    @PostMapping("/approve-profile-change")
    public Map<String, String> approveProfileChange(@RequestBody Map<String, String> request) {
        String changeIdStr = request.get("changeId");
        String adminUserIdStr = request.get("adminUserId");
        
        Map<String, String> response = new HashMap<>();
        
        try {
            Integer changeId = Integer.parseInt(changeIdStr);
            Integer adminUserId = Integer.parseInt(adminUserIdStr);
            
            Optional<PendingProfileChange> changeOpt = pendingProfileChangeRepository.findById(changeId);
            if (changeOpt.isEmpty()) {
                response.put("status", "error");
                response.put("message", "Profile change not found");
                return response;
            }
            
            PendingProfileChange change = changeOpt.get();
            
            if (change.getChangeStatus() != PendingProfileChange.ChangeStatus.pending) {
                response.put("status", "error");
                response.put("message", "This change has already been processed");
                return response;
            }
            
            // Apply the change to the user
            Optional<User> userOpt = userRepository.findById(change.getUserId());
            if (userOpt.isEmpty()) {
                response.put("status", "error");
                response.put("message", "User not found");
                return response;
            }
            
            User user = userOpt.get();
            
            // Apply the change based on field name
            switch (change.getFieldName()) {
                case "name":
                    user.setName(change.getNewValue());
                    break;
                case "email":
                    user.setEmail(change.getNewValue());
                    break;
                case "phone":
                    user.setPhone(change.getNewValue());
                    break;
                case "location":
                    user.setLocation(change.getNewValue());
                    break;
                case "nationalId":
                    user.setNationalId(change.getNewValue());
                    break;
                default:
                    response.put("status", "error");
                    response.put("message", "Unknown field: " + change.getFieldName());
                    return response;
            }
            
            userRepository.save(user);
            
            // Mark change as approved
            change.setChangeStatus(PendingProfileChange.ChangeStatus.approved);
            change.setReviewedAt(new java.sql.Timestamp(System.currentTimeMillis()));
            change.setReviewedBy(adminUserId);
            pendingProfileChangeRepository.save(change);
            
            response.put("status", "success");
            response.put("message", "Profile change approved and applied successfully");
            return response;
            
        } catch (NumberFormatException e) {
            response.put("status", "error");
            response.put("message", "Invalid ID format");
            return response;
        } catch (Exception e) {
            response.put("status", "error");
            response.put("message", "Error approving change: " + e.getMessage());
            return response;
        }
    }

    // Reject a profile change
    @PostMapping("/reject-profile-change")
    public Map<String, String> rejectProfileChange(@RequestBody Map<String, String> request) {
        String changeIdStr = request.get("changeId");
        String adminUserIdStr = request.get("adminUserId");
        
        Map<String, String> response = new HashMap<>();
        
        try {
            Integer changeId = Integer.parseInt(changeIdStr);
            Integer adminUserId = Integer.parseInt(adminUserIdStr);
            
            Optional<PendingProfileChange> changeOpt = pendingProfileChangeRepository.findById(changeId);
            if (changeOpt.isEmpty()) {
                response.put("status", "error");
                response.put("message", "Profile change not found");
                return response;
            }
            
            PendingProfileChange change = changeOpt.get();
            
            if (change.getChangeStatus() != PendingProfileChange.ChangeStatus.pending) {
                response.put("status", "error");
                response.put("message", "This change has already been processed");
                return response;
            }
            
            // Mark change as rejected
            change.setChangeStatus(PendingProfileChange.ChangeStatus.rejected);
            change.setReviewedAt(new java.sql.Timestamp(System.currentTimeMillis()));
            change.setReviewedBy(adminUserId);
            pendingProfileChangeRepository.save(change);
            
            response.put("status", "success");
            response.put("message", "Profile change rejected successfully");
            return response;
            
        } catch (NumberFormatException e) {
            response.put("status", "error");
            response.put("message", "Invalid ID format");
            return response;
        } catch (Exception e) {
            response.put("status", "error");
            response.put("message", "Error rejecting change: " + e.getMessage());
            return response;
        }
    }
    
    private String getStatusMessage(String status) {
        switch (status) {
            case "pending":
                return "Your account is pending admin approval. Please wait for approval.";
            case "active":
                return "Your account is active. You can log in.";
            case "rejected":
                return "Your account has been rejected. Please contact administration.";
            default:
                return "Unknown account status.";
        }
    }

    // Get student courses, grades, and GPA
    @GetMapping("/student-data/{userId}")
    public Map<String, Object> getStudentData(@PathVariable Integer userId) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            // Get student record
            Optional<Student> studentOpt = studentRepository.findByStudentId(userId);
            if (!studentOpt.isPresent()) {
                response.put("status", "error");
                response.put("message", "Student not found");
                return response;
            }
            
            Student student = studentOpt.get();
            
            // Get all approved enrollments for this student
            List<Enrollment> enrollments = enrollmentRepository.findByStudentIdAndStatus(userId, "approved");
            
            List<Map<String, Object>> courses = new ArrayList<>();
            double totalPoints = 0.0;
            int totalCredits = 0;
            
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
                if (semesterOpt.isPresent()) {
                    semesterName = semesterOpt.get().getName();
                }
                
                // Get grade for this enrollment
                Optional<Grade> gradeOpt = gradeRepository.findByEnrollmentId(enrollment.getEnrollmentId());
                
                Map<String, Object> courseData = new HashMap<>();
                courseData.put("code", course.getCourseCode());
                courseData.put("name", course.getTitle());
                courseData.put("credits", course.getCredits());
                courseData.put("semester", semesterName);
                courseData.put("section", section.getSectionNumber());
                
                if (gradeOpt.isPresent()) {
                    Grade grade = gradeOpt.get();
                    String letterGrade = grade.getFinalLetterGrade();
                    courseData.put("grade", letterGrade != null ? letterGrade : "N/A");
                    
                    // Add detailed marks - convert BigDecimal to Double
                    Map<String, Object> marks = new HashMap<>();
                    marks.put("midterm", grade.getMidterm());
                    marks.put("project", grade.getProject());
                    marks.put("assignments_total", grade.getAssignmentsTotal());
                    marks.put("quizzes_total", grade.getQuizzesTotal());
                    marks.put("attendance", grade.getAttendance());
                    marks.put("final_exam_mark", grade.getFinalExamMark());
                    marks.put("final_letter_grade", letterGrade);
                    courseData.put("marks", marks);
                    
                    // Calculate GPA points
                    if (letterGrade != null && !letterGrade.equals("N/A")) {
                        double gradePoints = getGradePoints(letterGrade);
                        totalPoints += course.getCredits() * gradePoints;
                        totalCredits += course.getCredits();
                    }
                } else {
                    courseData.put("grade", "N/A");
                    courseData.put("marks", new HashMap<>());
                }
                
                courses.add(courseData);
            }
            
            // Calculate GPA
            double calculatedGPA = totalCredits > 0 ? totalPoints / totalCredits : 0.0;
            
            Map<String, Object> studentData = new HashMap<>();
            studentData.put("courses", courses);
            studentData.put("cumulativeGPA", calculatedGPA);
            studentData.put("completedCredits", totalCredits);
            studentData.put("databaseGPA", student.getCumulativeGpa() != null ? student.getCumulativeGpa().doubleValue() : 0.0);
            
            // Add department information
            if (student.getDepartmentId() != null) {
                Optional<Department> departmentOpt = departmentRepository.findById(student.getDepartmentId());
                if (departmentOpt.isPresent()) {
                    Department department = departmentOpt.get();
                    studentData.put("departmentId", student.getDepartmentId());
                    studentData.put("departmentName", department.getName());
                } else {
                    studentData.put("departmentId", student.getDepartmentId());
                    studentData.put("departmentName", "Unknown Department");
                }
            } else {
                studentData.put("departmentId", null);
                studentData.put("departmentName", "No Department");
            }
            
            response.put("status", "success");
            response.put("data", studentData);
            
        } catch (Exception e) {
            response.put("status", "error");
            response.put("message", "Error fetching student data: " + e.getMessage());
        }
        
        return response;
    }
    
    private double getGradePoints(String grade) {
        switch (grade) {
            case "A+": return 4.0;
            case "A": return 4.0;
            case "A-": return 3.7;
            case "B+": return 3.3;
            case "B": return 3.0;
            case "B-": return 2.7;
            case "C+": return 2.3;
            case "C": return 2.0;
            case "C-": return 1.7;
            case "D+": return 1.3;
            case "D": return 1.0;
            case "F": return 0.0;
            default: return 0.0;
        }
    }
    
    // Create a new user
    @PostMapping("/create-user")
    public Map<String, Object> createUser(@RequestBody Map<String, Object> request) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            // Extract user data
            String name = (String) request.get("name");
            String email = (String) request.get("email");
            String officialMail = (String) request.get("officialMail");
            String phone = (String) request.get("phone");
            String location = (String) request.get("location");
            String nationalId = (String) request.get("nationalId");
            String password = (String) request.get("password");
            String role = (String) request.get("role");
            String studentNationalId = (String) request.get("studentNationalId");
            
            // Validate required fields
            if (name == null || name.trim().isEmpty() ||
                email == null || email.trim().isEmpty() ||
                officialMail == null || officialMail.trim().isEmpty() ||
                nationalId == null || nationalId.trim().isEmpty() ||
                password == null || password.trim().isEmpty() ||
                role == null || role.trim().isEmpty()) {
                response.put("status", "error");
                response.put("message", "All required fields must be provided");
                return response;
            }
            
            // Additional validation for parents
            if ("parent".equals(role) && (studentNationalId == null || studentNationalId.trim().isEmpty())) {
                response.put("status", "error");
                response.put("message", "Student National ID is required for parent accounts");
                return response;
            }
            
            // Check if user already exists
            Optional<User> existingUser = userRepository.findByEmail(email);
            if (existingUser.isPresent()) {
                response.put("status", "error");
                response.put("message", "User with this email already exists");
                return response;
            }
            
            Optional<User> existingNationalId = userRepository.findByNationalId(nationalId);
            if (existingNationalId.isPresent()) {
                response.put("status", "error");
                response.put("message", "User with this national ID already exists");
                return response;
            }
            
            // Create new user
            User newUser = new User();
            newUser.setName(name.trim());
            newUser.setEmail(email.trim());
            newUser.setOfficialMail(officialMail.trim());
            newUser.setPhone(phone != null ? phone.trim() : "");
            newUser.setLocation(location != null ? location.trim() : "");
            newUser.setNationalId(nationalId.trim());
            newUser.setPasswordHash(password.trim()); // In real app, hash this password
            newUser.setRole(role.trim());
            newUser.setAccountStatus("active"); // Admin-created users are active by default
            
            User savedUser = userRepository.save(newUser);
            
            // Create role-specific records
            if ("student".equals(role)) {
                Student student = new Student();
                student.setStudentId(savedUser.getUserId());
                student.setStudentUid("S-" + savedUser.getUserId());
                student.setCumulativeGpa(new java.math.BigDecimal("0.00"));
                
                // Set department if provided
                if (request.containsKey("departmentId")) {
                    Object deptIdObj = request.get("departmentId");
                    Integer departmentId;
                    if (deptIdObj instanceof String) {
                        departmentId = Integer.parseInt((String) deptIdObj);
                    } else {
                        departmentId = (Integer) deptIdObj;
                    }
                    student.setDepartmentId(departmentId);
                }
                
                studentRepository.save(student);
            } else if ("instructor".equals(role)) {
                Instructor instructor = new Instructor();
                instructor.setInstructorId(savedUser.getUserId());
                
                // Set instructor type if provided
                if (request.containsKey("instructorType")) {
                    String instructorType = (String) request.get("instructorType");
                    instructor.setInstructorType(instructorType);
                } else {
                    instructor.setInstructorType("professor"); // Default
                }
                
                instructorRepository.save(instructor);
            } else if ("parent".equals(role)) {
                // Handle parent-student relationship
                Optional<User> studentUserOpt = userRepository.findByNationalId(studentNationalId);
                if (!studentUserOpt.isPresent()) {
                    response.put("status", "error");
                    response.put("message", "Student with national ID " + studentNationalId + " not found");
                    return response;
                }
                
                User studentUser = studentUserOpt.get();
                if (!"student".equals(studentUser.getRole())) {
                    response.put("status", "error");
                    response.put("message", "User with national ID " + studentNationalId + " is not a student");
                    return response;
                }
                
                // Check if student already has a parent
                Optional<Student> existingStudentOpt = studentRepository.findByStudentId(studentUser.getUserId());
                if (existingStudentOpt.isPresent()) {
                    Student existingStudent = existingStudentOpt.get();
                    if (existingStudent.getParentUserId() != null) {
                        // Student already has a parent - ask for confirmation
                        Optional<User> existingParentOpt = userRepository.findById(existingStudent.getParentUserId());
                        String existingParentName = existingParentOpt.isPresent() ? existingParentOpt.get().getName() : "Unknown";
                        
                        response.put("status", "confirmation_required");
                        response.put("message", "Student " + studentUser.getName() + " already has a parent: " + existingParentName);
                        response.put("studentId", studentUser.getUserId());
                        response.put("existingParentId", existingStudent.getParentUserId());
                        response.put("existingParentName", existingParentName);
                        return response;
                    }
                }
                
                // Update student record with new parent
                if (existingStudentOpt.isPresent()) {
                    Student student = existingStudentOpt.get();
                    student.setParentUserId(savedUser.getUserId());
                    studentRepository.save(student);
                }
            }
            
            response.put("status", "success");
            response.put("message", "User created successfully");
            response.put("userId", savedUser.getUserId());
            
        } catch (Exception e) {
            response.put("status", "error");
            response.put("message", "Error creating user: " + e.getMessage());
        }
        
        return response;
    }
    
    // Replace existing parent with new parent
    @PostMapping("/replace-parent")
    public Map<String, Object> replaceParent(@RequestBody Map<String, Object> request) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            Integer studentId = (Integer) request.get("studentId");
            Integer existingParentId = (Integer) request.get("existingParentId");
            Integer newParentId = (Integer) request.get("newParentId");
            Boolean replaceParent = (Boolean) request.get("replaceParent");
            
            if (studentId == null || existingParentId == null || newParentId == null || replaceParent == null) {
                response.put("status", "error");
                response.put("message", "Missing required parameters");
                return response;
            }
            
            Optional<Student> studentOpt = studentRepository.findByStudentId(studentId);
            if (!studentOpt.isPresent()) {
                response.put("status", "error");
                response.put("message", "Student not found");
                return response;
            }
            
            Student student = studentOpt.get();
            
            if (replaceParent) {
                // Replace the existing parent
                student.setParentUserId(newParentId);
                studentRepository.save(student);
                
                response.put("status", "success");
                response.put("message", "Parent replaced successfully");
            } else {
                // Keep existing parent, don't create new parent
                response.put("status", "cancelled");
                response.put("message", "Parent creation cancelled - keeping existing parent");
            }
            
        } catch (Exception e) {
            response.put("status", "error");
            response.put("message", "Error replacing parent: " + e.getMessage());
        }
        
        return response;
    }
}
