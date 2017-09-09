using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using static CodeFirst.Program;

namespace CodeFirst
{
    public class Category
    {
        public int CategoryId { get; set; }
        public string Name { get; set; }
        public virtual List<Blog> Blogs { get; set; }
        public void printSelf()
        {
            Console.WriteLine("Id: {0}, Name: {1}", CategoryId, Name);
        }
    }
}
