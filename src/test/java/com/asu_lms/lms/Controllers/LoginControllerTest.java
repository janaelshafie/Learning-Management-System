package com.asu_lms.lms.Controllers;

import org.junit.jupiter.api.Assertions;
import org.junit.jupiter.api.Test;
import java.util.HashMap;
import java.util.Map;
import static org.mockito.Mockito.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.test.web.servlet.MockMvc;

import com.fasterxml.jackson.databind.ObjectMapper;


import static org.junit.jupiter.api.Assertions.*;

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



}