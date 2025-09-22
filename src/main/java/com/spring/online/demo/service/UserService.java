package com.spring.online.demo.service;

import com.spring.online.demo.DAO.UserDao;
import com.spring.online.demo.models.User;

import java.util.HashMap;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestParam;
import jakarta.mail.MessagingException;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;

import jakarta.mail.internet.MimeMessage;

@Service
public class UserService {

    @Autowired
    UserDao userDao;

    @Autowired
    JwtManager jwtManager;

    @Autowired
    JavaMailSender mailSender;

    public String addUser(@RequestBody User user) throws MessagingException {
        // Debug print to check what role is being received
        System.out.println("Received user with role: " + user.getRole());
        
        // Set default role only if null
        if(user.getRole() == null) {
            user.setRole("USER");
        } else {
            // Ensure role is uppercase for consistency
            user.setRole(user.getRole().toUpperCase());
        }
        
        // Debug print to check what role will be saved
        System.out.println("Saving user with role: " + user.getRole());
        
        userDao.save(user);
        // sendMail(user.getEmail());
        return "User added with role: " + user.getRole();
    }

    public Map<String, Object> validateUser(@RequestParam("email") String email, @RequestParam("password") String password) throws MessagingException {
        Map<String, Object> response = new HashMap<>();
        User user = userDao.findByEmail(email);
        if (user != null && user.getPassword().equals(password)) {
            String role = String.valueOf(user.getRole());
            String token = jwtManager.generateToken(user.getEmail(), role); // Include role in token
            // sendMail(email);
            // Create proper JSON response
            response.put("token", token);
            response.put("user", user);
            response.put("expiresIn", 3600); // 1 hour token expiry
            response.put("status", "success");
            return response;
        }
        response.put("status", "error");
        response.put("message", "Invalid Credentials");
        return response;
    }

    public User getUserById(int id) {
        return userDao.findById(id).orElse(null);
    }

    public String sendMail(String email) throws MessagingException {
        User user = userDao.findByEmail(email);
        if (user == null) {
            return "User not found";
        }
        String username = user.getUsername();
        MimeMessage mimeMessage = mailSender.createMimeMessage();
        MimeMessageHelper helper = new MimeMessageHelper(mimeMessage, true);
        String htmlContent = String.format("""
        <!DOCTYPE html>
        <html lang=\"en\">
        <head>
            <meta charset=\"UTF-8\">
            <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">
            <title>Welcome to TuneUp</title>
            <style>
                body, html { margin: 0; padding: 0; font-family: 'Poppins', sans-serif; background: linear-gradient(135deg, #1DB954 0%%, #191414 100%%); color: #ffffff; }
                .email-container { max-width: 600px; margin: 20px auto; background: rgba(255, 255, 255, 0.1); border-radius: 15px; padding: 30px; text-align: center; }
                .header-title { font-size: 36px; font-weight: 700; color: #ffffff; }
                .welcome-message { font-size: 24px; font-weight: 600; color: #1ED760; }
                .cta-button { display: inline-block; padding: 15px 30px; background: #1ED760; color: #191414; text-decoration: none; border-radius: 50px; font-weight: 700; }
                .cta-button:hover { background: #1DB954; }
                .email-footer { margin-top: 20px; font-size: 12px; color: #ccc; }
            </style>
        </head>
        <body>
            <div class=\"email-container\">
                <h1 class=\"header-title\">Welcome to TuneUp, %s! 🎵</h1>
                <p class=\"welcome-message\">Your Musical Universe Awaits!</p>
                <p>Get ready to dive into a world where music meets magic. TuneUp is more than a platform—it's your personal soundtrack.</p>
                <a href=\"#\" class=\"cta-button\">Unleash Your Playlist</a>
                <div class=\"email-footer\">© 2025 TuneUp. All rights reserved.</div>
            </div>
        </body>
        </html>
        """, username);
        helper.setTo(email);
        helper.setSubject("Welcome to TuneUp!");
        helper.setText(htmlContent, true);
        mailSender.send(mimeMessage);
        return "Mail Sent Successfully";
    }
}