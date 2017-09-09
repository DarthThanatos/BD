package pl.edu.agh.iisg.bd.graph.repository;

import org.junit.Assert;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.junit4.SpringRunner;
import pl.edu.agh.iisg.bd.graph.assignment.Solution;
import pl.edu.agh.iisg.bd.graph.model.Movie;
import pl.edu.agh.iisg.bd.graph.model.Person;

import java.util.Optional;

@RunWith(SpringRunner.class)
@SpringBootTest
public class SolutionTest {

    private final static Logger LOGGER = LoggerFactory.getLogger(SolutionTest.class);

    @Autowired
    Solution solution;

    @Test
    public void testName() throws Exception {
        LOGGER.warn("My name is " + solution.yourName());
    }

    @Test
    public void testPerson() throws Exception {
        solution.createPerson(solution.yourName(), 1, "unknown");
        Optional<Person> personOptional = solution.findPerson(solution.yourName());
        Assert.assertTrue(personOptional.isPresent());
        Person person = personOptional.get();
        Optional<Movie> movieOptional = solution.findMovie("Listy do M.");
        Assert.assertTrue(movieOptional.isPresent());
        Movie movie = movieOptional.get();
        solution.setMovieForPerson(person, movie);
        Optional<Person> personOptional2 = solution.findPerson(solution.yourName());
        Assert.assertTrue(personOptional2.isPresent());
        Person person2 = personOptional2.get();
        Assert.assertTrue(person2.getMovies().contains(movie));
        solution.deletePerson(person);
        Assert.assertFalse(solution.findPerson(solution.yourName()).isPresent());
    }
    
    
    @Test
    public void testPath() throws Exception {
        Optional<Person> emma = solution.findPerson("Emma Watson II");
        Optional<Person> karolak = solution.findPerson("Tomasz Karolak");
        Assert.assertTrue(emma.isPresent());
        Assert.assertTrue(karolak.isPresent());
        Assert.assertFalse(solution.shortestPath(emma.get(), karolak.get()).isEmpty());
    }

    
    @Test
    public void testIntroduction() throws Exception {
        Optional<Person> emma = solution.findPerson("Emma Watson II");
        Optional<Person> karolak = solution.findPerson("Tomasz Karolak");
        Optional<Person> bill = solution.findPerson("Bill Murray I");
        Assert.assertTrue(emma.isPresent());
        Assert.assertTrue(karolak.isPresent());
        Assert.assertTrue(bill.isPresent());
        Assert.assertTrue(solution.whoWillIntroduce(emma.get(), karolak.get()).contains(bill.get()));
    }


}
