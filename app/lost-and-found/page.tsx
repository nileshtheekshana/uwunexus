import { Search, MapPin, Clock, PlusCircle } from "lucide-react";

export default function LostAndFoundPage() {
  const reports = [
    {
      id: 1,
      type: "Lost",
      item: "Black Wallet",
      location: "Library 2nd Floor",
      time: "Today, 10:30 AM",
      description: "Contains my student ID and some cash. Please contact if found.",
      color: "var(--danger)"
    },
    {
      id: 2,
      type: "Found",
      item: "Blue Umbrella",
      location: "Cafeteria",
      time: "Yesterday, 02:15 PM",
      description: "Left near the corner table. Handed over to security.",
      color: "var(--success)"
    },
    {
      id: 3,
      type: "Lost",
      item: "Gold Ring",
      location: "Near E-Block",
      time: "Oct 12, 08:00 AM",
      description: "Small gold ring with a clear stone. Sentimental value.",
      color: "var(--danger)"
    }
  ];

  return (
    <div className="container py-8">
      <div className="flex justify-between items-center mb-8 flex-wrap gap-4">
        <div>
          <h1 className="text-4xl font-bold mb-2 flex items-center gap-3">
            <Search size={36} className="text-warning" />
            Lost & Found
          </h1>
          <p className="text-muted">Community portal to report and recover misplaced items.</p>
        </div>
        <button className="btn btn-primary" style={{ backgroundColor: 'var(--warning)', color: '#000' }}>
          <PlusCircle size={18} />
          Report Item
        </button>
      </div>

      <div className="flex gap-4 mb-8">
        <button className="btn btn-secondary" style={{ borderColor: 'var(--warning)', color: 'var(--warning)' }}>All Reports</button>
        <button className="btn btn-secondary">Lost Items</button>
        <button className="btn btn-secondary">Found Items</button>
      </div>

      <div className="grid grid-cols-1 md-grid-cols-2 lg-grid-cols-3 gap-6">
        {reports.map((report) => (
          <div key={report.id} className="card" style={{ borderTop: `4px solid ${report.color}` }}>
            <div className="flex justify-between items-start mb-4">
              <h3 className="font-bold text-xl">{report.item}</h3>
              <span className="badge" style={{ backgroundColor: `${report.color}33`, color: report.color }}>
                {report.type}
              </span>
            </div>
            
            <p className="text-sm mb-4">{report.description}</p>
            
            <div className="flex flex-col gap-2 text-muted text-sm mb-6">
              <div className="flex items-center gap-2">
                <MapPin size={16} />
                <span>{report.location}</span>
              </div>
              <div className="flex items-center gap-2">
                <Clock size={16} />
                <span>{report.time}</span>
              </div>
            </div>

            <button className="btn w-full" style={{ border: '1px solid var(--border)' }}>
              Contact Reporter
            </button>
          </div>
        ))}
      </div>
    </div>
  );
}
