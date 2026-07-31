/* muzy — additional states: Missing files, Duplicate review, Data error, Preferences */

/* ============================================================
   1. MISSING / UNAVAILABLE FILES
   File path no longer resolves (moved or deleted on disk).
   Tracks stay in the library; flagged + offered re-link.
   ============================================================ */
function MissingFilesScreen() {
  return (
    <Win sel="songs" title="Songs" count="8,214 songs · 3 unavailable">
      <div className="banner">
        <span className="bic"><Icon.warn size={16} /></span>
        <span className="btx"><b>3 songs are unavailable.</b> Their files moved or were deleted since the last scan.</span>
        <span className="spacer" />
        <span className="bact">Locate…</span>
        <span className="bact">Remove</span>
        <span className="bx"><Icon.x size={13} /></span>
      </div>
      <div className="scroll">
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
            {SONGS.map((s, i) => {
              const missing = i === 3 || i === 7 || i === 12;
              return (
                <tr key={i} className={`${missing ? 'missing' : ''} ${i === 0 ? 'playing' : ''}`}>
                  <td className="num">{i === 0 ? <span className="eq"><i /><i /><i /></span> : s.n}</td>
                  <td className="title cell-art">
                    <span>{s.t}</span>
                  </td>
                  <td className="sub">{s.a}</td>
                  <td className="sub">{s.al}</td>
                  <td className="heart">{s.fav && !missing && <span className="hb"><Icon.heart size={13} /></span>}</td>
                  <td className="qual">
                    {missing
                      ? <span className="miss-flag"><span className="md" />Unavailable</span>
                      : <QualityCell q={s.q} pill />}
                  </td>
                  <td className="time sub">{missing ? '—' : s.time}</td>
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
   2. DUPLICATE REVIEW  (sheet over Import)
   Same fileHash / filePath detected during import.
   ============================================================ */
const DUPES = [
  { t: 'Neon Hours', sub: 'Midnight Arcade · FLAC 96/24', path: '~/Downloads/midnight/01 Neon Hours.flac', cv: 7, choice: 'skip' },
  { t: 'Coastlines', sub: 'Hollow Coast · ALAC 48/24', path: '~/Downloads/tidewater/coastlines.m4a', cv: 5, choice: 'keep' },
  { t: 'Afterglow', sub: 'The Velvet Hours · FLAC 192/24', path: '~/Music/dump/afterglow (1).flac', cv: 2, choice: 'skip' },
  { t: 'Riverbed', sub: 'Anna Reyes · FLAC 44.1/16', path: '~/Downloads/northbound/06 riverbed.flac', cv: 11, choice: 'skip' },
];

function DupeSeg({ choice }) {
  return (
    <div className="dseg">
      <span className={`dopt skip ${choice === 'skip' ? 'on skip' : ''}`}>Skip</span>
      <span className={`dopt keep ${choice === 'keep' ? 'on keep' : ''}`}>Import anyway</span>
    </div>
  );
}

function DuplicateScreen() {
  const sheet = (
    <div className="modal-scrim">
      <div className="sheet">
        <div className="sheet-head">
          <span className="sic"><Icon.warn size={20} /></span>
          <div>
            <h3>4 duplicates found</h3>
            <p>These files match songs already in your library (same audio fingerprint). Choose what to do with each — muzy skips duplicates by default.</p>
          </div>
        </div>
        <div className="dupe-list">
          {DUPES.map((d, i) => (
            <div key={i} className="dupe-row">
              <div style={{ minWidth: 0 }}>
                <div className="dn">{d.t}</div>
                <div className="dp">{d.path}</div>
              </div>
              <span className="dseg-wrap" style={{ marginLeft: 'auto' }}><DupeSeg choice={d.choice} /></span>
            </div>
          ))}
        </div>
        <div className="sheet-foot">
          <span className="fnote">3 to skip · 1 to import</span>
          <span className="spacer" />
          <span className="btn soft">Apply to all ▾</span>
          <span className="btn solid">Continue Import</span>
        </div>
      </div>
    </div>
  );
  return (
    <Win sel="songs" title="Songs" count="">
      <div className="import-wrap">
        <div className="import-card" style={{ opacity: .5 }}>
          <div className="ih">
            <div className="spin" />
            <div>
              <h3>Importing your library…</h3>
              <div className="ip">Paused — review needed</div>
            </div>
          </div>
          <div className="bar"><div className="f" style={{ width: '62%' }} /></div>
        </div>
      </div>
      {sheet}
    </Win>
  );
}

/* ============================================================
   3. DATA ERROR ALERT  (spec 9.3 — corruption must be surfaced)
   ============================================================ */
function ErrorAlertScreen() {
  const alert = (
    <div className="modal-scrim">
      <div className="alert">
        <div className="app-ic">
          <Icon.note size={30} fill="currentColor" />
          <span className="warn"><Icon.warn size={14} /></span>
        </div>
        <h3>muzy can't open your library</h3>
        <p>The library database appears to be damaged and couldn't be read. Your music files are untouched — rebuilding will re-scan them.</p>
        <div className="abtns">
          <span className="abtn primary">Rebuild Library…</span>
          <span className="abtn secondary">Quit</span>
          <span className="abtn link">Show in Finder</span>
        </div>
      </div>
    </div>
  );
  return (
    <Win sel="songs" title="Songs" count="">
      <div className="scroll" style={{ position: 'relative', filter: 'saturate(.6)' }}>
        <table className="tbl">
          <thead>
            <tr><th className="num">#</th><th>Title</th><th>Artist</th><th>Album</th><th className="qual">Quality</th><th className="time">Time</th></tr>
          </thead>
          <tbody>
            {SONGS.slice(0, 8).map((s, i) => (
              <tr key={i} style={{ opacity: .4 }}>
                <td className="num">{s.n}</td>
                <td className="title cell-art"><span>{s.t}</span></td>
                <td className="sub">{s.a}</td>
                <td className="sub">{s.al}</td>
                <td className="qual"><QualityCell q={s.q} /></td>
                <td className="time sub">{s.time}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
      {alert}
    </Win>
  );
}

/* ============================================================
   4. PREFERENCES WINDOW  (standalone macOS-style)
   ============================================================ */
function Toggle({ on }) { return <span className={`toggle ${on ? 'on' : ''}`}><span className="tk" /></span>; }
function Radio({ on, label }) { return <span className="radio"><span className={`rd ${on ? 'on' : ''}`} />{label}</span>; }

function PrefsScreen() {
  const tabs = [
    { id: 'general', label: 'General', icon: 'gear' },
    { id: 'library', label: 'Library', icon: 'folderOpen' },
    { id: 'playback', label: 'Playback', icon: 'sliders' },
    { id: 'import', label: 'Import', icon: 'download' },
  ];
  return (
    <div style={{ width: 1280, height: 800, display: 'flex', alignItems: 'center', justifyContent: 'center', background: '#e9e7e2' }} className="radix-themes">
      <div className="prefs-win">
        <div className="prefs-tabbar">
          <div className="pt-traffic"><i className="r" /><i className="y" /><i className="g" /></div>
          {tabs.map((t) => {
            const Ic = Icon[t.icon];
            return (
              <div key={t.id} className={`ptab ${t.id === 'library' ? 'on' : ''}`}>
                <Ic size={19} />
                <span className="pl">{t.label}</span>
              </div>
            );
          })}
        </div>
        <div className="prefs-body">
          <div className="pgroup">
            <div className="prow">
              <span className="plabel">Music folders</span>
              <div className="pctl">
                <div className="path-field">
                  <Icon.folder size={15} />
                  <span className="pf">~/Music</span>
                  <span className="pstepbtn"><Icon.x size={12} /></span>
                </div>
                <div className="path-field">
                  <Icon.folder size={15} />
                  <span className="pf">/Volumes/Audio/Hi-Res</span>
                  <span className="pstepbtn"><Icon.x size={12} /></span>
                </div>
                <span className="pstepbtn" style={{ alignSelf: 'flex-start', marginTop: 2 }}><Icon.plus size={13} />Add Folder…</span>
              </div>
            </div>
            <div className="prow toggle-row">
              <span className="plabel">Watch for changes</span>
              <div className="pctl">
                <Toggle on={true} />
                <span className="phint">Automatically scan folders and update the library when files are added or removed.</span>
              </div>
            </div>
            <div className="prow toggle-row">
              <span className="plabel">Keep files in place</span>
              <div className="pctl">
                <Toggle on={true} />
                <span className="phint">muzy never copies or moves your music — it reads files where they live.</span>
              </div>
            </div>
          </div>

          <div className="pgroup">
            <div className="prow">
              <span className="plabel">When tags change</span>
              <div className="pctl radio-row">
                <Radio on={true} label="Update the library only" />
                <Radio on={false} label="Also write tags back to files" />
              </div>
            </div>
            <div className="prow">
              <span className="plabel">Artwork</span>
              <div className="pctl">
                <span className="pselect">Embedded, then folder image<span className="pchev"><Icon.chevDown size={13} /></span></span>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}

Object.assign(window, { MissingFilesScreen, DuplicateScreen, ErrorAlertScreen, PrefsScreen });
