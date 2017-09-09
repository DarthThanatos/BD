use [CodeFirst.Program+BlogContext]

select b.BlogId,b.Name,count(*) 
from posts p join blogs b
on p.BlogId = b.BlogId
group by b.BlogId,b.Name


select b.BlogId, p.Title
from Blogs b join Posts p
on b.BlogId = p.BlogId

select substring(b.name,0,1) as first_letter
from Blogs as b
group by substring(b.Name,0,1)
order by substring(b.name,0,1)