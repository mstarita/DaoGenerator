package thecat.model.businessobject;

import java.io.Serializable;

import javax.persistence.Entity;
import javax.persistence.Id;

@Entity
public class Title implements GenericPK<Long>, Serializable {

	private static final long serialVersionUID = 1L;
	
	private Long id;
	private String theTitle;
	
	@Id
	public Long getId() {
		return id;
	}
	public void setId(Long id) {
		this.id = id;
	}
	public String getTheTitle() {
		return theTitle;
	}
	public void setTheTitle(String theTitle) {
		this.theTitle = theTitle;
	}
	@Override
	public int hashCode() {
		final int prime = 31;
		int result = 1;
		result = prime * result + ((id == null) ? 0 : id.hashCode());
		return result;
	}
	@Override
	public boolean equals(Object obj) {
		if (this == obj)
			return true;
		if (obj == null)
			return false;
		if (getClass() != obj.getClass())
			return false;
		Title other = (Title) obj;
		if (id == null) {
			if (other.id != null)
				return false;
		} else if (!id.equals(other.id))
			return false;
		return true;
	}
	@Override
	public String toString() {
		return "Title [id=" + id + ", theTitle=" + theTitle + "]";
	}
	
}
