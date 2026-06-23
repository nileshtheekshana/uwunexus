"use client";

import { useState, useEffect, useCallback } from "react";
import Image from "next/image";
import { Shield, Users, Calendar, Search, RefreshCw, CheckCircle, XCircle, Trash2, PlusCircle, Clock, MapPin, X, Upload, ChevronDown } from "lucide-react";
import { uploadToCloudinary } from "../lib/cloudinary";

/* ─── Types ──────────────────────────────────────────────────── */
interface User {
  id: number; full_name: string; email: string;
  enrollment_number: string; batch: string; degree: string;
  role: string; created_at: string;
}
interface Event {
  id: number; title: string; description: string;
  event_date: string; event_time: string; location: string;
  organized_by: string; category: string; image_url: string | null;
  status: string; created_by: number; creator_name: string;
}

/* ─── Constants ─────────────────────────────────────────────── */
const ROLE_COLORS: Record<string, { bg: string; color: string }> = {
  superadmin: { bg: "rgba(139,92,246,0.2)", color: "#8b5cf6" },
  clubadmin:  { bg: "rgba(59,130,246,0.2)",  color: "#3b82f6" },
  staff:      { bg: "rgba(234,179,8,0.2)",   color: "#eab308" },
  student:    { bg: "rgba(34,197,94,0.2)",   color: "#22c55e" },
};
const STATUS_COLORS: Record<string, { bg: string; color: string }> = {
  approved: { bg: "rgba(34,197,94,0.2)",  color: "#22c55e" },
  pending:  { bg: "rgba(234,179,8,0.2)",  color: "#eab308" },
  rejected: { bg: "rgba(239,68,68,0.2)",  color: "#ef4444" },
};
const CATEGORIES = ["Academic", "Cultural", "Sports", "Club Activity", "Career", "Other"];

function formatDate(d: string) {
  return new Date(d + "T00:00:00").toLocaleDateString("en-US", { day: "numeric", month: "short", year: "numeric" });
}
function formatTime(t: string) {
  const [h, m] = t.split(":");
  const date = new Date(); date.setHours(+h, +m);
  return date.toLocaleTimeString("en-US", { hour: "2-digit", minute: "2-digit" });
}

/* ─── Main Component ────────────────────────────────────────── */
export default function AdminPage() {
  const [tab, setTab] = useState<"users" | "events">("users");

  /* auth from cookie */
  const [myId, setMyId] = useState("");
  const [myRole, setMyRole] = useState("");
  useEffect(() => {
    const parse = (n: string) =>
      document.cookie.split("; ").find(r => r.startsWith(n + "="))?.split("=")[1] ?? "";
    setMyId(parse("uwu_user_id"));
    setMyRole(parse("uwu_role"));
  }, []);

  /* ── Users Tab ────────────────────────────────────────────── */
  const [users, setUsers] = useState<User[]>([]);
  const [usersLoading, setUsersLoading] = useState(true);
  const [userSearch, setUserSearch] = useState("");
  const [roleFilter, setRoleFilter] = useState("all");
  const [updatingUserId, setUpdatingUserId] = useState<number | null>(null);

  const fetchUsers = useCallback(async () => {
    if (!myId) return;
    setUsersLoading(true);
    try {
      const r = await fetch(`http://localhost:8000/users.php?requester_id=${myId}`);
      const d = await r.json();
      if (d.success) setUsers(d.users);
    } finally { setUsersLoading(false); }
  }, [myId]);

  useEffect(() => { if (myId) fetchUsers(); }, [myId, fetchUsers]);

  const updateUserRole = async (targetId: number, newRole: string) => {
    setUpdatingUserId(targetId);
    await fetch("http://localhost:8000/update_role.php", {
      method: "POST", headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ requester_id: +myId, target_id: targetId, new_role: newRole }),
    });
    setUsers(prev => prev.map(u => u.id === targetId ? { ...u, role: newRole } : u));
    setUpdatingUserId(null);
  };

  const filteredUsers = users.filter(u => {
    const matchRole = roleFilter === "all" || u.role === roleFilter;
    const q = userSearch.toLowerCase();
    return matchRole && (!q || u.full_name.toLowerCase().includes(q) || u.email.toLowerCase().includes(q) || u.enrollment_number.toLowerCase().includes(q));
  });

  /* ── Events Tab ───────────────────────────────────────────── */
  const [events, setEvents] = useState<Event[]>([]);
  const [eventsLoading, setEventsLoading] = useState(true);
  const [eventStatusFilter, setEventStatusFilter] = useState("all");
  const [showCreateModal, setShowCreateModal] = useState(false);

  const fetchEvents = useCallback(async () => {
    if (!myId) return;
    setEventsLoading(true);
    try {
      const r = await fetch(`http://localhost:8000/get_events.php?requester_id=${myId}&status=all`);
      const d = await r.json();
      if (d.success) setEvents(d.events);
    } finally { setEventsLoading(false); }
  }, [myId]);

  useEffect(() => { if (myId && tab === "events") fetchEvents(); }, [myId, tab, fetchEvents]);

  const updateEventStatus = async (eventId: number, status: string) => {
    await fetch("http://localhost:8000/update_event_status.php", {
      method: "POST", headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ requester_id: +myId, event_id: eventId, status }),
    });
    setEvents(prev => prev.map(e => e.id === eventId ? { ...e, status } : e));
  };

  const deleteEvent = async (eventId: number) => {
    if (!confirm("Delete this event permanently?")) return;
    await fetch("http://localhost:8000/delete_event.php", {
      method: "POST", headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ requester_id: +myId, event_id: eventId }),
    });
    setEvents(prev => prev.filter(e => e.id !== eventId));
  };

  const filteredEvents = events.filter(e =>
    eventStatusFilter === "all" || e.status === eventStatusFilter
  );

  const eventStats = {
    total: events.length,
    approved: events.filter(e => e.status === "approved").length,
    pending: events.filter(e => e.status === "pending").length,
    rejected: events.filter(e => e.status === "rejected").length,
  };

  const userStats = {
    total: users.length,
    students: users.filter(u => u.role === "student").length,
    staff: users.filter(u => u.role === "staff").length,
    admins: users.filter(u => ["superadmin", "clubadmin"].includes(u.role)).length,
  };

  /* ── Render ───────────────────────────────────────────────── */
  return (
    <div className="container py-8">
      {/* Header */}
      <div className="flex justify-between items-center mb-8 flex-wrap gap-4">
        <div>
          <h1 className="text-4xl font-bold mb-2 flex items-center gap-3">
            <Shield size={36} style={{ color: "var(--primary)" }} />
            Admin Panel
          </h1>
          <p className="text-muted">Manage users, roles, and events for UWU-NEXUS.</p>
        </div>
        <div className="flex gap-3">
          {tab === "events" && ["superadmin", "clubadmin"].includes(myRole) && (
            <button className="btn btn-primary" onClick={() => setShowCreateModal(true)}>
              <PlusCircle size={18} /> Create Event
            </button>
          )}
          <button className="btn btn-secondary" onClick={tab === "users" ? fetchUsers : fetchEvents}>
            <RefreshCw size={16} /> Refresh
          </button>
        </div>
      </div>

      {/* Tab Switcher */}
      <div className="flex gap-1 mb-8 p-1 rounded-lg" style={{ backgroundColor: "var(--secondary)", display: "inline-flex", border: "1px solid var(--border)" }}>
        {[{ key: "users", label: "Users", icon: <Users size={16} /> }, { key: "events", label: "Events", icon: <Calendar size={16} /> }].map(t => (
          <button key={t.key} onClick={() => setTab(t.key as "users" | "events")}
            className="btn flex items-center gap-2"
            style={{ padding: "0.5rem 1.5rem", backgroundColor: tab === t.key ? "var(--primary)" : "transparent", color: tab === t.key ? "white" : "var(--foreground)", transition: "all 0.2s" }}>
            {t.icon}{t.label}
          </button>
        ))}
      </div>

      {/* ── USERS TAB ── */}
      {tab === "users" && (
        <>
          {/* Stats */}
          <div className="grid gap-6 mb-8" style={{ gridTemplateColumns: "repeat(auto-fit, minmax(160px, 1fr))" }}>
            {[
              { label: "Total Users", value: userStats.total, color: "var(--primary)" },
              { label: "Students", value: userStats.students, color: "var(--success)" },
              { label: "Staff", value: userStats.staff, color: "var(--warning)" },
              { label: "Admins", value: userStats.admins, color: "var(--accent)" },
            ].map(s => (
              <div key={s.label} className="card text-center" style={{ borderTop: `3px solid ${s.color}` }}>
                <div className="text-4xl font-bold mb-1" style={{ color: s.color }}>{s.value}</div>
                <div className="text-muted text-sm">{s.label}</div>
              </div>
            ))}
          </div>

          {/* Filters */}
          <div className="card mb-6 p-4 flex flex-wrap gap-4 items-center">
            <div style={{ flex: "1 1 250px", position: "relative" }}>
              <Search size={16} className="text-muted" style={{ position: "absolute", left: "1rem", top: "50%", transform: "translateY(-50%)" }} />
              <input type="text" className="form-input" placeholder="Search users..." style={{ paddingLeft: "2.5rem" }} value={userSearch} onChange={e => setUserSearch(e.target.value)} />
            </div>
            <select className="form-input" style={{ width: "160px" }} value={roleFilter} onChange={e => setRoleFilter(e.target.value)}>
              <option value="all">All Roles</option>
              <option value="student">Student</option>
              <option value="staff">Staff</option>
              <option value="clubadmin">Club Admin</option>
              <option value="superadmin">Super Admin</option>
            </select>
          </div>

          {/* Table */}
          <div className="card p-0 overflow-hidden">
            {usersLoading ? <div className="p-12 text-center text-muted">Loading users...</div> :
              filteredUsers.length === 0 ? <div className="p-12 text-center text-muted">No users found.</div> : (
                <div style={{ overflowX: "auto" }}>
                  <table style={{ width: "100%", borderCollapse: "collapse" }}>
                    <thead style={{ backgroundColor: "rgba(255,255,255,0.04)" }}>
                      <tr>
                        {["#", "Full Name", "Email", "Enrollment No.", "Batch", "Degree", "Role", ...(myRole === "superadmin" ? ["Actions"] : [])].map(h => (
                          <th key={h} className="p-4 text-left text-sm font-semibold text-muted" style={{ borderBottom: "1px solid var(--border)", whiteSpace: "nowrap" }}>{h}</th>
                        ))}
                      </tr>
                    </thead>
                    <tbody>
                      {filteredUsers.map((user, i) => {
                        const rc = ROLE_COLORS[user.role] ?? ROLE_COLORS.student;
                        return (
                          <tr key={user.id} style={{ borderBottom: "1px solid var(--border)" }}
                            onMouseEnter={e => (e.currentTarget.style.backgroundColor = "rgba(255,255,255,0.03)")}
                            onMouseLeave={e => (e.currentTarget.style.backgroundColor = "")}>
                            <td className="p-4 text-muted text-sm">{i + 1}</td>
                            <td className="p-4 font-semibold">{user.full_name}</td>
                            <td className="p-4 text-sm text-muted">{user.email}</td>
                            <td className="p-4 text-sm font-mono">{user.enrollment_number}</td>
                            <td className="p-4 text-sm">{user.batch}</td>
                            <td className="p-4 text-sm">{user.degree}</td>
                            <td className="p-4">
                              <span className="badge" style={{ backgroundColor: rc.bg, color: rc.color, textTransform: "capitalize" }}>{user.role}</span>
                            </td>
                            {myRole === "superadmin" && (
                              <td className="p-4">
                                {user.id === +myId ? <span className="text-muted text-sm">You</span> : (
                                  <select className="form-input text-sm" style={{ padding: "0.35rem 0.75rem", width: "140px" }}
                                    value={user.role} disabled={updatingUserId === user.id}
                                    onChange={e => updateUserRole(user.id, e.target.value)}>
                                    <option value="student">Student</option>
                                    <option value="staff">Staff</option>
                                    <option value="clubadmin">Club Admin</option>
                                    <option value="superadmin">Super Admin</option>
                                  </select>
                                )}
                              </td>
                            )}
                          </tr>
                        );
                      })}
                    </tbody>
                  </table>
                </div>
              )}
          </div>
        </>
      )}

      {/* ── EVENTS TAB ── */}
      {tab === "events" && (
        <>
          {/* Stats */}
          <div className="grid gap-6 mb-8" style={{ gridTemplateColumns: "repeat(auto-fit, minmax(160px, 1fr))" }}>
            {[
              { label: "Total Events", value: eventStats.total, color: "var(--primary)" },
              { label: "Approved", value: eventStats.approved, color: "var(--success)" },
              { label: "Pending", value: eventStats.pending, color: "var(--warning)" },
              { label: "Rejected", value: eventStats.rejected, color: "var(--danger)" },
            ].map(s => (
              <div key={s.label} className="card text-center" style={{ borderTop: `3px solid ${s.color}` }}>
                <div className="text-4xl font-bold mb-1" style={{ color: s.color }}>{s.value}</div>
                <div className="text-muted text-sm">{s.label}</div>
              </div>
            ))}
          </div>

          {/* Status filter */}
          <div className="flex gap-2 mb-6 flex-wrap">
            {["all", "approved", "pending", "rejected"].map(s => {
              const sc = STATUS_COLORS[s];
              return (
                <button key={s} onClick={() => setEventStatusFilter(s)}
                  className="btn text-sm capitalize"
                  style={{
                    padding: "0.4rem 1.2rem",
                    backgroundColor: eventStatusFilter === s ? (sc?.bg ?? "var(--primary)") : "var(--secondary)",
                    color: eventStatusFilter === s ? (sc?.color ?? "white") : "var(--foreground)",
                    border: `1px solid ${eventStatusFilter === s ? (sc?.color ?? "var(--primary)") : "var(--border)"}`,
                  }}>
                  {s === "all" ? "All Events" : s}
                </button>
              );
            })}
          </div>

          {/* Events list */}
          {eventsLoading ? <div className="p-12 text-center text-muted">Loading events...</div> :
            filteredEvents.length === 0 ? (
              <div className="card text-center py-16 text-muted">
                <Calendar size={48} style={{ margin: "0 auto 1rem", opacity: 0.3 }} />
                <p>No events found.</p>
              </div>
            ) : (
              <div className="flex flex-col gap-4">
                {filteredEvents.map(event => {
                  const sc = STATUS_COLORS[event.status];
                  return (
                    <div key={event.id} className="card flex flex-wrap gap-4 items-center" style={{ padding: "1rem 1.5rem" }}>
                      {/* Thumbnail */}
                      <div style={{ width: "80px", height: "60px", borderRadius: "0.5rem", overflow: "hidden", flexShrink: 0, backgroundColor: "var(--background)", position: "relative" }}>
                        {event.image_url ? (
                          <Image src={event.image_url} alt={event.title} fill sizes="80px" style={{ objectFit: "cover" }} />
                        ) : (
                          <div style={{ height: "100%", display: "flex", alignItems: "center", justifyContent: "center" }}>
                            <Calendar size={28} className="text-muted" />
                          </div>
                        )}
                      </div>

                      {/* Info */}
                      <div style={{ flex: "1 1 200px" }}>
                        <div className="font-bold mb-1">{event.title}</div>
                        <div className="flex flex-wrap gap-3 text-xs text-muted">
                          <span className="flex items-center gap-1"><Calendar size={11} /> {formatDate(event.event_date)}</span>
                          <span className="flex items-center gap-1"><Clock size={11} /> {formatTime(event.event_time)}</span>
                          <span className="flex items-center gap-1"><MapPin size={11} /> {event.location}</span>
                        </div>
                        <div className="text-xs text-muted mt-1">By: <strong className="text-foreground">{event.creator_name}</strong> · {event.category}</div>
                      </div>

                      {/* Status badge */}
                      <span className="badge capitalize" style={{ backgroundColor: sc.bg, color: sc.color }}>{event.status}</span>

                      {/* Actions (superadmin only) */}
                      {myRole === "superadmin" && (
                        <div className="flex gap-2 flex-wrap">
                          {event.status !== "approved" && (
                            <button onClick={() => updateEventStatus(event.id, "approved")}
                              className="btn text-sm" title="Approve"
                              style={{ backgroundColor: "rgba(34,197,94,0.1)", color: "var(--success)", border: "1px solid var(--success)", padding: "0.35rem 0.75rem" }}>
                              <CheckCircle size={15} /> Approve
                            </button>
                          )}
                          {event.status !== "rejected" && (
                            <button onClick={() => updateEventStatus(event.id, "rejected")}
                              className="btn text-sm" title="Reject"
                              style={{ backgroundColor: "rgba(239,68,68,0.1)", color: "var(--danger)", border: "1px solid var(--danger)", padding: "0.35rem 0.75rem" }}>
                              <XCircle size={15} /> Reject
                            </button>
                          )}
                          <button onClick={() => deleteEvent(event.id)}
                            className="btn text-sm" title="Delete"
                            style={{ backgroundColor: "rgba(239,68,68,0.05)", color: "var(--danger)", border: "1px solid rgba(239,68,68,0.3)", padding: "0.35rem 0.75rem" }}>
                            <Trash2 size={15} />
                          </button>
                        </div>
                      )}
                    </div>
                  );
                })}
              </div>
            )}
        </>
      )}

      {/* ── Create Event Modal ── */}
      {showCreateModal && (
        <CreateEventModal
          myId={myId}
          onClose={() => setShowCreateModal(false)}
          onCreated={(ev) => { setEvents(prev => [ev, ...prev]); setShowCreateModal(false); }}
        />
      )}
    </div>
  );
}

/* ─── Create Event Modal ──────────────────────────────────────── */
function CreateEventModal({ myId, onClose, onCreated }: { myId: string; onClose: () => void; onCreated: (e: Event) => void; }) {
  const [form, setForm] = useState({ title: "", description: "", event_date: "", event_time: "", location: "", organized_by: "", category: "Academic" });
  const [imageFile, setImageFile] = useState<File | null>(null);
  const [imagePreview, setImagePreview] = useState<string>("");
  const [uploading, setUploading] = useState(false);
  const [submitting, setSubmitting] = useState(false);
  const [error, setError] = useState("");

  const handleImageChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file) return;
    setImageFile(file);
    setImagePreview(URL.createObjectURL(file));
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError(""); setSubmitting(true);
    try {
      let image_url = "";
      if (imageFile) {
        setUploading(true);
        image_url = await uploadToCloudinary(imageFile, "uwunexus/events");
        setUploading(false);
      }
      const res = await fetch("http://localhost:8000/create_event.php", {
        method: "POST", headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ ...form, image_url, requester_id: +myId }),
      });
      const data = await res.json();
      if (!data.success) throw new Error(data.message);
      onCreated({ ...form, id: data.id, image_url, status: data.status, created_by: +myId, creator_name: "You" } as any);
    } catch (err: any) {
      setError(err.message || "Failed to create event.");
    } finally {
      setSubmitting(false); setUploading(false);
    }
  };

  const set = (k: string, v: string) => setForm(f => ({ ...f, [k]: v }));

  return (
    <div style={{ position: "fixed", inset: 0, backgroundColor: "rgba(0,0,0,0.8)", zIndex: 100, display: "flex", alignItems: "center", justifyContent: "center", padding: "1rem" }}
      onClick={onClose}>
      <div className="card" style={{ maxWidth: "600px", width: "100%", maxHeight: "92vh", overflowY: "auto" }} onClick={e => e.stopPropagation()}>
        <div className="flex justify-between items-center mb-6">
          <h2 className="text-2xl font-bold flex items-center gap-2">
            <PlusCircle size={24} style={{ color: "var(--primary)" }} /> Create New Event
          </h2>
          <button onClick={onClose} style={{ background: "none", border: "none", cursor: "pointer", color: "var(--muted)" }}><X size={22} /></button>
        </div>

        {error && <div className="mb-4 p-3 rounded text-sm" style={{ backgroundColor: "rgba(239,68,68,0.1)", color: "var(--danger)", border: "1px solid rgba(239,68,68,0.2)" }}>{error}</div>}

        <form onSubmit={handleSubmit}>
          {/* Image upload */}
          <div className="form-group mb-4">
            <label className="form-label text-sm">Event Banner Image</label>
            <label style={{ display: "block", cursor: "pointer" }}>
              <div className="form-input flex items-center gap-3" style={{ cursor: "pointer", padding: "0.75rem" }}>
                <Upload size={18} className="text-muted" />
                <span className="text-muted text-sm">{imageFile ? imageFile.name : "Click to upload image (auto-compressed)"}</span>
              </div>
              <input type="file" accept="image/*" style={{ display: "none" }} onChange={handleImageChange} />
            </label>
            {imagePreview && (
              <div style={{ position: "relative", height: "160px", marginTop: "0.5rem", borderRadius: "0.5rem", overflow: "hidden" }}>
                <img src={imagePreview} alt="preview" style={{ width: "100%", height: "100%", objectFit: "cover" }} />
                <button type="button" onClick={() => { setImageFile(null); setImagePreview(""); }}
                  style={{ position: "absolute", top: "0.5rem", right: "0.5rem", backgroundColor: "rgba(0,0,0,0.7)", border: "none", borderRadius: "50%", width: "28px", height: "28px", cursor: "pointer", color: "white", display: "flex", alignItems: "center", justifyContent: "center" }}>
                  <X size={14} />
                </button>
              </div>
            )}
          </div>

          <div className="form-group mb-4">
            <label className="form-label text-sm">Event Title *</label>
            <input type="text" className="form-input" placeholder="e.g. Tech Symposium 2026" required value={form.title} onChange={e => set("title", e.target.value)} />
          </div>

          <div className="form-group mb-4">
            <label className="form-label text-sm">Description</label>
            <textarea className="form-input" placeholder="Brief description of the event..." rows={3} style={{ resize: "vertical" }} value={form.description} onChange={e => set("description", e.target.value)} />
          </div>

          <div className="grid gap-4 mb-4" style={{ gridTemplateColumns: "1fr 1fr" }}>
            <div className="form-group">
              <label className="form-label text-sm">Date *</label>
              <input type="date" className="form-input" required value={form.event_date} onChange={e => set("event_date", e.target.value)} />
            </div>
            <div className="form-group">
              <label className="form-label text-sm">Time *</label>
              <input type="time" className="form-input" required value={form.event_time} onChange={e => set("event_time", e.target.value)} />
            </div>
          </div>

          <div className="form-group mb-4">
            <label className="form-label text-sm">Location *</label>
            <input type="text" className="form-input" placeholder="e.g. Main Auditorium" required value={form.location} onChange={e => set("location", e.target.value)} />
          </div>

          <div className="form-group mb-4">
            <label className="form-label text-sm">Organized By *</label>
            <input type="text" className="form-input" placeholder="e.g. Computer Science Society" required value={form.organized_by} onChange={e => set("organized_by", e.target.value)} />
          </div>

          <div className="form-group mb-6">
            <label className="form-label text-sm">Category *</label>
            <select className="form-input" value={form.category} onChange={e => set("category", e.target.value)}>
              {CATEGORIES.map(c => <option key={c} value={c}>{c}</option>)}
            </select>
          </div>

          <button type="submit" disabled={submitting || uploading} className="btn btn-primary w-full justify-center text-lg"
            style={{ padding: "0.75rem", opacity: submitting ? 0.7 : 1 }}>
            {uploading ? "Uploading image..." : submitting ? "Creating event..." : "Create Event"}
          </button>
        </form>
      </div>
    </div>
  );
}
