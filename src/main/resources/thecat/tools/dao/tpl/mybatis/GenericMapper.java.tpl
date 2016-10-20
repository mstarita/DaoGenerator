package ${packageName}.mapper;

import java.io.Serializable;
import java.util.List;

import org.apache.ibatis.session.RowBounds;

public interface GenericMapper<T, PK extends Serializable> {

	T findById(PK id);
	
	List<T> findAll(String orderBy, Boolean desc);
	
	List<T> findAll(String orderBy, Boolean desc, RowBounds rowBounds);
	
	int countAll();

<#if useDb == 'mysql'>
	void insert(T t);
<#elseif useDb == 'postgres' >	
	PK insert(T t);
</#if>
	
	void update(T t);
	
	int delete(T t);
	
}
