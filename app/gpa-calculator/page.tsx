"use client";

import { useState } from "react";
import { Calculator, CheckCircle2 } from "lucide-react";

export default function GPACalculatorPage() {
  const [indexNumber, setIndexNumber] = useState("");
  const [curriculumLoaded, setCurriculumLoaded] = useState(false);

  const mockSubjects = [
    { code: "CST201-3", name: "Data Structures", credits: 3 },
    { code: "CST202-2", name: "Database Systems", credits: 2 },
    { code: "IIT201-3", name: "Web Application Development", credits: 3 },
    { code: "IIT203-2", name: "Software Engineering", credits: 2 },
  ];

  const handleLoadCurriculum = (e: React.FormEvent) => {
    e.preventDefault();
    if (indexNumber) {
      setCurriculumLoaded(true);
    }
  };

  return (
    <div className="container py-8 max-w-4xl">
      <div className="text-center mb-12">
        <h1 className="text-4xl font-bold mb-4 flex justify-center items-center gap-3">
          <Calculator size={36} className="text-danger" />
          Smart GPA Calculator
        </h1>
        <p className="text-muted">Enter your Index Number to auto-load your curriculum.</p>
      </div>

      {!curriculumLoaded ? (
        <div className="card max-w-md mx-auto">
          <form onSubmit={handleLoadCurriculum}>
            <div className="form-group mb-4">
              <label className="form-label">University Index Number</label>
              <input 
                type="text" 
                className="form-input" 
                placeholder="e.g. UWU/IIT/21/001" 
                value={indexNumber}
                onChange={(e) => setIndexNumber(e.target.value)}
                required
              />
            </div>
            <button type="submit" className="btn btn-primary w-full" style={{ backgroundColor: 'var(--danger)' }}>
              Load Curriculum
            </button>
          </form>
        </div>
      ) : (
        <div>
          <div className="card mb-8 flex justify-between items-center" style={{ borderLeft: '4px solid var(--danger)' }}>
            <div>
              <div className="text-sm text-muted">Detected Program</div>
              <div className="font-bold text-lg flex items-center gap-2">
                <CheckCircle2 size={18} className="text-success" />
                BSc (Hons) in Industrial Information Technology
              </div>
            </div>
            <button className="btn btn-secondary" onClick={() => setCurriculumLoaded(false)}>Reset</button>
          </div>

          <div className="card p-0 overflow-hidden mb-8">
            <table className="w-full text-left" style={{ width: '100%', borderCollapse: 'collapse' }}>
              <thead style={{ backgroundColor: 'rgba(255,255,255,0.05)' }}>
                <tr>
                  <th className="p-4 border-b border-border">Subject Code</th>
                  <th className="p-4 border-b border-border">Subject Name</th>
                  <th className="p-4 border-b border-border">Credits</th>
                  <th className="p-4 border-b border-border">Grade</th>
                </tr>
              </thead>
              <tbody>
                {mockSubjects.map((sub, i) => (
                  <tr key={i} style={{ borderBottom: '1px solid var(--border)' }}>
                    <td className="p-4 font-mono text-sm">{sub.code}</td>
                    <td className="p-4">{sub.name}</td>
                    <td className="p-4">{sub.credits}</td>
                    <td className="p-4">
                      <select className="form-input p-2" style={{ width: '100px' }}>
                        <option value="A+">A+</option>
                        <option value="A">A</option>
                        <option value="A-">A-</option>
                        <option value="B+">B+</option>
                        <option value="B">B</option>
                        <option value="B-">B-</option>
                        <option value="C+">C+</option>
                        <option value="C">C</option>
                        <option value="C-">C-</option>
                        <option value="D+">D+</option>
                        <option value="D">D</option>
                        <option value="E">E</option>
                      </select>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>

          <div className="flex justify-end gap-4 items-center">
            <div className="text-xl">Estimated GPA: <strong className="text-danger text-2xl ml-2">--</strong></div>
            <button className="btn btn-primary" style={{ backgroundColor: 'var(--danger)' }}>Calculate GPA</button>
          </div>
        </div>
      )}
    </div>
  );
}
