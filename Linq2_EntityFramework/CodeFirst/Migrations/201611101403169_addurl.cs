namespace CodeFirst.Migrations
{
    using System;
    using System.Data.Entity.Migrations;
    
    public partial class addurl : DbMigration
    {
        public override void Up()
        {
            AddColumn("dbo.Blogs", "URL", c => c.String());
        }
        
        public override void Down()
        {
            DropColumn("dbo.Blogs", "URL");
        }
    }
}
