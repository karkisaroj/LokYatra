using Microsoft.EntityFrameworkCore.Migrations;
using Npgsql.EntityFrameworkCore.PostgreSQL.Metadata;

#nullable disable

namespace backend.Migrations
{
    /// <inheritdoc />
    public partial class AddCulturalSitesAndStories : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "CulturalSites",
                columns: table => new
                {
                    Id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    Name = table.Column<string>(type: "character varying(120)", maxLength: 120, nullable: false),
                    Category = table.Column<string>(type: "character varying(60)", maxLength: 60, nullable: false),
                    District = table.Column<string>(type: "character varying(80)", maxLength: 80, nullable: false),
                    Address = table.Column<string>(type: "character varying(160)", maxLength: 160, nullable: false),
                    ShortDescription = table.Column<string>(type: "character varying(500)", maxLength: 500, nullable: false),
                    HistoricalSignificance = table.Column<string>(type: "character varying(300)", maxLength: 300, nullable: true),
                    CulturalImportance = table.Column<string>(type: "character varying(300)", maxLength: 300, nullable: true),
                    EntryFeeNPR = table.Column<decimal>(type: "numeric", nullable: true),
                    EntryFeeSAARC = table.Column<decimal>(type: "numeric", nullable: true),
                    OpeningTime = table.Column<string>(type: "character varying(5)", maxLength: 5, nullable: true),
                    ClosingTime = table.Column<string>(type: "character varying(5)", maxLength: 5, nullable: true),
                    BestTimeToVisit = table.Column<string>(type: "character varying(120)", maxLength: 120, nullable: true),
                    IsUNESCO = table.Column<bool>(type: "boolean", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_CulturalSites", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "CulturalSiteImages",
                columns: table => new
                {
                    Id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    CulturalSiteId = table.Column<int>(type: "integer", nullable: false),
                    Url = table.Column<string>(type: "character varying(300)", maxLength: 300, nullable: false),
                    PublicId = table.Column<string>(type: "character varying(300)", maxLength: 300, nullable: false),
                    Position = table.Column<int>(type: "integer", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_CulturalSiteImages", x => x.Id);
                    table.ForeignKey(
                        name: "FK_CulturalSiteImages_CulturalSites_CulturalSiteId",
                        column: x => x.CulturalSiteId,
                        principalTable: "CulturalSites",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "Stories",
                columns: table => new
                {
                    Id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    CulturalSiteId = table.Column<int>(type: "integer", nullable: false),
                    Title = table.Column<string>(type: "character varying(160)", maxLength: 160, nullable: false),
                    StoryType = table.Column<string>(type: "character varying(40)", maxLength: 40, nullable: false),
                    EstimatedReadTimeMinutes = table.Column<int>(type: "integer", nullable: false),
                    FullContent = table.Column<string>(type: "character varying(5000)", maxLength: 5000, nullable: false),
                    HistoricalContext = table.Column<string>(type: "character varying(500)", maxLength: 500, nullable: true),
                    CulturalSignificance = table.Column<string>(type: "character varying(500)", maxLength: 500, nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Stories", x => x.Id);
                    table.ForeignKey(
                        name: "FK_Stories_CulturalSites_CulturalSiteId",
                        column: x => x.CulturalSiteId,
                        principalTable: "CulturalSites",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "StoryImages",
                columns: table => new
                {
                    Id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    StoryId = table.Column<int>(type: "integer", nullable: false),
                    Url = table.Column<string>(type: "character varying(300)", maxLength: 300, nullable: false),
                    PublicId = table.Column<string>(type: "character varying(300)", maxLength: 300, nullable: false),
                    Position = table.Column<int>(type: "integer", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_StoryImages", x => x.Id);
                    table.ForeignKey(
                        name: "FK_StoryImages_Stories_StoryId",
                        column: x => x.StoryId,
                        principalTable: "Stories",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_CulturalSiteImages_CulturalSiteId",
                table: "CulturalSiteImages",
                column: "CulturalSiteId");

            migrationBuilder.CreateIndex(
                name: "IX_Stories_CulturalSiteId",
                table: "Stories",
                column: "CulturalSiteId");

            migrationBuilder.CreateIndex(
                name: "IX_StoryImages_StoryId",
                table: "StoryImages",
                column: "StoryId");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "CulturalSiteImages");

            migrationBuilder.DropTable(
                name: "StoryImages");

            migrationBuilder.DropTable(
                name: "Stories");

            migrationBuilder.DropTable(
                name: "CulturalSites");
        }
    }
}
