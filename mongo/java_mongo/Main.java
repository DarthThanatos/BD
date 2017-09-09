import java.net.UnknownHostException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import com.mongodb.AggregationOutput;
import com.mongodb.BasicDBObject;
import com.mongodb.DB;
import com.mongodb.DBCollection;
import com.mongodb.DBObject;
import com.mongodb.MapReduceCommand;
import com.mongodb.MapReduceOutput;
import com.mongodb.MongoClient;

public class Main{
	private MongoClient mongoClient;
	private DB db;
	
	public Main() throws UnknownHostException {
		mongoClient = new MongoClient();
		db = mongoClient.getDB("jeopardy");
	}
	
	public void showCollections(){
		for(String name : db.getCollectionNames()){
			System.out.println("colname: "+name);
		}
	}

	public void queryOne(){
		//db.question.find({show_number:{$gt:6290}}).sort({show_number:-1,air_date:-1}).limit(1)
		DBCollection question = db.getCollection("question");
		BasicDBObject sortFields = new  BasicDBObject("show_number",-1);
		sortFields.put("air_date", -1);
		DBObject res = question.find(new BasicDBObject("show_number",new BasicDBObject("$gt",6290))).sort(sortFields).limit(1).one();
		System.out.println(res);
	}
	
	public void queryTwo(){
		//db.question.aggregate([{$match:{$and:[{round:"Double Jeopardy!"},{show_number:{$gte:5000}}]}},{$group:{_id:"$show_number",count:{$sum:1}}},{$sort:{_id:-1}},{$limit:1}])
		DBCollection question = db.getCollection("question");
		List <DBObject> and_input = new ArrayList<DBObject>();
		and_input.add(new BasicDBObject("round","Double Jeopardy!"));
		and_input.add(new BasicDBObject("show_number",new BasicDBObject("$gte",5000)));
		DBObject match = new BasicDBObject("$match", new BasicDBObject("$and",and_input));
		DBObject groupFields = new BasicDBObject("_id","$show_number");
		groupFields.put("count", new BasicDBObject("$sum",1));
		DBObject group = new BasicDBObject("$group",groupFields);
		DBObject sort = new BasicDBObject("$sort",new BasicDBObject("_id",-1));
		DBObject limit = new BasicDBObject("$limit",1);
		List<DBObject> pipeline = Arrays.asList(match,group,sort,limit);
		AggregationOutput output = question.aggregate(pipeline);
		for (DBObject result : output.results()){
			System.out.println(result);
		}
	}
	
	public void queryThree(){
		DBCollection question = db.getCollection("question");
		String map = "    function map(){        if(this.category == \"EVERYBODY TALKS ABOUT IT...\")            emit(this.category,1);         if(this.show_number >= 5000)            emit(\"Amount of questions with show number bigger than 5k\",1);        if(this.air_date > new ISODate(\"2004-12-31T00:00:00.000Z\"))         emit(\"Amount of questions that were asked after 2004-12-31\",1)     }";
		String reduce = "function reduce(key,values){return Array.sum(values)}";
		MapReduceCommand cmd = new MapReduceCommand(question,map,reduce,null,MapReduceCommand.OutputType.INLINE,null);
		MapReduceOutput out = question.mapReduce(cmd);
		for(DBObject o : out.results()){
			System.out.println(o.toString());
		}
	}

	
	public static void main(String[] args) throws UnknownHostException {
		Main mongoLab = new Main();
		mongoLab.queryOne();
		//mongoLab.queryTwo();
		//mongoLab.queryThree();
	}

}

