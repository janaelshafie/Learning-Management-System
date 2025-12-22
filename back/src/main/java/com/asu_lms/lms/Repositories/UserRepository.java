package com.asu_lms.lms.Repositories;

import com.asu_lms.lms.Entities.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface UserRepository extends JpaRepository<User, Integer> {
    Optional<User> findByEmail(String email);
    Optional<User> findByOfficialMail(String officialMail);
    Optional<User> findByNationalId(String nationalId);
    boolean existsByEmail(String email);
    boolean existsByOfficialMail(String officialMail);
    boolean existsByNationalId(String nationalId);
    List<User> findByAccountStatus(String accountStatus);
    List<User> findByRole(String role);
}
