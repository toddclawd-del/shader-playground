import { Link } from 'react-router-dom'
import { shaderList } from '../shaders'

export function Home() {
  return (
    <div style={styles.container}>
      <header style={styles.header}>
        <h1 style={styles.title}>Shader Playground</h1>
        <p style={styles.subtitle}>Interactive GLSL shader experiments</p>
      </header>
      
      <div style={styles.grid}>
        {shaderList.map((shader) => (
          <Link key={shader.id} to={`/${shader.id}`} style={styles.card}>
            <div style={styles.cardContent}>
              <h2 style={styles.cardTitle}>{shader.name}</h2>
              <p style={styles.cardDesc}>{shader.description}</p>
            </div>
            <div style={styles.arrow}>→</div>
          </Link>
        ))}
      </div>
    </div>
  )
}

const styles: Record<string, React.CSSProperties> = {
  container: {
    minHeight: '100vh',
    background: '#0a0a0a',
    color: '#fff',
    fontFamily: 'Inter, -apple-system, sans-serif',
    padding: '4rem 2rem'
  },
  header: {
    maxWidth: '800px',
    margin: '0 auto 4rem',
    textAlign: 'center'
  },
  title: {
    fontSize: 'clamp(2.5rem, 6vw, 4rem)',
    fontWeight: 800,
    letterSpacing: '-0.03em',
    marginBottom: '1rem'
  },
  subtitle: {
    fontSize: '1.25rem',
    color: 'rgba(255,255,255,0.6)'
  },
  grid: {
    maxWidth: '800px',
    margin: '0 auto',
    display: 'grid',
    gridTemplateColumns: 'repeat(auto-fill, minmax(300px, 1fr))',
    gap: '1rem'
  },
  card: {
    display: 'flex',
    justifyContent: 'space-between',
    alignItems: 'center',
    padding: '1.25rem 1.5rem',
    background: 'rgba(255,255,255,0.05)',
    border: '1px solid rgba(255,255,255,0.1)',
    borderRadius: '12px',
    textDecoration: 'none',
    color: '#fff',
    transition: 'all 0.2s ease'
  },
  cardContent: {
    display: 'flex',
    flexDirection: 'column',
    gap: '0.25rem'
  },
  cardTitle: {
    fontSize: '1.15rem',
    fontWeight: 600
  },
  cardDesc: {
    fontSize: '0.9rem',
    color: 'rgba(255,255,255,0.6)'
  },
  arrow: {
    fontSize: '1.25rem',
    color: 'rgba(255,255,255,0.4)'
  }
}
