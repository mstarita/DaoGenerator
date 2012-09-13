package thecat.model.businessobject;

import java.io.Serializable;

import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.Transient;

@Entity
public class Person implements Serializable {

	private static final long serialVersionUID = 1L;

	private Long id;
	private String firstname;
	private String lastname;
	private Long age;

	@Id
	public Long getId() {
		return id;
	}
	public void setId(Long id) {
		this.id = id;
	}
	public String getFirstname() {
		return firstname;
	}
	public void setFirstname(String firstname) {
		this.firstname = firstname;
	}
	public String getLastname() {
		return lastname;
	}
	public void setLastname(String lastname) {
		this.lastname = lastname;
	}
	public void setAge(Long age) {
		this.age = age;
	}
	public Long getAge() {
		return age;
	}
	
	public long getPk() {
		return id;
	}
}
