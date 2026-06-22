import { Ticket, MapPin, Calendar, Clock } from "lucide-react";

export default function TicketsPage() {
  const ticketedEvents = [
    {
      id: 1,
      title: "Musical Night: UWU Beats",
      date: "Nov 02, 2026",
      time: "06:30 PM",
      venue: "Open Air Theatre",
      price: "Rs. 500",
      availableTickets: 120,
      imagePlaceholder: "linear-gradient(135deg, var(--primary) 0%, var(--accent) 100%)"
    },
    {
      id: 2,
      title: "Tech Innovation Summit",
      date: "Nov 15, 2026",
      time: "09:00 AM",
      venue: "Main Auditorium",
      price: "Rs. 1000",
      availableTickets: 45,
      imagePlaceholder: "linear-gradient(135deg, #10b981 0%, #3b82f6 100%)"
    }
  ];

  return (
    <div className="container py-8">
      <div className="text-center mb-12">
        <h1 className="text-4xl font-bold mb-4">Event Tickets</h1>
        <p className="text-muted max-w-2xl mx-auto">
          Securely purchase your tickets online for premium campus events. No more cash hassles or lost tickets.
        </p>
      </div>

      <div className="grid grid-cols-1 md-grid-cols-2 lg-grid-cols-3 gap-8">
        {ticketedEvents.map((event) => (
          <div key={event.id} className="card p-0 overflow-hidden flex flex-col" style={{ padding: 0 }}>
            {/* Image Placeholder */}
            <div style={{ background: event.imagePlaceholder, height: '200px', width: '100%' }}></div>
            
            <div className="p-6 flex flex-col flex-1">
              <div className="flex justify-between items-start mb-4">
                <h2 className="text-2xl font-bold leading-tight">{event.title}</h2>
                <span className="badge badge-primary text-lg font-bold" style={{ backgroundColor: 'var(--primary)', color: 'white' }}>
                  {event.price}
                </span>
              </div>

              <div className="flex flex-col gap-3 text-muted text-sm mb-6">
                <div className="flex items-center gap-2">
                  <Calendar size={16} />
                  <span>{event.date}</span>
                </div>
                <div className="flex items-center gap-2">
                  <Clock size={16} />
                  <span>{event.time}</span>
                </div>
                <div className="flex items-center gap-2">
                  <MapPin size={16} />
                  <span>{event.venue}</span>
                </div>
              </div>

              <div className="mt-auto">
                <div className="flex justify-between items-center mb-4 text-sm font-semibold">
                  <span className="text-muted">Tickets left:</span>
                  <span className={event.availableTickets < 50 ? "text-warning" : "text-success"}>
                    {event.availableTickets} available
                  </span>
                </div>
                <button className="btn btn-primary w-full" style={{ width: '100%', justifyContent: 'center' }}>
                  <Ticket size={18} />
                  Book Now
                </button>
              </div>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}
