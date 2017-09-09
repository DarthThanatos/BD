package pl.edu.agh.iisg.bd.graph.assignment;

import org.assertj.core.util.Lists;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import pl.edu.agh.iisg.bd.graph.model.Movie;
import pl.edu.agh.iisg.bd.graph.model.Person;
import pl.edu.agh.iisg.bd.graph.repository.MovieRepository;
import pl.edu.agh.iisg.bd.graph.repository.PersonRepository;

import java.util.List;
import java.util.Map;
import java.util.Optional;

@Service
public class Solution {
	@Autowired
	PersonRepository pr;
	
	@Autowired
	MovieRepository mr;
	
    public String yourName() {
        return "Robert Bielas";
    }

    public void createPerson(final String name, final int imdbId, final String gender) {
    	Person person = new Person(name, imdbId, gender);
    	pr.save(person);
    }

    public Optional<Person> findPerson(final String name) {
    	Person person = pr.findByName(name);
        return Optional.ofNullable(person);
    }

    public Optional<Movie> findMovie(final String title) {
    	Movie movie = mr.findByTitle(title);
        return Optional.ofNullable(movie);
    }

    public void deletePerson(final Person person) {
    	pr.deletePerson(person.getName());
    }

    public void setMovieForPerson(final Person person, final Movie movie) {
    	mr.createPersonMovieRelationship(person.getName(), movie.getTitle());
    }

    /**
     * Hint: https://github.com/luanne/flavorwocky/blob/sdn/src/main/java/com/flavorwocky/repository/IngredientRepository.java#L20
     */
    public List<Map<String,Object>> shortestPath(final Person start, final Person end) {
        return pr.findShortestPath(start.getName(), end.getName());
    }

    public List<Person> whoWillIntroduce(final Person start, final Person end) {
    	List<Person> result = pr.findCoActors(start.getName(), end.getName());
        return result;
    }

}
