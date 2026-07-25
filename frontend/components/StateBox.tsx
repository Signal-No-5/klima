type Props = {
  title: string;
  children: React.ReactNode;
};

export function StateBox({ title, children }: Props) {
  return (
    <div className="state-box" role="status">
      <strong>{title}</strong>
      {children}
    </div>
  );
}
