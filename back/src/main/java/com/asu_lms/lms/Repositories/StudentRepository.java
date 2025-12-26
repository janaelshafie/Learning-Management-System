package com.asu_lms.lms.Repositories;

import com.asu_lms.lms.Entities.Student;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;
import java.util.List;

@Repository
public interface StudentRepository extends JpaRepository<Student, Integer> {
    Optional<Student> findByStudentId(Integer studentId);
    List<Student> findByParentUserId(Integer parentUserId);
    List<Student> findByAdvisorId(Integer advisorId);
    List<Student> findByDepartmentId(Integer departmentId);
}
