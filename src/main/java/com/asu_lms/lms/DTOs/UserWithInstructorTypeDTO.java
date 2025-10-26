package com.asu_lms.lms.DTOs;

import java.util.Map;
import java.util.HashMap;

public class UserWithInstructorTypeDTO {
    private Map<String, Object> userData;
    private String instructorType;
    
    public UserWithInstructorTypeDTO(Map<String, Object> userData, String instructorType) {
        this.userData = new HashMap<>(userData);
        this.instructorType = instructorType;
    }
    
    public Map<String, Object> getUserData() {
        return userData;
    }
    
    public void setUserData(Map<String, Object> userData) {
        this.userData = userData;
    }
    
    public String getInstructorType() {
        return instructorType;
    }
    
    public void setInstructorType(String instructorType) {
        this.instructorType = instructorType;
    }
}

