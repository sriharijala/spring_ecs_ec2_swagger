package com.sjala.springboot3.jpa.hibernate.services;

import java.util.List;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.sjala.springboot3.jpa.hibernate.model.Location;
import com.sjala.springboot3.jpa.hibernate.repositories.LocationRepository;

@Service
public class LocationService {

    @Autowired
    private LocationRepository locationRepository;

    public List<Location> findAllLocation() {
        return (List<Location>) locationRepository.findAll();
    }

    public Optional<Location> findLocationById(Long id) {
        Optional<Location> location = locationRepository.findById(id);
        return location;
    }
}
