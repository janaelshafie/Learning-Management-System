package com.asu_lms.lms.Controllers;


import com.asu_lms.lms.Services.AuthService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;


@RestController
@RequestMapping("/api/auth")
@CrossOrigin(origins = "*")
public class LoginController {

    @Autowired
    private AuthService authService;

    @PostMapping("/login")
    public Map<String , String> login(@RequestBody Map<String , String> request) {
        String email = request.get("email");
        String password = request.get("password");
        String role = authService.login(email, password);

        Map<String, String> response = new HashMap<>();
        if (!role.equals("invalid")) {
            response.put("status", "success");
            response.put("role", role);
        } else {
            response.put("status", "error");
            response.put("message", "Invalid email or password");
        }
        return response;
    }

}
