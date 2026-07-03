// mirror-screens-reading.jsx v3 — score tiers, PB badge, mode-aware, no emojis, typographic animals

function scoreTier(s) {
  if (s < 5)   return 'Brutal';
  if (s < 7)   return 'Solid';
  if (s < 8.5) return 'Top Tier';
  return 'Legendary';
}

function ResultsScreen({ navigate, go, back, mode }) {
  const { useState } = React;
  const [openSection, setOpenSection] = useState(null);
  const [glowTab, setGlowTab] = useState('skincare');
  const score = 7.4;
  const isPB = true; // simulate personal best

  const toggle = (i) => setOpenSection(openSection === i ? null : i);

  const features = [
    { label:'Jawline',  score:7.8 },
    { label:'Symmetry', score:8.1 },
    { label:'Eyes',     score:7.6 },
    { label:'Skin',     score:7.2 },
    { label:'Nose',     score:7.0 },
    { label:'Lips',     score:7.8 },
  ];

  const glowContent = {
    haircut: 'A textured crop or grown-out curtain fringe balances your long midface. Ask for weight above the ears — it shortens the visual length without touching structure.',
    skincare: 'Niacinamide 10% will flatten texture in your T-zone. SPF 50 daily — the skin tone is doing heavy lifting here and sun damage shows first in the under-eye zone.',
    beard: 'Short stubble (3–5mm) frames the jaw without concealing it. Your chin has natural definition — keep the neckline clean-shaved.',
    glasses: 'Thin round frames in tortoiseshell complement the Dark Ethereal archetype. Avoid heavy rectangular frames — they compete with your brow structure.',
  };

  const roastVibe = 'Solid foundation — the structure carries you. But the tension you\'re holding in your midface today reads as fatigue, not intensity. Sleep more. Come back when you mean it.';
  const niceVibe  = 'A measured presence. There\'s an edge in the structure of your face that reads as earned, not performed. The face you\'re wearing today holds its ground without needing to announce it.';

  const sections = [
    {
      title: 'Facial Features',
      content: (
        <div style={{ padding:'4px 0 6px' }}>
          {features.map((f,i) => <ScoreBar key={i} label={f.label} score={f.score} />)}
        </div>
      ),
    },
    {
      title: 'Your Archetype',
      content: (
        <div style={{ padding:'4px 0 12px' }}>
          <div style={{ fontFamily:'var(--serif)', fontSize:26, fontStyle:'italic', letterSpacing:'-0.02em', color:'var(--ink)', marginBottom:6 }}>The Heron</div>
          <p style={{ fontFamily:'var(--serif)', fontSize:13, lineHeight:1.55, color:'var(--inkm)', marginBottom:12 }}>
            Watchful, self-contained, patient with stillness. The Dark Ethereal archetype sits at the intersection of structural refinement and quiet intensity.
          </p>
          <button onClick={() => navigate('animal')} style={{ background:'none', border:'none', fontFamily:'var(--sans)', fontSize:10, letterSpacing:'0.16em', textTransform:'uppercase', color:'var(--accent)', padding:0 }}>
            See full reveal →
          </button>
        </div>
      ),
    },
    {
      title: 'Glow-Up Plan',
      content: (
        <div style={{ padding:'4px 0 8px' }}>
          <div style={{ display:'flex', gap:0, marginBottom:12, borderBottom:'0.5px solid var(--rule)' }}>
            {['haircut','skincare','beard','glasses'].map(tab => (
              <button key={tab} onClick={() => setGlowTab(tab)} style={{
                background:'none', border:'none',
                fontFamily:'var(--sans)', fontSize:9, letterSpacing:'0.14em',
                textTransform:'uppercase', paddingBottom:8, paddingLeft:8, paddingRight:8,
                color: glowTab===tab ? 'var(--accent)' : 'var(--inkw)',
                borderBottom: glowTab===tab ? '1px solid var(--accent)' : '1px solid transparent',
                marginBottom:'-0.5px',
              }}>{tab}</button>
            ))}
          </div>
          <p style={{ fontFamily:'var(--sans)', fontSize:12, lineHeight:1.6, color:'var(--inkm)' }}>{glowContent[glowTab]}</p>
        </div>
      ),
    },
    {
      title: 'Celebrity Match',
      content: (
        <div style={{ padding:'4px 0 12px', display:'flex', alignItems:'flex-start', gap:12 }}>
          <div style={{ flex:1 }}>
            <div style={{ fontFamily:'var(--serif)', fontSize:18, fontStyle:'italic', color:'var(--ink)', marginBottom:4 }}>Jeremy Allen White</div>
            <div style={{ fontFamily:'var(--sans)', fontSize:11, color:'var(--inkm)', lineHeight:1.5 }}>
              Shared brow compression, midface ratio, and jawline definition. The quiet intensity reads similarly in both portraits.
            </div>
          </div>
          <span style={{ background:'none', border:'0.5px solid var(--accent)', fontFamily:'var(--sans)', fontSize:10, color:'var(--accent)', padding:'3px 8px', letterSpacing:'0.1em', flexShrink:0 }}>87%</span>
        </div>
      ),
    },
    {
      title: 'Character Match',
      content: (
        <div style={{ padding:'4px 0 12px', display:'flex', alignItems:'flex-start', gap:12 }}>
          <div style={{ flex:1 }}>
            <div style={{ fontFamily:'var(--serif)', fontSize:18, fontStyle:'italic', color:'var(--ink)', marginBottom:4 }}>Harvey Specter</div>
            <div style={{ fontFamily:'var(--sans)', fontSize:11, color:'var(--inkm)', lineHeight:1.5 }}>
              Controlled, deliberate, reads the room before entering it. The structural restraint aligns with this archetype's authority without aggression.
            </div>
          </div>
          <span style={{ background:'none', border:'0.5px solid var(--accent)', fontFamily:'var(--sans)', fontSize:10, color:'var(--accent)', padding:'3px 8px', letterSpacing:'0.1em', flexShrink:0 }}>82%</span>
        </div>
      ),
    },
    {
      title: 'Vibe',
      content: (
        <div style={{ padding:'4px 0 12px' }}>
          <p style={{ fontFamily:'var(--serif)', fontSize:14, fontStyle:'italic', lineHeight:1.6, color:'var(--inkm)' }}>
            {mode === 'roast' ? roastVibe : niceVibe}
          </p>
        </div>
      ),
    },
  ];

  return (
    <div className="ms" style={{ display:'flex', flexDirection:'column' }}>
      <Masthead onBack={back}
        left={<Eyebrow>Scan no. 023</Eyebrow>}
        right={<Eyebrow>18 May 2026</Eyebrow>}
      />

      <div className="ms-scroll">
        <div style={{ padding:'20px 16px 0' }}>

          {/* Score block */}
          <div style={{ display:'flex', flexDirection:'column', alignItems:'center', marginBottom:20 }}>
            <Eyebrow accent style={{ display:'block', marginBottom:4, textAlign:'center' }}>Your score</Eyebrow>

            {/* Score + PB badge inline */}
            <div style={{ display:'flex', alignItems:'flex-start', gap:8, marginBottom:12 }}>
              <span style={{
                fontFamily:'var(--serif)', fontSize:92, fontStyle:'italic', fontWeight:400,
                color:'var(--accent)', letterSpacing:'-0.04em', lineHeight:1,
              }}>{score}</span>
              {isPB && (
                <div style={{
                  marginTop:10, border:'0.5px solid var(--teal)',
                  padding:'3px 8px', background:'none',
                }}>
                  <span style={{ fontFamily:'var(--sans)', fontSize:9, letterSpacing:'0.14em', textTransform:'uppercase', color:'var(--teal)' }}>New PB</span>
                </div>
              )}
            </div>

            {/* Score tier badge */}
            <div style={{ border:'0.5px solid var(--accent)', padding:'4px 12px', marginBottom:8 }}>
              <span style={{ fontFamily:'var(--sans)', fontSize:10, letterSpacing:'0.14em', textTransform:'uppercase', color:'var(--accent)' }}>
                {scoreTier(score)}
              </span>
            </div>

            {/* Percentile */}
            <div style={{ border:'0.5px solid var(--teal)', padding:'3px 10px', marginBottom:8 }}>
              <span style={{ fontFamily:'var(--sans)', fontSize:10, letterSpacing:'0.14em', textTransform:'uppercase', color:'var(--teal)' }}>Top 23% globally</span>
            </div>

            {/* Delta */}
            <span style={{ fontFamily:'var(--sans)', fontSize:12, color:'var(--teal)', fontVariantNumeric:'tabular-nums' }}>
              ↑ 0.4 from your last scan
            </span>
          </div>

          <Rule style={{ marginBottom:14 }} />

          {/* Expandable sections */}
          {sections.map((sec, i) => (
            <div key={i} style={{ marginBottom:6 }}>
              <button onClick={() => toggle(i)} style={{
                width:'100%', background:'var(--surface)',
                border:'0.5px solid var(--rule)', padding:'12px 14px',
                display:'flex', justifyContent:'space-between', alignItems:'center',
                textAlign:'left', transition:'background 0.2s',
              }}>
                <span style={{ fontFamily:'var(--sans)', fontSize:13, fontWeight:500, color:'var(--ink)' }}>{sec.title}</span>
                <span style={{ fontFamily:'var(--sans)', fontSize:15, color:'var(--accent)', lineHeight:1 }}>{openSection===i ? '−' : '+'}</span>
              </button>
              {openSection === i && (
                <div style={{ background:'var(--surface)', border:'0.5px solid var(--rule)', borderTop:'none', padding:'0 14px' }}>
                  {sec.content}
                </div>
              )}
            </div>
          ))}

          {/* Actions */}
          <div style={{ display:'flex', gap:8, padding:'14px 0 24px' }}>
            <OutlineBtn style={{ flex:'0 0 38%' }}>Save</OutlineBtn>
            <RustBtn onClick={() => navigate('animal')} style={{ flex:'0 0 calc(62% - 8px)' }}>Share my score →</RustBtn>
          </div>
        </div>
      </div>

      <BottomNav active="home" go={go} />
    </div>
  );
}

// ── Animal Reveal ──────────────────────────────────────────────────
function AnimalRevealScreen({ navigate, go, back }) {
  const { useState } = React;
  const [whyOpen, setWhyOpen] = useState(false);
  const rarity = 'rare';
  const rarityColor = RARITY[rarity].color;

  return (
    <div className="ms" style={{ display:'flex', flexDirection:'column' }}>
      <Masthead onBack={back} left={<Wordmark size={20} />} right={<Eyebrow accent>An archetype</Eyebrow>} />

      <div className="ms-scroll">
        <div style={{ display:'flex', flexDirection:'column', alignItems:'center', padding:'28px 16px 0' }}>

          {/* Animal emoji with rarity glow */}
          <div style={{
            width:120, height:120, borderRadius:'50%',
            display:'flex', alignItems:'center', justifyContent:'center',
            boxShadow:`0 0 32px 10px ${rarityColor}38`,
            marginBottom:18,
          }}>
            <span style={{ fontSize:80, lineHeight:1 }}>🦅</span>
          </div>

          <div style={{ fontFamily:'var(--serif)', fontSize:36, fontStyle:'italic', fontWeight:400, letterSpacing:'-0.02em', color:'var(--ink)', marginBottom:10, textAlign:'center' }}>
            The Heron
          </div>

          <div style={{ marginBottom:10 }}><RarityBadge rarity={rarity} /></div>

          <Eyebrow muted style={{ display:'block', textAlign:'center', marginBottom:18 }}>Top 12% of animals</Eyebrow>

          <p style={{ fontFamily:'var(--serif)', fontSize:14, fontStyle:'italic', color:'var(--inkm)', textAlign:'center', lineHeight:1.6, maxWidth:280, marginBottom:22 }}>
            "Watchful, self-contained,<br />patient with stillness."
          </p>

          <Rule style={{ width:'100%', marginBottom:0 }} />

          <button onClick={() => setWhyOpen(!whyOpen)} style={{
            width:'100%', background:'none', border:'none',
            display:'flex', justifyContent:'space-between', alignItems:'center',
            padding:'12px 0', textAlign:'left',
          }}>
            <Eyebrow>Why this animal?</Eyebrow>
            <span style={{ fontFamily:'var(--sans)', fontSize:14, color:'var(--inkw)' }}>{whyOpen ? '−' : '+'}</span>
          </button>

          {whyOpen && (
            <p style={{ fontFamily:'var(--sans)', fontSize:12, lineHeight:1.65, color:'var(--inkm)', paddingBottom:14, width:'100%' }}>
              The Heron is assigned to faces scoring high in vertical feature ratios and brow tension — a combination that reads as watchful. The eyes carry distance without vacancy. This archetype appears in 1 of every 200 analyzed portraits.
            </p>
          )}

          <Rule style={{ width:'100%', marginBottom:0 }} />

          <div style={{ width:'100%', padding:'18px 0 8px' }}>
            <RustBtn wide onClick={() => navigate('share')}>Share this archetype</RustBtn>
          </div>
          <button onClick={() => {}} style={{
            background:'none', border:'none', padding:'8px 0 24px',
            fontFamily:'var(--sans)', fontSize:10, letterSpacing:'0.14em',
            textTransform:'uppercase', color:'var(--inkm)',
          }}>Save to photos</button>
        </div>
      </div>
    </div>
  );
}

// ── Share Card ─────────────────────────────────────────────────────
function ShareCardScreen({ navigate, go, back }) {
  const rarity = 'rare';
  const rarityColor = RARITY[rarity].color;

  return (
    <div className="ms" style={{ display:'flex', flexDirection:'column', alignItems:'center', justifyContent:'space-between', padding:'0 14px 18px' }}>

      <div style={{ width:'100%', display:'flex', alignItems:'center', padding:'12px 4px 8px' }}>
        <BackBtn onClick={back} />
        <Eyebrow>Share card</Eyebrow>
      </div>

      {/* Card */}
      <div style={{
        width:'100%', flex:1,
        border:'0.5px solid var(--inkw)',
        background:'#110F0E',
        display:'flex', flexDirection:'column', alignItems:'center',
        justifyContent:'space-between', padding:'22px 22px 0',
        position:'relative', overflow:'hidden', marginBottom:12,
        transition:'border-color 0.35s',
      }}>
        <div style={{ width:'100%', display:'flex', justifyContent:'flex-end' }}>
          <span style={{ fontFamily:'var(--serif)', fontSize:13, fontStyle:'italic', color:'rgba(230,224,212,0.28)' }}>mirror</span>
        </div>

        <div style={{ display:'flex', flexDirection:'column', alignItems:'center', gap:12, flex:1, justifyContent:'center' }}>
          {/* Animal emoji with rarity glow */}
          <div style={{
            width:100, height:100, borderRadius:'50%',
            display:'flex', alignItems:'center', justifyContent:'center',
            boxShadow:`0 0 28px 10px ${rarityColor}44`,
          }}>
            <span style={{ fontSize:72, lineHeight:1 }}>🦅</span>
          </div>

          <div style={{ fontFamily:'var(--serif)', fontSize:104, fontStyle:'italic', fontWeight:400, color:'var(--accent)', letterSpacing:'-0.04em', lineHeight:1 }}>7.4</div>

          <div style={{ display:'flex', flexDirection:'column', alignItems:'center', gap:7 }}>
            <div style={{ fontFamily:'var(--serif)', fontSize:28, fontStyle:'italic', letterSpacing:'-0.02em', color:'#E6E0D4', textAlign:'center' }}>The Heron</div>
            <RarityBadge rarity={rarity} />
          </div>

          <div style={{ fontFamily:'var(--serif)', fontSize:15, fontStyle:'italic', color:'rgba(230,224,212,0.55)', textAlign:'center' }}>Dark Ethereal</div>
          <Eyebrow teal center style={{ display:'block', textAlign:'center' }}>Top 23% globally</Eyebrow>
        </div>

        {/* Rarity strip — bottom */}
        <div style={{ width:'calc(100% + 44px)', height:4, background:rarityColor, flexShrink:0 }} />
      </div>

      <div style={{ display:'flex', gap:8, width:'100%', flexShrink:0 }}>
        <OutlineBtn style={{ flex:1 }}>Save image</OutlineBtn>
        <RustBtn style={{ flex:1 }}>Share →</RustBtn>
      </div>
    </div>
  );
}

Object.assign(window, { ResultsScreen, AnimalRevealScreen, ShareCardScreen });
