//use jeopardy
/*db.question.find().forEach( function (x) {   
  x.air_date = new ISODate(x.air_date); // convert field to string
  db.question.save(x);
});
db.question.find().forEach( function (x) {   
  x.show_number = new NumberInt(x.show_number); // convert field to string
  db.question.save(x);
});*/
/*1*/db.question.find({show_number:{$gt:6290}}).sort({show_number:-1,air_date:-1}).limit(1)
///*2*/db.question.aggregate([{$match:{$and:[{round:"Double Jeopardy!"},{show_number:{$gte:6290}}]}},{$group:{_id:"$show_number",count:{$sum:1}}},{$sort:{_id:-1}},{$limit:1}])
/*3*//*db.question.mapReduce(
    function map(){
        if(this.category == "EVERYBODY TALKS ABOUT IT...")
            emit(this.category,1); 
        if(this.show_number >= 5000) 
            emit("Amount of questions with show number bigger than 5k",1); 
        if(this.air_date > new ISODate("2004-12-31T00:00:00.000Z"))
            emit("Amount of questions that were asked after 2004-12-31",1)
     }, 
    function reduce(key,values){return Array.sum(values)},
    {out:"homework_mapRed"})*/