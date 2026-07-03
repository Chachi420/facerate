// mirror-screens-scan.jsx v5 — face detection mesh + no emojis

// ── Face landmark data — corrected anatomical proportions ──────────
// Oval: 168×222px, center (0,0). Eyes sit near y=0 (midpoint rule).
const FACE_PTS = {
  forehead: [[-42,-80],[-22,-90],[0,-93],[22,-90],[42,-80]],
  leftBrow:  [[-60,-34],[-50,-42],[-38,-45],[-27,-40],[-18,-33]],
  rightBrow: [[18,-33],[27,-40],[38,-45],[50,-42],[60,-34]],
  leftEye:  [[-56,-8],[-47,-17],[-38,-20],[-29,-17],[-20,-8],[-38,-1]],
  rightEye: [[20,-8],[29,-17],[38,-20],[47,-17],[56,-8],[38,-1]],
  nose:     [[0,-28],[0,-8],[0,30],[-12,36],[12,36],[0,42]],
  mouth:    [[-24,56],[-13,50],[-5,48],[5,48],[13,50],[24,56],
             [12,62],[-12,62],[-18,68],[0,74],[18,68],[0,78]],
  jaw:      [[-70,4],[-76,24],[-72,48],[-58,72],[-34,90],
             [0,100],[34,90],[58,72],[72,48],[76,24],[70,4]],
};

const MESH_LINES = [
  [...FACE_PTS.leftEye,  FACE_PTS.leftEye[0]],
  [...FACE_PTS.rightEye, FACE_PTS.rightEye[0]],
  FACE_PTS.leftBrow,
  FACE_PTS.rightBrow,
  FACE_PTS.nose.slice(0,3),
  [FACE_PTS.nose[3], FACE_PTS.nose[5], FACE_PTS.nose[4]],
  FACE_PTS.mouth.slice(0,8),
  FACE_PTS.mouth.slice(8),
  FACE_PTS.jaw,
  FACE_PTS.forehead,
];

// Secondary fill dots for deep-scan mode
const SECONDARY_PTS = [
  [-74,-6],[74,-6],           // temples
  [-70,18],[70,18],           // upper cheek
  [-66,38],[66,38],           // mid cheek
  [-60,56],[60,56],           // lower cheek
  [-48,-4],[48,-4],           // under-eye outer
  [-33,-3],[33,-3],           // under-eye inner
  [-10,12],[10,12],           // nose sides
  [-18,20],[18,20],           // nostril outer
  [-32,-38],[32,-38],         // between brows
  [-58,-72],[58,-72],         // forehead sides
  [-68,-52],[68,-52],         // temple ridge
  [-22,86],[22,86],           // chin sides
  [-44,96],[44,96],           // jaw bottom
  [-5,44],[5,44],             // philtrum
  [-24,58],[24,58],           // lip corners
  [-52,8],[52,8],             // cheekbone
];

const MEASURES = [
  { x1:-50, y1:-10, x2:50,  y2:-10, label:'67 mm',  lx:4,  ly:-16 },
  { x1:0,   y1:-8,  x2:0,   y2:50,  label:'1.618',  lx:9,  ly:22  },
  { x1:-62, y1:48,  x2:62,  y2:48,  label:'143 mm', lx:4,  ly:44  },
  { x1:0,   y1:-88, x2:0,   y2:98,  label:'196 mm', lx:12, ly:4   },
];

// Ordered group list for staggered dot animation
const DOT_ORDER = ['forehead','leftBrow','rightBrow','leftEye','rightEye','nose','mouth','jaw'];

// ── FaceMesh SVG component ─────────────────────────────────────────
function FaceMesh({ detected, deep, completed }) {
  const allDots = DOT_ORDER.flatMap((g, gi) =>
    (FACE_PTS[g] || []).map((pt, i) => ({ pt, delay: (gi * 6 + i) * 14 }))
  );

  return (
    <div style={{
      position: 'absolute', top: '50%', left: '50%',
      transform: 'translate(-50%, -58%)',
      width: 168, height: 222, pointerEvents: 'none', zIndex: 5,
    }}>
      <svg viewBox="-84 -111 168 222" width="168" height="222"
        style={{ overflow: 'visible' }}>
        <defs>
          <filter id="green-glow" x="-50%" y="-50%" width="200%" height="200%">
            <feGaussianBlur in="SourceGraphic" stdDeviation="3" result="blur"/>
            <feMerge><feMergeNode in="blur"/><feMergeNode in="SourceGraphic"/></feMerge>
          </filter>
          <filter id="line-glow" x="-50%" y="-50%" width="200%" height="200%">
            <feGaussianBlur in="SourceGraphic" stdDeviation="2" result="blur"/>
            <feMerge><feMergeNode in="blur"/><feMergeNode in="SourceGraphic"/></feMerge>
          </filter>
        </defs>

        {/* Oval — dashed when not detected, solid green when detected */}
        <ellipse cx="0" cy="0" rx="82" ry="109" fill="none"
          stroke={detected ? GREEN : 'rgba(230,224,212,0.40)'}
          strokeWidth={detected ? '1.5' : '0.5'}
          strokeDasharray={detected ? undefined : '5 4'}
          style={{ transition: 'stroke 0.2s ease-out, stroke-width 0.2s' }}
        />

        {/* Glow ring when detected */}
        {detected && (
          <ellipse cx="0" cy="0" rx="82" ry="109" fill="none"
            stroke={GREEN} strokeWidth="10" strokeOpacity="0.14"
          />
        )}

        {/* Mesh connector lines — subtle */}
        {detected && MESH_LINES.map((pts, i) => (
          <polyline key={i}
            points={pts.map(([x,y]) => `${x},${y}`).join(' ')}
            fill="none" stroke={GREEN} strokeWidth="0.4" strokeOpacity="0.28"
            strokeLinejoin="round" strokeLinecap="round"
            style={{ opacity: 1, transition: `opacity 0.2s ease-out ${300 + i*20}ms` }}
          />
        ))}

        {/* Deep mode: secondary dots — very fine */}
        {detected && deep && SECONDARY_PTS.map(([x,y], i) => (
          <circle key={`s${i}`} cx={x} cy={y} r="1" fill={GREEN} fillOpacity="0.35"
            style={{ opacity: 1, transition: `opacity 0.15s ease-out ${i*8}ms` }}
          />
        ))}

        {/* Deep mode: measurement lines */}
        {detected && deep && MEASURES.map((m, i) => (
          <g key={`m${i}`} style={{ opacity: completed ? 0 : 1, transition: 'opacity 0.4s' }}>
            <line x1={m.x1} y1={m.y1} x2={m.x2} y2={m.y2}
              stroke={GREEN} strokeWidth="0.5" strokeOpacity="0.55"
              strokeDasharray="3 2"
            />
            <text x={m.lx} y={m.ly} fill={GREEN} fillOpacity="0.75"
              fontSize="5" fontFamily="'Inter Tight', sans-serif"
              textAnchor="middle">{m.label}</text>
          </g>
        ))}

        {/* Deep mode: scanning line */}
        {detected && deep && (
          <g style={{ animation: 'scan-sweep 2.2s linear infinite' }} filter="url(#line-glow)">
            <line x1="-80" y1="0" x2="80" y2="0"
              stroke={GREEN} strokeWidth="1" strokeOpacity="0.6" />
            <line x1="-80" y1="0" x2="80" y2="0"
              stroke={GREEN} strokeWidth="5" strokeOpacity="0.12" />
          </g>
        )}

        {/* Primary landmark dots — smaller, more delicate */}
        {detected && allDots.map(({ pt: [x,y], delay }, i) => (
          <g key={`d${i}`}>
            <circle cx={x} cy={y} r="2.5" fill="none"
              stroke="rgba(17,15,14,0.60)" strokeWidth="0.8"
              style={{ opacity: 1, transition: `opacity 0.12s ease-out ${delay}ms` }}
            />
            <circle cx={x} cy={y} r="1.5" fill={GREEN}
              style={{ opacity: 1, transition: `opacity 0.12s ease-out ${delay}ms` }}
            />
          </g>
        ))}
      </svg>
    </div>
  );
}

// ── ScanScreen ─────────────────────────────────────────────────────
function ScanScreen({ navigate, go, back, mode, setMode }) {
  const { useState, useEffect } = React;
  const [mood, setMood] = useState('steady');
  const [flash, setFlash] = useState(false);
  const [faceDetected, setFaceDetected] = useState(false);

  useEffect(() => {
    const t = setTimeout(() => setFaceDetected(true), 2400);
    return () => clearTimeout(t);
  }, []);

  const moods = [
    { id: 'tired',  label: 'Tired'     },
    { id: 'steady', label: 'Steady'    },
    { id: 'awake',  label: 'Energized' },
  ];

  return (
    <div className="ms" style={{ display: 'flex', flexDirection: 'column' }}>
      <Masthead onBack={back}
        left={<Eyebrow>Scanning</Eyebrow>}
        right={<Eyebrow>Step 1 of 2</Eyebrow>}
      />

      {/* VIEWFINDER — always dark */}
      <div style={{
        flex: 1, position: 'relative', background: '#060408',
        overflow: 'hidden', display: 'flex',
        alignItems: 'center', justifyContent: 'center', minHeight: 0,
      }}>
        <div style={{
          position: 'absolute', inset: 0, pointerEvents: 'none',
          background: 'radial-gradient(ellipse 80% 90% at 50% 50%, transparent 40%, rgba(0,0,0,0.6) 100%)',
        }} />

        {/* Outer frame */}
        <div style={{ position: 'absolute', top: 16, left: 16, right: 16, bottom: 16, border: '0.5px solid rgba(230,224,212,0.09)', pointerEvents: 'none' }} />

        {/* Corner brackets */}
        {[{top:16,left:16},{top:16,right:16},{bottom:16,left:16},{bottom:16,right:16}].map((pos,i) => {
          const R='right' in pos, B='bottom' in pos;
          return <div key={i} style={{
            position:'absolute', width:20, height:20, pointerEvents:'none',
            borderTop:    B?'none':'1.5px solid var(--accent)',
            borderBottom: B?'1.5px solid var(--accent)':'none',
            borderLeft:   R?'none':'1.5px solid var(--accent)',
            borderRight:  R?'1.5px solid var(--accent)':'none',
            ...pos,
          }}/>;
        })}

        {/* Top controls */}
        <div style={{
          position:'absolute', top:28, left:28, right:28, zIndex:10,
          display:'flex', justifyContent:'space-between', alignItems:'center',
        }}>
          <button onClick={() => setFlash(f => !f)} style={{
            background:'none', border:'none',
            display:'flex', alignItems:'center', gap:5, padding:0,
          }}>
            <span style={{
              fontFamily:'var(--sans)', fontSize:9, letterSpacing:'0.16em',
              textTransform:'uppercase',
              color: flash ? 'var(--accent)' : 'rgba(230,224,212,0.35)',
            }}>Flash {flash ? 'On' : 'Off'}</span>
          </button>
          <button style={{ background:'none', border:'none' }}>
            <span style={{ fontFamily:'var(--sans)', fontSize:9, letterSpacing:'0.16em', textTransform:'uppercase', color:'rgba(230,224,212,0.35)' }}>Flip</span>
          </button>
        </div>

        {/* Face mesh SVG overlay (replaces CSS oval) */}
        <div style={{ position:'absolute', top:0, left:0, right:0, bottom:0 }}>
          <FaceMesh detected={faceDetected} deep={false} />
        </div>

        {/* Status */}
        <div style={{
          position:'absolute', bottom:24, left:0, right:0,
          display:'flex', alignItems:'center', justifyContent:'center', gap:7,
        }}>
          <div style={{
            width:5, height:5, borderRadius:'50%', flexShrink:0,
            background: faceDetected ? GREEN : 'rgba(230,224,212,0.22)',
            transition:'background 0.4s ease',
          }}/>
          <span style={{
            fontFamily:'var(--sans)', fontSize:10, letterSpacing:'0.16em',
            textTransform:'uppercase',
            color: faceDetected ? GREEN : 'rgba(230,224,212,0.35)',
            transition:'color 0.4s ease',
          }}>{faceDetected ? 'Face detected — tap to scan' : 'Position your face in the frame'}</span>
        </div>
      </div>

      {/* BOTTOM SHEET */}
      <div style={{ background:'var(--sel)', borderTop:'0.5px solid var(--rule)', padding:'16px 16px 0', flexShrink:0, transition:'background 0.35s' }}>

        <Eyebrow style={{ display:'block', marginBottom:10 }}>How are you feeling?</Eyebrow>

        {/* Mood pills — no emojis */}
        <div style={{ display:'flex', gap:6, marginBottom:12 }}>
          {moods.map(m => (
            <button key={m.id} onClick={() => setMood(m.id)} style={{
              flex:1, padding:'8px 0',
              background: mood===m.id ? 'var(--ink)' : 'transparent',
              border:`0.5px solid ${mood===m.id ? 'var(--ink)' : 'var(--inkw)'}`,
              transition:'background 0.2s, border-color 0.2s',
            }}>
              <span style={{ fontFamily:'var(--sans)', fontSize:11, color: mood===m.id ? 'var(--canvas)' : 'var(--ink)' }}>{m.label}</span>
            </button>
          ))}
        </div>

        {/* Mode toggle — no emojis */}
        <div style={{ display:'flex', gap:20, marginBottom:14, alignItems:'flex-end' }}>
          {[
            { id:'nice',  label:'Be Nice'  },
            { id:'roast', label:'Roast Me' },
          ].map(m => (
            <div key={m.id} style={{ display:'flex', flexDirection:'column', gap:3 }}>
              <button onClick={() => setMode(m.id)} style={{
                background:'none', border:'none',
                fontFamily:'var(--serif)', fontSize:14, fontStyle:'italic',
                color: mode===m.id ? 'var(--ink)' : 'var(--inkm)',
                borderBottom: mode===m.id ? '0.5px solid var(--ink)' : '0.5px solid transparent',
                paddingBottom:2, paddingLeft:0, paddingRight:0, transition:'color 0.2s',
              }}>{m.label}</button>
              {m.id==='roast' && mode==='roast' && (
                <Eyebrow accent style={{ fontSize:9 }}>Harshly honest.</Eyebrow>
              )}
            </div>
          ))}
        </div>

        {/* Action row */}
        <div style={{ display:'flex', alignItems:'center', justifyContent:'space-between', paddingBottom:22 }}>
          <button style={{ background:'none', border:'none', width:52, fontFamily:'var(--sans)', fontSize:9, letterSpacing:'0.16em', textTransform:'uppercase', color:'var(--inkm)', textAlign:'center' }}>
            Gallery
          </button>
          <div style={{ width:78, height:78, borderRadius:'50%', border:'1.5px solid var(--inkw)', display:'flex', alignItems:'center', justifyContent:'center', flexShrink:0 }}>
            <button onClick={() => navigate('loading')} style={{
              width:62, height:62, borderRadius:'50%',
              background: faceDetected ? GREEN : 'var(--accent)',
              border:'none', display:'flex', alignItems:'center', justifyContent:'center',
              transition:'background 0.3s ease', boxShadow: faceDetected ? `0 0 16px 4px ${GREEN}55` : 'none',
            }}>
              <span style={{ fontFamily:'var(--serif)', fontSize:26, fontStyle:'italic', color:'#F4F0E8', lineHeight:1 }}>m</span>
            </button>
          </div>
          <button style={{ background:'none', border:'none', width:52, fontFamily:'var(--sans)', fontSize:9, letterSpacing:'0.16em', textTransform:'uppercase', color:'var(--inkm)', textAlign:'center' }}>
            Timer
          </button>
        </div>
      </div>
    </div>
  );
}

// ── LoadingScreen ──────────────────────────────────────────────────
function LoadingScreen({ navigate, back, isReturning }) {
  const { useState, useEffect } = React;
  const steps = ['Detecting face', 'Mapping features', 'Matching archetype', 'Composing reading'];
  const [done, setDone] = useState(0);
  const [progress, setProgress] = useState(0);
  const [completed, setCompleted] = useState(false);

  useEffect(() => {
    const timers = [];
    steps.forEach((_, i) => {
      timers.push(setTimeout(() => { setDone(i + 1); setProgress((i + 1) * 25); }, 600 + i * 550));
    });
    timers.push(setTimeout(() => setCompleted(true), 600 + steps.length * 550 + 100));
    timers.push(setTimeout(() => navigate('results'), 600 + steps.length * 550 + 500));
    return () => timers.forEach(clearTimeout);
  }, []);

  // Face layers are pinned to the same origin as the FaceMesh SVG
  const faceStyle = {
    position: 'absolute', top: '50%', left: '50%',
    transform: 'translate(-50%, -58%)',
    pointerEvents: 'none',
  };

  return (
    <div className="ms" style={{ background: '#060408', position: 'relative', overflow: 'hidden' }}>

      {/* Cancel */}
      <button onClick={back} style={{
        position: 'absolute', top: 16, left: 16, zIndex: 30,
        background: 'none', border: 'none', fontFamily: 'var(--sans)',
        fontSize: 9, letterSpacing: '0.16em', textTransform: 'uppercase',
        color: 'rgba(230,224,212,0.30)',
      }}>← Cancel</button>

      {/* ── Face photo layers — aligned to mesh coordinate origin ── */}

      {/* Base skin tone — blur makes it feel photographic */}
      <div style={{ ...faceStyle, width: 168, height: 222, borderRadius: '52% 48% 50% 50%',
        background: `radial-gradient(ellipse 62% 68% at 46% 36%,
          rgba(205,156,108,0.82) 0%, rgba(178,130,84,0.65) 18%,
          rgba(148,102,62,0.42) 38%, rgba(98,62,34,0.18) 62%, transparent 82%)`,
        filter: 'blur(5px)',
      }} />

      {/* Lighting — brighter centre highlight */}
      <div style={{ ...faceStyle, width: 168, height: 222, borderRadius: '52% 48% 50% 50%',
        background: `radial-gradient(ellipse 38% 30% at 44% 28%,
          rgba(240,200,160,0.30) 0%, transparent 75%)`,
        filter: 'blur(3px)',
      }} />

      {/* Hair shadow at top */}
      <div style={{ ...faceStyle, width: 200, height: 110, top: 'calc(50% + -129px - 5px)', borderRadius: '50% 50% 30% 30%',
        background: 'radial-gradient(ellipse 85% 90% at 50% 10%, rgba(8,5,3,0.92) 20%, transparent 100%)',
        filter: 'blur(6px)',
      }} />

      {/* Neck shadow below face */}
      <div style={{ ...faceStyle, width: 72, height: 52,
        marginTop: 210,
        background: 'radial-gradient(ellipse 100% 80% at 50% 0%, rgba(165,118,76,0.26) 0%, transparent 100%)',
        filter: 'blur(4px)',
      }} />

      {/* Subtle noise grain over face */}
      <div style={{ ...faceStyle, width: 168, height: 222, borderRadius: '52% 48% 50% 50%',
        backgroundImage: `url("data:image/svg+xml,${encodeURIComponent('<svg xmlns="http://www.w3.org/2000/svg" width="168" height="222"><filter id="g"><feTurbulence type="fractalNoise" baseFrequency="0.72" numOctaves="4" stitchTiles="stitch"/><feColorMatrix type="saturate" values="0"/></filter><rect width="168" height="222" filter="url(#g)" opacity="0.06"/></svg>')}")`,
        mixBlendMode: 'overlay',
        opacity: 0.6,
      }} />

      {/* ── Face mesh — sits directly on top ── */}
      <div style={{ position: 'absolute', inset: 0, zIndex: 5, pointerEvents: 'none' }}>
        <FaceMesh detected={true} deep={true} completed={completed} />
      </div>

      {/* Cinematic vignette around edges */}
      <div style={{
        position: 'absolute', inset: 0, pointerEvents: 'none', zIndex: 6,
        background: 'radial-gradient(ellipse 68% 72% at 50% 42%, transparent 28%, rgba(6,4,8,0.92) 88%)',
      }} />

      {/* ── Progress panel — frosted glass at bottom ── */}
      <div style={{
        position: 'absolute', bottom: 0, left: 0, right: 0, zIndex: 10,
        background: 'rgba(6,4,8,0.88)',
        borderTop: `0.5px solid rgba(61,220,151,0.18)`,
        padding: '18px 20px 26px',
      }}>
        <p style={{
          fontFamily: 'var(--serif)', fontSize: 19, fontStyle: 'italic',
          color: 'rgba(230,224,212,0.88)', marginBottom: 18, letterSpacing: '-0.01em', lineHeight: 1.2,
        }}>
          {isReturning ? 'Welcome back. Composing today\'s reading.' : 'Analyzing your face…'}
        </p>

        <div style={{ display: 'flex', flexDirection: 'column', gap: 9, marginBottom: 16 }}>
          {steps.map((step, i) => (
            <div key={i} style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
              <div style={{
                width: 15, height: 15, borderRadius: '50%', flexShrink: 0,
                background: i < done ? GREEN : 'transparent',
                border: `0.5px solid ${i < done ? GREEN : 'rgba(230,224,212,0.18)'}`,
                display: 'flex', alignItems: 'center', justifyContent: 'center',
                transition: 'all 0.3s ease',
              }}>
                {i < done && <span style={{ fontSize: 8, color: '#060408', fontWeight: 700 }}>✓</span>}
              </div>
              <span style={{
                fontFamily: 'var(--sans)', fontSize: 10, letterSpacing: '0.16em', textTransform: 'uppercase',
                color: i < done ? 'rgba(230,224,212,0.88)' : 'rgba(230,224,212,0.22)',
                transition: 'color 0.3s ease',
              }}>{step}</span>
              {i < done && (
                <span style={{ marginLeft: 'auto', fontFamily: 'var(--sans)', fontSize: 9, color: GREEN, letterSpacing: '0.1em' }}>✓</span>
              )}
            </div>
          ))}
        </div>

        {/* Green progress bar */}
        <div style={{ width: '100%', height: '0.5px', background: 'rgba(230,224,212,0.10)', position: 'relative', overflow: 'hidden' }}>
          <div style={{
            position: 'absolute', left: 0, top: 0, bottom: 0,
            width: `${progress}%`, background: GREEN,
            transition: 'width 0.5s ease',
            boxShadow: `0 0 6px ${GREEN}`,
          }} />
        </div>
      </div>
    </div>
  );
}

Object.assign(window, { FaceMesh, ScanScreen, LoadingScreen });
