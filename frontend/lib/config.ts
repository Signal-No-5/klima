/** Backend base URL (no trailing slash). Documented in frontend/README.md. */
export function getApiBaseUrl(): string {
  const raw =
    process.env.NEXT_PUBLIC_KLIMA_API_URL?.trim() || "http://127.0.0.1:8000";
  return raw.replace(/\/+$/, "");
}
