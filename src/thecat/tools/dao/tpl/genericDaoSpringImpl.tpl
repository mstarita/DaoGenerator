package ${packageName};

import java.io.Serializable;
import java.util.List;

import org.hibernate.Criteria;
import org.hibernate.criterion.DetachedCriteria;
import org.hibernate.criterion.Order;
import org.hibernate.criterion.Projections;
import org.springframework.dao.support.DataAccessUtils;
import org.springframework.orm.hibernate3.support.HibernateDaoSupport;

<#list importList as import>
import ${import};
</#list>

public class GenericDaoSpringImpl<T, PK extends Serializable> extends HibernateDaoSupport implements GenericDao<T, PK> {

	private Class<T> persistentClass;
	
	public GenericDaoSpringImpl(final Class<T> persistentClass) {
		this.persistentClass = persistentClass;
	}
	
	@SuppressWarnings("unchecked")
	private List<T> findAll(String orderBy, Boolean desc, int startRow, int pageSize) {
		
		DetachedCriteria criteria = DetachedCriteria.forClass(${className}.class);
			
		if (orderBy != null) {
			if (desc != null && desc) {
				criteria.addOrder(Order.desc(orderBy));
			} else {
				criteria.addOrder(Order.asc(orderBy));
			}
		}
		
		criteria.setResultTransformer(Criteria.DISTINCT_ROOT_ENTITY);
		
		return getHibernateTemplate().findByCriteria(criteria, startRow, pageSize);
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
		
		return (T) getHibernateTemplate().get(persistentClass, id);
	}
	
	@Override
	public int countAll() {
		DetachedCriteria criteria = DetachedCriteria.forClass(${className}.class);
			
		criteria.setResultTransformer(Criteria.DISTINCT_ROOT_ENTITY);
		criteria.setProjection(Projections.rowCount());
		return ((Long) DataAccessUtils.uniqueResult(getHibernateTemplate().findByCriteria(criteria))).intValue();
	}

	@Override
	@SuppressWarnings("unchecked")
	public T create(T entity) {		
		if (entity == null) {
			throw new IllegalArgumentException("The entity parameter cannot be null");
		}
		
		return (T) getHibernateTemplate().save(entity);
	}

	@Override
	public void update(T entity) {
		if (entity == null) {
			throw new IllegalArgumentException("The entity parameter cannot be null");
		}
		
		getHibernateTemplate().update(entity);
	}
	
	@Override
	public void delete(T entity) {
		if (entity == null) {
			throw new IllegalArgumentException("The entity parameter cannot be null");
		}
		
		getHibernateTemplate().delete(entity);	
	}

}
