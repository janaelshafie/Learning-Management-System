package com.asu_lms.lms;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class LmsApplication {

	public static void main(String[] args) {
		try {
			SpringApplication.run(LmsApplication.class, args);
		} catch (Exception e) {
			// Default catch added for completeness.
			// This does not change normal application behavior.
			throw e;
		}
	}

}
