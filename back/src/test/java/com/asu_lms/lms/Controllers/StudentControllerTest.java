// package com.asu_lms.lms.Controllers;

// import com.asu_lms.lms.Entities.*;
// import com.asu_lms.lms.Repositories.*;
// import com.asu_lms.lms.Services.AuthService;
// import com.asu_lms.lms.Controllers.StudentController;

// import org.junit.jupiter.api.BeforeEach;
// import org.junit.jupiter.api.Test;
// import org.mockito.ArgumentCaptor;
// import org.mockito.InjectMocks;
// import org.mockito.Mockito;
// import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;

// import org.springframework.beans.factory.annotation.Autowired;
// import org.springframework.test.web.servlet.MockMvc;
// import org.springframework.http.MediaType;
// import org.springframework.web.bind.annotation.PathVariable;
// import org.springframework.web.bind.annotation.RequestBody;

// import java.sql.Date;
// import java.time.LocalDate;
// import java.util.*;

// import static org.hamcrest.Matchers.any;
// import static org.junit.jupiter.api.Assertions.*;
// import static org.mockito.Mockito.*;
// import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
// import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;
// @WebMvcTest(StudentController.class)
// class StudentControllerTest {



//     @Autowired
//     private EnrollmentRepository enrollmentRepository;

//     @Autowired
//     private SectionRepository sectionRepository;
//     @Autowired
//     private OfferedCourseRepository offeredCourseRepository;
//     @Autowired
//     private DepartmentRepository departmentRepository;
//     @Autowired
//     private DepartmentCourseRepository departmentCourseRepository;
//     @Autowired
//     private StudentRepository studentRepository;

//     @Autowired
//     private CourseRepository courseRepository;

//     @Autowired
//     private SemesterRepository semesterRepository;

//     @Autowired
//     private MockMvc mockMvc;
//     @Autowired
//     private UserRepository userRepository;

//     @InjectMocks
//     private StudentController studentController;

//     @Autowired
//     private AdminController InstructorController;


//     @Test
//     void getRegistrationData_studentNotFound() {
//         when(studentRepository.findByStudentId(1)).thenReturn(Optional.empty());

//         Map<String, Object> response = studentController.getRegistrationData(1);

//         assertEquals("error", response.get("status"));
//         assertEquals("Student not found", response.get("message"));
//     }

//     @Test
//     void getRegistrationData_noDepartment() {
//         Student student = new Student();
//         student.setStudentId(1);
//         student.setDepartmentId(null);
//         when(studentRepository.findByStudentId(1)).thenReturn(Optional.of(student));

//         Map<String, Object> response = studentController.getRegistrationData(1);

//         assertEquals("error", response.get("status"));
//         assertEquals("Student is not linked to a department", response.get("message"));
//     }

//     @Test
//     void getRegistrationData_noCurrentSemester() {
//         Student student = new Student();
//         student.setStudentId(1);
//         student.setDepartmentId(10);
//         when(studentRepository.findByStudentId(1)).thenReturn(Optional.of(student));



//         Semester semester = new Semester();
//         semester.setRegistrationOpen(false);
//         Map<String, Object> response = studentController.getRegistrationData(1);

//         @SuppressWarnings("unchecked")
//         Map<String, Object> data = (Map<String, Object>) response.get("data");
//         assertEquals(false, data.get("registrationOpen"));
//         assertNull(data.get("currentSemester"));
//     }

//     @Test
//     void getRegistrationData_successWithRegistrations() {
//         // Student setup
//         Student student = new Student();
//         student.setStudentId(1);
//         student.setDepartmentId(10);
//         when(studentRepository.findByStudentId(1)).thenReturn(Optional.of(student));

//         // Current semester
//         Semester semester = new Semester();
//         semester.setSemesterId(100);
//         semester.setName("Fall 2025");
//         semester.setRegistrationOpen(true);


//         // Department courses
//         DepartmentCourse dc1 = new DepartmentCourse();
//         dc1.setCourseId(200);
//         dc1.setCourseType("core");
//         when(departmentCourseRepository.findByDepartmentId(10))
//                 .thenReturn(List.of(dc1));

//         // ASU courses (mock getAsuDepartmentId)
//         doReturn(20).when(studentController).getAsuDepartmentId();
//         DepartmentCourse asuDc = new DepartmentCourse();
//         asuDc.setCourseId(300);
//         when(departmentCourseRepository.findByDepartmentId(20))
//                 .thenReturn(List.of(asuDc));

//         // Offered courses
//         OfferedCourse oc1 = new OfferedCourse();
//         oc1.setOfferedCourseId(1000);
//         oc1.setCourseId(200);
//         oc1.setSemesterId(100);
//         OfferedCourse oc2 = new OfferedCourse();
//         oc2.setOfferedCourseId(1001);
//         oc2.setCourseId(300);
//         oc2.setSemesterId(100);
//         when(offeredCourseRepository.findBySemesterId(100)).thenReturn(List.of(oc1, oc2));

//         // Enrollment
//         Enrollment enrollment = new Enrollment();
//         enrollment.setEnrollmentId(10);
//         enrollment.setStudentId(1);
//         enrollment.setSectionId(500);
//         enrollment.setStatus("approved");
//         when(enrollmentRepository.findByStudentId(1)).thenReturn(List.of(enrollment));

//         // Section, Course mocks
//         Section section = new Section();
//         section.setSectionId(500);
//         section.setOfferedCourseId(1000);
//         section.setSectionNumber("01");
//         when(sectionRepository.findBySectionId(500)).thenReturn(Optional.of(section));

//         Course course = new Course();
//         course.setCourseId(200);
//         course.setCourseCode("CS101");
//         course.setTitle("Intro CS");
//         course.setCredits(3);
//         when(courseRepository.findById(200)).thenReturn(Optional.of(course));

//         // When
//         Map<String, Object> response = studentController.getRegistrationData(1);

//         // Then
//         assertEquals("success", response.get("status"));

//         @SuppressWarnings("unchecked")
//         Map<String, Object> data = (Map<String, Object>) response.get("data");
//         assertTrue((Boolean) data.get("registrationOpen"));

//         @SuppressWarnings("unchecked")
//         List<Map<String, Object>> registeredCourses =
//                 (List<Map<String, Object>>) data.get("registeredCourses");
//         assertEquals(1, registeredCourses.size());

//         @SuppressWarnings("unchecked")
//         List<Map<String, Object>> courses =
//                 (List<Map<String, Object>>) data.get("courses");
//         assertEquals(2, courses.size()); // ASU + Department course
//     }

//     @Test
//     void getRegistrationData_noRegistrationsButAvailableCourses() {
//         Student student = new Student();
//         student.setStudentId(1);
//         student.setDepartmentId(10);
//         when(studentRepository.findByStudentId(1)).thenReturn(Optional.of(student));

//         Semester semester = new Semester();
//         semester.setSemesterId(100);
//         semester.setRegistrationOpen(false);

//         doReturn(20).when(studentController).getAsuDepartmentId();

//         when(enrollmentRepository.findByStudentId(1)).thenReturn(Collections.emptyList());
//         when(departmentCourseRepository.findByDepartmentId(10)).thenReturn(Collections.emptyList());
//         when(departmentCourseRepository.findByDepartmentId(20)).thenReturn(Collections.emptyList());
//         when(offeredCourseRepository.findBySemesterId(100)).thenReturn(Collections.emptyList());

//         Map<String, Object> response = studentController.getRegistrationData(1);

//         @SuppressWarnings("unchecked")
//         Map<String, Object> data = (Map<String, Object>) response.get("data");
//         assertFalse((Boolean) data.get("registrationOpen"));
//         assertEquals("Registration is currently closed. You can still view available courses.",
//                 response.get("message"));
//     }

//     // Helper to create request map
//     private Map<String, Object> createRequest(Integer studentId, Integer enrollmentId) {
//         Map<String, Object> request = new HashMap<>();
//         request.put("studentId", studentId);
//         request.put("enrollmentId", enrollmentId);
//         return request;
//     }

//     @Test
//     void dropCourse_success() {
//         Integer studentId = 1;
//         Integer enrollmentId = 10;
//         Map<String, Object> request = createRequest(studentId, enrollmentId);

//         Student student = new Student();
//         student.setStudentId(studentId);
//         when(studentRepository.findByStudentId(studentId)).thenReturn(Optional.of(student));

//         Enrollment enrollment = new Enrollment();
//         enrollment.setEnrollmentId(enrollmentId);
//         enrollment.setStudentId(studentId);
//         enrollment.setSectionId(100);
//         enrollment.setStatus("approved");
//         when(enrollmentRepository.findById(enrollmentId)).thenReturn(Optional.of(enrollment));

//         Section section = new Section();
//         section.setSectionId(100);
//         section.setOfferedCourseId(1000);
//         when(sectionRepository.findBySectionId(100)).thenReturn(Optional.of(section));

//         OfferedCourse offeredCourse = new OfferedCourse();
//         offeredCourse.setOfferedCourseId(1000);
//         offeredCourse.setSemesterId(2000);
//         when(offeredCourseRepository.findByOfferedCourseId(1000)).thenReturn(Optional.of(offeredCourse));

//         Semester semester = new Semester();
//         semester.setSemesterId(2000);
//         semester.setStartDate(Date.valueOf(LocalDate.now().minusDays(1)));
//         semester.setEndDate(Date.valueOf(LocalDate.now().plusDays(10)));
//         semester.setRegistrationOpen(true);
//         when(semesterRepository.findById(2000)).thenReturn(Optional.of(semester));

//         Map<String, Object> response = studentController.dropCourse(request);

//         assertEquals("success", response.get("status"));
//         assertEquals("Drop request submitted. Waiting for advisor approval.", response.get("message"));

//         ArgumentCaptor<Enrollment> enrollmentCaptor = ArgumentCaptor.forClass(Enrollment.class);
//         verify(enrollmentRepository).save(enrollmentCaptor.capture());

//         Enrollment savedEnrollment = enrollmentCaptor.getValue();
//         assertEquals("drop_pending", savedEnrollment.getStatus());
//     }

//     @Test
//     void dropCourse_invalidStudentOrEnrollment() {
//         Map<String, Object> request = new HashMap<>();
//         // Missing studentId and enrollmentId
//         Map<String, Object> response = studentController.dropCourse(request);

//         assertEquals("error", response.get("status"));
//         assertEquals("Invalid student or enrollment information.", response.get("message"));
//     }

//     @Test
//     void dropCourse_studentNotFound() {
//         Integer studentId = 1;
//         Integer enrollmentId = 10;
//         Map<String, Object> request = createRequest(studentId, enrollmentId);
//         when(studentRepository.findByStudentId(studentId)).thenReturn(Optional.empty());

//         Map<String, Object> response = studentController.dropCourse(request);

//         assertEquals("error", response.get("status"));
//         assertEquals("Student not found.", response.get("message"));
//     }

//     @Test
//     void dropCourse_enrollmentNotFound() {
//         Integer studentId = 1;
//         Integer enrollmentId = 10;
//         Map<String, Object> request = createRequest(studentId, enrollmentId);
//         Student student = new Student();
//         student.setStudentId(studentId);
//         when(studentRepository.findByStudentId(studentId)).thenReturn(Optional.of(student));
//         when(enrollmentRepository.findById(enrollmentId)).thenReturn(Optional.empty());

//         Map<String, Object> response = studentController.dropCourse(request);

//         assertEquals("error", response.get("status"));
//         assertEquals("Enrollment not found.", response.get("message"));
//     }

//     @Test
//     void dropCourse_enrollmentStudentMismatch() {
//         Integer studentId = 1;
//         Integer enrollmentId = 10;
//         Map<String, Object> request = createRequest(studentId, enrollmentId);
//         Student student = new Student();
//         student.setStudentId(studentId);
//         when(studentRepository.findByStudentId(studentId)).thenReturn(Optional.of(student));

//         Enrollment enrollment = new Enrollment();
//         enrollment.setEnrollmentId(enrollmentId);
//         enrollment.setStudentId(99);  // different student
//         when(enrollmentRepository.findById(enrollmentId)).thenReturn(Optional.of(enrollment));

//         Map<String, Object> response = studentController.dropCourse(request);

//         assertEquals("error", response.get("status"));
//         assertEquals("Enrollment does not belong to this student.", response.get("message"));
//     }

//     @Test
//     void dropCourse_sectionNotFound() {
//         Integer studentId = 1;
//         Integer enrollmentId = 10;
//         Map<String, Object> request = createRequest(studentId, enrollmentId);
//         Student student = new Student();
//         student.setStudentId(studentId);
//         when(studentRepository.findByStudentId(studentId)).thenReturn(Optional.of(student));

//         Enrollment enrollment = new Enrollment();
//         enrollment.setEnrollmentId(enrollmentId);
//         enrollment.setStudentId(studentId);
//         enrollment.setSectionId(100);
//         enrollment.setStatus("approved");
//         when(enrollmentRepository.findById(enrollmentId)).thenReturn(Optional.of(enrollment));

//         when(sectionRepository.findBySectionId(100)).thenReturn(Optional.empty());

//         Map<String, Object> response = studentController.dropCourse(request);
//         assertEquals("error", response.get("status"));
//         assertEquals("Section not found.", response.get("message"));
//     }

//     @Test
//     void dropCourse_offeredCourseNotFound() {
//         Integer studentId = 1;
//         Integer enrollmentId = 10;
//         Map<String, Object> request = createRequest(studentId, enrollmentId);
//         Student student = new Student();
//         student.setStudentId(studentId);
//         when(studentRepository.findByStudentId(studentId)).thenReturn(Optional.of(student));

//         Enrollment enrollment = new Enrollment();
//         enrollment.setEnrollmentId(enrollmentId);
//         enrollment.setStudentId(studentId);
//         enrollment.setSectionId(100);
//         enrollment.setStatus("approved");
//         when(enrollmentRepository.findById(enrollmentId)).thenReturn(Optional.of(enrollment));

//         Section section = new Section();
//         section.setSectionId(100);
//         section.setOfferedCourseId(1000);
//         when(sectionRepository.findBySectionId(100)).thenReturn(Optional.of(section));

//         when(offeredCourseRepository.findByOfferedCourseId(1000)).thenReturn(Optional.empty());

//         Map<String, Object> response = studentController.dropCourse(request);
//         assertEquals("error", response.get("status"));
//         assertEquals("Offered course not found.", response.get("message"));
//     }

//     @Test
//     void dropCourse_semesterNotFound() {
//         Integer studentId = 1;
//         Integer enrollmentId = 10;
//         Map<String, Object> request = createRequest(studentId, enrollmentId);
//         Student student = new Student();
//         student.setStudentId(studentId);
//         when(studentRepository.findByStudentId(studentId)).thenReturn(Optional.of(student));

//         Enrollment enrollment = new Enrollment();
//         enrollment.setEnrollmentId(enrollmentId);
//         enrollment.setStudentId(studentId);
//         enrollment.setSectionId(100);
//         enrollment.setStatus("approved");
//         when(enrollmentRepository.findById(enrollmentId)).thenReturn(Optional.of(enrollment));

//         Section section = new Section();
//         section.setSectionId(100);
//         section.setOfferedCourseId(1000);
//         when(sectionRepository.findBySectionId(100)).thenReturn(Optional.of(section));

//         OfferedCourse offeredCourse = new OfferedCourse();
//         offeredCourse.setOfferedCourseId(1000);
//         offeredCourse.setSemesterId(2000);
//         when(offeredCourseRepository.findByOfferedCourseId(1000)).thenReturn(Optional.of(offeredCourse));

//         when(semesterRepository.findById(2000)).thenReturn(Optional.empty());

//         Map<String, Object> response = studentController.dropCourse(request);
//         assertEquals("error", response.get("status"));
//         assertEquals("Semester not found.", response.get("message"));
//     }

//     @Test
//     void dropCourse_notWithinSemesterPeriod() {
//         Integer studentId = 1;
//         Integer enrollmentId = 10;
//         Map<String, Object> request = createRequest(studentId, enrollmentId);
//         Student student = new Student();
//         student.setStudentId(studentId);
//         when(studentRepository.findByStudentId(studentId)).thenReturn(Optional.of(student));

//         Enrollment enrollment = new Enrollment();
//         enrollment.setEnrollmentId(enrollmentId);
//         enrollment.setStudentId(studentId);
//         enrollment.setSectionId(100);
//         enrollment.setStatus("approved");
//         when(enrollmentRepository.findById(enrollmentId)).thenReturn(Optional.of(enrollment));

//         Section section = new Section();
//         section.setSectionId(100);
//         section.setOfferedCourseId(1000);
//         when(sectionRepository.findBySectionId(100)).thenReturn(Optional.of(section));

//         OfferedCourse offeredCourse = new OfferedCourse();
//         offeredCourse.setOfferedCourseId(1000);
//         offeredCourse.setSemesterId(2000);
//         when(offeredCourseRepository.findByOfferedCourseId(1000)).thenReturn(Optional.of(offeredCourse));

//         Semester semester = new Semester();
//         semester.setSemesterId(2000);
//         semester.setStartDate(Date.valueOf(LocalDate.now().plusDays(1))); // Future start
//         semester.setEndDate(Date.valueOf(LocalDate.now().plusDays(10)));
//         semester.setRegistrationOpen(true);
//         when(semesterRepository.findById(2000)).thenReturn(Optional.of(semester));

//         Map<String, Object> response = studentController.dropCourse(request);

//         assertEquals("error", response.get("status"));
//         assertEquals("Dropping courses is only allowed during the active semester period.", response.get("message"));
//     }

//     @Test
//     void dropCourse_registrationWindowClosed() {
//         Integer studentId = 1;
//         Integer enrollmentId = 10;
//         Map<String, Object> request = createRequest(studentId, enrollmentId);
//         Student student = new Student();
//         student.setStudentId(studentId);
//         when(studentRepository.findByStudentId(studentId)).thenReturn(Optional.of(student));

//         Enrollment enrollment = new Enrollment();
//         enrollment.setEnrollmentId(enrollmentId);
//         enrollment.setStudentId(studentId);
//         enrollment.setSectionId(100);
//         enrollment.setStatus("approved");
//         when(enrollmentRepository.findById(enrollmentId)).thenReturn(Optional.of(enrollment));

//         Section section = new Section();
//         section.setSectionId(100);
//         section.setOfferedCourseId(1000);
//         when(sectionRepository.findBySectionId(100)).thenReturn(Optional.of(section));

//         OfferedCourse offeredCourse = new OfferedCourse();
//         offeredCourse.setOfferedCourseId(1000);
//         offeredCourse.setSemesterId(2000);
//         when(offeredCourseRepository.findByOfferedCourseId(1000)).thenReturn(Optional.of(offeredCourse));

//         Semester semester = new Semester();
//         semester.setSemesterId(2000);
//         semester.setStartDate(Date.valueOf(LocalDate.now().minusDays(1)));
//         semester.setEndDate(Date.valueOf(LocalDate.now().plusDays(10)));
//         semester.setRegistrationOpen(false);
//         when(semesterRepository.findById(2000)).thenReturn(Optional.of(semester));

//         Map<String, Object> response = studentController.dropCourse(request);

//         assertEquals("error", response.get("status"));
//         assertEquals("Registration window is closed; you cannot drop courses now.", response.get("message"));
//     }

//     @Test
//     void dropCourse_alreadyDropPending() {
//         Integer studentId = 1;
//         Integer enrollmentId = 10;
//         Map<String, Object> request = createRequest(studentId, enrollmentId);
//         Student student = new Student();
//         student.setStudentId(studentId);
//         when(studentRepository.findByStudentId(studentId)).thenReturn(Optional.of(student));

//         Enrollment enrollment = new Enrollment();
//         enrollment.setEnrollmentId(enrollmentId);
//         enrollment.setStudentId(studentId);
//         enrollment.setSectionId(100);
//         enrollment.setStatus("drop_pending");
//         when(enrollmentRepository.findById(enrollmentId)).thenReturn(Optional.of(enrollment));

//         Section section = new Section();
//         section.setSectionId(100);
//         section.setOfferedCourseId(1000);
//         when(sectionRepository.findBySectionId(100)).thenReturn(Optional.of(section));

//         OfferedCourse offeredCourse = new OfferedCourse();
//         offeredCourse.setOfferedCourseId(1000);
//         offeredCourse.setSemesterId(2000);
//         when(offeredCourseRepository.findByOfferedCourseId(1000)).thenReturn(Optional.of(offeredCourse));

//         Semester semester = new Semester();
//         semester.setSemesterId(2000);
//         semester.setStartDate(Date.valueOf(LocalDate.now().minusDays(1)));
//         semester.setEndDate(Date.valueOf(LocalDate.now().plusDays(10)));
//         semester.setRegistrationOpen(true);
//         when(semesterRepository.findById(2000)).thenReturn(Optional.of(semester));

//         Map<String, Object> response = studentController.dropCourse(request);

//         assertEquals("error", response.get("status"));
//         assertEquals("You already have a pending drop request for this course.", response.get("message"));
//     }

//     @Test
//     void dropCourse_notApprovedEnrollment() {
//         Integer studentId = 1;
//         Integer enrollmentId = 10;
//         Map<String, Object> request = createRequest(studentId, enrollmentId);
//         Student student = new Student();
//         student.setStudentId(studentId);
//         when(studentRepository.findByStudentId(studentId)).thenReturn(Optional.of(student));

//         Enrollment enrollment = new Enrollment();
//         enrollment.setEnrollmentId(enrollmentId);
//         enrollment.setStudentId(studentId);
//         enrollment.setSectionId(100);
//         enrollment.setStatus("pending");
//         when(enrollmentRepository.findById(enrollmentId)).thenReturn(Optional.of(enrollment));

//         Section section = new Section();
//         section.setSectionId(100);
//         section.setOfferedCourseId(1000);
//         when(sectionRepository.findBySectionId(100)).thenReturn(Optional.of(section));

//         OfferedCourse offeredCourse = new OfferedCourse();
//         offeredCourse.setOfferedCourseId(1000);
//         offeredCourse.setSemesterId(2000);
//         when(offeredCourseRepository.findByOfferedCourseId(1000)).thenReturn(Optional.of(offeredCourse));

//         Semester semester = new Semester();
//         semester.setSemesterId(2000);
//         semester.setStartDate(Date.valueOf(LocalDate.now().minusDays(1)));
//         semester.setEndDate(Date.valueOf(LocalDate.now().plusDays(10)));
//         semester.setRegistrationOpen(true);
//         when(semesterRepository.findById(2000)).thenReturn(Optional.of(semester));

//         Map<String, Object> response = studentController.dropCourse(request);

//         assertEquals("error", response.get("status"));
//         assertEquals("You cannot drop a course that is still pending registration approval. Please wait for your advisor to approve the registration first.", response.get("message"));
//     }
// }