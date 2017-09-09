package pl.edu.agh.iisg.bd.graph.repository;

import org.springframework.data.neo4j.annotation.Query;
import org.springframework.data.neo4j.repository.GraphRepository;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import pl.edu.agh.iisg.bd.graph.model.Person;

import java.util.List;
import java.util.Map;

@Repository
public interface PersonRepository extends GraphRepository<Person> {

    Person findByName(@Param("name") String name);

    @Query("MATCH (p:Person) WHERE p.name CONTAINS {name} RETURN p")
    List<Person> findByNameContaining(@Param("name") String name);
    
    @Query("MATCH (emma:Person{name:{emma}})-[:ACTED_IN]->(movie0)<-[:ACTED_IN]-(coActors)-[:ACTED_IN]->(movie1)<-[:ACTED_IN]-(karolak:Person{name:{karolak}}) RETURN coActors")
    List<Person> findCoActors(@Param("emma") String name1, @Param("karolak") String name2);
    
    @Query("match p = shortestPath((emma:Person{name:{0}})-[*]-(karolak:Person{name:{1}})) return p")
    List<Map<String,Object>> findShortestPath(String name1, String name2);
    
    @Query("match (p:Person{name:{0}}) detach delete p")
    void deletePerson(String name);

}
