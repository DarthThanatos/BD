package pl.edu.agh.ki.bd.htmlIndexer.model;

import java.util.Set;


public class Sentence {
	
	private long id;
	private Set<ProcessedUrl> processedurls;
	private Set<Word> words;
	private String content;
	
	public Sentence() 
	{
	}
	
	public Sentence(String sentenceContent){
		content = sentenceContent;
	}
	
	public long getId() {
		return id;
	}
	public void setId(long id) {
		this.id = id;
	}
	
	public void setContent(String content){
		this.content = content;
	}
	
	public String getContent(){
		return this.content;
	}
	
	public void setProcessedurls(Set<ProcessedUrl> processedurls){
		this.processedurls = processedurls;
	}
	
	public Set<ProcessedUrl> getProcessedurls(){
		return this.processedurls;
	}
	
	public void setWords(Set<Word> words){
		this.words = words;
	}
	
	public Set<Word> getWords(){
		return words;
	}
	
}
