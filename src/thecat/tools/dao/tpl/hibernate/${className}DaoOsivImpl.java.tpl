<#assign entityName=className?uncap_first>
<#function getAttributeName methodName>
	<#return methodName?substring(3, methodName?length)?uncap_first >
</#function>
package ${packageName};

import java.util.List;

import org.hibernate.Criteria;
import org.hibernate.criterion.Order;
import org.hibernate.criterion.Projections;
import org.hibernate.criterion.Restrictions;
import org.hibernate.criterion.SimpleExpression;

<#list importList as import>
import ${import};
</#list>

public class ${className}DaoOsivImpl extends GenericDaoOsivImpl<${className}, ${keyFieldType}> implements ${className}Dao {

	public ${className}DaoOsivImpl() {
		super(${className}.class);
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
	
	private List<${className}> findBy(${className} ${entityName}, int startRow, int pageSize) {
		return findBy(${entityName}, null, null, false, true, startRow, pageSize);
	}
	
	@SuppressWarnings("unchecked")
	private List<${className}> findBy(${className} ${entityName}, String orderBy, Boolean reverse, boolean useLike, boolean caseSensitive, int startRow, int pageSize) {
		if (${entityName} == null) {
			throw new IllegalArgumentException("The ${entityName} parameter cannot be null");
		}
		
		List<${className}> ${entityName}List = null;
		Criteria criteria = getSession().createCriteria(${className}.class);

		if (startRow != -1) { criteria.setFirstResult(startRow); }
		if (pageSize != -1) { criteria.setMaxResults(pageSize); } 
			
<#list fieldList as field>
	<#if field.fieldType == "String">
		if (${entityName}.get${field.fieldName?cap_first}() != null && !${entityName}.get${field.fieldName?cap_first}().equals("")) {
			SimpleExpression criterion;
			if (useLike) {
				criterion = Restrictions.like("${field.fieldName}", ${entityName}.get${field.fieldName?cap_first}());
			} else {
				criterion = Restrictions.eq("${field.fieldName}", ${entityName}.get${field.fieldName?cap_first}());
			}
			
			if (!caseSensitive) {
				criterion.ignoreCase();
			}
			
			criteria.add(criterion);
		}
	<#else>
		if (${entityName}.get${field.fieldName?cap_first}() != null) {
		<#if field.fieldType?starts_with("List") || field.fieldType?starts_with("Set") >
			if (!${entityName}.get${field.fieldName?cap_first}().isEmpty()) {
				<#assign collectionType = field.fieldType?substring(field.fieldType?index_of("<") + 1, field.fieldType?index_of(">")) />
				Criteria collectionCriteria = criteria.createCriteria("${field.fieldName}");
				List<${field.fieldId.fieldType}> ids = new ArrayList<${field.fieldId.fieldType}>();
				for (${collectionType} item : ${entityName}.get${field.fieldName?cap_first}()) {
					if (item != null && item.get${field.fieldId.fieldName?cap_first}() != null) {
						ids.add(item.get${field.fieldId.fieldName?cap_first}());
					}
				}
				collectionCriteria.add(Restrictions.in("${field.fieldId.fieldName}", ids));
			}
		<#else>
			criteria.add(Restrictions.eq("${field.fieldName}", ${entityName}.get${field.fieldName?cap_first}()));
		</#if>
		}
	</#if>
	
</#list>

		if (orderBy != null) {
			if (reverse != null && reverse) {
				criteria.addOrder(Order.desc(orderBy));
			} else {
				criteria.addOrder(Order.asc(orderBy));
			}
		}

		criteria.setResultTransformer(Criteria.DISTINCT_ROOT_ENTITY);
		${entityName}List = criteria.list();
			
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
	public List<${className}> findByPaged(${className} ${entityName}, int startRow, int pageSize) {
		return findBy(${entityName}, startRow, pageSize);
	}
	
	@Override
	public List<${className}> findByPagedNCS(${className} ${entityName}, int startRow, int pageSize) {
		return findBy(${entityName}, null, null, false, false, startRow, pageSize);
	}

	@Override
	public List<${className}> findByPagedNCSOrderBy(${className} ${entityName}, String orderBy,
			int startRow, int pageSize) {
		if (orderBy == null) {
			throw new IllegalArgumentException("The orderBy parameter cannot be null");
		}
		
		return findBy(${entityName}, orderBy, false, false, false, startRow, pageSize);
	}

	@Override
	public List<${className}> findByPagedNCSOrderByDesc(${className} ${entityName},
			String orderBy, int startRow, int pageSize) {
		if (orderBy == null) {
			throw new IllegalArgumentException("The orderBy parameter cannot be null");
		}
		
		return findBy(${entityName}, orderBy, true, false, false, startRow, pageSize);
	}

	@Override
	public List<${className}> findByPagedOrderBy(${className} ${entityName}, String orderBy,
			int startRow, int pageSize) {
		if (orderBy == null) {
			throw new IllegalArgumentException("The orderBy parameter cannot be null");
		}
		
		return findBy(${entityName}, orderBy, false, false, true, startRow, pageSize);
	}

	@Override
	public List<${className}> findByPagedOrderByDesc(${className} ${entityName}, String orderBy,
			int startRow, int pageSize) {
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
	public List<${className}> likeByPaged(${className} ${entityName}, int startRow, int pageSize) {
		return findBy(${entityName}, null, null, true, true, startRow, pageSize);
	}
	
	@Override
	public List<${className}> likeByPagedNCS(${className} ${entityName}, int startRow, int pageSize) {
		return findBy(${entityName}, null, null, true, false, startRow, pageSize);
	}

	@Override
	public List<${className}> likeByPagedNCSOrderBy(${className} ${entityName}, String orderBy,
			int startRow, int pageSize) {
		if (orderBy == null) {
			throw new IllegalArgumentException("The orderBy parameter cannot be null");
		}
		
		return findBy(${entityName}, orderBy, false, true, false, startRow, pageSize);
	}

	@Override
	public List<${className}> likeByPagedNCSOrderByDesc(${className} ${entityName},
			String orderBy, int startRow, int pageSize) {
		if (orderBy == null) {
			throw new IllegalArgumentException("The orderBy parameter cannot be null");
		}
		
		return findBy(${entityName}, orderBy, true, true, false, startRow, pageSize);
	}

	@Override
	public List<${className}> likeByPagedOrderBy(${className} ${entityName}, String orderBy,
			int startRow, int pageSize) {
		if (orderBy == null) {
			throw new IllegalArgumentException("The orderBy parameter cannot be null");
		}
		
		return findBy(${entityName}, orderBy, false, true, true, startRow, pageSize);
	}

	@Override
	public List<${className}> likeByPagedOrderByDesc(${className} ${entityName}, String orderBy,
			int startRow, int pageSize) {
		if (orderBy == null) {
			throw new IllegalArgumentException("The orderBy parameter cannot be null");
		}
		
		return findBy(${entityName}, orderBy, true, true, true, startRow, pageSize);
	}
	
	// NOTICE the criteria generation can be merged with findby one
	private int countBy(${className} ${entityName}, boolean useLike) {
		if (${entityName} == null) {
			throw new IllegalArgumentException("The ${entityName} parameter cannot be null");
		}
		
		int rowCount = 0;
		
		Criteria criteria = getSession().createCriteria(${className}.class);

<#list fieldList as field>
	<#if field.fieldType == "String">
		if (${entityName}.get${field.fieldName?cap_first}() != null && !${entityName}.get${field.fieldName?cap_first}().equals("")) {
			SimpleExpression criterion;
			if (useLike) {
				criterion = Restrictions.like("${field.fieldName}", ${entityName}.get${field.fieldName?cap_first}());
			} else {
				criterion = Restrictions.eq("${field.fieldName}", ${entityName}.get${field.fieldName?cap_first}());
			}
			
			criteria.add(criterion);
		}
	<#else>
		if (${entityName}.get${field.fieldName?cap_first}() != null) {
		<#if field.fieldType?starts_with("List") || field.fieldType?starts_with("Set") >
			if (!${entityName}.get${field.fieldName?cap_first}().isEmpty()) {
				<#assign collectionType = field.fieldType?substring(field.fieldType?index_of("<") + 1, field.fieldType?index_of(">")) />
				Criteria collectionCriteria = criteria.createCriteria("${field.fieldName}");
				List<${field.fieldId.fieldType}> ids = new ArrayList<${field.fieldId.fieldType}>();
				for (${collectionType} item : ${entityName}.get${field.fieldName?cap_first}()) {
					if (item != null && item.get${field.fieldId.fieldName?cap_first}() != null) {
						ids.add(item.get${field.fieldId.fieldName?cap_first}());
					}
				}
				collectionCriteria.add(Restrictions.in("${field.fieldId.fieldName}", ids));
			}
		<#else>
			criteria.add(Restrictions.eq("${field.fieldName}", ${entityName}.get${field.fieldName?cap_first}()));
		</#if>
		}
	</#if>
	
</#list>	

		criteria.setResultTransformer(Criteria.DISTINCT_ROOT_ENTITY);
		criteria.setProjection(Projections.rowCount());
		rowCount = ((Long) criteria.uniqueResult()).intValue();
			
		return rowCount;
	}

	@Override
	public int countBy(${className} ${entityName}) {
		return countBy(${entityName}, false);
	}
	
	@Override
	public int countByLike(${className} ${entityName}) {
		return countBy(${entityName}, true);
	}

}
