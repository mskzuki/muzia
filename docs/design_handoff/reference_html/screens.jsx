/* muzy — screen content for each artboard */

/* ---------- sample library (fictional, rock / pop) ---------- */
const Q = {
  hires:    (r) => ({ cls: 'hires-dot',    fmt: 'FLAC', rate: r || '96/24',  tier: 'hires' }),
  hires2:   (r) => ({ cls: 'hires-dot',    fmt: 'ALAC', rate: r || '192/24', tier: 'hires' }),
  lossless: (r) => ({ cls: 'lossless-dot', fmt: 'FLAC', rate: r || '44.1/16',tier: 'lossless' }),
  alac:     (r) => ({ cls: 'lossless-dot', fmt: 'ALAC', rate: r || '48/24',  tier: 'lossless' }),
  aac:      (r) => ({ cls: 'lossy-dot',    fmt: 'AAC',  rate: r || '256',    tier: 'lossy' }),
  mp3:      (r) => ({ cls: 'lossy-dot',    fmt: 'MP3',  rate: r || '320',    tier: 'lossy' }),
};

const SONGS = [
  { n: 1, t: 'Neon Hours', a: 'Midnight Arcade', al: 'Parallel Lines', cv: 7, time: '3:58', q: Q.hires(), fav: true, playing: true },
  { n: 2, t: 'Coastlines', a: 'Hollow Coast', al: 'Tidewater', cv: 5, time: '4:21', q: Q.lossless() },
  { n: 3, t: 'Paper Crowns', a: 'The Velvet Hours', al: 'Slow Burn', cv: 2, time: '3:12', q: Q.hires2('192/24'), fav: true },
  { n: 4, t: 'Static Bloom', a: 'Cascade Theory', al: 'Half-Light', cv: 9, time: '5:03', q: Q.aac() },
  { n: 5, t: 'Golden Static', a: 'Midnight Arcade', al: 'Parallel Lines', cv: 7, time: '3:44', q: Q.hires() },
  { n: 6, t: 'Riverbed', a: 'Anna Reyes', al: 'Northbound', cv: 11, time: '4:08', q: Q.lossless('44.1/16') },
  { n: 7, t: 'Lantern', a: 'Hollow Coast', al: 'Tidewater', cv: 5, time: '3:51', q: Q.lossless() },
  { n: 8, t: 'Afterglow', a: 'The Velvet Hours', al: 'Slow Burn', cv: 2, time: '4:37', q: Q.hires2('192/24'), fav: true },
  { n: 9, t: 'Marble Sky', a: 'Forrest & Vale', al: 'Open Fields', cv: 3, time: '2:58', q: Q.mp3() },
  { n: 10, t: 'Undertow', a: 'Cascade Theory', al: 'Half-Light', cv: 9, time: '6:14', q: Q.hires('88.2/24') },
  { n: 11, t: 'Citylights', a: 'Anna Reyes', al: 'Northbound', cv: 11, time: '3:29', q: Q.lossless('44.1/16'), fav: true },
  { n: 12, t: 'Slow Motion', a: 'The Paper Tigers', al: 'Loud Quiet Loud', cv: 0, time: '3:47', q: Q.aac() },
  { n: 13, t: 'Hollow Bones', a: 'Forrest & Vale', al: 'Open Fields', cv: 3, time: '4:55', q: Q.alac('48/24') },
  { n: 14, t: 'Ember', a: 'Midnight Arcade', al: 'Parallel Lines', cv: 7, time: '3:33', q: Q.hires() },
  { n: 15, t: 'Glasshouse', a: 'The Paper Tigers', al: 'Loud Quiet Loud', cv: 0, time: '4:02', q: Q.lossless() },
  { n: 16, t: 'Northern Line', a: 'Anna Reyes', al: 'Northbound', cv: 11, time: '5:18', q: Q.hires2('192/24') },
];

const ALBUMS = [
  { t: 'Parallel Lines', a: 'Midnight Arcade', cv: 7, year: '2024', tier: 'hires' },
  { t: 'Tidewater', a: 'Hollow Coast', cv: 5, year: '2023', tier: 'lossless' },
  { t: 'Slow Burn', a: 'The Velvet Hours', cv: 2, year: '2024', tier: 'hires' },
  { t: 'Half-Light', a: 'Cascade Theory', cv: 9, year: '2022', tier: 'lossy' },
  { t: 'Northbound', a: 'Anna Reyes', cv: 11, year: '2023', tier: 'lossless' },
  { t: 'Open Fields', a: 'Forrest & Vale', cv: 3, year: '2021', tier: 'lossy' },
  { t: 'Loud Quiet Loud', a: 'The Paper Tigers', cv: 0, year: '2024', tier: 'lossless' },
  { t: 'Wilder Shores', a: 'Hollow Coast', cv: 4, year: '2025', tier: 'hires' },
  { t: 'Small Hours', a: 'Midnight Arcade', cv: 6, year: '2021', tier: 'lossless' },
  { t: 'Driftwood', a: 'Anna Reyes', cv: 10, year: '2020', tier: 'lossy' },
];

const ARTISTS = [
  { n: 'Midnight Arcade', albums: 3, songs: 41, cv: 7, g: 'Synth-pop' },
  { n: 'Anna Reyes', albums: 3, songs: 38, cv: 11, g: 'Indie Folk' },
  { n: 'Hollow Coast', albums: 4, songs: 52, cv: 5, g: 'Dream Pop' },
  { n: 'The Velvet Hours', albums: 2, songs: 24, cv: 2, g: 'Art Rock' },
  { n: 'Cascade Theory', albums: 2, songs: 19, cv: 9, g: 'Post-Rock' },
  { n: 'Forrest & Vale', albums: 5, songs: 61, cv: 3, g: 'Folk' },
  { n: 'The Paper Tigers', albums: 3, songs: 33, cv: 0, g: 'Alt Rock' },
];

/* ---------- helpers ---------- */
function QualityCell({ q, pill }) {
  return (
    <span className="qbadge">
      <span className={`dot ${q.cls}`} />
      <span className="fmt">{q.fmt}</span>
      <span className="rate">{q.rate} kHz</span>
      {pill && q.tier === 'hires' && <span className="hires-pill" style={{ marginLeft: 2 }}>Hi-Res</span>}
    </span>
  );
}

function TierBadge({ tier }) {
  if (tier === 'hires') return <span className="hires-pill">Hi-Res</span>;
  if (tier === 'lossless') return <span className="qbadge"><span className="dot lossless-dot" /><span className="rate" style={{ fontSize: 10.5 }}>Lossless</span></span>;
  return null;
}

/* ============================================================
   SONGS  (table)
   ============================================================ */
function SongsScreen() {
  return (
    <Win sel="songs" title="Songs" count="8,214 songs · 61.4 GB" searchFocused
      toolbarRight={<span className="tb-btn" style={{ color: 'var(--accent-11)' }}><Icon.more size={17} /></span>}>
      <div className="scroll">
        <table className="tbl">
          <thead>
            <tr>
              <th className="num">#</th>
              <th className="so">Title <Icon.sort /></th>
              <th>Artist</th>
              <th>Album</th>
              <th className="heart"></th>
              <th className="qual">Quality</th>
              <th className="time">Time</th>
            </tr>
          </thead>
          <tbody>
            {SONGS.map((s, i) => (
              <tr key={i} className={`${i === 4 ? 'sel' : ''} ${s.playing ? 'playing' : ''}`}>
                <td className="num">
                  {s.playing ? <span className="eq"><i /><i /><i /></span> : s.n}
                </td>
                <td className="title cell-art">
                  <span style={{ overflow: 'hidden', textOverflow: 'ellipsis' }}>{s.t}</span>
                </td>
                <td className="sub">{s.a}</td>
                <td className="sub">{s.al}</td>
                <td className="heart">{s.fav && <span className="hb"><Icon.heart size={13} /></span>}</td>
                <td className="qual"><QualityCell q={s.q} pill /></td>
                <td className="time sub">{s.time}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </Win>
  );
}

/* ============================================================
   ALBUMS  (grid)
   ============================================================ */
function AlbumsScreen() {
  return (
    <Win sel="albums" title="Albums" count="736 albums"
      toolbarRight={
        <div className="seg" style={{ marginRight: 4 }}>
          <span className="s on"><Icon.grid size={15} /></span>
          <span className="s"><Icon.rows size={15} /></span>
        </div>
      }>
      <div className="content-head">
        <div>
          <h1>Albums</h1>
          <div className="sub">736 albums · sorted by Recently Added</div>
        </div>
        <span className="spacer" />
        <span className="btn soft"><Icon.sort size={13} />Sort</span>
      </div>
      <div className="scroll">
        <div className="albgrid">
          {ALBUMS.map((al, i) => (
            <div key={i} className="albcard">
              <Cover id={al.cv} label={al.t} />
              <div>
                <div className="an">{al.t}</div>
                <div className="aa">{al.a}</div>
              </div>
              <div className="ab-foot">
                <span className="aa" style={{ fontSize: 11, color: 'var(--fg-tertiary)' }}>{al.year}</span>
                <span className="spacer" />
                <TierBadge tier={al.tier} />
              </div>
            </div>
          ))}
        </div>
      </div>
    </Win>
  );
}

/* ============================================================
   ARTISTS  (master list + album detail)
   ============================================================ */
const ALBUM_DETAILS = [
  {
    title: 'Parallel Lines', artist: 'Midnight Arcade', cv: 7,
    year: '2024', songs: 11, dur: '44 min', tier: 'hires',
    tracks: [
      { t: 'Neon Hours',        time: '3:58', playing: true },
      { t: 'Coast to Coast',    time: '4:12' },
      { t: 'Golden Static',     time: '3:44' },
      { t: 'Parallel',          time: '4:30' },
      { t: 'Ember',             time: '3:33' },
      { t: 'Half Awake',        time: '3:51' },
      { t: 'Telephone Lines',   time: '4:07' },
      { t: 'Slow Motion Light', time: '5:02' },
      { t: 'Cinder',            time: '3:19' },
      { t: 'Paper Avenue',      time: '3:48' },
      { t: 'Afterglow',         time: '4:21' },
    ],
  },
  {
    title: 'Small Hours', artist: 'Midnight Arcade', cv: 6,
    year: '2021', songs: 10, dur: '39 min', tier: 'lossless',
    tracks: [
      { t: 'Carousel',      time: '5:08' },
      { t: 'Long Way Down', time: '4:12' },
      { t: 'Static Bloom',  time: '3:36' },
      { t: 'Held Light',    time: '4:02' },
      { t: 'Nightswim',     time: '3:47' },
      { t: 'Low Tide',      time: '4:25' },
      { t: 'Quiet Engine',  time: '3:14' },
      { t: 'Reflection',    time: '3:58' },
      { t: 'Small Hours',   time: '4:33' },
      { t: 'Closing Doors', time: '2:51' },
    ],
  },
  {
    title: 'Dust & Gold', artist: 'Midnight Arcade', cv: 8,
    year: '2019', songs: 9, dur: '36 min', tier: 'hires',
    tracks: [
      { t: 'Marigold',     time: '4:02' },
      { t: 'Slow Tide',    time: '3:47' },
      { t: 'Afterimage',   time: '5:21' },
      { t: 'Gold Static',  time: '3:29' },
      { t: 'Embers Low',   time: '4:14' },
      { t: 'Driftwood',    time: '3:55' },
      { t: 'Hollow Coast', time: '4:38' },
      { t: 'Dust',         time: '3:02' },
      { t: 'Goldlight',    time: '4:11' },
    ],
  },
];

function AlbumDetail({ ab }) {
  return (
    <div className="ad-album">
      <div className="ad-hero">
        <Cover id={ab.cv} className="ad-cover" />
        <div className="ad-info">
          <div className="kick">Album</div>
          <h1>{ab.title}</h1>
          <div className="ad-artist">{ab.artist}</div>
          <div className="ad-meta">
            <span>{ab.year}</span><span>·</span>
            <span>{ab.songs} songs</span><span>·</span>
            <span>{ab.dur}</span>
            <TierBadge tier={ab.tier} />
          </div>
          <div className="ad-acts">
            <span className="btn solid"><Icon.play size={15} />Play</span>
            <span className="btn soft"><Icon.shuffle size={15} />Shuffle</span>
          </div>
        </div>
      </div>
      <div className="ad-tracks">
        <div className="ad-thead">
          <span className="h-num">#</span>
          <span>Title</span>
          <span className="h-time">Time</span>
        </div>
        {ab.tracks.map((s, i) => (
          <div key={i} className={`ad-trk ${s.playing ? 'playing' : ''}`}>
            <span className="tn">{i + 1}</span>
            <span className="tt">{s.t}</span>
            <span className="tm">{s.time}</span>
          </div>
        ))}
      </div>
    </div>
  );
}

function ArtistsScreen() {
  return (
    <Win sel="artists" title="Artists" count="412 artists"
      toolbarRight={
        <div className="seg" style={{ marginRight: 4 }}>
          <span className="s on"><Icon.rows size={15} /></span>
          <span className="s"><Icon.grid size={15} /></span>
        </div>
      }>
      <div className="artists-split">
        {/* master — artist list */}
        <div className="artist-master">
          <div className="am-head"><h1>Artists</h1></div>
          <div className="am-subhead">
            <span className="cnt">412 Artists</span>
            <span className="sortbtn"><Icon.sort size={12} />Recently Added</span>
          </div>
          <div className="am-list">
            {ARTISTS.map((ar, i) => (
              <div key={i} className={`am-row ${i === 0 ? 'sel' : ''}`}>
                <Cover id={ar.cv} className="avatar" />
                <div style={{ minWidth: 0 }}>
                  <div className="nm">{ar.n}</div>
                  <div className="g">{ar.g}</div>
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* detail — albums (scrolls) */}
        <div className="artist-stage">
          {ALBUM_DETAILS.map((ab, i) => (
            <AlbumDetail key={i} ab={ab} />
          ))}
        </div>
      </div>
    </Win>
  );
}

/* ============================================================
   PLAYLIST  (hero + tracks)
   ============================================================ */
function PlaylistScreen() {
  const tracks = SONGS.filter((s) => s.q.tier === 'hires').concat(SONGS.slice(2, 6));
  return (
    <Win sel="p2" title="Hi-Res Showcase">
      <div className="scroll">
        <div className="pl-hero">
          <Cover id={3} className="cover" />
          <div>
            <div className="kick">Playlist</div>
            <h1>Hi-Res Showcase</h1>
            <div className="desc">Studio masters at 24-bit and above — the records worth the disk space. Updated whenever something lossless lands in the library.</div>
            <div className="stat">28 songs · 2 hr 14 min · 6.8 GB</div>
            <div className="pl-actions">
              <span className="btn solid lg"><Icon.play size={15} />Play</span>
              <span className="btn soft lg"><Icon.shuffle size={15} />Shuffle</span>
              <span className="btn soft lg icon"><Icon.more size={17} /></span>
            </div>
          </div>
        </div>
        <table className="tbl">
          <thead>
            <tr>
              <th className="num">#</th>
              <th>Title</th>
              <th>Album</th>
              <th className="qual">Quality</th>
              <th className="time">Time</th>
            </tr>
          </thead>
          <tbody>
            {tracks.map((s, i) => (
              <tr key={i} className={i === 0 ? 'playing' : ''}>
                <td className="num">{i === 0 ? <span className="eq"><i /><i /><i /></span> : i + 1}</td>
                <td className="title cell-art">
                  <span>{s.t}</span>
                  <span className="sub" style={{ fontWeight: 400 }}>— {s.a}</span>
                </td>
                <td className="sub">{s.al}</td>
                <td className="qual"><QualityCell q={s.q} pill /></td>
                <td className="time sub">{s.time}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </Win>
  );
}

/* ============================================================
   EMPTY / FIRST-RUN
   ============================================================ */
function EmptyScreen() {
  return (
    <Win sel="songs" title="Songs" count="">
      <div className="empty">
        <div className="glyph"><Icon.note size={44} /></div>
        <h2>Your library is empty</h2>
        <p>Add a folder of music and muzy will scan it in place — your files never move, and tags stay in sync.</p>
        <div className="drop hot">
          <Icon.folder size={26} />
          <div style={{ fontWeight: 500 }}>Drop a music folder here</div>
          <div style={{ fontSize: 12, opacity: .8 }}>FLAC · ALAC · AAC · MP3 · WAV</div>
        </div>
        <div className="actions">
          <span className="btn solid lg"><Icon.plus size={15} />Add Folder…</span>
          <span className="btn soft lg">Import from Music.app</span>
        </div>
      </div>
    </Win>
  );
}

/* ============================================================
   IMPORT PROGRESS
   ============================================================ */
function ImportScreen() {
  return (
    <Win sel="songs" title="Songs" count="">
      <div className="import-wrap">
        <div className="import-card">
          <div className="ih">
            <div className="spin" />
            <div>
              <h3>Importing your library…</h3>
              <div className="ip">Reading tags and analyzing audio · 62%</div>
            </div>
            <span className="spacer" />
            <span className="btn soft" style={{ height: 28 }}>Pause</span>
          </div>
          <div className="bar"><div className="f" style={{ width: '62%' }} /></div>
          <div className="stats">
            <div className="stat"><div className="n">5,118</div><div className="l">Imported</div></div>
            <div className="stat"><div className="n">3,096</div><div className="l">Remaining</div></div>
            <div className="stat"><div className="n">214</div><div className="l">Hi-Res found</div></div>
            <div className="stat"><div className="n">~2 min</div><div className="l">Estimated</div></div>
          </div>
          <div className="insp-divider" />
          <div className="nowfile">
            <span className="fdot" />
            <span>/Music/Hollow Coast/Wilder Shores/04 Lantern.flac</span>
          </div>
        </div>
      </div>
    </Win>
  );
}

Object.assign(window, { SongsScreen, AlbumsScreen, ArtistsScreen, PlaylistScreen, EmptyScreen, ImportScreen,
  SONGS, ALBUMS, ARTISTS, Q, QualityCell, TierBadge });
