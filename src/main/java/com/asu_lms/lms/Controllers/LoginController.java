package com.asu_lms.lms.Controllers;


import com.asu_lms.lms.Services.AuthService;
import com.asu_lms.lms.Repositories.UserRepository;
import com.asu_lms.lms.Entities.User;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;
import java.util.Optional;


@RestController
@RequestMapping("/api/auth")
@CrossOrigin(origins = "*")
public class LoginController {

    @Autowired
    private AuthService authService;

    @Autowired
    private UserRepository userRepository;

    @PostMapping("/login")
    public Map<String , String> login(@RequestBody Map<String , String> request) {
        String email = request.get("email");
        String password = request.get("password");
        String result = authService.login(email, password);

        Map<String, String> response = new HashMap<>();
        
        if (result.equals("pending")) {
            response.put("status", "error");
            response.put("message", "Your account is pending admin approval. Please wait for approval.");
        } else if (result.equals("rejected")) {
            response.put("status", "error");
            response.put("message", "Your account has been rejected. Please contact administration.");
        } else if (!result.equals("invalid")) {
            response.put("status", "success");
            response.put("role", result);
        } else {
            response.put("status", "error");
            response.put("message", "Invalid email or password");
        }
        
        return response;
    }

    @PostMapping("/signup")
    public Map<String, String> signup(@RequestBody Map<String, String> request) {
        String name = request.get("name");
        String nationalId = request.get("nationalId");
        String email = request.get("email");
        String officialMail = request.get("officialMail");
        String phone = request.get("phone");
        String location = request.get("location");
        String password = request.get("password");
        String role = request.get("role");
        String studentNationalId = request.get("studentNationalId");

        Map<String, String> response = new HashMap<>();
        
        // Check if students are trying to signup (not allowed)
        if ("student".equals(role)) {
            response.put("status", "error");
            response.put("message", "Students cannot create accounts. Please contact administration.");
            return response;
        }

        String result = authService.signup(name, nationalId, email, officialMail, phone, location, password, role, studentNationalId);
        
        if (result.equals("success")) {
            response.put("status", "success");
            response.put("message", "Account created successfully");
        } else {
            response.put("status", "error");
            response.put("message", result);
        }
        
        return response;
    }

    @PostMapping("/get-user-by-email")
    public Map<String, Object> getUserByEmail(@RequestBody Map<String, String> request) {
        String email = request.get("email");
        Map<String, Object> response = new HashMap<>();
        
        if (email == null || email.trim().isEmpty()) {
            response.put("status", "error");
            response.put("message", "Email is required");
            return response;
        }
        
        try {
            Optional<User> userOpt = userRepository.findByEmail(email.trim());
            if (userOpt.isPresent()) {
                User user = userOpt.get();
                Map<String, Object> userData = new HashMap<>();
                userData.put("userId", user.getUserId());
                userData.put("nationalId", user.getNationalId());
                userData.put("name", user.getName());
                userData.put("email", user.getEmail());
                userData.put("officialMail", user.getOfficialMail());
                userData.put("phone", user.getPhone());
                userData.put("location", user.getLocation());
                userData.put("role", user.getRole());
                userData.put("accountStatus", user.getAccountStatus());
                
                response.put("status", "success");
                response.put("data", userData);
            } else {
                response.put("status", "error");
                response.put("message", "User not found");
            }
        } catch (Exception e) {
            response.put("status", "error");
            response.put("message", "Error fetching user data: " + e.getMessage());
        }
        
        return response;
    }

}
