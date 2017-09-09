package pl.edu.agh.iisg.bd.graph.repository;

import org.springframework.data.neo4j.annotation.Query;
import org.springframework.data.neo4j.repository.GraphRepository;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import pl.edu.agh.iisg.bd.graph.model.Movie;
import pl.edu.agh.iisg.bd.graph.model.Person;

@Repository
public interface MovieRepository extends GraphRepository<Movie> {
	
	
	Movie findByTitle(@Param("name") String name);
	
	@Query("match (p: Person{name:{0}}), (m: Movie{title:{1}}) create (p)-[:ACTED_IN]->(m)")
	void createPersonMovieRelationship(String personName, String movieTitle);
	
	
}
