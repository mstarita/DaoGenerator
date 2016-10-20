package ${packageName};

public class DaoHelper {

	private static DBHelper dbHelper = null;

	private DaoHelper() { }
	
	public static DBHelper getDBHelperInstance() {
		if (null == dbHelper) {
			dbHelper = new DBHelperImpl(ApplicationContextProvider.getContext());
		}
		return dbHelper;
	}

	public static void resetAllInstances() {
	
		dbHelper = null;
		
	}
		
}
