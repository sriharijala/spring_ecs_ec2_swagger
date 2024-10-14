package com.sjala.springboot3.jpa.hibernate;

import java.util.Collection;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.context.event.ContextRefreshedEvent;
import org.springframework.context.event.EventListener;
import org.springframework.core.env.ConfigurableEnvironment;
import org.springframework.core.env.MapPropertySource;
import org.springframework.stereotype.Component;

@Component
public class AppContextRefreshedEventPropertiesPrinter {

	Logger logger = LoggerFactory.getLogger(AppContextRefreshedEventPropertiesPrinter.class);

	@EventListener
	public void handleContextRefreshed(ContextRefreshedEvent event) {
		ConfigurableEnvironment env = (ConfigurableEnvironment) event.getApplicationContext().getEnvironment();

		env.getPropertySources().stream().filter(
				ps -> ps instanceof MapPropertySource)
				.map(ps -> ((MapPropertySource) ps).getSource().keySet()).flatMap(Collection::stream).distinct()
				.sorted().forEach(key -> logger.info("{}={}", key, env.getProperty(key)));
	}

}
