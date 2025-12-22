package com.asu_lms.lms.Controllers;

import java.sql.Timestamp;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.Set;
import java.util.stream.Collectors;

import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.asu_lms.lms.Entities.Course;
import com.asu_lms.lms.Entities.Enrollment;
import com.asu_lms.lms.Entities.Instructor;
import com.asu_lms.lms.Entities.Message;
import com.asu_lms.lms.Entities.OfferedCourse;
import com.asu_lms.lms.Entities.OfferedCourseInstructor;
import com.asu_lms.lms.Entities.Section;
import com.asu_lms.lms.Entities.Semester;
import com.asu_lms.lms.Entities.Student;
import com.asu_lms.lms.Entities.User;
import com.asu_lms.lms.Repositories.CourseRepository;
import com.asu_lms.lms.Repositories.EnrollmentRepository;
import com.asu_lms.lms.Repositories.InstructorRepository;
import com.asu_lms.lms.Repositories.MessageRepository;
import com.asu_lms.lms.Repositories.OfferedCourseInstructorRepository;
import com.asu_lms.lms.Repositories.OfferedCourseRepository;
import com.asu_lms.lms.Repositories.SectionRepository;
import com.asu_lms.lms.Repositories.SemesterRepository;
import com.asu_lms.lms.Repositories.StudentRepository;
import com.asu_lms.lms.Repositories.UserRepository;
import com.asu_lms.lms.Services.EAVService;

@RestController
@RequestMapping("/api/message")
@CrossOrigin(origins = "*")
public class MessageController {

    private final MessageRepository messageRepository;
    private final UserRepository userRepository;
    private final StudentRepository studentRepository;
    private final InstructorRepository instructorRepository;
    private final EnrollmentRepository enrollmentRepository;
    private final SectionRepository sectionRepository;
    private final OfferedCourseRepository offeredCourseRepository;
    private final OfferedCourseInstructorRepository offeredCourseInstructorRepository;
    private final CourseRepository courseRepository;
    private final SemesterRepository semesterRepository;
    private final EAVService eavService;

    public MessageController(
            MessageRepository messageRepository,
            UserRepository userRepository,
            StudentRepository studentRepository,
            InstructorRepository instructorRepository,
            EnrollmentRepository enrollmentRepository,
            SectionRepository sectionRepository,
            OfferedCourseRepository offeredCourseRepository,
            OfferedCourseInstructorRepository offeredCourseInstructorRepository,
            CourseRepository courseRepository,
            SemesterRepository semesterRepository,
            EAVService eavService
    ) {
        this.messageRepository = messageRepository;
        this.userRepository = userRepository;
        this.studentRepository = studentRepository;
        this.instructorRepository = instructorRepository;
        this.enrollmentRepository = enrollmentRepository;
        this.sectionRepository = sectionRepository;
        this.offeredCourseRepository = offeredCourseRepository;
        this.offeredCourseInstructorRepository = offeredCourseInstructorRepository;
        this.courseRepository = courseRepository;
        this.semesterRepository = semesterRepository;
        this.eavService = eavService;
    }

    /**
     * Get available recipients for a student (advisor + instructors for current semester courses)
     */
    @GetMapping("/student/{studentId}/recipients")
    public Map<String, Object> getStudentRecipients(@PathVariable Integer studentId) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            Optional<Student> studentOpt = studentRepository.findByStudentId(studentId);
            if (studentOpt.isEmpty()) {
                response.put("status", "error");
                response.put("message", "Student not found");
                return response;
            }
            
            Student student = studentOpt.get();
            List<Map<String, Object>> recipients = new ArrayList<>();
            Set<Integer> addedUserIds = new HashSet<>();
            
            // Add advisor if exists
            if (student.getAdvisorId() != null) {
                Optional<Instructor> advisorOpt = instructorRepository.findByInstructorId(student.getAdvisorId());
                if (advisorOpt.isPresent()) {
                    Optional<User> advisorUserOpt = userRepository.findById(student.getAdvisorId());
                    if (advisorUserOpt.isPresent()) {
                        User advisorUser = advisorUserOpt.get();
                        Map<String, Object> advisor = new HashMap<>();
                        advisor.put("userId", advisorUser.getUserId());
                        advisor.put("name", advisorUser.getName());
                        advisor.put("email", advisorUser.getEmail());
                        advisor.put("role", "advisor");
                        advisor.put("type", "Advisor");
                        recipients.add(advisor);
                        addedUserIds.add(advisorUser.getUserId());
                    }
                }
            }
            
            // Get current semester
            LocalDate today = LocalDate.now();
            Semester currentSemester = findCurrentSemester(today);
            
            if (currentSemester != null) {
                // Get enrollments for current semester
                List<Enrollment> allEnrollments = enrollmentRepository.findByStudentId(studentId);
                List<Enrollment> enrollments = allEnrollments.stream()
                        .filter(e -> {
                            String status = eavService.getEnrollmentStatus(e.getEnrollmentId());
                            return "approved".equals(status) || "pending".equals(status) || "drop_pending".equals(status);
                        })
                        .collect(Collectors.toList());
                
                // Get instructors for current semester courses
                for (Enrollment enrollment : enrollments) {
                    Optional<Section> sectionOpt = sectionRepository.findBySectionId(enrollment.getSectionId());
                    if (sectionOpt.isEmpty()) continue;
                    
                    Section section = sectionOpt.get();
                    Optional<OfferedCourse> offeredCourseOpt = offeredCourseRepository.findByOfferedCourseId(section.getOfferedCourseId());
                    if (offeredCourseOpt.isEmpty()) continue;
                    
                    OfferedCourse offeredCourse = offeredCourseOpt.get();
                    if (!offeredCourse.getSemesterId().equals(currentSemester.getSemesterId())) continue;
                    
                    // Get instructors for this offered course
                    List<OfferedCourseInstructor> courseInstructors = offeredCourseInstructorRepository.findByOfferedCourseId(offeredCourse.getOfferedCourseId());
                    
                    for (OfferedCourseInstructor oci : courseInstructors) {
                        if (addedUserIds.contains(oci.getInstructorId())) continue;
                        
                        Optional<User> instructorUserOpt = userRepository.findById(oci.getInstructorId());
                        if (instructorUserOpt.isEmpty()) continue;
                        
                        Optional<Course> courseOpt = courseRepository.findById(offeredCourse.getCourseId());
                        String courseName = courseOpt.map(Course::getTitle).orElse("Unknown Course");
                        String courseCode = courseOpt.map(Course::getCourseCode).orElse("");
                        
                        User instructorUser = instructorUserOpt.get();
                        Map<String, Object> instructor = new HashMap<>();
                        instructor.put("userId", instructorUser.getUserId());
                        instructor.put("name", instructorUser.getName());
                        instructor.put("email", instructorUser.getEmail());
                        instructor.put("role", "instructor");
                        instructor.put("type", "Instructor");
                        instructor.put("courseCode", courseCode);
                        instructor.put("courseName", courseName);
                        recipients.add(instructor);
                        addedUserIds.add(instructorUser.getUserId());
                    }
                }
            }
            
            response.put("status", "success");
            response.put("recipients", recipients);
            
        } catch (Exception e) {
            response.put("status", "error");
            response.put("message", "Error fetching recipients: " + e.getMessage());
        }
        
        return response;
    }

    /**
     * Get available recipients for a parent (advisor + instructors for current semester courses of their child)
     */
    @GetMapping("/parent/{parentId}/student/{studentId}/recipients")
    public Map<String, Object> getParentRecipients(@PathVariable Integer parentId, @PathVariable Integer studentId) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            // Verify parent exists
            Optional<User> parentOpt = userRepository.findById(parentId);
            if (parentOpt.isEmpty() || !"parent".equals(parentOpt.get().getRole())) {
                response.put("status", "error");
                response.put("message", "Parent not found");
                return response;
            }
            
            // Verify student exists and belongs to parent
            Optional<Student> studentOpt = studentRepository.findByStudentId(studentId);
            if (studentOpt.isEmpty()) {
                response.put("status", "error");
                response.put("message", "Student not found");
                return response;
            }
            
            Student student = studentOpt.get();
            if (student.getParentUserId() == null || !student.getParentUserId().equals(parentId)) {
                response.put("status", "error");
                response.put("message", "Student does not belong to this parent");
                return response;
            }
            
            List<Map<String, Object>> recipients = new ArrayList<>();
            Set<Integer> addedUserIds = new HashSet<>();
            
            // Add advisor if exists
            if (student.getAdvisorId() != null) {
                Optional<Instructor> advisorOpt = instructorRepository.findByInstructorId(student.getAdvisorId());
                if (advisorOpt.isPresent()) {
                    Optional<User> advisorUserOpt = userRepository.findById(student.getAdvisorId());
                    if (advisorUserOpt.isPresent()) {
                        User advisorUser = advisorUserOpt.get();
                        Map<String, Object> advisor = new HashMap<>();
                        advisor.put("userId", advisorUser.getUserId());
                        advisor.put("name", advisorUser.getName());
                        advisor.put("email", advisorUser.getEmail());
                        advisor.put("role", "advisor");
                        advisor.put("type", "Advisor");
                        recipients.add(advisor);
                        addedUserIds.add(advisorUser.getUserId());
                    }
                }
            }
            
            // Get current semester
            LocalDate today = LocalDate.now();
            Semester currentSemester = findCurrentSemester(today);
            
            if (currentSemester != null) {
                // Get enrollments for current semester
                List<Enrollment> allEnrollments = enrollmentRepository.findByStudentId(studentId);
                List<Enrollment> enrollments = allEnrollments.stream()
                        .filter(e -> {
                            String status = eavService.getEnrollmentStatus(e.getEnrollmentId());
                            return "approved".equals(status) || "pending".equals(status) || "drop_pending".equals(status);
                        })
                        .collect(Collectors.toList());
                
                // Get instructors for current semester courses
                for (Enrollment enrollment : enrollments) {
                    Optional<Section> sectionOpt = sectionRepository.findBySectionId(enrollment.getSectionId());
                    if (sectionOpt.isEmpty()) continue;
                    
                    Section section = sectionOpt.get();
                    Optional<OfferedCourse> offeredCourseOpt = offeredCourseRepository.findByOfferedCourseId(section.getOfferedCourseId());
                    if (offeredCourseOpt.isEmpty()) continue;
                    
                    OfferedCourse offeredCourse = offeredCourseOpt.get();
                    if (!offeredCourse.getSemesterId().equals(currentSemester.getSemesterId())) continue;
                    
                    // Get instructors for this offered course
                    List<OfferedCourseInstructor> courseInstructors = offeredCourseInstructorRepository.findByOfferedCourseId(offeredCourse.getOfferedCourseId());
                    
                    for (OfferedCourseInstructor oci : courseInstructors) {
                        if (addedUserIds.contains(oci.getInstructorId())) continue;
                        
                        Optional<User> instructorUserOpt = userRepository.findById(oci.getInstructorId());
                        if (instructorUserOpt.isEmpty()) continue;
                        
                        Optional<Course> courseOpt = courseRepository.findById(offeredCourse.getCourseId());
                        String courseName = courseOpt.map(Course::getTitle).orElse("Unknown Course");
                        String courseCode = courseOpt.map(Course::getCourseCode).orElse("");
                        
                        User instructorUser = instructorUserOpt.get();
                        Map<String, Object> instructor = new HashMap<>();
                        instructor.put("userId", instructorUser.getUserId());
                        instructor.put("name", instructorUser.getName());
                        instructor.put("email", instructorUser.getEmail());
                        instructor.put("role", "instructor");
                        instructor.put("type", "Instructor");
                        instructor.put("courseCode", courseCode);
                        instructor.put("courseName", courseName);
                        recipients.add(instructor);
                        addedUserIds.add(instructorUser.getUserId());
                    }
                }
            }
            
            response.put("status", "success");
            response.put("recipients", recipients);
            
        } catch (Exception e) {
            response.put("status", "error");
            response.put("message", "Error fetching recipients: " + e.getMessage());
        }
        
        return response;
    }

    /**
     * Send a message
     */
    @PostMapping("/send")
    public Map<String, Object> sendMessage(@RequestBody Map<String, Object> request) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            Integer senderUserId = Integer.parseInt(request.get("senderUserId").toString());
            Integer recipientUserId = Integer.parseInt(request.get("recipientUserId").toString());
            String content = request.get("content").toString();
            
            if (content == null || content.trim().isEmpty()) {
                response.put("status", "error");
                response.put("message", "Message content cannot be empty");
                return response;
            }
            
            // Verify users exist
            Optional<User> senderOpt = userRepository.findById(senderUserId);
            Optional<User> recipientOpt = userRepository.findById(recipientUserId);
            
            if (senderOpt.isEmpty() || recipientOpt.isEmpty()) {
                response.put("status", "error");
                response.put("message", "Invalid sender or recipient");
                return response;
            }
            
            Message message = new Message(senderUserId, recipientUserId, content);
            messageRepository.save(message);
            
            response.put("status", "success");
            response.put("message", "Message sent successfully");
            response.put("messageId", message.getMessageId());
            
        } catch (Exception e) {
            response.put("status", "error");
            response.put("message", "Error sending message: " + e.getMessage());
        }
        
        return response;
    }

    /**
     * Get inbox (received messages) for a user
     */
    @GetMapping("/{userId}/inbox")
    public Map<String, Object> getInbox(@PathVariable Integer userId) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            List<Message> messages = messageRepository.findByRecipientUserIdOrderBySentAtDesc(userId);
            List<Map<String, Object>> messageList = new ArrayList<>();
            
            for (Message message : messages) {
                Optional<User> senderOpt = userRepository.findById(message.getSenderUserId());
                if (senderOpt.isEmpty()) continue;
                
                User sender = senderOpt.get();
                Map<String, Object> messageData = new HashMap<>();
                messageData.put("messageId", message.getMessageId());
                messageData.put("senderUserId", message.getSenderUserId());
                messageData.put("senderName", sender.getName());
                messageData.put("senderEmail", sender.getEmail());
                messageData.put("content", message.getContent());
                messageData.put("sentAt", message.getSentAt().toString());
                messageData.put("readAt", message.getReadAt() != null ? message.getReadAt().toString() : null);
                messageData.put("isRead", message.getReadAt() != null);
                messageList.add(messageData);
            }
            
            long unreadCount = messageRepository.countByRecipientUserIdAndReadAtIsNull(userId);
            
            response.put("status", "success");
            response.put("messages", messageList);
            response.put("unreadCount", unreadCount);
            
        } catch (Exception e) {
            response.put("status", "error");
            response.put("message", "Error fetching inbox: " + e.getMessage());
        }
        
        return response;
    }

    /**
     * Get sent messages for a user
     */
    @GetMapping("/{userId}/sent")
    public Map<String, Object> getSentMessages(@PathVariable Integer userId) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            List<Message> messages = messageRepository.findBySenderUserIdOrderBySentAtDesc(userId);
            List<Map<String, Object>> messageList = new ArrayList<>();
            
            for (Message message : messages) {
                Optional<User> recipientOpt = userRepository.findById(message.getRecipientUserId());
                if (recipientOpt.isEmpty()) continue;
                
                User recipient = recipientOpt.get();
                Map<String, Object> messageData = new HashMap<>();
                messageData.put("messageId", message.getMessageId());
                messageData.put("recipientUserId", message.getRecipientUserId());
                messageData.put("recipientName", recipient.getName());
                messageData.put("recipientEmail", recipient.getEmail());
                messageData.put("content", message.getContent());
                messageData.put("sentAt", message.getSentAt().toString());
                messageData.put("readAt", message.getReadAt() != null ? message.getReadAt().toString() : null);
                messageData.put("isRead", message.getReadAt() != null);
                messageList.add(messageData);
            }
            
            response.put("status", "success");
            response.put("messages", messageList);
            
        } catch (Exception e) {
            response.put("status", "error");
            response.put("message", "Error fetching sent messages: " + e.getMessage());
        }
        
        return response;
    }

    /**
     * Mark a message as read
     */
    @PutMapping("/{messageId}/read")
    public Map<String, Object> markAsRead(@PathVariable Integer messageId) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            Optional<Message> messageOpt = messageRepository.findById(messageId);
            if (messageOpt.isEmpty()) {
                response.put("status", "error");
                response.put("message", "Message not found");
                return response;
            }
            
            Message message = messageOpt.get();
            if (message.getReadAt() == null) {
                message.setReadAt(new Timestamp(System.currentTimeMillis()));
                messageRepository.save(message);
            }
            
            response.put("status", "success");
            response.put("message", "Message marked as read");
            
        } catch (Exception e) {
            response.put("status", "error");
            response.put("message", "Error marking message as read: " + e.getMessage());
        }
        
        return response;
    }

    private Semester findCurrentSemester(LocalDate today) {
        List<Semester> semesters = semesterRepository.findAll();
        
        return semesters.stream()
                .filter(semester -> isWithinSemester(semester, today))
                .sorted(Comparator.comparing(Semester::getStartDate))
                .findFirst()
                .orElse(null);
    }

    private boolean isWithinSemester(Semester semester, LocalDate today) {
        if (semester.getStartDate() == null || semester.getEndDate() == null) {
            return false;
        }
        
        LocalDate start = semester.getStartDate().toLocalDate();
        LocalDate end = semester.getEndDate().toLocalDate();
        
        return (today.isEqual(start) || today.isAfter(start)) &&
                (today.isEqual(end) || today.isBefore(end));
    }
}
