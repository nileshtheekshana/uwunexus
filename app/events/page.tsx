import { Calendar, MapPin, Clock, Users } from "lucide-react";

export default function EventsPage() {
  const events = [
    {
      id: 1,
      title: "Tech Symposium 2026",
      date: "Oct 15, 2026",
      time: "09:00 AM - 04:00 PM",
      venue: "Main Auditorium",
      organizer: "Computer Science Society",
      type: "Academic"
    },
    {
      id: 2,
      title: "Inter-Faculty Debate Final",
      date: "Oct 18, 2026",
      time: "02:00 PM - 05:00 PM",
      venue: "Mini Auditorium",
      organizer: "Gavel Club",
      type: "Club Activity"
    },
    {
      id: 3,
      title: "Career Fair: Nexus",
      date: "Oct 25, 2026",
      time: "10:00 AM - 05:00 PM",
      venue: "University Grounds",
      organizer: "Career Guidance Unit",
      type: "Career"
    }
  ];

  return (
    <div className="container py-8">
      <div className="flex justify-between items-center mb-8" style={{ flexWrap: 'wrap', gap: '1rem' }}>
        <div>
          <h1 className="text-4xl font-bold mb-2">University Event Calendar</h1>
          <p className="text-muted">Discover and stay updated with campus activities.</p>
        </div>
        <button className="btn btn-primary">
          <Calendar size={18} />
          <span>Add Event</span>
        </button>
      </div>

      {/* Calendar Filters/Tabs */}
      <div className="flex gap-4 mb-8" style={{ borderBottom: '1px solid var(--border)', paddingBottom: '1rem', overflowX: 'auto' }}>
        <button className="btn font-semibold" style={{ color: 'var(--primary)', borderBottom: '2px solid var(--primary)', borderRadius: '0' }}>Upcoming</button>
        <button className="btn text-muted font-semibold">This Week</button>
        <button className="btn text-muted font-semibold">This Month</button>
        <button className="btn text-muted font-semibold">Past Events</button>
      </div>

      <div className="grid grid-cols-1 gap-6">
        {events.map((event) => (
          <div key={event.id} className="card flex flex-col md-flex-row justify-between gap-6" style={{ display: 'flex', flexWrap: 'wrap', alignItems: 'center' }}>
            <div style={{ flex: '1 1 300px' }}>
              <div className="flex items-center gap-2 mb-2">
                <span className="badge badge-primary">{event.type}</span>
              </div>
              <h2 className="text-2xl font-bold mb-4">{event.title}</h2>
              <div className="flex flex-col gap-2 text-muted text-sm">
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
                <div className="flex items-center gap-2">
                  <Users size={16} />
                  <span>Organized by: {event.organizer}</span>
                </div>
              </div>
            </div>
            
            <div className="flex flex-col gap-2" style={{ minWidth: '150px' }}>
              <button className="btn btn-secondary w-full" style={{ width: '100%' }}>View Details</button>
              <button className="btn btn-primary w-full" style={{ width: '100%', backgroundColor: 'rgba(139, 92, 246, 0.1)', color: 'var(--primary)', border: '1px solid var(--primary)' }}>Add to Calendar</button>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}
