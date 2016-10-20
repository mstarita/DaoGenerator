package ${packageName};

import java.util.List;

import com.j256.ormlite.dao.Dao;
import com.j256.ormlite.stmt.QueryBuilder;
import com.j256.ormlite.stmt.UpdateBuilder;
import com.j256.ormlite.stmt.Where;
import ${fqClassName};

public class ${className}DaoExtImpl extends ${className}DaoImpl implements ${className}DaoExt {

	public ${className}DaoExtImpl(Dao<${className}, Long> baseDao) {
		super(baseDao);
	}

}
