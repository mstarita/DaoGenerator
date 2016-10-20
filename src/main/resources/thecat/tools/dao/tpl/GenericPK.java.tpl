package ${packageName};

import java.io.Serializable;

public interface GenericPK<PK extends Serializable> {

	void setId(PK id);
	
}
