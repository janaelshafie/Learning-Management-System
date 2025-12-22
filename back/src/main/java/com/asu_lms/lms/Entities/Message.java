package com.asu_lms.lms.Entities;

import java.sql.Timestamp;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

@Entity
@Table(name = "Message")
public class Message {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "message_id")
    private Integer messageId;

    @Column(name = "sender_user_id", nullable = false)
    private Integer senderUserId;

    @Column(name = "recipient_user_id", nullable = false)
    private Integer recipientUserId;

    @Column(name = "content", columnDefinition = "TEXT", nullable = false)
    private String content;

    @Column(name = "sent_at", nullable = false)
    private Timestamp sentAt = new Timestamp(System.currentTimeMillis());

    @Column(name = "read_at")
    private Timestamp readAt;

    // Constructors
    public Message() {}

    public Message(Integer senderUserId, Integer recipientUserId, String content) {
        this.senderUserId = senderUserId;
        this.recipientUserId = recipientUserId;
        this.content = content;
        this.sentAt = new Timestamp(System.currentTimeMillis());
    }

    // Getters and Setters
    public Integer getMessageId() { return messageId; }
    public void setMessageId(Integer messageId) { this.messageId = messageId; }

    public Integer getSenderUserId() { return senderUserId; }
    public void setSenderUserId(Integer senderUserId) { this.senderUserId = senderUserId; }

    public Integer getRecipientUserId() { return recipientUserId; }
    public void setRecipientUserId(Integer recipientUserId) { this.recipientUserId = recipientUserId; }

    public String getContent() { return content; }
    public void setContent(String content) { this.content = content; }

    public Timestamp getSentAt() { return sentAt; }
    public void setSentAt(Timestamp sentAt) { this.sentAt = sentAt; }

    public Timestamp getReadAt() { return readAt; }
    public void setReadAt(Timestamp readAt) { this.readAt = readAt; }
}
