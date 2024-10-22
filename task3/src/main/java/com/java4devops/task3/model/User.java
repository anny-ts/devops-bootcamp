package com.java4devops.task3.model;

/**
 * Created by Anna Tsiunchyk on 10/19/24.
 */
public class User {
    private Long id;
    private String username;
    private String email;

    public Long getId() {
        return id;
    }

    public User setId(Long id) {
        this.id = id;
        return this;
    }

    public String getUsername() {
        return username;
    }

    public User setUsername(String username) {
        this.username = username;
        return this;
    }

    public String getEmail() {
        return email;
    }

    public User setEmail(String email) {
        this.email = email;
        return this;
    }
}
