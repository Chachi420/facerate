// mirror-screens-home.jsx v3 — no emojis, typographic animal letter

function HomeScreen({ navigate, go, back }) {
  return (
    <div className="ms" style={{ display:'flex', flexDirection:'column' }}>
      <Masthead
        left={<Wordmark size={22} />}
        right={<CreditsChip count={14} onClick={() => navigate('paywall')} />}
      />

      <div className="ms-scroll">
        <div style={{ padding:'18px 16px 0' }}>

          {/* Last scan trophy card */}
          <div style={{ border:'0.5px solid var(--inkw)', padding:14, marginBottom:20, background:'var(--surface)', transition:'background 0.35s, border-color 0.35s', boxShadow:'var(--btn-shadow)' }}>
            <Eyebrow accent style={{ display:'block', marginBottom:10 }}>Last scan · 3 days ago</Eyebrow>
            <div style={{ display:'flex', alignItems:'center', gap:14, marginBottom:12 }}>
              {/* Animal emoji */}
              <span style={{ fontSize:52, lineHeight:1, flexShrink:0 }}>🦅</span>
              <div>
                <div style={{ fontFamily:'var(--serif)', fontSize:20, fontStyle:'italic', color:'var(--ink)', marginBottom:2 }}>The Heron</div>
                <div style={{ fontFamily:'var(--serif)', fontSize:12, fontStyle:'italic', color:'var(--inkm)' }}>Dark Ethereal</div>
              </div>
            </div>
            <Rule style={{ marginBottom:10 }} />
            <div style={{ display:'flex', alignItems:'baseline', gap:10 }}>
              <span style={{ fontFamily:'var(--serif)', fontSize:40, fontStyle:'italic', fontWeight:400, color:'var(--accent)', lineHeight:1, letterSpacing:'-0.02em' }}>7.4</span>
              <span style={{ fontFamily:'var(--sans)', fontSize:11, color:'var(--teal)', fontVariantNumeric:'tabular-nums' }}>↑ 0.4 since last</span>
              <div style={{ marginLeft:'auto', border:'0.5px solid var(--teal)', padding:'2px 7px' }}>
                <span style={{ fontFamily:'var(--sans)', fontSize:9, letterSpacing:'0.14em', textTransform:'uppercase', color:'var(--teal)' }}>New PB</span>
              </div>
            </div>
          </div>

          {/* Scan hero — concentric rings */}
          <div style={{ display:'flex', flexDirection:'column', alignItems:'center', gap:12, marginBottom:20 }}>
            <div style={{ position:'relative', width:96, height:96, flexShrink:0 }}>
              {[96,76,58].map((sz,i) => (
                <div key={i} style={{
                  position:'absolute',
                  top:(96-sz)/2, left:(96-sz)/2,
                  width:sz, height:sz, borderRadius:'50%',
                  border:`0.5px solid rgba(230,224,212,${0.28 - i*0.08})`,
                }} />
              ))}
              <div style={{ position:'absolute', inset:0, display:'flex', alignItems:'center', justifyContent:'center' }}>
                <span style={{ fontFamily:'var(--serif)', fontSize:32, fontStyle:'italic', color:'var(--ink)' }}>m</span>
              </div>
            </div>
          </div>
        </div>

        {/* Primary CTA */}
        <div style={{ padding:'0 16px 8px' }}>
          <InkBtn wide onClick={() => navigate('scan')}>Scan your face.</InkBtn>
        </div>
        <div style={{ textAlign:'center', paddingBottom:18 }}>
          <Eyebrow>or upload from gallery</Eyebrow>
        </div>

        {/* Info cards — no emojis */}
        <div style={{ display:'flex', gap:8, padding:'0 16px 24px' }}>
          <div style={{ flex:1, background:'var(--surface)', border:'0.5px solid var(--rule)', padding:12, boxShadow:'var(--btn-shadow)', transition:'background 0.35s' }}>
            <Eyebrow accent style={{ display:'block', marginBottom:6 }}>7-day streak</Eyebrow>
            <div style={{ fontFamily:'var(--serif)', fontSize:16, fontStyle:'italic', color:'var(--ink)' }}>Keep going.</div>
            {/* Mini streak bar */}
            <div style={{ display:'flex', gap:3, marginTop:8 }}>
              {[1,2,3,4,5,6,7].map(d => (
                <div key={d} style={{ flex:1, height:3, background: d<=5 ? 'var(--accent)' : 'var(--rule)' }} />
              ))}
            </div>
          </div>
          <div style={{ flex:1, background:'var(--surface)', border:'0.5px solid var(--rule)', padding:12, boxShadow:'var(--btn-shadow)', transition:'background 0.35s' }}>
            <Eyebrow accent style={{ display:'block', marginBottom:6 }}>Top 23% this week</Eyebrow>
            <div style={{ fontFamily:'var(--serif)', fontSize:16, fontStyle:'italic', color:'var(--ink)' }}>This week.</div>
            <div style={{ marginTop:8, height:3, background:'var(--rule)', position:'relative', overflow:'hidden' }}>
              <div style={{ position:'absolute', left:0, top:0, bottom:0, width:'77%', background:'var(--teal)' }} />
            </div>
          </div>
        </div>
      </div>

      <BottomNav active="home" go={go} />
    </div>
  );
}

Object.assign(window, { HomeScreen });
