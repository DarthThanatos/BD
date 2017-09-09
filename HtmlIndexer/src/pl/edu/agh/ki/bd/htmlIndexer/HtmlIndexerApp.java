package pl.edu.agh.ki.bd.htmlIndexer;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.Date;

import pl.edu.agh.ki.bd.htmlIndexer.model.ProcessedUrl;
import pl.edu.agh.ki.bd.htmlIndexer.model.Sentence;
import pl.edu.agh.ki.bd.htmlIndexer.persistence.HibernateUtils;

public class HtmlIndexerApp 
{

	public static void main(String[] args) throws IOException
	{
		HibernateUtils.getSession().close();

		BufferedReader bufferedReader = new BufferedReader(new InputStreamReader(System.in));
		Index indexer = new Index(); 
		
		while (true)
		{
			System.out.println("\nHtmlIndexer [? for help] > : ");
			String command = bufferedReader.readLine();
	        long startAt = new Date().getTime();

			if (command.startsWith("?"))
			{
				System.out.println("'?'      	- print this help");
				System.out.println("'x'      	- exit HtmlIndexer");
				System.out.println("'i URLs'  	- index URLs, space separated");
				System.out.println("'f WORDS'	- find sentences containing all WORDs, space separated, sort in order of number of words matched, prints also url of a sentence's site");
				System.out.println("'l len'	- find sentences whose lengths are bigger than len");
				System.out.println("'c'	- print urls, first come those with the biggest sentences counter");
				System.out.println("'w WORD'  - count how many times a word is present in all sentences (if a sentence has two or more occurences of this word, it is counted only once)");
			}
			else if (command.startsWith("x"))
			{
				System.out.println("HtmlIndexer terminated.");
				HibernateUtils.shutdown();
				break;				
			}
			else if (command.startsWith("i "))
			{
				for (String url : command.substring(2).split(" "))
				{
					try {
						indexer.indexWebPage(url);
					} catch (Exception e) {
						System.out.println("Error indexing: " + e.getMessage());
					}
				}
			}
			else if (command.startsWith("f "))
			{
 				for (Object sentence[] : indexer.findSentencesByWords(command.substring(2)))
				{
					System.out.println("Found in sentence: " + ((Sentence)sentence[0]).getId() + " url: " + ((ProcessedUrl)sentence[1]).getAddress());
				}
			}
			else if(command.startsWith("l ")){
				int length = Integer.parseInt(command.substring(2));
				System.out.println("Sentence ids of sentences longer than " + length);
				for ( Object result : indexer.findSentencesLongerThan(length)){
					System.out.println(((Sentence)result).getId());
				}
			}
			else if(command.startsWith("c")){
 				for (Object[] len_info : indexer.sortUrls())
				{
					System.out.println("url: " + len_info[0] + " sum: " + len_info[1]);
				}
			}
			else if(command.startsWith("w ")){
				String word = command.substring(1);
				long amount = 0;
				for (Object res : indexer.amountOfWordInIndex(word)) amount = (long)res;
				System.out.println("Amount of the word " + word.split("\\s+")[1] + " in the index: " + amount);
			}
			System.out.println("took "+ (new Date().getTime() - startAt)+ " ms");		

		}

	}

}
