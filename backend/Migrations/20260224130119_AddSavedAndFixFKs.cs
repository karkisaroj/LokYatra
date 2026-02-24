using System;
using Microsoft.EntityFrameworkCore.Migrations;
using Npgsql.EntityFrameworkCore.PostgreSQL.Metadata;

#nullable disable

namespace backend.Migrations
{
    /// <inheritdoc />
    public partial class AddSavedAndFixFKs : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AlterColumn<int>(
                name: "OwnerId",
                table: "Homestays",
                type: "integer",
                nullable: true,
                oldClrType: typeof(int),
                oldType: "integer");

            migrationBuilder.CreateTable(
                name: "SavedHomestays",
                columns: table => new
                {
                    Id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    UserId = table.Column<int>(type: "integer", nullable: false),
                    HomestayId = table.Column<int>(type: "integer", nullable: false),
                    SavedAt = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_SavedHomestays", x => x.Id);
                    table.ForeignKey(
                        name: "FK_SavedHomestays_Homestays_HomestayId",
                        column: x => x.HomestayId,
                        principalTable: "Homestays",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_SavedHomestays_User_UserId",
                        column: x => x.UserId,
                        principalTable: "User",
                        principalColumn: "UserId",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_Homestays_OwnerId",
                table: "Homestays",
                column: "OwnerId");

            migrationBuilder.CreateIndex(
                name: "IX_SavedHomestays_HomestayId",
                table: "SavedHomestays",
                column: "HomestayId");

            migrationBuilder.CreateIndex(
                name: "IX_SavedHomestays_UserId_HomestayId",
                table: "SavedHomestays",
                columns: new[] { "UserId", "HomestayId" },
                unique: true);

            migrationBuilder.AddForeignKey(
                name: "FK_Homestays_User_OwnerId",
                table: "Homestays",
                column: "OwnerId",
                principalTable: "User",
                principalColumn: "UserId");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Homestays_User_OwnerId",
                table: "Homestays");

            migrationBuilder.DropTable(
                name: "SavedHomestays");

            migrationBuilder.DropIndex(
                name: "IX_Homestays_OwnerId",
                table: "Homestays");

            migrationBuilder.AlterColumn<int>(
                name: "OwnerId",
                table: "Homestays",
                type: "integer",
                nullable: false,
                defaultValue: 0,
                oldClrType: typeof(int),
                oldType: "integer",
                oldNullable: true);
        }
    }
}
