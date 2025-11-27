package com.asu_lms.lms.Controllers;

import com.asu_lms.lms.Entities.*;
import com.asu_lms.lms.Repositories.*;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.*;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/instructors")
@CrossOrigin(origins = "*")
public class InstructorController {

    private final InstructorRepository instructorRepository;
    private final OfferedCourseInstructorRepository offeredCourseInstructorRepository;
    private final OfferedCourseRepository offeredCourseRepository;
    private final CourseRepository courseRepository;
    private final DepartmentCourseRepository departmentCourseRepository;
    private final DepartmentRepository departmentRepository;
    private final SemesterRepository semesterRepository;
    private final SectionRepository sectionRepository;
    private final StudentRepository studentRepository;
    private final UserRepository userRepository;
    private final EnrollmentRepository enrollmentRepository;
    private final GradeRepository gradeRepository;

    public InstructorController(
            InstructorRepository instructorRepository,
            OfferedCourseInstructorRepository offeredCourseInstructorRepository,
            OfferedCourseRepository offeredCourseRepository,
            CourseRepository courseRepository,
            DepartmentCourseRepository departmentCourseRepository,
            DepartmentRepository departmentRepository,
            SemesterRepository semesterRepository,
            SectionRepository sectionRepository,
            StudentRepository studentRepository,
            UserRepository userRepository,
            EnrollmentRepository enrollmentRepository,
            GradeRepository gradeRepository
    ) {
        this.instructorRepository = instructorRepository;
        this.offeredCourseInstructorRepository = offeredCourseInstructorRepository;
        this.offeredCourseRepository = offeredCourseRepository;
        this.courseRepository = courseRepository;
        this.departmentCourseRepository = departmentCourseRepository;
        this.departmentRepository = departmentRepository;
        this.semesterRepository = semesterRepository;
        this.sectionRepository = sectionRepository;
        this.studentRepository = studentRepository;
        this.userRepository = userRepository;
        this.enrollmentRepository = enrollmentRepository;
        this.gradeRepository = gradeRepository;
    }

    @GetMapping("/{instructorId}/dashboard")
    public Map<String, Object> getInstructorDashboard(@PathVariable Integer instructorId) {
        Map<String, Object> response = new HashMap<>();

        try {
            Optional<Instructor> instructorOpt = instructorRepository.findByInstructorId(instructorId);
            if (instructorOpt.isEmpty()) {
                response.put("status", "error");
                response.put("message", "Instructor not found");
                return response;
            }

            Instructor instructor = instructorOpt.get();

            List<Map<String, Object>> courses = buildCourseAssignments(instructor);
            int totalStudents = courses.stream()
                    .mapToInt(course -> (Integer) course.getOrDefault("totalStudents", 0))
                    .sum();

            Map<String, Object> data = new HashMap<>();
            data.put("instructorType", instructor.getInstructorType());
            data.put("courses", courses);
            data.put("studentsCount", totalStudents);
            data.put("pendingRequests", 0); // Placeholder for future workflows
            data.put("officeHours", buildOfficeHours(instructor.getOfficeHours()));

            if ("professor".equalsIgnoreCase(instructor.getInstructorType())) {
                data.put("advisees", buildAdviseeList(instructor));
            } else {
                data.put("advisees", Collections.emptyList());
            }

            response.put("status", "success");
            response.put("data", data);
        } catch (Exception e) {
            response.put("status", "error");
            response.put("message", "Error loading instructor dashboard: " + e.getMessage());
        }

        return response;
    }

    private List<Map<String, Object>> buildCourseAssignments(Instructor instructor) {
        List<OfferedCourseInstructor> assignments =
                offeredCourseInstructorRepository.findByInstructorId(instructor.getInstructorId());

        List<Map<String, Object>> courses = new ArrayList<>();

        for (OfferedCourseInstructor assignment : assignments) {
            Optional<OfferedCourse> offeredCourseOpt =
                    offeredCourseRepository.findByOfferedCourseId(assignment.getOfferedCourseId());
            if (offeredCourseOpt.isEmpty()) continue;
            OfferedCourse offeredCourse = offeredCourseOpt.get();

            Optional<Course> courseOpt = courseRepository.findById(offeredCourse.getCourseId());
            if (courseOpt.isEmpty()) continue;
            Course course = courseOpt.get();

            Optional<Semester> semesterOpt = semesterRepository.findById(offeredCourse.getSemesterId());
            String semesterName = semesterOpt.map(Semester::getName).orElse("Unknown Semester");
            boolean isCurrentTerm = semesterOpt.map(semester ->
                    isCurrentSemester(semester, LocalDate.now())).orElse(false);

            String departmentName = departmentCourseRepository.findByCourseId(course.getCourseId())
                    .stream()
                    .map(dc -> departmentRepository.findById(dc.getDepartmentId())
                            .map(Department::getName)
                            .orElse(null))
                    .filter(Objects::nonNull)
                    .findFirst()
                    .orElse("Unknown Department");

            List<Section> sections =
                    sectionRepository.findByOfferedCourseId(offeredCourse.getOfferedCourseId());
            List<Map<String, Object>> sectionSummaries = new ArrayList<>();
            int courseStudents = 0;

            for (Section section : sections) {
                int current = section.getCurrentEnrollment() != null ? section.getCurrentEnrollment() : 0;
                int capacity = section.getCapacity() != null ? section.getCapacity() : 0;
                courseStudents += current;

                Map<String, Object> sectionData = new HashMap<>();
                sectionData.put("sectionId", section.getSectionId());
                sectionData.put("sectionNumber", section.getSectionNumber());
                sectionData.put("capacity", capacity);
                sectionData.put("currentEnrollment", current);
                sectionSummaries.add(sectionData);
            }

            Map<String, Object> courseData = new HashMap<>();
            courseData.put("offeredCourseId", offeredCourse.getOfferedCourseId());
            courseData.put("courseId", course.getCourseId());
            courseData.put("courseCode", course.getCourseCode());
            courseData.put("courseTitle", course.getTitle());
            courseData.put("code", course.getCourseCode());
            courseData.put("name", course.getTitle());
            courseData.put("credits", course.getCredits());
            courseData.put("semester", semesterName);
            courseData.put("departmentName", departmentName);
            courseData.put("sections", sectionSummaries);
            courseData.put("totalStudents", courseStudents);
            courseData.put("students", courseStudents);
            courseData.put("currentTerm", isCurrentTerm);

            courses.add(courseData);
        }

        return courses;
    }

    private List<Map<String, Object>> buildOfficeHours(String officeHours) {
        if (officeHours == null || officeHours.trim().isEmpty()) {
            return Collections.emptyList();
        }

        Map<String, Object> slot = new HashMap<>();
        slot.put("day", officeHours);
        slot.put("from", "");
        slot.put("to", "");
        slot.put("location", "Office");
        return Collections.singletonList(slot);
    }

    private List<Map<String, Object>> buildAdviseeList(Instructor instructor) {
        List<Student> advisees = studentRepository.findByAdvisorId(instructor.getInstructorId());
        if (advisees.isEmpty()) return Collections.emptyList();

        return advisees.stream().map(student -> {
            Map<String, Object> studentData = new HashMap<>();
            studentData.put("studentId", student.getStudentId());
            studentData.put("studentUid", student.getStudentUid());
            studentData.put("departmentId", student.getDepartmentId());

            userRepository.findById(student.getStudentId()).ifPresent(user -> {
                studentData.put("name", user.getName());
                studentData.put("email", user.getEmail());
                studentData.put("status", user.getAccountStatus());
            });

            return studentData;
        }).collect(Collectors.toList());
    }

    @GetMapping("/{instructorId}/courses/{offeredCourseId}")
    public Map<String, Object> getCourseRoster(
            @PathVariable Integer instructorId,
            @PathVariable Integer offeredCourseId
    ) {
        Map<String, Object> response = new HashMap<>();

        try {
            Optional<OfferedCourseInstructor> assignmentOpt =
                    offeredCourseInstructorRepository.findByOfferedCourseIdAndInstructorId(
                            offeredCourseId, instructorId);
            if (assignmentOpt.isEmpty()) {
                response.put("status", "error");
                response.put("message", "Instructor is not assigned to this course");
                return response;
            }

            Optional<OfferedCourse> offeredCourseOpt = offeredCourseRepository.findByOfferedCourseId(offeredCourseId);
            if (offeredCourseOpt.isEmpty()) {
                response.put("status", "error");
                response.put("message", "Offered course not found");
                return response;
            }
            OfferedCourse offeredCourse = offeredCourseOpt.get();

            Optional<Course> courseOpt = courseRepository.findById(offeredCourse.getCourseId());
            if (courseOpt.isEmpty()) {
                response.put("status", "error");
                response.put("message", "Course not found");
                return response;
            }
            Course course = courseOpt.get();

            Optional<Semester> semesterOpt = semesterRepository.findById(offeredCourse.getSemesterId());
            String semesterName = semesterOpt.map(Semester::getName).orElse("Unknown Semester");

            String departmentName = departmentCourseRepository.findByCourseId(course.getCourseId())
                    .stream()
                    .map(dc -> departmentRepository.findById(dc.getDepartmentId())
                            .map(Department::getName)
                            .orElse(null))
                    .filter(Objects::nonNull)
                    .findFirst()
                    .orElse("Unknown Department");

            Map<String, Object> courseInfo = new HashMap<>();
            courseInfo.put("courseId", course.getCourseId());
            courseInfo.put("courseCode", course.getCourseCode());
            courseInfo.put("courseTitle", course.getTitle());
            courseInfo.put("credits", course.getCredits());
            courseInfo.put("semester", semesterName);
            courseInfo.put("departmentName", departmentName);

            List<Section> sections = sectionRepository.findByOfferedCourseId(offeredCourseId);
            List<Map<String, Object>> sectionDetails = new ArrayList<>();

            for (Section section : sections) {
                Map<String, Object> sectionData = new HashMap<>();
                sectionData.put("sectionId", section.getSectionId());
                sectionData.put("sectionNumber", section.getSectionNumber());
                sectionData.put("capacity", section.getCapacity());
                sectionData.put("currentEnrollment", section.getCurrentEnrollment());

                List<Enrollment> enrollments = enrollmentRepository.findBySectionId(section.getSectionId());
                List<Map<String, Object>> students = new ArrayList<>();

                for (Enrollment enrollment : enrollments) {
                    Map<String, Object> studentData = new HashMap<>();
                    studentData.put("enrollmentId", enrollment.getEnrollmentId());
                    studentData.put("studentId", enrollment.getStudentId());

                    studentRepository.findByStudentId(enrollment.getStudentId()).ifPresent(student -> {
                        studentData.put("studentUid", student.getStudentUid());
                        studentData.put("departmentId", student.getDepartmentId());
                    });

                    userRepository.findById(enrollment.getStudentId()).ifPresent(user -> {
                        studentData.put("name", user.getName());
                        studentData.put("email", user.getEmail());
                        studentData.put("status", user.getAccountStatus());
                    });

                    Map<String, Object> gradeData = new HashMap<>();
                    gradeRepository.findByEnrollmentId(enrollment.getEnrollmentId()).ifPresent(grade -> {
                        gradeData.put("midterm", grade.getMidterm());
                        gradeData.put("project", grade.getProject());
                        gradeData.put("assignmentsTotal", grade.getAssignmentsTotal());
                        gradeData.put("quizzesTotal", grade.getQuizzesTotal());
                        gradeData.put("attendance", grade.getAttendance());
                        gradeData.put("finalExamMark", grade.getFinalExamMark());
                        gradeData.put("finalLetterGrade", grade.getFinalLetterGrade());
                    });
                    studentData.put("grade", gradeData);

                    students.add(studentData);
                }

                sectionData.put("students", students);
                sectionDetails.add(sectionData);
            }

            Map<String, Object> data = new HashMap<>();
            data.put("course", courseInfo);
            data.put("sections", sectionDetails);

            response.put("status", "success");
            response.put("data", data);
        } catch (Exception e) {
            response.put("status", "error");
            response.put("message", "Error loading course roster: " + e.getMessage());
        }

        return response;
    }

    @PutMapping("/grades/{enrollmentId}")
    public Map<String, Object> updateGrade(
            @PathVariable Integer enrollmentId,
            @RequestBody Map<String, Object> payload
    ) {
        Map<String, Object> response = new HashMap<>();

        try {
            Optional<Enrollment> enrollmentOpt = enrollmentRepository.findById(enrollmentId);
            if (enrollmentOpt.isEmpty()) {
                response.put("status", "error");
                response.put("message", "Enrollment not found");
                return response;
            }

            Grade grade = gradeRepository.findByEnrollmentId(enrollmentId)
                    .orElseGet(() -> {
                        Grade g = new Grade();
                        g.setEnrollmentId(enrollmentId);
                        return g;
                    });

            applyGradeValue(grade::setMidterm, payload.get("midterm"));
            applyGradeValue(grade::setProject, payload.get("project"));
            applyGradeValue(grade::setAssignmentsTotal, payload.get("assignmentsTotal"));
            applyGradeValue(grade::setQuizzesTotal, payload.get("quizzesTotal"));
            applyGradeValue(grade::setAttendance, payload.get("attendance"));
            applyGradeValue(grade::setFinalExamMark, payload.get("finalExamMark"));

            gradeRepository.save(grade);

            Map<String, Object> gradeData = new HashMap<>();
            gradeData.put("midterm", grade.getMidterm());
            gradeData.put("project", grade.getProject());
            gradeData.put("assignmentsTotal", grade.getAssignmentsTotal());
            gradeData.put("quizzesTotal", grade.getQuizzesTotal());
            gradeData.put("attendance", grade.getAttendance());
            gradeData.put("finalExamMark", grade.getFinalExamMark());
            gradeData.put("finalLetterGrade", grade.getFinalLetterGrade());

            response.put("status", "success");
            response.put("data", gradeData);
        } catch (Exception e) {
            response.put("status", "error");
            response.put("message", "Error updating grade: " + e.getMessage());
        }

        return response;
    }

    private void applyGradeValue(java.util.function.Consumer<BigDecimal> consumer, Object value) {
        if (value == null || (value instanceof String && ((String) value).isBlank())) {
            consumer.accept(null);
            return;
        }
        try {
            BigDecimal decimalValue;
            if (value instanceof Number) {
                decimalValue = BigDecimal.valueOf(((Number) value).doubleValue());
            } else {
                decimalValue = new BigDecimal(value.toString());
            }
            consumer.accept(decimalValue);
        } catch (NumberFormatException ignored) {
            // Skip invalid values silently
        }
    }

    private boolean isCurrentSemester(Semester semester, LocalDate today) {
        if (semester.getStartDate() == null || semester.getEndDate() == null) {
            return false;
        }
        LocalDate start = semester.getStartDate().toLocalDate();
        LocalDate end = semester.getEndDate().toLocalDate();
        return (today.isEqual(start) || today.isAfter(start)) &&
                (today.isEqual(end) || today.isBefore(end));
    }

    @GetMapping("/{instructorId}/pending-requests")
    public Map<String, Object> getPendingRequests(@PathVariable Integer instructorId) {
        Map<String, Object> response = new HashMap<>();

        try {
            Optional<Instructor> instructorOpt = instructorRepository.findByInstructorId(instructorId);
            if (instructorOpt.isEmpty()) {
                response.put("status", "error");
                response.put("message", "Instructor not found");
                return response;
            }

            Instructor instructor = instructorOpt.get();
            if (!"professor".equalsIgnoreCase(instructor.getInstructorType())) {
                response.put("status", "error");
                response.put("message", "Only professors can view registration requests");
                return response;
            }

            List<Student> advisees = studentRepository.findByAdvisorId(instructorId);
            List<Map<String, Object>> pendingRegistrations = new ArrayList<>();
            List<Map<String, Object>> pendingDrops = new ArrayList<>();

            for (Student advisee : advisees) {
                List<Enrollment> enrollments = enrollmentRepository.findByStudentId(advisee.getStudentId());
                
                for (Enrollment enrollment : enrollments) {
                    String status = enrollment.getStatus();
                    if (!"pending".equals(status) && !"drop_pending".equals(status)) {
                        continue;
                    }

                    Optional<Section> sectionOpt = sectionRepository.findBySectionId(enrollment.getSectionId());
                    if (sectionOpt.isEmpty()) continue;
                    Section section = sectionOpt.get();

                    Optional<OfferedCourse> offeredCourseOpt = offeredCourseRepository.findByOfferedCourseId(section.getOfferedCourseId());
                    if (offeredCourseOpt.isEmpty()) continue;
                    OfferedCourse offeredCourse = offeredCourseOpt.get();

                    Optional<Course> courseOpt = courseRepository.findById(offeredCourse.getCourseId());
                    if (courseOpt.isEmpty()) continue;
                    Course course = courseOpt.get();

                    Optional<Semester> semesterOpt = semesterRepository.findById(offeredCourse.getSemesterId());
                    String semesterName = semesterOpt.map(Semester::getName).orElse("Unknown");

                    Optional<User> studentUserOpt = userRepository.findById(advisee.getStudentId());
                    String studentName = studentUserOpt.map(User::getName).orElse("Unknown");
                    String studentUid = advisee.getStudentUid() != null ? advisee.getStudentUid() : "N/A";

                    Map<String, Object> requestData = new HashMap<>();
                    requestData.put("enrollmentId", enrollment.getEnrollmentId());
                    requestData.put("studentId", advisee.getStudentId());
                    requestData.put("studentUid", studentUid);
                    requestData.put("studentName", studentName);
                    requestData.put("courseId", course.getCourseId());
                    requestData.put("courseCode", course.getCourseCode());
                    requestData.put("courseTitle", course.getTitle());
                    requestData.put("credits", course.getCredits());
                    requestData.put("sectionId", section.getSectionId());
                    requestData.put("sectionNumber", section.getSectionNumber());
                    requestData.put("semester", semesterName);
                    requestData.put("requestType", "pending".equals(status) ? "registration" : "drop");

                    if ("pending".equals(status)) {
                        pendingRegistrations.add(requestData);
                    } else {
                        pendingDrops.add(requestData);
                    }
                }
            }

            Map<String, Object> data = new HashMap<>();
            data.put("pendingRegistrations", pendingRegistrations);
            data.put("pendingDrops", pendingDrops);
            data.put("totalPending", pendingRegistrations.size() + pendingDrops.size());

            response.put("status", "success");
            response.put("data", data);
        } catch (Exception e) {
            response.put("status", "error");
            response.put("message", "Error loading pending requests: " + e.getMessage());
        }

        return response;
    }

    @PostMapping("/approve-request")
    @org.springframework.transaction.annotation.Transactional
    public Map<String, Object> approveRequest(@RequestBody Map<String, Object> request) {
        Map<String, Object> response = new HashMap<>();

        try {
            Integer instructorId = parseInteger(request.get("instructorId"));
            Integer enrollmentId = parseInteger(request.get("enrollmentId"));
            String action = (String) request.get("action"); // "approve" or "reject"

            if (instructorId == null || enrollmentId == null || action == null) {
                response.put("status", "error");
                response.put("message", "Invalid request parameters");
                return response;
            }

            Optional<Instructor> instructorOpt = instructorRepository.findByInstructorId(instructorId);
            if (instructorOpt.isEmpty()) {
                response.put("status", "error");
                response.put("message", "Instructor not found");
                return response;
            }

            Instructor instructor = instructorOpt.get();
            if (!"professor".equalsIgnoreCase(instructor.getInstructorType())) {
                response.put("status", "error");
                response.put("message", "Only professors can approve requests");
                return response;
            }

            Optional<Enrollment> enrollmentOpt = enrollmentRepository.findById(enrollmentId);
            if (enrollmentOpt.isEmpty()) {
                response.put("status", "error");
                response.put("message", "Enrollment not found");
                return response;
            }

            Enrollment enrollment = enrollmentOpt.get();
            String currentStatus = enrollment.getStatus();

            // Verify this enrollment belongs to an advisee
            Optional<Student> studentOpt = studentRepository.findByStudentId(enrollment.getStudentId());
            if (studentOpt.isEmpty() || !instructorId.equals(studentOpt.get().getAdvisorId())) {
                response.put("status", "error");
                response.put("message", "This enrollment does not belong to your advisee");
                return response;
            }

            Optional<Section> sectionOpt = sectionRepository.findBySectionId(enrollment.getSectionId());
            if (sectionOpt.isEmpty()) {
                response.put("status", "error");
                response.put("message", "Section not found");
                return response;
            }
            Section section = sectionOpt.get();

            if ("approve".equalsIgnoreCase(action)) {
                if ("pending".equals(currentStatus)) {
                    // Approve registration: change status to approved and increment section enrollment
                    enrollment.setStatus("approved");
                    enrollmentRepository.save(enrollment);
                    
                    int currentEnrollment = section.getCurrentEnrollment() != null ? section.getCurrentEnrollment() : 0;
                    section.setCurrentEnrollment(currentEnrollment + 1);
                    sectionRepository.save(section);
                    
                    response.put("status", "success");
                    response.put("message", "Registration approved successfully");
                } else if ("drop_pending".equals(currentStatus)) {
                    // Approve drop: decrement section enrollment first, then delete enrollment
                    Integer currentEnrollment = section.getCurrentEnrollment();
                    if (currentEnrollment == null) {
                        currentEnrollment = 0;
                    }
                    section.setCurrentEnrollment(Math.max(0, currentEnrollment - 1));
                    sectionRepository.save(section);
                    
                    // Delete enrollment after updating section
                    enrollmentRepository.delete(enrollment);
                    
                    response.put("status", "success");
                    response.put("message", "Drop request approved successfully");
                } else {
                    response.put("status", "error");
                    response.put("message", "This enrollment is not in a pending state");
                }
            } else if ("reject".equalsIgnoreCase(action)) {
                if ("pending".equals(currentStatus)) {
                    // Reject registration: delete the pending enrollment
                    enrollmentRepository.delete(enrollment);
                    response.put("status", "success");
                    response.put("message", "Registration request rejected");
                } else if ("drop_pending".equals(currentStatus)) {
                    // Reject drop: change status back to approved
                    enrollment.setStatus("approved");
                    enrollmentRepository.save(enrollment);
                    response.put("status", "success");
                    response.put("message", "Drop request rejected");
                } else {
                    response.put("status", "error");
                    response.put("message", "This enrollment is not in a pending state");
                }
            } else {
                response.put("status", "error");
                response.put("message", "Invalid action. Use 'approve' or 'reject'");
            }

        } catch (Exception e) {
            response.put("status", "error");
            response.put("message", "Error processing request: " + e.getMessage());
        }

        return response;
    }

    private Integer parseInteger(Object value) {
        if (value instanceof Integer) {
            return (Integer) value;
        }
        if (value instanceof String) {
            try {
                return Integer.parseInt((String) value);
            } catch (NumberFormatException ignored) {
                return null;
            }
        }
        if (value instanceof Number) {
            return ((Number) value).intValue();
        }
        return null;
    }
}

