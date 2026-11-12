const piece = new URLSearchParams(window.location.search).get('piece');
const titleNode = document.querySelector('[data-title]');
const statusNode = document.querySelector('[data-status]');
const messageNode = document.querySelector('[data-message]');

function fail(message) {
  statusNode.textContent = '';
  messageNode.textContent = message;
}

async function loadScores() {
  const [catalogResponse, reviewsResponse] = await Promise.all([
    fetch('catalog.json'),
    fetch('reviews.json'),
  ]);
  if (!catalogResponse.ok || !reviewsResponse.ok) throw new Error('Score lists unavailable');
  const [catalog, reviews] = await Promise.all([
    catalogResponse.json(),
    reviewsResponse.json(),
  ]);
  return {catalog: catalog.scores, reviews: reviews.scores};
}

function showQueue(catalog, reviews) {
  titleNode.textContent = 'Scores to proofread';
  statusNode.textContent = 'No one has checked these scores yet.';
  const queue = document.querySelector('[data-queue]');
  const waiting = catalog.filter((score) => score.step === 3 && !score.verified_by);
  for (const score of [...waiting, ...reviews]) {
    const item = document.createElement('li');
    const link = document.createElement('a');
    link.href = `proofread.html?piece=${encodeURIComponent(score.slug)}`;
    link.textContent = `${score.composer} - ${score.title} (${score.catalogue})`;
    item.append(link);
    queue.append(item);
  }
  queue.hidden = false;
  if (!waiting.length && !reviews.length) messageNode.textContent = 'There is nothing to proofread right now.';
}

function showScore(score) {
  for (const link of document.querySelectorAll('[data-scorebrush]')) {
    link.href = 'reviewer/?piece=' + encodeURIComponent(score.slug);
  }
  for (const link of document.querySelectorAll('[data-score-desk]')) {
    link.href = `contributor/?piece=${encodeURIComponent(score.slug)}`;
  }
  titleNode.textContent = `${score.composer} - ${score.title}`;
  document.title = `${score.title} - Proofread - The OPUS Project`;
  statusNode.textContent = score.draft
    ? 'Unmerged draft'
    : score.verified_by
      ? `Checked by @${score.verified_by}`
      : score.step === 3
        ? 'Needs proofreading'
        : `Draft, step ${score.step} of 3`;

  document.querySelector('[data-source-link]').href = score.source_pdf;
  document.querySelector('[data-source-frame]').src = score.source_pdf;
  document.querySelector('[data-library-link]').href = score.source_page;
  const crosscheck = document.querySelector('[data-crosscheck-link]');
  if (score.crosscheck_url) {
    crosscheck.href = score.crosscheck_url;
    crosscheck.textContent = score.crosscheck_name || 'High-resolution scan';
  } else {
    crosscheck.hidden = true;
  }
  document.querySelector('[data-rendered-link]').href = score.pdf_url;
  document.querySelector('[data-rendered-frame]').src = score.pdf_url;
  document.querySelector('[data-lilypond-link]').href = score.lilypond_url;

  const reportTitle = `Proofreading: ${score.composer} - ${score.title}`;
  const reportBody = `Work: ${score.composer} - ${score.title}\nResult: [no errors found / corrections needed]\nPages and measures checked:\nRevision checked:\nDetails:\nSource PDF: ${score.source_pdf}\nRendered PDF: ${new URL(score.pdf_url, window.location.href).href}`;
  const params = new URLSearchParams({category: 'general', title: reportTitle, body: reportBody});
  for (const link of document.querySelectorAll('[data-feedback]')) {
    link.href = `https://github.com/the-opus-project/the-opus-project.github.io/discussions/new?${params}`;
  }

  const discussionNode = document.querySelector('[data-discussion]');
  window.addEventListener('message', (event) => {
    if (event.origin !== 'https://giscus.app') return;
    if (event.source !== discussionNode.querySelector('iframe')?.contentWindow) return;
    if (typeof event.data?.giscus?.error === 'string') discussionNode.hidden = true;
  });

  const discussionScript = document.createElement('script');
  discussionScript.src = 'https://giscus.app/client.js';
  discussionScript.async = true;
  discussionScript.crossOrigin = 'anonymous';
  const discussionOptions = {
    repo: 'the-opus-project/the-opus-project.github.io',
    'repo-id': 'R_kgDOUtZHyQ',
    category: 'General',
    'category-id': 'DIC_kwDOUtZHyc4DGioB',
    mapping: 'specific',
    term: `Score reports: ${score.slug}`,
    strict: '1',
    'reactions-enabled': '0',
    'emit-metadata': '0',
    'input-position': 'top',
    theme: 'preferred_color_scheme',
    lang: 'en',
  };
  for (const [key, value] of Object.entries(discussionOptions)) {
    discussionScript.setAttribute(`data-${key}`, value);
  }
  discussionNode.append(discussionScript);

  document.querySelector('[data-compare]').hidden = false;
  document.querySelector('[data-report]').hidden = false;
}

loadScores()
  .then(({catalog, reviews}) => {
    if (!piece) {
      showQueue(catalog, reviews);
      return;
    }
    const score = [...catalog, ...reviews].find((entry) => entry.slug === piece);
    if (score) showScore(score);
    else fail('This work is not available for proofreading.');
  })
  .catch(() => fail('The score lists could not be loaded. Please try again later.'));
