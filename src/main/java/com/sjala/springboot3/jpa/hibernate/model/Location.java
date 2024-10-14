package com.sjala.springboot3.jpa.hibernate.model;

import java.util.List;

import com.fasterxml.jackson.annotation.JsonManagedReference;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.OneToMany;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity
@NoArgsConstructor
@AllArgsConstructor
@Getter
@Setter
@Schema(description = "Location Model Information")
public class Location {

    @Id
    @GeneratedValue(strategy = GenerationType.SEQUENCE)
    @Column(name = "id", nullable = false)
    @Schema(accessMode = Schema.AccessMode.READ_ONLY, description = "Location Id", example = "123")
    private Long id;

    @Schema(description = "Address of the location", example = "Cherry ln, MA")
    private String address;

    @Schema(description = "list of user at the location")
    @OneToMany(mappedBy = "location")
    private List<User> users;

    @JsonManagedReference
    public List<User> getUsers() {
        return users;
    }
}
