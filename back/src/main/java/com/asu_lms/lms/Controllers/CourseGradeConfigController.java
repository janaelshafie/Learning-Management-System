package com.asu_lms.lms.Controllers;

import com.asu_lms.lms.Services.CourseGradeConfigService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/course/grade-config")
@CrossOrigin(origins = "*")
public class CourseGradeConfigController {

    @Autowired
    private CourseGradeConfigService gradeConfigService;

    /**
     * Configure grade components for a course
     * POST /api/course/grade-config/{offeredCourseId}
     */
    @PostMapping("/{offeredCourseId}")
    public Map<String, Object> configureGradeComponents(
            @PathVariable Integer offeredCourseId,
            @RequestBody Map<String, Double> components) {
        return gradeConfigService.configureGradeComponents(offeredCourseId, components);
    }

    /**
     * Get grade component configuration for a course
     * GET /api/course/grade-config/{offeredCourseId}
     */
    @GetMapping("/{offeredCourseId}")
    public Map<String, Object> getGradeComponentConfig(@PathVariable Integer offeredCourseId) {
        return gradeConfigService.getGradeComponentConfig(offeredCourseId);
    }
}

