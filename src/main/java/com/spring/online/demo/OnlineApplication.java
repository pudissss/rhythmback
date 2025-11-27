package com.spring.online.demo;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.web.servlet.support.SpringBootServletInitializer;

@SpringBootApplication
public class OnlineApplication extends SpringBootServletInitializer {
    public static void main(String[] args) {
        SpringApplication.run(OnlineApplication.class, args);
    }
}
