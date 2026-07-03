// mirror-shared.jsx v4 — Cormorant Garamond, paper texture, button depth

(() => {
  const s = document.createElement('style');

  // Texture data URL for light mode (paper grain via SVG feTurbulence)
  const noiseSVG = `<svg xmlns="http://www.w3.org/2000/svg" width="256" height="256"><filter id="n"><feTurbulence type="fractalNoise" baseFrequency="0.75" numOctaves="4" stitchTiles="stitch"/><feColorMatrix type="saturate" values="0"/></filter><rect width="256" height="256" filter="url(#n)" opacity="0.055"/></svg>`;
  const noiseUrl = `url("data:image/svg+xml,${encodeURIComponent(noiseSVG)}")`;

  s.textContent = `
    @import url('https://fonts.googleapis.com/css2?family=Cormorant+Garamond:ital,wght@0,400;0,500;0,600;1,400;1,500;1,600&family=Inter+Tight:wght@400;500&display=swap');
    *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

    /* ── Dark theme ─────────────────────────────────────── */
    :root, [data-theme="dark"] {
      --canvas:  #110F0E;
      --surface: #1C1916;
      --sel:     #252118;
      --ink:     #E6E0D4;
      --inkm:    rgba(230,224,212,0.56);
      --inkw:    rgba(230,224,212,0.28);
      --rule:    rgba(230,224,212,0.08);
      --accent:  #C4462D;
      --teal:    #198868;
      --serif:   'Cormorant Garamond', 'EB Garamond', Georgia, serif;
      --sans:    'Inter Tight', sans-serif;
      --btn-shadow: 0 2px 0 rgba(0,0,0,0.45);
      --card-border: rgba(230,224,212,0.08);
    }

    /* ── Light theme ────────────────────────────────────── */
    [data-theme="light"] {
      --canvas:  #F2EDE2;
      --surface: #E9E2D4;
      --sel:     #DFD7C6;
      --ink:     #1C1916;
      --inkm:    rgba(28,25,22,0.52);
      --inkw:    rgba(28,25,22,0.28);
      --rule:    rgba(28,25,22,0.10);
      --accent:  #C4462D;
      --teal:    #167050;
      --btn-shadow: 0 2px 0 rgba(28,25,22,0.18), inset 0 1px 0 rgba(255,255,255,0.12);
      --card-border: rgba(28,25,22,0.10);
    }

    /* ── Shell ──────────────────────────────────────────── */
    .ms {
      width: 390px; height: 844px;
      background: var(--canvas);
      color: var(--ink);
      overflow: hidden;
      position: relative;
      display: flex; flex-direction: column;
      font-family: var(--serif);
      -webkit-font-smoothing: antialiased;
      transition: background 0.35s ease, color 0.35s ease;
    }
    .ms-scroll { overflow-y: auto; overflow-x: hidden; flex: 1; min-height: 0; }
    .ms-scroll::-webkit-scrollbar { display: none; }

    /* Light mode paper texture */
    [data-theme="light"] .ms {
      background-image: ${noiseUrl};
      background-size: 256px 256px;
    }

    /* ── Animations ─────────────────────────────────────── */
    @keyframes spin-cw  { from { transform:rotate(0deg);   } to { transform:rotate(360deg);  } }
    @keyframes spin-ccw { from { transform:rotate(0deg);   } to { transform:rotate(-360deg); } }
    @keyframes fade-up  { from { opacity:0; transform:translateY(8px); } to { opacity:1; transform:translateY(0); } }
    @keyframes dot-in   { from { opacity:0; r:0; } to { opacity:1; r:2; } }
    @keyframes scan-sweep {
      0%   { transform: translateY(-115px); opacity: 0; }
      6%   { opacity: 0.65; }
      90%  { opacity: 0.65; }
      100% { transform: translateY(115px); opacity: 0; }
    }
    @keyframes mesh-pulse {
      0%, 100% { opacity: 1; }
      50%       { opacity: 1.4; }
    }
    .fade-up { animation: fade-up 0.45s ease forwards; }

    /* ── Global ─────────────────────────────────────────── */
    button { cursor: pointer; -webkit-tap-highlight-color: transparent; }
    button:focus { outline: none; }
    button:active { opacity: 0.75; transform: translateY(1px); }
    input { background: transparent; caret-color: var(--accent); color: var(--ink); }
    input::placeholder { color: var(--inkw); }
    input:focus { outline: none; }
  `;
  document.head.appendChild(s);
})();

const C = {
  canvas: 'var(--canvas)', surface: 'var(--surface)', sel: 'var(--sel)',
  ink: 'var(--ink)', inkm: 'var(--inkm)', inkw: 'var(--inkw)',
  rule: 'var(--rule)', accent: 'var(--accent)', teal: 'var(--teal)',
};

const GREEN = '#3DDC97'; // face detection only

const RARITY = {
  common:    { label: 'COMMON',    color: '#7A7870' },
  uncommon:  { label: 'UNCOMMON',  color: '#198868' },
  rare:      { label: 'RARE',      color: '#6030B8' },
  epic:      { label: 'EPIC',      color: '#C06890' },
  legendary: { label: 'LEGENDARY', color: '#C88818' },
};

// ── Primitives ─────────────────────────────────────────────────────
function Eyebrow({ children, accent, teal, brass, muted, center, style: s }) {
  const color = accent ? 'var(--accent)' : teal ? 'var(--teal)' : brass ? '#C88818' : muted ? 'var(--inkw)' : 'var(--inkm)';
  return (
    <span style={{
      fontFamily: 'var(--sans)', fontSize: 10, fontWeight: 400,
      letterSpacing: '0.18em', textTransform: 'uppercase',
      color, lineHeight: 1.2, display: 'inline-block',
      textAlign: center ? 'center' : undefined, ...(s || {}),
    }}>{children}</span>
  );
}

function Rule({ style: s }) {
  return <div style={{ width: '100%', height: '0.5px', background: 'var(--rule)', flexShrink: 0, transition: 'background 0.35s', ...(s || {}) }} />;
}

function Wordmark({ size = 22, style: s }) {
  return (
    <span style={{
      fontFamily: 'var(--serif)', fontSize: size, fontStyle: 'italic',
      fontWeight: 400, color: 'var(--ink)', letterSpacing: '-0.01em',
      display: 'inline-block', transition: 'color 0.35s', ...(s || {}),
    }}>mirror</span>
  );
}

function CreditsChip({ count = 14, onClick }) {
  return (
    <button onClick={onClick} style={{
      display: 'flex', alignItems: 'center', gap: 4,
      border: '0.5px solid var(--inkw)', borderRadius: 20,
      padding: '4px 10px', background: 'none',
      boxShadow: 'var(--btn-shadow)', transition: 'box-shadow 0.35s',
    }}>
      <span style={{ fontFamily: 'var(--sans)', fontSize: 11, color: 'var(--accent)', fontVariantNumeric: 'tabular-nums', fontWeight: 500 }}>{count}</span>
      <span style={{ fontFamily: 'var(--sans)', fontSize: 11, color: 'var(--inkm)' }}>credits</span>
    </button>
  );
}

function AnimalLetter({ name, size = 52, color }) {
  const letter = name ? name.replace(/^The\s+/i, '')[0].toLowerCase() : '?';
  return (
    <span style={{
      fontFamily: 'var(--serif)', fontSize: size, fontStyle: 'italic',
      fontWeight: 400, color: color || 'var(--ink)', lineHeight: 1, display: 'block',
    }}>{letter}</span>
  );
}

function RarityBadge({ rarity }) {
  const r = RARITY[rarity] || RARITY.common;
  return (
    <span style={{
      fontFamily: 'var(--sans)', fontSize: 10, fontWeight: 500,
      letterSpacing: '0.16em', textTransform: 'uppercase',
      color: r.color, border: `0.5px solid ${r.color}`,
      padding: '3px 9px', display: 'inline-block', background: 'var(--surface)',
    }}>{r.label}</span>
  );
}

function ScoreBar({ label, score }) {
  const pct = Math.round((score / 10) * 100);
  return (
    <div style={{ marginBottom: 12 }}>
      <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: 4, alignItems: 'baseline' }}>
        <span style={{ fontFamily: 'var(--sans)', fontSize: 12, color: 'var(--inkm)' }}>{label}</span>
        <span style={{ fontFamily: 'var(--serif)', fontSize: 16, fontStyle: 'italic', color: 'var(--ink)' }}>{score}</span>
      </div>
      <div style={{ height: 3, background: 'var(--rule)', position: 'relative', overflow: 'hidden' }}>
        <div style={{ position: 'absolute', left: 0, top: 0, bottom: 0, width: `${pct}%`, background: 'var(--accent)' }} />
      </div>
    </div>
  );
}

function BackBtn({ onClick }) {
  return (
    <button onClick={onClick} style={{
      background: 'none', border: 'none', display: 'flex', alignItems: 'center',
      padding: '0 12px 0 0', color: 'var(--inkm)',
    }}>
      <svg width="16" height="16" viewBox="0 0 16 16" fill="none">
        <path d="M10 3L5 8L10 13" stroke="currentColor" strokeWidth="1" strokeLinecap="round" strokeLinejoin="round"/>
      </svg>
    </button>
  );
}

function Masthead({ left, right, onBack }) {
  return (
    <div style={{ flexShrink: 0 }}>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', padding: '14px 16px 12px' }}>
        <div style={{ display: 'flex', alignItems: 'center' }}>
          {onBack && <BackBtn onClick={onBack} />}
          <div>{left}</div>
        </div>
        <div>{right}</div>
      </div>
      <Rule />
    </div>
  );
}

function BottomNav({ active, go }) {
  const items = ['home', 'history', 'bestiary', 'profile'];
  return (
    <div style={{ flexShrink: 0 }}>
      <Rule />
      <div style={{ display: 'flex', justifyContent: 'space-around', padding: '11px 0 18px', background: 'var(--canvas)', transition: 'background 0.35s' }}>
        {items.map(item => (
          <button key={item} onClick={() => go(item)} style={{
            background: 'none', border: 'none',
            fontFamily: 'var(--sans)', fontSize: 9, fontWeight: active === item ? 500 : 400,
            letterSpacing: '0.18em', textTransform: 'uppercase',
            color: active === item ? 'var(--ink)' : 'var(--inkw)',
            padding: '4px 10px', transition: 'color 0.2s',
            borderBottom: active === item ? '1px solid var(--accent)' : '1px solid transparent',
          }}>{item}</button>
        ))}
      </div>
    </div>
  );
}

function InkBtn({ children, onClick, wide, style: s }) {
  return (
    <button onClick={onClick} style={{
      background: 'var(--ink)', color: 'var(--canvas)', border: 'none',
      fontFamily: 'var(--serif)', fontSize: 15, fontStyle: 'italic', fontWeight: 400,
      padding: '14px 22px', width: wide ? '100%' : 'auto',
      letterSpacing: '-0.01em', boxShadow: 'var(--btn-shadow)',
      transition: 'background 0.35s, color 0.35s, box-shadow 0.35s', ...(s || {}),
    }}>{children}</button>
  );
}

function OutlineBtn({ children, onClick, style: s }) {
  return (
    <button onClick={onClick} style={{
      background: 'none', color: 'var(--ink)',
      border: '0.5px solid var(--inkw)',
      fontFamily: 'var(--sans)', fontSize: 13, fontWeight: 500,
      padding: '14px 22px', letterSpacing: '0.02em',
      boxShadow: 'var(--btn-shadow)',
      transition: 'color 0.35s, border-color 0.35s', ...(s || {}),
    }}>{children}</button>
  );
}

function RustBtn({ children, onClick, wide, style: s }) {
  return (
    <button onClick={onClick} style={{
      background: 'var(--accent)', color: '#F4F0E8', border: 'none',
      fontFamily: 'var(--sans)', fontSize: 13, fontWeight: 500,
      padding: '15px 22px', width: wide ? '100%' : 'auto',
      letterSpacing: '0.03em', boxShadow: '0 2px 0 rgba(0,0,0,0.3)',
      transition: 'background 0.35s', ...(s || {}),
    }}>{children}</button>
  );
}

function Folio({ children, style: s }) {
  return (
    <span style={{ fontFamily: 'var(--serif)', fontSize: 11, fontStyle: 'italic', color: 'var(--inkw)', ...(s || {}) }}>{children}</span>
  );
}

Object.assign(window, {
  C, GREEN, RARITY, Eyebrow, Rule, Wordmark, CreditsChip, AnimalLetter,
  RarityBadge, ScoreBar, BackBtn, Masthead, BottomNav, InkBtn, OutlineBtn, RustBtn, Folio,
});
