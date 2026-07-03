// mirror-screens-onboarding.jsx v2 — no emojis, typographic animals

// ── Splash ────────────────────────────────────────────────────────
function SplashScreen({ navigate }) {
  const { useEffect, useState } = React;
  const [visible, setVisible] = useState(false);

  useEffect(() => {
    const t1 = setTimeout(() => setVisible(true), 100);
    const t2 = setTimeout(() => navigate('onboarding'), 2600);
    return () => { clearTimeout(t1); clearTimeout(t2); };
  }, []);

  return (
    <div className="ms" style={{ display:'flex', flexDirection:'column', alignItems:'center', justifyContent:'center' }}>
      <div style={{
        display:'flex', flexDirection:'column', alignItems:'center', gap:16,
        opacity: visible ? 1 : 0,
        transform: visible ? 'translateY(0)' : 'translateY(12px)',
        transition: 'opacity 1s ease, transform 1s ease',
      }}>
        {/* Full app name — large display treatment */}
        <span style={{
          fontFamily:'var(--serif)', fontSize:68, fontStyle:'italic',
          fontWeight:400, color:'var(--ink)', letterSpacing:'-0.025em', lineHeight:1,
        }}>mirror</span>

        {/* Thin rule */}
        <div style={{ width:40, height:'0.5px', background:'var(--accent)' }} />

        <span style={{ fontFamily:'var(--serif)', fontSize:16, fontStyle:'italic', color:'var(--inkm)', letterSpacing:'-0.01em' }}>
          AI rates your face.
        </span>
      </div>
    </div>
  );
}

// ── Onboarding slides ─────────────────────────────────────────────
const SLIDES = [
  {
    eyebrow: 'Scan · Score · Repeat',
    visual: () => (
      <div style={{ display:'flex', flexDirection:'column', alignItems:'center', gap:10 }}>
        <div style={{ fontFamily:'var(--serif)', fontSize:84, fontStyle:'italic', fontWeight:400, color:'var(--accent)', letterSpacing:'-0.04em', lineHeight:1 }}>8.3</div>
        <div style={{ display:'flex', gap:8, alignItems:'center' }}>
          <span style={{ border:'0.5px solid var(--accent)', padding:'3px 10px', fontFamily:'var(--sans)', fontSize:10, letterSpacing:'0.14em', textTransform:'uppercase', color:'var(--accent)' }}>Top Tier</span>
          <span style={{ border:'0.5px solid var(--teal)', padding:'3px 10px', fontFamily:'var(--sans)', fontSize:10, letterSpacing:'0.14em', textTransform:'uppercase', color:'var(--teal)' }}>Top 18% globally</span>
        </div>
      </div>
    ),
    headline: 'Your face, analyzed.',
    body: 'AI maps your features and returns a score out of 10 — plus the animal archetype your face carries today.',
  },
  {
    eyebrow: 'Collect your archetypes',
    visual: () => (
      <div style={{ display:'flex', gap:16, alignItems:'flex-end' }}>
        {[
          { name:'The Owl',     emoji:'🦉', rarity:'uncommon', size:44 },
          { name:'The Heron',   emoji:'🦅', rarity:'rare',     size:62 },
          { name:'The Panther', emoji:'🐆', rarity:'epic',     size:44 },
        ].map((a,i) => {
          const rc = RARITY[a.rarity].color;
          return (
            <div key={i} style={{ display:'flex', flexDirection:'column', alignItems:'center', gap:6 }}>
              <div style={{
                width: a.size+20, height: a.size+20, borderRadius:'50%',
                border:`0.5px solid ${rc}`,
                display:'flex', alignItems:'center', justifyContent:'center',
                boxShadow: i===1 ? `0 0 18px 6px ${rc}33` : 'none',
              }}>
                <span style={{ fontSize:a.size, lineHeight:1 }}>{a.emoji}</span>
              </div>
              <span style={{ fontFamily:'var(--sans)', fontSize:9, letterSpacing:'0.12em', textTransform:'uppercase', color:rc, border:`0.5px solid ${rc}`, padding:'2px 6px' }}>
                {RARITY[a.rarity].label}
              </span>
            </div>
          );
        })}
      </div>
    ),
    headline: '12 of ∞ archetypes.',
    body: 'Each scan surfaces an archetype from the collection. Common, Uncommon, Rare, Epic, Legendary — collect them all.',
  },
  {
    eyebrow: 'Made to share',
    visual: () => {
      const rc = RARITY.rare.color;
      return (
        <div style={{
          width:210, border:'0.5px solid var(--inkw)', background:'#110F0E',
          display:'flex', flexDirection:'column', alignItems:'center',
          padding:'18px 18px 0', position:'relative',
        }}>
          <span style={{ fontFamily:'var(--serif)', fontSize:12, fontStyle:'italic', color:'rgba(230,224,212,0.25)', alignSelf:'flex-end', marginBottom:10 }}>mirror</span>
          <div style={{ width:52, height:52, borderRadius:'50%', border:`0.5px solid ${rc}`, display:'flex', alignItems:'center', justifyContent:'center', boxShadow:`0 0 16px 6px ${rc}44`, marginBottom:8 }}>
            <span style={{ fontSize:36, lineHeight:1 }}>🦅</span>
          </div>
          <div style={{ fontFamily:'var(--serif)', fontSize:50, fontStyle:'italic', color:'#C4462D', letterSpacing:'-0.04em', lineHeight:1, marginBottom:6 }}>8.3</div>
          <div style={{ fontFamily:'var(--serif)', fontSize:18, fontStyle:'italic', color:'#E6E0D4', marginBottom:4 }}>The Heron</div>
          <span style={{ fontFamily:'var(--sans)', fontSize:9, letterSpacing:'0.12em', textTransform:'uppercase', color:rc, border:`0.5px solid ${rc}`, padding:'2px 7px', marginBottom:12 }}>RARE</span>
          <div style={{ width:'calc(100% + 36px)', height:4, background:rc }} />
        </div>
      );
    },
    headline: 'Screenshot and share.',
    body: 'Your score, your animal, your percentile — one tap away from your Story. Brag or keep it private.',
  },
];

function OnboardingScreen({ navigate }) {
  const { useState } = React;
  const [slide, setSlide] = useState(0);
  const s = SLIDES[slide];

  function next() {
    if (slide < SLIDES.length - 1) setSlide(slide + 1);
    else navigate('signup');
  }

  return (
    <div className="ms" style={{ display:'flex', flexDirection:'column' }}>
      <div style={{ display:'flex', justifyContent:'space-between', alignItems:'center', padding:'14px 16px 12px', flexShrink:0 }}>
        <Wordmark size={18} />
        <button onClick={() => navigate('signup')} style={{
          background:'none', border:'none', fontFamily:'var(--sans)', fontSize:9,
          letterSpacing:'0.18em', textTransform:'uppercase', color:'var(--inkw)',
        }}>Skip</button>
      </div>
      <Rule />

      <div style={{ flex:1, display:'flex', flexDirection:'column', alignItems:'center', justifyContent:'center', padding:'24px 24px 0', overflow:'hidden' }}>
        <Eyebrow accent style={{ display:'block', textAlign:'center', marginBottom:28 }}>{s.eyebrow}</Eyebrow>
        <div style={{ marginBottom:32, display:'flex', alignItems:'center', justifyContent:'center' }}>
          <s.visual />
        </div>
        <div style={{ textAlign:'center', maxWidth:300 }}>
          <div style={{ fontFamily:'var(--serif)', fontSize:30, fontStyle:'italic', fontWeight:400, letterSpacing:'-0.02em', color:'var(--ink)', lineHeight:1.15, marginBottom:12 }}>{s.headline}</div>
          <p style={{ fontFamily:'var(--serif)', fontSize:14, lineHeight:1.6, color:'var(--inkm)' }}>{s.body}</p>
        </div>
      </div>

      <div style={{ padding:'22px 16px 28px', flexShrink:0, display:'flex', flexDirection:'column', gap:16, alignItems:'center' }}>
        <div style={{ display:'flex', gap:6, alignItems:'center' }}>
          {SLIDES.map((_,i) => (
            <button key={i} onClick={() => setSlide(i)} style={{ background:'none', border:'none', padding:3 }}>
              <div style={{
                width: i===slide ? 20 : 6, height:6, borderRadius:3,
                background: i===slide ? 'var(--accent)' : 'var(--rule)',
                transition:'width 0.3s ease, background 0.3s ease',
              }} />
            </button>
          ))}
        </div>
        <button onClick={next} style={{
          width:'100%', padding:'15px', background:'var(--ink)', border:'none',
          fontFamily:'var(--serif)', fontSize:16, fontStyle:'italic',
          color:'var(--canvas)', letterSpacing:'-0.01em', boxShadow:'var(--btn-shadow)',
          transition:'background 0.35s, color 0.35s',
        }}>
          {slide < SLIDES.length-1 ? 'Next →' : 'Get started →'}
        </button>
      </div>
    </div>
  );
}

// ── Sign Up ───────────────────────────────────────────────────────
function SignUpScreen({ navigate, back }) {
  const { useState } = React;
  const [name, setName]   = useState('');
  const [email, setEmail] = useState('');
  const inputStyle = {
    width:'100%', background:'transparent', border:'none',
    borderBottom:'0.5px solid var(--rule)',
    padding:'13px 0', fontFamily:'var(--serif)', fontSize:16,
    color:'var(--ink)', letterSpacing:'-0.01em',
  };

  return (
    <div className="ms" style={{ display:'flex', flexDirection:'column' }}>
      <Masthead onBack={back} left={<Wordmark size={20} />} right={null} />
      <div className="ms-scroll">
        <div style={{ padding:'28px 16px 0' }}>
          <h1 style={{ fontFamily:'var(--serif)', fontSize:36, fontStyle:'italic', fontWeight:400, letterSpacing:'-0.02em', color:'var(--ink)', lineHeight:1.1, marginBottom:6 }}>
            Begin your<br />reading.
          </h1>
          <p style={{ fontFamily:'var(--serif)', fontSize:14, fontStyle:'italic', color:'var(--inkm)', marginBottom:30 }}>Create your account to start scanning.</p>

          <div style={{ display:'flex', flexDirection:'column', gap:6, marginBottom:24 }}>
            <input type="text" placeholder="Full name" value={name} onChange={e => setName(e.target.value)} style={inputStyle} />
            <input type="email" placeholder="Email address" value={email} onChange={e => setEmail(e.target.value)} style={inputStyle} />
          </div>

          <InkBtn wide onClick={() => navigate('camerapermission')}>Sit for your first reading.</InkBtn>

          <div style={{ display:'flex', alignItems:'center', gap:12, margin:'20px 0' }}>
            <div style={{ flex:1, height:'0.5px', background:'var(--rule)' }} />
            <span style={{ fontFamily:'var(--sans)', fontSize:10, color:'var(--inkw)', letterSpacing:'0.12em' }}>OR</span>
            <div style={{ flex:1, height:'0.5px', background:'var(--rule)' }} />
          </div>

          {/* Social buttons — no emojis */}
          <div style={{ display:'flex', flexDirection:'column', gap:8, marginBottom:24 }}>
            {['Continue with Apple', 'Continue with Google'].map((label, i) => (
              <button key={i} style={{
                width:'100%', background:'none',
                border:'0.5px solid var(--rule)', padding:'13px 18px',
                display:'flex', alignItems:'center', justifyContent:'center', gap:10,
                boxShadow:'var(--btn-shadow)', transition:'border-color 0.35s',
              }}>
                <span style={{ fontFamily:'var(--sans)', fontSize:13, fontWeight:500, color:'var(--ink)' }}>{label}</span>
              </button>
            ))}
          </div>

          <div style={{ textAlign:'center', marginBottom:18 }}>
            <button onClick={() => navigate('signin')} style={{ background:'none', border:'none', fontFamily:'var(--sans)', fontSize:12, color:'var(--inkm)' }}>
              Already reading? <span style={{ color:'var(--accent)' }}>Sign in →</span>
            </button>
          </div>

          <p style={{ fontFamily:'var(--sans)', fontSize:10, color:'var(--inkw)', textAlign:'center', lineHeight:1.6, paddingBottom:28 }}>
            By continuing you agree to our Terms of Service<br />and Privacy Policy. Must be 16 or older.
          </p>
        </div>
      </div>
    </div>
  );
}

// ── Sign In ───────────────────────────────────────────────────────
function SignInScreen({ navigate, back }) {
  const { useState } = React;
  const [email, setEmail]       = useState('');
  const [password, setPassword] = useState('');
  const inputStyle = {
    width:'100%', background:'transparent', border:'none',
    borderBottom:'0.5px solid var(--rule)',
    padding:'13px 0', fontFamily:'var(--serif)', fontSize:16,
    color:'var(--ink)', letterSpacing:'-0.01em',
  };

  return (
    <div className="ms" style={{ display:'flex', flexDirection:'column' }}>
      <Masthead onBack={back} left={<Wordmark size={20} />} right={null} />
      <div className="ms-scroll">
        <div style={{ padding:'28px 16px 0' }}>
          <h1 style={{ fontFamily:'var(--serif)', fontSize:36, fontStyle:'italic', fontWeight:400, letterSpacing:'-0.02em', color:'var(--ink)', lineHeight:1.1, marginBottom:6 }}>
            Welcome<br />back.
          </h1>
          <p style={{ fontFamily:'var(--serif)', fontSize:14, fontStyle:'italic', color:'var(--inkm)', marginBottom:30 }}>Your readings are waiting.</p>

          <div style={{ display:'flex', flexDirection:'column', gap:6, marginBottom:24 }}>
            <input type="email" placeholder="Email address" value={email} onChange={e => setEmail(e.target.value)} style={inputStyle} />
            <input type="password" placeholder="Password" value={password} onChange={e => setPassword(e.target.value)} style={inputStyle} />
          </div>

          <InkBtn wide onClick={() => navigate('home')}>Sign in.</InkBtn>

          <div style={{ textAlign:'center', marginTop:16, marginBottom:24 }}>
            <button style={{ background:'none', border:'none', fontFamily:'var(--sans)', fontSize:11, color:'var(--inkm)' }}>Forgot your password?</button>
          </div>

          <Rule />

          <div style={{ textAlign:'center', paddingTop:18, paddingBottom:28 }}>
            <button onClick={() => navigate('signup')} style={{ background:'none', border:'none', fontFamily:'var(--sans)', fontSize:12, color:'var(--inkm)' }}>
              New here? <span style={{ color:'var(--accent)' }}>Start reading →</span>
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}

// ── Camera Permission ─────────────────────────────────────────────
function CameraPermissionScreen({ navigate, back }) {
  return (
    <div className="ms" style={{ display:'flex', flexDirection:'column' }}>
      <Masthead onBack={back} left={<Wordmark size={20} />} right={null} />
      <div style={{ flex:1, display:'flex', flexDirection:'column', alignItems:'center', justifyContent:'center', padding:'0 24px 48px' }}>
        {/* Bracketed m icon */}
        <div style={{
          width:88, height:88, border:'0.5px solid var(--inkm)',
          display:'flex', alignItems:'center', justifyContent:'center',
          position:'relative', marginBottom:28, flexShrink:0,
          boxShadow:'var(--btn-shadow)',
        }}>
          {[{top:-2,left:-2},{top:-2,right:-2},{bottom:-2,left:-2},{bottom:-2,right:-2}].map((p,i) => {
            const R='right' in p, B='bottom' in p;
            return <div key={i} style={{
              position:'absolute', width:10, height:10,
              borderTop: B?'none':'1.5px solid var(--accent)',
              borderBottom: B?'1.5px solid var(--accent)':'none',
              borderLeft: R?'none':'1.5px solid var(--accent)',
              borderRight: R?'1.5px solid var(--accent)':'none',
              ...p,
            }}/>;
          })}
          <span style={{ fontFamily:'var(--serif)', fontSize:38, fontStyle:'italic', color:'var(--ink)' }}>m</span>
        </div>

        <h2 style={{ fontFamily:'var(--serif)', fontSize:26, fontStyle:'italic', fontWeight:400, letterSpacing:'-0.02em', color:'var(--ink)', textAlign:'center', lineHeight:1.2, marginBottom:12 }}>
          Your camera<br />stays private.
        </h2>
        <p style={{ fontFamily:'var(--serif)', fontSize:14, lineHeight:1.65, color:'var(--inkm)', textAlign:'center', marginBottom:36, maxWidth:280 }}>
          Mirror uses your front camera to read your face. No images are uploaded, stored, or shared — ever.
        </p>
        <div style={{ width:'100%', display:'flex', flexDirection:'column', gap:10 }}>
          <InkBtn wide onClick={() => navigate('notificationpermission')}>Allow camera access.</InkBtn>
          <button onClick={() => navigate('home')} style={{
            background:'none', border:'none', width:'100%', padding:'13px',
            fontFamily:'var(--sans)', fontSize:11, letterSpacing:'0.14em',
            textTransform:'uppercase', color:'var(--inkw)',
          }}>Not now</button>
        </div>
      </div>
    </div>
  );
}

// ── Notification Permission ───────────────────────────────────────
function NotificationPermissionScreen({ navigate, back }) {
  return (
    <div className="ms" style={{ display:'flex', flexDirection:'column' }}>
      <Masthead onBack={back} left={<Wordmark size={20} />} right={null} />
      <div style={{ flex:1, display:'flex', flexDirection:'column', alignItems:'center', justifyContent:'center', padding:'0 24px 48px' }}>
        {/* Streak visual — no emoji */}
        <div style={{ display:'flex', flexDirection:'column', alignItems:'center', gap:10, marginBottom:28 }}>
          <div style={{ display:'flex', gap:4, alignItems:'flex-end' }}>
            {[1,2,3,4,5,6,7].map(d => (
              <div key={d} style={{
                width:18, height: 10 + d*5,
                background: d<=5 ? 'var(--accent)' : 'var(--rule)',
                transition:'background 0.35s',
              }} />
            ))}
          </div>
          <Eyebrow accent>7-day streak</Eyebrow>
        </div>

        <h2 style={{ fontFamily:'var(--serif)', fontSize:26, fontStyle:'italic', fontWeight:400, letterSpacing:'-0.02em', color:'var(--ink)', textAlign:'center', lineHeight:1.2, marginBottom:12 }}>
          Stay in<br />practice.
        </h2>
        <p style={{ fontFamily:'var(--serif)', fontSize:14, lineHeight:1.65, color:'var(--inkm)', textAlign:'center', marginBottom:36, maxWidth:280 }}>
          Scanning daily sharpens your baseline and builds your streak. One reminder a day — nothing more.
        </p>
        <div style={{ width:'100%', display:'flex', flexDirection:'column', gap:10 }}>
          <InkBtn wide onClick={() => navigate('home')}>Allow daily reminders.</InkBtn>
          <button onClick={() => navigate('home')} style={{
            background:'none', border:'none', width:'100%', padding:'13px',
            fontFamily:'var(--sans)', fontSize:11, letterSpacing:'0.14em',
            textTransform:'uppercase', color:'var(--inkw)',
          }}>Maybe later</button>
        </div>
      </div>
    </div>
  );
}

Object.assign(window, {
  SplashScreen, OnboardingScreen,
  SignUpScreen, SignInScreen,
  CameraPermissionScreen, NotificationPermissionScreen,
});
