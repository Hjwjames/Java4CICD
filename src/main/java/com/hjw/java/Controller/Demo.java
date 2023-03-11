package com.hjw.java.Controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class Demo {

    @Autowired
    private StringRedisTemplate redisTemplate;

    @GetMapping("/hello")
    public String count(){
        Long increment = redisTemplate.opsForValue().increment("count-people");
        return "一共【 "+increment+" 】人访问";
    }

}
