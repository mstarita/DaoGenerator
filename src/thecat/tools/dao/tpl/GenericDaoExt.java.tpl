package ${packageName};

import java.io.Serializable;
import java.util.List;

public interface GenericDaoExt<T extends GenericPK<PK>, PK extends Serializable> extends GenericDao<T, PK> {

	List<T> findBy(T entity);
	List<T> findByOrderBy(T entity, String orderBy);
	List<T> findByOrderByDesc(T entity, String orderBy);
	List<T> findByNCS(T entity);
	List<T> findByNCSOrderBy(T entity, String orderBy);
	List<T> findByNCSOrderByDesc(T entity, String orderBy);
	
	List<T> findByPaged(T entity, int startRow, int pageSize);
	List<T> findByPagedOrderBy(T entity, String orderBy, int startRow, int pageSize);
	List<T> findByPagedOrderByDesc(T entity, String orderBy, int startRow, int pageSize);
	List<T> findByPagedNCS(T entity, int startRow, int pageSize);
	List<T> findByPagedNCSOrderBy(T entity, String orderBy, int startRow, int pageSize);
	List<T> findByPagedNCSOrderByDesc(T entity, String orderBy, int startRow, int pageSize);
	
	
	List<T> likeBy(T entity);
	List<T> likeByOrderBy(T entity, String orderBy);
	List<T> likeByOrderByDesc(T entity, String orderBy);
	List<T> likeByNCS(T entity);
	List<T> likeByNCSOrderBy(T entity, String orderBy);
	List<T> likeByNCSOrderByDesc(T entity, String orderBy);
	
	List<T> likeByPaged(T entity, int startRow, int pageSize);
	List<T> likeByPagedOrderBy(T entity, String orderBy, int startRow, int pageSize);
	List<T> likeByPagedOrderByDesc(T entity, String orderBy, int startRow, int pageSize);
	List<T> likeByPagedNCS(T entity, int startRow, int pageSize);
	List<T> likeByPagedNCSOrderBy(T entity, String orderBy, int startRow, int pageSize);
	List<T> likeByPagedNCSOrderByDesc(T entity, String orderBy, int startRow, int pageSize);
	
	
	int countBy(T entity);
	int countByLike(T entity);
	
}
