package com.asu_lms.lms.Services;

import com.asu_lms.lms.Entities.Admin;
import com.asu_lms.lms.Entities.Instructor;
import com.asu_lms.lms.Entities.Student;
import com.asu_lms.lms.Repositories.AdminRepository;
import com.asu_lms.lms.Repositories.InstructorRepository;
import com.asu_lms.lms.Repositories.StudentRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.Optional;

@Service
public class AuthService {

    @Autowired
    private StudentRepository studentRepository;

    @Autowired
    private InstructorRepository instructorRepository;

    @Autowired
    private AdminRepository adminRepository;

    public String login(String email, String password) {
        if (email.endsWith("@eng.asu.edu.eg")) {
            Optional<Student> student = studentRepository.findByStudentMail(email);
            if (student.isPresent() && student.get().getStudentPassword().equals(password)) {
                return "student";
            }

        } else if (email.endsWith("@prof.asu.edu.eg")) {
            Optional<Instructor> instructor = instructorRepository.findByInstructorMail(email);
            if (instructor.isPresent() && instructor.get().getInstructorPassword().equals(password)) {
                return "instructor";
            }

        } else if (email.endsWith("@adm.asu.edu.eg")) {
            Optional<Admin> admin = adminRepository.findByAdminMail(email);
            if (admin.isPresent() && admin.get().getAdminPassword().equals(password)) {
                return "admin";
            }
        }

        return "invalid";
    }
}
