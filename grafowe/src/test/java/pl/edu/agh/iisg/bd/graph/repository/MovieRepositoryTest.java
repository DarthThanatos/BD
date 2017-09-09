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
public class MovieRepositoryTest {

    @Autowired
    MovieRepository movieRepository;

    @Test
    public void testRepository() throws Exception {
        Assert.assertTrue(movieRepository.count() > 0);
    }

}
