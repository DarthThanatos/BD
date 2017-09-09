package pl.edu.agh.ki.bd.htmlIndexer;

import java.io.IOException;
import java.util.Date;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

import org.hibernate.Session;
import org.hibernate.Transaction;
import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;
import org.jsoup.nodes.Element;
import org.jsoup.select.Elements;

import pl.edu.agh.ki.bd.htmlIndexer.model.ProcessedUrl;
import pl.edu.agh.ki.bd.htmlIndexer.model.Sentence;
import pl.edu.agh.ki.bd.htmlIndexer.model.Word;
import pl.edu.agh.ki.bd.htmlIndexer.persistence.HibernateUtils;

public class Index 
{	
	private Session session;
	private Transaction transaction;
	
	boolean urlExists(String url){
		Session session = HibernateUtils.getSession();
		Transaction transaction = session.beginTransaction();
		List<Object> result=session.createQuery("select p from ProcessedUrl p where p.address like :param",Object.class).setParameter("param", url).getResultList();
		transaction.commit();
		session.close();
		if (result.isEmpty()) return false;
		return true;
	}
	
	public Sentence getSentence(String sentenceContent){
		List<Sentence> result=session.createQuery("select s from Sentence s where s.content like :param",Sentence.class).setParameter("param", sentenceContent).getResultList();
		if(result.isEmpty()){
			Sentence sentence = new Sentence(sentenceContent);
			sentence.setProcessedurls(new HashSet<ProcessedUrl>());
			sentence.setWords(new HashSet<Word>());
			session.saveOrUpdate(sentence);
			return sentence;
		}
		return result.get(0);
	}
	
	
	public Word getWord(String wordContent){
		List<Word> result=session.createQuery("select w from Word w where w.content like :param",Word.class).setParameter("param",wordContent).getResultList();
		if(result.isEmpty()){
			Word word = new Word(wordContent);
			word.setSentences(new HashSet<Sentence>());
			session.saveOrUpdate(word);
			return word;
		}
		return result.get(0);
	}
	
	public Set<Sentence> getWordSentences(String wordContent){
		Set<Sentence> result = new HashSet<Sentence>();
		result.addAll(session.createQuery("select s from Word w join w.sentences w where w.content like :param",Sentence.class).setParameter("param", wordContent).getResultList());
		return result;
	}
	
	public void indexWebPage(String url) throws IOException{
		if(urlExists(url)){
			System.out.println("URL already exists in Database. Rolling back...");
			return;
		}
				
		Document doc = Jsoup.connect(url).get();
		Elements elements = doc.body().select("*");
		session = HibernateUtils.getSession();
		transaction = session.beginTransaction();
		ProcessedUrl processedUrl = new ProcessedUrl(url, new Date());
		Set<Sentence> sentencesForParsedUrl = new HashSet<Sentence>();
		session.saveOrUpdate(processedUrl);
		for (Element element : elements) 
		{
			if (element.ownText().trim().length() > 1)
			{
				for (String sentenceContent : element.ownText().split("\\. "))
				{
					Sentence sentence = getSentence(sentenceContent);
					HashSet<Word> wordsForSentence = new HashSet<Word>();
					String[] words = sentenceContent.split("\\s+");
					for (int i = 0; i < words.length; i++) {
						Word word = getWord(words[i]);
						Set<Sentence> sentencesForWord = word.getSentences();
						sentencesForWord.add(sentence);
						word.setSentences(sentencesForWord);
						wordsForSentence.add(word);
					}
					sentence.setWords(wordsForSentence);
					Set<ProcessedUrl> processedurls = sentence.getProcessedurls();
					processedurls.add(processedUrl);
					sentence.setProcessedurls(processedurls);
					sentencesForParsedUrl.add(sentence);
				}
			}
		}
		processedUrl.setSentences(sentencesForParsedUrl);
		transaction.commit();
		session.close();	
		System.out.println("Indexed: " + url);	
	}	
	
	public List<Object[]> findSentencesByWords(String words)
	{
		//select s.id, p.url 
		//from sentence s join sentence_words sw 
		//on s.id = sw.sentence_id 
		// join word w 
		// on sw.word_id = w.id
		// join processedurl p
		// on p.processedurl = s.processed_url_id
		// where w.content like 'Jan' or 
		//		 w.content like 'franciszek' or
		// 		 w.content like 'Miodek'
		// group by s.id 
		// order by count(*) desc => 8 columns
		
		String where_query[] = words.split("\\s+");
		String sql_query = "select s, p "
				+ "from ProcessedUrl p "
				+ "join p.sentences s "
				+ "join s.words w "
				+ "where w.content like '" + where_query[0] +"'";
		for(int i = 1; i < where_query.length; i++){
			sql_query += " or w.content like '" + where_query[i] +"'";
		}
		sql_query += " group by s order by count(*) desc";
		Session session = HibernateUtils.getSession();
		Transaction transaction = session.beginTransaction();
		List<Object[]> result =  session.createQuery(sql_query, Object[].class).getResultList();
		
		transaction.commit();
		session.close();
		
		return result;
	}	
	
	public List<Object> findSentencesLongerThan(int length){
		/*
		 select s.id 
		 from sentence s join sentence_words sw
		 on s.id = sw.sentence_id
		 join word w 
		 on w.id = sw.word_id
		 group by s.id
		 having count(*) > 10 => 43 columns
		 */
		
		Session session = HibernateUtils.getSession();
		Transaction transaction = session.beginTransaction();
		String query = 
				"select s "
				+"from Sentence s join s.words w "
				+"group by s.id "
				+ "having count (*) > :param";
		List<Object> result = session.createQuery(query, Object.class)
				.setParameter("param",(long) length)
				.getResultList();
		transaction.commit();
		session.close();
		return result;
	}
	
	public List<Object[]> sortUrls(){
		Session session = HibernateUtils.getSession();
		Transaction transaction = session.beginTransaction();
		String query = 
				"select p.address, count(*) as c_count"
				+ " from ProcessedUrl p "
				+ "join p.sentences s "
				+ "group by p.id "
				+ "order by c_count desc";
		List<Object[]> result = session.createQuery(query, Object[].class)
				.getResultList();
		transaction.commit();
		session.close();
		return result;
	}	
	
	public List<Object> amountOfWordInIndex(String input){
		Session session = HibernateUtils.getSession();
		Transaction transaction = session.beginTransaction();
		// select count(*)
		// from word w join sentence_words sw
		// on sw.word_id = w.id
		// join sentence s 
		// on s.id = sw.sentence_id
		// where w.content like 'jan'
		// group by w.id
		
		String query = 
				"select count(*) "
				+ "from Word w "
				+ "join w.sentences s "
				+ "where w.content like :param "
				+ "group by w ";
		
		String word = input.split("\\s+")[1];
		
		List<Object> result = session.createQuery(query, Object.class)
				.setParameter("param", word)
				.getResultList();
		transaction.commit();
		session.close();
		return result;
	}
}
