package com.asu_lms.lms.Repositories;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.asu_lms.lms.Entities.Message;

@Repository
public interface MessageRepository extends JpaRepository<Message, Integer> {
    List<Message> findByRecipientUserIdOrderBySentAtDesc(Integer recipientUserId);
    List<Message> findBySenderUserIdOrderBySentAtDesc(Integer senderUserId);
    List<Message> findByRecipientUserIdAndReadAtIsNull(Integer recipientUserId);
    long countByRecipientUserIdAndReadAtIsNull(Integer recipientUserId);
}
