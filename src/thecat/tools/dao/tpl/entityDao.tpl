<#assign entityName=className?uncap_first>
<#function getAttributeName methodName>
	<#return methodName?substring(3, methodName?length)?uncap_first >
</#function>
package ${packageName};

import java.util.List;

<#list importList as import>
import ${import};
</#list>

public interface ${className}Dao extends GenericDaoExt<${className}, ${keyFieldType}> {

<#if !isAbstract >
	<#list fieldList as field>
		<#if keyField != field.fieldName>
	public List<${className}> findBy${field.fieldName?cap_first}(${field.fieldType} ${field.fieldName});
	public List<${className}> findBy${field.fieldName?cap_first}OrderBy(${field.fieldType} ${field.fieldName}, String orderBy);
	public List<${className}> findBy${field.fieldName?cap_first}OrderByDesc(${field.fieldType} ${field.fieldName}, String orderBy);
			<#if field.fieldType == "String">
	public List<${className}> findBy${field.fieldName?cap_first}NCS(${field.fieldType} ${field.fieldName});
	public List<${className}> findBy${field.fieldName?cap_first}NCSOrderBy(${field.fieldType} ${field.fieldName}, String orderBy);
	public List<${className}> findBy${field.fieldName?cap_first}NCSOrderByDesc(${field.fieldType} ${field.fieldName}, String orderBy);
	
	public List<${className}> likeBy${field.fieldName?cap_first}(${field.fieldType} ${field.fieldName});
	public List<${className}> likeBy${field.fieldName?cap_first}OrderBy(${field.fieldType} ${field.fieldName}, String orderBy);
	public List<${className}> likeBy${field.fieldName?cap_first}OrderByDesc(${field.fieldType} ${field.fieldName}, String orderBy);
	public List<${className}> likeBy${field.fieldName?cap_first}NCS(${field.fieldType} ${field.fieldName});
	public List<${className}> likeBy${field.fieldName?cap_first}NCSOrderBy(${field.fieldType} ${field.fieldName}, String orderBy);
	public List<${className}> likeBy${field.fieldName?cap_first}NCSOrderByDesc(${field.fieldType} ${field.fieldName}, String orderBy);
			</#if>
			
						
		</#if>
	</#list>
</#if>
	
}
