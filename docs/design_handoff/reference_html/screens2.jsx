/* muzy — additional screens (density pass): Genres, Artist/Album detail,
   Search results, Context menu, Multi-select, song edit dialog */

/* ---------- shared compact songs table (no inspector deps) ---------- */
function SongTable({ rows, selRange, playingIdx }) {
  return (
    <table className="tbl">
      <thead>
        <tr>
          <th className="num">#</th>
          <th>Title</th>
          <th>Artist</th>
          <th>Album</th>
          <th className="heart"></th>
          <th className="qual">Quality</th>
          <th className="time">Time</th>
        </tr>
      </thead>
      <tbody>
        {rows.map((s, i) => {
          const sel = selRange && i >= selRange[0] && i <= selRange[1];
          const playing = i === playingIdx;
          return (
            <tr key={i} className={`${sel ? 'sel' : ''} ${playing ? 'playing' : ''}`}>
              <td className="num">{playing ? <span className="eq"><i /><i /><i /></span> : s.n}</td>
              <td className="title cell-art">
                <span>{s.t}</span>
              </td>
              <td className="sub">{s.a}</td>
              <td className="sub">{s.al}</td>
              <td className="heart">{s.fav && <span className="hb"><Icon.heart size={13} /></span>}</td>
              <td className="qual"><QualityCell q={s.q} pill /></td>
              <td className="time sub">{s.time}</td>
            </tr>
          );
        })}
      </tbody>
    </table>
  );
}

/* ============================================================
   GENRES
   ============================================================ */
const GENRES = [
  { n: 'Alternative', c: '1,204 songs', cv: [5, 9, 0, 2] },
  { n: 'Synth-pop', c: '612 songs', cv: [7, 6, 4, 11] },
  { n: 'Indie Rock', c: '988 songs', cv: [2, 3, 5, 0] },
  { n: 'Electronic', c: '743 songs', cv: [9, 7, 11, 6] },
  { n: 'Folk', c: '421 songs', cv: [3, 10, 1, 8] },
  { n: 'Ambient', c: '307 songs', cv: [6, 4, 9, 7] },
  { n: 'Post-Rock', c: '256 songs', cv: [8, 5, 2, 9] },
  { n: 'Dream Pop', c: '389 songs', cv: [4, 11, 7, 6] },
  { n: 'Classic Rock', c: '1,533 songs', cv: [0, 3, 10, 5] },
];

function GenresScreen() {
  return (
    <Win sel="genres" title="Genres" count="24 genres">
      <div className="content-head"><div><h1>Genres</h1></div></div>
      <div className="scroll">
        <div className="genre-grid">
          {GENRES.map((g, i) => (
            <div key={i} className="genre-card">
              <div className="genre-mosaic">
                {g.cv.map((c, j) => <Cover key={j} id={c} />)}
                <span className="gname">{g.n}</span>
              </div>
              <span className="gc">{g.c}</span>
            </div>
          ))}
        </div>
      </div>
    </Win>
  );
}

/* ============================================================
   ARTIST DETAIL
   ============================================================ */
const ARTIST_ALBUMS = [
  { t: 'Parallel Lines', year: '2024', cv: 7, tier: 'hires' },
  { t: 'Small Hours', year: '2021', cv: 6, tier: 'lossless' },
  { t: 'Wired — EP', year: '2019', cv: 1, tier: 'lossless' },
];
const ARTIST_TOP = [
  { t: 'Neon Hours', al: 'Parallel Lines', time: '3:58' },
  { t: 'Golden Static', al: 'Parallel Lines', time: '3:44' },
  { t: 'Afterimage', al: 'Small Hours', time: '4:12' },
  { t: 'Ember', al: 'Parallel Lines', time: '3:33' },
  { t: 'Slow Signal', al: 'Small Hours', time: '5:01' },
];

function ArtistDetailScreen() {
  return (
    <Win sel="artists" title="Artists" count="412 artists"
      toolbarRight={<span className="tb-btn off"><Icon.chevL size={18} /></span>}>
      <div className="scroll">
        <div className="artist-hero">
          <Cover id={7} className="ava" />
          <div>
            <div className="kick">Artist</div>
            <h1>Midnight Arcade</h1>
            <div className="meta">3 albums · 41 songs · Synth-pop · 2 hr 38 min</div>
            <div className="acts">
              <span className="btn solid lg"><Icon.play size={15} />Play</span>
              <span className="btn soft lg"><Icon.shuffle size={15} />Shuffle</span>
              <span className="btn soft lg icon"><Icon.heartline size={17} /></span>
            </div>
          </div>
        </div>

        <div className="section-title">Albums</div>
        <div className="hrow">
          {ARTIST_ALBUMS.map((al, i) => (
            <div key={i} className="albcard">
              <Cover id={al.cv} label={al.t} />
              <div>
                <div className="an">{al.t}</div>
                <div className="ab-foot">
                  <span className="aa" style={{ fontSize: 11, color: 'var(--fg-tertiary)' }}>{al.year}</span>
                  <span className="spacer" />
                  <TierBadge tier={al.tier} />
                </div>
              </div>
            </div>
          ))}
        </div>

        <div className="section-title">Top Songs <span className="more">See all 41</span></div>
        <div className="topsongs">
          {ARTIST_TOP.map((s, i) => (
            <div key={i} className="ts-row">
              <span className="ti">{i + 1}</span>
              <div style={{ minWidth: 0 }}>
                <div className="tn">{s.t}</div>
              </div>
              <span className="tt2" style={{ color: 'var(--fg-secondary)' }}>{s.al}</span>
              <span className="tt2">{s.time}</span>
            </div>
          ))}
        </div>
      </div>
    </Win>
  );
}

/* ============================================================
   ALBUM DETAIL
   ============================================================ */
const ALBUM_TRACKS = [
  { t: 'Neon Hours', time: '3:58', fav: true },
  { t: 'Coast to Coast', time: '4:11' },
  { t: 'Golden Static', time: '3:44' },
  { t: 'Parallel', time: '4:33', fav: true },
  { t: 'Ember', time: '3:33' },
  { t: 'Half Awake', time: '5:09' },
  { t: 'Telephone Lines', time: '3:02' },
  { t: 'Slow Motion Light', time: '4:48', fav: true },
  { t: 'Ultraviolet', time: '3:27' },
  { t: 'Receiver', time: '4:55' },
  { t: 'Neon Hours (Reprise)', time: '2:42' },
];

function AlbumDetailScreen() {
  const inspector = (
    <aside className="inspector">
      <div className="insp-head">Album Info<span className="x"><Icon.x size={15} /></span></div>
      <div className="insp-body">
        <Cover id={7} className="insp-art" label="Parallel Lines" />
        <div>
          <div className="insp-title">Parallel Lines</div>
          <div className="insp-sub">Midnight Arcade</div>
        </div>
        <div className="field"><label>Album Artist</label><div className="input">Midnight Arcade</div></div>
        <div className="field-row">
          <div className="field"><label>Year</label><div className="input">2024</div></div>
          <div className="field"><label>Tracks</label><div className="input">11</div></div>
        </div>
        <div className="field"><label>Genre</label><div className="input">Synth-pop</div></div>
        <div className="insp-divider" />
        <div>
          <div className="insp-label">Album Summary</div>
          <dl className="tech-grid">
            <dt>Duration</dt><dd>44:12</dd>
            <dt>Format</dt><dd>FLAC · 96/24</dd>
            <dt>Quality</dt><dd>Hi-Res Lossless</dd>
            <dt>Total size</dt><dd>812 MB</dd>
            <dt>Added</dt><dd>Mar 14, 2024</dd>
          </dl>
        </div>
      </div>
    </aside>
  );
  return (
    <Win sel="albums" title="Albums" count="" inspector={inspector}
      toolbarRight={<span className="tb-btn" style={{ color: 'var(--accent-11)' }}><Icon.inspector size={17} /></span>}>
      <div className="scroll">
        <div className="album-hero">
          <Cover id={7} className="cover" label="Parallel Lines" />
          <div>
            <div className="kick">Album</div>
            <h1>Parallel Lines</h1>
            <div className="by">Midnight Arcade</div>
            <div className="meta">
              <span>2024</span><span>·</span><span>11 songs</span><span>·</span><span>44 min</span>
              <span className="hires-pill" style={{ marginLeft: 2 }}>Hi-Res</span>
            </div>
            <div className="acts">
              <span className="btn solid lg"><Icon.play size={15} />Play</span>
              <span className="btn soft lg"><Icon.shuffle size={15} />Shuffle</span>
            </div>
          </div>
        </div>
        <table className="tbl">
          <thead>
            <tr><th className="num">#</th><th>Title</th><th className="heart"></th><th className="time">Time</th></tr>
          </thead>
          <tbody>
            {ALBUM_TRACKS.map((s, i) => (
              <tr key={i} className={i === 0 ? 'playing' : ''}>
                <td className="num">{i === 0 ? <span className="eq"><i /><i /><i /></span> : i + 1}</td>
                <td className="title">{s.t}</td>
                <td className="heart tk-fav">{s.fav && <span className="hb"><Icon.heart size={13} /></span>}</td>
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
   SEARCH RESULTS  (incremental, contextual)
   ============================================================ */
const HL = (text) => {
  const parts = text.split(/(north)/i);
  return parts.map((p, i) => (/^north$/i.test(p) ? <mark key={i}>{p}</mark> : <span key={i}>{p}</span>));
};

function SearchScreen() {
  return (
    <Win sel="songs" title="Songs" count="" searchFocused>
      <div className="scroll">
        <div className="result-bar"><Icon.search size={13} />3 results for “north” in Songs</div>

        <div className="group-head">Albums</div>
        <div className="res-album">
          <Cover id={11} className="ac" />
          <div>
            <div className="rn">{HL('Northbound')}</div>
            <div className="rm">Anna Reyes · 2023 · 11 songs</div>
          </div>
          <span className="spacer" />
          <TierBadge tier="lossless" />
        </div>

        <div className="group-head">Songs</div>
        <table className="tbl">
          <tbody>
            <tr>
              <td className="num" style={{ width: 40 }}>1</td>
              <td className="title cell-art"><span>{HL('Northern Line')}</span></td>
              <td className="sub">Anna Reyes</td>
              <td className="sub">{HL('Northbound')}</td>
              <td className="qual"><QualityCell q={Q.hires2('192/24')} pill /></td>
              <td className="time sub" style={{ width: 56 }}>5:18</td>
            </tr>
            <tr>
              <td className="num" style={{ width: 40 }}>2</td>
              <td className="title cell-art"><span>{HL('Northern Lights')}</span></td>
              <td className="sub">Cascade Theory</td>
              <td className="sub">Half-Light</td>
              <td className="qual"><QualityCell q={Q.lossless()} pill /></td>
              <td className="time sub" style={{ width: 56 }}>6:02</td>
            </tr>
          </tbody>
        </table>
      </div>
    </Win>
  );
}

/* ============================================================
   CONTEXT MENU  (right-click on a track)
   ============================================================ */
function CtxItem({ icon, label, kbd, chev, on, danger }) {
  const Ic = icon ? Icon[icon] : null;
  return (
    <div className={`ctx-item ${on ? 'on' : ''} ${danger ? 'danger' : ''}`}>
      <span className="cil">{Ic && <Ic size={14} />}</span>
      <span>{label}</span>
      {kbd && <span className="kbd">{kbd}</span>}
      {chev && <span className="chev"><Icon.chevR size={13} /></span>}
    </div>
  );
}

function ContextMenuScreen() {
  return (
    <Win sel="songs" title="Songs" count="8,214 songs · 61.4 GB">
      <div className="scroll" style={{ position: 'relative' }}>
        <SongTable rows={SONGS} selRange={[2, 2]} playingIdx={0} />
        <div className="ctx-overlay">
          <div className="ctx-menu" style={{ top: 96, left: 360 }}>
            <CtxItem icon="play" label="曲を再生" />
            <div className="ctx-sep" />
            <CtxItem icon="pencil" label="曲を編集…" kbd="⌘I" on />
            <div className="ctx-sep" />
            <CtxItem icon="x" label="ライブラリから削除…" danger />
          </div>
        </div>
      </div>
    </Win>
  );
}

/* ============================================================
   MULTI-SELECT  (selection bar + kebab column — UIQ-5)
   ============================================================ */
function MultiSelectScreen() {
  return (
    <Win sel="songs" title="" count=""
      player={{ title: 'Static Bloom', artist: 'Cascade Theory', album: 'Half-Light', cover: 9, cur: '0:13', dur: '5:03', pct: 13, q: { dot: 'lossy-dot', fg: 'gray-11', label: 'AAC 256' } }}>
      <div className="sel-bar">
        <span className="sb-count">5 曲を選択中</span>
        <span className="spacer" />
        <span className="btn solid sb-btn"><Icon.pencil size={14} />一括編集</span>
      </div>
      <div className="scroll">
        <table className="tbl">
          <thead>
            <tr>
              <th className="num">#</th>
              <th>Title</th>
              <th>Artist</th>
              <th>Album</th>
              <th className="qual">Quality</th>
              <th className="time">Time</th>
              <th className="kebab"></th>
            </tr>
          </thead>
          <tbody>
            {SONGS.map((s, i) => {
              const sel = i >= 4 && i <= 8;
              const playing = i === 3;
              return (
                <tr key={i} className={`${sel ? 'sel' : ''} ${playing ? 'playing' : ''}`}>
                  <td className="num">{s.n}</td>
                  <td className="title">{s.t}</td>
                  <td className="sub">{s.a}</td>
                  <td className="sub">{s.al}</td>
                  <td className="qual"><QualityCell q={s.q} pill /></td>
                  <td className="time sub">{s.time}</td>
                  <td className="kebab"><span className="kb"><Icon.kebab size={16} /></span></td>
                </tr>
              );
            })}
          </tbody>
        </table>
      </div>
    </Win>
  );
}

/* ============================================================
   BULK EDIT DRAWER  (after pressing 一括編集)
   Partial single-album selection → split prediction.
   ============================================================ */
const BULK_SEL = new Set([0, 4, 13]); // 3 Parallel Lines tracks

function BulkTable() {
  return (
    <table className="tbl">
      <thead>
        <tr>
          <th className="num">#</th>
          <th>Title</th>
          <th>Artist</th>
          <th>Album</th>
          <th className="time">Time</th>
          <th className="kebab"></th>
        </tr>
      </thead>
      <tbody>
        {SONGS.map((s, i) => {
          const sel = BULK_SEL.has(i);
          const playing = i === 3;
          return (
            <tr key={i} className={`${sel ? 'sel' : ''} ${playing ? 'playing' : ''}`}>
              <td className="num">{s.n}</td>
              <td className="title">{s.t}</td>
              <td className="sub">{s.a}</td>
              <td className="sub">{s.al}</td>
              <td className="time sub">{s.time}</td>
              <td className="kebab"><span className="kb"><Icon.kebab size={16} /></span></td>
            </tr>
          );
        })}
      </tbody>
    </table>
  );
}

function AlbumDialog() {
  return (
    <div className="proto-overlay">
      <div className="album-dialog radix-themes">
        <div className="albd-head">
          <div className="albd-head-top">
            <span className="albd-title">アルバム情報の一括編集</span>
            <span className="x"><Icon.x size={15} /></span>
          </div>
          <div className="albd-scope">
            <span className="albd-chip">3 曲を選択中</span>
            <span className="albd-src">Parallel Lines</span>
          </div>
        </div>

        <div className="albd-body">
          <div className="albd-note-static">曲名とトラック番号は、重複を避けるため一括編集できません。</div>

          {/* Artist */}
          <div className="albf">
            <label className="albf-toggle"><span className="albf-label">アーティスト</span></label>
            <div className="albf-body">
              <div className="albd-input ph">Midnight Arcade</div>
            </div>
          </div>

          {/* Album name */}
          <div className="albf">
            <label className="albf-toggle"><span className="albf-label">アルバム名</span></label>
            <div className="albf-body">
              <div className="albd-input ph">Parallel Lines</div>
              <label className="albd-check">
                <span className="albf-box sm"><Icon.check size={10} /></span>
                <span>選択していない同じアルバムの曲も含めて変更する</span>
              </label>
              <div className="albf-hint" style={{ marginTop: 0 }}></div>
            </div>
          </div>

          {/* Release year */}
          <div className="albf">
            <label className="albf-toggle"><span className="albf-label">リリース年</span></label>
            <div className="albf-body">
              <div className="albd-input narrow ph">YYYY</div>
              <div className="albf-hint" style={{ marginTop: 0 }}></div>
            </div>
          </div>

          {/* Genre */}
          <div className="albf">
            <label className="albf-toggle"><span className="albf-label">ジャンル</span></label>
            <div className="albf-body">
              <div className="albd-input ph">ジャンル</div>
              <div className="albd-chips">
                {['Synth-pop', 'Alternative', 'Indie Rock', 'Electronic', 'Dream Pop'].map((g) => (
                  <span key={g} className="albd-gchip">{g}</span>
                ))}
              </div>
            </div>
          </div>
        </div>

        <div className="albd-foot">
          <span className="btn soft">キャンセル</span>
          <span className="btn solid">保存</span>
        </div>
      </div>
    </div>
  );
}

function BulkEditScreen() {
  return (
    <Win sel="songs" title="" count="" overlay={<AlbumDialog />}
      player={{ title: 'Static Bloom', artist: 'Cascade Theory', album: 'Half-Light', cover: 9, cur: '0:13', dur: '5:03', pct: 13, q: { dot: 'lossy-dot', fg: 'gray-11', label: 'AAC 256' } }}>
      <div className="sel-bar">
        <span className="sb-count">3 曲を選択中</span>
        <span className="spacer" />
        <span className="btn solid sb-btn"><Icon.pencil size={14} />一括編集</span>
      </div>
      <div className="scroll"><BulkTable /></div>
    </Win>
  );
}

function BulkConfirmScreen() {
  return (
    <Win sel="songs" title="" count=""
      player={{ title: 'Static Bloom', artist: 'Cascade Theory', album: 'Half-Light', cover: 9, cur: '0:13', dur: '5:03', pct: 13, q: { dot: 'lossy-dot', fg: 'gray-11', label: 'AAC 256' } }}
      overlay={
        <div className="proto-overlay">
          <div className="proto-dialog radix-themes">
            <h3>次の変更を適用します</h3>
            <ul className="confirm-list">
              <li>選択した 3 曲だけを「Parallel Lines (Deluxe)」へ分割します。残り 8 曲は「Parallel Lines」のままです。</li>
            </ul>
            <p className="confirm-note">ファイルには書き込まれません（編集はライブラリ内にのみ保存されます）。</p>
            <div className="pd-actions">
              <span className="btn ghost">戻る</span>
              <span className="btn solid">適用</span>
            </div>
          </div>
        </div>
      }>
      <div className="sel-bar">
        <span className="sb-count">3 曲を選択中</span>
        <span className="spacer" />
        <span className="btn solid sb-btn"><Icon.pencil size={14} />一括編集</span>
      </div>
      <div className="scroll"><BulkTable /></div>
    </Win>
  );
}

/* ============================================================
   SONG EDIT DIALOG  (右クリック → 曲を編集)
   ============================================================ */
function SongDialog() {
  return (
    <div className="proto-overlay">
      <div className="song-dialog radix-themes">
        <div className="albd-head">
          <div className="albd-head-top">
            <span className="albd-title">曲を編集</span>
            <span className="x"><Icon.x size={15} /></span>
          </div>
          <div className="songd-ident">
            <Cover id={7} className="songd-art" />
            <div style={{ minWidth: 0 }}>
              <div className="songd-name">Michael Jackson</div>
              <div className="albd-src">Black or White — Dangerous</div>
            </div>
          </div>
        </div>

        <div className="albd-body songd-body">
          <div className="songd-field">
            <label>曲名</label>
            <div className="albd-input focus">Black or White<span className="caret" /></div>
          </div>
          <div className="songd-field">
            <label>アーティスト</label>
            <div className="albd-input">Michael Jackson</div>
          </div>
          <div className="songd-field">
            <label>アルバム</label>
            <div className="albd-input">Dangerous</div>
          </div>
          <div className="songd-grid narrow">
            <div className="songd-field">
              <label>トラック</label>
              <div className="albd-input">5</div>
            </div>
            <div className="songd-field">
              <label>リリース年</label>
              <div className="albd-input">2024</div>
            </div>
          </div>
          <div className="songd-field">
            <label>ジャンル</label>
            <div className="albd-input">Black Music</div>
            <div className="albd-chips" style={{ marginTop: 8 }}>
              {['Alternative', 'Indie Rock', 'Electronic', 'Dream Pop'].map((g) => (
                <span key={g} className="albd-gchip">{g}</span>
              ))}
            </div>
          </div>
        </div>

        <div className="albd-foot">
          <span className="btn soft">キャンセル</span>
          <span className="btn solid">保存</span>
        </div>
      </div>
    </div>
  );
}

function SongEditScreen() {
  return (
    <Win sel="songs" title="Songs" count="8,214 songs · 61.4 GB" overlay={<SongDialog />}
      player={{ title: 'Static Bloom', artist: 'Cascade Theory', album: 'Half-Light', cover: 9, cur: '0:13', dur: '5:03', pct: 13, q: { dot: 'lossy-dot', fg: 'gray-11', label: 'AAC 256' } }}>
      <div className="scroll"><SongTable rows={SONGS} selRange={[4, 4]} playingIdx={3} /></div>
    </Win>
  );
}

Object.assign(window, { SongDialog, SongEditScreen, GenresScreen, ArtistDetailScreen, AlbumDetailScreen, SearchScreen, ContextMenuScreen, MultiSelectScreen, BulkEditScreen, BulkConfirmScreen });
