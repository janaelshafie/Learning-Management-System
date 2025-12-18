package com.asu_lms.lms.Repositories;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.asu_lms.lms.Entities.Rooms;

@Repository
public interface RoomsRepository extends JpaRepository<Rooms, Integer> {
    List<Rooms> findByRoomType(String roomType);
    List<Rooms> findByBuilding(String building);
    List<Rooms> findByStatus(String status);
    List<Rooms> findByBuildingAndRoomType(String building, String roomType);
}
