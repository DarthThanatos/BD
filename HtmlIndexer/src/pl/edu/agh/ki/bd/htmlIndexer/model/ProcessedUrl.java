package pl.edu.agh.ki.bd.htmlIndexer.model;

import java.util.Date;
import java.util.Set;

public class ProcessedUrl {
	
	private long processedUrl;
	private String address;
	private Date date;
	private Set<Sentence> sentences;
	
	public ProcessedUrl() 
	{
	}
	
	public ProcessedUrl(String address, Date date)
	{
		this.setDate(date);
		this.setAddress(address);
	}
	
	public long getProcessedUrl() {
		return processedUrl;
	}
	public void setProcessedUrl(long processedUrl) {
		this.processedUrl = processedUrl;
	}

	public void setAddress(String address){
		this.address = address;
	}
	
	public String getAddress(){
		return this.address;
	}
	
	public Date getDate() {
		return this.date;
	}

	public void setDate(Date date) {
		this.date = date;
	}

	public void setSentences(Set<Sentence> sentences){
		this.sentences = sentences;
	}
	
	public Set<Sentence> getSentences(){
		return this.sentences;
	}
}