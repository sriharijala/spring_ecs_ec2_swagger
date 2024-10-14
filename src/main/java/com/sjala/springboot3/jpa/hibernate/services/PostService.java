package com.sjala.springboot3.jpa.hibernate.services;

import java.util.List;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.sjala.springboot3.jpa.hibernate.model.Review;
import com.sjala.springboot3.jpa.hibernate.repositories.PostRepository;

@Service
public class PostService {

    @Autowired
    private PostRepository postRepository;

    public List<Review> findAllPosts() {

        List<Review> posts = (List<Review>) postRepository.findAll();
        return posts;
    }

    public Optional<Review> findPostById(Long id) {
        Optional<Review> post = postRepository.findById(id);
        return post;
    }

    @Transactional
	public Optional<Review> addReview(Review review) {
		Review post = postRepository.save(review);
		return Optional.of(post);
	}

}
