namespace CodeFirst.Migrations
{
    using System;
    using System.Data.Entity.Migrations;
    
    public partial class post_url : DbMigration
    {
        public override void Up()
        {
            AddColumn("dbo.Posts", "URL", c => c.String());
        }
        
        public override void Down()
        {
            DropColumn("dbo.Posts", "URL");
        }
    }
}
