<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE configuration PUBLIC "-//mybatis.org//DTD Config 3.0//EN" "http://mybatis.org/dtd/mybatis-3-config.dtd">
<configuration>
	<environments default="development">
		
		<environment id="development">
			<transactionManager type="JDBC"/>
			<dataSource type="POOLED">
<#if useDb == 'mysql' >
				<property name="driver" value="com.mysql.jdbc.Driver"/>
				<property name="url" value="jdbc:mysql://localhost/mybatis"/>
				<property name="username" value="user"/>
				<property name="password" value="password"/>
</#if>

<#if useDb == 'postgres' >
				<property name="driver" value="org.postgresql.Driver"/>
				<property name="url" value="jdbc:postgresql://localhost/mybatis"/>
				<property name="username" value="user"/>
				<property name="password" value="password"/>
</#if>
								
			</dataSource>
		</environment>
		
		<environment id="production">
			<transactionManager type="JDBC"/>
			<dataSource type="POOLED">
<#if useDb == 'mysql' >
				<property name="driver" value="com.mysql.jdbc.Driver"/>
				<property name="url" value="jdbc:mysql://localhost/mybatis"/>
				<property name="username" value="user"/>
				<property name="password" value="password"/>
</#if>

<#if useDb == 'postgres' >
				<property name="driver" value="org.postgresql.Driver"/>
				<property name="url" value="jdbc:postgresql://localhost/mybatis"/>
				<property name="username" value="user"/>
				<property name="password" value="password"/>
</#if>
								
			</dataSource>
		</environment>
		
	</environments>
	
 	<mappers>
		<mapper resource="${packageName?replace('.', '/')}/mapper/${className}Mapper-${useDb}.xml"/>
	</mappers>
	
</configuration>
