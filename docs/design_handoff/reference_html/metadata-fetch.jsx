/* muzy — Album Metadata Fetch (008-metadata-fetch)
   Running example: a freshly imported WAV rip of "Parallel Lines" — no tags,
   generic "Track NN.wav" names. The fetch identifies it via AcoustID →
   MusicBrainz → Cover Art Archive and proposes album-level metadata for the
   user to confirm. Nothing is written to the audio files (Pattern D). */

/* ---- local icons (SF-flavored, beyond shell.jsx's Icon set) ---- */
const MIcon = {
  fingerprint: (p = {}) => (
    <svg width={p.size || 16} height={p.size || 16} viewBox="0 0 24 24" fill="none"
      stroke="currentColor" strokeWidth="1.6" strokeLinecap="round" strokeLinejoin="round" style={{ display: 'block' }}>
      <path d="M12 11v3m0 0a8 8 0 0 1-1.4 4.5M12 14a8 8 0 0 0 1.6 4.8" />
      <path d="M8.5 12a3.5 3.5 0 0 1 7 0c0 2.5-.4 4.6-1.2 6.3" />
      <path d="M5.2 12a6.8 6.8 0 0 1 13.6 0c0 1.3-.1 2.5-.3 3.6" />
      <path d="M5.5 8.2a8 8 0 0 1 13 0" />
    </svg>
  ),
  disc: (p = {}) => (
    <svg width={p.size || 16} height={p.size || 16} viewBox="0 0 24 24" fill="none"
      stroke="currentColor" strokeWidth="1.6" strokeLinecap="round" strokeLinejoin="round" style={{ display: 'block' }}>
      <circle cx="12" cy="12" r="9" /><circle cx="12" cy="12" r="3" />
      <path d="M12 3a9 9 0 0 1 0 18" opacity=".4" />
    </svg>
  ),
  globe: (p = {}) => (
    <svg width={p.size || 16} height={p.size || 16} viewBox="0 0 24 24" fill="none"
      stroke="currentColor" strokeWidth="1.6" strokeLinecap="round" strokeLinejoin="round" style={{ display: 'block' }}>
      <circle cx="12" cy="12" r="9" /><path d="M3 12h18M12 3c2.5 2.5 2.5 15 0 18M12 3c-2.5 2.5-2.5 15 0 18" />
    </svg>
  ),
  arrowR: (p = {}) => (
    <svg width={p.size || 14} height={p.size || 14} viewBox="0 0 24 24" fill="none"
      stroke="currentColor" strokeWidth="1.7" strokeLinecap="round" strokeLinejoin="round" style={{ display: 'block' }}>
      <path d="M5 12h13M13 6l6 6-6 6" />
    </svg>
  ),
};

/* country code + name (data labels — no emoji, per design system) */
const CCODE = { GB: 'GB', US: 'US', JP: 'JP', XW: 'WW', '—': '??' };
const COUNTRY = { GB: 'イギリス', US: 'アメリカ', JP: '日本', XW: 'ワールドワイド', '—': '国不明' };

/* ---- data ---- */
const MF = {
  folder: '~/Music/Rips/Parallel Lines',
  identified: { title: 'Parallel Lines', artist: 'Midnight Arcade', year: '2024', cv: 7 },
  release: { country: 'GB', media: 'CD', year: '2024', score: 98 },
};

// original WAV file name (from the rip) → identified track name
const MF_TRACKS = [
  { n: 1,  orig: 'Track 01.wav', id: 'Neon Hours',        time: '3:58', score: 99 },
  { n: 2,  orig: 'Track 02.wav', id: 'Coast to Coast',    time: '4:12', score: 98 },
  { n: 3,  orig: 'Track 03.wav', id: 'Golden Static',     time: '3:44', score: 97 },
  { n: 4,  orig: 'Track 04.wav', id: 'Parallel',          time: '4:30', score: 99 },
  { n: 5,  orig: 'Track 05.wav', id: 'Ember',             time: '3:33', score: 96 },
  { n: 6,  orig: 'Track 06.wav', id: 'Half Awake',        time: '3:51', score: 98 },
  { n: 7,  orig: 'Track 07.wav', id: null,                time: '4:07', score: 0  },  // 該当なし
  { n: 8,  orig: 'Track 08.wav', id: 'Slow Motion Light', time: '5:02', score: 94 },
  { n: 9,  orig: 'Track 09.wav', id: 'Cinder',            time: '3:19', score: 61, low: true },  // 要確認
  { n: 10, orig: 'Track 10.wav', id: 'Paper Avenue',      time: '3:48', score: 95 },
  { n: 11, orig: 'Track 11.wav', id: 'Afterglow',         time: '4:21', score: 97 },
];

const MF_RELEASES = [
  { id: 'gb', country: 'GB', title: 'Parallel Lines',          date: '2024-03-15', media: 'CD',            tracks: 11, score: 98, def: true },
  { id: 'us', country: 'US', title: 'Parallel Lines',          date: '2024-04-02', media: 'CD',            tracks: 11, score: 95 },
  { id: 'xw', country: 'XW', title: 'Parallel Lines (Deluxe)', date: '2024-09-10', media: 'Digital Media', tracks: 14, score: 91 },
  { id: 'jp', country: 'JP', title: 'Parallel Lines',          date: '2024-05-22', media: 'CD + Blu-ray',  tracks: 12, score: 88 },
  { id: 'uk2', country: '—', title: 'Parallel Lines',          date: '日付不明',    media: 'Digital Media', tracks: 11, score: 76, unknown: true },
];

/* generic pre-fetch track names for the album-detail background */
const PRE_TRACKS = MF_TRACKS.map((t) => ({ orig: t.orig.replace('.wav', ''), time: t.time }));

/* ============================================================
   BACKGROUND — album detail before fetch (untagged WAV rip)
   ============================================================ */
function PreAlbumDetail({ dim }) {
  return (
    <div className="scroll" style={dim ? { filter: 'saturate(.7)' } : undefined}>
      <div className="pre-hero">
        <div className="cover ph"><Icon.note size={46} /></div>
        <div>
          <div className="kick">Album</div>
          <h1>Parallel Lines</h1>
          <div className="by">不明なアーティスト</div>
          <div className="meta">
            <span>11 曲</span><span>·</span><span>44 分</span><span>·</span><span>WAV · 44.1/16</span>
            <span className="untag"><Icon.warn size={11} />タグなし</span>
          </div>
          <div className="acts">
            <span className="btn solid lg"><Icon.play size={15} />Play</span>
            <span className="btn soft lg"><Icon.shuffle size={15} />Shuffle</span>
            <span className="btn fetch lg"><MIcon.fingerprint size={16} />アルバム情報を取得</span>
          </div>
        </div>
      </div>
      <div className="pre-tracks">
        <table className="tbl">
          <thead>
            <tr><th className="num">#</th><th>Title</th><th className="time">Time</th></tr>
          </thead>
          <tbody>
            {PRE_TRACKS.map((s, i) => (
              <tr key={i}>
                <td className="num">{i + 1}</td>
                <td className="title generic">{s.orig}</td>
                <td className="time sub">{s.time}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}

/* ============================================================
   1. TRIGGER — album detail with the fetch action
   ============================================================ */
function FetchTriggerScreen() {
  return (
    <Win sel="albums" title="Albums" count=""
      toolbarRight={<span className="tb-btn"><Icon.inspector size={17} /></span>}>
      <PreAlbumDetail />
    </Win>
  );
}

/* ============================================================
   2. FETCHING — serial MusicBrainz query (1 req/s)
   ============================================================ */
function FetchingScreen() {
  const steps = [
    { ic: 'wave', lbl: 'フィンガープリント', state: 'done' },
    { ic: 'fingerprint', lbl: 'AcoustID 照合', state: 'done' },
    { ic: 'disc', lbl: 'MusicBrainz 照会', state: 'active' },
    { ic: 'note', lbl: 'アルバムアート', state: 'pending' },
  ];
  return (
    <Win sel="albums" title="Albums" count="">
      <div className="fetch-wrap">
        <div className="fetch-prog radix-themes">
          <div className="fp-head">
            <div className="fp-spin" />
            <div>
              <h3>アルバム情報を取得中…</h3>
              <div className="fp-sub">Parallel Lines · 11 曲をフィンガープリントで認識</div>
            </div>
          </div>

          <div className="fp-pipe">
            {steps.map((s, i) => {
              const Ic = s.ic === 'fingerprint' ? MIcon.fingerprint : s.ic === 'disc' ? MIcon.disc : Icon[s.ic];
              return (
                <div key={i} className={`fp-step ${s.state}`}>
                  <span className="dot">{s.state === 'done' ? <Icon.check size={14} /> : <Ic size={14} />}</span>
                  <span className="lbl">{s.lbl}</span>
                </div>
              );
            })}
          </div>

          <div className="fp-bar"><div className="f" style={{ width: '64%' }} /></div>
          <div className="fp-foot">
            <div className="fp-now"><span className="pdot" />MusicBrainz に照会中 — Track 07.wav（7 / 11）</div>
            <span className="fp-rate">1 req/s</span>
            <span className="btn soft" style={{ height: 28 }}>キャンセル</span>
          </div>
        </div>
      </div>
    </Win>
  );
}

/* ============================================================
   Shared sheet pieces
   ============================================================ */
function SheetBar({ onlyClose }) {
  return (
    <div className="fs-bar">
      <span className="fs-bar-kicker">取得結果</span>
      <span className="fs-bar-title">アルバム情報を確認</span>
      <span className="spacer" />
      <span className="x"><Icon.x size={15} /></span>
    </div>
  );
}

function SheetHeader({ placeholder, artNote, match }) {
  return (
    <div className="fs-head">
      {placeholder
        ? <div className="fs-art ph"><Icon.note size={34} />{artNote && <span className="art-flag">アート未取得</span>}</div>
        : <Cover id={MF.identified.cv} className="fs-art" />}
      <div className="fs-meta">
        <div className="fs-kicker">認識されたアルバム</div>
        <div className="fs-title">{MF.identified.title}</div>
        <div className="fs-artist">{MF.identified.artist}</div>
        <div className="fs-facts">
          <span>{MF.identified.year}</span><span>·</span><span>11 曲</span><span>·</span>
          <span>MusicBrainz</span>
        </div>
      </div>
      <div className="fs-rel">
        <div className="fs-rel-cap">Release</div>
        <span className="fs-rel-btn">
          <span className="cc">GB</span>イギリス · CD · 2024
          <span className="rb-chev"><Icon.chevDown size={13} /></span>
        </span>
        {match !== false && <span className="fs-match"><span className="md" />一致 {MF.release.score}%</span>}
      </div>
    </div>
  );
}

function trackTagA(t) {
  if (t.id === null) return null; // the name cell already reads "該当なし" in amber
  if (t.low) return <span className="fst-tag low">要確認 {t.score}%</span>;
  return null;
}

function SheetFooter({ note }) {
  return (
    <div className="fs-foot">
      <span className="btn ghost">やめる</span>
      <span className="fnote">{note}</span>
      <span className="spacer" />
      <span className="btn soft"><MIcon.disc size={14} />別 Release に変更</span>
      <span className="btn solid">適用</span>
    </div>
  );
}

const SUMMARY_NOTE = <span><b>11 曲中 10 曲</b>を認識 · 1 曲は該当なし</span>;

/* ============================================================
   3B. CONFIRM SHEET — B案: レビュー表 (wide table)
   ============================================================ */
function StatusPill({ t }) {
  if (t.id === null) return <span className="status-pill unid"><span className="sd" />該当なし</span>;
  if (t.low) return <span className="status-pill low"><span className="sd" />要確認 · {t.score}%</span>;
  return <span className="status-pill ok"><span className="sd" />一致 {t.score}%</span>;
}

function ConfirmSheetB() {
  return (
    <Win sel="albums" title="Albums" count="">
      <PreAlbumDetail dim />
      <div className="fetch-overlay">
        <div className="fetch-sheet wide radix-themes">
          <SheetBar />
          <div className="fs-view">
            <SheetHeader />
            <div className="fsb">
              <table>
                <thead>
                  <tr>
                    <th className="c-n">#</th>
                    <th className="c-orig">元のファイル</th>
                    <th className="c-arrow" />
                    <th className="c-id">認識された曲名</th>
                    <th className="c-time">長さ</th>
                    <th className="c-status">認識スコア</th>
                  </tr>
                </thead>
                <tbody>
                  {MF_TRACKS.map((t, i) => (
                    <tr key={i} className={t.id === null ? 'unid' : ''}>
                      <td className="c-n">{t.n}</td>
                      <td className="c-orig">{t.orig}</td>
                      <td className="c-arrow"><MIcon.arrowR size={13} /></td>
                      <td className="c-id">{t.id === null ? '該当なし' : t.id}</td>
                      <td className="c-time">{t.time}</td>
                      <td className="c-status"><StatusPill t={t} /></td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </div>
          <SheetFooter note={SUMMARY_NOTE} />
        </div>
      </div>
    </Win>
  );
}

/* ============================================================
   4. RELEASE PICKER — popover over the (dimmed) sheet
   ============================================================ */
function ReleasePickerScreen() {
  return (
    <Win sel="albums" title="Albums" count="">
      <PreAlbumDetail dim />
      <div className="fetch-overlay">
        <div className="fetch-sheet wide dim radix-themes">
          <SheetBar />
          <div className="fs-view">
            <SheetHeader />
            <div className="fsb">
              <table>
                <thead>
                  <tr>
                    <th className="c-n">#</th><th className="c-orig">元のファイル</th>
                    <th className="c-arrow" /><th className="c-id">認識された曲名</th>
                    <th className="c-time">長さ</th><th className="c-status">認識スコア</th>
                  </tr>
                </thead>
                <tbody>
                  {MF_TRACKS.slice(0, 5).map((t, i) => (
                    <tr key={i} className={t.id === null ? 'unid' : ''}>
                      <td className="c-n">{t.n}</td><td className="c-orig">{t.orig}</td>
                      <td className="c-arrow"><MIcon.arrowR size={13} /></td>
                      <td className="c-id">{t.id === null ? '該当なし' : t.id}</td>
                      <td className="c-time">{t.time}</td><td className="c-status"><StatusPill t={t} /></td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </div>
          <SheetFooter note={SUMMARY_NOTE} />
        </div>

        {/* popover — sibling of the sheet so it isn't clipped; anchored under
            the header's Release control (sheet right edge) */}
        <div className="rel-pop" style={{ top: 150, right: 254 }}>
            <div className="rel-head">
              <h3>Release を選択</h3>
              <p>認識された候補 Release。各トラックの投票で既定を決めています。スコアは参考値です。</p>
            </div>
            <div className="rel-list">
              {MF_RELEASES.map((r) => (
                <div key={r.id} className={`rel-row ${r.def ? 'sel' : ''}`}>
                  <span className="rel-radio" />
                  <div className="rel-main">
                    <div className="rel-name">
                      {r.title}
                      {r.def && <span className="rel-deftag">既定</span>}
                    </div>
                    <div className="rel-attrs">
                      <span className="cc">{CCODE[r.country]}</span>
                      <span>{COUNTRY[r.country]}</span><span className="sep">·</span>
                      <span>{r.media}</span><span className="sep">·</span>
                      <span className={r.unknown ? 'unknown' : ''}>{r.date}</span><span className="sep">·</span>
                      <span>{r.tracks} 曲</span>
                    </div>
                  </div>
                  <div className="rel-score">
                    <span className="pct">{r.score}%</span>
                    <span className="barwrap"><span className="bf" style={{ width: `${r.score}%` }} /></span>
                  </div>
                </div>
              ))}
            </div>
            <div className="rel-foot">
              <span className="tiebreak">投票が割れた場合は、最も古いリリース日を既定に選びます（日付不明は最劣後）。</span>
              <span className="btn ghost">キャンセル</span>
              <span className="btn solid">この Release を使う</span>
            </div>
          </div>
        </div>
    </Win>
  );
}

/* ============================================================
   5. NO MATCH — 該当なし (候補ゼロ)
   ============================================================ */
function NoMatchScreen() {
  return (
    <Win sel="albums" title="Albums" count="">
      <PreAlbumDetail dim />
      <div className="fetch-overlay">
        <div className="fetch-sheet narrow radix-themes">
          <SheetBar />
          <div className="fs-view">
            <div className="fs-empty">
              <div className="glyph"><Icon.search size={30} /></div>
              <h3>このアルバムを認識できませんでした</h3>
              <p>11 曲をフィンガープリントで照会しましたが、一致する候補が見つかりませんでした。音声ファイルには何も書き込まれていません。</p>
              <div className="sub">「該当なしとして確定」すると、再実行のたびに照会し直す対象から外れます。</div>
            </div>
          </div>
          <div className="fs-foot">
            <span className="btn ghost">やめる</span>
            <span className="spacer" />
            <span className="btn soft">もう一度試す</span>
            <span className="btn solid">該当なしとして確定</span>
          </div>
        </div>
      </div>
    </Win>
  );
}

/* ============================================================
   6. NO ARTWORK — アート未取得 (placeholder)
   ============================================================ */
function NoArtworkScreen() {
  return (
    <Win sel="albums" title="Albums" count="">
      <PreAlbumDetail dim />
      <div className="fetch-overlay">
        <div className="fetch-sheet narrow radix-themes">
          <SheetBar />
          <div className="fs-view">
            <SheetHeader placeholder artNote />
            <div className="fs-banner">
              <span className="bic"><Icon.warn size={15} /></span>
              <span>アルバムアートが見つかりませんでした（Cover Art Archive・iTunes とも未提供）。</span>
              <span className="spacer" />
              <span className="bact">アートを再取得</span>
            </div>
            <div className="fst">
              <div className="fst-lead">
                <span className="lead-r">#</span><span>元のファイル</span><span /><span>認識された曲名</span>
              </div>
              {MF_TRACKS.map((t, i) => (
                <div key={i} className={`fst-row ${t.id === null ? 'unid' : ''}`}>
                  <span className="fst-n">{t.n}</span>
                  <span className="fst-orig">{t.orig}</span>
                  <span className="fst-arrow"><MIcon.arrowR size={13} /></span>
                  <span className="fst-id"><span className="nm">{t.id === null ? '該当なし' : t.id}</span>{trackTagA(t)}</span>
                </div>
              ))}
            </div>
          </div>
          <div className="fs-foot">
            <span className="btn ghost">やめる</span>
            <span className="fnote">アートなしで適用できます</span>
            <span className="spacer" />
            <span className="btn soft"><MIcon.disc size={14} />別 Release に変更</span>
            <span className="btn solid">適用</span>
          </div>
        </div>
      </div>
    </Win>
  );
}

/* ============================================================
   7. PARTIAL FAILURE — 取得失敗 / 一部 failed
   3 tracks failed on network; offered re-run. failed ≠ unidentified.
   ============================================================ */
const FAIL_SET = new Set([6, 7, 9]); // 0-based: tracks 7,8,10 failed

function PartialFailScreen() {
  return (
    <Win sel="albums" title="Albums" count="">
      <PreAlbumDetail dim />
      <div className="fetch-overlay">
        <div className="fetch-sheet wide radix-themes">
          <SheetBar />
          <div className="fs-view">
            <SheetHeader />
            <div className="fs-banner">
              <span className="bic"><Icon.warn size={15} /></span>
              <span><b style={{ fontWeight: 'var(--font-weight-bold)' }}>3 曲</b>の取得に失敗しました（ネットワークエラー）。指数バックオフで 3 回再試行しても応答がありませんでした。</span>
              <span className="spacer" />
              <span className="bact">失敗分を再試行</span>
            </div>
            <div className="fsb">
              <table>
                <thead>
                  <tr>
                    <th className="c-n">#</th><th className="c-orig">元のファイル</th>
                    <th className="c-arrow" /><th className="c-id">認識された曲名</th>
                    <th className="c-time">長さ</th><th className="c-status">状態</th>
                  </tr>
                </thead>
                <tbody>
                  {MF_TRACKS.map((t, i) => {
                    const failed = FAIL_SET.has(i);
                    return (
                      <tr key={i} className={failed ? 'fail' : ''}>
                        <td className="c-n">{t.n}</td>
                        <td className="c-orig">{t.orig}</td>
                        <td className="c-arrow"><MIcon.arrowR size={13} /></td>
                        <td className="c-id">{failed ? '—' : t.id}</td>
                        <td className="c-time">{t.time}</td>
                        <td className="c-status">
                          {failed
                            ? <span className="status-pill fail"><span className="sd" />取得失敗</span>
                            : <span className="status-pill ok"><span className="sd" />一致 {t.score}%</span>}
                        </td>
                      </tr>
                    );
                  })}
                </tbody>
              </table>
            </div>
          </div>
          <div className="fs-foot">
            <span className="btn ghost">やめる</span>
            <span className="fnote"><b>8 曲</b>を認識 · 3 曲は取得失敗（<span style={{ color: 'var(--red-11)' }}>failed</span> として記録）</span>
            <span className="spacer" />
            <span className="btn soft">失敗分を再試行</span>
            <span className="btn solid">取得分のみ適用</span>
          </div>
        </div>
      </div>
    </Win>
  );
}

Object.assign(window, {
  FetchTriggerScreen, FetchingScreen, ConfirmSheetB,
  ReleasePickerScreen, NoMatchScreen, NoArtworkScreen, PartialFailScreen,
});
