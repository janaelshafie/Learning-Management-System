package com.asu_lms.lms.Repositories;

import com.asu_lms.lms.Entities.Prerequisite;
import com.asu_lms.lms.Entities.PrerequisiteId;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface PrerequisiteRepository extends JpaRepository<Prerequisite, PrerequisiteId> {
    List<Prerequisite> findByCourseId(Integer courseId);
    List<Prerequisite> findByPrereqCourseId(Integer prereqCourseId);
    
    @Query("SELECT p FROM Prerequisite p WHERE p.courseId = :courseId OR p.prereqCourseId = :courseId")
    List<Prerequisite> findAllByCourseId(@Param("courseId") Integer courseId);
    
    boolean existsByCourseIdAndPrereqCourseId(Integer courseId, Integer prereqCourseId);
}

