package com.asu_lms.lms.Repositories;

import com.asu_lms.lms.Entities.CourseMaterial;
import com.asu_lms.lms.Entities.CourseMaterialAttributes;
import com.asu_lms.lms.Entities.CourseMaterialAttributeValues;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface CourseMaterialAttributeValuesRepository extends JpaRepository<CourseMaterialAttributeValues, Integer> {
    List<CourseMaterialAttributeValues> findByMaterial_MaterialId(Integer materialId);
    
    Optional<CourseMaterialAttributeValues> findByMaterial_MaterialIdAndAttribute_AttributeName(
        Integer materialId, String attributeName
    );
    
    @Query("SELECT cmav FROM CourseMaterialAttributeValues cmav WHERE cmav.material = :material AND cmav.attribute = :attribute")
    Optional<CourseMaterialAttributeValues> findByMaterialAndAttribute(
        @Param("material") CourseMaterial material,
        @Param("attribute") CourseMaterialAttributes attribute
    );
    
    void deleteByMaterial_MaterialId(Integer materialId);
}

