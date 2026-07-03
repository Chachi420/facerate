// mirror-screens-archive.jsx v3 — no emojis, typographic letters, collection rename

function HistoryScreen({ navigate, go, back }) {
  const { useState } = React;
  const [filter, setFilter] = useState('may 2026');

  const months = [
    {
      label: 'May 2026',
      scans: [
        { date:'18 may', name:'The Heron',  emoji:'🦅', rarity:'rare',     score:7.4, delta:+0.4 },
        { date:'15 may', name:'The Owl',    emoji:'🦉', rarity:'uncommon', score:7.0, delta:-0.1 },
        { date:'12 may', name:'The Fox',    emoji:'🦊', rarity:'uncommon', score:7.1, delta:+0.3 },
        { date:'09 may', name:'The Stag',   emoji:'🦌', rarity:'rare',     score:6.8, delta:null  },
      ],
    },
    {
      label: 'April 2026',
      scans: [
        { date:'30 apr', name:'The Panther', emoji:'🐆', rarity:'epic',    score:8.1, delta:+1.3 },
        { date:'22 apr', name:'The Heron',   emoji:'🦅', rarity:'rare',    score:6.8, delta:null  },
        { date:'14 apr', name:'The Owl',     emoji:'🦉', rarity:'uncommon',score:7.2, delta:+0.4 },
      ],
    },
  ];

  const filters = ['may 2026','april 2026','all'];
  const filtered = filter === 'all' ? months : months.filter(m => m.label.toLowerCase() === filter);

  return (
    <div className="ms" style={{ display:'flex', flexDirection:'column' }}>
      <Masthead onBack={back}
        left={<Eyebrow>History</Eyebrow>}
        right={<Eyebrow>23 scans</Eyebrow>}
      />

      <div className="ms-scroll">
        <div style={{ padding:'12px 16px 0' }}>

          {/* Streak — no emoji */}
          <div style={{ marginBottom:14, display:'flex', alignItems:'center', gap:10 }}>
            <Eyebrow accent>7-day streak</Eyebrow>
            <div style={{ display:'flex', gap:2, flex:1 }}>
              {[1,2,3,4,5,6,7].map(d => (
                <div key={d} style={{ flex:1, height:2, background: d<=5 ? 'var(--accent)' : 'var(--rule)' }} />
              ))}
            </div>
          </div>

          {/* Filter */}
          <div style={{ display:'flex', gap:14, marginBottom:14 }}>
            {filters.map(f => (
              <button key={f} onClick={() => setFilter(f)} style={{
                background:'none', border:'none',
                fontFamily:'var(--sans)', fontSize:10, letterSpacing:'0.14em', textTransform:'uppercase',
                padding:'0 0 5px',
                color: filter===f ? 'var(--ink)' : 'var(--inkw)',
                borderBottom: filter===f ? '0.5px solid var(--ink)' : '0.5px solid transparent',
              }}>{f}</button>
            ))}
          </div>

          {filtered.map((month, mi) => (
            <div key={mi} style={{ marginBottom:20 }}>
              <div style={{ fontFamily:'var(--serif)', fontSize:18, fontStyle:'italic', color:'var(--ink)', letterSpacing:'-0.01em', marginBottom:6 }}>{month.label}</div>
              <Rule style={{ marginBottom:0 }} />

              {month.scans.map((scan, si) => {
                const dc = scan.delta > 0 ? 'var(--teal)' : scan.delta < 0 ? '#E24B4A' : 'var(--ink)';
                const ds = scan.delta > 0 ? `↑${scan.delta.toFixed(1)}` : scan.delta < 0 ? `↓${Math.abs(scan.delta).toFixed(1)}` : '';
                const rc = RARITY[scan.rarity]?.color || RARITY.common.color;
                return (
                  <div key={si}>
                    <button onClick={() => navigate('results')} style={{
                      width:'100%', background:'none', border:'none',
                      display:'flex', alignItems:'center', gap:10,
                      padding:'12px 0', textAlign:'left',
                    }}>
                      <span style={{ fontFamily:'var(--sans)', fontSize:11, color:'var(--inkw)', minWidth:42, fontVariantNumeric:'tabular-nums' }}>{scan.date}</span>

                      {/* Animal emoji */}
                      <span style={{ fontSize:22, lineHeight:1, flexShrink:0 }}>{scan.emoji}</span>

                      <div style={{ flex:1 }}>
                        <div style={{ fontFamily:'var(--serif)', fontSize:14, color:'var(--ink)' }}>{scan.name}</div>
                      </div>
                      <div style={{ display:'flex', alignItems:'baseline', gap:4, flexShrink:0 }}>
                        <span style={{ fontFamily:'var(--serif)', fontSize:18, fontStyle:'italic', color:dc }}>{scan.score}</span>
                        {ds && <span style={{ fontFamily:'var(--sans)', fontSize:10, color:dc, fontVariantNumeric:'tabular-nums' }}>{ds}</span>}
                      </div>
                    </button>
                    <Rule />
                  </div>
                );
              })}
            </div>
          ))}
        </div>
      </div>

      <BottomNav active="history" go={go} />
    </div>
  );
}

// Collection (formerly Bestiary) — typographic letters, sorted by rarity
function BestiaryScreen({ navigate, go, back }) {
  const { useState } = React;
  const [filter, setFilter] = useState('all');

  // Sorted by rarity weight
  const rarityWeight = { legendary:0, epic:1, rare:2, uncommon:3, common:4 };
  const plates = [
    { name:'The Heron',    emoji:'🦅', rarity:'rare',      collected:true  },
    { name:'The Owl',      emoji:'🦉', rarity:'uncommon',  collected:true  },
    { name:'The Fox',      emoji:'🦊', rarity:'uncommon',  collected:true  },
    { name:'The Stag',     emoji:'🦌', rarity:'rare',      collected:true  },
    { name:'The Panther',  emoji:'🐆', rarity:'epic',      collected:true  },
    { name:'The Condor',   emoji:'🦅', rarity:'common',    collected:true  },
    { name:'The Wolf',     emoji:'🐺', rarity:'rare',      collected:false },
    { name:'The Lynx',     emoji:'🐈', rarity:'epic',      collected:false },
    { name:'The Dragon',   emoji:'🐉', rarity:'legendary', collected:false },
    { name:'—',            emoji:'?',  rarity:'common',    collected:false },
    { name:'—',            emoji:'?',  rarity:'uncommon',  collected:false },
    { name:'—',            emoji:'?',  rarity:'rare',      collected:false },
  ].sort((a,b) => rarityWeight[a.rarity] - rarityWeight[b.rarity]);

  const rarityFilters = ['all','rare','epic','legendary'];
  const shown = filter==='all' ? plates : plates.filter(p => p.rarity===filter);

  return (
    <div className="ms" style={{ display:'flex', flexDirection:'column' }}>
      <Masthead onBack={back}
        left={
          <span style={{ fontFamily:'var(--serif)', fontSize:18, fontStyle:'italic', color:'var(--ink)', letterSpacing:'-0.01em' }}>
            Collection · 12 of ∞
          </span>
        }
        right={null}
      />

      {/* Filter */}
      <div style={{ padding:'10px 16px', flexShrink:0, display:'flex', gap:8 }}>
        {rarityFilters.map(f => (
          <button key={f} onClick={() => setFilter(f)} style={{
            background: filter===f ? 'var(--ink)' : 'transparent',
            border:`0.5px solid ${filter===f ? 'var(--ink)' : 'var(--rule)'}`,
            fontFamily:'var(--sans)', fontSize:10, letterSpacing:'0.14em',
            textTransform:'uppercase', padding:'4px 10px',
            color: filter===f ? 'var(--canvas)' : 'var(--inkw)',
            transition:'background 0.2s, color 0.2s',
          }}>{f}</button>
        ))}
      </div>

      <Rule />

      <div className="ms-scroll">
        <div style={{ padding:'12px 16px 24px', display:'grid', gridTemplateColumns:'1fr 1fr', gap:8 }}>
          {shown.map((p, i) => {
            const rc = RARITY[p.rarity].color;
            const isGlow = p.collected && (p.rarity==='epic' || p.rarity==='legendary');
            return (
              <button key={i} onClick={() => p.collected && navigate('animal')} style={{
                background:'var(--surface)', border:`0.5px solid ${p.collected ? rc : 'var(--rule)'}`,
                aspectRatio:'1 / 1',
                display:'flex', flexDirection:'column', alignItems:'center', justifyContent:'center',
                padding:12, cursor: p.collected ? 'pointer' : 'default',
                boxShadow: isGlow ? `0 0 14px 3px ${rc}33` : 'var(--btn-shadow)',
                transition:'background 0.35s',
              }}>
                {/* Animal emoji — full color collected, dimmed undiscovered */}
                <div style={{ flex:1, display:'flex', alignItems:'center', justifyContent:'center' }}>
                  {p.collected ? (
                    <span style={{ fontSize:44, lineHeight:1 }}>{p.emoji}</span>
                  ) : (
                    <span style={{ fontSize:32, lineHeight:1, opacity:0.25, filter:'grayscale(1)' }}>{p.emoji !== '?' ? p.emoji : '—'}</span>
                  )}
                </div>
                <div style={{ fontFamily:'var(--serif)', fontSize:12, color: p.collected ? 'var(--ink)' : 'var(--inkw)', marginBottom:6, textAlign:'center' }}>
                  {p.collected ? p.name : '—'}
                </div>
                <span style={{
                  fontFamily:'var(--sans)', fontSize:9, letterSpacing:'0.14em', textTransform:'uppercase',
                  color: p.collected ? rc : `${rc}50`,
                  border:`0.5px solid ${p.collected ? rc : `${rc}40`}`,
                  padding:'2px 6px',
                }}>{RARITY[p.rarity].label}</span>
              </button>
            );
          })}
        </div>
      </div>

      <BottomNav active="bestiary" go={go} />
    </div>
  );
}

Object.assign(window, { HistoryScreen, BestiaryScreen });
