using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Data.Entity;
using System.ComponentModel.DataAnnotations;
using System.Windows.Forms;
using System.Data.Entity.Core.Objects;
using System.Linq.Expressions;

// update-database -targetmigration:""

namespace CodeFirst
{
    public class Program
    {
        static void fillDB(BlogContext db)
        {
            Console.WriteLine("Type the name of blogs:");
            var names = Console.ReadLine();
            foreach (string name in names.Split())
            {
                Blog blog = new Blog { Name = name, Posts = new List<Post>() };
                Console.WriteLine("Type the name of posts for blog {0}:", blog.Name);
                var posts = Console.ReadLine();
                foreach (var post in posts.Split())
                {
                    if (post != "")
                        blog.Posts.Add(new Post { Title = post, blog = blog });
                }
                db.blogs.Add(blog);
            }
            try
            {
                db.SaveChanges();
            }
            catch (Exception e)
            {
                Console.WriteLine(e.ToString());
            }

        }

        static void selectBlogNames(BlogContext db)
        {
            var query = from b in db.blogs
                        orderby b.Name descending
                        select b;
            var method_query = (db.blogs.Select(o => o.Name)).ToArray();
            Console.WriteLine("\nqeury syntax:");
            foreach (var b in query)
            {
                Console.WriteLine(b.Name);
            }

            Console.WriteLine("\nmethod-based syntax:");
            foreach (var elem in method_query)
            {
                Console.WriteLine(elem);
            }
        }

        static void postsUseJoins(BlogContext db)
        {
            var query = from b in db.blogs
                        join p in db.posts
                        on b.BlogId equals p.BlogId
                        select new
                        {
                            BlogId = b.BlogId,
                            PostId = p.PostId,
                            BlogName = b.Name,
                            PostName = p.Title
                        };

            Console.WriteLine("Query:");
            foreach (var obj in query)
            {
                Console.WriteLine("BlogId:{0},PostId:{1},BlogName:{2},PostName:{3}", obj.BlogId, obj.PostId, obj.BlogName,obj.PostName);
            }

            var method_based = db.blogs.Join(
                    db.posts, 
                    blog => blog.BlogId, //primary key of prime collection
                    post => post.BlogId, //foraign key of joined collection
                    (blog,post) => // "select" 
                    new {
                        BlogId = blog.BlogId,
                        PostId = post.PostId,
                        BlogName = blog.Name,
                        PostName = post.Title
                    }
                );

            Console.WriteLine("\nMethod based:");
            foreach (var obj in query)
            {
                Console.WriteLine("BlogId:{0},PostId:{1},BlogName:{2},PostName:{3}", obj.BlogId, obj.PostId, obj.BlogName, obj.PostName);
            }
        }

        static void navProps_QuerySyntax(BlogContext db)
        {
            var query = from b in db.blogs
                        from p in b.Posts
                        select new
                        { BlogId = b.BlogId, PostId = p.PostId, BlogName = b.Name, PostName = p.Title };
            foreach (var obj in query)
                Console.WriteLine("BlogId:{0},PostId:{1},BlogName:{2},PostName:{3}", obj.BlogId, obj.PostId, obj.BlogName, obj.PostName);
        }


        static void navProp_MetSyntax(BlogContext db)
        {
            /*var query = db.blogs.Select(b => b.Posts);
            foreach(var obj in query)
            {
                foreach (var p in obj)
                    Console.WriteLine(p.Title);
            }*/
            var query_many = db.blogs.SelectMany( //select many flattens list of lists to a result list
                b => b.Posts, 
                (b, p) => new {BlogId = b.BlogId, PostId = p.PostId, BlogName = b.Name, PostName = p.Title}
            );
            foreach (var obj in query_many)
                Console.WriteLine("BlogId:{0},PostId:{1},BlogName:{2},PostName:{3}", obj.BlogId, obj.PostId, obj.BlogName, obj.PostName);
            var query_simple = db.blogs.SelectMany(b => b.Posts, (b,p)=>new { Blog = b, Post = p });
            foreach(var obj in query_simple)
            {
                Console.WriteLine("{0},{1},{2},{3}",obj.Blog.BlogId, obj.Post.PostId,obj.Blog.Name,obj.Post.Title);
            }
        }


        static void lazyLoading(BlogContext db)
        {
            db.Configuration.LazyLoadingEnabled = true;
            //Only blogs for now
            IList<Blog> blogs = db.blogs.ToList<Blog>();
            //now posts
            foreach(Blog blog in blogs)
            {
                try
                {
                    //first count without loading
                    var postsAmount = db.Entry(blog).Collection(b => b.Posts).Query().Count<Post>();
                    Console.WriteLine("\n===\n{0} has {1} posts:\n===\n", blog.Name,postsAmount);
                    db.Entry(blog).Collection(b => b.Posts).Load();
                    foreach (Post post in blog.Posts)
                    {
                        Console.WriteLine(post.Title);
                    }
                }catch(Exception e)
                {
                    Console.WriteLine(e.Message);
                }
            }
        }



        static void eagerLoading(BlogContext db)
        {
            //blogs with its posts
            //var blogs = db.blogs.Include(b => b.Posts);
            var blogs = db.blogs.Include("Posts");
            foreach (Blog blog in blogs)
            {
                try
                {
                    Console.WriteLine("\n===\n{0}\n===\n", blog.Name);
                    foreach (Post post in blog.Posts.ToList<Post>())
                    {
                        Console.WriteLine(post.Title);
                    }
                }
                catch (Exception e)
                {
                    Console.WriteLine(e.Message);

                }
            }
        }

        static void countPostsInBlog(BlogContext db)
        {
            var query = from b in db.blogs
                        join p in db.posts
                        on b.BlogId equals p.BlogId into g
                        select new
                        {
                            Blog = b.Name,                
                            TotalAmount = g.Count()
                        };
            Console.WriteLine("query syntax:\n");
            foreach (var obj in query)
            {
                Console.WriteLine("blog: {0} has {1} posts",obj.Blog,obj.TotalAmount);
            }

            Console.WriteLine("\nMethod syntax:\n");
            var method_query = db.blogs.GroupJoin(
                    db.posts,
                    blog => blog.BlogId,
                    post => post.BlogId,
                    (blog,g) => new
                    {
                        BlogName = blog.Name,
                        Total = g.Count() 
                    }
                );
            foreach (var obj in method_query)
            {
                Console.WriteLine("blog: {0} has {1} posts", obj.BlogName, obj.Total);
            }
        }


        // =============================================================================
        //HOMEWORK
        //==============================================================================

        static void addCategory(BlogContext db)
        {
            Console.WriteLine("Type the name of the Category:");
            var name = Console.ReadLine();
            var check = from c in db.categories
                        where name == c.Name
                        select c;
            if (check.Count() != 0)
            {
                Console.WriteLine("There already is the category of name " + name);
            }
            else
            {
                var amountOfCategories = (from c in db.categories
                                         select c).Count(); 
                // ^ everything is imediately loaded, so our category won't be included here...
                Console.WriteLine("There are {0} categories in the db", amountOfCategories); //...because we add it here and not before Count()
                db.categories.Add(new Category { Name = name });
                db.SaveChanges();
                Console.WriteLine("Category " + name + " added successfully");
            }
        }

        static void addUser(BlogContext db)
        {
            Console.WriteLine("Type the name of the User:");
            var name = Console.ReadLine();
            
            var check = db.users.Select(u => u).Where(u => u.UserName == name);
            if (check.Count() != 0)
            {
                Console.WriteLine("There already is the user of name " + name);
            }
            else
            {
                var users = from u in db.users
                            select u; // deffered lading - query is here, before adding new user to db...
                db.users.Add(new User { UserName = name });
                db.SaveChanges();
                Console.WriteLine("User " + name + " added successfully, Situation at the moment:");
                foreach (var user in users) user.printSelf(); // but he will be printed automagically here anyway
            }

        }

        static void addPost(BlogContext db)
        {
            Console.WriteLine("Type the title of the Post:");
            var title = Console.ReadLine();
            var check = from p in db.posts
                        where title == p.Title
                        select p;
            if (check.Count() != 0)
            {
                Console.WriteLine("There already is the post of title " + title);
                return;
            }
            Console.WriteLine("Type the name of the user that adds this post:");
            var userName = Console.ReadLine();
            var user = from u in db.users
                       where u.UserName == userName
                       select u;
            if (user.Count() == 0)
            {
                Console.WriteLine("No such user, exiting");
                return;
            }
            Console.WriteLine("Type the name of the blog to which this post belongs");
            var blogName = Console.ReadLine();
            var blog = db.blogs.Where(b => b.Name == blogName);
            if (blog.Count() == 0)
            {
                Console.WriteLine("No such blog, exiting");
                return;
            }
            Post post = new Post { Title = title, blog = blog.First(), user = user.First() };
            db.posts.Add(post);
            blog.First().Posts.Add(post);
            user.First().Posts.Add(post);
            Console.WriteLine("Post " + title + " added successfully");
            db.SaveChanges();
        }

        static void addBlog(BlogContext db)
        {
            Console.WriteLine("Type the name of the new blog");
            var blogName = Console.ReadLine();
            var blog = from b in db.blogs
                       where b.Name == blogName
                       select b;
            if (blog.Count() != 0)
            {
                Console.WriteLine("There already is a blog of name " + blogName + "; exiting");
                return;
            }
            Console.WriteLine("Type the name of the Category that blog belongs to: ");
            var categoryName = Console.ReadLine();
            var category = db.categories.Where(c => c.Name == categoryName);
            if (category.Count() == 0)
            {
                Console.WriteLine("There is no such category: " + categoryName + "in database. Exiting");
                return;
            }
            Blog newBlog = new Blog { Name = blogName, category = category.First() };
            db.blogs.Add(newBlog);
            category.First().Blogs.Add(newBlog);
            db.SaveChanges();
            Console.WriteLine("Blog " + blogName + " added successfully");
        }

        static void selectUsers(BlogContext db) {
            var users = db.users.ToArray();
            foreach (User u in users) u.printSelf();
        }

        static void selectBlogs(BlogContext db)
        {
            var blogs = db.blogs.ToArray();
            foreach(Blog blog in blogs)
            {
                blog.printSelf();
            }
        }

        static void selectCategories(BlogContext db)
        {
            var cats = db.categories.ToArray();
            foreach(Category cat in cats)
            {
                cat.printSelf();

            }
        }

        static void selectPosts(BlogContext db)
        {
            var posts = from p in db.posts
                        select p;
            foreach(Post post in posts)
            {
                post.printSelf();
            }
        }

        static void selectParticularPosts(BlogContext db)
        {
            Console.WriteLine("Type titles of posts, separated by spaces: ");
            var titles = Console.ReadLine().Split();
            var posts = db.posts.Where(b => titles.Contains(b.Title));
            foreach (var post in posts)
            {
                post.printSelf();
            }
        }

        static void selectParticularUSers(BlogContext db)
        {
            Console.WriteLine("Type user names, separated by spaces: ");
            var userNames = Console.ReadLine().Split();
            var users = from u in db.users
                        where userNames.Contains(u.UserName)
                        select u;

            foreach (var user in users)
            {
                user.printSelf();
            }
        }

        static void postInfoJoin(BlogContext db)
        {
            var posts = from u in db.users
                        join p in db.posts
                        on u.UserName equals p.user.UserName
                        join b in db.blogs
                        on p.BlogId equals b.BlogId
                        select p;
            foreach(var post in posts)
            {
                Console.WriteLine("\n=======\n");
                Console.WriteLine("PostInfo:");
                post.printSelf();
                Console.WriteLine("\nUserInfo:");
                post.user.printSelf();
                Console.WriteLine("\nBlogInfo:");
                post.blog.printSelf();
                Console.WriteLine("\n=======\n");

            }

        }

        static void statistics_LazyLoading(BlogContext db)
        {

            db.Configuration.LazyLoadingEnabled = true;
            //Only users
            IList<User> users = db.users.ToList<User>();
            foreach (User user in users)
            {
                var postsAmount = db.Entry(user).Collection(u => u.Posts).Query().Count<Post>();
                Console.WriteLine("User: {0} has written: {1} posts", user.UserName, postsAmount);
            }
            Console.WriteLine("\n");
            //Only categories
            IList<Category> categories = db.categories.ToList<Category>();
            foreach (Category cat in categories)
            {
                var blogsAmount = db.Entry(cat).Collection(c => c.Blogs).Query().Count<Blog>();
                Console.WriteLine("Category: {0} has: {1} posts",cat.Name, blogsAmount);

            }
            Console.WriteLine("\n");
            //Only blogs for now
            IList<Blog> blogs = db.blogs.ToList<Blog>();
            foreach (Blog blog in blogs)
            {
                var postsAmount = db.Entry(blog).Collection(b => b.Posts).Query().Count<Post>();
                Console.WriteLine("Blog: {0} has: {1} posts",blog.Name, postsAmount);
            }
        }

        static void blogInfoGroupJoin(BlogContext db)
        {
            var blog_group = db.blogs.Include("Posts").Include("category")//here we have eager loading of all blog's posts - since we need to load them anyway - and its category
                .GroupJoin(db.posts,
                    b => b.BlogId,
                    p=> p.BlogId,
                    (b,g) => new {blog = b, posts = g}
                 );
            foreach(var blog_struct in blog_group)
            {
                Console.WriteLine("\n=======\n");
                Console.WriteLine("\nBlog: ");
                blog_struct.blog.printSelf();
                Console.WriteLine("\nCategory of the blog: ");
                blog_struct.blog.category.printSelf();
                Console.WriteLine("\nBlog's posts' list: ");
                foreach(var post in blog_struct.posts)
                {
                    post.printSelf();
                }
                Console.WriteLine("\nTotal Amount of posts: {0}", blog_struct.posts.Count());
                Console.WriteLine("\n=======\n");
            }

        }

            static void interactive(BlogContext db)
        {
            bool shouldContinue = true;
            while (shouldContinue)
            {
                Console.Write("\nWhat do you want to do?\n" +
                    "1 - add a Category\n" + 
                    "2 - add a new User (deffered loading of result)\n" +
                    "3 - Add new Post\n" + 
                    "4 - add new blog\n" + 
                    "b - select list of blogs\n" + 
                    "p - select list of posts\n" + 
                    "c - select list of categories\n" + 
                    "u - select list of users\n" +
                    "<UPArrow> - print info about posts of the particular titles (where contains method syntax)\n" +
                    "<DownArrow> - print info about users (query syntax)\n" + 
                    "i - for each post in db print info about the user who added it and the blog it belongs to (query syntax + Nav Properties)\n" + 
                    "s - print statistics: for each user print total amount of his posts, for each category print total amount of its blogs, foreach\nblog print total amount of its posts (lazy loading)\n" +
                    "g - for each blog in db print info about its category and list info about each of its posts(eager loading + navigation\nprops + method syntax group join)\n" + 
                    "x - exit: ");
                var option = Console.ReadKey();
                Console.WriteLine();
                switch (option.Key)
                {
                    case ConsoleKey.D1:
                        addCategory(db);
                        break;
                    case ConsoleKey.D2:
                        addUser(db);
                        break;
                    case ConsoleKey.D3:
                        addPost(db);
                        break;
                    case ConsoleKey.D4:
                        addBlog(db);
                        break;
                    case ConsoleKey.X:
                        shouldContinue = false;
                        break;
                    case ConsoleKey.U:
                        selectUsers(db);
                        break;
                    case ConsoleKey.B:
                        selectBlogs(db);
                        break;
                    case ConsoleKey.C:
                        selectCategories(db);
                        break;
                    case ConsoleKey.P:
                        selectPosts(db);
                        break;
                    case ConsoleKey.UpArrow:
                        selectParticularPosts(db);
                        break;
                    case ConsoleKey.DownArrow:
                        selectParticularUSers(db);
                        break;
                    case ConsoleKey.I:
                        postInfoJoin(db);
                        break;
                    case ConsoleKey.S:
                        statistics_LazyLoading(db);
                        break;
                    case ConsoleKey.G:
                        blogInfoGroupJoin(db);
                        break;
                    default:
                        Console.WriteLine("\n" + option + ": not a known option\n");
                        break;
                }
                Console.WriteLine("<<Press Sth to continue>>");
                var continueKey = Console.ReadKey();
            }
        }
        
        static void Main(string[] args)
        {
            using (var db = new BlogContext())
            // ^ to ensure that after using this context its resources are freed correctly
            {
                interactive(db);
                //lazyLoading(db);

                /*Application.EnableVisualStyles();
                Application.SetCompatibleTextRenderingDefault(false);
                Application.Run(new BlogForm() {db = db });*/     
            }
        }


        public class User
        {
            [Key]
            public string UserName { get; set; }
            public string Description { get; set; }
            public virtual List<Post> Posts { get; set; }
            public void printSelf()
            {
                Console.WriteLine("UserNAme: {0}, Description: {1}", UserName, Description);
            }
        }

        public class Blog
        {
            public int BlogId { get; set; }
            public string Name { get; set; }
            public string URL { get; set; }
            public virtual List<Post> Posts {get; set; }
            public virtual Category category { get; set; }
            public void printSelf()
            {
                Console.WriteLine("Id: {0}, Name: {1}, URL: {2}", BlogId, Name, URL);
            }
        }
        


        public class Post
        {
            public int PostId { get; set; }
            public string Title { get; set; }
            public string Content { get; set; }
            public int BlogId { get; set; }
            public virtual Blog blog { get; set; }
            public virtual User user { get; set; }
            public void printSelf()
            {
                Console.WriteLine("Id: {0}, Title: {1}, Content: {2}", PostId, Title,Content);
            }
        }


        public class BlogContext : DbContext
        {
            public DbSet<Blog> blogs { get; set; }
            public DbSet<Post> posts { get; set; } 
            public DbSet<User> users { get; set; }
            public DbSet<Category> categories { get; set; }

            protected override void OnModelCreating(DbModelBuilder modelBuilder)
            {
                modelBuilder.Entity<User>().
                    Property(u => u.Description)
                    .HasColumnName("DetailedDescription");
                modelBuilder.Entity<Post>()
                    .HasRequired(p => p.user)
                    .WithMany(u => u.Posts)
                    .Map(m => m.MapKey("UserName"));
                modelBuilder.Entity<Blog>()
                    .HasRequired(b => b.category)
                    .WithMany(c => c.Blogs)
                    .Map(m => m.MapKey("CategoryId"));
            }
        }
    }
}
