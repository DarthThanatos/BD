package pl.edu.agh.ki.bd.htmlIndexer.model;

import java.util.Set;

public class Word {
	private String content;
	private Set<Sentence> sentences;
	private long id;
	
	public Word(){}
	
	public void setId(long id){
		this.id = id;
	}
	public Word(String content){
		this.content = content;
	}
	
	
	public long getId(){
		return id;
	}
	
	public void setContent(String content){
		this.content = content;
	}
	
	public String getContent(){
		return content;
	}
	
	public void setSentences(Set<Sentence> sentences){
		this.sentences = sentences;
	}
	
	public Set<Sentence> getSentences(){
		return sentences;
	}

}
