package pl.edu.agh.iisg.bd.graph.model;

import org.neo4j.ogm.annotation.GraphId;
import org.neo4j.ogm.annotation.NodeEntity;
import org.neo4j.ogm.annotation.Relationship;

import java.util.HashSet;
import java.util.Set;

@NodeEntity
public class Person {

    @GraphId
    private Long id;

    private String name;

    private int imdbId;

    private String gender;

    @Relationship(type = "ACTED_IN")
    private Set<Movie> movies = new HashSet<>();

    private Person() {
    }

    public Person(String name, int imdbId, String gender) {
        this.name = name;
        this.imdbId = imdbId;
        this.gender = gender;
    }

    public void actedIn(final Movie movie) {
        movies.add(movie);
        movie.getActors().add(this);
    }

    public Long getId() {
        return id;
    }

    public String getName() {
        return name;
    }

    public int getImdbId() {
        return imdbId;
    }

    public String getGender() {
        return gender;
    }

    public Set<Movie> getMovies() {
        return movies;
    }

    @Override
    public String toString() {
        return "Person{" +
                "id=" + id +
                ", name='" + name + '\'' +
                ", imdbId=" + imdbId +
                ", gender='" + gender + '\'' +
                '}';
    }
}
