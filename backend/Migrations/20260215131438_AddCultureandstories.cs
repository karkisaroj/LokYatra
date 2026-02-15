using System;
using System.Collections.Generic;
using Microsoft.EntityFrameworkCore.Migrations;
using Npgsql.EntityFrameworkCore.PostgreSQL.Metadata;

#nullable disable

namespace backend.Migrations
{
    /// <inheritdoc />
    public partial class AddCultureandstories : Migration
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
                    Name = table.Column<string>(type: "text", nullable: true),
                    Category = table.Column<string>(type: "text", nullable: true),
                    District = table.Column<string>(type: "text", nullable: true),
                    Address = table.Column<string>(type: "text", nullable: true),
                    ShortDescription = table.Column<string>(type: "text", nullable: true),
                    HistoricalSignificance = table.Column<string>(type: "text", nullable: true),
                    CulturalImportance = table.Column<string>(type: "text", nullable: true),
                    EntryFeeNPR = table.Column<string>(type: "text", nullable: true),
                    EntryFeeSAARC = table.Column<string>(type: "text", nullable: true),
                    OpeningTime = table.Column<string>(type: "text", nullable: true),
                    ClosingTime = table.Column<string>(type: "text", nullable: true),
                    BestTimeToVisit = table.Column<string>(type: "text", nullable: true),
                    IsUNESCO = table.Column<bool>(type: "boolean", nullable: false),
                    ImageUrls = table.Column<List<string>>(type: "text[]", nullable: true),
                    CreatedAt = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: false),
                    UpdatedAt = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_CulturalSites", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "Stories",
                columns: table => new
                {
                    Id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    CulturalSiteId = table.Column<int>(type: "integer", nullable: false),
                    Title = table.Column<string>(type: "text", nullable: true),
                    StoryType = table.Column<string>(type: "text", nullable: true),
                    EstimatedReadTimeMinutes = table.Column<int>(type: "integer", nullable: false),
                    FullContent = table.Column<string>(type: "text", nullable: true),
                    HistoricalContext = table.Column<string>(type: "text", nullable: true),
                    CulturalSignificance = table.Column<string>(type: "text", nullable: true),
                    ImageUrls = table.Column<List<string>>(type: "text[]", nullable: true),
                    CreatedAt = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: false),
                    UpdatedAt = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Stories", x => x.Id);
                });

            migrationBuilder.CreateIndex(
                name: "IX_User_Email",
                table: "User",
                column: "Email",
                unique: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "CulturalSites");

            migrationBuilder.DropTable(
                name: "Stories");

            migrationBuilder.DropIndex(
                name: "IX_User_Email",
                table: "User");
        }
    }
}
