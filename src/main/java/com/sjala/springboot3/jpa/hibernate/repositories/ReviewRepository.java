package com.sjala.springboot3.jpa.hibernate.repositories;

import java.util.List;

import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.CrudRepository;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import com.sjala.springboot3.jpa.hibernate.model.Review;

@Repository
public interface ReviewRepository extends CrudRepository<Review,Long> {

    @Query(
  		  value = "SELECT * FROM review r WHERE r.customer_id = :customerID", 
  		  nativeQuery = true)
	List<Review> getReviewsByCusomerId(@Param("customerID") Long customerID);
}
