package ${packageName};

import java.util.logging.Level;
import java.util.logging.Logger;

import org.hibernate.HibernateException;
import org.hibernate.Session;
import org.hibernate.SessionFactory;
import org.hibernate.cfg.AnnotationConfiguration;

public class Dao {

	private static final Logger log = Logger.getAnonymousLogger();
	private static final SessionFactory sessionFactory = new AnnotationConfiguration().configure().buildSessionFactory();
	
	protected Dao() { }
	
	public static Session getSession() {
		return sessionFactory.getCurrentSession();
	}
	
	protected void begin() {
		getSession().beginTransaction();
	}
	
	protected void commit() {
		getSession().getTransaction().commit();
	}
	
	protected void rollback() {
		try {
			getSession().getTransaction().rollback();
		} catch (HibernateException ex) {
			log.log(Level.WARNING, "Cannot rollback: " + ex);
		}
		
		try {
			getSession().close();
		} catch (HibernateException ex) {
			log.log(Level.WARNING, "Cannot close: " + ex);
		}		
	}
	
	public void close() {
		getSession().close();
	}
	
	public static SessionFactory getSessionFactory() {
		return sessionFactory;
	}
}
