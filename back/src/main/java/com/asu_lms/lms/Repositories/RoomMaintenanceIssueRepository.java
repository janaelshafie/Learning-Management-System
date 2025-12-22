package com.asu_lms.lms.Repositories;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.asu_lms.lms.Entities.RoomMaintenanceIssue;

@Repository
public interface RoomMaintenanceIssueRepository extends JpaRepository<RoomMaintenanceIssue, Integer> {
    List<RoomMaintenanceIssue> findByRoomId(Integer roomId);
    List<RoomMaintenanceIssue> findByReportedByUserId(Integer userId);
    List<RoomMaintenanceIssue> findByStatus(String status);
    List<RoomMaintenanceIssue> findByPriority(String priority);
    List<RoomMaintenanceIssue> findByAssignedToUserId(Integer userId);
    List<RoomMaintenanceIssue> findByRoomIdAndStatus(Integer roomId, String status);
}
