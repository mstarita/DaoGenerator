package ${packageName};

import java.sql.SQLException;

import android.content.Context;
import android.database.sqlite.SQLiteDatabase;
import android.util.Log;

import com.j256.ormlite.android.apptools.OrmLiteSqliteOpenHelper;
import com.j256.ormlite.dao.Dao;
import com.j256.ormlite.support.ConnectionSource;
import com.j256.ormlite.table.TableUtils;

<#list importList as import>
import ${import};
</#list>

public class DBHelperImpl extends OrmLiteSqliteOpenHelper implements DBHelper {

	private static final String DATABASE_NAME = "ormlite-test.db";
	private static final int DATABASE_VERSION = 1;
	
	private ${className}Dao ${entityName}Dao = null;
	
	public DBHelperImpl(Context context) {
		//super(context, DATABASE_NAME, null, DATABASE_VERSION, R.raw.ormlite_config);
		super(context, DATABASE_NAME, null, DATABASE_VERSION);
	}

	public DBHelperImpl(Context context, boolean useInMemoryDB) {
		//super(context, DATABASE_NAME, null, DATABASE_VERSION, R.raw.ormlite_config);
		super(context, useInMemoryDB ? null : DATABASE_NAME, null, DATABASE_VERSION);
	}
	
	@Override
	public void onCreate(SQLiteDatabase sqLiteDatabase, ConnectionSource connectionSource) {
		try {
			Log.i(DBHelper.class.getName(), "onCreate");
			TableUtils.createTable(connectionSource, Person.class);
		} catch (SQLException sqlex) {
			Log.e(DBHelper.class.getName(), "Can't create the database");
		}
	}

	@Override
	public void onUpgrade(SQLiteDatabase sqLiteDatabase, ConnectionSource connectionSource, 
			int oldVersion, int newVersion) {
		try {
			Log.i(DBHelper.class.getName(), "onUpgrade");
			TableUtils.dropTable(connectionSource, Person.class, true);
			onCreate(sqLiteDatabase, connectionSource);
		} catch (SQLException sqlex) {
			
		}
	}
	
	public ${className}Dao get${className}Dao() throws SQLException {
		if (${entityName}Dao == null) {
			Dao<${className}, ${keyFieldType}> baseDao = getDao(${className}.class);
			${entityName}Dao = new ${className}DaoImpl(baseDao);
		}
		
		return ${entityName}Dao;
	}
	
	@Override
	public void close() {
		super.close();
		
		${entityName}Dao = null;
	}

}
