// mirror-screens-profile.jsx v3 — no emojis

function ProfileScreen({ navigate, go, back }) {
  const settings = [
    { group:'Account',     items:['Account','Preferences'] },
    { group:'Preferences', items:['Notifications'] },
    { group:'Legal',       items:['Legal','Sign out'] },
  ];

  return (
    <div className="ms" style={{ display:'flex', flexDirection:'column' }}>
      <Masthead onBack={back} left={<Eyebrow>Profile</Eyebrow>} right={null} />

      <div className="ms-scroll">
        <div style={{ padding:'18px 16px 0' }}>

          {/* Avatar + name */}
          <div style={{ display:'flex', alignItems:'center', gap:12, marginBottom:18 }}>
            <div style={{
              width:56, height:56, borderRadius:'50%',
              background:'var(--surface)', border:'0.5px solid var(--rule)',
              display:'flex', alignItems:'center', justifyContent:'center', flexShrink:0,
              boxShadow:'var(--btn-shadow)',
            }}>
              <span style={{ fontFamily:'var(--serif)', fontSize:22, fontStyle:'italic', color:'var(--ink)' }}>ab</span>
            </div>
            <div>
              <div style={{ display:'flex', alignItems:'center', gap:8, marginBottom:2 }}>
                <span style={{ fontFamily:'var(--serif)', fontSize:22, fontWeight:400, color:'var(--ink)', letterSpacing:'-0.01em' }}>Abhinav</span>
                <span style={{
                  fontFamily:'var(--sans)', fontSize:9, letterSpacing:'0.16em', textTransform:'uppercase',
                  color:'var(--accent)', border:'0.5px solid var(--accent)', padding:'2px 7px',
                }}>PRO</span>
              </div>
              <span style={{ fontFamily:'var(--sans)', fontSize:11, color:'var(--inkm)' }}>abhinav@gmail.com</span>
            </div>
          </div>

          {/* Credits row */}
          <div style={{ background:'var(--surface)', border:'0.5px solid var(--rule)', padding:'12px 14px', marginBottom:8, display:'flex', justifyContent:'space-between', alignItems:'center', boxShadow:'var(--btn-shadow)', transition:'background 0.35s' }}>
            <div style={{ display:'flex', alignItems:'center', gap:8 }}>
              <Eyebrow>Credits</Eyebrow>
              <span style={{ fontFamily:'var(--sans)', fontSize:12, color:'var(--accent)', fontWeight:500, fontVariantNumeric:'tabular-nums' }}>14</span>
            </div>
            <button onClick={() => navigate('paywall')} style={{
              background:'none', border:'none', fontFamily:'var(--sans)',
              fontSize:10, letterSpacing:'0.14em', textTransform:'uppercase', color:'var(--accent)',
            }}>Buy more →</button>
          </div>

          {/* Streak row — no emoji */}
          <div style={{ background:'var(--surface)', border:'0.5px solid var(--rule)', padding:'12px 14px', marginBottom:18, boxShadow:'var(--btn-shadow)', transition:'background 0.35s' }}>
            <div style={{ display:'flex', justifyContent:'space-between', alignItems:'center', marginBottom:8 }}>
              <Eyebrow accent>7-day streak</Eyebrow>
              <span style={{ fontFamily:'var(--sans)', fontSize:11, fontStyle:'normal', color:'var(--ink)' }}>day 5 of 7</span>
            </div>
            <div style={{ display:'flex', gap:3 }}>
              {[1,2,3,4,5,6,7].map(d => (
                <div key={d} style={{ flex:1, height:4, background: d<=5 ? 'var(--accent)' : 'var(--rule)', transition:'background 0.35s' }} />
              ))}
            </div>
          </div>

          {/* Stats strip */}
          <div style={{
            background:'var(--surface)', border:'0.5px solid var(--rule)',
            padding:'14px 12px', marginBottom:20,
            display:'flex', boxShadow:'var(--btn-shadow)', transition:'background 0.35s',
          }}>
            {[
              { num:'23',     label:'Total scans' },
              { num:'8.1',    label:'Best score'  },
              { num:'Dark\nEthereal', label:'Top archetype' },
            ].map((s, i) => (
              <div key={i} style={{
                flex:1, display:'flex', flexDirection:'column', alignItems:'center', gap:4,
                borderRight: i<2 ? '0.5px solid var(--rule)' : 'none',
              }}>
                <span style={{ fontFamily:'var(--sans)', fontSize:16, fontWeight:500, color:'var(--ink)', fontVariantNumeric:'tabular-nums', textAlign:'center', whiteSpace:'pre', lineHeight:1.2 }}>{s.num}</span>
                <Eyebrow style={{ textAlign:'center', display:'block', fontSize:9 }}>{s.label}</Eyebrow>
              </div>
            ))}
          </div>

          {/* Settings */}
          {settings.map((group, gi) => (
            <div key={gi} style={{ marginBottom:14 }}>
              <Eyebrow style={{ display:'block', marginBottom:7 }}>{group.group}</Eyebrow>
              {group.items.map((item, ii) => (
                <div key={ii}>
                  <button style={{
                    width:'100%', background:'none', border:'none',
                    display:'flex', justifyContent:'space-between', alignItems:'center',
                    padding:'13px 0', textAlign:'left',
                  }}>
                    <span style={{ fontFamily:'var(--sans)', fontSize:13, color: item==='Sign out' ? 'var(--inkm)' : 'var(--ink)' }}>{item}</span>
                    {item !== 'Sign out' && <span style={{ color:'var(--accent)', fontSize:14 }}>→</span>}
                  </button>
                  <Rule />
                </div>
              ))}
            </div>
          ))}

          <div style={{ padding:'20px 0 28px', textAlign:'center' }}>
            <p style={{ fontFamily:'var(--serif)', fontSize:13, fontStyle:'italic', color:'var(--inkm)', lineHeight:1.55 }}>
              "The face you carry is not the face you were given."
            </p>
          </div>
        </div>
      </div>

      <BottomNav active="profile" go={go} />
    </div>
  );
}

function PaywallScreen({ navigate, go, back }) {
  const { useState } = React;
  const [selected, setSelected] = useState(1);

  const cards = [
    { word:'Starter',      count:10,  price:'$0.99', desc:'Unlock 5 epic plates',        border:'var(--rule)',  eyebrowColor:'var(--inkm)' },
    { word:'Most Chosen',  count:30,  price:'$2.99', desc:'30 credits · unlock 15 plates', border:'#C88818',    eyebrowColor:'#C88818'     },
    { word:'Best Value',   count:100, price:'$6.99', desc:'100 credits · unlock 50+ plates',border:'var(--rule)',eyebrowColor:'var(--accent)' },
  ];

  return (
    <div className="ms" style={{ display:'flex', flexDirection:'column' }}>
      <Masthead onBack={back}
        left={
          <div style={{ display:'flex', alignItems:'center', gap:6 }}>
            <Eyebrow brass>Unlock Legendary</Eyebrow>
            <span style={{ color:'#C88818', fontSize:11, fontFamily:'var(--serif)', fontStyle:'italic' }}>✦</span>
          </div>
        }
        right={null}
      />

      <div className="ms-scroll">
        <div style={{ padding:'22px 16px 0' }}>

          {/* Hero — typographic locked emblem */}
          <div style={{ display:'flex', flexDirection:'column', alignItems:'center', marginBottom:24 }}>
            <div style={{
              width:100, height:100, borderRadius:'50%',
              background:'var(--surface)', border:'0.5px solid var(--rule)',
              display:'flex', alignItems:'center', justifyContent:'center',
              marginBottom:16, position:'relative',
              boxShadow:`0 0 28px 8px rgba(200,136,24,0.12)`,
            }}>
              {/* Blurred animal letter behind lock */}
              <span style={{ fontFamily:'var(--serif)', fontSize:40, fontStyle:'italic', color:'var(--inkw)', filter:'blur(4px)', position:'absolute' }}>d</span>
              <div style={{
                position:'absolute', inset:0, display:'flex', alignItems:'center', justifyContent:'center',
              }}>
                <div style={{ border:'0.5px solid var(--inkm)', padding:'6px 8px' }}>
                  <span style={{ fontFamily:'var(--sans)', fontSize:10, letterSpacing:'0.16em', textTransform:'uppercase', color:'var(--inkm)' }}>Locked</span>
                </div>
              </div>
            </div>

            <h2 style={{ fontFamily:'var(--serif)', fontSize:28, fontStyle:'italic', fontWeight:400, letterSpacing:'-0.02em', color:'var(--ink)', textAlign:'center', lineHeight:1.2, marginBottom:10 }}>
              Some animals<br />stay hidden.
            </h2>
            <p style={{ fontFamily:'var(--sans)', fontSize:13, color:'var(--inkm)', textAlign:'center', lineHeight:1.6, maxWidth:280 }}>
              Buy credits to unlock Epic and Legendary archetypes, and reveal locked plates from past scans.
            </p>
          </div>

          {/* Vertical pricing cards */}
          <div style={{ display:'flex', flexDirection:'column', gap:8, marginBottom:18 }}>
            {cards.map((card, i) => (
              <button key={i} onClick={() => setSelected(i)} style={{
                background:'var(--surface)', border:`0.5px solid ${selected===i ? card.border : 'var(--rule)'}`,
                padding:'16px 16px', display:'flex', alignItems:'center', gap:14, textAlign:'left', width:'100%',
                boxShadow: selected===i ? 'var(--btn-shadow)' : 'none',
                transition:'border-color 0.2s, box-shadow 0.2s, background 0.35s',
              }}>
                <div style={{ flexShrink:0, width:52, display:'flex', flexDirection:'column', alignItems:'center' }}>
                  <span style={{ fontFamily:'var(--serif)', fontSize:30, fontStyle:'italic', fontWeight:400, color: selected===i ? 'var(--ink)' : 'var(--inkm)', lineHeight:1 }}>{card.count}</span>
                  <Eyebrow style={{ color:card.eyebrowColor, fontSize:9, marginTop:3, display:'block', textAlign:'center' }}>{card.word}</Eyebrow>
                </div>
                <div style={{ width:'0.5px', alignSelf:'stretch', background:'var(--rule)', flexShrink:0 }} />
                <div style={{ flex:1 }}>
                  <div style={{ fontFamily:'var(--serif)', fontSize:22, fontStyle:'italic', color:'var(--ink)', letterSpacing:'-0.01em', marginBottom:3 }}>{card.price}</div>
                  <div style={{ fontFamily:'var(--sans)', fontSize:11, color:'var(--inkm)' }}>{card.desc}</div>
                </div>
                <div style={{ background:'var(--accent)', padding:'7px 12px', flexShrink:0 }}>
                  <span style={{ fontFamily:'var(--sans)', fontSize:11, fontWeight:500, color:'#F4F0E8', letterSpacing:'0.04em' }}>Buy</span>
                </div>
              </button>
            ))}
          </div>

          <InkBtn wide>Unlock {cards[selected].count} credits.</InkBtn>
          <p style={{ fontFamily:'var(--serif)', fontSize:13, fontStyle:'italic', color:'var(--inkm)', textAlign:'center', marginTop:16, lineHeight:1.55 }}>
            Every purchase supports a sole reader's work.
          </p>
          <div style={{ textAlign:'center', padding:'16px 0 28px' }}>
            <Folio>Restore purchases</Folio>
          </div>
        </div>
      </div>
    </div>
  );
}

Object.assign(window, { ProfileScreen, PaywallScreen });
