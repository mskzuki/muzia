/* muzy — shared shell: icons, abstract cover art, sidebar, toolbar, player */

/* ============================================================
   ICONS  (SF-Symbol-flavored, 1em stroke icons)
   ============================================================ */
const I = (p) => {
  const { d, size = 16, sw = 1.6, fill = 'none', vb = 24, children } = p;
  return (
    <svg width={size} height={size} viewBox={`0 0 ${vb} ${vb}`} fill={fill}
      stroke={fill === 'none' ? 'currentColor' : 'none'} strokeWidth={sw}
      strokeLinecap="round" strokeLinejoin="round" style={{ display: 'block' }}>
      {d ? <path d={d} /> : children}
    </svg>
  );
};

const Icon = {
  note: (p) => <I {...p} fill="currentColor" vb={24} d="M9 18V5l11-2v13M9 18a3 3 0 1 1-6 0 3 3 0 0 1 6 0Zm11-2a3 3 0 1 1-6 0 3 3 0 0 1 6 0Z" />,
  person: (p) => <I {...p}><circle cx="12" cy="8" r="4" /><path d="M5 20c0-3.5 3-6 7-6s7 2.5 7 6" /></I>,
  albums: (p) => <I {...p}><rect x="3" y="3" width="18" height="18" rx="3" /><circle cx="12" cy="12" r="4" /><circle cx="12" cy="12" r="0.6" fill="currentColor" /></I>,
  genre: (p) => <I {...p}><path d="M9 18V6l10-2v12" /><circle cx="6.5" cy="18" r="2.5" /><circle cx="16.5" cy="16" r="2.5" /></I>,
  list: (p) => <I {...p}><path d="M8 6h12M8 12h12M8 18h12M3.5 6h.01M3.5 12h.01M3.5 18h.01" /></I>,
  playlist: (p) => <I {...p}><path d="M4 7h11M4 12h11M4 17h7M17 17V9l4-1" /><circle cx="16" cy="18" r="2" /></I>,
  heart: (p) => <I {...p} fill="currentColor" sw={0} d="M12 21s-7-4.5-9.5-9C1 8.5 2.5 5 6 5c2 0 3.2 1.2 4 2.3C10.8 6.2 12 5 14 5c3.5 0 5 3.5 3.5 7-2.5 4.5-9.5 9-9.5 9Z" />,
  heartline: (p) => <I {...p} d="M12 20s-6.5-4.2-9-8.2C1.2 8.7 2.6 5.5 6 5.5c2 0 3.2 1.3 4 2.5.8-1.2 2-2.5 4-2.5 3.4 0 4.8 3.2 3 6.3-2.5 4-9 8.2-9 8.2Z" />,
  search: (p) => <I {...p}><circle cx="11" cy="11" r="7" /><path d="m20 20-3.2-3.2" /></I>,
  sidebar: (p) => <I {...p}><rect x="3" y="4" width="18" height="16" rx="2.5" /><path d="M9 4v16" /></I>,
  inspector: (p) => <I {...p}><rect x="3" y="4" width="18" height="16" rx="2.5" /><path d="M15 4v16" /></I>,
  grid: (p) => <I {...p}><rect x="3.5" y="3.5" width="7" height="7" rx="1.5" /><rect x="13.5" y="3.5" width="7" height="7" rx="1.5" /><rect x="3.5" y="13.5" width="7" height="7" rx="1.5" /><rect x="13.5" y="13.5" width="7" height="7" rx="1.5" /></I>,
  rows: (p) => <I {...p}><path d="M4 7h16M4 12h16M4 17h16" /></I>,
  play: (p) => <I {...p} fill="currentColor" sw={0} d="M7 5.5v13c0 .8.9 1.3 1.6.8l10-6.5c.6-.4.6-1.3 0-1.6l-10-6.5C7.9 4.2 7 4.7 7 5.5Z" />,
  pause: (p) => <I {...p} fill="currentColor" sw={0}><rect x="6" y="5" width="4" height="14" rx="1.2" /><rect x="14" y="5" width="4" height="14" rx="1.2" /></I>,
  back: (p) => <I {...p} fill="currentColor" sw={0} d="M6 5v14a1 1 0 0 0 2 0v-5l8.4 5.6c.7.5 1.6 0 1.6-.8V5.2c0-.8-.9-1.3-1.6-.8L8 10V5a1 1 0 0 0-2 0Z" />,
  fwd: (p) => <I {...p} fill="currentColor" sw={0} d="M18 5v14a1 1 0 0 1-2 0v-5l-8.4 5.6c-.7.5-1.6 0-1.6-.8V5.2c0-.8.9-1.3 1.6-.8L16 10V5a1 1 0 0 1 2 0Z" />,
  shuffle: (p) => <I {...p}><path d="M3 6h3.5c1.5 0 2.5.8 3.5 2l4 6c1 1.2 2 2 3.5 2H21M3 18h3.5c1.5 0 2.5-.8 3.5-2M15 6h3.5c1.2 0 1.8.4 2.5 1M15 18h3.5c1.2 0 1.8-.4 2.5-1" /><path d="M18.5 3.5 21 6l-2.5 2.5M18.5 15.5 21 18l-2.5 2.5" /></I>,
  repeat: (p) => <I {...p}><path d="M17 3l3 3-3 3" /><path d="M20 6H8a4 4 0 0 0-4 4v1" /><path d="M7 21l-3-3 3-3" /><path d="M4 18h12a4 4 0 0 0 4-4v-1" /></I>,
  vol: (p) => <I {...p}><path d="M11 5 6 9H3v6h3l5 4V5Z" /><path d="M15.5 8.5a5 5 0 0 1 0 7M18.5 6a8.5 8.5 0 0 1 0 12" /></I>,
  queue: (p) => <I {...p}><path d="M4 7h16M4 12h10M4 17h10" /><path d="M18 17V11l3-1" /><circle cx="17" cy="17.5" r="1.6" /></I>,
  airplay: (p) => <I {...p}><path d="M5 17H4a1 1 0 0 1-1-1V6a1 1 0 0 1 1-1h16a1 1 0 0 1 1 1v10a1 1 0 0 1-1 1h-1" /><path d="M12 14l4 5H8l4-5Z" /></I>,
  plus: (p) => <I {...p}><path d="M12 5v14M5 12h14" /></I>,
  chevL: (p) => <I {...p}><path d="M15 5l-7 7 7 7" /></I>,
  chevR: (p) => <I {...p}><path d="M9 5l7 7-7 7" /></I>,
  chevDown: (p) => <I {...p} sw={1.8}><path d="M5 9l7 7 7-7" /></I>,
  x: (p) => <I {...p}><path d="M6 6l12 12M18 6 6 18" /></I>,
  info: (p) => <I {...p}><circle cx="12" cy="12" r="9" /><path d="M12 11v5M12 8h.01" /></I>,
  more: (p) => <I {...p} fill="currentColor" sw={0}><circle cx="5" cy="12" r="1.7" /><circle cx="12" cy="12" r="1.7" /><circle cx="19" cy="12" r="1.7" /></I>,
  kebab: (p) => <I {...p} fill="currentColor" sw={0}><circle cx="12" cy="5" r="1.7" /><circle cx="12" cy="12" r="1.7" /><circle cx="12" cy="19" r="1.7" /></I>,
  pencil: (p) => <I {...p}><path d="M4 20h4L18.5 9.5a2 2 0 0 0 0-2.8l-1.2-1.2a2 2 0 0 0-2.8 0L4 16v4Z" /><path d="M13 6l3 3" /></I>,
  sort: (p) => <I {...p} size={11}><path d="M12 5v14M7 14l5 5 5-5" /></I>,
  folder: (p) => <I {...p}><path d="M3 7a2 2 0 0 1 2-2h4l2 2h8a2 2 0 0 1 2 2v8a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V7Z" /></I>,
  wave: (p) => <I {...p}><path d="M3 12h2l1.5-5 2.5 14 3-19 2.5 13L20 8h1" /></I>,
  check: (p) => <I {...p} sw={1.8}><path d="M5 12.5l4.5 4.5L19 6.5" /></I>,
  warn: (p) => <I {...p}><path d="M12 9v4M12 17h.01" /><path d="M10.3 3.9 2.4 18a2 2 0 0 0 1.7 3h15.8a2 2 0 0 0 1.7-3L13.7 3.9a2 2 0 0 0-3.4 0Z" /></I>,
  warnFill: (p) => <I {...p} fill="currentColor" sw={0}><path d="M10.3 3.2 1.6 18.5A2 2 0 0 0 3.3 21.5h17.4a2 2 0 0 0 1.7-3L13.7 3.2a2 2 0 0 0-3.4 0Z" /><path d="M12 8.5v5.2" stroke="#fff" strokeWidth="1.8" /><circle cx="12" cy="17" r="1.1" fill="#fff" /></I>,
  unlink: (p) => <I {...p}><path d="M9 17H7A5 5 0 0 1 7 7h2M15 7h2a5 5 0 0 1 4 8M8 12h3M2 2l20 20" /></I>,
  gear: (p) => <I {...p}><circle cx="12" cy="12" r="3.2" /><path d="M12 2v3M12 19v3M4.2 4.2l2.1 2.1M17.7 17.7l2.1 2.1M2 12h3M19 12h3M4.2 19.8l2.1-2.1M17.7 6.3l2.1-2.1" /></I>,
  folderOpen: (p) => <I {...p}><path d="M3 7a2 2 0 0 1 2-2h4l2 2h8a2 2 0 0 1 2 2v1H3V7Z" /><path d="M3 10h19l-2.3 8a2 2 0 0 1-1.9 1.5H5a2 2 0 0 1-2-2V10Z" /></I>,
  sliders: (p) => <I {...p}><path d="M4 21v-7M4 10V3M12 21v-9M12 8V3M20 21v-5M20 12V3M1 14h6M9 8h6M17 16h6" /></I>,
  download: (p) => <I {...p}><path d="M12 3v12M7 11l5 4 5-4M5 21h14" /></I>,
};

/* ============================================================
   COVER ART — deterministic, muted, geometric
   ============================================================ */
const PALETTES = [
  ['#2b3a55', '#5b7b9a'], ['#7a4a3a', '#c98a5e'], ['#3b4a3f', '#7fa07a'],
  ['#4a3b56', '#9a7fb0'], ['#52404a', '#b08a93'], ['#2f4858', '#86b3c4'],
  ['#5a4a2a', '#c2a878'], ['#3a3f52', '#8a90b0'], ['#503838', '#b88a72'],
  ['#2d4a45', '#79b0a4'], ['#454535', '#a8a06a'], ['#3e3550', '#8e7ab0'],
];

function Cover({ id = 0, label, size, radius, className = '', style = {} }) {
  const [a, b] = PALETTES[id % PALETTES.length];
  const motif = id % 6;
  const layers = [];
  if (motif === 0) {
    layers.push(<div key="g" style={{ position: 'absolute', inset: 0, background: `radial-gradient(120% 120% at 25% 15%, ${b}, ${a})` }} />);
    layers.push(<div key="c" style={{ position: 'absolute', left: '50%', top: '50%', width: '46%', height: '46%', transform: 'translate(-50%,-50%)', borderRadius: '50%', border: '2.5px solid rgba(255,255,255,.18)' }} />);
  } else if (motif === 1) {
    layers.push(<div key="g" style={{ position: 'absolute', inset: 0, background: `linear-gradient(135deg, ${a}, ${b})` }} />);
    layers.push(<div key="b" style={{ position: 'absolute', inset: 0, background: 'repeating-linear-gradient(90deg, transparent 0 14%, rgba(255,255,255,.07) 14% 16%)' }} />);
  } else if (motif === 2) {
    layers.push(<div key="g" style={{ position: 'absolute', inset: 0, background: a }} />);
    layers.push(<div key="c" style={{ position: 'absolute', right: '-18%', bottom: '-18%', width: '78%', height: '78%', borderRadius: '50%', background: `radial-gradient(circle at 30% 30%, ${b}, transparent 70%)` }} />);
    layers.push(<div key="c2" style={{ position: 'absolute', left: '14%', top: '16%', width: '24%', height: '24%', borderRadius: '50%', background: b, opacity: .8 }} />);
  } else if (motif === 3) {
    layers.push(<div key="g" style={{ position: 'absolute', inset: 0, background: `linear-gradient(180deg, ${b} 0%, ${a} 100%)` }} />);
    layers.push(<div key="t" style={{ position: 'absolute', left: 0, right: 0, bottom: 0, height: '50%', background: a, clipPath: 'polygon(0 60%, 35% 10%, 62% 55%, 100% 5%, 100% 100%, 0 100%)', opacity: .55 }} />);
  } else if (motif === 4) {
    layers.push(<div key="g" style={{ position: 'absolute', inset: 0, background: a }} />);
    layers.push(<div key="d" style={{ position: 'absolute', inset: 0, background: `radial-gradient(rgba(255,255,255,.16) 1.4px, transparent 1.6px)`, backgroundSize: '13% 13%' }} />);
    layers.push(<div key="b" style={{ position: 'absolute', left: '18%', top: '30%', width: '64%', height: '12%', borderRadius: 99, background: b }} />);
  } else {
    layers.push(<div key="g" style={{ position: 'absolute', inset: 0, background: `conic-gradient(from 210deg at 70% 30%, ${a}, ${b}, ${a})` }} />);
    layers.push(<div key="s" style={{ position: 'absolute', left: '20%', top: '22%', width: '40%', height: '40%', background: 'rgba(255,255,255,.12)', transform: 'rotate(12deg)', borderRadius: 6 }} />);
  }
  const s = { ...style };
  if (size != null) { s.width = size; s.height = size; }
  if (radius != null) s.borderRadius = radius;
  return (
    <div className={`cover ${className}`} style={s}>
      {layers}
      {label && <div className="ttl" style={{ fontSize: 'clamp(11px, 14%, 26px)' }}>{label}</div>}
    </div>
  );
}

/* ============================================================
   SIDEBAR
   ============================================================ */
const LIBRARY = [
  { id: 'songs', name: 'Songs', icon: 'note', cnt: '8,214' },
  { id: 'artists', name: 'Artists', icon: 'person', cnt: '412' },
  { id: 'albums', name: 'Albums', icon: 'albums', cnt: '736' },
  { id: 'genres', name: 'Genres', icon: 'genre', cnt: '24' },
];
const PLAYLISTS = [
  { id: 'p1', name: 'Late Night Drive' },
  { id: 'p2', name: 'Hi-Res Showcase' },
  { id: 'p3', name: 'Sunday Mornings' },
  { id: 'p4', name: 'Focus / Deep Work' },
  { id: 'p5', name: '90s Alternative' },
];

function Sidebar({ sel }) {
  return (
    <nav className="sidebar">
      <div className="side-head" style={{ paddingTop: 8 }}>Library</div>
      {LIBRARY.map((it) => {
        const Ic = Icon[it.icon];
        const on = sel === it.id;
        return (
          <div key={it.id} className={`side-item ${on ? 'sel' : ''}`}>
            <span className="ic"><Ic size={16} /></span>
            <span className="label">{it.name}</span>
            <span className="cnt">{it.cnt}</span>
          </div>
        );
      })}
      <div className="side-head">
        Playlists
        <span className="add"><Icon.plus size={13} /></span>
      </div>
      {PLAYLISTS.map((p) => {
        const on = sel === p.id;
        return (
          <div key={p.id} className={`side-item ${on ? 'sel' : ''}`}>
            <span className="ic pl-ic"><Icon.playlist size={16} /></span>
            <span className="label">{p.name}</span>
          </div>
        );
      })}
    </nav>
  );
}

/* ============================================================
   TITLE BAR
   ============================================================ */
function TitleBar({ title, count, right, searchFocused }) {
  return (
    <div className="titlebar">
      <div className="tb-left">
        <div className="traffic"><i className="r" /><i className="y" /><i className="g" /></div>
        <span className="tb-btn" style={{ marginLeft: 4 }}><Icon.sidebar size={17} /></span>
      </div>
      <div className="tb-right">
        <span className="tb-btn off"><Icon.chevL size={18} /></span>
        <span className="tb-btn"><Icon.chevR size={18} /></span>
        <div style={{ marginLeft: 6, display: 'flex', alignItems: 'baseline', gap: 1 }}>
          <span className="tb-title">{title}</span>
          {count && <span className="tb-count">· {count}</span>}
        </div>
        <span className="spacer" />
        {right}
        <div className={`search ${searchFocused ? 'on' : ''}`}>
          <Icon.search size={14} />
          <span>{searchFocused ? 'midnight' : 'Search'}</span>
          {searchFocused && <span style={{ width: 1, height: 13, background: 'var(--accent-9)', marginLeft: -2 }} />}
        </div>
        <span className="tb-btn"><Icon.inspector size={17} /></span>
      </div>
    </div>
  );
}

/* ============================================================
   PLAYER FOOTER
   ============================================================ */
function Player({ track }) {
  const t = track || { title: 'Neon Hours', artist: 'Midnight Arcade', cover: 7, cur: '1:42', dur: '3:58', pct: 43 };
  return (
    <div className="player">
      <div className="pl-now">
        <div className="tt">
          <div className="t1">{t.title}</div>
          <div className="t2">{t.artist} — {t.album || 'Parallel Lines'}</div>
        </div>
      </div>
      <div className="pl-center">
        <div className="pl-ctrls">
          <span className="c sm"><Icon.shuffle size={16} /></span>
          <span className="c"><Icon.back size={19} /></span>
          <span className="pl-play"><Icon.pause size={16} /></span>
          <span className="c"><Icon.fwd size={19} /></span>
          <span className="c sm act"><Icon.repeat size={16} /></span>
        </div>
        <div className="pl-scrub">
          <span className="tnum r">{t.cur}</span>
          <div className="track">
            <div className="fill" style={{ width: `${t.pct}%` }} />
            <div className="knob" style={{ left: `${t.pct}%` }} />
          </div>
          <span className="tnum">{t.dur}</span>
        </div>
      </div>
      <div className="pl-right">
        <span className="c">
          {t.q
            ? <span className="qbadge"><span className={`dot ${t.q.dot}`} /><span className="fmt" style={{ color: `var(--${t.q.fg})` }}>{t.q.label}</span></span>
            : <span className="qbadge"><span className="dot hires-dot" /><span className="fmt" style={{ color: 'var(--gold-11)' }}>FLAC 96/24</span></span>}
        </span>
        <span className="c"><Icon.queue size={17} /></span>
        <span className="c"><Icon.airplay size={17} /></span>
        <div className="pl-vol">
          <Icon.vol size={16} />
          <div className="track"><div className="fill" style={{ width: '68%' }} /><div className="knob" style={{ left: '68%' }} /></div>
        </div>
      </div>
    </div>
  );
}

/* ============================================================
   WINDOW WRAPPER
   ============================================================ */
function Win({ sel, title, count, toolbarRight, searchFocused, children, inspector, player, modal, overlay }) {
  return (
    <div className={`win radix-themes ${modal ? 'has-modal-drawer' : ''}`} data-radius="medium">
      <TitleBar title={title} count={count} right={toolbarRight} searchFocused={searchFocused} />
      <div className="body">
        <Sidebar sel={sel} />
        <div className="content">{children}</div>
        {modal && <div className="drawer-scrim" />}
        {inspector}
      </div>
      <Player track={player} />
      {overlay}
    </div>
  );
}

Object.assign(window, { Icon, Cover, Sidebar, TitleBar, Player, Win, LIBRARY, PLAYLISTS });
