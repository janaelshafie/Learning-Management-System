package com.asu_lms.lms.Repositories;

import com.asu_lms.lms.Entities.AnnouncementAttributes;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface AnnouncementAttributesRepository extends JpaRepository<AnnouncementAttributes, Integer> {
    Optional<AnnouncementAttributes> findByAttributeName(String attributeName);
}

