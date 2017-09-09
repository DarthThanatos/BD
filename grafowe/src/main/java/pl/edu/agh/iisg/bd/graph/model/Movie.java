package pl.edu.agh.iisg.bd.graph.model;

import org.neo4j.ogm.annotation.GraphId;
import org.neo4j.ogm.annotation.NodeEntity;
import org.neo4j.ogm.annotation.Relationship;

import java.util.HashSet;
import java.util.Set;

@NodeEntity
public class Movie {

    @GraphId
    private Long id;

    private String title;

    private int imdbId;

    private String kind;

    private int year;

    @Relationship(type="ACTED_IN", direction = Relationship.INCOMING)
    private Set<Person> actors = new HashSet<>();

    private Movie() {
    }

    public Movie(String title, int imdbId, String kind, int year) {
        this.title = title;
        this.imdbId = imdbId;
        this.kind = kind;
        this.year = year;
    }

    public Long getId() {
        return id;
    }

    public String getTitle() {
        return title;
    }

    public int getImdbId() {
        return imdbId;
    }

    public String getKind() {
        return kind;
    }

    public int getYear() {
        return year;
    }

    public Set<Person> getActors() {
        return actors;
    }

    @Override
    public String toString() {
        return "Movie{" +
                "id=" + id +
                ", title='" + title + '\'' +
                ", imdbId=" + imdbId +
                ", kind='" + kind + '\'' +
                ", year=" + year +
                '}';
    }
}
