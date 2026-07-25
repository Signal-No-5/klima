export default function HomePage() {
  return (
    <main
      style={{
        fontFamily: "Georgia, 'Times New Roman', serif",
        minHeight: "100vh",
        display: "grid",
        placeItems: "center",
        padding: "2rem",
        background:
          "linear-gradient(165deg, #e8f0ea 0%, #c5d4c8 45%, #9bb0a3 100%)",
        color: "#1a2e24",
      }}
    >
      <div style={{ maxWidth: "36rem", textAlign: "center" }}>
        <p style={{ letterSpacing: "0.12em", textTransform: "uppercase", fontSize: "0.75rem" }}>
          Klima
        </p>
        <h1 style={{ fontSize: "2rem", fontWeight: 600, margin: "0.75rem 0" }}>
          LGU dashboard not implemented yet
        </h1>
        <p style={{ lineHeight: 1.6, margin: 0 }}>
          This package is an honest monorepo scaffold. Citizen flows live in{" "}
          <code>mobile/</code>; API + ETL live in <code>backend/</code>. See root{" "}
          <code>STATUS.md</code>.
        </p>
      </div>
    </main>
  );
}
