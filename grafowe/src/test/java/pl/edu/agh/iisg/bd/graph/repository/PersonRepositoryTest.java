package pl.edu.agh.iisg.bd.graph.repository;

import org.junit.Assert;
import org.junit.Ignore;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.junit4.SpringRunner;

@RunWith(SpringRunner.class)
@SpringBootTest
@Ignore
public class PersonRepositoryTest {

    @Autowired
    PersonRepository personRepository;

    @Test
    public void testRepository() throws Exception {
        Assert.assertTrue(personRepository.count() > 0);
    }

    @Test
    public void testEmma() throws Exception {
        Assert.assertNotNull(personRepository.findByName("Emma Watson II"));
        Assert.assertNotNull(personRepository.findByName("Emma Watson II").getMovies());
        Assert.assertFalse(personRepository.findByName("Emma Watson II").getMovies().isEmpty());
    }

    @Test
    public void testContainingEmma() throws Exception {
        Assert.assertFalse(personRepository.findByNameContaining("Emma Watson").isEmpty());
    }

}
