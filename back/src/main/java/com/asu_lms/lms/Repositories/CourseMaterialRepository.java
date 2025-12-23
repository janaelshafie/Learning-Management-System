package com.asu_lms.lms.Repositories;

import com.asu_lms.lms.Entities.CourseMaterial;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface CourseMaterialRepository extends JpaRepository<CourseMaterial, Integer> {
    List<CourseMaterial> findByOfferedCourseId(Integer offeredCourseId);
    Optional<CourseMaterial> findByMaterialId(Integer materialId);
    void deleteByMaterialId(Integer materialId);
}

