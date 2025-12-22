package com.asu_lms.lms.Repositories;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.asu_lms.lms.Entities.Department;

@Repository
public interface DepartmentRepository extends JpaRepository<Department, Integer> {
    Optional<Department> findByName(String name);
    Optional<Department> findByDepartmentCode(String departmentCode);
    List<Department> findByUnitHeadId(Integer unitHeadId);
    boolean existsByName(String name);
    boolean existsByDepartmentCode(String departmentCode);
}

