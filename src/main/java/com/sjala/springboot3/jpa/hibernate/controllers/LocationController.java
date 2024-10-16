package com.sjala.springboot3.jpa.hibernate.controllers;

import java.util.List;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RestController;

import com.sjala.springboot3.jpa.hibernate.model.Location;
import com.sjala.springboot3.jpa.hibernate.model.Review;
import com.sjala.springboot3.jpa.hibernate.model.Customer;
import com.sjala.springboot3.jpa.hibernate.services.LocationService;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;

@Tag(name = "Location", description = "Location management APIs")
@RestController
public class LocationController {

    @Autowired
    private LocationService locationService;

    @Operation(
	  	      summary = "List all locations",
	  	      description = "It returns all locaion details.",
	  	      tags = { "Location" })
    @ApiResponses({
      @ApiResponse(responseCode = "200", content = { @Content(schema = @Schema(implementation = Location.class), mediaType = "application/json") }),
      @ApiResponse(responseCode = "204", description = "No locations found", content = { @Content(schema = @Schema()) })
    })
    @GetMapping("/location")
    public ResponseEntity<List<Location>> getAllLocations() {
        List<Location> locations = locationService.findAllLocation();
        
        if(locations.size() ==0)
    	    		return new ResponseEntity<>(null,HttpStatus.NO_CONTENT);
        else
    			return new ResponseEntity<>(locations,HttpStatus.OK);
    }

    @Operation(
	  	      summary = "Get location details",
	  	      description = "Returns location details by location idr",
	  	      tags = { "Location" })
	@ApiResponses({
	    @ApiResponse(responseCode = "200", content = { @Content(schema = @Schema(implementation = Location.class), mediaType = "application/json") }),
	    @ApiResponse(responseCode = "204", description = "No users found", content = { @Content(schema = @Schema()) })
	  })
    @GetMapping("/location/{id}")
    public ResponseEntity<Optional<Location>> getLocationById(@PathVariable Long id) {
        Optional<Location> location = locationService.findLocationById(id);

        if(location == null)
	    		return new ResponseEntity<>(null,HttpStatus.NO_CONTENT);
		else
			return new ResponseEntity<>(location, HttpStatus.OK);
    }
    
    @Operation(
	  	      summary = "Users in a given location",
	  	      description = "Returns all user from a given location",
	  	      tags = { "Location" })
	  @ApiResponses({
	    @ApiResponse(responseCode = "200", content = { @Content(schema = @Schema(implementation = Customer.class), mediaType = "application/json") }),
	    @ApiResponse(responseCode = "204", description = "No users found in location", content = { @Content(schema = @Schema()) })
	  })    
    @GetMapping("/location/{id}/users")
    public ResponseEntity<List<Customer>> getListOfUsersByLocation(@PathVariable Long id) {
        
    		Optional<Location> location = locationService.findLocationById(id);

    		List<Customer> users = null;
    		
        if(location.isPresent()) {
            Location newLocation = location.get();
            users = newLocation.getUsers();
        }

        if(users == null)
    			return new ResponseEntity<>(null,HttpStatus.NO_CONTENT);
        else
        		return new ResponseEntity<>(users, HttpStatus.OK);
    }
}
