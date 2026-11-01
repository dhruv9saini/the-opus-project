import {fetchBounded,validateWork,verified,projectId,projectFiles,makeReport,reportDiscussion} from './opus-review.mjs';
const $=id=>document.getElementById(id);
const root=new URL('../',import.meta.url);
const slug=new URLSearchParams(location.search).get('piece');
let work,rendered,ly,bridge,sourceBusy=false,exportBusy=false,scopeKey=null,scopeListener=false;
const status=message=>{$('status').textContent=message;};
function download(blob,name){
  const url=URL.createObjectURL(blob),a=document.createElement('a');
  a.href=url;a.download=name;a.click();setTimeout(()=>URL.revokeObjectURL(url),60000);
}
function syncScope(){
  const snapshot=bridge?.current().snapshotId;
  if(!snapshot)return;
  const next='opus-human-review-scope:'+work.slug+':'+snapshot;
  if(next===scopeKey)return;
  scopeKey=next;$('coverage').value='';$('outcome').value='partial';$('discussion').hidden=true;
  try{
    const saved=JSON.parse(localStorage.getItem(scopeKey));
    if(saved&&typeof saved.coverage==='string'&&saved.coverage.length<=2000&&
      ['partial','corrections-needed','no-errors-found'].includes(saved.outcome)){
      $('coverage').value=saved.coverage;$('outcome').value=saved.outcome;
    }
  }catch{/* Scope drafting remains available when local storage is unavailable. */}
}
function saveScope(){
  $('discussion').hidden=true;
  if(scopeKey)try{localStorage.setItem(scopeKey,JSON.stringify({coverage:$('coverage').value,outcome:$('outcome').value}));}catch{}
}
async function open(source){
  if(sourceBusy)return;sourceBusy=true;$('sourceFile').disabled=true;
  try{
    await verified(source,work.source_sha256,'Source PDF');
    $('workspace').hidden=false;$('workspace').inert=true;
    const scene=await bridge.open(projectFiles(work,source,rendered,ly),await projectId(work.slug));
    const actual=scene.review.files;
    if(actual.source.sha256!==work.source_sha256||actual.ly.sha256!==work.code_sha256||actual.rendered.sha256!==work.render_sha256)
      throw new Error('The workspace did not open the selected score revision.');
    $('workspace').inert=false;$('sourceRecovery').hidden=true;$('reportForm').hidden=false;
    syncScope();
    if(!scopeListener){
      $('workspace').contentDocument.addEventListener('score-desk-controls',syncScope);scopeListener=true;
    }
    status('Compare the printed source with the transcription, mark findings, then record your coverage. Saved drafts stay on this device.');
  }catch(error){$('workspace').hidden=true;$('sourceRecovery').hidden=false;$('sourceError').textContent=error.message;status('The score has not opened. Select the recorded source PDF to retry.');}
  finally{sourceBusy=false;$('sourceFile').disabled=false;}
}
$('sourceFile').addEventListener('change',()=>{const file=$('sourceFile').files[0];if(file)void open(file);});
$('backup').onclick=()=>bridge.backup();
$('reportForm').onsubmit=async event=>{
  event.preventDefault();if(exportBusy)return;exportBusy=true;
  const button=$('reportForm').querySelector('button[type=submit]');button.disabled=true;$('discussion').hidden=true;
  try{
    const report=await makeReport(work,await bridge.capture(),$('coverage').value,$('outcome').value);
    download(new Blob([JSON.stringify(report,null,2)+'\n'],{type:'application/json'}),work.slug+'-opus-review.json');
    $('discussion').href=reportDiscussion(report);$('discussion').hidden=false;
    status('Report downloaded. Save a review backup to retain the PDFs and history, then post both to OPUS. Nothing has been submitted yet.');
  }catch(error){status(error.message);}
  finally{exportBusy=false;button.disabled=false;}
};
for(const field of ['coverage','outcome'])$(field).addEventListener('input',saveScope);
async function start(){
  const index=JSON.parse(await (await fetchBounded(new URL('works.json',import.meta.url),{limit:2*1024*1024})).text());
  if(index.schema!==1||!Array.isArray(index.scores))throw new Error('The review score list is unavailable. Rebuild the site.');
  if(!slug){
    status('Choose a reconciled score to compare in ScoreBrush. Reviews save locally until you export and submit them.');
    $('queue').hidden=false;
    for(const entry of index.scores){
      validateWork(entry);const a=document.createElement('a'),li=document.createElement('li');
      a.href='?'+new URLSearchParams({piece:entry.slug});a.textContent=entry.composer+' — '+entry.title;
      li.append(a);$('queue').append(li);
    }
    if(!index.scores.length)status('No reconciled scores are ready for human review.');
    return;
  }
  work=validateWork(index.scores.find(s=>s.slug===slug));
  $('workTitle').textContent=work.composer+' — '+work.title;
  document.title=work.title+' — Human review — OPUS';
  $('sourceLink').href=work.source_pdf;
  const frame=$('workspace');
  const loaded=new Promise((resolve,reject)=>{
    const timer=setTimeout(()=>reject(new Error('ScoreBrush took too long to load. Keep your backups and try again.')),45000);
    frame.onload=()=>{clearTimeout(timer);resolve();};
    frame.onerror=()=>{clearTimeout(timer);reject(new Error('ScoreBrush could not load.'));};
  });
  frame.src='scorebrush/';
  status('Loading ScoreBrush and the selected score…');
  [rendered,ly]=await Promise.all([
    fetchBounded(new URL(work.pdf_url,root)).then(b=>verified(b,work.render_sha256,'Rendered PDF')),
    fetchBounded(new URL(work.lilypond_url,root)).then(b=>verified(b,work.code_sha256,'LilyPond file')),loaded
  ]);
  await loaded;
  bridge=frame.contentWindow.opusScoreBrush;
  if(!bridge)throw new Error('The ScoreBrush adapter could not load. Keep your backups and reload the page.');
  await bridge.ready;
  try{
    const source=await fetchBounded(work.source_pdf);
    await open(source);
  }catch{
    $('sourceRecovery').hidden=false;
    $('sourceError').textContent='The library did not allow an automatic download. Download the original from the link and select it here. Its exact edition is checked before opening.';
    status('The transcription is ready. Select the original source PDF to begin.');
  }
}
void start().catch(error=>{status(error.message);});
