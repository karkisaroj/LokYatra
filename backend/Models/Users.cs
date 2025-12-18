using System.ComponentModel.DataAnnotations;

namespace backend.Models
{
    public class Users
    {
        [Key]
        public int userId { get; set; }
        [Required]
        public String name { get; set; }

        [Required]
        public string address {  get; set; }
    }
}
