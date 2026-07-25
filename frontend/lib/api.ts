import { getApiBaseUrl } from "./config";
import type { HazardOut, ReportOut, RiskOut, SafeZoneOut } from "./types";

export class ApiError extends Error {
  readonly status?: number;
  readonly baseUrl: string;

  constructor(message: string, baseUrl: string, status?: number) {
    super(message);
    this.name = "ApiError";
    this.baseUrl = baseUrl;
    this.status = status;
  }
}

export type ApiResult<T> =
  | { ok: true; data: T }
  | { ok: false; error: ApiError };

async function fetchJson<T>(path: string): Promise<T> {
  const baseUrl = getApiBaseUrl();
  const url = `${baseUrl}${path.startsWith("/") ? path : `/${path}`}`;

  let res: Response;
  try {
    res = await fetch(url, {
      cache: "no-store",
      headers: { Accept: "application/json" },
    });
  } catch {
    throw new ApiError(
      `Backend unreachable at ${baseUrl}. Start the API or set NEXT_PUBLIC_KLIMA_API_URL.`,
      baseUrl,
    );
  }

  if (!res.ok) {
    throw new ApiError(
      `GET ${path} returned ${res.status} ${res.statusText}`,
      baseUrl,
      res.status,
    );
  }

  return (await res.json()) as T;
}

async function settle<T>(fn: () => Promise<T>): Promise<ApiResult<T>> {
  try {
    return { ok: true, data: await fn() };
  } catch (err) {
    if (err instanceof ApiError) {
      return { ok: false, error: err };
    }
    const baseUrl = getApiBaseUrl();
    return {
      ok: false,
      error: new ApiError(
        err instanceof Error ? err.message : "Unknown fetch error",
        baseUrl,
      ),
    };
  }
}

/** Paths match backend `app/api/v1/endpoints/klima.py` (also mounted at root). */
export function getLatestHazards(): Promise<ApiResult<HazardOut[]>> {
  return settle(() => fetchJson<HazardOut[]>("/hazard/latest"));
}

export function getReports(): Promise<ApiResult<ReportOut[]>> {
  return settle(() => fetchJson<ReportOut[]>("/reports"));
}

export function getSafeZones(): Promise<ApiResult<SafeZoneOut[]>> {
  return settle(() => fetchJson<SafeZoneOut[]>("/safezones"));
}

export function getRisk(barangayId: string): Promise<ApiResult<RiskOut>> {
  const id = encodeURIComponent(barangayId);
  return settle(() => fetchJson<RiskOut>(`/risk/${id}`));
}

export function getHealth(): Promise<ApiResult<{ status: string }>> {
  return settle(() => fetchJson<{ status: string }>("/health"));
}
