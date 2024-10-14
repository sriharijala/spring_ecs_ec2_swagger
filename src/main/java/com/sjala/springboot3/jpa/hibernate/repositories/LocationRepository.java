package com.sjala.springboot3.jpa.hibernate.repositories;

import org.springframework.data.repository.CrudRepository;
import org.springframework.stereotype.Repository;

import com.sjala.springboot3.jpa.hibernate.model.Location;

@Repository
public interface LocationRepository extends CrudRepository<Location,Long> {
}
