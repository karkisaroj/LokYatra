#!/usr/bin/env dotnet-script
// Run with: dotnet script GenerateHostSeeds.csx
// Or just run GenerateHostSeeds.cs as a console app

using Microsoft.AspNetCore.Identity;

// Simple stub class matching the User entity signature needed by PasswordHasher
class User { }

var hasher = new PasswordHasher<User>();
var dummy = new User();
string password = "Host@1234";

var hosts = new[]
{
    new { Name = "Bikash Shrestha",     Email = "bikash.shrestha@gmail.com",  Phone = "9841234567" },
    new { Name = "Tenzin Lama",         Email = "tenzin.lama@gmail.com",       Phone = "9852345678" },
    new { Name = "Sarita Maharjan",     Email = "sarita.maharjan@gmail.com",   Phone = "9803456789" },
    new { Name = "Dipak Tamang",        Email = "dipak.tamang@gmail.com",      Phone = "9864567890" },
    new { Name = "Sunita Gurung",       Email = "sunita.gurung@gmail.com",     Phone = "9875678901" },
    new { Name = "Ram Prasad Adhikari", Email = "ramprasad.adhikari@gmail.com",Phone = "9816789012" },
    new { Name = "Kamala Neupane",      Email = "kamala.neupane@gmail.com",    Phone = "9847890123" },
    new { Name = "Gopal Bajracharya",   Email = "gopal.bajracharya@gmail.com", Phone = "9858901234" },
};

Console.WriteLine("-- ============================================================");
Console.WriteLine("-- LokYatra: Host User Seed Data");
Console.WriteLine("-- Password for all hosts: Host@1234");
Console.WriteLine("-- ============================================================");
Console.WriteLine();
Console.WriteLine("INSERT INTO \"User\" (\"IsActive\",\"Name\",\"Email\",\"PasswordHash\",\"Role\",\"PhoneNumber\",\"ProfileImage\",\"QuizPoints\",\"CreatedAt\",\"UpdatedAt\") VALUES");

for (int i = 0; i < hosts.Length; i++)
{
    var h = hosts[i];
    var hash = hasher.HashPassword(dummy, password);
    var comma = i < hosts.Length - 1 ? "," : ";";
    Console.WriteLine($"(TRUE,'{h.Name}','{h.Email}','{hash}','owner','{h.Phone}','',0,NOW(),NOW()){comma}");
}
