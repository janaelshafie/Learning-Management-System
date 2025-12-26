package com.asu_lms.lms.Services;

import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.asu_lms.lms.Entities.User;
import com.asu_lms.lms.Repositories.UserRepository;

@Service
public class AuthService {

    @Autowired
    private UserRepository userRepository;
    
    @Autowired
    private PasswordService passwordService;

    public String login(String email, String password) {
        // Trim the email to handle any whitespace
        email = email != null ? email.trim() : "";
        password = password != null ? password.trim() : "";
        
        // Try to find user by email or official mail
        Optional<User> userOpt = userRepository.findByEmail(email);
        if (userOpt.isEmpty()) {
            userOpt = userRepository.findByOfficialMail(email);
        }

        if (userOpt.isPresent()) {
            User user = userOpt.get();
            // Check password using BCrypt verification
            if (passwordService.verifyPassword(password, user.getPasswordHash())) {
                // Check account status using switch with a default case (no behavioral change)
                String status = user.getAccountStatus();
                switch (status) {
                    case "active":
                        return user.getRole();
                    case "pending":
                        return "pending";
                    case "rejected":
                        return "rejected";
                    default:
                        // Default added for clarity - same effect as falling through to return "invalid" below.
                        return "invalid";
                }
            }
        }

        return "invalid";
    }

    public String signup(String name, String nationalId, String email, String officialMail, 
                        String phone, String location, String password, String role, String studentNationalId) {
        try {
            // Check if email already exists
            if (userRepository.existsByEmail(email)) {
                return "Email already exists";
            }
            
            // Check if official mail already exists (only if provided and not empty)
            if (officialMail != null && !officialMail.trim().isEmpty()) {
                if (userRepository.existsByOfficialMail(officialMail)) {
                    return "Official email already exists";
                }
            }
            
            // Check if national ID already exists
            if (userRepository.existsByNationalId(nationalId)) {
                return "National ID already exists";
            }

            // Hash the password before storing
            String hashedPassword = passwordService.hashPassword(password);
            
            // For parents, validate student national ID exists
            if ("parent".equals(role) && studentNationalId != null && !studentNationalId.trim().isEmpty()) {
                Optional<User> studentOpt = userRepository.findByNationalId(studentNationalId);
                if (studentOpt.isEmpty()) {
                    // Student with this national ID doesn't exist
                    return "Student with national ID " + studentNationalId + " not found. Please verify the student's national ID and try again.";
                }
                if (!"student".equals(studentOpt.get().getRole())) {
                    // User exists but is not a student
                    return "User with national ID " + studentNationalId + " is not a student. Please enter a valid student national ID.";
                }
            }

            // Create new user with pending status (requires admin approval)
            User newUser = new User(nationalId, name, email, 
                (officialMail != null && !officialMail.trim().isEmpty()) ? officialMail : email, 
                phone, location, hashedPassword, role);
            newUser.setAccountStatus("pending"); // All accounts need admin approval
            userRepository.save(newUser);
            
            return "success";
        } catch (Exception e) {
            return "Error creating account: " + e.getMessage();
        }
    }
}
