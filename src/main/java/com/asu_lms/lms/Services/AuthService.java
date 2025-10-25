package com.asu_lms.lms.Services;

import com.asu_lms.lms.Entities.User;
import com.asu_lms.lms.Repositories.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.Optional;

@Service
public class AuthService {

    @Autowired
    private UserRepository userRepository;

    public String login(String email, String password) {
        // Try to find user by email or official mail
        Optional<User> userOpt = userRepository.findByEmail(email);
        if (userOpt.isEmpty()) {
            userOpt = userRepository.findByOfficialMail(email);
        }

        if (userOpt.isPresent()) {
            User user = userOpt.get();
            // Check password
            if (user.getPasswordHash().equals(password)) {
                // Check account status
                if ("active".equals(user.getAccountStatus())) {
                    return user.getRole();
                } else if ("pending".equals(user.getAccountStatus())) {
                    return "pending";
                } else if ("rejected".equals(user.getAccountStatus())) {
                    return "rejected";
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

            // For parents, validate student national ID exists
            if ("parent".equals(role) && studentNationalId != null && !studentNationalId.trim().isEmpty()) {
                Optional<User> studentOpt = userRepository.findByNationalId(studentNationalId);
                if (studentOpt.isEmpty() || !"student".equals(studentOpt.get().getRole())) {
                    // Student doesn't exist, create parent with rejected status
                    User newUser = new User(nationalId, name, email, 
                        (officialMail != null && !officialMail.trim().isEmpty()) ? officialMail : email, 
                        phone, location, password, role);
                    newUser.setAccountStatus("rejected"); // Rejected because student doesn't exist
                    userRepository.save(newUser);
                    return "success"; // Still return success but with rejected status
                }
            }

            // Create new user with pending status (requires admin approval)
            User newUser = new User(nationalId, name, email, 
                (officialMail != null && !officialMail.trim().isEmpty()) ? officialMail : email, 
                phone, location, password, role);
            newUser.setAccountStatus("pending"); // All accounts need admin approval
            userRepository.save(newUser);
            
            return "success";
        } catch (Exception e) {
            return "Error creating account: " + e.getMessage();
        }
    }
}