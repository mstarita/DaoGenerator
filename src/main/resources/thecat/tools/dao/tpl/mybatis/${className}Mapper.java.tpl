package ${packageName}.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Delete;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;
import org.apache.ibatis.session.RowBounds;

<#list importList as import>
import ${import};
</#list>

public interface ${className}Mapper extends GenericMapper<${className}, ${keyFieldType}> {

	@Override
	${className} findById(Long id);

	@Override
	List<${className}> findAll(
			@Param(value="orderBy") String orderBy, 
			@Param(value="desc") Boolean desc);
	
	@Override
	List<${className}> findAll(
			@Param(value="orderBy") String orderBy, 
			@Param(value="desc") Boolean desc, 
			RowBounds rowBounds);
		
	List<${className}> findBy(
			@Param(value="${entityName}") ${className} ${entityName}, 
			@Param(value="orderBy") String orderBy,
			@Param(value="reverse") Boolean reverse,
			@Param(value="useLike") Boolean useLike,
			@Param(value="caseSensitive") Boolean caseSensitive);
	
	List<${className}> findBy(
			@Param(value="${entityName}") ${className} ${entityName}, 
			@Param(value="orderBy") String orderBy,
			@Param(value="reverse") Boolean reverse,
			@Param(value="useLike") Boolean useLike,
			@Param(value="caseSensitive") Boolean caseSensitive,
			RowBounds rowBounds);
	
	@Override
	@Select("SELECT COUNT(*) FROM ${entityName}")
	int countAll();
	
	int countBy(
			@Param(value="${entityName}") ${className} ${entityName}, 
			@Param(value="useLike") boolean useLike);

	@Override
<#if useDb == 'mysql' >
	void insert(${className} ${entityName});
<#elseif useDb == 'postgres' >
	${keyFieldType} insert(${className} ${entityName});
</#if>

	@Override
	void update(${className} ${entityName});
	
	@Override
	@Delete("DELETE FROM ${entityName} WHERE ${keyField} = <#noparse>#{</#noparse>${keyField}}")
	int delete(${className} ${entityName});

}
