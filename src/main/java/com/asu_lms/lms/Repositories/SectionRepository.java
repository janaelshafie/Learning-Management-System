package com.asu_lms.lms.Repositories;

import com.asu_lms.lms.Entities.Section;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface SectionRepository extends JpaRepository<Section, Integer> {
    List<Section> findByOfferedCourseId(Integer offeredCourseId);
    Optional<Section> findBySectionId(Integer sectionId);
}

