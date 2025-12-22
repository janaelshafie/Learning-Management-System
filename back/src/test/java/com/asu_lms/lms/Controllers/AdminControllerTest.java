package com.asu_lms.lms.Controllers;

import com.asu_lms.lms.Services.AuthService;
import com.asu_lms.lms.Repositories.UserRepository;
import com.asu_lms.lms.Entities.User;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.Mockito;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.http.MediaType;

import java.util.HashMap;
import java.util.Map;
import java.util.Optional;

import static org.hamcrest.Matchers.any;
import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@WebMvcTest(AdminController.class)
class AdminControllerTest {

    @Autowired
    private MockMvc mockMvc;
    @Autowired
    private UserRepository userRepository;

    @Autowired
    private AdminController adminController;

    @Test
    public void TestapproveAccount_Success()  {
        User user = new User();
        user.setUserId(215);
        user.setAccountStatus("pending");
        Map<String, String> request = new HashMap<>();
        request.put("UserId", "215");
        when(userRepository.findById(215)).thenReturn(Optional.of(user));

        Map<String, String> response = adminController.approveAccount(request);
        assertEquals("success", response.get("status"));
        assertEquals("Account approved successfully", response.get("message"));
        assertEquals("active", user.getAccountStatus());

    }

    @Test
    public void TestapproveAccount_Failure()  {
        User user = new User();
        user.setUserId(2);
        user.setAccountStatus("active"); // Not "pending"
        Map<String, String> request = new HashMap<>();
        request.put("userId", "2");

        when(userRepository.findById(2)).thenReturn(Optional.of(user));

        Map<String, String> response = adminController.approveAccount(request);

        assertEquals("error", response.get("status"));
        assertEquals("Account is not in pending status", response.get("message"));

    }

    @Test
    public void testApproveAccount_UserNotFound() {
        Map<String, String> request = new HashMap<>();
        request.put("userId", "3");

        when(userRepository.findById(3)).thenReturn(Optional.empty());

        Map<String, String> response = adminController.approveAccount(request);

        assertEquals("error", response.get("status"));
        assertEquals("User not found", response.get("message"));
    }

    @Test
    public void testApproveAccount_Exception() {
        Map<String, String> request = new HashMap<>();
        request.put("userId", "notANumber");

        Map<String, String> response = adminController.approveAccount(request);

        assertEquals("error", response.get("status"));
        assertTrue(response.get("message").startsWith("Error approving account:"));
    }

    @Test
    void testGetPendingAccounts() throws Exception {
        mockMvc.perform(get("/api/admin/pending-accounts"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.status").value("success"));
    }

    @Test
    public void TestRejectedAccountSuccess()  {
        User user = new User();
        user.setUserId(1);
        user.setAccountStatus("pending");
        Map<String, String> request = new HashMap<>();
        request.put("userId", "1");
        when(userRepository.findById(1)).thenReturn(Optional.of(user));
        Map<String, String> response = adminController.rejectAccount(request);
        assertEquals("success", response.get("status"));
        assertEquals("Account rejected successfully", response.get("message"));
        assertEquals("rejected", user.getAccountStatus());
    }
    @Test
    public void TestRejectedAccountFailure()  {
        User user = new User();
        user.setUserId(2);
        user.setAccountStatus("active");
        Map<String, String> request = new HashMap<>();
        request.put("userId", "2");
        when(userRepository.findById(2)).thenReturn(Optional.of(user));
        Map<String, String> response = adminController.rejectAccount(request);
        assertEquals("error", response.get("status"));
        assertEquals("Account is not in pending status", response.get("message"));
    }
    @Test
    public void TestApproveAccount_UserNotFound() {
        Map<String, String> request = new HashMap<>();
        request.put("userId", "5");
        when(userRepository.findById(5)).thenReturn(Optional.empty());
        Map<String, String> response = adminController.approveAccount(request);
        assertEquals("error", response.get("status"));
        assertEquals("User not found", response.get("message"));

    }

    @Test
    public void TestgetAccountStatus() {
        User user = new User();

        String email = "user1@eng.asu.edu.eg";

        user.setOfficialMail("22p0215@eng.asu.edu.eg");
        user.setAccountStatus("active");
        Map<String, String> request = new HashMap<>();
        when(userRepository.findByEmail(email)).thenReturn(Optional.of(user));
        Map<String, String> response = adminController.getAccountStatus(email);
        assertEquals("success", response.get("status"));
        assertEquals("active", response.get("accountStatus"));

    }

    @Test
    public void testGetAccountStatus_UserNotFound() {
        String email = "unknown@eng.asu.edu.eg";

        when(userRepository.findByEmail(email)).thenReturn(Optional.empty());
        when(userRepository.findByOfficialMail(email)).thenReturn(Optional.empty());

        Map<String, String> response = adminController.getAccountStatus(email);

        assertEquals("error", response.get("status"));
        assertEquals("User not found", response.get("message"));
        assertNull(response.get("accountStatus"));
    }

}