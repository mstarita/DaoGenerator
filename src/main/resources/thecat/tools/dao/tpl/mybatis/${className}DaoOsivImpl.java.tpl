package ${packageName};

import java.util.List;

import org.apache.ibatis.session.RowBounds;

import ${packageName}.mapper.${className}Mapper;

<#list importList as import>
import ${import};
</#list>

public class ${className}DaoImpl extends GenericDaoImpl<${className}, ${keyFieldType}> implements ${className}Dao {

	public ${className}DaoImpl() {
		super(${className}.class, ${className}Mapper.class);
	}
	
	<#if !isAbstract >
	<#list fieldList as field>
		<#if keyField != field.fieldName>
	private List<${className}> findBy${field.fieldName?cap_first}(${field.fieldType} ${field.fieldName}, String orderBy, Boolean desc, boolean useLike, boolean caseSensitive) {
		${className} ${entityName} = new ${className}();
		${entityName}.set${field.fieldName?cap_first}(${field.fieldName});
		
		return findBy(${entityName}, orderBy, desc, useLike, caseSensitive);
	}

	@Override
	public List<${className}> findBy${field.fieldName?cap_first}(${field.fieldType} ${field.fieldName}) {
		if (${field.fieldName} == null) {
			throw new IllegalArgumentException("The ${field.fieldName} parameter cannot be null");
		}
		
		return findBy${field.fieldName?cap_first}(${field.fieldName}, null, null, false, true);
	}
	
	@Override
	public List<${className}> findBy${field.fieldName?cap_first}OrderBy(${field.fieldType} ${field.fieldName}, String orderBy) {
		if (${field.fieldName} == null || orderBy == null) {
			throw new IllegalArgumentException("The ${field.fieldName} and orderBy parameter cannot be null");
		}
		
		return findBy${field.fieldName?cap_first}(${field.fieldName}, orderBy, false, false, true);
	}
	
	@Override
	public List<${className}> findBy${field.fieldName?cap_first}OrderByDesc(${field.fieldType} ${field.fieldName}, String orderBy) {
		if (${field.fieldName} == null || orderBy == null) {
			throw new IllegalArgumentException("The ${field.fieldName} and orderBy parameter cannot be null");
		}
		
		return findBy${field.fieldName?cap_first}(${field.fieldName}, orderBy, true, false, true);
	}
			<#if field.fieldType == "String">
	@Override
	public List<${className}> findBy${field.fieldName?cap_first}NCS(${field.fieldType} ${field.fieldName}) {
		if (${field.fieldName} == null) {
			throw new IllegalArgumentException("The ${field.fieldName} parameter cannot be null");
		}
		
		return findBy${field.fieldName?cap_first}(${field.fieldName}, null, null, false, false);
	}
	
	@Override
	public List<${className}> findBy${field.fieldName?cap_first}NCSOrderBy(${field.fieldType} ${field.fieldName}, String orderBy) {
		if (${field.fieldName} == null || orderBy == null) {
			throw new IllegalArgumentException("The ${field.fieldName} and orderBy parameter cannot be null");
		}
		
		return findBy${field.fieldName?cap_first}(${field.fieldName}, orderBy, false, false, false);
	}
	
	@Override
	public List<${className}> findBy${field.fieldName?cap_first}NCSOrderByDesc(${field.fieldType} ${field.fieldName}, String orderBy) {
		if (${field.fieldName} == null || orderBy == null) {
			throw new IllegalArgumentException("The ${field.fieldName} and orderBy parameter cannot be null");
		}
		
		return findBy${field.fieldName?cap_first}(${field.fieldName}, orderBy, true, false, false);
	}
	
	@Override
	public List<${className}> likeBy${field.fieldName?cap_first}(${field.fieldType} ${field.fieldName}) {
		if (${field.fieldName} == null) {
			throw new IllegalArgumentException("The ${field.fieldName} parameter cannot be null");
		}
		
		return findBy${field.fieldName?cap_first}(${field.fieldName}, null, null, true, true);
	}
	
	@Override
	public List<${className}> likeBy${field.fieldName?cap_first}OrderBy(${field.fieldType} ${field.fieldName}, String orderBy) {
		if (${field.fieldName} == null || orderBy == null) {
			throw new IllegalArgumentException("The ${field.fieldName} and orderBy parameter cannot be null");
		}
		
		return findBy${field.fieldName?cap_first}(${field.fieldName}, orderBy, false, true, true);
	}
	
	@Override
	public List<${className}> likeBy${field.fieldName?cap_first}OrderByDesc(${field.fieldType} ${field.fieldName}, String orderBy) {
		if (${field.fieldName} == null || orderBy == null) {
			throw new IllegalArgumentException("The ${field.fieldName} and orderBy parameter cannot be null");
		}
		
		return findBy${field.fieldName?cap_first}(${field.fieldName}, orderBy, true, true, true);
	}
	
	@Override
	public List<${className}> likeBy${field.fieldName?cap_first}NCS(${field.fieldType} ${field.fieldName}) {
		if (${field.fieldName} == null) {
			throw new IllegalArgumentException("The ${field.fieldName} parameter cannot be null");
		}
		
		return findBy${field.fieldName?cap_first}(${field.fieldName}, null, null, true, false);
	}
	
	@Override
	public List<${className}> likeBy${field.fieldName?cap_first}NCSOrderBy(${field.fieldType} ${field.fieldName}, String orderBy) {
		if (${field.fieldName} == null || orderBy == null) {
			throw new IllegalArgumentException("The ${field.fieldName} and orderBy parameter cannot be null");
		}
		
		return findBy${field.fieldName?cap_first}(${field.fieldName}, orderBy, false, true, false);
	}
	
	@Override
	public List<${className}> likeBy${field.fieldName?cap_first}NCSOrderByDesc(${field.fieldType} ${field.fieldName}, String orderBy) {
		if (${field.fieldName} == null || orderBy == null) {
			throw new IllegalArgumentException("The ${field.fieldName} and orderBy parameter cannot be null");
		}
		
		return findBy${field.fieldName?cap_first}(${field.fieldName}, orderBy, true, true, false);
	}
			</#if>
		
		</#if>
	</#list>
</#if>
	
	private List<${className}> findBy(${className} ${entityName}, String orderBy, Boolean reverse, boolean useLike, boolean caseSensitive) {
		return findBy(${entityName}, orderBy, reverse, useLike, caseSensitive, -1, -1);
	}
	
	private List<${className}> findBy(${className} ${entityName}, long startRow, long pageSize) {
		return findBy(${entityName}, null, null, false, true, startRow, pageSize);
	}
	
	@SuppressWarnings("unchecked")
	private List<${className}> findBy(${className} ${entityName}, String orderBy, Boolean reverse, boolean useLike, boolean caseSensitive, long startRow, long pageSize) {
		if (${entityName} == null) {
			throw new IllegalArgumentException("The ${entityName} parameter cannot be null");
		}
		
		List<${className}> ${entityName}List = null;
		
		${className}Mapper mapper = getSession().getMapper(${className}Mapper.class);
		if (startRow != -1 && pageSize != -1) {
			RowBounds rowBounds = new RowBounds(startRow, pageSize);
			${entityName}List = mapper.findBy(${entityName}, orderBy, reverse, useLike, caseSensitive, rowBounds);
		} else {
			${entityName}List = mapper.findBy(${entityName}, orderBy, reverse, useLike, caseSensitive);
		}
		
		return ${entityName}List;
	}
	
	@Override
	public List<${className}> findBy(${className} ${entityName}) {
		return findBy(${entityName}, null, null, false, true);
	}
	
	@Override
	public List<${className}> findByOrderBy(${className} ${entityName}, String orderBy) {
		if (orderBy == null) {
			throw new IllegalArgumentException("The orderBy parameter cannot be null");
		}
		
		return findBy(${entityName}, orderBy, false, false, true);
	}

	@Override
	public List<${className}> findByOrderByDesc(${className} ${entityName}, String orderBy) {
		if (orderBy == null) {
			throw new IllegalArgumentException("The orderBy parameter cannot be null");
		}
		
		return findBy(${entityName}, orderBy, true, false, true);
	}
	
	@Override
	public List<${className}> findByNCS(${className} ${entityName}) {
		return findBy(${entityName}, null, null, false, false);
	}

	@Override
	public List<${className}> findByNCSOrderBy(${className} ${entityName}, String orderBy) {
		if (orderBy == null) {
			throw new IllegalArgumentException("The orderBy parameter cannot be null");
		}
		
		return findBy(${entityName}, orderBy, false, false, false);
	}

	@Override
	public List<${className}> findByNCSOrderByDesc(${className} ${entityName}, String orderBy) {
		if (orderBy == null) {
			throw new IllegalArgumentException("The orderBy parameter cannot be null");
		}
		
		return findBy(${entityName}, orderBy, true, false, false);
	}
	
	@Override
	public List<${className}> findByPaged(${className} ${entityName}, long startRow, long pageSize) {
		return findBy(${entityName}, startRow, pageSize);
	}
	
	@Override
	public List<${className}> findByPagedNCS(${className} ${entityName}, long startRow, long pageSize) {
		return findBy(${entityName}, null, null, false, false, startRow, pageSize);
	}

	@Override
	public List<${className}> findByPagedNCSOrderBy(${className} ${entityName}, String orderBy,
			long startRow, long pageSize) {
		if (orderBy == null) {
			throw new IllegalArgumentException("The orderBy parameter cannot be null");
		}
		
		return findBy(${entityName}, orderBy, false, false, false, startRow, pageSize);
	}

	@Override
	public List<${className}> findByPagedNCSOrderByDesc(${className} ${entityName},
			String orderBy, long startRow, long pageSize) {
		if (orderBy == null) {
			throw new IllegalArgumentException("The orderBy parameter cannot be null");
		}
		
		return findBy(${entityName}, orderBy, true, false, false, startRow, pageSize);
	}

	@Override
	public List<${className}> findByPagedOrderBy(${className} ${entityName}, String orderBy,
			long startRow, long pageSize) {
		if (orderBy == null) {
			throw new IllegalArgumentException("The orderBy parameter cannot be null");
		}
		
		return findBy(${entityName}, orderBy, false, false, true, startRow, pageSize);
	}

	@Override
	public List<${className}> findByPagedOrderByDesc(${className} ${entityName}, String orderBy,
			long startRow, long pageSize) {
		if (orderBy == null) {
			throw new IllegalArgumentException("The orderBy parameter cannot be null");
		}
		
		return findBy(${entityName}, orderBy, true, false, true, startRow, pageSize);
	}
	
	@Override
	public List<${className}> likeBy(${className} ${entityName}) {
		return findBy(${entityName}, null, null, true, true);
	}
	
	@Override
	public List<${className}> likeByOrderBy(${className} ${entityName}, String orderBy) {
		if (orderBy == null) {
			throw new IllegalArgumentException("The orderBy parameter cannot be null");
		}
		
		return findBy(${entityName}, orderBy, false, true, true);
	}

	@Override
	public List<${className}> likeByOrderByDesc(${className} ${entityName}, String orderBy) {
		if (orderBy == null) {
			throw new IllegalArgumentException("The orderBy parameter cannot be null");
		}
		
		return findBy(${entityName}, orderBy, true, true, true);
	}
	
	@Override
	public List<${className}> likeByNCS(${className} ${entityName}) {
		return findBy(${entityName}, null, null, true, false);
	}

	@Override
	public List<${className}> likeByNCSOrderBy(${className} ${entityName}, String orderBy) {
		if (orderBy == null) {
			throw new IllegalArgumentException("The orderBy parameter cannot be null");
		}
		
		return findBy(${entityName}, orderBy, false, true, false);
	}

	@Override
	public List<${className}> likeByNCSOrderByDesc(${className} ${entityName}, String orderBy) {
		if (orderBy == null) {
			throw new IllegalArgumentException("The orderBy parameter cannot be null");
		}
		
		return findBy(${entityName}, orderBy, true, true, false);
	}

	@Override
	public List<${className}> likeByPaged(${className} ${entityName}, long startRow, long pageSize) {
		return findBy(${entityName}, null, null, true, true, startRow, pageSize);
	}
	
	@Override
	public List<${className}> likeByPagedNCS(${className} ${entityName}, long startRow, long pageSize) {
		return findBy(${entityName}, null, null, true, false, startRow, pageSize);
	}

	@Override
	public List<${className}> likeByPagedNCSOrderBy(${className} ${entityName}, String orderBy,
			long startRow, long pageSize) {
		if (orderBy == null) {
			throw new IllegalArgumentException("The orderBy parameter cannot be null");
		}
		
		return findBy(${entityName}, orderBy, false, true, false, startRow, pageSize);
	}

	@Override
	public List<${className}> likeByPagedNCSOrderByDesc(${className} ${entityName},
			String orderBy, long startRow, long pageSize) {
		if (orderBy == null) {
			throw new IllegalArgumentException("The orderBy parameter cannot be null");
		}
		
		return findBy(${entityName}, orderBy, true, true, false, startRow, pageSize);
	}

	@Override
	public List<${className}> likeByPagedOrderBy(${className} ${entityName}, String orderBy,
			long startRow, long pageSize) {
		if (orderBy == null) {
			throw new IllegalArgumentException("The orderBy parameter cannot be null");
		}
		
		return findBy(${entityName}, orderBy, false, true, true, startRow, pageSize);
	}

	@Override
	public List<${className}> likeByPagedOrderByDesc(${className} ${entityName}, String orderBy,
			long startRow, long pageSize) {
		if (orderBy == null) {
			throw new IllegalArgumentException("The orderBy parameter cannot be null");
		}
		
		return findBy(${entityName}, orderBy, true, true, true, startRow, pageSize);
	}
	
	private long countBy(${className} ${entityName}, boolean useLike) {
		if (${entityName} == null) {
			throw new IllegalArgumentException("The ${entityName} parameter cannot be null");
		}
		
		long rowCount = 0;
		
		
		${className}Mapper mapper = getSession().getMapper(${className}Mapper.class);
		rowCount = mapper.countBy(${entityName}, useLike);	
		
		return rowCount;
	}

	@Override
	public long countBy(${className} ${entityName}) {
		return countBy(${entityName}, false);
	}
	
	@Override
	public long countByLike(${className} ${entityName}) {
		return countBy(${entityName}, true);
	}

}
