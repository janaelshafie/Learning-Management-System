package com.asu_lms.lms.Controllers;

import com.asu_lms.lms.Entities.*;
import com.asu_lms.lms.Repositories.*;
import com.asu_lms.lms.Services.CourseGradeConfigService;
import com.asu_lms.lms.Services.EAVService;
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
    private final EAVService eavService;
    private final CourseGradeConfigService gradeConfigService;

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
            GradeRepository gradeRepository,
            EAVService eavService,
            CourseGradeConfigService gradeConfigService
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
        this.eavService = eavService;
        this.gradeConfigService = gradeConfigService;
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

    private static final String OFFICE_HOUR_FIELD_DELIMITER = "~";
    private static final String OFFICE_HOUR_SLOT_JOIN = " | ";

    private List<Map<String, Object>> buildOfficeHours(String officeHours) {
        // Office hours are stored as a single string column on Instructor.officeHours.
        // Each slot is serialized as day~from~to~location and separated by "|".
        if (officeHours == null) {
            return Collections.emptyList();
        }

        String normalized = officeHours.trim();
        if (normalized.isEmpty()) {
            return Collections.emptyList();
        }

        String[] rawSlots = normalized.split("\\|");
        List<Map<String, Object>> slots = new ArrayList<>();

        for (String raw : rawSlots) {
            String text = raw.trim();
            if (text.isEmpty()) {
                continue;
            }

            String[] parts = text.split(OFFICE_HOUR_FIELD_DELIMITER, -1);
            Map<String, Object> slot = new HashMap<>();
            if (parts.length >= 3) {
                slot.put("day", parts[0]);
                slot.put("from", parts[1]);
                slot.put("to", parts[2]);
                slot.put("location", parts.length >= 4 ? parts[3] : "");
            } else {
                // Backwards compatibility for legacy data where the whole string was stored.
                slot.put("day", text);
                slot.put("from", "");
                slot.put("to", "");
                slot.put("location", "");
            }
            slots.add(slot);
        }

        return slots;
    }

    @PutMapping("/{instructorId}/office-hours")
    public Map<String, Object> updateOfficeHours(
            @PathVariable Integer instructorId,
            @RequestBody Map<String, Object> request
    ) {
        Map<String, Object> response = new HashMap<>();

        try {
            Optional<Instructor> instructorOpt = instructorRepository.findByInstructorId(instructorId);
            if (instructorOpt.isEmpty()) {
                response.put("status", "error");
                response.put("message", "Instructor not found");
                return response;
            }

            Instructor instructor = instructorOpt.get();

            // The frontend sends structured slots (day, from, to, location) which we serialize
            // back into a single string to preserve the existing column structure.
            Object slotsObj = request.get("slots");
            String combined = serializeOfficeHours(slotsObj);

            instructor.setOfficeHours(combined);
            instructorRepository.save(instructor);

            response.put("status", "success");
            response.put("message", "Office hours updated successfully");
            response.put("officeHours", buildOfficeHours(combined));
        } catch (Exception e) {
            response.put("status", "error");
            response.put("message", "Error updating office hours: " + e.getMessage());
        }

        return response;
    }

    private String serializeOfficeHours(Object slotsObj) {
        if (!(slotsObj instanceof List<?> slotsList)) {
            return "";
        }

        List<String> serialized = new ArrayList<>();

        for (Object entry : slotsList) {
            if (!(entry instanceof Map<?, ?> mapEntry)) {
                continue;
            }

            String day = Optional.ofNullable(mapEntry.get("day"))
                    .map(Object::toString)
                    .map(String::trim)
                    .orElse("");
            String from = Optional.ofNullable(mapEntry.get("from"))
                    .map(Object::toString)
                    .map(String::trim)
                    .orElse("");
            String to = Optional.ofNullable(mapEntry.get("to"))
                    .map(Object::toString)
                    .map(String::trim)
                    .orElse("");
            String location = Optional.ofNullable(mapEntry.get("location"))
                    .map(Object::toString)
                    .map(String::trim)
                    .orElse("");

            if (day.isEmpty() || from.isEmpty() || to.isEmpty()) {
                continue;
            }

            serialized.add(String.join(OFFICE_HOUR_FIELD_DELIMITER, day, from, to, location));
        }

        if (serialized.isEmpty()) {
            return "";
        }

        return serialized.stream().collect(Collectors.joining(OFFICE_HOUR_SLOT_JOIN));
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
                        // Get grade attributes from EAV
                        Map<String, String> gradeAttributes = eavService.getGradeAttributes(grade.getGradeId());
                        gradeData.put("midterm", gradeAttributes.get("midterm"));
                        gradeData.put("project", gradeAttributes.get("project"));
                        gradeData.put("assignmentsTotal", gradeAttributes.get("assignments_total"));
                        gradeData.put("quizzesTotal", gradeAttributes.get("quizzes_total"));
                        gradeData.put("attendance", gradeAttributes.get("attendance"));
                        gradeData.put("finalExamMark", gradeAttributes.get("final_exam_mark"));
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

            Enrollment enrollment = enrollmentOpt.get();
            
            // Get offered course ID from enrollment -> section -> offeredCourse
            Optional<Section> sectionOpt = sectionRepository.findBySectionId(enrollment.getSectionId());
            if (sectionOpt.isEmpty()) {
                response.put("status", "error");
                response.put("message", "Section not found");
                return response;
            }
            
            Integer offeredCourseId = sectionOpt.get().getOfferedCourseId();
            
            // Get grade component configuration for this course
            Map<String, Object> configResponse = gradeConfigService.getGradeComponentConfig(offeredCourseId);
            if (!"success".equals(configResponse.get("status"))) {
                response.put("status", "error");
                response.put("message", "Error getting grade component configuration");
                return response;
            }
            
            @SuppressWarnings("unchecked")
            Map<String, Double> configuredComponents = (Map<String, Double>) configResponse.get("components");

            Grade grade = gradeRepository.findByEnrollmentId(enrollmentId)
                    .orElseGet(() -> {
                        Grade g = new Grade();
                        g.setEnrollmentId(enrollmentId);
                        gradeRepository.save(g);
                        return g;
                    });

            // Map frontend field names to database attribute names
            Map<String, String> fieldNameMap = new HashMap<>();
            fieldNameMap.put("midterm", "midterm");
            fieldNameMap.put("project", "project");
            fieldNameMap.put("assignmentsTotal", "assignments_total");
            fieldNameMap.put("quizzesTotal", "quizzes_total");
            fieldNameMap.put("attendance", "attendance");
            fieldNameMap.put("finalExamMark", "final_exam_mark");

            // Get existing grade attributes first
            Map<String, String> existingGradeAttributes = eavService.getGradeAttributes(grade.getGradeId());
            
            // Calculate total marks and validate
            double totalMarks = 0.0;
            for (Map.Entry<String, String> entry : fieldNameMap.entrySet()) {
                String frontendField = entry.getKey();
                String dbAttribute = entry.getValue();
                
                // Check if this component is enabled in configuration
                if (configuredComponents.containsKey(dbAttribute) && configuredComponents.get(dbAttribute) != null) {
                    Object valueObj = payload.get(frontendField);
                    String valueStr = null;
                    
                    // Use value from payload if present, otherwise use existing value
                    if (valueObj != null) {
                        valueStr = convertToString(valueObj);
                    } else {
                        valueStr = existingGradeAttributes.get(dbAttribute);
                    }
                    
                    if (valueStr != null && !valueStr.trim().isEmpty()) {
                        try {
                            double value = Double.parseDouble(valueStr);
                            
                            // Update the grade attribute if it was in payload
                            if (payload.containsKey(frontendField)) {
                                eavService.setGradeAttribute(grade, dbAttribute, valueStr);
                            }
                            
                            // Validate against max value
                            Double maxValue = configuredComponents.get(dbAttribute);
                            if (value > maxValue) {
                                response.put("status", "error");
                                response.put("message", String.format("%s value (%.2f) exceeds maximum (%.2f)", 
                                    frontendField, value, maxValue));
                                return response;
                            }
                            totalMarks += value;
                        } catch (NumberFormatException e) {
                            // Skip invalid numbers
                        }
                    }
                }
            }

            // Validate total doesn't exceed 100
            double maxTotal = configuredComponents.values().stream()
                .filter(Objects::nonNull)
                .mapToDouble(Double::doubleValue)
                .sum();
            
            if (totalMarks > 100.0) {
                response.put("status", "error");
                response.put("message", String.format("Total marks (%.2f) exceeds 100. Please adjust the grades.", totalMarks));
                return response;
            }

            // Do NOT set finalLetterGrade here - it should be set manually via separate endpoint
            // Only allow setting it explicitly if provided (for backward compatibility, but should use calculate endpoint)
            if (payload.containsKey("finalLetterGrade")) {
                grade.setFinalLetterGrade((String) payload.get("finalLetterGrade"));
                gradeRepository.save(grade);
            }

            // Get all grade attributes to return
            Map<String, String> gradeAttributes = eavService.getGradeAttributes(grade.getGradeId());
            Map<String, Object> gradeData = new HashMap<>();
            gradeData.put("midterm", gradeAttributes.get("midterm"));
            gradeData.put("project", gradeAttributes.get("project"));
            gradeData.put("assignmentsTotal", gradeAttributes.get("assignments_total"));
            gradeData.put("quizzesTotal", gradeAttributes.get("quizzes_total"));
            gradeData.put("attendance", gradeAttributes.get("attendance"));
            gradeData.put("finalExamMark", gradeAttributes.get("final_exam_mark"));
            gradeData.put("finalLetterGrade", grade.getFinalLetterGrade());
            gradeData.put("totalMarks", totalMarks);
            gradeData.put("maxTotal", maxTotal);

            response.put("status", "success");
            response.put("data", gradeData);
        } catch (Exception e) {
            response.put("status", "error");
            response.put("message", "Error updating grade: " + e.getMessage());
        }

        return response;
    }

    /**
     * Calculate and set final letter grade for a student
     * POST /api/instructors/grades/{enrollmentId}/calculate-final-grade
     */
    @PostMapping("/grades/{enrollmentId}/calculate-final-grade")
    public Map<String, Object> calculateFinalGrade(@PathVariable Integer enrollmentId) {
        Map<String, Object> response = new HashMap<>();

        try {
            Optional<Enrollment> enrollmentOpt = enrollmentRepository.findById(enrollmentId);
            if (enrollmentOpt.isEmpty()) {
                response.put("status", "error");
                response.put("message", "Enrollment not found");
                return response;
            }

            Enrollment enrollment = enrollmentOpt.get();
            
            // Get offered course ID
            Optional<Section> sectionOpt = sectionRepository.findBySectionId(enrollment.getSectionId());
            if (sectionOpt.isEmpty()) {
                response.put("status", "error");
                response.put("message", "Section not found");
                return response;
            }
            
            Integer offeredCourseId = sectionOpt.get().getOfferedCourseId();
            
            // Get grade component configuration
            Map<String, Object> configResponse = gradeConfigService.getGradeComponentConfig(offeredCourseId);
            if (!"success".equals(configResponse.get("status"))) {
                response.put("status", "error");
                response.put("message", "Error getting grade component configuration");
                return response;
            }
            
            @SuppressWarnings("unchecked")
            Map<String, Double> configuredComponents = (Map<String, Double>) configResponse.get("components");

            // Get or create grade
            Grade grade = gradeRepository.findByEnrollmentId(enrollmentId)
                    .orElseGet(() -> {
                        Grade g = new Grade();
                        g.setEnrollmentId(enrollmentId);
                        gradeRepository.save(g);
                        return g;
                    });

            // Calculate total marks from grade attributes
            Map<String, String> gradeAttributes = eavService.getGradeAttributes(grade.getGradeId());
            double totalMarks = 0.0;
            
            for (Map.Entry<String, Double> configEntry : configuredComponents.entrySet()) {
                String attributeName = configEntry.getKey();
                if (configEntry.getValue() != null) { // Component is enabled
                    String valueStr = gradeAttributes.get(attributeName);
                    if (valueStr != null && !valueStr.trim().isEmpty()) {
                        try {
                            double value = Double.parseDouble(valueStr);
                            totalMarks += value;
                        } catch (NumberFormatException e) {
                            // Skip invalid values
                        }
                    }
                }
            }

            // Calculate final letter grade
            String finalLetterGrade = gradeConfigService.calculateFinalLetterGrade(totalMarks);
            
            // Set final letter grade
            grade.setFinalLetterGrade(finalLetterGrade);
            gradeRepository.save(grade);

            response.put("status", "success");
            response.put("message", "Final grade calculated and saved");
            response.put("totalMarks", totalMarks);
            response.put("finalLetterGrade", finalLetterGrade);

        } catch (Exception e) {
            response.put("status", "error");
            response.put("message", "Error calculating final grade: " + e.getMessage());
        }

        return response;
    }

    private String convertToString(Object value) {
        if (value == null) return null;
        if (value instanceof String && ((String) value).isBlank()) return null;
        return value.toString();
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
                    String status = eavService.getEnrollmentStatus(enrollment.getEnrollmentId());
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
            String currentStatus = eavService.getEnrollmentStatus(enrollment.getEnrollmentId());

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
                    eavService.setEnrollmentAttribute(enrollment, "status", "approved");
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
                    eavService.setEnrollmentAttribute(enrollment, "status", "approved");
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

