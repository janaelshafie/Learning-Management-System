package com.asu_lms.lms.Repositories;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.asu_lms.lms.Entities.Schedule;

@Repository
public interface ScheduleRepository extends JpaRepository<Schedule, Integer> {
    List<Schedule> findByOfferedCourseId(Integer offeredCourseId);
    List<Schedule> findBySectionId(Integer sectionId);
    List<Schedule> findByRoomId(Integer roomId);
}
