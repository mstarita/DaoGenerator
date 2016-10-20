package ${packageName};

import java.io.Reader;
import java.util.logging.Level;
import java.util.logging.Logger;

import org.apache.ibatis.io.Resources;
import org.apache.ibatis.session.SqlSession;
import org.apache.ibatis.session.SqlSessionException;
import org.apache.ibatis.session.SqlSessionFactory;
import org.apache.ibatis.session.SqlSessionFactoryBuilder;

public class Dao {

	private static final String MYBATIS_CONFIG_FILE = "mybatis.xml";
	
	private static final Logger log = Logger.getAnonymousLogger();
	private static final ThreadLocal session = new ThreadLocal();
	private static Reader reader; 
	private static SqlSessionFactory sessionFactory;
	
	static {
		try {
		reader = Resources.getResourceAsReader(Dao.class.getClassLoader(), MYBATIS_CONFIG_FILE);
		sessionFactory = new SqlSessionFactoryBuilder().build(reader);
		} catch (Exception ex) {
			log.log(Level.SEVERE, "Cannot init mybatis: " + ex.getMessage());
		}
	}
	
	protected Dao() { }
	
	public static SqlSession getSession() {
		SqlSession session = (SqlSession) Dao.session.get();
		if (session == null) {
			session = sessionFactory.openSession();
			Dao.session.set(session);
		}
		return session;
	}
	
	protected void commit() {
		getSession().commit();
	}
	
	protected void rollback() {
		try {
			getSession().rollback();
		} catch (SqlSessionException ex) {
			log.log(Level.WARNING, "Cannot rollback: " + ex);
		}		
	}
	
	public void close() {
		getSession().close();
		Dao.session.set(null);
	}
	
	public static SqlSessionFactory getSessionFactory() {
		return sessionFactory;
	}
}