package com.hjw.java;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.ComponentScan;

@SpringBootApplication
@ComponentScan("com.hjw.java")
public class JavaDemoApplication {

	public static void main(String[] args) {
		SpringApplication.run(JavaDemoApplication.class, args);
	}

}
