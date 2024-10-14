package com.sjala.springboot3.jpa.hibernate.controllers;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.sjala.springboot3.jpa.hibernate.model.Review;
import com.sjala.springboot3.jpa.hibernate.model.User;
import com.sjala.springboot3.jpa.hibernate.services.PostService;
import com.sjala.springboot3.jpa.hibernate.services.UserService;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.parameters.RequestBody;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;

@Tag(name = "Review", description = "Review management APIs")
@RestController
public class ReviewController {

	@Autowired
	private PostService postService;
	
	@Autowired
	private UserService userService;

	@Operation(summary = "Retrieve a all reviews", description = "Get all posts. The response is list of Post objects.", tags = {
			"Review" })
	@ApiResponses({
	    @ApiResponse(responseCode = "200", content = { @Content(schema = @Schema(implementation = Review.class), mediaType = "application/json") }),
	    @ApiResponse(responseCode = "204", description = "No reviews found", content = { @Content(schema = @Schema()) })
	  })
	@GetMapping("/reviews")
	public ResponseEntity<List<Review>> getPosts() {
		
		List<Review> reviews = postService.findAllPosts();			
		
		if(reviews == null)
	      return new ResponseEntity<>(null,HttpStatus.NO_CONTENT);
	    else 
	     return new ResponseEntity<>(reviews, HttpStatus.OK);
	}

	@Operation(
  	      summary = "Retrieve a Post  by Id",
  	      description = "Get a post object by specifying its id. The response is Post object details .",
  	      tags = { "Review" })
    @ApiResponses({
        @ApiResponse(responseCode = "200", content = { @Content(schema = @Schema(implementation = Review.class), mediaType = "application/json") }),
        @ApiResponse(responseCode = "404", description = "The Post with given Id was not found.", content = { @Content(schema = @Schema()) })
      })
    @GetMapping("review/{id}")
    public ResponseEntity<Optional<Review>> getLocationById(@PathVariable Long id) {
		
        Optional<Review> post = postService.findPostById(id);
        
        if(post == null)
  	      return new ResponseEntity<>(null,HttpStatus.NO_CONTENT);
  	    else 
  	     return new ResponseEntity<>(post, HttpStatus.OK);
    }

	
	@Operation(
	  	      summary = "Add new review",
	  	      description = "User can add new review.",
	  	      tags = { "Review" })
    @ApiResponses({
        @ApiResponse(responseCode = "200", content = { @Content(schema = @Schema(implementation = Review.class), mediaType = "application/json") }),
        @ApiResponse(responseCode = "500", description = "Something went wrong, please retry.", content = { @Content(schema = @Schema()) })
      })
	@PostMapping(path = "/review",  produces = "application/json", consumes = "application/json")
	public ResponseEntity<Optional<Review>> submitReview(
			@RequestBody(description = "Review to add.", required = true,
             content = @Content(
                     schema=@Schema(implementation = Review.class))) 
			@Valid @org.springframework.web.bind.annotation.RequestBody Review review
		)
	{
		
		 Optional<Review> postedReview = null;
		 review.setPostDate(LocalDateTime.now());
		 Optional<User> userPosted = userService.getUserById(review.getReviewerId());
		 if(userPosted.get() != null) {
			 review.setUser(userPosted.get());
		 	 postedReview = postService.addReview(review);
		 } 

		 if(postedReview == null)
	  	      return new ResponseEntity<>(null,HttpStatus.INTERNAL_SERVER_ERROR);
	  	    else 
	  	     return new ResponseEntity<>(postedReview, HttpStatus.OK);
		 	
	}

}
