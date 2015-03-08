package ${packageName};

import java.util.HashSet;
import java.util.Set;

import javax.ws.rs.core.Application;

public class ${className}Application extends Application {

	HashSet<Object> singletons = new HashSet<Object>();

	public ${className}Application() {
	}

	@Override
	public Set<Class<?>> getClasses() {
		HashSet<Class<?>> set = new HashSet<Class<?>>();
		
		set.add(${className}Service.class);
		
		set.add(com.wordnik.swagger.jaxrs.listing.ApiListingResource.class);
		set.add(com.wordnik.swagger.jaxrs.listing.ApiDeclarationProvider.class);
		set.add(com.wordnik.swagger.jaxrs.listing.ApiListingResourceJSON.class);
		set.add(com.wordnik.swagger.jaxrs.listing.ResourceListingProvider.class);
		
		return set;
	}

	@Override
	public Set<Object> getSingletons() {
		return singletons;  
	}  
}
