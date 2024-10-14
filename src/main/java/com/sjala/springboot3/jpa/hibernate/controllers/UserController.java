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

import com.sjala.springboot3.jpa.hibernate.model.Review;
import com.sjala.springboot3.jpa.hibernate.model.User;
import com.sjala.springboot3.jpa.hibernate.services.UserService;

import io.swagger.v3.oas.annotations.Operation;
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

    @Operation(
	  	      summary = "List all users",
	  	      description = "It returns all uses details.",
	  	      tags = { "User" })
    @ApiResponses({
        @ApiResponse(responseCode = "200", content = { @Content(schema = @Schema(implementation = Review.class), mediaType = "application/json") }),
        @ApiResponse(responseCode = "204", description = "No users found", content = { @Content(schema = @Schema()) })
      })
    @GetMapping("/users")
    public  ResponseEntity<List<User>>  getAllUsers() {
        List<User> users = userService.getAllUsers();
        if(users.size() ==0)
        	    return new ResponseEntity<>(null,HttpStatus.NO_CONTENT);
        else
        		return new ResponseEntity<>(users,HttpStatus.OK);
    }

    @Operation(
	  	      summary = "Get User details",
	  	      description = "Returns user details by user idr",
	  	      tags = { "User" })
    @ApiResponses({
      @ApiResponse(responseCode = "200", content = { @Content(schema = @Schema(implementation = Review.class), mediaType = "application/json") }),
      @ApiResponse(responseCode = "204", description = "No users found", content = { @Content(schema = @Schema()) })
    })
    @GetMapping("/user/{id}")
    public ResponseEntity<Optional<User>> getUserById(@PathVariable Long id) {
        Optional<User> user = userService.getUserById(id);
        
        if(user == null)
        	  return new ResponseEntity<>(null,HttpStatus.NO_CONTENT);
        else 
        		return new ResponseEntity<>(user, HttpStatus.OK);
 
    }

    @Operation(
	  	      summary = "Reviews submitted",
	  	      description = "Returns seviews submitted by user id",
	  	      tags = { "User" })
	  @ApiResponses({
	    @ApiResponse(responseCode = "200", content = { @Content(schema = @Schema(implementation = Review.class), mediaType = "application/json") }),
	    @ApiResponse(responseCode = "204", description = "No reviews found", content = { @Content(schema = @Schema()) })
	  })
    @GetMapping("/user/{id}/posts")
    public ResponseEntity<List<Review>> getListOfPostsByUser(@PathVariable Long id) {
        Optional<User> user = userService.getUserById(id);

        List<Review> reviews = null;
        
        if(user.isPresent()) {
            User newUser = user.get();
            reviews = newUser.getPosts();
        }

        if(reviews == null)
      	  return new ResponseEntity<>(null,HttpStatus.NO_CONTENT);
        else 
      	  return new ResponseEntity<>(reviews, HttpStatus.OK);
    }
    
    @Operation(
	  	      summary = "Add new review",
	  	      description = "User can add new review.",
	  	      tags = { "User" })
    @ApiResponses({
      @ApiResponse(responseCode = "200", content = { @Content(schema = @Schema(implementation = Review.class), mediaType = "application/json") }),
      @ApiResponse(responseCode = "500", description = "Something went wrong, please retry.", content = { @Content(schema = @Schema()) })
    })
	@PostMapping(path = "/user", produces = "application/json", consumes = "application/json")
	public ResponseEntity<User> addUser(
			@RequestBody(description = "User details", required = true,
                         content = @Content(
                        			schema=@Schema(implementation = User.class))) 
			@Valid @org.springframework.web.bind.annotation.RequestBody User user
		)
	{

    	Optional<User> savedUser = userService.addUser(user);
    	
		 if(user == null)
	  	     return new ResponseEntity<>(null,HttpStatus.INTERNAL_SERVER_ERROR);
	  	 else 
	  	     return new ResponseEntity<>(savedUser.get(), HttpStatus.OK);
		 	
	}
}
