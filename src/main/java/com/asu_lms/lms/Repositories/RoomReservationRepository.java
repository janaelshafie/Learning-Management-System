package com.asu_lms.lms.Repositories;

import java.sql.Timestamp;
import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import com.asu_lms.lms.Entities.RoomReservation;

@Repository
public interface RoomReservationRepository extends JpaRepository<RoomReservation, Integer> {
    List<RoomReservation> findByRoomId(Integer roomId);
    List<RoomReservation> findByReservedByUserId(Integer userId);
    List<RoomReservation> findByStatus(String status);
    
    @Query("SELECT r FROM RoomReservation r WHERE r.roomId = :roomId " +
           "AND r.status IN ('pending', 'approved') " +
           "AND ((r.startDatetime <= :endTime AND r.endDatetime >= :startTime))")
    List<RoomReservation> findConflictingReservations(
        @Param("roomId") Integer roomId,
        @Param("startTime") Timestamp startTime,
        @Param("endTime") Timestamp endTime
    );
    
    @Query("SELECT r FROM RoomReservation r WHERE r.roomId = :roomId " +
           "AND r.startDatetime >= :startDate AND r.startDatetime <= :endDate " +
           "ORDER BY r.startDatetime")
    List<RoomReservation> findByRoomIdAndDateRange(
        @Param("roomId") Integer roomId,
        @Param("startDate") Timestamp startDate,
        @Param("endDate") Timestamp endDate
    );
}
