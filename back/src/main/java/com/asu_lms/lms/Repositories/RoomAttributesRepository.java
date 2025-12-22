package com.asu_lms.lms.Repositories;

import com.asu_lms.lms.Entities.RoomAttributes;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface RoomAttributesRepository extends JpaRepository<RoomAttributes, Integer> {
    Optional<RoomAttributes> findByAttributeName(String attributeName);
}
