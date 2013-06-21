package thecat.model.businessobject;

import java.io.Serializable;

import javax.persistence.Entity;
import javax.persistence.Id;

@Entity
public class Address implements Serializable {

	private static final long serialVersionUID = 1L;

	private Long id;
	private String theAddress;
	private PersonCollection personCollection;
	
	public PersonCollection getPersonCollection() {
		return personCollection;
	}
	public void setPersonCollection(PersonCollection personCollection) {
		this.personCollection = personCollection;
	}
	public Address() {}
	public Address(Long id) {
		this.id = id;
	}
	
	@Id
	public Long getId() {
		return id;
	}
	public void setId(Long id) {
		this.id = id;
	}
	public String getTheAddress() {
		return theAddress;
	}
	public void setTheAddress(String theAddress) {
		this.theAddress = theAddress;
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
		Address other = (Address) obj;
		if (id == null) {
			if (other.id != null)
				return false;
		} else if (!id.equals(other.id))
			return false;
		return true;
	}
	@Override
	public String toString() {
		return "Address [id=" + id 
			+ ", personsCollection=" + personCollection
			+ ", theAddress=" + theAddress + "]";
	}
	
	
}
