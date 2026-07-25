import { HazardPanel } from "@/components/HazardPanel";
import { ReportPanel } from "@/components/ReportPanel";
import { RiskPanel } from "@/components/RiskPanel";
import { SafeZonePanel } from "@/components/SafeZonePanel";
import {
  getHealth,
  getLatestHazards,
  getReports,
  getRisk,
  getSafeZones,
} from "@/lib/api";
import { getApiBaseUrl } from "@/lib/config";

export const dynamic = "force-dynamic";

const DEFAULT_BARANGAY = "iba-este";

export default async function HomePage() {
  const baseUrl = getApiBaseUrl();
  const barangayId = DEFAULT_BARANGAY;

  const [health, hazards, reports, safeZones, risk] = await Promise.all([
    getHealth(),
    getLatestHazards(),
    getReports(),
    getSafeZones(),
    getRisk(barangayId),
  ]);

  const liveOk = health.ok;
  const anyDataOk =
    hazards.ok || reports.ok || safeZones.ok || risk.ok;

  return (
    <main className="app-shell">
      <header className="brand-row">
        <div>
          <h1 className="brand">
            Klima <span>LGU</span>
          </h1>
          <p className="tagline">
            Hazard feed, incoming reports, safe-zone occupancy, and barangay
            risk — fetched from the live backend (no fabricated demo payload).
          </p>
        </div>
        <div className="meta">
          <div>
            API base: <strong>{baseUrl}</strong>
          </div>
          <div>
            Env: <code>NEXT_PUBLIC_KLIMA_API_URL</code>
          </div>
        </div>
      </header>

      {liveOk ? (
        <div className="banner ok" role="status">
          Backend health OK ({health.data.status}). Views below use real{" "}
          <code>GET</code> responses from this base URL.
        </div>
      ) : (
        <div className="banner error" role="alert">
          <strong>Backend unreachable.</strong> {health.error.message}
          {!anyDataOk
            ? " All dashboard panels show explicit error states — data is not faked."
            : null}
        </div>
      )}

      <div className="grid">
        <HazardPanel result={hazards} />
        <ReportPanel result={reports} />
        <RiskPanel barangayId={barangayId} result={risk} />
        <SafeZonePanel result={safeZones} />
      </div>

      <p className="footer-note">
        Types in <code>lib/types.ts</code> mirror{" "}
        <code>schema/exported/*.schema.json</code>. Endpoints match{" "}
        <code>backend/app/api/v1/endpoints/klima.py</code> (also mounted at
        root). Map UI, triage actions, and auth are out of scope for this MVP.
      </p>
    </main>
  );
}
