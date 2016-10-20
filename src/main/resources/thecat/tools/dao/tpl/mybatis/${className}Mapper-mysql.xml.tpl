<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE mapper PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN" 
"http://mybatis.org/dtd/mybatis-3-mapper.dtd">

<mapper namespace="${packageName}.mapper.${className}Mapper">

	<resultMap 
		id="findByResultMap"
		type="${fqClassName}" >
		<id property="${keyField}" column="${entityName}_${keyField}" />
		<#list fieldList as field>
			<#if keyField != field.fieldName>
				<#if field.fqFieldType?starts_with("java.lang.") && !field.fieldType?starts_with("List") && !field.fieldType?starts_with("Set") >
		<result property="${field.fieldName}" column="${entityName}_${field.fieldName}" />
				</#if>
			</#if>
		</#list>
		<#list fieldList as field>
			<#if keyField != field.fieldName>
				<#if field.fieldType?starts_with("List") || field.fieldType?starts_with("Set") >
					<#assign collectionType = field.fieldType?substring(field.fieldType?index_of("<") + 1, field.fieldType?index_of(">")) />
		<collection 
			property="${field.fieldName}"
			ofType="${field.fqFieldType?substring(field.fqFieldType?index_of("<") + 1, field.fqFieldType?index_of(">"))}" >
			<id property="${field.fieldId.fieldName}" column="${entityName}_${collectionType}_${field.fieldId.fieldName}" />			
					<#list field.fieldList as subField>
						<#if field.fieldId.fieldName != subField.fieldName>
			<result property="${subField.fieldName}" column="${entityName}_${collectionType}_${subField.fieldName}" />
						</#if>
					</#list>
		</collection>
				<#elseif !field.fqFieldType?starts_with("java.lang.") >
		<association 
			property="${field.fieldName}"
			column="${field.fieldName}_${field.fieldId.fieldName}"
			javaType="${field.fqFieldType}" >
			<id property="${field.fieldId.fieldName}" column="${entityName}_${field.fieldName}_${field.fieldId.fieldName}" />
					<#list field.fieldList as subField>
						<#if field.fieldId.fieldName != subField.fieldName>
			<result property="${subField.fieldName}" column="${entityName}_${field.fieldName}_${subField.fieldName}" />
						</#if>
					</#list>
		</association>	
				</#if>
			</#if>
		</#list>
	</resultMap>
	
	<select 
		id="findById" 
		parameterType="${keyFieldType}"
		resultMap="findByResultMap" >
		SELECT 
<#assign fieldCount = 1 />
<#list fieldList as field>
	<#if field.fieldType?starts_with("List") || field.fieldType?starts_with("Set") >
		<#list field.fieldList as subField>
			<#assign subFieldType = field.fieldType?substring(field.fieldType?index_of("<") + 1, field.fieldType?index_of(">")) />
			<#if fieldCount != 1>, </#if>${subFieldType}.${subField.fieldName} as ${entityName}_${subFieldType}_${subField.fieldName}
			<#assign fieldCount = fieldCount + 1 />
		</#list>
	<#elseif !field.fqFieldType?starts_with("java.lang.") >
		<#list field.fieldList as subField>
			<#if fieldCount != 1>, </#if>${field.fieldType}.${subField.fieldName} as ${entityName}_${field.fieldType}_${subField.fieldName}
			<#assign fieldCount = fieldCount + 1 />
		</#list>
	<#else>
			<#if fieldCount != 1>, </#if>${entityName}.${field.fieldName} as ${entityName}_${field.fieldName}		
	</#if>
	<#assign fieldCount = fieldCount + 1 />
</#list> 
		FROM 
		${entityName}
<#assign fieldMatch = 0 />
<#list fieldList as field>
	<#if field.fieldType?starts_with("List") || field.fieldType?starts_with("Set") >
		<#assign fqCollectionType = field.fqFieldType?substring(field.fqFieldType?index_of("<") + 1, field.fqFieldType?index_of(">")) />
		<#if !fqCollectionType?starts_with("java.lang.") >
			<#assign collectionType = field.fieldType?substring(field.fieldType?index_of("<") + 1, field.fieldType?index_of(">")) />
			LEFT OUTER JOIN ${collectionType} ON ${entityName}.${keyField} = ${collectionType}.${entityName}_${keyField}
			<#assign fieldMatch = fieldMatch + 1 />
		</#if>
	<#elseif !field.fqFieldType?starts_with("java.lang.") >
		LEFT OUTER JOIN ${field.fieldType} ON ${entityName}.${field.fieldName}_${field.fieldId.fieldName} = ${field.fieldType?uncap_first}.${field.fieldId.fieldName}
		<#assign fieldMatch = fieldMatch + 1 />
	</#if>
</#list>
		<where>
			${entityName}.${keyField} = <#noparse>#{</#noparse>${keyField}}
		</where>
	</select>
	
	<select 
		id="findBy" 
		parameterType="${fqClassName}"
		resultMap="findByResultMap" >
		SELECT 
<#assign fieldCount = 1 />
<#list fieldList as field>
	<#if field.fieldType?starts_with("List") || field.fieldType?starts_with("Set") >
		<#list field.fieldList as subField>
			<#assign subFieldType = field.fieldType?substring(field.fieldType?index_of("<") + 1, field.fieldType?index_of(">")) />
			<#if fieldCount != 1>, </#if>${subFieldType}.${subField.fieldName} as ${entityName}_${subFieldType}_${subField.fieldName}
			<#assign fieldCount = fieldCount + 1 />
		</#list>
	<#elseif !field.fqFieldType?starts_with("java.lang.") >
		<#list field.fieldList as subField>
			<#if fieldCount != 1>, </#if>${field.fieldType}.${subField.fieldName} as ${entityName}_${field.fieldType}_${subField.fieldName}
			<#assign fieldCount = fieldCount + 1 />
		</#list>
	<#else>
			<#if fieldCount != 1>, </#if>${entityName}.${field.fieldName} as ${entityName}_${field.fieldName}		
	</#if>
	<#assign fieldCount = fieldCount + 1 />
</#list> 
		FROM 
		${entityName}
<#assign fieldMatch = 0 />
<#list fieldList as field>
	<#if field.fieldType?starts_with("List") || field.fieldType?starts_with("Set") >
		<#assign fqCollectionType = field.fqFieldType?substring(field.fqFieldType?index_of("<") + 1, field.fqFieldType?index_of(">")) />
		<#if !fqCollectionType?starts_with("java.lang.") >
			<#assign collectionType = field.fieldType?substring(field.fieldType?index_of("<") + 1, field.fieldType?index_of(">")) />
			LEFT OUTER JOIN ${collectionType} ON ${entityName}.${keyField} = ${collectionType}.${entityName}_${keyField}
			<#assign fieldMatch = fieldMatch + 1 />
		</#if>
	<#elseif !field.fqFieldType?starts_with("java.lang.") >
		LEFT OUTER JOIN ${field.fieldType} ON ${entityName}.${field.fieldName}_${field.fieldId.fieldName} = ${field.fieldType?uncap_first}.${field.fieldId.fieldName}
		<#assign fieldMatch = fieldMatch + 1 />
	</#if>
</#list>
		<where>
			<if test="useLike == false">
<#assign fieldCount = 1 />
<#list fieldList as field>
	<#if field.fieldType?starts_with("List") || field.fieldType?starts_with("Set") >
				<if test="${entityName}.${field.fieldName} != null and ${entityName}.${field.fieldName}.${field.fieldId.fieldName} != null" >
					<#assign subFieldType = field.fieldType?substring(field.fieldType?index_of("<") + 1, field.fieldType?index_of(">")) />
					<if test="caseSensitive == true">
						<#if fieldCount != 1>AND </#if>BINARY ${entityName}.${keyField} = <#noparse>#{</#noparse>${subFieldType}.${entityName}_${keyField}}
					</if>
					<if test="caseSensitive == false">
						<#if fieldCount != 1>AND </#if>${entityName}.${keyField} = <#noparse>#{</#noparse>${subFieldType}.${entityName}_${keyField}}
					</if>
				</if>
	<#elseif !field.fqFieldType?starts_with("java.lang.") >
				<if test="${entityName}.${field.fieldName} != null and ${entityName}.${field.fieldName}.${field.fieldId.fieldName} != null" >
					<if test="caseSensitive == true">
						<#if fieldCount != 1>AND </#if>BINARY ${entityName}.${field.fieldName}_${field.fieldId.fieldName} = <#noparse>#{</#noparse>${entityName}.${field.fieldName}.${field.fieldId.fieldName}}
					</if>
					<if test="caseSensitive == false">
						<#if fieldCount != 1>AND </#if>${entityName}.${field.fieldName}_${field.fieldId.fieldName} = <#noparse>#{</#noparse>${entityName}.${field.fieldName}.${field.fieldId.fieldName}}
					</if>
				</if>
	<#else>
				<if test="${entityName}.${field.fieldName} != null">
					<if test="caseSensitive == true">
						<#if fieldCount != 1>AND </#if>BINARY ${entityName}.${field.fieldName} = <#noparse>#{</#noparse>${entityName}.${field.fieldName}}
					</if>
					<if test="caseSensitive == false">
						<#if fieldCount != 1>AND </#if>${entityName}.${field.fieldName} = <#noparse>#{</#noparse>${entityName}.${field.fieldName}}
					</if>
				</if>
	</#if>
	<#assign fieldCount = fieldCount + 1 />
</#list>
			</if>
				
			<if test="useLike == true" >
<#assign fieldCount = 1 />
<#list fieldList as field>
	<#if field.fieldType?starts_with("List") || field.fieldType?starts_with("Set") >
				<if test="${entityName}.${field.fieldName} != null and ${entityName}.${field.fieldName}.${field.fieldId.fieldName} != null" >
					<#assign subFieldType = field.fieldType?substring(field.fieldType?index_of("<") + 1, field.fieldType?index_of(">")) />
					<if test="caseSensitive == true">
						<#if fieldCount != 1>AND </#if>BINARY ${entityName}.${keyField} LIKE <#noparse>#{</#noparse>${subFieldType}.${entityName}_${keyField}}
					</if>
					<if test="caseSensitive == false">
						<#if fieldCount != 1>AND </#if>${entityName}.${keyField} LIKE <#noparse>#{</#noparse>${subFieldType}.${entityName}_${keyField}}
					</if>					
				</if>
	<#elseif !field.fqFieldType?starts_with("java.lang.") >
				<if test="${entityName}.${field.fieldName} != null and ${entityName}.${field.fieldName}.${field.fieldId.fieldName} != null" >
					<if test="caseSensitive == true">
						<#if fieldCount != 1>AND </#if>BINARY ${entityName}.${field.fieldName}_${field.fieldId.fieldName} LIKE <#noparse>#{</#noparse>${entityName}.${field.fieldName}.${field.fieldId.fieldName}}
					</if>
					<if test="caseSensitive == false">
						<#if fieldCount != 1>AND </#if>${entityName}.${field.fieldName}_${field.fieldId.fieldName} LIKE <#noparse>#{</#noparse>${entityName}.${field.fieldName}.${field.fieldId.fieldName}}
					</if>
				</if>
	<#else>
				<if test="${entityName}.${field.fieldName} != null">
					<if test="caseSensitive == true">
						<#if fieldCount != 1>AND </#if>BINARY ${entityName}.${field.fieldName} LIKE <#noparse>#{</#noparse>${entityName}.${field.fieldName}}
					</if>
					<if test="caseSensitive == false">
						<#if fieldCount != 1>AND </#if>${entityName}.${field.fieldName} LIKE <#noparse>#{</#noparse>${entityName}.${field.fieldName}}
					</if>
				</if>
	</#if>
<#assign fieldCount = fieldCount + 1 />
</#list>
			</if>
		</where>
		
		<if test="orderBy != null" >
			ORDER BY <#noparse>${orderBy}</#noparse>
			<if test="reverse == true">
				DESC
			</if>
		</if>
	</select>
	
	<select 
		id="findAll" 
		resultType="${fqClassName}" >
		SELECT * FROM ${entityName}
		<if test="orderBy != null" >
			ORDER BY <#noparse>${orderBy}</#noparse>
			<if test="desc == true">
				DESC
			</if>
		</if>
	</select>
	
	<insert 
		id="insert" 
		parameterType="${fqClassName}"
		useGeneratedKeys="true" 
		keyProperty="${keyField}" >
		INSERT INTO ${entityName} (
			<#assign fieldCount = 1 />
			<#list fieldList as field>
				<#if keyField != field.fieldName>
					<#if !field.fieldType?starts_with("List") && !field.fieldType?starts_with("Set") >
						<#if !field.fqFieldType?starts_with("java.lang.") >
			<#if fieldCount != 1>, </#if>${field.fieldName}_${field.fieldId.fieldName}<#assign fieldCount = fieldCount +1 />
						<#else>
			<#if fieldCount != 1>, </#if>${field.fieldName}<#assign fieldCount = fieldCount +1 />
						</#if>
					</#if>
				</#if>
			</#list>)
		VALUES (
			<#assign fieldCount = 1 />
			<#list fieldList as field>
				<#if keyField != field.fieldName>
					<#if !field.fieldType?starts_with("List") && !field.fieldType?starts_with("Set") >
						<#if !field.fqFieldType?starts_with("java.lang.") >
			<#if fieldCount != 1>, </#if><#noparse>#{</#noparse>${field.fieldName}.${field.fieldId.fieldName}}<#assign fieldCount = fieldCount +1 />
						<#else>
			<#if fieldCount != 1>, </#if><#noparse>#{</#noparse>${field.fieldName}}<#assign fieldCount = fieldCount +1 />
						</#if>
					</#if>
				</#if>
			</#list>)
	</insert>
	
	<update 
		id="update" 
		parameterType="${fqClassName}" >
		UPDATE ${entityName} SET  
			<#assign fieldCount = 1 />
			<#list fieldList as field>
				<#if keyField != field.fieldName>
					<#if !field.fieldType?starts_with("List") && !field.fieldType?starts_with("Set") >
						<#if !field.fqFieldType?starts_with("java.lang.") >
			<#if fieldCount != 1>, </#if>${field.fieldName}_${field.fieldId.fieldName} = <#noparse>#{</#noparse>${field.fieldName}.${field.fieldId.fieldName}}<#assign fieldCount = fieldCount + 1 />
						<#else>
			<#if fieldCount != 1>, </#if>${field.fieldName} = <#noparse>#{</#noparse>${field.fieldName}}<#assign fieldCount = fieldCount + 1 />
						</#if>
					</#if>
				</#if>
			</#list>
		WHERE ${keyField} = <#noparse>#{</#noparse>${keyField}}
	</update>
	
	<select
		id="countBy"
		parameterType="${fqClassName}"
		resultType="int" >
		SELECT count(*) 
		FROM ${entityName}
		<where>
<#assign fieldCount = 1 />
<#list fieldList as field>		
			<if test="${entityName}.${field.fieldName} != null">
	<#if field.fieldType?starts_with("List") || field.fieldType?starts_with("Set") >
				<if test="${entityName}.${field.fieldName} != null and ${entityName}.${field.fieldName}.${field.fieldId.fieldName} != null" >
					<#assign subFieldType = field.fieldType?substring(field.fieldType?index_of("<") + 1, field.fieldType?index_of(">")) />
					<if test="useLike != true">
						<#if fieldCount != 1>AND </#if>BINARY ${entityName}.${keyField} = <#noparse>#{</#noparse>${subFieldType}.${entityName}_${keyField}}
					</if>
					<if test="useLike == true">
						<#if fieldCount != 1>AND </#if>BINARY ${entityName}.${keyField} LIKE <#noparse>#{</#noparse>${subFieldType}.${entityName}_${keyField}}
					</if>
				</if>
	<#elseif !field.fqFieldType?starts_with("java.lang.") >
				<if test="${entityName}.${field.fieldName} != null and ${entityName}.${field.fieldName}.${field.fieldId.fieldName} != null" >
					<if test="useLike != true">
						<#if fieldCount != 1>AND </#if>BINARY ${field.fieldName}_${field.fieldId.fieldName} = <#noparse>#{</#noparse>${entityName}.${field.fieldName}.${field.fieldId.fieldName}}
					</if>
					<if test="useLike == true">
						<#if fieldCount != 1>AND </#if>BINARY ${field.fieldName}_${field.fieldId.fieldName} LIKE <#noparse>#{</#noparse>${entityName}.${field.fieldName}.${field.fieldId.fieldName}}
					</if>
				</if>
	<#else>
				<if test="useLike != true" >
					<#if fieldCount != 1>AND </#if>BINARY ${field.fieldName} = <#noparse>#{</#noparse>${entityName}.${field.fieldName}}
				</if>
				<if test="useLike == true" >
					<#if fieldCount != 1>AND </#if>BINARY ${field.fieldName} LIKE <#noparse>#{</#noparse>${entityName}.${field.fieldName}}
				</if>
	</#if>
			</if>
<#assign fieldCount = fieldCount + 1 />
</#list>
		</where>
	</select>
	
</mapper>
