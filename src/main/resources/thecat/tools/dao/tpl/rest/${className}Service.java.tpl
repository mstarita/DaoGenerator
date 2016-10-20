<#assign entityName=className?uncap_first>
package ${packageName};

import java.net.URI;
import java.util.List;

import javax.ws.rs.Consumes;
import javax.ws.rs.DELETE;
import javax.ws.rs.DefaultValue;
import javax.ws.rs.GET;
import javax.ws.rs.POST;
import javax.ws.rs.PUT;
import javax.ws.rs.Path;
import javax.ws.rs.PathParam;
import javax.ws.rs.Produces;
import javax.ws.rs.QueryParam;
import javax.ws.rs.WebApplicationException;
import javax.ws.rs.core.Context;
import javax.ws.rs.core.Response;
import javax.ws.rs.core.UriInfo;

import ${packageName}.${className}Dao;
import ${packageName}.${className}DaoImpl;
<#list importList as import>
import ${import};
</#list>

<#if generateSwaggerUi >
import com.wordnik.swagger.annotations.Api;
import com.wordnik.swagger.annotations.ApiModel;
import com.wordnik.swagger.annotations.ApiOperation;
import com.wordnik.swagger.annotations.ApiParam;
import com.wordnik.swagger.annotations.ApiResponse;
</#if>

<#if generateSwaggerUi >
@Api(value="/${entityName}", description = "Operations about ${entityName}")
@Path("/${entityName}")
</#if>
public class ${className}Service {
	
	private ${className}Dao ${entityName}Dao = new ${className}DaoImpl();
	
	// findby${keyField}
	@GET
	@Path("{${keyField}}")
	<#if restFormat == "json+xml" >
	@Produces({ "application/json", "application/xml" })
	<#else>
	@Produces("application/${restFormat}")
	</#if>
	<#if generateSwaggerUi >@ApiOperation(value = "Find ${entityName} by ${keyField}")</#if>
	public ${className} get${className}By${keyField?cap_first}(
		<#if generateSwaggerUi >@ApiParam(value = "${keyField?cap_first} of ${entityName} that needs to be fetched", required = true)</#if>
			@PathParam("${keyField}") String ${keyField}) {
	
		System.out.println("find ${entityName} by ${keyField} " + ${keyField});

		Long ${entityName}${keyField?cap_first} = null;
		${className} ${entityName} = null;
		
		try {
<#if keyFieldType == "Long" >
			${entityName}${keyField?cap_first} = Long.parseLong(${keyField});
<#else>
			${entityName}${keyField?cap_first} = ${keyField};
</#if>
		} catch (NumberFormatException nfex) {
			nfex.printStackTrace();
			System.out.println(nfex.getMessage());
			
			throw new WebApplicationException(Response.Status.BAD_REQUEST);
		}
		
		try {
			${entityName} = ${entityName}Dao.findBy${keyField?cap_first}(${entityName}${keyField?cap_first});
		} catch (Exception ex) {
			ex.printStackTrace();
			System.out.println("findBy${keyField} exception: " + ex.getMessage());
			
			throw new WebApplicationException(Response.Status.INTERNAL_SERVER_ERROR);
		}
		
		if (${entityName} != null) {
			return ${entityName};
		} else {
			throw new WebApplicationException(Response.Status.NOT_FOUND);
		}
	}
	
	// findby
	@GET
	<#if restFormat == "json+xml" >
	@Produces({ "application/json", "application/xml" })
	<#else>
	@Produces("application/${restFormat}")
	</#if>
	<#if generateSwaggerUi >@ApiOperation(value = "Find ${entityName} by parameters")</#if>
	public List<${className}> get${className}WithQueryParams(
			<#if generateSwaggerUi >@ApiParam(value = "Order by ${entityName} field", allowableValues= "<#list fieldList as field>${field.fieldName}<#if field != fieldList[fieldList?size - 1]>, </#if></#list>", required = false)</#if>
				@QueryParam("orderby") String orderBy,
			<#if generateSwaggerUi >@ApiParam(value = "Direction of order", allowableValues= "true, false", defaultValue="true", required = false)</#if>
				@QueryParam("asc") @DefaultValue("true") boolean ascending,
			<#if generateSwaggerUi >@ApiParam(value = "Use of case sensitive or not", allowableValues= "true, false", defaultValue="true", required = false)</#if>
				@QueryParam("caseSensitive") @DefaultValue("true") boolean caseSensitive,
			<#if generateSwaggerUi >@ApiParam(value = "Use like as file match style (wildcard is %)", allowableValues= "true, false", defaultValue="false", required = false)</#if>
				@QueryParam("useLike") @DefaultValue("false") boolean useLike,
			<#if generateSwaggerUi >@ApiParam(value = "Start rows of paged result", defaultValue="-1", required = false)</#if>
				@QueryParam("startRow") @DefaultValue("-1") long startRow,
			<#if generateSwaggerUi >@ApiParam(value = "Number of row of paged result", defaultValue= "-1", required = false)</#if>	
				@QueryParam("pageSize") @DefaultValue("-1") long pageSize,
			@Context UriInfo info) {

		System.out.println("findby ${entityName}...");
		 
		List<${className}> ${entityName}List;
		
		${className} ${entityName} = new ${className}();
<#list fieldList as field>
	<#if keyField != field.fieldName>
		${entityName}.set${field.fieldName?cap_first}(info.getQueryParameters().getFirst("${field.fieldName}"));
	<#else>
		<#if field.fieldType == "Long">
		if (info.getQueryParameters().getFirst("${field.fieldName}") != null) {
			${entityName}.set${field.fieldName?cap_first}(Long.parseLong(info.getQueryParameters().getFirst("${field.fieldName}")));
		}
		<#else>
		${entityName}.set${field.fieldName?cap_first}(info.getQueryParameters().getFirst("${field.fieldName}"));
		</#if>
	</#if>
</#list>		

		try {
			if (orderBy != null) {
				if (!caseSensitive) {
					if (useLike) {
						if (ascending) {
							if (startRow != -1 && pageSize != -1){
								${entityName}List = ${entityName}Dao.likeByPagedNCSOrderBy(${entityName}, orderBy, startRow, pageSize);
							} else {
								${entityName}List = ${entityName}Dao.likeByNCSOrderBy(${entityName}, orderBy);
							}
						} else {
							if (startRow != -1 && pageSize != -1){
								${entityName}List = ${entityName}Dao.likeByPagedNCSOrderByDesc(${entityName}, orderBy, startRow, pageSize);
							} else {
								${entityName}List = ${entityName}Dao.likeByNCSOrderByDesc(${entityName}, orderBy);
							}
						}
					} else {
						if (ascending) {
							if (startRow != -1 && pageSize != -1){
								${entityName}List = ${entityName}Dao.findByPagedNCSOrderBy(${entityName}, orderBy, startRow, pageSize);
							} else {
								${entityName}List = ${entityName}Dao.findByNCSOrderBy(${entityName}, orderBy);
							}
						} else {
							if (startRow != -1 && pageSize != -1){
								${entityName}List = ${entityName}Dao.findByPagedNCSOrderByDesc(${entityName}, orderBy, startRow, pageSize);
							} else {
								${entityName}List = ${entityName}Dao.findByNCSOrderByDesc(${entityName}, orderBy);
							}
						}
					}
				} else {
					if (useLike) {
						if (ascending) {
							if (startRow != -1 && pageSize != -1){
								${entityName}List = ${entityName}Dao.likeByPagedOrderBy(${entityName}, orderBy, startRow, pageSize);
							} else {
								${entityName}List = ${entityName}Dao.likeByOrderBy(${entityName}, orderBy);
							}
						} else {
							if (startRow != -1 && pageSize != -1){
								${entityName}List = ${entityName}Dao.likeByPagedOrderByDesc(${entityName}, orderBy, startRow, pageSize);
							} else {
								${entityName}List = ${entityName}Dao.likeByOrderByDesc(${entityName}, orderBy);
							}
						}
					} else {
						if (ascending) {
							if (startRow != -1 && pageSize != -1){
								${entityName}List = ${entityName}Dao.findByPagedOrderBy(${entityName}, orderBy, startRow, pageSize);
							} else {
								${entityName}List = ${entityName}Dao.findByOrderBy(${entityName}, orderBy);
							}
						} else {
							if (startRow != -1 && pageSize != -1){
								${entityName}List = ${entityName}Dao.findByPagedOrderByDesc(${entityName}, orderBy, startRow, pageSize);
							} else {
								${entityName}List = ${entityName}Dao.findByOrderByDesc(${entityName}, orderBy);
							}
						}
					}
				}
			} else {
				if (!caseSensitive) {
					if (useLike) {
						if (startRow != -1 && pageSize != -1){
							${entityName}List = ${entityName}Dao.likeByPagedNCS(${entityName}, startRow, pageSize);
						} else {
							${entityName}List = ${entityName}Dao.likeByNCS(${entityName});
						}
					} else {
						if (startRow != -1 && pageSize != -1){
							${entityName}List = ${entityName}Dao.findByPagedNCS(${entityName}, startRow, pageSize);
						} else {
							${entityName}List = ${entityName}Dao.findByNCS(${entityName});
						}
					}
				} else {
					if (useLike) {
						if (startRow != -1 && pageSize != -1){
							${entityName}List = ${entityName}Dao.likeByPaged(${entityName}, startRow, pageSize);
						} else {
							${entityName}List = ${entityName}Dao.likeBy(${entityName});
						}
					} else {
						if (startRow != -1 && pageSize != -1){
							${entityName}List = ${entityName}Dao.findByPaged(${entityName}, startRow, pageSize);
						} else {
							${entityName}List = ${entityName}Dao.findBy(${entityName});
						}
					}
				}
			}
		} catch (Exception ex) {
			ex.printStackTrace();
			System.out.println("findBy exception: " + ex.getMessage());
			
			throw new WebApplicationException(Response.Status.INTERNAL_SERVER_ERROR);
		}
		
		if (${entityName}List != null && ${entityName}List.size() != 0) {
			return ${entityName}List;
		} else {
			throw new WebApplicationException(Response.Status.NOT_FOUND);
		}
	}
	 
	// create
	@POST
	<#if restFormat == "json+xml" >
	@Produces({ "application/json", "application/xml" })
	<#else>
	@Produces("application/${restFormat}")
	</#if>
	<#if generateSwaggerUi >@ApiOperation(value = "Creates a new ${entityName}")</#if>
	public Response create(
		<#if generateSwaggerUi >@ApiParam(value = "The new ${entityName} to be added", required = true)</#if> ${className} ${entityName}) {
		
		System.out.println("creating new ${entityName}...");
		 
		try {
			${entityName}Dao.create(${entityName});
			 
			return Response.created(URI.create("${entityName}/" + ${entityName}.get${keyField?cap_first}())).build();
		} catch (Exception ex) {
			ex.printStackTrace();
			System.out.println("create exception: " + ex.getMessage());
			 
			throw new WebApplicationException(Response.Status.INTERNAL_SERVER_ERROR);
		}
	}
	 
	// update
	@PUT
	<#if restFormat == "json+xml" >
	@Produces({ "application/json", "application/xml" })
	<#else>
	@Produces("application/${restFormat}")
	</#if>
	<#if generateSwaggerUi >@ApiOperation(value = "Update ${entityName} by ${keyField}")</#if>
	public Response update( 
			<#if generateSwaggerUi >@ApiParam(value = "${className} details", required = true)</#if> ${className} ${entityName}) {
		 
		System.out.println("updating ${entityName}...");
		 
		try {
			${entityName}Dao.update(${entityName});
			 	 
			return Response.ok().entity(${entityName}).build();
			
		} catch (Exception ex) {
			ex.printStackTrace();
			System.out.println("update exception: " + ex.getMessage());
			 
			throw new WebApplicationException(Response.Status.INTERNAL_SERVER_ERROR);
		}
	}
	 
	// delete
	@DELETE
	@Path("{${keyField}}")
	<#if generateSwaggerUi >@ApiOperation(value = "Delete ${entityName} by ${keyField}")</#if>
	public Response delete(
		<#if generateSwaggerUi >@ApiParam(value = "${keyField} of ${entityName} to delete", required = true)</#if>
			@PathParam("${keyField}") String ${keyField}) {
		 
		System.out.println("deleting ${entityName} with ${keyField} " + ${keyField});
		 
		${className} ${entityName} = new ${className}();
<#if keyFieldType == "Long" >
		${entityName}.set${keyField?cap_first}(Long.parseLong(${keyField}));
<#else>
		${entityName}.set${keyField?cap_first}(${keyField});
</#if>		 
		try {
			${entityName}Dao.delete(${entityName});
			return Response.ok().entity(${entityName}).build();
		} catch (Exception ex) {
			ex.printStackTrace();
			System.out.println("delete exception: " + ex.getMessage());
			 
			throw new WebApplicationException(Response.Status.INTERNAL_SERVER_ERROR);
		}
	}
}
