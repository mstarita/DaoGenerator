<#assign entityName=className?uncap_first>
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns:tx="http://www.springframework.org/schema/tx"
	xmlns:aop="http://www.springframework.org/schema/aop"
	xsi:schemaLocation="
		http://www.springframework.org/schema/beans
		http://www.springframework.org/schema/beans/spring-beans-2.5.xsd
		http://www.springframework.org/schema/tx
		http://www.springframework.org/schema/tx/spring-tx.xsd
		http://www.springframework.org/schema/aop
		http://www.springframework.org/schema/aop/spring-aop-2.5.xsd">

	<bean id="dataSource" class="org.apache.commons.dbcp.BasicDataSource">
		<property name="driverClassName" value="org.hsqldb.jdbcDriver" />
		<property name="url" value="jdbc:hsqldb:mem:test" />
		<property name="username" value="sa" />
		<property name="password" value="" />
	</bean>

	<bean id="sessionFactory" class="org.springframework.orm.hibernate3.annotation.AnnotationSessionFactoryBean">
		<property name="hibernateProperties">
			<props>
				<prop key="hibernate.transaction.factory_class" >org.hibernate.transaction.JDBCTransactionFactory</prop>
				<prop key="hibernate.dialect">org.hibernate.dialect.HSQLDialect</prop>
				
				<prop key="hibernate.show_sql">true</prop>
				<prop key="hibernate.format_sql">true</prop>
				
				<prop key="hibernate.connection.pool_size">5</prop>
				<prop key="hibernate.hbm2ddl.auto">create</prop>				
<#if useEhcache>
				<!-- 2L cache provider -->
	    		<prop key="hibernate.cache.use_second_level_cache">true</prop>
	    		<prop key="hibernate.cache.region.factory_class">net.sf.ehcache.hibernate.EhCacheRegionFactory</prop>
	    		<prop key="hibernate.cache.use_query_cache">true</prop>
</#if>
			</props>
		</property>
		<property name="dataSource" >
			<ref local="dataSource" />
		</property>
		<property name="annotatedClasses" >
			<list>
				<value>${fqClassName}</value>
			</list>
		</property>
	</bean>
	
	<bean id="${entityName}Dao" class="${packageName}.${className}DaoSpringImpl">
		<property name="hibernateTemplate" >
			<bean class="org.springframework.orm.hibernate3.HibernateTemplate">
				<constructor-arg>
					<ref local="sessionFactory" />
				</constructor-arg>
			</bean>
		</property>
	</bean>

	<bean id="transactionManager" class="org.springframework.orm.hibernate3.HibernateTransactionManager">
		<property name="sessionFactory">
			<ref local="sessionFactory" />
		</property>
	</bean>
	
	<tx:advice id="transactionInterceptor" transaction-manager="transactionManager">
		<tx:attributes>
			<tx:method name="find*" read-only="true" rollback-for="Throwable"/>
			<tx:method name="like*" read-only="true" rollback-for="Throwable"/>
			<tx:method name="create" rollback-for="Throwable"/>
			<tx:method name="delete" rollback-for="Throwable"/>
			<tx:method name="update" rollback-for="Throwable"/>
		</tx:attributes>
	</tx:advice>
	
	<aop:config>
		<aop:advisor 
			pointcut=" execution(* ${packageName}.*Impl.*(..))"
			advice-ref="transactionInterceptor"/>
	</aop:config>
	
</beans>
