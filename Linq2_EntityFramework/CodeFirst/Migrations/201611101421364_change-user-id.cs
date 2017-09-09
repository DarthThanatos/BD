namespace CodeFirst.Migrations
{
    using System;
    using System.Data.Entity.Migrations;
    
    public partial class changeuserid : DbMigration
    {
        public override void Up()
        {
            DropPrimaryKey("dbo.Users");
            AddColumn("dbo.Users", "UserName", c => c.String(nullable: false, maxLength: 128));
            AddPrimaryKey("dbo.Users", "UserName");
            DropColumn("dbo.Users", "UserId");
        }
        
        public override void Down()
        {
            AddColumn("dbo.Users", "UserId", c => c.String(nullable: false, maxLength: 128));
            DropPrimaryKey("dbo.Users");
            DropColumn("dbo.Users", "UserName");
            AddPrimaryKey("dbo.Users", "UserId");
        }
    }
}
