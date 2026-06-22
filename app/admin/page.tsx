"use client";

import { useState, useEffect, useCallback } from "react";
import { Shield, Search, RefreshCw } from "lucide-react";

interface User {
  id: number;
  full_name: string;
  email: string;
  enrollment_number: string;
  batch: string;
  degree: string;
  role: string;
  created_at: string;
}

const ROLE_COLORS: Record<string, { bg: string; color: string }> = {
  superadmin: { bg: "rgba(139,92,246,0.2)", color: "#8b5cf6" },
  clubadmin:  { bg: "rgba(59,130,246,0.2)", color: "#3b82f6" },
  staff:      { bg: "rgba(234,179,8,0.2)",  color: "#eab308" },
  student:    { bg: "rgba(34,197,94,0.2)",  color: "#22c55e" },
};

export default function AdminPage() {
  const [users, setUsers] = useState<User[]>([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState("");
  const [roleFilter, setRoleFilter] = useState("all");
  const [updatingId, setUpdatingId] = useState<number | null>(null);
  const [error, setError] = useState("");

  // Read user id from cookie on client
  const [myId, setMyId] = useState<string>("");
  const [myRole, setMyRole] = useState<string>("");

  useEffect(() => {
    // Read cookies client-side
    const cookieStr = document.cookie;
    const parse = (name: string) =>
      cookieStr.split("; ").find(r => r.startsWith(name + "="))?.split("=")[1] ?? "";
    setMyId(parse("uwu_user_id"));
    setMyRole(parse("uwu_role"));
  }, []);

  const fetchUsers = useCallback(async () => {
    if (!myId) return;
    setLoading(true);
    try {
      const res = await fetch(`http://localhost:8000/users.php?requester_id=${myId}`);
      const data = await res.json();
      if (data.success) setUsers(data.users);
      else setError(data.message);
    } catch {
      setError("Failed to connect to backend.");
    } finally {
      setLoading(false);
    }
  }, [myId]);

  useEffect(() => {
    if (myId) fetchUsers();
  }, [myId, fetchUsers]);

  const updateRole = async (targetId: number, newRole: string) => {
    setUpdatingId(targetId);
    try {
      const res = await fetch("http://localhost:8000/update_role.php", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ requester_id: parseInt(myId), target_id: targetId, new_role: newRole }),
      });
      const data = await res.json();
      if (data.success) {
        setUsers(prev => prev.map(u => u.id === targetId ? { ...u, role: newRole } : u));
      } else {
        setError(data.message);
      }
    } catch {
      setError("Failed to update role.");
    } finally {
      setUpdatingId(null);
    }
  };

  const filtered = users.filter(u => {
    const matchRole = roleFilter === "all" || u.role === roleFilter;
    const q = search.toLowerCase();
    const matchSearch = !q ||
      u.full_name.toLowerCase().includes(q) ||
      u.email.toLowerCase().includes(q) ||
      u.enrollment_number.toLowerCase().includes(q);
    return matchRole && matchSearch;
  });

  const stats = {
    total: users.length,
    students: users.filter(u => u.role === "student").length,
    staff: users.filter(u => u.role === "staff").length,
    admins: users.filter(u => ["superadmin","clubadmin"].includes(u.role)).length,
  };

  return (
    <div className="container py-8">
      {/* Header */}
      <div className="flex justify-between items-center mb-8 flex-wrap gap-4">
        <div>
          <h1 className="text-4xl font-bold mb-2 flex items-center gap-3">
            <Shield size={36} style={{ color: "var(--primary)" }} />
            Admin Panel
          </h1>
          <p className="text-muted">Manage users and roles for the UWU-NEXUS platform.</p>
        </div>
        <button className="btn btn-secondary" onClick={fetchUsers}>
          <RefreshCw size={16} />
          Refresh
        </button>
      </div>

      {error && (
        <div className="mb-6 p-3 rounded text-sm" style={{ backgroundColor: "rgba(239,68,68,0.1)", color: "var(--danger)", border: "1px solid rgba(239,68,68,0.2)" }}>
          {error}
        </div>
      )}

      {/* Stats Cards */}
      <div className="grid gap-6 mb-8" style={{ gridTemplateColumns: "repeat(auto-fit, minmax(180px, 1fr))" }}>
        {[
          { label: "Total Users", value: stats.total, color: "var(--primary)" },
          { label: "Students",    value: stats.students, color: "var(--success)" },
          { label: "Staff",       value: stats.staff, color: "var(--warning)" },
          { label: "Admins",      value: stats.admins, color: "var(--accent)" },
        ].map(stat => (
          <div key={stat.label} className="card text-center" style={{ borderTop: `3px solid ${stat.color}` }}>
            <div className="text-4xl font-bold mb-1" style={{ color: stat.color }}>{stat.value}</div>
            <div className="text-muted text-sm">{stat.label}</div>
          </div>
        ))}
      </div>

      {/* Filters */}
      <div className="card mb-6 p-4 flex flex-wrap gap-4 items-center">
        <div style={{ flex: "1 1 250px", position: "relative" }}>
          <Search size={16} className="text-muted" style={{ position: "absolute", left: "1rem", top: "50%", transform: "translateY(-50%)" }} />
          <input type="text" className="form-input" placeholder="Search users..." style={{ paddingLeft: "2.5rem" }} value={search} onChange={e => setSearch(e.target.value)} />
        </div>
        <div style={{ position: "relative" }}>
          <select className="form-input" style={{ paddingRight: "2rem", cursor: "pointer" }} value={roleFilter} onChange={e => setRoleFilter(e.target.value)}>
            <option value="all">All Roles</option>
            <option value="student">Student</option>
            <option value="staff">Staff</option>
            <option value="clubadmin">Club Admin</option>
            <option value="superadmin">Super Admin</option>
          </select>
        </div>
      </div>

      {/* Users Table */}
      <div className="card p-0 overflow-hidden">
        {loading ? (
          <div className="p-12 text-center text-muted">Loading users...</div>
        ) : filtered.length === 0 ? (
          <div className="p-12 text-center text-muted">No users found.</div>
        ) : (
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
                {filtered.map((user, i) => {
                  const rc = ROLE_COLORS[user.role] ?? ROLE_COLORS.student;
                  return (
                    <tr key={user.id} style={{ borderBottom: "1px solid var(--border)", transition: "background 0.15s" }}
                      onMouseEnter={e => (e.currentTarget.style.backgroundColor = "rgba(255,255,255,0.03)")}
                      onMouseLeave={e => (e.currentTarget.style.backgroundColor = "")}>
                      <td className="p-4 text-muted text-sm">{i + 1}</td>
                      <td className="p-4 font-semibold">{user.full_name}</td>
                      <td className="p-4 text-sm text-muted">{user.email}</td>
                      <td className="p-4 text-sm font-mono">{user.enrollment_number}</td>
                      <td className="p-4 text-sm">{user.batch}</td>
                      <td className="p-4 text-sm">{user.degree}</td>
                      <td className="p-4">
                        <span className="badge" style={{ backgroundColor: rc.bg, color: rc.color, textTransform: "capitalize" }}>
                          {user.role}
                        </span>
                      </td>
                      {myRole === "superadmin" && (
                        <td className="p-4">
                          {user.id === parseInt(myId) ? (
                            <span className="text-muted text-sm">You</span>
                          ) : (
                            <select
                              className="form-input text-sm"
                              style={{ padding: "0.35rem 0.75rem", cursor: "pointer", width: "140px" }}
                              value={user.role}
                              disabled={updatingId === user.id}
                              onChange={e => updateRole(user.id, e.target.value)}
                            >
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
    </div>
  );
}
