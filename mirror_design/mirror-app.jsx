// mirror-app.jsx v5 — mode state, isReturning, collection nav

const TWEAK_DEFAULTS = /*EDITMODE-BEGIN*/{
  "theme": "dark"
}/*EDITMODE-END*/;

function ThemeToggle({ theme, setTheme }) {
  const opts = [
    { id:'dark',  label:'Dark',  bg:'#110F0E', ink:'#E6E0D4' },
    { id:'light', label:'Light', bg:'#F4F0E8', ink:'#1C1916' },
  ];
  return (
    <div style={{ display:'flex', gap:8 }}>
      {opts.map(opt => (
        <button key={opt.id} onClick={() => setTheme(opt.id)} style={{
          flex:1, padding:'10px 8px', background:opt.bg,
          border:`${theme===opt.id ? '1.5px' : '0.5px'} solid ${theme===opt.id ? '#C4462D' : 'rgba(128,128,128,0.3)'}`,
          display:'flex', flexDirection:'column', alignItems:'center', gap:6, cursor:'pointer',
        }}>
          <div style={{ display:'flex', gap:3 }}>
            {[opt.ink, opt.bg].map((c,i) => (
              <div key={i} style={{ width:14, height:14, borderRadius:'50%', background:i===0 ? opt.ink : opt.bg, border:`0.5px solid ${opt.ink}44` }} />
            ))}
          </div>
          <span style={{ fontFamily:'var(--sans)', fontSize:10, letterSpacing:'0.12em', textTransform:'uppercase', color:opt.ink }}>{opt.label}</span>
        </button>
      ))}
    </div>
  );
}

function TweaksPanel({ theme, setTheme, scanMode, setScanMode, onClose }) {
  const panelBg   = theme==='dark' ? '#1C1916' : '#EBE5D9';
  const panelInk  = theme==='dark' ? '#E6E0D4' : '#1C1916';
  const panelRule = theme==='dark' ? 'rgba(230,224,212,0.10)' : 'rgba(28,25,22,0.10)';

  return (
    <div style={{
      position:'absolute', bottom:80, right:12, width:230,
      background:panelBg, border:`0.5px solid ${panelRule}`, zIndex:9999,
      padding:16, boxShadow:'0 8px 32px rgba(0,0,0,0.3)',
    }}>
      <div style={{ display:'flex', justifyContent:'space-between', alignItems:'center', marginBottom:12 }}>
        <span style={{ fontFamily:'var(--sans)', fontSize:10, letterSpacing:'0.16em', textTransform:'uppercase', color:panelInk }}>Tweaks</span>
        <button onClick={onClose} style={{ background:'none', border:'none', fontFamily:'var(--sans)', fontSize:16, color:panelInk, lineHeight:1, padding:0 }}>×</button>
      </div>
      <div style={{ height:'0.5px', background:panelRule, marginBottom:14 }} />

      <span style={{ fontFamily:'var(--sans)', fontSize:9, letterSpacing:'0.16em', textTransform:'uppercase', color:`${panelInk}70`, display:'block', marginBottom:8 }}>Appearance</span>
      <ThemeToggle theme={theme} setTheme={setTheme} />

      <div style={{ height:'0.5px', background:panelRule, margin:'14px 0' }} />

      <span style={{ fontFamily:'var(--sans)', fontSize:9, letterSpacing:'0.16em', textTransform:'uppercase', color:`${panelInk}70`, display:'block', marginBottom:8 }}>Scan Mode</span>
      <div style={{ display:'flex', gap:6 }}>
        {['nice','roast'].map(m => (
          <button key={m} onClick={() => setScanMode(m)} style={{
            flex:1, padding:'8px 4px', background:'none',
            border:`0.5px solid ${scanMode===m ? '#C4462D' : `${panelInk}30`}`,
            fontFamily:'var(--sans)', fontSize:11, letterSpacing:'0.08em',
            color: scanMode===m ? '#C4462D' : panelInk, cursor:'pointer',
          }}>{m==='nice' ? 'Be Nice' : 'Roast Me'}</button>
        ))}
      </div>
    </div>
  );
}

function App() {
  const { useState, useEffect } = React;
  const [screen, setScreen]       = useState('splash');
  const [stack,  setStack]        = useState([]);
  const [theme,  setTheme]        = useState(TWEAK_DEFAULTS.theme || 'dark');
  const [scanMode, setScanMode]   = useState('nice');
  const [isReturning, setIsReturning] = useState(false);
  const [tweaksOpen, setTweaksOpen]   = useState(false);

  useEffect(() => {
    window.__mirrorNav = (s) => { setStack([]); setScreen(s); };
    return () => { delete window.__mirrorNav; };
  }, []);

  useEffect(() => {
    const handler = (e) => {
      if (e.data?.type === '__activate_edit_mode')   setTweaksOpen(true);
      if (e.data?.type === '__deactivate_edit_mode') setTweaksOpen(false);
    };
    window.addEventListener('message', handler);
    window.parent.postMessage({ type:'__edit_mode_available' }, '*');
    return () => window.removeEventListener('message', handler);
  }, []);

  function applyTheme(t) {
    setTheme(t);
    window.parent.postMessage({ type:'__edit_mode_set_keys', edits:{ theme:t } }, '*');
  }

  function navigate(to) {
    if (to === 'loading') setIsReturning(stack.includes('results') || stack.includes('home'));
    setStack(s => [...s, screen]);
    setScreen(to);
  }

  function back() {
    if (stack.length > 0) { setScreen(stack[stack.length-1]); setStack(s => s.slice(0,-1)); }
    else setScreen('home');
  }

  function go(to) { setStack([]); setScreen(to); }

  const props = { navigate, back, go, screen, mode:scanMode, setMode:setScanMode };

  const screens = {
    splash:                 <SplashScreen               {...props} />,
    onboarding:             <OnboardingScreen            {...props} />,
    signup:                 <SignUpScreen                {...props} />,
    signin:                 <SignInScreen                {...props} />,
    camerapermission:       <CameraPermissionScreen      {...props} />,
    notificationpermission: <NotificationPermissionScreen {...props} />,
    home:     <HomeScreen         {...props} />,
    scan:     <ScanScreen         {...props} />,
    loading:  <LoadingScreen      {...props} isReturning={isReturning} />,
    results:  <ResultsScreen      {...props} />,
    animal:   <AnimalRevealScreen {...props} />,
    share:    <ShareCardScreen    {...props} />,
    history:  <HistoryScreen      {...props} />,
    bestiary: <BestiaryScreen     {...props} />,
    profile:  <ProfileScreen      {...props} />,
    paywall:  <PaywallScreen      {...props} />,
  };

  return (
    <div data-theme={theme} style={{ position:'relative', boxShadow:'0 0 0 0.5px rgba(128,128,128,0.12)' }}>
      {screens[screen] || screens.splash}
      {tweaksOpen && (
        <TweaksPanel
          theme={theme} setTheme={applyTheme}
          scanMode={scanMode} setScanMode={setScanMode}
          onClose={() => { setTweaksOpen(false); window.parent.postMessage({ type:'__edit_mode_dismissed' }, '*'); }}
        />
      )}
    </div>
  );
}

ReactDOM.createRoot(document.getElementById('root')).render(<App />);
