package ${packageName};

import java.io.Serializable;
import java.util.List;

public interface GenericDao<T extends GenericPK<PK>, PK extends Serializable> {

	List<T> findAll();
	List<T> findAllOrderBy(String orderBy);
	List<T> findAllOrderByDesc(String orderBy);
	
	List<T> findAllPaged(int startRow, int pageSize);
	List<T> findAllPagedOrderBy(String orderBy, int startRow, int pageSize);
	List<T> findAllPagedOrderByDesc(String orderBy, int startRow, int pageSize);
	
	
	T findById(PK id);
	
	
	int countAll();
	
	
	T create(T entity);
	void update(T entity);
	void delete(T entity);
	
}
