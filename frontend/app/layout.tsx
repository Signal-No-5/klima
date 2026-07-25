export const metadata = {
  title: "Klima LGU Dashboard",
  description: "Scaffold — not implemented yet",
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en">
      <body style={{ margin: 0 }}>{children}</body>
    </html>
  );
}
