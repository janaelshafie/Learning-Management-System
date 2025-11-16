package com.asu_lms.lms.Repositories;

import com.asu_lms.lms.Entities.PendingProfileChange;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface PendingProfileChangeRepository extends JpaRepository<PendingProfileChange, Integer> {
    List<PendingProfileChange> findByUserId(Integer userId);
    List<PendingProfileChange> findByChangeStatus(PendingProfileChange.ChangeStatus status);
    List<PendingProfileChange> findByUserIdAndChangeStatus(Integer userId, PendingProfileChange.ChangeStatus status);
}



