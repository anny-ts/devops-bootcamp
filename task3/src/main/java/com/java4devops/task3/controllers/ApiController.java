package com.java4devops.task3.controllers;

import com.java4devops.task3.model.User;
import com.java4devops.task3.repo.UserRepository;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

/**
 * Created by Anna Tsiunchyk on 10/19/24.
 */
@RestController
public class ApiController {

    @Value("${custom.name}")
    private String customName;
    private final UserRepository userRepository;

    public ApiController(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    @GetMapping(path = "/hello")
    public String hello() {
        return "Hello " + customName;
    }

    @GetMapping("/users")
    public List<User> getUserById() {
        return userRepository.findAll();
    }

    @GetMapping("/{id}")
    public User getUserById(@PathVariable Long id) {
        return userRepository.findById(id);
    }

    @PostMapping(path = "/user")
    public String createUser(@RequestBody User user) {
        userRepository.save(user.getUsername(), user.getEmail());
        return "User created successfully!";
    }
}
