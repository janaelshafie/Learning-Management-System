package com.asu_lms.lms.Repositories;

import com.asu_lms.lms.Entities.Student;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.Optional;

public interface StudentRepository extends JpaRepository<Student, Integer> {
    Optional<Student> findByStudentMail(String studentMail);
}
