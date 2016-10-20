package ${packageName};

import java.io.Serializable;
import java.util.List;

import com.j256.ormlite.dao.Dao;
import com.j256.ormlite.stmt.QueryBuilder;

public class GenericDaoImpl<T extends GenericPK<PK>, PK extends Serializable> implements GenericDao<T, PK> {

	private Class<T> persistentClass;
	protected Dao<T, PK> baseDao;
	
	public GenericDaoImpl(final Class<T> persistentClass, final Dao<T, PK> baseDao) {
		this.persistentClass = persistentClass;
		this.baseDao = baseDao;
	}
	
	private List<T> findAll(String orderBy, Boolean desc, long startRow, long pageSize) {
		List<T> entityList = null;
		
		try {
			QueryBuilder<T, PK> queryBuilder = baseDao.queryBuilder();
			if (orderBy != null) {
				if (desc != null) {
					queryBuilder.orderBy(orderBy, !desc);
				} else {
					queryBuilder.orderBy(orderBy, true);
				}
			}
			if (startRow != -1) {
				queryBuilder.offset(startRow);
				queryBuilder.limit(pageSize);
			}
			entityList = queryBuilder.query();
		} catch (Exception ex) {
			throw new RuntimeException("Could not find the entity " + persistentClass.getSimpleName(), ex);
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
	public List<T> findAllPaged(long startRow, long pageSize) {
		return findAll(null, null, startRow, pageSize);
	}
	
	@Override
	public List<T> findAllPagedOrderBy(String orderBy, long startRow, long pageSize) {
		if (orderBy == null) {
			throw new IllegalArgumentException("The orderBy parameter cannot be null, if sort order is not required use findAllPaged() method instead");
		}
		
		return findAll(orderBy, null, startRow, pageSize);
	}
	
	@Override
	public List<T> findAllPagedOrderByDesc(String orderBy, long startRow, long pageSize) {
		if (orderBy == null) {
			throw new IllegalArgumentException("The orderBy parameter cannot be null, if sort order is not required use findAllPaged() method instead");
		}
		
		return findAll(orderBy, true, startRow, pageSize);
	}
	
	@Override
	public T findById(PK id) {
		if (id == null) {
			throw new IllegalArgumentException("The id parameter cannot be null");
		}
		
		T entity = null;
		
		try {
			entity = baseDao.queryForId(id);
		} catch (Exception ex) {
			throw new RuntimeException("Could not find the entity " + persistentClass.getSimpleName(), ex);
		}
		
		return entity;
	}
	
	@Override
	public long countAll() {
		long rowCount = 0;
		
		try {
			rowCount = baseDao.countOf();
		} catch (Exception ex) {
			throw new RuntimeException("Could not count the entity " + persistentClass.getSimpleName(), ex);
		}
		
		return rowCount;
	}

	@Override
	public T create(T entity) {
		T result = null;
		
		if (entity == null) {
			throw new IllegalArgumentException("The entity parameter cannot be null");
		}
		
		try {
			baseDao.create(entity);
			result = entity;
		} catch (Exception ex) {
			throw new RuntimeException("Could not create the entity " + persistentClass.getSimpleName(), ex);
		}
		
		return result;
	}

	@Override
	public void update(T entity) {
		if (entity == null) {
			throw new IllegalArgumentException("The entity parameter cannot be null");
		}
		
		try {
			baseDao.update(entity);
		} catch (Exception ex) {
			throw new RuntimeException("Could not update the entity " + persistentClass.getSimpleName(), ex);
		}
	}
	
	@Override
	public void delete(T entity) {
		if (entity == null) {
			throw new IllegalArgumentException("The entity parameter cannot be null");
		}
		
		try {
			int delCount = baseDao.delete(entity);
			if (delCount == 0) {
				throw new RuntimeException("Could not find the entity " + persistentClass.getSimpleName());
			}
		} catch (Exception ex) {
			throw new RuntimeException("Could not delete the entity " + persistentClass.getSimpleName(), ex);
		}
	}

}
