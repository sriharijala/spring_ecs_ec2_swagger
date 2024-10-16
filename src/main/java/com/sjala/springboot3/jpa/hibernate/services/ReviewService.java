package com.sjala.springboot3.jpa.hibernate.services;

import java.util.List;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.sjala.springboot3.jpa.hibernate.model.Review;
import com.sjala.springboot3.jpa.hibernate.repositories.ReviewRepository;

@Service
public class ReviewService {

    @Autowired
    private ReviewRepository reviewRepository;

    public List<Review> findAllPosts() {

        List<Review> reviews = (List<Review>) reviewRepository.findAll();
        return reviews;
    }

    public Optional<Review> findPostById(Long id) {
        Optional<Review> post = reviewRepository.findById(id);
        return post;
    }

    @Transactional
	public Optional<Review> addReview(Review review) {
		Review post = reviewRepository.save(review);
		return Optional.of(post);
	}

	public List<Review> getReviewByUserId(Long id) {
		List<Review> reviews = reviewRepository.getReviewsByCusomerId(id);
		return reviews;
	}

}
