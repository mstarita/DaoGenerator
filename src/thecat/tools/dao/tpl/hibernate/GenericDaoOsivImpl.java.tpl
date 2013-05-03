package ${packageName};

import java.io.Serializable;
import java.util.List;

import org.hibernate.Criteria;
import org.hibernate.Query;
import org.hibernate.criterion.Order;

public class GenericDaoOsivImpl<T extends GenericPK<PK>, PK extends Serializable> extends Dao implements GenericDao<T, PK> {

	private Class<T> persistentClass;
	
	public GenericDaoOsivImpl(final Class<T> persistentClass) {
		this.persistentClass = persistentClass;
	}
	
	@SuppressWarnings("unchecked")
	private List<T> findAll(String orderBy, Boolean desc, int startRow, int pageSize) {
		Criteria criteria = getSession().createCriteria(persistentClass);
			
		if (startRow != -1) { criteria.setFirstResult(startRow); }
		if (pageSize != -1) { criteria.setMaxResults(pageSize); } 
			
		if (orderBy != null) {
			if (desc != null && desc) {
				criteria.addOrder(Order.desc(orderBy));
			} else {
				criteria.addOrder(Order.asc(orderBy));
			}
		}
			
		criteria.setResultTransformer(Criteria.DISTINCT_ROOT_ENTITY);
			
		return criteria.list();
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
		
		return (T) getSession().get(persistentClass, id);
	}
	
	@Override
	public int countAll() {
		Query query = getSession().createQuery("select count(*) from " + persistentClass.getSimpleName());

		return ((Long) query.uniqueResult()).intValue();
	}

	@Override
	@SuppressWarnings("unchecked")
	public T create(T entity) {
		if (entity == null) {
			throw new IllegalArgumentException("The entity parameter cannot be null");
		}
		
		return (T) getSession().save(entity);
	}

	@Override
	public void update(T entity) {
		if (entity == null) {
			throw new IllegalArgumentException("The entity parameter cannot be null");
		}
		
		getSession().update(entity);
	}
	
	@Override
	public void delete(T entity) {
		if (entity == null) {
			throw new IllegalArgumentException("The entity parameter cannot be null");
		}
		
		getSession().delete(entity);
	}

}
