package com.asu_lms.lms.Entities;

import jakarta.persistence.*;

@Entity
@Table(name = "RoomAttributeValues")
public class RoomAttributeValues {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "rav_id")
    private Integer ravId;

    @ManyToOne
    @JoinColumn(name = "room_id", nullable = false)
    private Rooms room;

    @ManyToOne
    @JoinColumn(name = "attribute_id", nullable = false)
    private RoomAttributes attribute;

    @Column(name = "value", columnDefinition = "TEXT")
    private String value;

    // Constructors
    public RoomAttributeValues() {}

    public RoomAttributeValues(Rooms room, RoomAttributes attribute, String value) {
        this.room = room;
        this.attribute = attribute;
        this.value = value;
    }

    // Getters and Setters
    public Integer getRavId() { return ravId; }
    public void setRavId(Integer ravId) { this.ravId = ravId; }

    public Rooms getRoom() { return room; }
    public void setRoom(Rooms room) { this.room = room; }

    public RoomAttributes getAttribute() { return attribute; }
    public void setAttribute(RoomAttributes attribute) { this.attribute = attribute; }

    public String getValue() { return value; }
    public void setValue(String value) { this.value = value; }
}
