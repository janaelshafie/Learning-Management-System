package com.asu_lms.lms.Repositories;

import com.asu_lms.lms.Entities.RoomAttributeValues;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface RoomAttributeValuesRepository extends JpaRepository<RoomAttributeValues, Integer> {
    
    // Find all attributes for a specific room
    List<RoomAttributeValues> findByRoom_RoomId(Integer roomId);
    
    // Find a specific attribute value for a room
    Optional<RoomAttributeValues> findByRoom_RoomIdAndAttribute_AttributeName(Integer roomId, String attributeName);
    
    // Find all rooms that have a specific attribute with a specific value
    @Query("SELECT rav FROM RoomAttributeValues rav WHERE rav.attribute.attributeName = :attrName AND rav.value = :value")
    List<RoomAttributeValues> findByAttributeNameAndValue(@Param("attrName") String attributeName, @Param("value") String value);
    
    // Find all rooms that have a specific attribute (regardless of value)
    @Query("SELECT rav FROM RoomAttributeValues rav WHERE rav.attribute.attributeName = :attrName")
    List<RoomAttributeValues> findByAttributeName(@Param("attrName") String attributeName);
    
    // Find rooms with boolean attribute set to true
    @Query("SELECT rav.room.roomId FROM RoomAttributeValues rav WHERE rav.attribute.attributeName = :attrName AND rav.value = 'true'")
    List<Integer> findRoomIdsWithTrueAttribute(@Param("attrName") String attributeName);
    
    // Delete all attribute values for a room
    void deleteByRoom_RoomId(Integer roomId);
}
