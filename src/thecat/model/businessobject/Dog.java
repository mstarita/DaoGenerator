package thecat.model.businessobject;

import java.util.List;

import javax.persistence.Entity;

@Entity
public class Dog extends Animal {

	private String race;
	private List<Person> persons;

	public String getRace() {
		return race;
	}
	public void setRace(String race) {
		this.race = race;
	}
	public void setPersons(List<Person> persons) {
		this.persons = persons;
	}
	public List<Person> getPersons() {
		return persons;
	}
	
}
