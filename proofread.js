const piece = new URLSearchParams(window.location.search).get('piece');
const titleNode = document.querySelector('[data-title]');
const statusNode = document.querySelector('[data-status]');
const messageNode = document.querySelector('[data-message]');

function fail(message) {
  statusNode.textContent = '';
  messageNode.textContent = message;
}

if (!piece) {
  fail('Choose a work from the catalog to compare its PDFs.');
} else {
  fetch('catalog.json')
    .then((response) => {
      if (!response.ok) throw new Error('Catalog unavailable');
      return response.json();
    })
    .then((catalog) => {
      const score = catalog.scores.find((entry) => entry.slug === piece);
      if (!score) {
        fail('This work is not in the catalog.');
        return;
      }

      titleNode.textContent = `${score.composer} — ${score.title}`;
      document.title = `${score.title} — Proofread — The OPUS Project`;
      statusNode.textContent = score.verified_by
        ? `Human verified by @${score.verified_by}`
        : score.step === 3
          ? 'Reconciled score — needs human proofreading'
          : `Agent step ${score.step}/3 — not yet reconciled`;

      document.querySelector('[data-source-link]').href = score.source_pdf;
      document.querySelector('[data-source-frame]').src = score.source_pdf;
      document.querySelector('[data-library-link]').href = score.source_page;
      document.querySelector('[data-rendered-link]').href = score.pdf_url;
      document.querySelector('[data-rendered-frame]').src = score.pdf_url;
      document.querySelector('[data-lilypond-link]').href = score.lilypond_url;

      const reportTitle = `Proofreading: ${score.composer} — ${score.title}`;
      const reportBody = `Work: ${score.composer} — ${score.title}\nResult: [no errors found / corrections needed]\nPages and measures checked:\nDetails:\nSource PDF: ${score.source_pdf}\nRendered PDF: ${new URL(score.pdf_url, window.location.href).href}`;
      const params = new URLSearchParams({category: 'general', title: reportTitle, body: reportBody});
      document.querySelector('[data-feedback]').href = `https://github.com/dhruv9saini/the-opus-project/discussions/new?${params}`;

      const discussionScript = document.createElement('script');
      discussionScript.src = 'https://giscus.app/client.js';
      discussionScript.async = true;
      discussionScript.crossOrigin = 'anonymous';
      const discussionOptions = {
        repo: 'dhruv9saini/the-opus-project',
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
      document.querySelector('[data-discussion]').append(discussionScript);

      document.querySelector('[data-compare]').hidden = false;
      document.querySelector('[data-report]').hidden = false;
    })
    .catch(() => fail('The catalog could not be loaded. Please try again later.'));
}
