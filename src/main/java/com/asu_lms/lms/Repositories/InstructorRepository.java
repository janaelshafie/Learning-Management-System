package com.asu_lms.lms.Repositories;

import com.asu_lms.lms.Entities.Instructor;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.Optional;

public interface InstructorRepository extends JpaRepository<Instructor, Integer> {
    Optional<Instructor> findByInstructorMail(String instructorMail);
}
