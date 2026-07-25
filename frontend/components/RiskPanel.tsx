import type { ApiResult } from "@/lib/api";
import type { RiskOut } from "@/lib/types";
import { StateBox } from "./StateBox";

function pct(n: number): string {
  return `${Math.round(n * 100)}%`;
}

export function RiskPanel({
  barangayId,
  result,
}: {
  barangayId: string;
  result: ApiResult<RiskOut>;
}) {
  if (!result.ok) {
    return (
      <section className="panel">
        <h2>Barangay risk</h2>
        <p className="sub">GET /risk/{barangayId}</p>
        <StateBox title="Backend unreachable or request failed">
          {result.error.message}
        </StateBox>
      </section>
    );
  }

  const r = result.data;
  return (
    <section className="panel">
      <h2>Barangay risk</h2>
      <p className="sub">
        GET /risk/{barangayId} · {r.barangay_name}, {r.municipality}
      </p>
      <div className="item-title">
        <span>Composite risk</span>
        <span className={`pill ${r.risk_level}`}>{r.risk_level}</span>
      </div>
      <dl className="scores">
        <div className="score">
          <dt>Risk</dt>
          <dd>{pct(r.risk_score)}</dd>
        </div>
        <div className="score">
          <dt>Hazard</dt>
          <dd>{pct(r.hazard_score)}</dd>
        </div>
        <div className="score">
          <dt>Exposure</dt>
          <dd>{pct(r.exposure_score)}</dd>
        </div>
        <div className="score">
          <dt>Vulnerability</dt>
          <dd>{pct(r.vulnerability_score)}</dd>
        </div>
      </dl>
      <p>
        Safe residents {r.safe_residents ?? 0} / {r.total_population ?? 0}
        {r.active_warnings?.length
          ? ` · Warnings: ${r.active_warnings.join("; ")}`
          : ""}
      </p>
    </section>
  );
}
