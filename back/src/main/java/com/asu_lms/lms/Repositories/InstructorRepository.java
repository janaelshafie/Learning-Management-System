package com.asu_lms.lms.Repositories;

import com.asu_lms.lms.Entities.Instructor;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;
import java.util.Optional;

@Repository
public interface InstructorRepository extends JpaRepository<Instructor, Integer> {
    Optional<Instructor> findByInstructorId(Integer instructorId);
    List<Instructor> findByInstructorType(String instructorType);
}





