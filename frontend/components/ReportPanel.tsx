import type { ApiResult } from "@/lib/api";
import type { ReportOut } from "@/lib/types";
import { StateBox } from "./StateBox";

function formatWhen(iso: string): string {
  const d = new Date(iso);
  if (Number.isNaN(d.getTime())) return iso;
  return d.toLocaleString();
}

export function ReportPanel({ result }: { result: ApiResult<ReportOut[]> }) {
  if (!result.ok) {
    return (
      <section className="panel">
        <h2>Incoming reports</h2>
        <p className="sub">GET /reports</p>
        <StateBox title="Backend unreachable or request failed">
          {result.error.message}
        </StateBox>
      </section>
    );
  }

  const pending = result.data.filter(
    (r) => (r.status ?? "pending").toLowerCase() === "pending",
  );
  const shown = pending.length > 0 ? pending : result.data;

  if (result.data.length === 0) {
    return (
      <section className="panel">
        <h2>Incoming reports</h2>
        <p className="sub">GET /reports</p>
        <StateBox title="No reports yet">
          The API is reachable. The in-memory report store is empty until
          citizens submit via mobile (<code>POST /reports</code>).
        </StateBox>
      </section>
    );
  }

  return (
    <section className="panel">
      <h2>Incoming reports</h2>
      <p className="sub">
        GET /reports · showing {shown.length}
        {pending.length > 0 ? " pending" : ""} of {result.data.length}
      </p>
      <ul className="list">
        {shown.map((r) => (
          <li key={r.id} className="item">
            <div className="item-title">
              <span>{r.title || "(untitled report)"}</span>
              <span className={`pill ${r.status ?? "pending"}`}>
                {r.status ?? "pending"} · {r.type ?? "hazard"}
              </span>
            </div>
            <p>{r.description || "No description"}</p>
            <p>
              {r.user_name ?? "Anonymous"}
              {r.barangay ? ` · ${r.barangay}` : ""}
              {r.municipality ? `, ${r.municipality}` : ""}
              {" · "}
              {formatWhen(r.timestamp)}
            </p>
          </li>
        ))}
      </ul>
    </section>
  );
}
