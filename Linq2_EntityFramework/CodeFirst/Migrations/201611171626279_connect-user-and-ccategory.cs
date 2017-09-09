namespace CodeFirst.Migrations
{
    using System;
    using System.Data.Entity.Migrations;
    
    public partial class connectuserandccategory : DbMigration
    {
        public override void Up()
        {
            CreateTable(
                "dbo.Categories",
                c => new
                    {
                        CategoryId = c.Int(nullable: false, identity: true),
                        Name = c.String(),
                    })
                .PrimaryKey(t => t.CategoryId);
            
            AddColumn("dbo.Blogs", "CategoryId", c => c.Int(nullable: false));
            AddColumn("dbo.Posts", "UserName", c => c.String(nullable: false, maxLength: 128));
            CreateIndex("dbo.Blogs", "CategoryId");
            CreateIndex("dbo.Posts", "UserName");
            AddForeignKey("dbo.Blogs", "CategoryId", "dbo.Categories", "CategoryId", cascadeDelete: true);
            AddForeignKey("dbo.Posts", "UserName", "dbo.Users", "UserName", cascadeDelete: true);
        }
        
        public override void Down()
        {
            DropForeignKey("dbo.Posts", "UserName", "dbo.Users");
            DropForeignKey("dbo.Blogs", "CategoryId", "dbo.Categories");
            DropIndex("dbo.Posts", new[] { "UserName" });
            DropIndex("dbo.Blogs", new[] { "CategoryId" });
            DropColumn("dbo.Posts", "UserName");
            DropColumn("dbo.Blogs", "CategoryId");
            DropTable("dbo.Categories");
        }
    }
}
