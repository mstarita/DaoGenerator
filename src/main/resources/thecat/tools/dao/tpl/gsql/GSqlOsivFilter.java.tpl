package ${packageName};

import java.io.IOException;
import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.FilterConfig;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

/**
 * GSql Open Session in View Filter implementation with Extend conversation flag (using session...)
 */
public class GSqlOsivFilter extends Dao implements Filter {

	public static final String EXTEND_CONVERSATION_FLAG = "extendConversation";

	public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain) throws IOException, ServletException {

		HttpServletRequest httpRequest = (HttpServletRequest) request;
		HttpSession session = httpRequest.getSession(false);
		
		try {
			if ((session == null) || (session != null && session.getAttribute(EXTEND_CONVERSATION_FLAG) == null)) {
				//System.out.println("osiv doFilter() - begin GSql transaction...");
				getSession();
			} else {
				//System.out.println("osiv doFilter() - before chain.doFilter() - EXTEND_CONVERSATION_FLAG found, continue the transaction");
			}
			
			// pass the request along the filter chain
			chain.doFilter(request, response);
			
			if (getSession().getTransaction().isActive()) {
				System.out.println("osiv doFilter() - trying to flush myBatis session...");
				getSession().flush();
			}
			
			if ((session == null) || (session != null && session.getAttribute(EXTEND_CONVERSATION_FLAG) == null)) {
				if (getSession().getTransaction().isActive()) {
					//System.out.println("osiv doFilter() - trying commit GSql transaction...");
					commit();
					//System.out.println("osiv doFilter() - commit done");
				}
			}
		} catch (Exception ex) {
			rollback();
			ex.printStackTrace();
			throw new ServletException(ex);
		} finally {
			if ((session == null) || (session != null && session.getAttribute(EXTEND_CONVERSATION_FLAG) == null)) {
				//System.out.println("osiv doFilter() - closing session");
				close();
			} else {
				//System.out.println("osiv doFilter() - after chain.doFilter() - EXTEND_CONVERSATION_FLAG found, continue the transaction");
			}
		}
		
	}

	public void init(FilterConfig fConfig) throws ServletException {
		System.out.println("osiv filter init");
	}

	public void destroy() {
		System.out.println("osiv filter destoy");
	}

}
