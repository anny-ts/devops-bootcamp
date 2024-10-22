package com.java4devops.task3.repo;

import com.java4devops.task3.model.User;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.stereotype.Repository;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.List;

/**
 * Created by Anna Tsiunchyk on 10/19/24.
 */
@Repository
public class UserRepositoryImpl implements UserRepository {

    private final JdbcTemplate jdbcTemplate;

    public UserRepositoryImpl(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    @Override
    public void save(String user, String email) {
        jdbcTemplate.update("INSERT INTO users (name, email)  VALUES (?, ?)", user, email);
    }

    @Override
    public User findByUsername(String username) {
        String sql = "SELECT id, name, email FROM users WHERE name = ?";
        return jdbcTemplate.queryForObject(sql, new UserRowMapper(), username);
    }

    @Override
    public List<User> findAll() {
        String sql = "SELECT id, name, email FROM users";
        return jdbcTemplate.query(sql, new UserRowMapper());
    }

    @Override
    public User findById(Long id) {
        String sql = "SELECT id, name, email FROM users WHERE id = ?";
        return jdbcTemplate.queryForObject(sql, new UserRowMapper(), id);
    }

    private static class UserRowMapper implements RowMapper<User> {
        @Override
        public User mapRow(ResultSet rs, int rowNum) throws SQLException {
            return new User().setId(rs.getLong("id"))
                    .setUsername(rs.getString("name"))
                    .setEmail(rs.getString("email"));
        }
    }
}
