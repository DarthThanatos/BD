using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Data.Entity;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using static CodeFirst.Program;

namespace CodeFirst
{
    public partial class BlogForm : Form
    {
        public BlogForm()
        {
            InitializeComponent();
        }
        
        public BlogContext db { get; set; }

        private void BlogForm_Load(object sender, EventArgs e)
        {
            db.blogs.Load();
            this.program_BlogBindingSource.DataSource = db.blogs.Local.ToBindingList();
            //this.postsDataGridView.DataSource = db.posts.Local.ToBindingList();
        }


        private void save_btn_Click(object sender, EventArgs e)
        {
            this.Validate();
            foreach(var post in db.posts) {
                    if (post.blog == null)
                {
                    Console.WriteLine("Deleted {0} id {1}",post.Title, post.PostId);
                    db.posts.Remove(post);
                }
            }
            db.SaveChanges();
            this.postsDataGridView.Refresh();
            this.program_BlogDataGridView.Refresh();
        }

        private void program_BlogDataGridView_CellContentClick(object sender, DataGridViewCellEventArgs e)
        {
            Console.WriteLine("Blogs");

        }

        private void postsDataGridView_CellContentClick(object sender, DataGridViewCellEventArgs e)
        {
            Console.WriteLine("Posts");
        }
    }
}
