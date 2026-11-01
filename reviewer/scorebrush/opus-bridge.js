// SPDX-License-Identifier: AGPL-3.0-or-later
// OPUS adapter for the unmodified ScoreBrush storage and review lifecycle.
import {opusReviewApi as api,completion} from './app.js';
const ready=document.body.dataset.ready==='true'?Promise.resolve():
  new Promise(resolve=>document.addEventListener('score-desk-ready',resolve,{once:true}));
window.opusScoreBrush=Object.freeze({
  ready,
  async open(files,projectId){
    await ready;
    if(document.getElementById('startupScreen').dataset.state==='error')
      throw new Error('ScoreBrush could not initialize. Use its recovery options.');
    if(api.status().busy)throw new Error('Wait for the current review operation.');
    document.getElementById('workspaceDialog').close();
    // Own each Blob in this frame's realm; upstream export validators correctly
    // reject cross-realm objects that are not this application's Blob instances.
    const owned=Object.fromEntries(await Promise.all(['source','rendered','ly'].map(async role=>[
      role,{name:files[role].name,blob:new Blob([await files[role].blob.arrayBuffer()],{type:files[role].blob.type})}
    ])));
    await api.openFiles(owned,{projectId,initialTranscriptionFilename:files.rendered.name});
    if(!api.capture().review)throw new Error('ScoreBrush could not open the score.');
    await api.flush();
    return api.capture();
  },
  async capture(){await api.flush();return api.capture();},
  backup(){completion.open();}
});
