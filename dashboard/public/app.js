const model = { skills: [], automations: [], csrf: '', filter: 'All', activeTab: 'skills' };
const jukebox = { tracks: [], folders: [], current: null, searchTimer: null };
const $ = (selector) => document.querySelector(selector);
const escapeHtml = (value) => String(value ?? '').replace(/[&<>"']/g, (character) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[character]));
const arrows = { up: '▲', down: '▼', left: '◀', right: '▶' };

async function api(path, options = {}) {
  options.headers = { ...(options.headers || {}), 'Content-Type': 'application/json', 'X-Thrax-CSRF': model.csrf };
  const response = await fetch(path, options);
  const data = await response.json();
  if (!response.ok) throw new Error(data.error || 'The control room could not complete that request.');
  return data;
}

function showToast(message) {
  const toast = $('#toast');
  toast.textContent = message;
  toast.classList.add('show');
  window.setTimeout(() => toast.classList.remove('show'), 4200);
}

function formatTime(seconds) {
  if (!Number.isFinite(seconds) || seconds < 0) return '0:00';
  const minutes = Math.floor(seconds / 60);
  return `${minutes}:${String(Math.floor(seconds % 60)).padStart(2, '0')}`;
}

function trackMeta(track) { return `${track.folder} · ${track.songFolder}`; }

function setNowPlaying(track) {
  jukebox.current = track;
  $('#nowPlaying').textContent = track ? track.title : 'Choose a track';
  $('#nowPlayingMeta').textContent = track ? trackMeta(track) : 'Search the installed library, then press play.';
  $('#jukeboxPack').textContent = track ? track.folder : '—';
  $('#jukeboxFormat').textContent = track ? track.extension.replace('.', '').toUpperCase() : 'LOCAL';
  $('#togglePlayback').textContent = '▶';
  $('#togglePlayback').setAttribute('aria-label', track ? `Play ${track.title}` : 'Play selected track');
  renderJukeboxTracks();
}

function renderJukeboxTracks() {
  const trackWheel = $('#jukeboxTracks');
  const resultLabel = $('#jukeboxResults');
  resultLabel.textContent = `${jukebox.tracks.length} shown`;
  trackWheel.innerHTML = jukebox.tracks.length ? jukebox.tracks.map((track, index) => `<button class="wheel-track ${track.id === jukebox.current?.id ? 'is-current' : ''}" data-jukebox-track="${escapeHtml(track.id)}"><span class="wheel-index">${String(index + 1).padStart(2, '0')}</span><span class="wheel-track-copy"><strong>${escapeHtml(track.title)}</strong><small>${escapeHtml(trackMeta(track))}</small></span><span class="wheel-format">${escapeHtml(track.extension.replace('.', ''))}</span></button>`).join('') : '<div class="wheel-empty">No playable tracks match this search.</div>';
  document.querySelectorAll('[data-jukebox-track]').forEach((button) => { button.onclick = () => selectJukeboxTrack(jukebox.tracks.find((track) => track.id === button.dataset.jukeboxTrack), true); });
}

async function loadJukebox() {
  const query = $('#jukeboxSearch').value.trim();
  const folder = $('#jukeboxFolder').value;
  $('#jukeboxTracks').innerHTML = '<p class="wheel-loading">Loading installed tracks…</p>';
  try {
    const data = await api(`/api/jukebox?q=${encodeURIComponent(query)}&folder=${encodeURIComponent(folder)}`);
    jukebox.tracks = data.tracks;
    jukebox.folders = data.folders;
    const select = $('#jukeboxFolder');
    const selectedFolder = folder;
    select.innerHTML = `<option value="">All packs</option>${data.folders.map((item) => `<option value="${escapeHtml(item)}">${escapeHtml(item)}</option>`).join('')}`;
    select.value = data.folders.includes(selectedFolder) ? selectedFolder : '';
    $('#jukeboxCount').textContent = `${data.trackCount.toLocaleString()} local tracks`;
    renderJukeboxTracks();
  } catch (error) {
    $('#jukeboxTracks').innerHTML = '<div class="wheel-empty">The local music index is unavailable.</div>';
    showToast(error.message);
  }
}

function drawWaveform(timestamp = 0) {
  const canvas = $('#waveform');
  const context = canvas.getContext('2d');
  const width = canvas.width;
  const height = canvas.height;
  context.clearRect(0, 0, width, height);
  context.fillStyle = '#101519';
  context.fillRect(0, 0, width, height);
  for (let line = 1; line < 4; line += 1) { context.fillStyle = 'rgba(119,147,167,.13)'; context.fillRect(0, Math.floor(height * line / 4), width, 1); }
  const bars = 58;
  const gap = 4;
  const barWidth = (width - (bars - 1) * gap) / bars;
  const colors = ['#21CCE8', '#E29C18', '#66C955', '#B45CFF', '#FF577E'];
  for (let index = 0; index < bars; index += 1) {
    const isPlaying = !$('#jukeboxAudio').paused;
    const idleLevel = .12 + Math.abs(Math.sin(timestamp / 650 + index * .48)) * .16;
    const playingLevel = .28 + Math.abs(Math.sin(timestamp / 170 + index * .78)) * .56;
    const level = isPlaying ? playingLevel : idleLevel;
    const barHeight = Math.max(5, Math.floor(level * (height - 16)));
    const x = index * (barWidth + gap);
    const y = Math.floor((height - barHeight) / 2);
    context.fillStyle = colors[index % colors.length];
    context.fillRect(x, y, barWidth, barHeight);
  }
  window.requestAnimationFrame(drawWaveform);
}

async function playSelectedAudio(audio) {
  // Call play() first, in the original click event.  Some embedded Chromium views
  // reject it once another awaited Web Audio operation has consumed that gesture.
  try {
    await audio.play();
  } catch (error) {
    const detail = error?.message ? ` (${error.message})` : '';
    showToast(`The selected local audio file could not be played${detail}`);
  }
}

async function selectJukeboxTrack(track, autoplay) {
  if (!track) return;
  const audio = $('#jukeboxAudio');
  setNowPlaying(track);
  audio.src = `/api/audio/${encodeURIComponent(track.id)}`;
  audio.load();
  if (!autoplay) return;
  await playSelectedAudio(audio);
}

async function chooseRandomTrack(folder) {
  try {
    const selected = await api(`/api/jukebox/random?folder=${encodeURIComponent(folder || '')}`);
    if (!jukebox.tracks.some((track) => track.id === selected.id)) jukebox.tracks.unshift(selected);
    await selectJukeboxTrack(selected, true);
  } catch (error) { showToast(error.message); }
}

function moveJukeboxTrack(direction) {
  if (!jukebox.tracks.length) return;
  const currentIndex = Math.max(0, jukebox.tracks.findIndex((track) => track.id === jukebox.current?.id));
  const nextIndex = (currentIndex + direction + jukebox.tracks.length) % jukebox.tracks.length;
  selectJukeboxTrack(jukebox.tracks[nextIndex], true);
}

function setupJukebox() {
  const audio = $('#jukeboxAudio');
  $('#jukeboxSearch').oninput = () => { window.clearTimeout(jukebox.searchTimer); jukebox.searchTimer = window.setTimeout(loadJukebox, 180); };
  $('#jukeboxFolder').onchange = loadJukebox;
  $('#shuffleAll').onclick = () => chooseRandomTrack('');
  $('#shuffleFolder').onclick = () => { const folder = $('#jukeboxFolder').value; if (!folder) { showToast('Choose a pack before shuffling its folder.'); return; } chooseRandomTrack(folder); };
  $('#previousTrack').onclick = () => moveJukeboxTrack(-1);
  $('#nextTrack').onclick = () => moveJukeboxTrack(1);
  $('#togglePlayback').onclick = async () => {
    if (!jukebox.current) { await selectJukeboxTrack(jukebox.tracks[0], true); return; }
    if (audio.paused) await playSelectedAudio(audio); else audio.pause();
  };
  $('#volume').oninput = (event) => { audio.volume = Number(event.target.value) / 100; };
  $('#trackPosition').oninput = (event) => { if (Number.isFinite(audio.duration)) audio.currentTime = Number(event.target.value); };
  audio.onloadedmetadata = () => { $('#trackPosition').max = Math.floor(audio.duration || 0); $('#trackTime').textContent = `0:00 / ${formatTime(audio.duration)}`; };
  audio.ontimeupdate = () => { $('#trackPosition').value = Math.floor(audio.currentTime || 0); $('#trackTime').textContent = `${formatTime(audio.currentTime)} / ${formatTime(audio.duration)}`; };
  audio.onplay = () => { $('#togglePlayback').textContent = '❚❚'; $('#togglePlayback').setAttribute('aria-label', 'Pause current track'); };
  audio.onpause = () => { $('#togglePlayback').textContent = '▶'; $('#togglePlayback').setAttribute('aria-label', jukebox.current ? `Play ${jukebox.current.title}` : 'Play selected track'); };
  audio.onended = () => moveJukeboxTrack(1);
  audio.onerror = () => {
    const messages = { 1: 'Playback was stopped.', 2: 'The local audio request failed.', 3: 'The audio file could not be decoded.', 4: 'This browser does not support this audio format.' };
    showToast(messages[audio.error?.code] || 'The selected local audio file could not be played in this browser.');
  };
  drawWaveform();
}

function setTab(tab) {
  model.activeTab = tab;
  document.querySelectorAll('.nav-item').forEach((button) => button.classList.toggle('active', button.dataset.tab === tab));
  document.querySelectorAll('.view').forEach((view) => view.classList.toggle('active', view.id === tab));
  $('#pageTitle').textContent = ({ skills: 'Capability Select', sessions: 'Session Results', tasks: 'Schedule Select', activity: 'Evaluation Log' })[tab];
  if (tab === 'sessions') loadPlaySessions();
  if (tab === 'activity') loadHistory();
}

function formatSessionDuration(seconds) {
  const hours = Math.floor(seconds / 3600);
  const minutes = Math.round((seconds % 3600) / 60);
  return hours ? `${hours}h ${minutes}m` : `${minutes}m`;
}

async function loadPlaySessions() {
  const grid = $('#sessionGrid');
  grid.innerHTML = '<p>Reading local score exports…</p>';
  try {
    const data = await api('/api/play-sessions');
    $('#sessionsObserved').textContent = `Updated ${new Date(data.observedAt).toLocaleString()}`;
    grid.innerHTML = data.people.map((person) => `<article class="player-session"><header><span class="player-badge">P1</span><div><p class="eyebrow">Player record</p><h3>${escapeHtml(person.name)}</h3></div></header><div class="session-pair">${person.sessions.map((session, index) => `<section class="session-card"><div class="session-title"><div><span>SESSION ${index + 1}</span><strong>${new Date(session.startedAt).toLocaleDateString(undefined,{month:'short',day:'numeric',year:'numeric'})}</strong></div><div class="session-duration"><strong>${formatSessionDuration(session.durationSeconds)}</strong><span>${session.songCount} songs</span></div></div><ol>${session.topSongs.map((song, rank) => `<li><span class="song-rank">${rank + 1}</span><div><strong>${escapeHtml(song.title)}</strong><small>${escapeHtml(song.artist)}</small></div><span class="song-level">${escapeHtml(song.difficulty)}${song.meter ? ` · ${song.meter}` : ''}</span><span class="song-score">${song.percent.toFixed(2)}%</span></li>`).join('')}</ol></section>`).join('') || '<p class="muted">No recorded sessions found.</p>'}</div></article>`).join('');
  } catch (error) { grid.innerHTML = '<p class="muted">Recent session evidence is unavailable.</p>'; showToast(error.message); }
}

function renderFilters() {
  const categories = ['All', ...new Set(model.skills.map((skill) => skill.category))];
  $('#filters').innerHTML = categories.map((category) => `<button class="filter-button ${category === model.filter ? 'active' : ''}" data-filter="${escapeHtml(category)}">${escapeHtml(category)}</button>`).join('');
  document.querySelectorAll('[data-filter]').forEach((button) => {
    button.onclick = () => { model.filter = button.dataset.filter; renderFilters(); renderSkills(); };
  });
}

function riskLabel(skill) {
  return skill.risk === 'read-only' ? '<span class="chip chip-safe">Read-only</span>' : '<span class="chip chip-review">Review required</span>';
}

function renderSkills() {
  const query = $('#search').value.trim().toLowerCase();
  const rows = model.skills.filter((skill) => (model.filter === 'All' || skill.category === model.filter) && `${skill.name} ${skill.description} ${skill.skill} ${skill.category}`.toLowerCase().includes(query));
  $('#skillGrid').innerHTML = rows.length ? rows.map((skill) => `
    <article class="capability-card">
      <div class="card-top"><span class="arrow-tile arrow-${escapeHtml(skill.icon)}" aria-hidden="true">${arrows[skill.icon]}</span><div class="card-chips"><span class="chip">${escapeHtml(skill.category)}</span>${riskLabel(skill)}</div></div>
      <div class="card-copy"><h3>${escapeHtml(skill.name)}</h3><p>${escapeHtml(skill.description)}</p></div>
      <div class="card-footer"><span class="skill-name">${escapeHtml(skill.skill)}</span><button class="button button-quiet" data-run="${escapeHtml(skill.id)}">${skill.risk === 'read-only' ? 'Run check' : 'Prepare request'} <span aria-hidden="true">→</span></button></div>
    </article>`).join('') : '<div class="empty-state"><strong>No capabilities found</strong><p>Try a different search or category.</p></div>';
  document.querySelectorAll('[data-run]').forEach((button) => { button.onclick = () => openAction(button.dataset.run, false); });
}

function inputFor(field) {
  const required = field.required ? 'required' : '';
  const placeholder = escapeHtml(field.placeholder || field.root || '');
  if (field.type === 'textarea') return `<textarea name="${escapeHtml(field.id)}" ${required} maxlength="${field.maxLength}" placeholder="${placeholder}"></textarea>`;
  if (field.type === 'select') return `<select name="${escapeHtml(field.id)}">${field.options.map((option) => `<option>${escapeHtml(option)}</option>`).join('')}</select>`;
  return `<input name="${escapeHtml(field.id)}" type="${field.type === 'url' ? 'url' : 'text'}" ${required} maxlength="${field.maxLength}" placeholder="${placeholder}">`;
}

function fieldsFor(skill, scheduling) {
  const capabilityFields = skill.fields.map((field) => `<label class="field"><span>${escapeHtml(field.label)}${field.required ? ' <b>*</b>' : ''}</span>${inputFor(field)}</label>`).join('');
  if (!scheduling) return capabilityFields || '<p class="form-hint">This check does not need any additional input.</p>';
  const start = new Date(Date.now() + 3600000);
  start.setMinutes(0, 0, 0);
  const policy = skill.action === 'request' ? 'When due, this creates a review request. It never makes an unattended live change.' : 'When due, this runs the fixed read-only helper.';
  return `${capabilityFields}
    <div class="form-divider"><span>Schedule</span></div>
    <label class="field"><span>Frequency <b>*</b></span><select name="frequency"><option value="daily">Daily</option><option value="hourly">Hourly</option><option value="weekly">Weekly</option></select></label>
    <label class="field"><span>First run <b>*</b></span><input name="startAt" type="datetime-local" required value="${start.toISOString().slice(0, 16)}"></label>
    <label class="confirmation"><input name="acknowledged" type="checkbox" required><span><strong>I understand.</strong> This is a dashboard-only schedule and works while Arcade Console is open. ${policy}</span></label>`;
}

function openAction(id, scheduling) {
  const skill = model.skills.find((candidate) => candidate.id === id);
  const action = scheduling ? 'Create schedule' : skill.risk === 'read-only' ? 'Run read-only check' : 'Stage review request';
  $('#dialogBody').innerHTML = `
    <p class="eyebrow">${scheduling ? 'New dashboard schedule' : skill.risk === 'read-only' ? 'Read-only capability' : 'Approval-gated capability'}</p>
    <h2 id="dialogTitle">${escapeHtml(skill.name)}</h2>
    <p class="dialog-description">${escapeHtml(skill.description)}</p>
    <form id="actionForm"><div class="form-grid">${fieldsFor(skill, scheduling)}</div><div class="dialog-note"><span aria-hidden="true">${scheduling ? '◷' : skill.risk === 'read-only' ? '✓' : '◇'}</span><p>${scheduling ? 'A schedule never changes external automation configuration.' : skill.risk === 'read-only' ? 'This helper reads status only.' : 'This records a request for your review; it does not make a live change.'}</p></div><div class="dialog-actions"><button type="button" class="button button-secondary" data-close>Cancel</button><button type="submit" class="button button-primary">${action}<span aria-hidden="true">→</span></button></div></form>`;
  const dialog = $('#actionDialog');
  dialog.showModal();
  $('[data-close]').onclick = () => dialog.close();
  $('#actionForm').onsubmit = async (event) => {
    event.preventDefault();
    const data = new FormData(event.target);
    const inputs = {};
    skill.fields.forEach((field) => { inputs[field.id] = data.get(field.id) || ''; });
    try {
      const payload = { capabilityId: id, inputs };
      if (scheduling) {
        payload.frequency = data.get('frequency');
        payload.startAt = new Date(data.get('startAt')).toISOString();
        payload.acknowledged = data.get('acknowledged') === 'on';
        await api('/api/schedules', { method: 'POST', body: JSON.stringify(payload) });
        showToast('Dashboard schedule created.');
        dialog.close();
        await loadSchedules();
        return;
      }
      const result = await api('/api/run', { method: 'POST', body: JSON.stringify(payload) });
      showToast(result.message || `${skill.name} completed.`);
      if (result.output) $('#dialogBody').insertAdjacentHTML('beforeend', `<details class="result-output" open><summary>Result</summary><pre>${escapeHtml(result.output)}</pre></details>`);
      await loadHistory();
    } catch (error) { showToast(error.message); }
  };
}

function taskStatusClass(status) { return String(status).toLowerCase().includes('active') ? 'task-active' : 'task-muted'; }
function renderTasks() {
  $('#existingTaskTotal').textContent = `${model.automations.length} tracked`;
  $('#taskList').innerHTML = model.automations.map((task) => `<article class="task-row"><span class="task-icon ${taskStatusClass(task.status)}" aria-hidden="true">◷</span><div class="task-copy"><strong>${escapeHtml(task.name)}</strong><span>${escapeHtml(task.scheduler)} · ${escapeHtml(task.source)}</span></div><div class="task-timing"><strong>${escapeHtml(task.schedule || task.rrule)}</strong><span>${escapeHtml(task.status)}</span></div></article>`).join('') || '<div class="empty-state"><strong>No recurring work reported</strong><p>Refresh the console to inspect current scheduling state.</p></div>';
}

async function loadSchedules() {
  const schedules = await api('/api/schedules');
  $('#scheduleList').innerHTML = schedules.length ? schedules.map((schedule) => `<article class="task-row"><span class="task-icon task-active" aria-hidden="true">▶</span><div class="task-copy"><strong>${escapeHtml(schedule.capabilityName)}</strong><span>${escapeHtml(schedule.runPolicy || 'Dashboard schedule')}</span></div><div class="task-timing"><strong>${escapeHtml(schedule.frequency)} · ${schedule.enabled ? 'Active' : 'Paused'}</strong><span>Next: ${new Date(schedule.nextRunAt).toLocaleString()}</span></div></article>`).join('') : '<div class="empty-state compact"><strong>No dashboard schedules</strong><p>Create one when a safe recurring check would help.</p></div>';
}

async function loadHistory() {
  const history = await api('/api/history');
  $('#history').innerHTML = history.length ? history.reverse().map((item) => `<article class="history-row"><span class="history-rail" aria-hidden="true"></span><div><strong>${escapeHtml(item.summary)}</strong><p>${new Date(item.timestamp).toLocaleString()} · ${escapeHtml(item.status)}</p></div></article>`).join('') : '<div class="empty-state"><strong>No activity yet</strong><p>Capability runs and review requests will appear here.</p></div>';
}

function openSchedulePicker() {
  $('#dialogBody').innerHTML = `<p class="eyebrow">New dashboard schedule</p><h2 id="dialogTitle">Choose a capability</h2><p class="dialog-description">Select an existing, allowlisted capability. You will set its frequency on the next step.</p><div class="schedule-picker">${model.skills.map((skill) => `<button data-schedule="${escapeHtml(skill.id)}"><span class="arrow-tile arrow-${escapeHtml(skill.icon)}" aria-hidden="true">${arrows[skill.icon]}</span><span><strong>${escapeHtml(skill.name)}</strong><small>${skill.risk === 'read-only' ? 'Read-only helper' : 'Creates review request'}</small></span><span aria-hidden="true">→</span></button>`).join('')}</div>`;
  const dialog = $('#actionDialog');
  dialog.showModal();
  document.querySelectorAll('[data-schedule]').forEach((button) => { button.onclick = () => openAction(button.dataset.schedule, true); });
}

document.querySelectorAll('.nav-item').forEach((button) => { button.onclick = () => setTab(button.dataset.tab); });
$('#search').oninput = renderSkills;
$('#newSchedule').onclick = openSchedulePicker;

(async () => {
  try {
    const catalog = await api('/api/catalog');
    Object.assign(model, catalog);
    $('#skillCount').textContent = model.skills.length;
    $('#taskCount').textContent = model.automations.length;
    renderFilters();
    renderSkills();
    renderTasks();
    await loadSchedules();
    setupJukebox();
    await loadJukebox();
  } catch (error) { showToast(error.message); }
})();
