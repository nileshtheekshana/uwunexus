import { BookOpen, Phone, FileText, UserCircle } from "lucide-react";

export default function InfoHubPage() {
  return (
    <div className="container py-8">
      <div className="text-center mb-12">
        <h1 className="text-4xl font-bold mb-4 flex justify-center items-center gap-3">
          <BookOpen size={36} style={{ color: '#ec4899' }} />
          Information Hub
        </h1>
        <p className="text-muted max-w-2xl mx-auto">
          Your primary point of reference for all university procedures, contacts, and emergency information.
        </p>
      </div>

      <div className="grid grid-cols-1 md-grid-cols-3 gap-8">
        
        {/* Procedures Section */}
        <div className="md-grid-cols-2" style={{ gridColumn: 'span 2' }}>
          <div className="flex items-center gap-2 mb-6">
            <FileText size={24} style={{ color: '#ec4899' }} />
            <h2 className="text-2xl font-bold">University Procedures</h2>
          </div>
          
          <div className="flex flex-col gap-4">
            <div className="card" style={{ padding: '1rem 1.5rem' }}>
              <h3 className="font-bold text-lg mb-2">Medical Submissions</h3>
              <p className="text-sm text-muted mb-4">
                Medical certificates must be submitted to the medical center within 7 days of absence. Ensure it is endorsed by a government medical officer.
              </p>
              <button className="btn btn-secondary text-sm" style={{ padding: '0.25rem 0.75rem' }}>Download Form</button>
            </div>
            
            <div className="card" style={{ padding: '1rem 1.5rem' }}>
              <h3 className="font-bold text-lg mb-2">Semester Registration</h3>
              <p className="text-sm text-muted mb-4">
                Registration for upcoming semesters must be completed through the online portal during the specified add/drop period.
              </p>
              <button className="btn btn-secondary text-sm" style={{ padding: '0.25rem 0.75rem' }}>Read Guidelines</button>
            </div>
            
            <div className="card" style={{ padding: '1rem 1.5rem' }}>
              <h3 className="font-bold text-lg mb-2">Library Membership</h3>
              <p className="text-sm text-muted">
                First-year students must physically visit the main library with their student ID to activate their library lending privileges.
              </p>
            </div>
          </div>
        </div>

        {/* Contacts Section */}
        <div>
          <div className="flex items-center gap-2 mb-6">
            <Phone size={24} className="text-danger" />
            <h2 className="text-2xl font-bold">Emergency Hotlines</h2>
          </div>
          
          <div className="card mb-8" style={{ borderLeft: '4px solid var(--danger)' }}>
            <div className="flex flex-col gap-4">
              <div className="flex justify-between items-center border-b border-border pb-2">
                <span className="font-semibold">Security Office</span>
                <a href="tel:0552226480" className="text-danger font-mono">055 222 6480</a>
              </div>
              <div className="flex justify-between items-center border-b border-border pb-2">
                <span className="font-semibold">Medical Center</span>
                <a href="tel:0552226481" className="text-danger font-mono">055 222 6481</a>
              </div>
              <div className="flex justify-between items-center">
                <span className="font-semibold">Student Affairs</span>
                <a href="tel:0552226482" className="text-danger font-mono">055 222 6482</a>
              </div>
            </div>
          </div>

          <div className="flex items-center gap-2 mb-6">
            <UserCircle size={24} className="text-primary" />
            <h2 className="text-2xl font-bold">Key Contacts</h2>
          </div>

          <div className="flex flex-col gap-4">
            <div className="card p-4">
              <div className="font-bold mb-1">Dr. A.B. Perera</div>
              <div className="text-sm text-muted mb-2">Head of Dept - CST</div>
              <a href="mailto:hod.cst@uwu.ac.lk" className="text-sm text-primary">hod.cst@uwu.ac.lk</a>
            </div>
            <div className="card p-4">
              <div className="font-bold mb-1">Mr. C.D. Silva</div>
              <div className="text-sm text-muted mb-2">IIT Course Coordinator</div>
              <a href="mailto:coord.iit@uwu.ac.lk" className="text-sm text-primary">coord.iit@uwu.ac.lk</a>
            </div>
          </div>

        </div>
      </div>
    </div>
  );
}
