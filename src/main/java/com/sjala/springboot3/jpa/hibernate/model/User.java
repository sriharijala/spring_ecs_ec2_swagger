package com.sjala.springboot3.jpa.hibernate.model;

import java.util.List;

import com.fasterxml.jackson.annotation.JsonIdentityInfo;
import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.annotation.ObjectIdGenerators;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
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
@JsonIdentityInfo(property = "id",
generator = ObjectIdGenerators.PropertyGenerator.class)
@Schema(description = "User Model Information")
public class User {

    @Id
    @GeneratedValue(strategy = GenerationType.SEQUENCE)
    @Column(name = "id", nullable = false)
    @Schema(accessMode = Schema.AccessMode.READ_ONLY, description = "Location Id", example = "123")
    private Long id;

    @Schema(description = "User Firstname ", example = "John")
    private String firstName;
    
    @Schema(description = "User Last name ", example = "Smith")
    private String lastName;
    
    @Schema(description = "User email address", example = "Smith")
    private String email;

    @ManyToOne
    @JoinColumn(name = "location_id")
    private Location location;

    @OneToMany(mappedBy = "user")
    private List<Review> posts;

    //@JsonBackReference
    @JsonIgnore
    public Location getLocation() {
        return location;
    }

    //@JsonManagedReference
    //alternate is to use JsonIdentityInfo on class
    public List<Review> getPosts() {
        return posts;
    }
}
