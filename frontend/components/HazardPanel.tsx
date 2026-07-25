import type { ApiResult } from "@/lib/api";
import type { HazardOut } from "@/lib/types";
import { StateBox } from "./StateBox";

function formatWhen(iso: string): string {
  const d = new Date(iso);
  if (Number.isNaN(d.getTime())) return iso;
  return d.toLocaleString();
}

export function HazardPanel({ result }: { result: ApiResult<HazardOut[]> }) {
  if (!result.ok) {
    return (
      <section className="panel">
        <h2>Latest hazards</h2>
        <p className="sub">GET /hazard/latest</p>
        <StateBox title="Backend unreachable or request failed">
          {result.error.message}
        </StateBox>
      </section>
    );
  }

  if (result.data.length === 0) {
    return (
      <section className="panel">
        <h2>Latest hazards</h2>
        <p className="sub">GET /hazard/latest</p>
        <StateBox title="No hazards returned">
          The API responded successfully, but the hazard feed is empty.
        </StateBox>
      </section>
    );
  }

  return (
    <section className="panel">
      <h2>Latest hazards</h2>
      <p className="sub">GET /hazard/latest · {result.data.length} item(s)</p>
      <ul className="list">
        {result.data.map((h) => (
          <li key={h.id} className="item">
            <div className="item-title">
              <span>{h.title}</span>
              <span className={`pill ${h.severity ?? "moderate"}`}>
                {h.severity ?? "moderate"} · {h.type}
              </span>
            </div>
            <p>{h.description}</p>
            <p>
              {[h.barangay, h.municipality, h.province].filter(Boolean).join(", ") ||
                "Location unspecified"}
              {" · "}
              {formatWhen(h.timestamp)}
              {h.source ? ` · ${h.source}` : ""}
              {h.is_verified ? " · verified" : ""}
            </p>
          </li>
        ))}
      </ul>
    </section>
  );
}
