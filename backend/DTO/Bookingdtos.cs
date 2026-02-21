namespace backend.DTO
{
    public class CreateBookingDto
    {
        public int HomestayId { get; set; }
        public DateOnly CheckIn { get; set; }
        public DateOnly CheckOut { get; set; }
        public int Rooms { get; set; }
        public int Guests { get; set; }
        public int PointsToRedeem { get; set; } = 0;
        public string PaymentMethod { get; set; } = "PayAtArrival"; 
        public string? SpecialRequests { get; set; }
    }

    public class UpdateBookingStatusDto
    {
        public string Status { get; set; } = "Confirmed"; // Confirmed | Rejected | Cancelled
        public string? RejectionReason { get; set; }
    }
}