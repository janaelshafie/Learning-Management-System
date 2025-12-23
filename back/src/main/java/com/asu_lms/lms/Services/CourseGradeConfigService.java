package com.asu_lms.lms.Services;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Optional;
import java.util.stream.Collectors;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.asu_lms.lms.Entities.GradeAttributes;
import com.asu_lms.lms.Entities.OfferedCourse;
import com.asu_lms.lms.Repositories.GradeAttributesRepository;
import com.asu_lms.lms.Repositories.OfferedCourseRepository;
import com.fasterxml.jackson.databind.ObjectMapper;

@Service
public class CourseGradeConfigService {

    @Autowired
    private OfferedCourseRepository offeredCourseRepository;

    @Autowired
    private GradeAttributesRepository gradeAttributesRepository;

    private final ObjectMapper objectMapper = new ObjectMapper();
    
    // Simple in-memory cache for grade component configurations
    // In production, you might want to use Redis or store in database
    // For now, we'll use a simple Map
    private static final Map<Integer, Map<String, Double>> configCache = new HashMap<>();

    /**
     * Get all available grade components from GradeAttributes table
     */
    public List<Map<String, Object>> getAvailableGradeComponents() {
        List<GradeAttributes> allAttributes = gradeAttributesRepository.findAll();
        return allAttributes.stream().map(attr -> {
            Map<String, Object> component = new HashMap<>();
            component.put("name", attr.getAttributeName());
            component.put("maxValue", attr.getMaxValue() != null ? attr.getMaxValue().doubleValue() : null);
            component.put("description", attr.getDescription());
            component.put("valueType", attr.getValueType());
            // No components are fixed - all are customizable
            component.put("fixed", false);
            return component;
        }).collect(Collectors.toList());
    }

    /**
     * Configure grade components for an offered course
     * @param offeredCourseId The offered course ID
     * @param components Map of component names to their max values (null means disabled)
     * @return Response map
     */
    @Transactional
    public Map<String, Object> configureGradeComponents(Integer offeredCourseId, Map<String, Double> components) {
        Map<String, Object> response = new HashMap<>();

        try {
            Optional<OfferedCourse> offeredCourseOpt = offeredCourseRepository.findById(offeredCourseId);
            if (offeredCourseOpt.isEmpty()) {
                response.put("status", "error");
                response.put("message", "Offered course not found");
                return response;
            }

            // No fixed restrictions - instructor can set any value for any component

            // Validate total doesn't exceed 100
            double total = components.values().stream()
                .filter(Objects::nonNull)
                .mapToDouble(Double::doubleValue)
                .sum();

            if (total > 100.0) {
                response.put("status", "error");
                response.put("message", String.format("Total marks (%.2f) exceeds 100. Please adjust the components.", total));
                return response;
            }

            // Store configuration in cache (in production, store in database)
            configCache.put(offeredCourseId, new HashMap<>(components));

            response.put("status", "success");
            response.put("message", "Grade components configured successfully");
            response.put("components", components);
            response.put("total", total);

        } catch (Exception e) {
            response.put("status", "error");
            response.put("message", "Error configuring grade components: " + e.getMessage());
        }

        return response;
    }

    /**
     * Get grade component configuration for an offered course
     */
    public Map<String, Object> getGradeComponentConfig(Integer offeredCourseId) {
        Map<String, Object> response = new HashMap<>();

        try {
            Optional<OfferedCourse> offeredCourseOpt = offeredCourseRepository.findById(offeredCourseId);
            if (offeredCourseOpt.isEmpty()) {
                response.put("status", "error");
                response.put("message", "Offered course not found");
                return response;
            }

            // Get configuration from cache (or default)
            Map<String, Double> components = configCache.getOrDefault(offeredCourseId, getDefaultConfiguration());

            // Get all available components from database
            List<Map<String, Object>> availableComponents = getAvailableGradeComponents();

            response.put("status", "success");
            response.put("components", components);
            response.put("availableComponents", availableComponents);

        } catch (Exception e) {
            response.put("status", "error");
            response.put("message", "Error getting grade component configuration: " + e.getMessage());
        }

        return response;
    }

    /**
     * Get default grade component configuration
     */
    private Map<String, Double> getDefaultConfiguration() {
        Map<String, Double> defaultConfig = new HashMap<>();
        // Get defaults from GradeAttributes table
        List<GradeAttributes> allAttributes = gradeAttributesRepository.findAll();
        for (GradeAttributes attr : allAttributes) {
            if (attr.getMaxValue() != null) {
                defaultConfig.put(attr.getAttributeName(), attr.getMaxValue().doubleValue());
            }
        }
        return defaultConfig;
    }

    /**
     * Calculate final letter grade based on total marks
     */
    public String calculateFinalLetterGrade(double totalMarks) {
        if (totalMarks >= 93) return "A+";
        if (totalMarks >= 90) return "A";
        if (totalMarks >= 87) return "A-";
        if (totalMarks >= 83) return "B+";
        if (totalMarks >= 80) return "B";
        if (totalMarks >= 77) return "B-";
        if (totalMarks >= 73) return "C+";
        if (totalMarks >= 70) return "C";
        if (totalMarks >= 67) return "C-";
        if (totalMarks >= 63) return "D+";
        if (totalMarks >= 60) return "D";
        return "F";
    }
}
