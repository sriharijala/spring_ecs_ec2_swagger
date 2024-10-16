package com.sjala.springboot3.jpa.hibernate.controllers;

import java.util.List;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RestController;

import com.sjala.springboot3.jpa.hibernate.model.Customer;
import com.sjala.springboot3.jpa.hibernate.model.Review;
import com.sjala.springboot3.jpa.hibernate.services.ReviewService;
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

@Tag(name = "User", description = "User management APIs")
@RestController
public class UserController {

    @Autowired
    private UserService userService;
    
    @Autowired
    private ReviewService  reviewService;
    

    @Operation(
	  	      summary = "List all customer",
	  	      description = "It returns all customer details.",
	  	      tags = { "User" })
    @ApiResponses({
        @ApiResponse(responseCode = "200", content = { @Content(schema = @Schema(implementation = Customer.class), mediaType = "application/json") }),
        @ApiResponse(responseCode = "204", description = "No users found", content = { @Content(schema = @Schema()) })
      })
    @GetMapping("/users")
    public  ResponseEntity<List<Customer>>  getAllUsers() {
        List<Customer> users = userService.getAllUsers();
        if(users.size() ==0)
        	    return new ResponseEntity<>(null,HttpStatus.NO_CONTENT);
        else
        		return new ResponseEntity<>(users,HttpStatus.OK);
    }

    @Operation(
	  	      summary = "Get customer details",
	  	      description = "Returns user details by user idr",
	  	      tags = { "User" })
    @ApiResponses({
      @ApiResponse(responseCode = "200", content = { @Content(schema = @Schema(implementation = Customer.class), mediaType = "application/json") }),
      @ApiResponse(responseCode = "204", description = "No users found", content = { @Content(schema = @Schema()) })
    })
    @GetMapping("/user/{id}")
    public ResponseEntity<Optional<Customer>> getUserById(@PathVariable Long id) {
        Optional<Customer> user = userService.getUserById(id);
        
        if(user == null)
        	  return new ResponseEntity<>(null,HttpStatus.NO_CONTENT);
        else 
        		return new ResponseEntity<>(user, HttpStatus.OK);
 
    }


    @Operation(
	  	      summary = "Reviews submitted by a given Customer",
	  	      description = "Returns reviews submitted by Customer id",
	  	      tags = { "User" })
	  @ApiResponses({
	    @ApiResponse(responseCode = "200", content = { @Content(schema = @Schema(implementation = Review.class), mediaType = "application/json") }),
	    @ApiResponse(responseCode = "204", description = "No reviews found", content = { @Content(schema = @Schema()) })
	  })
    @GetMapping("/user/{id}/reviews")
    public ResponseEntity<List<Review>> getListOfPostsByUser(
    		@Parameter(
    			       description = "Reviewer Id",
    			       required = true)
    		@PathVariable Long id) {
       
    	Optional<Customer> user = userService.getUserById(id);

        List<Review> reviews = null;
        Optional<Customer> dbCustomer = null;
        
        if(user.isPresent()) {
        	dbCustomer = Optional.ofNullable(user.get());
        	
        	reviews = reviewService.getReviewByUserId(id);
        }

        if(dbCustomer.get() == null)
      	  return new ResponseEntity<>(null,HttpStatus.NO_CONTENT);
        else 
      	  return new ResponseEntity<>(reviews, HttpStatus.OK);
    }
    
    @Operation(
	  	      summary = "Post a new review",
	  	      description = "Customer can add new review.",
	  	      tags = { "User" })
    @ApiResponses({
      @ApiResponse(responseCode = "200", content = { @Content(schema = @Schema(implementation = Customer.class), mediaType = "application/json") }),
      @ApiResponse(responseCode = "500", description = "Something went wrong, please retry.", content = { @Content(schema = @Schema()) })
    })
	@PostMapping(path = "/user", produces = "application/json", consumes = "application/json")
	public ResponseEntity<Customer> addUser(
			@RequestBody(description = "User details", required = true,
                         content = @Content(
                        			schema=@Schema(implementation = Customer.class))) 
			@Valid @org.springframework.web.bind.annotation.RequestBody Customer user
		)
	{

    	Optional<Customer> savedUser = userService.addUser(user);
    	
		 if(user == null)
	  	     return new ResponseEntity<>(null,HttpStatus.INTERNAL_SERVER_ERROR);
	  	 else 
	  	     return new ResponseEntity<>(savedUser.get(), HttpStatus.OK);
		 	
	}

}
