package com.asu_lms.lms.Controllers;

import com.asu_lms.lms.Entities.*;
import com.asu_lms.lms.Repositories.*;
import com.asu_lms.lms.Services.EAVService;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.*;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/student")
@CrossOrigin(origins = "*")
public class StudentController {

    private final StudentRepository studentRepository;
    private final SemesterRepository semesterRepository;
    private final OfferedCourseRepository offeredCourseRepository;
    private final CourseRepository courseRepository;
    private final DepartmentCourseRepository departmentCourseRepository;
    private final SectionRepository sectionRepository;
    private final EnrollmentRepository enrollmentRepository;
    private final DepartmentRepository departmentRepository;
    private final EAVService eavService;

    public StudentController(
            StudentRepository studentRepository,
            SemesterRepository semesterRepository,
            OfferedCourseRepository offeredCourseRepository,
            CourseRepository courseRepository,
            DepartmentCourseRepository departmentCourseRepository,
            SectionRepository sectionRepository,
            EnrollmentRepository enrollmentRepository,
            DepartmentRepository departmentRepository,
            EAVService eavService
    ) {
        this.studentRepository = studentRepository;
        this.semesterRepository = semesterRepository;
        this.offeredCourseRepository = offeredCourseRepository;
        this.courseRepository = courseRepository;
        this.departmentCourseRepository = departmentCourseRepository;
        this.sectionRepository = sectionRepository;
        this.enrollmentRepository = enrollmentRepository;
        this.departmentRepository = departmentRepository;
        this.eavService = eavService;
    }

    @GetMapping("/{studentId}/registration")
    public Map<String, Object> getRegistrationData(@PathVariable Integer studentId) {
        Map<String, Object> response = new HashMap<>();

        try {
            Optional<Student> studentOpt = studentRepository.findByStudentId(studentId);
            if (studentOpt.isEmpty()) {
                response.put("status", "error");
                response.put("message", "Student not found");
                return response;
            }

            Student student = studentOpt.get();
            if (student.getDepartmentId() == null) {
                response.put("status", "error");
                response.put("message", "Student is not linked to a department");
                return response;
            }

            Map<String, Object> data = new HashMap<>();
            LocalDate today = LocalDate.now();
            Semester currentSemester = findCurrentSemester(today);

            if (currentSemester == null) {
                data.put("currentSemester", null);
                data.put("registrationOpen", false);
                data.put("courses", Collections.emptyList());
                data.put("registeredSectionIds", Collections.emptyList());
                response.put("status", "success");
                response.put("message", "No active semester at this time.");
                response.put("data", data);
                return response;
            }

            Map<String, Object> semesterInfo = new HashMap<>();
            semesterInfo.put("semesterId", currentSemester.getSemesterId());
            semesterInfo.put("name", currentSemester.getName());
            semesterInfo.put("startDate", currentSemester.getStartDate() != null ? currentSemester.getStartDate().toString() : null);
            semesterInfo.put("endDate", currentSemester.getEndDate() != null ? currentSemester.getEndDate().toString() : null);
            semesterInfo.put("registrationOpen", currentSemester.getRegistrationOpen());
            data.put("currentSemester", semesterInfo);

            boolean registrationOpen = Boolean.TRUE.equals(currentSemester.getRegistrationOpen());
            data.put("registrationOpen", registrationOpen);

            Integer asuDepartmentId = getAsuDepartmentId();
            List<DepartmentCourse> departmentCourses = departmentCourseRepository.findByDepartmentId(student.getDepartmentId());
            Set<Integer> allowedCourseIds = departmentCourses.stream()
                    .map(DepartmentCourse::getCourseId)
                    .collect(Collectors.toSet());

            List<DepartmentCourse> asuDepartmentCourses = asuDepartmentId != null
                    ? departmentCourseRepository.findByDepartmentId(asuDepartmentId)
                    : Collections.emptyList();
            Set<Integer> asuCourseIds = asuDepartmentCourses.stream()
                    .map(DepartmentCourse::getCourseId)
                    .collect(Collectors.toSet());

            Map<Integer, DepartmentCourse> departmentCourseByCourseId =
                    java.util.stream.Stream.concat(departmentCourses.stream(), asuDepartmentCourses.stream())
                            .collect(Collectors.toMap(DepartmentCourse::getCourseId, dc -> dc, (a, b) -> a));

            List<OfferedCourse> offeredCourses = offeredCourseRepository.findBySemesterId(currentSemester.getSemesterId());
            List<Enrollment> enrollments = enrollmentRepository.findByStudentId(studentId);
            List<Map<String, Object>> registeredCourses = new ArrayList<>();
            Set<Integer> registeredSectionIds = new HashSet<>();
            Map<Integer, Enrollment> enrollmentBySectionId = new HashMap<>();
            for (Enrollment enrollment : enrollments) {
                // Include approved, pending, and drop_pending enrollments
                String status = eavService.getEnrollmentStatus(enrollment.getEnrollmentId());
                if (!"approved".equals(status) && !"pending".equals(status) && !"drop_pending".equals(status)) {
                    continue;
                }
                
                Optional<Section> sectionOpt = sectionRepository.findBySectionId(enrollment.getSectionId());
                if (sectionOpt.isEmpty()) continue;
                Section section = sectionOpt.get();
                Optional<OfferedCourse> offeredCourseOpt = offeredCourseRepository.findByOfferedCourseId(section.getOfferedCourseId());
                if (offeredCourseOpt.isEmpty()) continue;
                OfferedCourse oc = offeredCourseOpt.get();
                if (!oc.getSemesterId().equals(currentSemester.getSemesterId())) continue;
                registeredSectionIds.add(section.getSectionId());
                enrollmentBySectionId.put(section.getSectionId(), enrollment);

                Optional<Course> courseOpt = courseRepository.findById(oc.getCourseId());
                if (courseOpt.isEmpty()) continue;
                Course course = courseOpt.get();
                boolean isAsuCourse = asuCourseIds.contains(course.getCourseId());

                Map<String, Object> courseData = new HashMap<>();
                courseData.put("enrollmentId", enrollment.getEnrollmentId());
                courseData.put("courseId", course.getCourseId());
                courseData.put("courseCode", course.getCourseCode());
                courseData.put("courseTitle", course.getTitle());
                courseData.put("credits", course.getCredits());
                courseData.put("sectionId", section.getSectionId());
                courseData.put("sectionNumber", section.getSectionNumber());
                courseData.put("category", isAsuCourse ? "asu" : "department");
                courseData.put("enrollmentStatus", status); // Include status: "approved", "pending", or "drop_pending"

                DepartmentCourse departmentCourse = departmentCourseByCourseId.get(course.getCourseId());
                if (departmentCourse != null) {
                    courseData.put("courseType", departmentCourse.getCourseType());
                    courseData.put("eligibilityRequirements", departmentCourse.getEligibilityRequirements());
                }
                registeredCourses.add(courseData);
            }

            data.put("registeredSectionIds", new ArrayList<>(registeredSectionIds));
            data.put("registeredCourses", registeredCourses);

            List<Map<String, Object>> asuCourses = new ArrayList<>();
            List<Map<String, Object>> departmentCourseList = new ArrayList<>();
            List<Map<String, Object>> availableCourses = new ArrayList<>();

            for (OfferedCourse offeredCourse : offeredCourses) {
                boolean isAsuCourse = asuCourseIds.contains(offeredCourse.getCourseId());

                if (!isAsuCourse && !allowedCourseIds.contains(offeredCourse.getCourseId())) {
                    continue;
                }

                Optional<Course> courseOpt = courseRepository.findById(offeredCourse.getCourseId());
                if (courseOpt.isEmpty()) {
                    continue;
                }

                Course course = courseOpt.get();
                Map<String, Object> courseData = new HashMap<>();
                courseData.put("offeredCourseId", offeredCourse.getOfferedCourseId());
                courseData.put("courseId", course.getCourseId());
                courseData.put("courseCode", course.getCourseCode());
                courseData.put("courseTitle", course.getTitle());
                courseData.put("credits", course.getCredits());
                courseData.put("semesterId", currentSemester.getSemesterId());
                courseData.put("category", isAsuCourse ? "asu" : "department");

                DepartmentCourse departmentCourse = departmentCourseByCourseId.get(course.getCourseId());
                if (departmentCourse != null) {
                    courseData.put("courseType", departmentCourse.getCourseType());
                    courseData.put("eligibilityRequirements", departmentCourse.getEligibilityRequirements());
                }

                List<Section> sections = sectionRepository.findByOfferedCourseId(offeredCourse.getOfferedCourseId());
                if (sections.isEmpty()) {
                    sections = Collections.singletonList(createDefaultSection(offeredCourse));
                }
                List<Map<String, Object>> sectionList = new ArrayList<>();
                boolean alreadyRegisteredForCourse = false;

                for (Section section : sections) {
                    Map<String, Object> sectionData = new HashMap<>();
                    sectionData.put("sectionId", section.getSectionId());
                    sectionData.put("sectionNumber", section.getSectionNumber());
                    sectionData.put("capacity", section.getCapacity());

                    int currentEnrollment = section.getCurrentEnrollment() != null ? section.getCurrentEnrollment() : 0;
                    sectionData.put("currentEnrollment", currentEnrollment);

                    boolean isFull = section.getCapacity() != null
                            && currentEnrollment >= section.getCapacity();
                    sectionData.put("isFull", isFull);

                    boolean studentEnrolled = registeredSectionIds.contains(section.getSectionId());
                    sectionData.put("studentEnrolled", studentEnrolled);
                    if (studentEnrolled) {
                        alreadyRegisteredForCourse = true;
                    }

                    sectionList.add(sectionData);
                }

                // Skip courses that do not have any sections available
                if (sectionList.isEmpty()) {
                    continue;
                }

                courseData.put("sections", sectionList);
                courseData.put("alreadyRegistered", alreadyRegisteredForCourse);

                if (isAsuCourse) {
                    asuCourses.add(courseData);
                } else {
                    departmentCourseList.add(courseData);
                }
                availableCourses.add(courseData);
            }

            data.put("asuCourses", asuCourses);
            data.put("departmentCourses", departmentCourseList);
            data.put("courses", availableCourses);
            response.put("status", "success");
            response.put("message", registrationOpen
                    ? "Registration is open for the current semester."
                    : "Registration is currently closed. You can still view available courses.");
            response.put("data", data);

        } catch (Exception e) {
            response.put("status", "error");
            response.put("message", "Error loading registration data: " + e.getMessage());
        }

        return response;
    }

    @PostMapping("/register")
    @Transactional
    public Map<String, Object> registerForCourse(@RequestBody Map<String, Object> request) {
        Map<String, Object> response = new HashMap<>();

        try {
            Integer studentId = parseInteger(request.get("studentId"));
            Integer sectionId = parseInteger(request.get("sectionId"));

            if (studentId == null || sectionId == null) {
                response.put("status", "error");
                response.put("message", "Invalid student or section information.");
                return response;
            }

            Optional<Student> studentOpt = studentRepository.findByStudentId(studentId);
            if (studentOpt.isEmpty()) {
                response.put("status", "error");
                response.put("message", "Student not found.");
                return response;
            }

            Student student = studentOpt.get();
            if (student.getDepartmentId() == null) {
                response.put("status", "error");
                response.put("message", "Student is not linked to a department.");
                return response;
            }

            Optional<Section> sectionOpt = sectionRepository.findBySectionId(sectionId);
            if (sectionOpt.isEmpty()) {
                response.put("status", "error");
                response.put("message", "Section not found.");
                return response;
            }

            Section section = sectionOpt.get();
            Optional<OfferedCourse> offeredCourseOpt = offeredCourseRepository.findByOfferedCourseId(section.getOfferedCourseId());
            if (offeredCourseOpt.isEmpty()) {
                response.put("status", "error");
                response.put("message", "Offered course not found.");
                return response;
            }

            OfferedCourse offeredCourse = offeredCourseOpt.get();

            Integer asuDepartmentId = getAsuDepartmentId();
            boolean courseAvailableToDepartment = departmentCourseRepository
                    .existsByDepartmentIdAndCourseId(student.getDepartmentId(), offeredCourse.getCourseId());
            boolean courseIsAsu = asuDepartmentId != null && departmentCourseRepository
                    .existsByDepartmentIdAndCourseId(asuDepartmentId, offeredCourse.getCourseId());

            if (!courseAvailableToDepartment && !courseIsAsu) {
                response.put("status", "error");
                response.put("message", "You are not eligible to register for this course.");
                return response;
            }

            Optional<Semester> semesterOpt = semesterRepository.findById(offeredCourse.getSemesterId());
            if (semesterOpt.isEmpty()) {
                response.put("status", "error");
                response.put("message", "Semester not found for this course.");
                return response;
            }

            Semester semester = semesterOpt.get();
            LocalDate today = LocalDate.now();
            if (!isWithinSemester(semester, today)) {
                response.put("status", "error");
                response.put("message", "Registration is only allowed during an active semester.");
                return response;
            }

            if (!Boolean.TRUE.equals(semester.getRegistrationOpen())) {
                response.put("status", "error");
                response.put("message", "Registration window is closed for this semester.");
                return response;
            }

            List<Enrollment> studentEnrollments = enrollmentRepository.findByStudentId(studentId);
            // Check for any enrollment (approved, pending, or drop_pending) in this section
            boolean alreadyInSection = studentEnrollments.stream()
                    .anyMatch(enrollment -> Objects.equals(enrollment.getSectionId(), sectionId) 
                        && ("approved".equals(eavService.getEnrollmentStatus(enrollment.getEnrollmentId())) || "pending".equals(eavService.getEnrollmentStatus(enrollment.getEnrollmentId()))));
            if (alreadyInSection) {
                response.put("status", "error");
                response.put("message", "You are already registered or have a pending registration in this section.");
                return response;
            }

            // Check if already registered in another section of the same course
            if (!studentEnrollments.isEmpty()) {
                List<Integer> sectionIds = studentEnrollments.stream()
                        .filter(e -> "approved".equals(eavService.getEnrollmentStatus(e.getEnrollmentId())) || "pending".equals(eavService.getEnrollmentStatus(e.getEnrollmentId())))
                        .map(Enrollment::getSectionId)
                        .collect(Collectors.toList());
                if (!sectionIds.isEmpty()) {
                    List<Section> registeredSections = sectionRepository.findAllById(sectionIds);
                    boolean alreadyInCourse = registeredSections.stream()
                            .anyMatch(s -> Objects.equals(s.getOfferedCourseId(), offeredCourse.getOfferedCourseId()));
                    if (alreadyInCourse) {
                        response.put("status", "error");
                        response.put("message", "You are already registered or have a pending registration in another section of this course.");
                        return response;
                    }
                }
            }

            int currentEnrollment = section.getCurrentEnrollment() != null ? section.getCurrentEnrollment() : 0;
            if (section.getCapacity() != null && currentEnrollment >= section.getCapacity()) {
                response.put("status", "error");
                response.put("message", "This section is already full.");
                return response;
            }

            // Check if there's already a pending enrollment for this section
            List<Enrollment> allEnrollments = enrollmentRepository.findByStudentId(studentId);
            boolean alreadyPending = allEnrollments.stream()
                    .filter(e -> "pending".equals(eavService.getEnrollmentStatus(e.getEnrollmentId())))
                    .anyMatch(e -> Objects.equals(e.getSectionId(), sectionId));
            if (alreadyPending) {
                response.put("status", "error");
                response.put("message", "You already have a pending registration request for this section.");
                return response;
            }

            // Create enrollment with "pending" status - do NOT increment section enrollment yet
            Enrollment enrollment = new Enrollment(studentId, sectionId);
            enrollmentRepository.save(enrollment);
            // Set status via EAV
            eavService.setEnrollmentAttribute(enrollment, "status", "pending");

            Map<String, Object> data = new HashMap<>();
            data.put("enrollmentId", enrollment.getEnrollmentId());
            data.put("sectionId", sectionId);
            data.put("offeredCourseId", offeredCourse.getOfferedCourseId());

            response.put("status", "success");
            response.put("message", "Course registration completed successfully.");
            response.put("data", data);

        } catch (Exception e) {
            response.put("status", "error");
            response.put("message", "Error registering for course: " + e.getMessage());
        }

        return response;
    }

    @PostMapping("/drop")
    @Transactional
    public Map<String, Object> dropCourse(@RequestBody Map<String, Object> request) {
        Map<String, Object> response = new HashMap<>();

        try {
            System.out.println("=== DROP REQUEST DEBUG ===");
            System.out.println("Request body: " + request);
            
            Integer studentId = parseInteger(request.get("studentId"));
            Integer enrollmentId = parseInteger(request.get("enrollmentId"));
            
            System.out.println("Parsed studentId: " + studentId);
            System.out.println("Parsed enrollmentId: " + enrollmentId);

            if (studentId == null || enrollmentId == null) {
                System.out.println("ERROR: Invalid student or enrollment information");
                response.put("status", "error");
                response.put("message", "Invalid student or enrollment information.");
                return response;
            }

            Optional<Student> studentOpt = studentRepository.findByStudentId(studentId);
            if (studentOpt.isEmpty()) {
                System.out.println("ERROR: Student not found with ID: " + studentId);
                response.put("status", "error");
                response.put("message", "Student not found.");
                return response;
            }
            System.out.println("Student found: " + studentOpt.get().getStudentId());

            Optional<Enrollment> enrollmentOpt = enrollmentRepository.findById(enrollmentId);
            if (enrollmentOpt.isEmpty()) {
                System.out.println("ERROR: Enrollment not found with ID: " + enrollmentId);
                response.put("status", "error");
                response.put("message", "Enrollment not found.");
                return response;
            }

            Enrollment enrollment = enrollmentOpt.get();
            String enrollmentStatus = eavService.getEnrollmentStatus(enrollment.getEnrollmentId());
            System.out.println("Enrollment found - StudentId: " + enrollment.getStudentId() + ", SectionId: " + enrollment.getSectionId() + ", Status: " + enrollmentStatus);
            
            if (!enrollment.getStudentId().equals(studentId)) {
                System.out.println("ERROR: Enrollment studentId (" + enrollment.getStudentId() + ") does not match request studentId (" + studentId + ")");
                response.put("status", "error");
                response.put("message", "Enrollment does not belong to this student.");
                return response;
            }

            Optional<Section> sectionOpt = sectionRepository.findBySectionId(enrollment.getSectionId());
            if (sectionOpt.isEmpty()) {
                System.out.println("ERROR: Section not found with ID: " + enrollment.getSectionId());
                response.put("status", "error");
                response.put("message", "Section not found.");
                return response;
            }
            System.out.println("Section found: " + sectionOpt.get().getSectionId());

            Section section = sectionOpt.get();
            Optional<OfferedCourse> offeredCourseOpt = offeredCourseRepository.findByOfferedCourseId(section.getOfferedCourseId());
            if (offeredCourseOpt.isEmpty()) {
                System.out.println("ERROR: OfferedCourse not found with ID: " + section.getOfferedCourseId());
                response.put("status", "error");
                response.put("message", "Offered course not found.");
                return response;
            }
            System.out.println("OfferedCourse found: " + offeredCourseOpt.get().getOfferedCourseId());

            OfferedCourse offeredCourse = offeredCourseOpt.get();
            Optional<Semester> semesterOpt = semesterRepository.findById(offeredCourse.getSemesterId());
            if (semesterOpt.isEmpty()) {
                System.out.println("ERROR: Semester not found with ID: " + offeredCourse.getSemesterId());
                response.put("status", "error");
                response.put("message", "Semester not found.");
                return response;
            }
            System.out.println("Semester found: " + semesterOpt.get().getSemesterId());

            Semester semester = semesterOpt.get();
            LocalDate today = LocalDate.now();
            System.out.println("Today's date: " + today);
            System.out.println("Semester start: " + semester.getStartDate());
            System.out.println("Semester end: " + semester.getEndDate());
            System.out.println("Registration open: " + semester.getRegistrationOpen());
            
            if (!isWithinSemester(semester, today)) {
                System.out.println("ERROR: Not within semester period");
                response.put("status", "error");
                response.put("message", "Dropping courses is only allowed during the active semester period.");
                return response;
            }

            if (!Boolean.TRUE.equals(semester.getRegistrationOpen())) {
                System.out.println("ERROR: Registration window is closed");
                response.put("status", "error");
                response.put("message", "Registration window is closed; you cannot drop courses now.");
                return response;
            }

            String currentStatus = eavService.getEnrollmentStatus(enrollment.getEnrollmentId());
            System.out.println("Current enrollment status: " + currentStatus);
            
            // Check if there's already a pending drop request
            if ("drop_pending".equals(currentStatus)) {
                System.out.println("ERROR: Already has pending drop request");
                response.put("status", "error");
                response.put("message", "You already have a pending drop request for this course.");
                return response;
            }

            // Only allow dropping approved enrollments (not pending registrations)
            if (!"approved".equals(currentStatus)) {
                System.out.println("ERROR: Enrollment status is not approved. Current status: " + currentStatus);
                response.put("status", "error");
                if ("pending".equals(currentStatus)) {
                    response.put("message", "You cannot drop a course that is still pending registration approval. Please wait for your advisor to approve the registration first.");
                } else {
                    response.put("message", "You can only drop approved enrollments.");
                }
                return response;
            }

            // Set status to "drop_pending" - do NOT delete or decrement section enrollment yet
            System.out.println("Setting enrollment status to drop_pending...");
            eavService.setEnrollmentAttribute(enrollment, "status", "drop_pending");
            enrollmentRepository.save(enrollment);
            System.out.println("Enrollment saved successfully");

            response.put("status", "success");
            response.put("message", "Drop request submitted. Waiting for advisor approval.");
            System.out.println("=== DROP REQUEST SUCCESS ===");

        } catch (Exception e) {
            System.out.println("=== DROP REQUEST EXCEPTION ===");
            System.out.println("Exception type: " + e.getClass().getName());
            System.out.println("Exception message: " + e.getMessage());
            e.printStackTrace();
            response.put("status", "error");
            response.put("message", "Error dropping course: " + e.getMessage());
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

    private Integer getAsuDepartmentId() {
        return departmentRepository.findByName("ASU Courses")
                .map(Department::getDepartmentId)
                .orElse(6);
    }

    private Section createDefaultSection(OfferedCourse offeredCourse) {
        Section section = new Section();
        section.setOfferedCourseId(offeredCourse.getOfferedCourseId());
        section.setSectionNumber("A");
        section.setCapacity(40);
        section.setCurrentEnrollment(0);
        return sectionRepository.save(section);
    }
}

