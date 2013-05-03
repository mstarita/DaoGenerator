package ${packageName};

import java.io.Serializable;
import java.util.List;

import org.apache.ibatis.session.RowBounds;

import ${packageName}.mapper.GenericMapper;

public class GenericDaoImpl<T extends GenericPK<PK>, PK extends Serializable> extends Dao implements GenericDao<T, PK> {

	private Class<T> persistentClass;
	private Class<T> mapperClass;
	
	public GenericDaoImpl(final Class<T> persistentClass, final Class mapperClass) {
		this.persistentClass = persistentClass;
		this.mapperClass = mapperClass;
	}
	
	@SuppressWarnings("unchecked")
	private List<T> findAll(String orderBy, Boolean desc, int startRow, int pageSize) {
		List<T> entityList = null;
		try {
			GenericMapper<T, PK> mapper = (GenericMapper<T, PK>) getSession().getMapper(mapperClass);
			if (startRow != -1 && pageSize != -1) {
				RowBounds rowBounds = new RowBounds(startRow, pageSize);
				entityList = mapper.findAll(orderBy, desc, rowBounds);
			} else {
				entityList = mapper.findAll(orderBy, desc);
			}
		} catch (Exception e) {
			throw new RuntimeException("Could not find the entity " + persistentClass.getSimpleName(), e);
		} finally {
			close();
		}
		
		return entityList;
	}
	
	@Override
	public List<T> findAll() {
		return findAll(null, null, -1, -1);
	}

	@Override
	public List<T> findAllOrderBy(String orderBy) {
		if (orderBy == null) {
			throw new IllegalArgumentException("The orderBy parameter cannot be null, if sort order is not required use findAll() method instead");
		}
		
		return findAll(orderBy, null, -1, -1);
	}

	@Override
	public List<T> findAllOrderByDesc(String orderBy) {
		if (orderBy == null) {
			throw new IllegalArgumentException("The orderBy parameter cannot be null, if sort order is not required use findAll() method instead");
		}
		
		return findAll(orderBy, true, -1, -1);
	}

	@Override
	public List<T> findAllPaged(int startRow, int pageSize) {
		return findAll(null, null, startRow, pageSize);
	}
	
	@Override
	public List<T> findAllPagedOrderBy(String orderBy, int startRow, int pageSize) {
		if (orderBy == null) {
			throw new IllegalArgumentException("The orderBy parameter cannot be null, if sort order is not required use findAllPaged() method instead");
		}
		
		return findAll(orderBy, null, startRow, pageSize);
	}
	
	@Override
	public List<T> findAllPagedOrderByDesc(String orderBy, int startRow, int pageSize) {
		if (orderBy == null) {
			throw new IllegalArgumentException("The orderBy parameter cannot be null, if sort order is not required use findAllPaged() method instead");
		}
		
		return findAll(orderBy, true, startRow, pageSize);
	}
	
	@Override
	@SuppressWarnings("unchecked")
	public T findById(PK id) {
		if (id == null) {
			throw new IllegalArgumentException("The id parameter cannot be null");
		}
		
		GenericMapper<T, PK> mapper = (GenericMapper<T, PK>) getSession().getMapper(mapperClass);
		T entityFound = mapper.findById(id);
		
		return entityFound;
	}
	
	@Override
	public int countAll() {
		int rowCount = 0;
		
		try {
			GenericMapper<T, PK> mapper = (GenericMapper<T, PK>) getSession().getMapper(mapperClass);

			rowCount = mapper.countAll();
		} catch (Exception e) {
			throw new RuntimeException("Could not count entities " + persistentClass.getSimpleName(), e);
		} finally {
			close();
		}
		
		return rowCount;
	}

	@Override
	@SuppressWarnings("unchecked")
	public T create(T entity) {
		T result;
		
		if (entity == null) {
			throw new IllegalArgumentException("The entity parameter cannot be null");
		}
		
		try {
			result = entity;
			
			GenericMapper<T, PK> mapper = (GenericMapper<T, PK>) getSession().getMapper(mapperClass);
<#if useDb == 'mysql' >
			mapper.insert(entity);
</#if>
<#if useDb == 'postgres' >
			PK id = mapper.insert(entity);
			result.setId(id);
</#if>	
			commit();
		} catch (Exception ex) {
			rollback();
			throw new RuntimeException("Could not create the entity", ex);
		} finally {
			close();
		}
		
		return result;
	}

	@Override
	public void update(T entity) {
		if (entity == null) {
			throw new IllegalArgumentException("The entity parameter cannot be null");
		}
		
		try {
			GenericMapper<T, PK> mapper = (GenericMapper<T, PK>) getSession().getMapper(mapperClass);
			mapper.update(entity);
			commit();
		} catch (Exception ex) {
			rollback();
			throw new RuntimeException("Could not update the entity", ex);
		} finally {
			close();
		}
	}
	
	@Override
	public void delete(T entity) {
		if (entity == null) {
			throw new IllegalArgumentException("The entity parameter cannot be null");
		}
		
		try {
			GenericMapper<T, PK> mapper = (GenericMapper<T, PK>) getSession().getMapper(mapperClass);
			if (mapper.delete(entity) == 0) {
				throw new RuntimeException("no row deleted");
			}
			commit();
		} catch (Exception ex) {
			rollback();
			throw new RuntimeException("Could not delete the entity", ex);
		} finally {
			close();
		}	
	}

}
