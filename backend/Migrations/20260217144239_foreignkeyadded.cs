using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace backend.Migrations
{
    /// <inheritdoc />
    public partial class foreignkeyadded : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateIndex(
                name: "IX_Homestays_NearCulturalSiteId",
                table: "Homestays",
                column: "NearCulturalSiteId");

            migrationBuilder.AddForeignKey(
                name: "FK_Homestays_CulturalSites_NearCulturalSiteId",
                table: "Homestays",
                column: "NearCulturalSiteId",
                principalTable: "CulturalSites",
                principalColumn: "Id");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Homestays_CulturalSites_NearCulturalSiteId",
                table: "Homestays");

            migrationBuilder.DropIndex(
                name: "IX_Homestays_NearCulturalSiteId",
                table: "Homestays");
        }
    }
}
