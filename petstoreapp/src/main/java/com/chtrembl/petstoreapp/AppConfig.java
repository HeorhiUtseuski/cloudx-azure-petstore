package com.chtrembl.petstoreapp;

import com.chtrembl.petstoreapp.security.AADB2COidcLoginConfigurerWrapper;
import com.github.benmanes.caffeine.cache.Caffeine;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.autoconfigure.EnableAutoConfiguration;
import org.springframework.cache.CacheManager;
import org.springframework.cache.annotation.EnableCaching;
import org.springframework.cache.caffeine.CaffeineCacheManager;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.method.configuration.EnableGlobalMethodSecurity;
import org.springframework.web.servlet.config.annotation.InterceptorRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

import java.util.concurrent.TimeUnit;

@Configuration
@EnableAutoConfiguration
@ComponentScan
@EnableCaching
@EnableGlobalMethodSecurity(securedEnabled = true, prePostEnabled = true)
public class AppConfig implements WebMvcConfigurer {

	private static final Logger log = LoggerFactory.getLogger(AppConfig.class);

	@Override
	public void addInterceptors(InterceptorRegistry registry) {
		log.info("Adding interceptors");
		log.info("Adding interceptors");
	}

	@Bean
	public AADB2COidcLoginConfigurerWrapper aadB2COidcLoginConfigurerWrapper() {
		return new AADB2COidcLoginConfigurerWrapper();
	}

	@Bean
	public Caffeine caffeineConfig() {
		return Caffeine.newBuilder().expireAfterAccess(300, TimeUnit.SECONDS);
	}

	@Bean
	public CacheManager currentUsersCacheManager(Caffeine caffeine) {
		CaffeineCacheManager caffeineCacheManager = new CaffeineCacheManager();
		caffeineCacheManager.setCaffeine(caffeine);
		return caffeineCacheManager;
	}
}