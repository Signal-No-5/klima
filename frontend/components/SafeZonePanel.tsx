import type { ApiResult } from "@/lib/api";
import type { SafeZoneOut } from "@/lib/types";
import { StateBox } from "./StateBox";

export function SafeZonePanel({ result }: { result: ApiResult<SafeZoneOut[]> }) {
  if (!result.ok) {
    return (
      <section className="panel span-2">
        <h2>Safe zones</h2>
        <p className="sub">GET /safezones</p>
        <StateBox title="Backend unreachable or request failed">
          {result.error.message}
        </StateBox>
      </section>
    );
  }

  if (result.data.length === 0) {
    return (
      <section className="panel span-2">
        <h2>Safe zones</h2>
        <p className="sub">GET /safezones</p>
        <StateBox title="No safe zones returned">
          The API responded successfully, but the safe-zone list is empty.
        </StateBox>
      </section>
    );
  }

  return (
    <section className="panel span-2">
      <h2>Safe zones</h2>
      <p className="sub">GET /safezones · {result.data.length} site(s)</p>
      <ul className="list">
        {result.data.map((z) => {
          const cap = z.capacity ?? 0;
          const occ = z.current_occupancy ?? 0;
          const pct = cap > 0 ? Math.round((occ / cap) * 100) : 0;
          return (
            <li key={z.id} className="item">
              <div className="item-title">
                <span>{z.name}</span>
                <span className={`pill ${z.is_operational === false ? "critical" : "verified"}`}>
                  {z.is_operational === false ? "offline" : "operational"} ·{" "}
                  {z.type ?? "evacuation_center"}
                </span>
              </div>
              <p>
                {z.address ||
                  [z.barangay, z.municipality].filter(Boolean).join(", ") ||
                  "Address unspecified"}
              </p>
              <p>
                Occupancy {occ}/{cap || "?"} ({pct}%)
                {z.contact_number ? ` · ${z.contact_number}` : ""}
                {z.amenities?.length ? ` · ${z.amenities.join(", ")}` : ""}
              </p>
            </li>
          );
        })}
      </ul>
    </section>
  );
}
