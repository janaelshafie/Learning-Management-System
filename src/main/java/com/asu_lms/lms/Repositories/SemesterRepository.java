package com.asu_lms.lms.Repositories;

import com.asu_lms.lms.Entities.Semester;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;
import java.util.Optional;

@Repository
public interface SemesterRepository extends JpaRepository<Semester, Integer> {
    Optional<Semester> findByName(String name);
    List<Semester> findAllByOrderByStartDateDesc();
}



