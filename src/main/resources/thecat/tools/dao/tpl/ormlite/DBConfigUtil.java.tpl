package com.trei.dao;

import com.j256.ormlite.android.apptools.OrmLiteConfigUtil;

public class DBConfigUtil extends OrmLiteConfigUtil {

	public static void main(String[] args) throws Exception {
		writeConfigFile("ormlite_config.txt");
	}
}
