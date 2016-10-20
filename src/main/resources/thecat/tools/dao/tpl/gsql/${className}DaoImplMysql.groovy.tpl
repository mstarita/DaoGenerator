package ${packageName}

import java.util.ArrayList;
import java.util.List;

import java.util.HashMap;
import java.util.Map;

<#list importList as import>
import ${import};
</#list>

class ${className}DaoImpl extends Dao implements ${className}Dao {

	private static final String entityName = "${entityName}"
	private static final String entityKey = "${keyField}"

	public ${className}DaoImpl() {
	}

	private ${className} setup${className}FromRow(row, ${entityName}Map=null) {
		${className} ${entityName}
		def keyRow = row.${entityName}_${keyField}
		boolean keyRowExists = false

		if (${entityName}Map != null) {		
			if (!${entityName}Map.containsKey(keyRow)) {
				${entityName} = new ${className}()
				${entityName}Map.put(keyRow, ${entityName})
			} else {
				${entityName} = ${entityName}Map.get(keyRow)
				keyRowExists = true
			}
		} else {
			if (keyRow != null) {
				${entityName} = new ${className}()
			}
		}

<#list fieldList as field>
	<#if field.fieldType?starts_with("List") || field.fieldType?starts_with("Set") >
		<#assign subFieldType = field.fieldType?substring(field.fieldType?index_of("<") + 1, field.fieldType?index_of(">")) />
		if (row.${entityName}_${subFieldType}_${field.fieldId.fieldName} != null) {
			if (${entityName}.${field.fieldName} == null) {
		<#if field.fieldType?starts_with("List")>
			${entityName}.${field.fieldName} = new ArrayList<${subFieldType}>()
		<#else>
			${entityName}.${field.fieldName} = new HashMap<${keyFieldType}, ${subFieldType}>()
		</#if>
			}
			${subFieldType} ${subFieldType?uncap_first} = new ${subFieldType}()
		<#if field.fieldType?starts_with("List")>
			${entityName}.${field.fieldName}.add(${subFieldType?uncap_first})
		<#else>
			${entityName}.${field.fieldName}.put(row.${entityName}_${field.fieldName}_${field.fieldId.fieldName}, ${subFieldType?uncap_first})
		</#if>
		<#list field.fieldList as subField>	
			${subFieldType?uncap_first}.${subField.fieldName} = row.${entityName}_${subFieldType}_${subField.fieldName}
		</#list>
		}
	<#elseif !field.fqFieldType?starts_with("java.lang.") >
		if (!keyRowExists) {
		<#list field.fieldList as subField>
			if (row.${entityName}_${field.fieldType}_${subField.fieldName} != null) {
				if (${entityName}.${field.fieldName} == null) {
					${entityName}.${field.fieldName} = new ${field.fieldType}()
				}
				${entityName}.${field.fieldName}.${subField.fieldName} = row.${entityName}_${field.fieldType}_${subField.fieldName}
			}
		</#list>
		}
		
	<#else>
		if (!keyRowExists) {
			${entityName}.${field.fieldName} = row.${entityName}_${field.fieldName}
		}		
	</#if>
</#list>
		
		${entityName}
	}
	
	private String generateSqlSelectFieldList() {
		
		"""
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
		"""
		
	}
	
	private String generateSqlSelectFrom() {
		"""
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
		"""
	}
	
	private String generateSqlSelectWhere(entity, sqlEqualOp, sqlCS) {
		
		def result = new StringBuilder()
		
		if (entity != null) {
<#list fieldList as field>
	<#if field.fieldType?starts_with("List") || field.fieldType?starts_with("Set") >
		if (entity.${field.fieldName} != null && entity.${field.fieldName}.${field.fieldId.fieldName} != null) {
			result.append("""
			<#assign subFieldType = field.fieldType?substring(field.fieldType?index_of("<") + 1, field.fieldType?index_of(">")) />
			<#noparse>${sqlCS}</#noparse> ${entityName}.${keyField} <#noparse> ${sqlEqualOp}</#noparse> \'${subFieldType}_${entityName}_${keyField}\' AND
				""")
			}
	<#elseif !field.fqFieldType?starts_with("java.lang.") >
			if (entity.${field.fieldName} != null && entity.${field.fieldName}.${field.fieldId.fieldName} != null) {
				result.append("<#noparse>${sqlCS}</#noparse> ${entityName}.${field.fieldName}_${field.fieldId.fieldName} <#noparse>${sqlEqualOp} \'${</#noparse>entity.${field.fieldName}.${field.fieldId.fieldName}}\' AND ")
			}
	<#else>
			if (entity.${field.fieldName} != null) {
				result.append("<#noparse>${sqlCS}</#noparse> ${entityName}.${field.fieldName} <#noparse>${sqlEqualOp} \'${</#noparse>entity.${field.fieldName}}\' AND ")
			}
	</#if>
</#list>
		}
		result.toString()
	}
	
	private String generateSqlSelectStatement(${className} ${entityName}, String orderBy, Boolean reverse, Boolean useLike, Boolean useCS,
			long startRow = -1, long pageSize = -1, boolean useCount = false) {

		def sqlStatement = new StringBuilder()
		
		if (useCount) {
			sqlStatement
				.append('SELECT COUNT(*) FROM ')
				.append(generateSqlSelectFrom())
		} else {
			sqlStatement
				.append('SELECT ')
					.append(generateSqlSelectFieldList())
				.append(' FROM ')
					.append(generateSqlSelectFrom())
		}
		
		def sqlCond = ''
		def sqlEqualOp = useLike ? ' LIKE ' : ' = '
		def sqlCS = useCS ? ' BINARY ' : ''

		if (${entityName} != null) {				
			sqlCond = generateSqlSelectWhere(${entityName}, sqlEqualOp, sqlCS)
			if (!sqlCond.isEmpty()) {
				sqlStatement.append(' WHERE ').append(sqlCond[0..-5])
			}
		}

		if (orderBy != null) {
			sqlStatement.append(' ORDER BY ').append(orderBy)
			if (reverse) {
				sqlStatement.append(' DESC')
			}
		}

		if (startRow != -1 && pageSize != -1) {
			sqlStatement += ' LIMIT ' + pageSize + ' OFFSET ' + startRow
		}

		sqlStatement
	}

	private List<${className}> _findAll(String orderBy, Boolean desc, long startRow, long pageSize) {
		List<${className}> entityList = null;
		try {
			entityList = new ArrayList<${className}>()

			def sqlStatement = generateSqlSelectStatement(null, orderBy, desc, false, false, startRow, pageSize)
			getSession().eachRow(sqlStatement) { row ->
				entityList << setup${className}FromRow(row)
			}
		} catch (Exception e) {
			throw new RuntimeException('Could not find the ${entityName}', e);
		} finally {
			close()
		}

		entityList;
	}

	@Override
	public List<${className}> findAll() {
		return _findAll(null, null, -1, -1)
	}

	@Override
	public List<${className}> findAllOrderBy(String orderBy) {
		if (orderBy == null) {
			throw new IllegalArgumentException('The orderBy parameter cannot be null, if sort order is not required use findAll() method instead')
		}

		return _findAll(orderBy, null, -1, -1)
	}

	@Override
	public List<${className}> findAllOrderByDesc(String orderBy) {
		if (orderBy == null) {
			throw new IllegalArgumentException('The orderBy parameter cannot be null, if sort order is not required use findAll() method instead')
		}

		return _findAll(orderBy, true, -1, -1)
	}

	@Override
	public List<${className}> findAllPaged(long startRow, long pageSize) {
		return _findAll(null, null, startRow, pageSize)
	}

	@Override
	public List<${className}> findAllPagedOrderBy(String orderBy, long startRow, long pageSize) {
		if (orderBy == null) {
			throw new IllegalArgumentException('The orderBy parameter cannot be null, if sort order is not required use findAllPaged() method instead')
		}

		return _findAll(orderBy, null, startRow, pageSize)
	}

	@Override
	public List<${className}> findAllPagedOrderByDesc(String orderBy, long startRow, long pageSize) {
		if (orderBy == null) {
			throw new IllegalArgumentException('The orderBy parameter cannot be null, if sort order is not required use findAllPaged() method instead')
		}

		return _findAll(orderBy, true, startRow, pageSize)
	}

	@Override
	public ${className} findById(Long id) {
		if (id == null) {
			throw new IllegalArgumentException('The id parameter cannot be null');
		}

		${className} entityFound
		${className} ${entityName} = new ${className}(${keyField}: id)
		def sqlStatement = generateSqlSelectStatement(${entityName}, null, false, false, false)
		def result = getSession().firstRow(sqlStatement)
		if (result != null) {
			entityFound = setup${className}FromRow(result)
		}

		entityFound
	}

	@Override
	public long countAll() {
		long rowCount = 0

		try {
			def sqlStatement = generateSqlSelectStatement(null, null, null, null, null, -1, -1, true)
			rowCount = getSession().firstRow(sqlStatement)[0]
		} catch (Exception e) {
			throw new RuntimeException('Could not count ${entityName}', e)
		} finally {
			close()
		}

		rowCount
	}

	@Override
	public ${className} create(${className} entity) {
		${className} result;

		if (entity == null) {
			throw new IllegalArgumentException('The entity parameter cannot be null');
		}

		try {
			getSession().cacheConnection { connection ->

				connection.autoCommit = false

				begin();
				def insertResult = getSession().executeInsert("""
					INSERT INTO ${entityName} (
<#assign fieldCount = 1 />
<#list fieldList as field>
	<#if keyField != field.fieldName>
		<#if !field.fieldType?starts_with("List") && !field.fieldType?starts_with("Set") >
			<#if field.fqFieldType?starts_with("java.lang.") >
				<#if fieldCount != 1>, </#if>${field.fieldName}<#assign fieldCount = fieldCount +1 />
			<#else>
				<#if fieldCount != 1>, </#if>${field.fieldName}_${field.fieldId.fieldName}<#assign fieldCount = fieldCount +1 />
			</#if>
		</#if>
	</#if>
</#list>)
					VALUES (
<#assign fieldCount = 1 />
<#list fieldList as field>
	<#if keyField != field.fieldName>
		<#if !field.fieldType?starts_with("List") && !field.fieldType?starts_with("Set") >
			<#if fieldCount != 1>, </#if>?<#assign fieldCount = fieldCount +1 />
		</#if>
	</#if>
</#list>)
					""", 
					[
<#assign fieldCount = 1 />
<#list fieldList as field>
	<#if keyField != field.fieldName>
		<#if !field.fieldType?starts_with("List") && !field.fieldType?starts_with("Set") >
			<#if field.fqFieldType?starts_with("java.lang.") >
				<#if fieldCount != 1>, </#if>entity.${field.fieldName}<#assign fieldCount = fieldCount +1 />
			<#else>
				<#if fieldCount != 1>, </#if>entity != null ? entity.${field.fieldName}.${field.fieldId.fieldName} : null<#assign fieldCount = fieldCount +1 />
			</#if>
		</#if>
	</#if>
</#list>					
					])

				if (insertResult != null) {
					entity.${keyField} = (${keyFieldType}) (insertResult[0][0])
				}
				result = entity

				commit()
			}
		} catch (Exception ex) {
			rollback()
			throw new RuntimeException('Could not create the entity', ex)
		} finally {
			getSession().cacheConnection { connection ->
				connection.autoCommit = true
			}

			close()
		}

		result
	}

	@Override
	public void update(${className} entity) {
		if (entity == null) {
			throw new IllegalArgumentException('The entity parameter cannot be null')
		}

		try {
			getSession().cacheConnection { connection ->
				connection.autoCommit = false

				begin()
				getSession().execute("""
					UPDATE ${entityName} SET 
<#assign fieldCount = 1 />
<#list fieldList as field>
	<#if keyField != field.fieldName>
		<#if !field.fieldType?starts_with("List") && !field.fieldType?starts_with("Set") >
			<#if field.fqFieldType?starts_with("java.lang.") >
				<#if fieldCount != 1>, </#if>${field.fieldName} = ?<#assign fieldCount = fieldCount + 1 />
			<#else>
				<#if fieldCount != 1>, </#if>${field.fieldName}_${field.fieldId.fieldName} = ?<#assign fieldCount = fieldCount +1 />
			</#if>
		</#if>
	</#if>
</#list>
					WHERE ${keyField} = ?
				""",
				[
<#assign fieldCount = 1 />				
<#list fieldList as field>
	<#if keyField != field.fieldName>
		<#if !field.fieldType?starts_with("List") && !field.fieldType?starts_with("Set") >
			<#if field.fqFieldType?starts_with("java.lang.") >
				<#if fieldCount != 1>, </#if>entity.${field.fieldName}<#assign fieldCount = fieldCount + 1 />
			<#else>
				<#if fieldCount != 1>, </#if>entity != null ? entity.${field.fieldName}.${field.fieldId.fieldName} : null<#assign fieldCount = fieldCount +1 />
			</#if>
		</#if>
	</#if>
</#list>				
				, entity.${keyField}])
				commit()
			}
		} catch (Exception ex) {
			rollback()
			throw new RuntimeException('Could not update the entity', ex)
		} finally {
			getSession().cacheConnection { connection ->
				connection.autoCommit = true
			}

			close()
		}
	}

	@Override
	public void delete(${className} entity) {
		if (entity == null) {
			throw new IllegalArgumentException('The entity parameter cannot be null');
		}

		int result = 0
		try {
			getSession().cacheConnection { connection ->
				connection.autoCommit = false

				begin()
				result = getSession().executeUpdate(
						"DELETE FROM ${entityName} WHERE ${keyField} = ?", [entity.${keyField}])
				commit()
			}
		} catch (Exception ex) {
			rollback()
			throw new RuntimeException('Could not delete the entity', ex)
		} finally {
			getSession().cacheConnection { connection ->
				connection.autoCommit = true
			}
			close()
			
			if (result == 0) {
				throw new RuntimeException("Entity with id <#noparse>${</#noparse>entity.${keyField}} not found.")
			}
		}
	}

<#if !isAbstract >
	<#list fieldList as field>
		<#if keyField != field.fieldName>
	private List<${className}> _findBy${field.fieldName?cap_first}(${field.fieldType} ${field.fieldName}, String orderBy, Boolean desc, boolean useLike, boolean caseSensitive) {
		${className} ${entityName} = new ${className}()
		${entityName}.set${field.fieldName?cap_first}(${field.fieldName})

		return _findBy(${entityName}, orderBy, desc, useLike, caseSensitive)
	}

	@Override
	public List<${className}> findBy${field.fieldName?cap_first}(${field.fieldType} ${field.fieldName}) {
		if (${field.fieldName} == null) {
			throw new IllegalArgumentException('The ${field.fieldName} parameter cannot be null')
		}

		return _findBy${field.fieldName?cap_first}(${field.fieldName}, null, null, false, true)
	}

	@Override
	public List<${className}> findBy${field.fieldName?cap_first}OrderBy(${field.fieldType} ${field.fieldName}, String orderBy) {
		if (${field.fieldName} == null || orderBy == null) {
			throw new IllegalArgumentException('The ${field.fieldName} and orderBy parameter cannot be null')
		}

		return _findBy${field.fieldName?cap_first}(${field.fieldName}, orderBy, false, false, true)
	}

	@Override
	public List<${className}> findBy${field.fieldName?cap_first}OrderByDesc(${field.fieldType} ${field.fieldName}, String orderBy) {
		if (${field.fieldName} == null || orderBy == null) {
			throw new IllegalArgumentException('The ${field.fieldName} and orderBy parameter cannot be null')
		}

		return _findBy${field.fieldName?cap_first}(${field.fieldName}, orderBy, true, false, true)
	}
	@Override
	public List<${className}> findBy${field.fieldName?cap_first}NCS(${field.fieldType} ${field.fieldName}) {
		if (${field.fieldName} == null) {
			throw new IllegalArgumentException('The ${field.fieldName} parameter cannot be null')
		}

		return _findBy${field.fieldName?cap_first}(${field.fieldName}, null, null, false, false)
	}

	@Override
	public List<${className}> findBy${field.fieldName?cap_first}NCSOrderBy(${field.fieldType} ${field.fieldName}, String orderBy) {
		if (${field.fieldName} == null || orderBy == null) {
			throw new IllegalArgumentException('The ${field.fieldName} and orderBy parameter cannot be null')
		}

		return _findBy${field.fieldName?cap_first}(${field.fieldName}, orderBy, false, false, false)
	}

	@Override
	public List<${className}> findBy${field.fieldName?cap_first}NCSOrderByDesc(${field.fieldType} ${field.fieldName}, String orderBy) {
		if (${field.fieldName} == null || orderBy == null) {
			throw new IllegalArgumentException('The ${field.fieldName} and orderBy parameter cannot be null')
		}

		return _findBy${field.fieldName?cap_first}(${field.fieldName}, orderBy, true, false, false)
	}

	@Override
	public List<${className}> likeBy${field.fieldName?cap_first}(${field.fieldType} ${field.fieldName}) {
		if (${field.fieldName} == null) {
			throw new IllegalArgumentException('The ${field.fieldName} parameter cannot be null')
		}

		return _findBy${field.fieldName?cap_first}(${field.fieldName}, null, null, true, true)
	}

	@Override
	public List<${className}> likeBy${field.fieldName?cap_first}OrderBy(${field.fieldType} ${field.fieldName}, String orderBy) {
		if (${field.fieldName} == null || orderBy == null) {
			throw new IllegalArgumentException('The ${field.fieldName} and orderBy parameter cannot be null')
		}

		return _findBy${field.fieldName?cap_first}(${field.fieldName}, orderBy, false, true, true)
	}

	@Override
	public List<${className}> likeBy${field.fieldName?cap_first}OrderByDesc(${field.fieldType} ${field.fieldName}, String orderBy) {
		if (${field.fieldName} == null || orderBy == null) {
			throw new IllegalArgumentException('The ${field.fieldName} and orderBy parameter cannot be null')
		}

		return _findBy${field.fieldName?cap_first}(${field.fieldName}, orderBy, true, true, true)
	}
			<#if field.fieldType == "String">
	@Override
	public List<${className}> likeBy${field.fieldName?cap_first}NCS(${field.fieldType} ${field.fieldName}) {
		if (${field.fieldName} == null) {
			throw new IllegalArgumentException('The ${field.fieldName} parameter cannot be null')
		}

		return _findBy${field.fieldName?cap_first}(${field.fieldName}, null, null, true, false)
	}

	@Override
	public List<${className}> likeBy${field.fieldName?cap_first}NCSOrderBy(${field.fieldType} ${field.fieldName}, String orderBy) {
		if (${field.fieldName} == null || orderBy == null) {
			throw new IllegalArgumentException('The ${field.fieldName} and orderBy parameter cannot be null')
		}

		return _findBy${field.fieldName?cap_first}(${field.fieldName}, orderBy, false, true, false)
	}

	@Override
	public List<${className}> likeBy${field.fieldName?cap_first}NCSOrderByDesc(${field.fieldType} ${field.fieldName}, String orderBy) {
		if (${field.fieldName} == null || orderBy == null) {
			throw new IllegalArgumentException('The ${field.fieldName} and orderBy parameter cannot be null')
		}

		return _findBy${field.fieldName?cap_first}(${field.fieldName}, orderBy, true, true, false)
	}	
			</#if>
		</#if>
	</#list>
</#if>

	private List<${className}> _findBy(${className} ${entityName}, long startRow, long pageSize) {
		return _findBy(${entityName}, null, null, false, true, startRow, pageSize)
	}

	private List<${className}> _findBy(${className} ${entityName}, String orderBy, Boolean reverse, boolean useLike, boolean caseSensitive, long startRow=-1, long pageSize=-1) {
		if (${entityName} == null) {
			throw new IllegalArgumentException('The ${entityName} parameter cannot be null')
		}

		Map<${keyFieldType}, ${className}> ${entityName}Map = null
		List<${className}> ${entityName}List = new ArrayList<${className}>()
		try {
			${entityName}Map = new HashMap<${keyFieldType}, ${className}>()

			def sqlStatement = generateSqlSelectStatement(${entityName}, orderBy, reverse, useLike, caseSensitive, startRow, pageSize)
			getSession().eachRow(sqlStatement) { row->
				${className} result${className} = setup${className}FromRow(row, ${entityName}Map)
				if (!${entityName}List.contains(result${className})) {
					${entityName}List << result${className}
				}
			}
		} catch (Exception e) {
			throw new RuntimeException('Could not find a ${entityName} ', e);
		} finally {
			close()
		}
		
		${entityName}List
	}

	@Override
	public List<${className}> findBy(${className} ${entityName}) {
		return _findBy(${entityName}, null, null, false, true)
	}

	@Override
	public List<${className}> findByOrderBy(${className} ${entityName}, String orderBy) {
		if (orderBy == null) {
			throw new IllegalArgumentException('The orderBy parameter cannot be null')
		}

		return _findBy(${entityName}, orderBy, false, false, true)
	}

	@Override
	public List<${className}> findByOrderByDesc(${className} ${entityName}, String orderBy) {
		if (orderBy == null) {
			throw new IllegalArgumentException('The orderBy parameter cannot be null')
		}

		return _findBy(${entityName}, orderBy, true, false, true)
	}

	@Override
	public List<${className}> findByNCS(${className} ${entityName}) {
		return _findBy(${entityName}, null, null, false, false)
	}

	@Override
	public List<${className}> findByNCSOrderBy(${className} ${entityName}, String orderBy) {
		if (orderBy == null) {
			throw new IllegalArgumentException('The orderBy parameter cannot be null')
		}

		return _findBy(${entityName}, orderBy, false, false, false)
	}

	@Override
	public List<${className}> findByNCSOrderByDesc(${className} ${entityName}, String orderBy) {
		if (orderBy == null) {
			throw new IllegalArgumentException('The orderBy parameter cannot be null')
		}

		return _findBy(${entityName}, orderBy, true, false, false)
	}

	@Override
	public List<${className}> findByPaged(${className} ${entityName}, long startRow, long pageSize) {
		return _findBy(${entityName}, startRow, pageSize)
	}

	@Override
	public List<${className}> findByPagedNCS(${className} ${entityName}, long startRow, long pageSize) {
		return _findBy(${entityName}, null, null, false, false, startRow, pageSize)
	}

	@Override
	public List<${className}> findByPagedNCSOrderBy(${className} ${entityName}, String orderBy,
			long startRow, long pageSize) {
		if (orderBy == null) {
			throw new IllegalArgumentException('The orderBy parameter cannot be null')
		}

		return _findBy(${entityName}, orderBy, false, false, false, startRow, pageSize)
	}

	@Override
	public List<${className}> findByPagedNCSOrderByDesc(${className} ${entityName},
			String orderBy, long startRow, long pageSize) {
		if (orderBy == null) {
			throw new IllegalArgumentException('The orderBy parameter cannot be null')
		}

		return _findBy(${entityName}, orderBy, true, false, false, startRow, pageSize)
	}

	@Override
	public List<${className}> findByPagedOrderBy(${className} ${entityName}, String orderBy,
			long startRow, long pageSize) {
		if (orderBy == null) {
			throw new IllegalArgumentException('The orderBy parameter cannot be null')
		}

		return _findBy(${entityName}, orderBy, false, false, true, startRow, pageSize)
	}

	@Override
	public List<${className}> findByPagedOrderByDesc(${className} ${entityName}, String orderBy,
			long startRow, long pageSize) {
		if (orderBy == null) {
			throw new IllegalArgumentException('The orderBy parameter cannot be null')
		}

		return _findBy(${entityName}, orderBy, true, false, true, startRow, pageSize)
	}

	@Override
	public List<${className}> likeBy(${className} ${entityName}) {
		return _findBy(${entityName}, null, null, true, true)
	}

	@Override
	public List<${className}> likeByOrderBy(${className} ${entityName}, String orderBy) {
		if (orderBy == null) {
			throw new IllegalArgumentException('The orderBy parameter cannot be null')
		}

		return _findBy(${entityName}, orderBy, false, true, true)
	}

	@Override
	public List<${className}> likeByOrderByDesc(${className} ${entityName}, String orderBy) {
		if (orderBy == null) {
			throw new IllegalArgumentException('The orderBy parameter cannot be null')
		}

		return _findBy(${entityName}, orderBy, true, true, true)
	}

	@Override
	public List<${className}> likeByNCS(${className} ${entityName}) {
		return _findBy(${entityName}, null, null, true, false)
	}

	@Override
	public List<${className}> likeByNCSOrderBy(${className} ${entityName}, String orderBy) {
		if (orderBy == null) {
			throw new IllegalArgumentException('The orderBy parameter cannot be null')
		}

		return _findBy(${entityName}, orderBy, false, true, false)
	}

	@Override
	public List<${className}> likeByNCSOrderByDesc(${className} ${entityName}, String orderBy) {
		if (orderBy == null) {
			throw new IllegalArgumentException('The orderBy parameter cannot be null')
		}

		return _findBy(${entityName}, orderBy, true, true, false)
	}

	@Override
	public List<${className}> likeByPaged(${className} ${entityName}, long startRow, long pageSize) {
		return _findBy(${entityName}, null, null, true, true, startRow, pageSize)
	}

	@Override
	public List<${className}> likeByPagedNCS(${className} ${entityName}, long startRow, long pageSize) {
		return _findBy(${entityName}, null, null, true, false, startRow, pageSize)
	}

	@Override
	public List<${className}> likeByPagedNCSOrderBy(${className} ${entityName}, String orderBy,
			long startRow, long pageSize) {
		if (orderBy == null) {
			throw new IllegalArgumentException('The orderBy parameter cannot be null')
		}

		return _findBy(${entityName}, orderBy, false, true, false, startRow, pageSize)
	}

	@Override
	public List<${className}> likeByPagedNCSOrderByDesc(${className} ${entityName},
			String orderBy, long startRow, long pageSize) {
		if (orderBy == null) {
			throw new IllegalArgumentException('The orderBy parameter cannot be null')
		}

		return _findBy(${entityName}, orderBy, true, true, false, startRow, pageSize)
	}

	@Override
	public List<${className}> likeByPagedOrderBy(${className} ${entityName}, String orderBy,
			long startRow, long pageSize) {
		if (orderBy == null) {
			throw new IllegalArgumentException('The orderBy parameter cannot be null')
		}

		return _findBy(${entityName}, orderBy, false, true, true, startRow, pageSize)
	}

	@Override
	public List<${className}> likeByPagedOrderByDesc(${className} ${entityName}, String orderBy,
			long startRow, long pageSize) {
		if (orderBy == null) {
			throw new IllegalArgumentException('The orderBy parameter cannot be null')
		}

		return _findBy(${entityName}, orderBy, true, true, true, startRow, pageSize)
	}

	private long _countBy(${className} ${entityName}, boolean useLike) {
		if (${entityName} == null) {
			throw new IllegalArgumentException('The ${entityName} parameter cannot be null')
		}

		long rowCount = 0;

		try {

			def sqlStatement = generateSqlSelectStatement(${entityName}, null, false, useLike, true, -1, -1, true)
			rowCount = getSession().firstRow(sqlStatement)[0]
		} catch (Exception e) {
			throw new RuntimeException('Could not count a ${entityName} ', e);
		} finally {
			close()
		}

		rowCount
	}

	@Override
	public long countBy(${className} ${entityName}) {
		return _countBy(${entityName}, false)
	}

	@Override
	public long countByLike(${className} ${entityName}) {
		return _countBy(${entityName}, true)
	}
}
