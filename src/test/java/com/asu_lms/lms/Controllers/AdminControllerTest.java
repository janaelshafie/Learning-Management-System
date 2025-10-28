package com.asu_lms.lms.Controllers;

import com.asu_lms.lms.Repositories.UserRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.Mockito;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.http.MediaType;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@WebMvcTest(AdminController.class)
class AdminControllerTest {

    @Autowired
    private MockMvc mockMvc;



    @BeforeEach
    void setup() {
        // mock user repository if needed
    }

    @Test
    void testGetPendingAccounts() throws Exception {
        mockMvc.perform(get("/api/admin/pending-accounts"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.status").value("success"));
    }
}