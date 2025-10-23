package com.asu_lms.lms.Repositories;

import com.asu_lms.lms.Entities.Admin;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.Optional;

public interface AdminRepository extends JpaRepository<Admin, Integer> {
    Optional<Admin> findByAdminMail(String adminMail);
}
