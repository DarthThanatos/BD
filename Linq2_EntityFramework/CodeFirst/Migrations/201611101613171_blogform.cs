namespace CodeFirst.Migrations
{
    using System;
    using System.Data.Entity.Migrations;
    
    public partial class blogform : DbMigration
    {
        public override void Up()
        {
            CreateTable(
                "dbo.BlogForms",
                c => new
                    {
                        BlogFormId = c.Int(nullable: false, identity: true),
                    })
                .PrimaryKey(t => t.BlogFormId);
            
            AddColumn("dbo.Blogs", "BlogFormId", c => c.Int(nullable: false));
            CreateIndex("dbo.Blogs", "BlogFormId");
            AddForeignKey("dbo.Blogs", "BlogFormId", "dbo.BlogForms", "BlogFormId", cascadeDelete: true);
        }
        
        public override void Down()
        {
            DropForeignKey("dbo.Blogs", "BlogFormId", "dbo.BlogForms");
            DropIndex("dbo.Blogs", new[] { "BlogFormId" });
            DropColumn("dbo.Blogs", "BlogFormId");
            DropTable("dbo.BlogForms");
        }
    }
}
