import { Link } from 'react-router-dom'
import { useState, useEffect, useRef } from 'react'
import { shaderList } from '../shaders'

// ════════════════════════════════════════════════════════════════
// SHADER LAB - Landing Page (Design Proposal Implementation)
// Phase 1 & 2: Hero, Card Grid, Footer, Hover States
// ════════════════════════════════════════════════════════════════

// Emoji mapping for shaders (playful vibe)
const shaderEmojis: Record<string, string> = {
  gradient: '🌈',
  noise: '📺',
  'bos-shapes': '⬡',
  'bos-patterns': '✦',
  waves: '🌊',
  texture: '🎨',
  liquid: '💧',
  raymarching: '🔮',
  ripple: '💫',
  flowfield: '🌀',
  aurora: '✨',
  glass: '🪟',
  holographic: '🦋',
  voronoi: '🔷',
  'domain-warp': '🌫️',
  'julia-set': '🧬',
  'truchet-tiles': '🧩',
  'gradient-mesh': '🎭',
  distortion: '👆',
  'chromatic-aberration': '🌈',
  'particle-field': '⭐',
  'reaction-diffusion': '🧪',
  fractal: '❄️',
  'noise-field': '💡',
  'voronoi-advanced': '🔶',
  gyroid: '🌐',
  'thin-film': '🫧',
}

// ────────────────────────────────────────────────────────────────
// ANIMATED BACKGROUND PARTICLES
// ────────────────────────────────────────────────────────────────
function Particles() {
  const canvasRef = useRef<HTMLCanvasElement>(null)
  
  useEffect(() => {
    const canvas = canvasRef.current
    if (!canvas) return
    
    const ctx = canvas.getContext('2d')
    if (!ctx) return
    
    let animationId: number
    const particles: { x: number; y: number; vx: number; vy: number; size: number; opacity: number }[] = []
    
    const resize = () => {
      canvas.width = window.innerWidth
      canvas.height = window.innerHeight
    }
    
    resize()
    window.addEventListener('resize', resize)
    
    // Create particles
    for (let i = 0; i < 50; i++) {
      particles.push({
        x: Math.random() * canvas.width,
        y: Math.random() * canvas.height,
        vx: (Math.random() - 0.5) * 0.3,
        vy: (Math.random() - 0.5) * 0.3,
        size: Math.random() * 2 + 0.5,
        opacity: Math.random() * 0.15 + 0.05
      })
    }
    
    const animate = () => {
      ctx.clearRect(0, 0, canvas.width, canvas.height)
      
      particles.forEach(p => {
        p.x += p.vx
        p.y += p.vy
        
        if (p.x < 0) p.x = canvas.width
        if (p.x > canvas.width) p.x = 0
        if (p.y < 0) p.y = canvas.height
        if (p.y > canvas.height) p.y = 0
        
        ctx.beginPath()
        ctx.arc(p.x, p.y, p.size, 0, Math.PI * 2)
        ctx.fillStyle = `rgba(96, 165, 250, ${p.opacity})`
        ctx.fill()
      })
      
      animationId = requestAnimationFrame(animate)
    }
    
    animate()
    
    return () => {
      cancelAnimationFrame(animationId)
      window.removeEventListener('resize', resize)
    }
  }, [])
  
  return <canvas ref={canvasRef} style={styles.particles} />
}

// ────────────────────────────────────────────────────────────────
// HERO SECTION
// ────────────────────────────────────────────────────────────────
function Hero() {
  const [mounted, setMounted] = useState(false)
  
  useEffect(() => {
    setMounted(true)
  }, [])
  
  const scrollToShaders = () => {
    document.getElementById('shaders')?.scrollIntoView({ behavior: 'smooth' })
  }
  
  return (
    <section style={styles.hero}>
      {/* Gradient orbs for visual interest */}
      <div style={{ ...styles.orb, ...styles.orb1 }} />
      <div style={{ ...styles.orb, ...styles.orb2 }} />
      
      <div style={{
        ...styles.heroContent,
        opacity: mounted ? 1 : 0,
        transform: mounted ? 'translateY(0)' : 'translateY(30px)',
      }}>
        {/* Logo */}
        <h1 style={styles.logo}>SHADER LAB</h1>
        
        {/* Tagline */}
        <p style={styles.tagline}>
          Interactive WebGL Experiments
        </p>
        <p style={styles.subtitle}>
          Explore GLSL shader effects with real-time controls
        </p>
        
        {/* CTA Button */}
        <button onClick={scrollToShaders} style={styles.ctaButton}>
          <span>Explore Shaders</span>
          <span style={styles.ctaArrow}>↓</span>
        </button>
        
        {/* Stats */}
        <div style={styles.stats}>
          <div style={styles.stat}>
            <span style={styles.statValue}>{shaderList.length}</span>
            <span style={styles.statLabel}>Shaders</span>
          </div>
          <div style={styles.statDivider} />
          <div style={styles.stat}>
            <span style={styles.statValue}>GLSL</span>
            <span style={styles.statLabel}>Language</span>
          </div>
          <div style={styles.statDivider} />
          <div style={styles.stat}>
            <span style={styles.statValue}>60</span>
            <span style={styles.statLabel}>FPS Target</span>
          </div>
        </div>
      </div>
    </section>
  )
}

// ────────────────────────────────────────────────────────────────
// SHADER CARD
// ────────────────────────────────────────────────────────────────
function ShaderCard({ shader, index }: { shader: { id: string; name: string; description?: string }; index: number }) {
  const [isHovered, setIsHovered] = useState(false)
  
  const emoji = shaderEmojis[shader.id] || '✨'
  
  return (
    <Link
      to={`/${shader.id}`}
      style={{
        ...styles.card,
        transform: isHovered ? 'scale(1.02) translateY(-4px)' : 'scale(1) translateY(0)',
        borderColor: isHovered ? '#60A5FA' : 'rgba(255,255,255,0.1)',
        boxShadow: isHovered 
          ? '0 20px 40px rgba(96, 165, 250, 0.15), 0 0 0 1px rgba(96, 165, 250, 0.3)' 
          : '0 4px 20px rgba(0,0,0,0.3)',
        animationDelay: `${index * 0.05}s`,
      }}
      onMouseEnter={() => setIsHovered(true)}
      onMouseLeave={() => setIsHovered(false)}
    >
      {/* Emoji Icon */}
      <div style={{
        ...styles.cardEmoji,
        transform: isHovered ? 'scale(1.2) rotate(5deg)' : 'scale(1) rotate(0deg)',
        filter: isHovered ? 'drop-shadow(0 0 12px rgba(96, 165, 250, 0.5))' : 'none',
      }}>
        {emoji}
      </div>
      
      {/* Card Content */}
      <div style={styles.cardContent}>
        <h2 style={{
          ...styles.cardTitle,
          color: isHovered ? '#fff' : 'rgba(255,255,255,0.95)',
        }}>
          {shader.name}
        </h2>
        {shader.description && (
          <p style={{
            ...styles.cardDesc,
            opacity: isHovered ? 0.8 : 0.6,
          }}>
            {shader.description}
          </p>
        )}
      </div>
      
      {/* Arrow */}
      <div style={{
        ...styles.cardArrow,
        transform: isHovered ? 'translateX(4px)' : 'translateX(0)',
        color: isHovered ? '#60A5FA' : 'rgba(255,255,255,0.4)',
      }}>
        →
      </div>
      
      {/* Hover gradient overlay */}
      <div style={{
        ...styles.cardGlow,
        opacity: isHovered ? 1 : 0,
      }} />
    </Link>
  )
}

// ────────────────────────────────────────────────────────────────
// SHADER GALLERY
// ────────────────────────────────────────────────────────────────
function ShaderGallery() {
  return (
    <section id="shaders" style={styles.gallery}>
      <div style={styles.galleryHeader}>
        <h2 style={styles.galleryTitle}>Shader Collection</h2>
        <p style={styles.gallerySubtitle}>
          Click any shader to explore with interactive controls
        </p>
      </div>
      
      <div style={styles.grid}>
        {shaderList.map((shader, i) => (
          <ShaderCard key={shader.id} shader={shader} index={i} />
        ))}
      </div>
    </section>
  )
}

// ────────────────────────────────────────────────────────────────
// FOOTER
// ────────────────────────────────────────────────────────────────
function Footer() {
  return (
    <footer style={styles.footer}>
      <div style={styles.footerInner}>
        {/* Brand */}
        <div style={styles.footerBrand}>
          <span style={styles.footerLogo}>✨ Shader Lab</span>
          <p style={styles.footerTagline}>
            Exploring the art of GPU programming through interactive experiments.
          </p>
        </div>
        
        {/* Tech Stack */}
        <div style={styles.footerSection}>
          <h4 style={styles.footerHeading}>Built With</h4>
          <div style={styles.techBadges}>
            {['Three.js', 'React', 'GLSL', 'TypeScript'].map(tech => (
              <span key={tech} style={styles.techBadge}>{tech}</span>
            ))}
          </div>
        </div>
        
        {/* Links */}
        <div style={styles.footerSection}>
          <h4 style={styles.footerHeading}>Links</h4>
          <div style={styles.footerLinks}>
            <a 
              href="https://github.com/toddclawd-del/shader-playground" 
              target="_blank" 
              rel="noopener noreferrer"
              style={styles.footerLink}
            >
              GitHub →
            </a>
            <a 
              href="https://toddclawd-del.github.io/interaction-lab" 
              target="_blank" 
              rel="noopener noreferrer"
              style={styles.footerLink}
            >
              Interaction Lab →
            </a>
          </div>
        </div>
      </div>
      
      {/* Bottom bar */}
      <div style={styles.footerBottom}>
        <span style={styles.footerCopy}>
          © 2025 Shader Lab. Open Source.
        </span>
        <span style={styles.footerCredits}>
          Made with 💜 and GLSL
        </span>
      </div>
    </footer>
  )
}

// ════════════════════════════════════════════════════════════════
// MAIN EXPORT
// ════════════════════════════════════════════════════════════════
export function Home() {
  return (
    <div style={styles.container}>
      <Particles />
      <Hero />
      <ShaderGallery />
      <Footer />
    </div>
  )
}

// ════════════════════════════════════════════════════════════════
// STYLES
// ════════════════════════════════════════════════════════════════
const styles: Record<string, React.CSSProperties> = {
  // Container
  container: {
    minHeight: '100vh',
    background: '#000000',
    color: '#fff',
    fontFamily: '"Inter", "SF Pro Display", -apple-system, BlinkMacSystemFont, sans-serif',
    overflowX: 'hidden',
    position: 'relative',
  },
  
  // Particles background
  particles: {
    position: 'fixed',
    top: 0,
    left: 0,
    width: '100%',
    height: '100%',
    pointerEvents: 'none',
    zIndex: 0,
  },
  
  // HERO
  hero: {
    minHeight: '100vh',
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    position: 'relative',
    padding: '2rem',
    overflow: 'hidden',
  },
  heroContent: {
    textAlign: 'center',
    position: 'relative',
    zIndex: 1,
    transition: 'all 0.8s cubic-bezier(0.16, 1, 0.3, 1)',
  },
  logo: {
    fontSize: 'clamp(32px, 8vw, 56px)',
    fontWeight: 700,
    letterSpacing: '0.15em',
    marginBottom: '1rem',
    textShadow: '0 2px 20px rgba(96, 165, 250, 0.3)',
    fontFamily: '"JetBrains Mono", "SF Mono", monospace',
  },
  tagline: {
    fontSize: 'clamp(1.25rem, 3vw, 1.75rem)',
    fontWeight: 600,
    color: 'rgba(255,255,255,0.9)',
    marginBottom: '0.5rem',
    textShadow: '0 2px 8px rgba(0,0,0,0.8)',
  },
  subtitle: {
    fontSize: 'clamp(0.9rem, 2vw, 1.1rem)',
    color: 'rgba(255,255,255,0.6)',
    marginBottom: '2.5rem',
    textShadow: '0 2px 8px rgba(0,0,0,0.8)',
  },
  ctaButton: {
    display: 'inline-flex',
    alignItems: 'center',
    gap: '0.75rem',
    padding: '1rem 2rem',
    background: 'transparent',
    border: '2px solid rgba(255,255,255,0.3)',
    borderRadius: '50px',
    color: '#fff',
    fontSize: '1rem',
    fontWeight: 600,
    cursor: 'pointer',
    transition: 'all 0.2s ease-out',
    marginBottom: '3rem',
  },
  ctaArrow: {
    fontSize: '1.25rem',
    transition: 'transform 0.2s ease-out',
  },
  stats: {
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    gap: '2rem',
    flexWrap: 'wrap',
  },
  stat: {
    textAlign: 'center',
  },
  statValue: {
    display: 'block',
    fontSize: '1.5rem',
    fontWeight: 700,
    color: '#60A5FA',
  },
  statLabel: {
    fontSize: '0.8rem',
    color: 'rgba(255,255,255,0.5)',
    textTransform: 'uppercase',
    letterSpacing: '0.05em',
  },
  statDivider: {
    width: '1px',
    height: '40px',
    background: 'rgba(255,255,255,0.1)',
  },
  
  // Gradient orbs
  orb: {
    position: 'absolute',
    borderRadius: '50%',
    filter: 'blur(100px)',
    opacity: 0.4,
    pointerEvents: 'none',
  },
  orb1: {
    width: '400px',
    height: '400px',
    background: 'linear-gradient(135deg, #60A5FA 0%, #8B5CF6 100%)',
    top: '-100px',
    right: '-100px',
  },
  orb2: {
    width: '300px',
    height: '300px',
    background: 'linear-gradient(135deg, #F472B6 0%, #EC4899 100%)',
    bottom: '-50px',
    left: '-50px',
  },
  
  // GALLERY
  gallery: {
    position: 'relative',
    zIndex: 1,
    padding: '6rem 2rem',
    background: 'linear-gradient(to bottom, #000000 0%, #0a0a0a 100%)',
  },
  galleryHeader: {
    maxWidth: '800px',
    margin: '0 auto 3rem',
    textAlign: 'center',
  },
  galleryTitle: {
    fontSize: 'clamp(1.75rem, 4vw, 2.5rem)',
    fontWeight: 700,
    letterSpacing: '-0.02em',
    marginBottom: '0.75rem',
    textShadow: '0 2px 8px rgba(0,0,0,0.8)',
  },
  gallerySubtitle: {
    fontSize: '1rem',
    color: 'rgba(255,255,255,0.5)',
    textShadow: '0 2px 8px rgba(0,0,0,0.8)',
  },
  
  // GRID
  grid: {
    maxWidth: '1000px',
    margin: '0 auto',
    display: 'grid',
    gridTemplateColumns: 'repeat(3, 1fr)',
    gap: '1.25rem',
  },
  
  // CARD
  card: {
    position: 'relative',
    display: 'flex',
    flexDirection: 'column',
    padding: '1.5rem',
    background: '#1a1a1a',
    border: '1px solid rgba(255,255,255,0.1)',
    borderRadius: '16px',
    textDecoration: 'none',
    color: '#fff',
    transition: 'all 0.2s ease-out',
    overflow: 'hidden',
    minHeight: '160px',
  },
  cardEmoji: {
    fontSize: '2rem',
    marginBottom: '0.75rem',
    transition: 'all 0.2s ease-out',
  },
  cardContent: {
    flex: 1,
    display: 'flex',
    flexDirection: 'column',
    gap: '0.25rem',
  },
  cardTitle: {
    fontSize: '1.1rem',
    fontWeight: 600,
    letterSpacing: '-0.01em',
    margin: 0,
    transition: 'color 0.2s ease-out',
    textShadow: '0 2px 8px rgba(0,0,0,0.8)',
  },
  cardDesc: {
    fontSize: '0.85rem',
    color: 'rgba(255,255,255,0.6)',
    lineHeight: 1.4,
    margin: 0,
    transition: 'opacity 0.2s ease-out',
    textShadow: '0 2px 8px rgba(0,0,0,0.8)',
  },
  cardArrow: {
    position: 'absolute',
    top: '1.5rem',
    right: '1.5rem',
    fontSize: '1.25rem',
    transition: 'all 0.2s ease-out',
  },
  cardGlow: {
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    bottom: 0,
    background: 'radial-gradient(circle at 30% 30%, rgba(96, 165, 250, 0.08) 0%, transparent 60%)',
    pointerEvents: 'none',
    transition: 'opacity 0.2s ease-out',
  },
  
  // FOOTER
  footer: {
    position: 'relative',
    zIndex: 1,
    padding: '4rem 2rem 2rem',
    background: '#0a0a0a',
    borderTop: '1px solid rgba(255,255,255,0.08)',
  },
  footerInner: {
    maxWidth: '1000px',
    margin: '0 auto',
    display: 'grid',
    gridTemplateColumns: '2fr 1fr 1fr',
    gap: '3rem',
    marginBottom: '3rem',
  },
  footerBrand: {},
  footerLogo: {
    fontSize: '1.25rem',
    fontWeight: 600,
    display: 'block',
    marginBottom: '0.5rem',
  },
  footerTagline: {
    fontSize: '0.9rem',
    color: 'rgba(255,255,255,0.5)',
    lineHeight: 1.6,
    margin: 0,
  },
  footerSection: {
    display: 'flex',
    flexDirection: 'column',
    gap: '0.75rem',
  },
  footerHeading: {
    fontSize: '0.75rem',
    fontWeight: 600,
    textTransform: 'uppercase',
    letterSpacing: '0.1em',
    color: 'rgba(255,255,255,0.7)',
    margin: 0,
  },
  techBadges: {
    display: 'flex',
    flexWrap: 'wrap',
    gap: '0.5rem',
  },
  techBadge: {
    padding: '0.35rem 0.7rem',
    background: 'rgba(255,255,255,0.08)',
    borderRadius: '6px',
    fontSize: '0.8rem',
    fontWeight: 500,
    color: 'rgba(255,255,255,0.8)',
  },
  footerLinks: {
    display: 'flex',
    flexDirection: 'column',
    gap: '0.5rem',
  },
  footerLink: {
    color: 'rgba(255,255,255,0.5)',
    textDecoration: 'none',
    fontSize: '0.9rem',
    transition: 'color 0.2s ease-out',
  },
  footerBottom: {
    maxWidth: '1000px',
    margin: '0 auto',
    paddingTop: '2rem',
    borderTop: '1px solid rgba(255,255,255,0.08)',
    display: 'flex',
    justifyContent: 'space-between',
    alignItems: 'center',
    flexWrap: 'wrap',
    gap: '1rem',
  },
  footerCopy: {
    fontSize: '0.85rem',
    color: 'rgba(255,255,255,0.4)',
  },
  footerCredits: {
    fontSize: '0.85rem',
    color: 'rgba(255,255,255,0.4)',
  },
}

// ════════════════════════════════════════════════════════════════
// INJECT GLOBAL STYLES & RESPONSIVE CSS
// ════════════════════════════════════════════════════════════════
if (typeof document !== 'undefined') {
  const styleSheet = document.createElement('style')
  styleSheet.id = 'shader-lab-styles'
  styleSheet.textContent = `
    @import url('https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&family=JetBrains+Mono:wght@600;700&display=swap');
    
    /* CTA button hover */
    button:hover {
      border-color: #60A5FA !important;
      box-shadow: 0 0 20px rgba(96, 165, 250, 0.3), inset 0 0 20px rgba(96, 165, 250, 0.1);
    }
    button:hover span:last-child {
      transform: translateY(3px) !important;
    }
    
    /* Footer link hover */
    footer a:hover {
      color: #60A5FA !important;
    }
    
    /* Responsive grid: 3 → 2 → 1 columns */
    @media (max-width: 900px) {
      #shaders > div:last-child {
        grid-template-columns: repeat(2, 1fr) !important;
      }
    }
    
    @media (max-width: 640px) {
      #shaders > div:last-child {
        grid-template-columns: 1fr !important;
      }
      
      /* Stack footer on mobile */
      footer > div:first-child {
        grid-template-columns: 1fr !important;
        text-align: center;
      }
      
      footer > div:last-child {
        flex-direction: column !important;
        text-align: center;
      }
      
      /* Reduce hero stats gap on mobile */
      section:first-of-type > div > div:last-child {
        gap: 1rem !important;
      }
    }
    
    /* Reduced motion preference */
    @media (prefers-reduced-motion: reduce) {
      *, *::before, *::after {
        animation-duration: 0.01ms !important;
        animation-iteration-count: 1 !important;
        transition-duration: 0.01ms !important;
      }
    }
  `
  
  // Only add if not already present
  if (!document.getElementById('shader-lab-styles')) {
    document.head.appendChild(styleSheet)
  }
}
