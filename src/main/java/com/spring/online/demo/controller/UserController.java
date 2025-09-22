package com.spring.online.demo.controller;

import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.spring.online.demo.models.User;
import com.spring.online.demo.service.UserService;

import jakarta.mail.MessagingException;

@RestController
@CrossOrigin(origins ="*")
@RequestMapping("/user")
public class UserController {

    @Autowired
    UserService us;

    @PostMapping("/signup")
    public String addUser(@RequestBody User user) throws MessagingException {
        // Debug logging to check what's in the request body
        System.out.println("Received signup request with role: " + user.getRole());
        return us.addUser(user);
    }

    @PostMapping("/signin")
    public Map<String, Object> signin(@RequestBody User user) throws MessagingException {
        return us.validateUser(user.getEmail(), user.getPassword());
    }

    @GetMapping("/{id}")
    public User getUserById(@PathVariable int id) {
       return us.getUserById(id); 
    }
    
}