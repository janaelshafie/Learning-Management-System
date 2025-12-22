package com.asu_lms.lms.Controllers;

import com.asu_lms.lms.Entities.*;
import com.asu_lms.lms.Repositories.*;
import com.asu_lms.lms.Services.EAVService;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import java.time.LocalDate;
import java.sql.Date;
import java.time.LocalDateTime;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

import java.sql.Timestamp;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.Set;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;

import static org.hamcrest.Matchers.*;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@WebMvcTest(MessageController.class)
class MessageControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired private MessageRepository messageRepository;
    @Autowired private UserRepository userRepository;
    @Autowired private StudentRepository studentRepository;
    @Autowired private InstructorRepository instructorRepository;
    @Autowired private EnrollmentRepository enrollmentRepository;
    @Autowired private SectionRepository sectionRepository;
    @Autowired private OfferedCourseRepository offeredCourseRepository;
    @Autowired private OfferedCourseInstructorRepository offeredCourseInstructorRepository;
    @Autowired private CourseRepository courseRepository;
    @Autowired private SemesterRepository semesterRepository;
    @Autowired private EAVService eavService;

    // ========== STUDENT RECIPIENTS ==========

    @Test
    void getStudentRecipients_studentNotFound() throws Exception {
        when(studentRepository.findByStudentId(100)).thenReturn(Optional.empty());  // [web:24][web:29]

        mockMvc.perform(get("/api/message/student/{studentId}/recipients", 100))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.status").value("error"))
                .andExpect(jsonPath("$.message").value("Student not found"));
    }

    @Test
    void getStudentRecipients_withAdvisorAndInstructor() throws Exception {
        // Student with advisor
        Student student = new Student();
        student.setStudentId(1);
        student.setAdvisorId(10);
        when(studentRepository.findByStudentId(1)).thenReturn(Optional.of(student));

        // Advisor user
        Instructor advisor = new Instructor();
        advisor.setInstructorId(10);
        when(instructorRepository.findByInstructorId(10)).thenReturn(Optional.of(advisor));

        User advisorUser = new User();
        advisorUser.setUserId(10);
        advisorUser.setName("Advisor A");
        advisorUser.setEmail("advisor@example.com");
        when(userRepository.findById(10)).thenReturn(Optional.of(advisorUser));

        // Current semester
        Semester semester = new Semester();
        semester.setSemesterId(1);
        semester.setName("Fall 2025");


        semester.setStartDate(Date.valueOf(LocalDate.of(2025, 9, 1)));
        semester.setEndDate(Date.valueOf(LocalDate.of(2025, 12, 31)));
        when(semesterRepository.findAll()).thenReturn(List.of(semester));

        // Enrollment in current semester
        Enrollment enrollment = new Enrollment();
        enrollment.setEnrollmentId(1000);
        enrollment.setStudentId(1);
        enrollment.setSectionId(5);
        when(enrollmentRepository.findByStudentId(1)).thenReturn(List.of(enrollment));
        when(eavService.getEnrollmentStatus(1000)).thenReturn("approved");

        // Section → OfferedCourse → Course
        Section section = new Section();
        section.setSectionId(5);
        section.setOfferedCourseId(7);
        when(sectionRepository.findBySectionId(5)).thenReturn(Optional.of(section));

        OfferedCourse oc = new OfferedCourse();
        oc.setOfferedCourseId(7);
        oc.setCourseId(20);
        oc.setSemesterId(1);
        when(offeredCourseRepository.findByOfferedCourseId(7)).thenReturn(Optional.of(oc));

        Course course = new Course();
        course.setCourseId(20);
        course.setCourseCode("CS101");
        course.setTitle("Intro to CS");
        when(courseRepository.findById(20)).thenReturn(Optional.of(course));

        // Instructor for this offered course
        OfferedCourseInstructor oci = new OfferedCourseInstructor();
        oci.setOfferedCourseId(7);
        oci.setInstructorId(11);
        when(offeredCourseInstructorRepository.findByOfferedCourseId(7))
                .thenReturn(List.of(oci));

        User instructorUser = new User();
        instructorUser.setUserId(11);
        instructorUser.setName("Instructor B");
        instructorUser.setEmail("instructor@example.com");
        when(userRepository.findById(11)).thenReturn(Optional.of(instructorUser));

        mockMvc.perform(get("/api/message/student/{studentId}/recipients", 1))
                .andExpect(status().isOk())                                      // [web:5][web:22]
                .andExpect(jsonPath("$.status").value("success"))
                // advisor
                .andExpect(jsonPath("$.recipients[?(@.role=='advisor')].length()").value(1))
                // instructor
                .andExpect(jsonPath("$.recipients[?(@.role=='instructor')].length()").value(1))
                .andExpect(jsonPath("$.recipients[?(@.role=='instructor')][0].courseCode").value("CS101"));
    }

    // ========== PARENT RECIPIENTS ==========

    @Test
    void getParentRecipients_parentNotFound() throws Exception {
        when(userRepository.findById(5)).thenReturn(Optional.empty());

        mockMvc.perform(get("/api/message/parent/{parentId}/student/{studentId}/recipients", 5, 1))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.status").value("error"))
                .andExpect(jsonPath("$.message").value("Parent not found"));
    }

    @Test
    void getParentRecipients_studentDoesNotBelongToParent() throws Exception {
        User parent = new User();
        parent.setUserId(5);
        parent.setRole("parent");
        when(userRepository.findById(5)).thenReturn(Optional.of(parent));

        Student student = new Student();
        student.setStudentId(1);
        student.setParentUserId(999); // different parent
        when(studentRepository.findByStudentId(1)).thenReturn(Optional.of(student));

        mockMvc.perform(get("/api/message/parent/{parentId}/student/{studentId}/recipients", 5, 1))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.status").value("error"))
                .andExpect(jsonPath("$.message").value("Student does not belong to this parent"));
    }

    // ========== SEND MESSAGE ==========

    @Test
    void sendMessage_emptyContent_error() throws Exception {
        String body = """
            {
              "senderUserId": 1,
              "recipientUserId": 2,
              "content": "   "
            }
            """;

        mockMvc.perform(post("/api/message/send")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(body))
                .andExpect(status().isOk())                                  // [web:25][web:27]
                .andExpect(jsonPath("$.status").value("error"))
                .andExpect(jsonPath("$.message").value("Message content cannot be empty"));
    }

    @Test
    void sendMessage_invalidUsers_error() throws Exception {
        String body = """
            {
              "senderUserId": 1,
              "recipientUserId": 2,
              "content": "Hello"
            }
            """;

        when(userRepository.findById(1)).thenReturn(Optional.empty());
        when(userRepository.findById(2)).thenReturn(Optional.empty());

        mockMvc.perform(post("/api/message/send")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(body))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.status").value("error"))
                .andExpect(jsonPath("$.message").value("Invalid sender or recipient"));
    }

    @Test
    void sendMessage_success() throws Exception {
        String body = """
            {
              "senderUserId": 1,
              "recipientUserId": 2,
              "content": "Hello there"
            }
            """;

        User sender = new User();
        sender.setUserId(1);
        User recipient = new User();
        recipient.setUserId(2);

        when(userRepository.findById(1)).thenReturn(Optional.of(sender));
        when(userRepository.findById(2)).thenReturn(Optional.of(recipient));
        when(messageRepository.save(any(Message.class))).thenAnswer(inv -> {
            Message m = inv.getArgument(0);
            m.setMessageId(50);
            return m;
        });

        mockMvc.perform(post("/api/message/send")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(body))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.status").value("success"))
                .andExpect(jsonPath("$.message").value("Message sent successfully"))
                .andExpect(jsonPath("$.messageId").value(50));
    }

    // ========== INBOX / SENT ==========

    @Test
    void getInbox_success() throws Exception {
        Message m = new Message(2, 1, "Hi");
        m.setMessageId(10);
        m.setSentAt(Timestamp.valueOf(LocalDateTime.of(2025, 12, 20, 10, 0)));
        m.setReadAt(null);

        User sender = new User();
        sender.setUserId(2);
        sender.setName("Alice");
        sender.setEmail("alice@example.com");

        when(messageRepository.findByRecipientUserIdOrderBySentAtDesc(1))
                .thenReturn(List.of(m));
        when(userRepository.findById(2)).thenReturn(Optional.of(sender));
        when(messageRepository.countByRecipientUserIdAndReadAtIsNull(1))
                .thenReturn(1L);

        mockMvc.perform(get("/api/message/{userId}/inbox", 1))
                .andExpect(status().isOk())                                // [web:14][web:23]
                .andExpect(jsonPath("$.status").value("success"))
                .andExpect(jsonPath("$.unreadCount").value(1))
                .andExpect(jsonPath("$.messages[0].senderName").value("Alice"))
                .andExpect(jsonPath("$.messages[0].isRead").value(false));
    }

    @Test
    void getSentMessages_success() throws Exception {
        Message m = new Message(1, 3, "Hi");
        m.setMessageId(11);
        m.setSentAt(Timestamp.valueOf(LocalDateTime.of(2025, 12, 20, 11, 0)));

        User recipient = new User();
        recipient.setUserId(3);
        recipient.setName("Bob");
        recipient.setEmail("bob@example.com");

        when(messageRepository.findBySenderUserIdOrderBySentAtDesc(1))
                .thenReturn(List.of(m));
        when(userRepository.findById(3)).thenReturn(Optional.of(recipient));

        mockMvc.perform(get("/api/message/{userId}/sent", 1))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.status").value("success"))
                .andExpect(jsonPath("$.messages[0].recipientName").value("Bob"));
    }

    // ========== MARK AS READ ==========

    @Test
    void markAsRead_messageNotFound() throws Exception {
        when(messageRepository.findById(99)).thenReturn(Optional.empty());

        mockMvc.perform(put("/api/message/{messageId}/read", 99))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.status").value("error"))
                .andExpect(jsonPath("$.message").value("Message not found"));
    }

    @Test
    void markAsRead_success() throws Exception {
        Message m = new Message(1, 2, "Hi");
        m.setMessageId(15);
        m.setSentAt(Timestamp.valueOf(LocalDateTime.now()));

        when(messageRepository.findById(15)).thenReturn(Optional.of(m));

        mockMvc.perform(put("/api/message/{messageId}/read", 15))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.status").value("success"))
                .andExpect(jsonPath("$.message").value("Message marked as read"));
    }
}
