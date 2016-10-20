package ${packageName}

import groovy.sql.Sql 
import java.sql.SQLException;
import java.util.Properties;
import java.util.logging.Level;
import java.util.logging.Logger;

import ${packageName}.util.PropertyLoader;

class Dao {

	private static final String GSQL_CFG_FILE = 'gsql-${useDb}.properties'
	
	private static final String GSQL_CFG_KEY_DB_DRIVER = 'db.driver'
	private static final String GSQL_CFG_KEY_DB_URL = 'db.url'
	private static final String GSQL_CFG_KEY_DB_USER = 'db.user'
	private static final String GSQL_CFG_KEY_DB_PASSWD = 'db.password'
	
	private static String dbDriver
	private static String dbUrl
	private static String dbUser
	private static String dbPassword
	
	private static final Logger log = Logger.getAnonymousLogger()
	private static final ThreadLocal session = new ThreadLocal()
	
	static {
		def properties = PropertyLoader.loadProperties(GSQL_CFG_FILE)
		
		dbDriver = properties.getProperty(GSQL_CFG_KEY_DB_DRIVER)
		dbUrl = properties.getProperty(GSQL_CFG_KEY_DB_URL)
		dbUser = properties.getProperty(GSQL_CFG_KEY_DB_USER)
		dbPassword = properties.getProperty(GSQL_CFG_KEY_DB_PASSWD)
	}
	
	protected Dao() { }
	
	public Sql getSession() {
		def localSession = Dao.session.get()
		if (localSession == null) {
			localSession = Sql.newInstance(dbUrl, dbUser, dbPassword, dbDriver)
			Dao.session.set(localSession)
		}
		return localSession
	}
	
	protected void begin() {
		//getSession().beginTransaction();
	}
	
	protected void commit() {
		getSession().commit();
	}
	
	protected void rollback() {
		try {
			getSession().rollback();
		} catch (SQLException ex) {
			log.log(Level.WARNING, "Cannot rollback: " + ex);
		}
		
		try {
			getSession().close();
		} catch (SQLException ex) {
			log.log(Level.WARNING, "Cannot close: " + ex);
		}
	}
	
	public void close() {
		getSession().close();
		Dao.session.set(null);
	}
	
}
