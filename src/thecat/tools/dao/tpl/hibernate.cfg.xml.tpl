<!DOCTYPE hibernate-configuration PUBLIC
	"-//Hibernate/Hibernate Configuration DTD 3.0//EN"
	"http://hibernate.sourceforge.net/hibernate-configuration-3.0.dtd">

<hibernate-configuration>
	<session-factory>
		
	    <property name="hibernate.connection.driver_class">org.hsqldb.jdbcDriver</property>
		<property name="hibernate.connection.url">jdbc:hsqldb:mem:test</property>	      
		<property name="hibernate.connection.username">sa</property>
		<property name="hibernate.connection.password"></property>
		<property name="hibernate.dialect">org.hibernate.dialect.HSQLDialect</property>
		
		<property name="hibernate.show_sql">true</property>
		<property name="hibernate.format_sql">true</property>
		
		<property name="hibernate.connection.pool_size">5</property>
		<property name="hibernate.hbm2ddl.auto">create</property>
	
		<property name="hibernate.current_session_context_class">thread</property>

<#if useEhcache>
		<!-- 2L cache provider -->
	    <property name="hibernate.cache.use_second_level_cache">true</property>
	    <property name="hibernate.cache.region.factory_class">net.sf.ehcache.hibernate.EhCacheRegionFactory</property>
	    <property name="hibernate.cache.use_query_cache">true</property>
</#if>
	      
	    <!-- Mapping classes -->  
		<mapping class="${fqClassName}" />

	</session-factory>
</hibernate-configuration>
