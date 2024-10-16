package com.sjala.springboot3.jpa.hibernate.services;

import java.util.List;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.sjala.springboot3.jpa.hibernate.model.Review;
import com.sjala.springboot3.jpa.hibernate.model.Customer;
import com.sjala.springboot3.jpa.hibernate.repositories.UserRepository;

import jakarta.validation.Valid;

@Service
public class UserService {

    @Autowired
    private UserRepository userRepository;

    public List<Customer> getAllUsers() {
        return (List<Customer>) userRepository.findAll();
    }

    public Optional<Customer> getUserById(Long id) {
        return userRepository.findById(id);
    }

	public Optional<Customer> addUser(@Valid Customer user) {
		Customer savedUser = userRepository.save(user);
		return Optional.of(savedUser);
	}
}
