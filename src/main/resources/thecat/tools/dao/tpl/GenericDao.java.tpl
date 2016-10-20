package ${packageName};

import java.io.Serializable;
import java.util.List;

public interface GenericDao<T extends GenericPK<PK>, PK extends Serializable> {

	List<T> findAll();
	List<T> findAllOrderBy(String orderBy);
	List<T> findAllOrderByDesc(String orderBy);
	
	List<T> findAllPaged(long startRow, long pageSize);
	List<T> findAllPagedOrderBy(String orderBy, long startRow, long pageSize);
	List<T> findAllPagedOrderByDesc(String orderBy, long startRow, long pageSize);
	
	
	T findById(PK id);
	
	
	long countAll();
	
	
	T create(T entity);
	void update(T entity);
	void delete(T entity);
	
}
