package com.asu_lms.lms.Repositories;

import com.asu_lms.lms.Entities.OfficeHours;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface OfficeHoursRepository extends JpaRepository<OfficeHours, Integer> {
    List<OfficeHours> findByInstructorId(Integer instructorId);
    void deleteByInstructorId(Integer instructorId);
}

