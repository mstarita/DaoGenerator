package ${packageName};

import java.io.Serializable;
import java.util.List;

import org.hibernate.Criteria;
import org.hibernate.HibernateException;
import org.hibernate.Query;
import org.hibernate.criterion.Order;

public class GenericDaoImpl<T extends GenericPK<PK>, PK extends Serializable> extends Dao implements GenericDao<T, PK> {

	private Class<T> persistentClass;
	
	public GenericDaoImpl(final Class<T> persistentClass) {
		this.persistentClass = persistentClass;
	}
	
	@SuppressWarnings("unchecked")
	private List<T> findAll(String orderBy, Boolean desc, long startRow, long pageSize) {
		List<T> entityList = null;
		try {
			begin();
			Criteria criteria = getSession().createCriteria(persistentClass);
			
			if (startRow != -1) { criteria.setFirstResult((int) startRow); }
			if (pageSize != -1) { criteria.setMaxResults((int) pageSize); } 
			
			if (orderBy != null) {
				if (desc != null && desc) {
					criteria.addOrder(Order.desc(orderBy));
				} else {
					criteria.addOrder(Order.asc(orderBy));
				}
			}
			
			criteria.setResultTransformer(Criteria.DISTINCT_ROOT_ENTITY);
			entityList = criteria.list();
			
			commit();
		} catch (HibernateException e) {
			rollback();
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
	@SuppressWarnings("unchecked")
	public T findById(PK id) {
		if (id == null) {
			throw new IllegalArgumentException("The id parameter cannot be null");
		}
		
		begin();
		T entityFound = (T) getSession().get(persistentClass, id);
		commit();
		
		return entityFound;
	}
	
	@Override
	public long countAll() {
		long rowCount = 0;
		
		try {
			begin();
			
			Query query = getSession().createQuery("select count(*) from " + persistentClass.getSimpleName());
			rowCount = ((Long) query.uniqueResult()).intValue();

			commit();
		} catch (HibernateException e) {
			rollback();
			throw new RuntimeException("Could not count entities " + persistentClass.getSimpleName(), e);
		} finally {
			close();
		}
		
		return rowCount;
	}

	@Override
	public T create(T entity) {
		
		if (entity == null) {
			throw new IllegalArgumentException("The entity parameter cannot be null");
		}
		
		try {
			begin();
				getSession().save(entity);
			commit();
		} catch (HibernateException ex) {
			rollback();
			throw new RuntimeException("Could not create the entity", ex);
		} finally {
			close();
		}
		
		return entity;
	}

	@Override
	public void update(T entity) {
		if (entity == null) {
			throw new IllegalArgumentException("The entity parameter cannot be null");
		}
		
		try {
			begin();
				getSession().update(entity);
			commit();
		} catch (HibernateException ex) {
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
			begin();
				getSession().delete(entity);
			commit();
		} catch (HibernateException ex) {
			rollback();
			throw new RuntimeException("Could not delete the entity", ex);
		} finally {
			close();
		}	
	}

}
