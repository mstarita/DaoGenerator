<?xml version="1.0" encoding="UTF-8"?>
<web-app id="WebApp_ID" version="2.4" xmlns="http://java.sun.com/xml/ns/j2ee" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://java.sun.com/xml/ns/j2ee http://java.sun.com/xml/ns/j2ee/web-app_2_4.xsd">
	<display-name>${className} RestWS ${restFormat}</display-name>
	<welcome-file-list>
		<welcome-file>index.html</welcome-file>
		<welcome-file>index.htm</welcome-file>
		<welcome-file>index.jsp</welcome-file>
		<welcome-file>default.html</welcome-file>
		<welcome-file>default.htm</welcome-file>
		<welcome-file>default.jsp</welcome-file>
	</welcome-file-list>
	
	<context-param>
		<param-name>resteasy.servlet.mapping.prefix</param-name>
		<param-value>/rest</param-value>
	</context-param>
	
	<servlet>
        <servlet-name>resteasy-servlet</servlet-name>
        <servlet-class>
            org.jboss.resteasy.plugins.server.servlet.HttpServletDispatcher
        </servlet-class>
        <init-param>
			<param-name>javax.ws.rs.Application</param-name>
			<param-value>${packageName}.${className}Application</param-value>
		</init-param>
		<load-on-startup>1</load-on-startup>
    </servlet>
  
    <servlet-mapping>
        <servlet-name>resteasy-servlet</servlet-name>
        <url-pattern>/rest/*</url-pattern>
    </servlet-mapping>

<#if generateSwaggerUi>
    <servlet>
		<servlet-name>DefaultJaxrsConfig</servlet-name>
		<servlet-class>com.wordnik.swagger.jaxrs.config.DefaultJaxrsConfig</servlet-class>
		<init-param>
			<param-name>api.version</param-name>
			<param-value>1.0.0</param-value>
		</init-param>
		<init-param>
			<param-name>swagger.api.basepath</param-name>
			<param-value>http://${host}:${port}/${warName}/rest</param-value>
		</init-param>
		<load-on-startup>2</load-on-startup>
	</servlet>
</#if>
    
</web-app>
