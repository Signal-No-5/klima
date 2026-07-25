/**
 * Hand-mirrored from `schema/exported/*.schema.json` / `klima_schema.models`.
 * Wire JSON uses snake_case. Do not invent parallel field names.
 */

export type HazardOut = {
  id: string;
  type: string;
  title: string;
  description: string;
  latitude: number;
  longitude: number;
  barangay?: string;
  municipality?: string;
  province?: string;
  severity?: string;
  timestamp: string;
  image_url?: string | null;
  source?: string;
  is_verified?: boolean;
  upvotes?: number;
  reports?: number;
  metadata?: Record<string, unknown> | null;
};

export type ReportOut = {
  id: string;
  user_id?: string;
  user_name?: string;
  type?: string;
  hazard_type?: string | null;
  title?: string;
  description?: string;
  latitude?: number;
  longitude?: number;
  barangay?: string;
  municipality?: string;
  timestamp: string;
  image_url?: string | null;
  image_urls?: string[] | null;
  status?: string;
  responder_notes?: string | null;
  responded_at?: string | null;
};

export type RiskOut = {
  barangay_id: string;
  barangay_name: string;
  municipality: string;
  hazard_score: number;
  exposure_score: number;
  vulnerability_score: number;
  risk_score: number;
  risk_level: string;
  hazard_breakdown?: Record<string, number>;
  last_updated: string;
  active_warnings?: string[];
  safe_residents?: number;
  total_population?: number;
};

export type SafeZoneOut = {
  id: string;
  name: string;
  type?: string;
  latitude: number;
  longitude: number;
  address?: string;
  barangay?: string;
  municipality?: string;
  capacity?: number;
  current_occupancy?: number;
  amenities?: string[];
  contact_number?: string | null;
  is_operational?: boolean;
  elevation?: number | null;
  image_url?: string | null;
  metadata?: Record<string, unknown> | null;
};
