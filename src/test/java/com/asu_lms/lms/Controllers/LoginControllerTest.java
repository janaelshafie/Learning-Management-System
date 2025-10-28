package com.asu_lms.lms.Controllers;

import org.junit.jupiter.api.Assertions;
import org.junit.jupiter.api.Test;
import java.util.HashMap;
import java.util.Map;
import static org.mockito.Mockito.*;
import com.asu_lms.lms.Services.AuthService;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.test.web.servlet.MockMvc;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.junit.jupiter.api.extension.ExtendWith;
import com.fasterxml.jackson.databind.ObjectMapper;


import static org.junit.jupiter.api.Assertions.*;

@ExtendWith(MockitoExtension.class)
class LoginControllerTest {

    @Test
    void getAllUsers() {


    }

    @Test

    public void testEmptyEmail_ReturnsErrorMessage() {
        LoginController controller = new LoginController();
        Map<String, String> request = new HashMap<>();
        request.put("email", "");
        request.put("password", "somePassword");
        Map<String, String> response = controller.login(request);
        assertEquals("error", response.get("status"));
        assertEquals("Email is required", response.get("message"));
    }

    @Test
    public void testEmptyPassword_ReturnsErrorMessage() {
        LoginController controller = new LoginController();
        Map<String, String> request = new HashMap<>();
        request.put("email", "user@eng.asu.edu.eg");
        request.put("password", "");
        Map<String, String> response = controller.login(request);
        assertEquals("error", response.get("status"));
        assertEquals("Password is required", response.get("message"));
    }

    @Test
    public void testCorrectEntry(){
        LoginController controller = new LoginController();
        Map<String, String> request = new HashMap<>();
        request.put("email", "22p0215@eng.asu.edu.eg");//correct email
        request.put("password", "Huss2004!!");//correct password
        Map<String, String> response = controller.login(request);
        assertEquals("success", response.get("status"));
        assertEquals("student", response.get("role"));
    }

    @Mock
    private AuthService authService;

    @InjectMocks
    private LoginController signupController; // Or LoginController if the signup method is there

    @Test
    public void testStudentSignup_NotAllowed() {
        Map<String, String> request = new HashMap<>();
        request.put("role", "student");
        Map<String, String> response = signupController.signup(request);
        assertEquals("error", response.get("status"));
        assertEquals("Students cannot create accounts. Please contact administration.", response.get("message"));
    }

    @Test
    public void testSignup_Success() {
        Map<String, String> request = new HashMap<>();
        request.put("role", "instructor");
        request.put("name", "Dr. Ahmed");
        request.put("nationalId", "12345678901234");
        request.put("email", "ahmed@gmail.com");
        request.put("officialMail", "22p0215@prof.asu.edu.eg");
        request.put("phone", "01001234567");
        request.put("location", "Cairo");
        request.put("password", "Test1234!");
        request.put("studentNationalId", "");

        when(authService.signup(anyString(), anyString(), anyString(), anyString(), anyString(), anyString(), anyString(), anyString(), anyString())).thenReturn("success");

        Map<String, String> response = signupController.signup(request);

        assertEquals("success", response.get("status"));
        assertEquals("Account created successfully", response.get("message"));
    }

    @Test
    public void testSignup_ErrorFromService() {
        Map<String, String> request = new HashMap<>();
        request.put("role", "instructor");
        request.put("name", "Dr. Error");
        // ... (fill other fields as needed)

        when(authService.signup(anyString(), anyString(), anyString(), anyString(), anyString(), anyString(), anyString(), anyString(), anyString()))
                .thenReturn("Email already exists");

        Map<String, String> response = signupController.signup(request);

        assertEquals("error", response.get("status"));
        assertEquals("Email already exists", response.get("message"));
    }



}