namespace CodeFirst.Migrations
{
    using System;
    using System.Data.Entity.Migrations;
    
    public partial class delposturl : DbMigration
    {
        public override void Up()
        {
            DropColumn("dbo.Posts", "URL");
        }
        
        public override void Down()
        {
            AddColumn("dbo.Posts", "URL", c => c.String());
        }
    }
}
