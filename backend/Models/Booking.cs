using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace backend.Models
{
    public enum BookingStatus
    {
        Pending,      // tourist booked, waiting owner confirmation
        Confirmed,    // owner confirmed
        Rejected,     // owner rejected
        Cancelled,    // tourist cancelled
        Completed,    // stay is done
    }

    public enum PaymentMethod
    {
        PayAtArrival,
        Khalti,
    }

    public enum PaymentStatus
    {
        Unpaid,
        Paid,
        Refunded,
    }

    public class Booking
    {
        [Key] public int Id { get; set; }

        public int HomestayId { get; set; }
        public int TouristId { get; set; }

        public DateOnly CheckIn { get; set; }
        public DateOnly CheckOut { get; set; }
        public int Rooms { get; set; }  
        public int Guests { get; set; }

        public decimal PricePerNight { get; set; }  
        public int Nights { get; set; }
        public decimal SubTotal { get; set; } 
        public int PointsRedeemed { get; set; }  
        public decimal PointsDiscount { get; set; }  
        public decimal TotalPrice { get; set; }  

        public BookingStatus Status { get; set; } = BookingStatus.Pending;
        public PaymentMethod PaymentMethod { get; set; } = PaymentMethod.PayAtArrival;
        public PaymentStatus PaymentStatus { get; set; } = PaymentStatus.Unpaid;
        public string? KhaltiPidx { get; set; } 
        public string? RejectionReason { get; set; }
        public string? SpecialRequests { get; set; }

        public DateTimeOffset CreatedAt { get; set; } = DateTimeOffset.UtcNow;
        public DateTimeOffset UpdatedAt { get; set; } = DateTimeOffset.UtcNow;
    }
}