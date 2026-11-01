// ScoreBrush Web adapter. Original OPUS integration code is CC0-1.0;
// the combined app retains ScoreBrush's AGPL-3.0-or-later licensing.
import {opusReviewApi as api,applicationShell,completion} from './scorebrush/app.js';
import {fetchBounded,validateWork,verified,projectId,projectFiles,makeReport,reportDiscussion} from './opus-review.mjs';
const $=id=>document.getElementById(id);
const site=new URL('../',import.meta.url);
const ready=document.body.dataset.ready==='true'?Promise.resolve():
  new Promise(resolve=>document.addEventListener('score-desk-ready',resolve,{once:true}));
let currentWork=null,pending=null,indexPromise=null,selection=0,sourceBusy=false,scopeKey=null,exportBusy=false;
const dialog=$('opusDialog');
const status=text=>{$('opusStatus').textContent=text;};
function download(blob,name){
  const url=URL.createObjectURL(blob),a=document.createElement('a');
  a.href=url;a.download=name;a.click();setTimeout(()=>URL.revokeObjectURL(url),60000);
}
function syncScope(){
  const snapshot=api.status().snapshotId;
  if(!currentWork||!snapshot)return;
  const next='opus-human-review-scope:'+currentWork.slug+':'+snapshot;
  if(next===scopeKey)return;
  scopeKey=next;$('opusCoverage').value='';$('opusOutcome').value='partial';$('opusDiscussion').hidden=true;
  try{
    const saved=JSON.parse(localStorage.getItem(scopeKey));
    if(saved&&typeof saved.coverage==='string'&&saved.coverage.length<=2000&&
      ['partial','corrections-needed','no-errors-found'].includes(saved.outcome)){
      $('opusCoverage').value=saved.coverage;$('opusOutcome').value=saved.outcome;
    }
  }catch{/* Coverage drafting remains usable if preference storage is unavailable. */}
}
function saveScope(){
  $('opusDiscussion').hidden=true;
  if(scopeKey)try{localStorage.setItem(scopeKey,JSON.stringify({coverage:$('opusCoverage').value,outcome:$('opusOutcome').value}));}catch{}
}
async function openNewProject(){
  if(api.status().busy)return;
  dialog.close();$('workspaceDialog').close();
  await applicationShell.execute('files');
  $('workspaceTitle').textContent='New ScoreBrush project';
  $('filesPanel').open=true;
  for(const role of ['source','rendered','ly'])$(role+'File').value='';
  $('fileSetupStatus').hidden=true;$('sourceFile').focus();
}
api.openWebProject=()=>void openNewProject();
$('chooseFolderInSetup').onclick=()=>void openNewProject();
$('load').onclick=async()=>{
  if(api.status().busy)return;
  $('fileSetupStatus').hidden=true;
  try{
    const files={};
    for(const role of ['source','rendered','ly']){
      const file=$(role+'File').files[0];
      if(!file)throw new Error('Choose the source PDF, transcription PDF, and LilyPond file.');
      if(!file.size||file.size>100*1024*1024)throw new Error('Each file must be between 1 byte and 100 MB.');
      if(role==='ly'&&!file.name.toLowerCase().endsWith('.ly'))throw new Error('The LilyPond file must end in .ly.');
      files[role]={name:file.name,blob:file};
    }
    $('workspaceDialog').close();
    await api.openFiles(files,{newProject:true});await api.flush();
    currentWork=null;scopeKey=null;delete document.body.dataset.opusPiece;$('opusReportForm').hidden=true;
    const url=new URL(location.href);url.searchParams.delete('piece');history.replaceState(null,'',url);
    document.title='ScoreBrush Web · The OPUS Project';
    api.message('Project opened. Findings save in this browser; use Save backup to keep a portable copy.');
  }catch(error){$('fileSetupStatus').textContent=error.message;$('fileSetupStatus').hidden=false;api.message(error.message,true,'web-files');}
};
async function scoreIndex(){
  return indexPromise??=fetchBounded(new URL('works.json',import.meta.url),{limit:2*1024*1024})
    .then(b=>b.text()).then(JSON.parse).then(index=>{
      if(index.schema!==1||!Array.isArray(index.scores))throw new Error('The OPUS score list is unavailable.');
      return index.scores.map(validateWork);
    }).catch(error=>{indexPromise=null;throw error;});
}
async function showOpus(){
  if(api.status().busy)return;
  $('workspaceDialog').close();
  if(!dialog.open)dialog.showModal();
  $('opusReportForm').hidden=!currentWork;syncScope();
  status(currentWork?'Reviewing '+currentWork.composer+' — '+currentWork.title+'. Record your coverage here when ready.':'Choose an OPUS score to open, or use New Project for your own files.');
  try{
    const scores=await scoreIndex();
    $('opusQueue').replaceChildren();
    for(const work of scores){
      const item=document.createElement('li'),button=document.createElement('button');
      button.type='button';button.textContent=work.composer+' — '+work.title;
      button.onclick=()=>void selectWork(work);item.append(button);$('opusQueue').append(item);
    }
  }catch(error){status(error.message+' You can still open your own score files or restore a backup.');}
}
async function selectWork(work){
  const token=++selection;pending=null;$('opusSourceRecovery').hidden=true;$('opusReportForm').hidden=true;
  status('Loading '+work.composer+' — '+work.title+'…');
  try{
    const [rendered,ly]=await Promise.all([
      fetchBounded(new URL(work.pdf_url,site)).then(b=>verified(b,work.render_sha256,'Rendered PDF')),
      fetchBounded(new URL(work.lilypond_url,site)).then(b=>verified(b,work.code_sha256,'LilyPond file'))
    ]);
    if(token!==selection||!dialog.open)return;
    pending={work,rendered,ly,token};$('opusSourceLink').href=work.source_pdf;
    try{
      const source=await fetchBounded(work.source_pdf);
      if(token===selection&&dialog.open)await openSource(source,pending);
    }catch{
      if(token!==selection||!dialog.open)return;
      $('opusSourceRecovery').hidden=false;
      $('opusSourceError').textContent='The library blocked automatic downloading. Download the recorded original and select it here; the exact edition is checked.';
      status('The transcription is ready. Select the original source PDF to begin.');
    }
  }catch(error){if(token===selection)status(error.message);}
}
async function openSource(source,target){
  if(sourceBusy||!target||target.token!==selection)return;
  sourceBusy=true;$('opusSourceFile').disabled=true;
  try{
    await verified(source,target.work.source_sha256,'Source PDF');
    if(target.token!==selection||!dialog.open)return;
    await api.openFiles(projectFiles(target.work,source,target.rendered,target.ly),{projectId:await projectId(target.work.slug)});
    await api.flush();
    const scene=api.capture(),actual=scene.review?.files;
    if(!actual||actual.source.sha256!==target.work.source_sha256||actual.ly.sha256!==target.work.code_sha256||
      actual.rendered.sha256!==target.work.render_sha256)throw new Error('The selected work did not open.');
    currentWork=target.work;pending=null;scopeKey=null;syncScope();
    $('opusSourceRecovery').hidden=true;$('opusReportForm').hidden=false;
    const url=new URL(location.href);url.searchParams.set('piece',currentWork.slug);history.replaceState(null,'',url);
    document.title=currentWork.title+' — ScoreBrush Web';document.body.dataset.opusPiece=currentWork.slug;dialog.close();
    api.message('Opened '+currentWork.composer+' — '+currentWork.title+'. Use OPUS scores & report to record coverage and export your review.');
  }catch(error){
    if(target.token!==selection)return;
    $('opusSourceRecovery').hidden=false;$('opusSourceError').textContent=error.message;
    status('The selected score has not opened. Select the recorded source PDF to retry.');
  }finally{sourceBusy=false;$('opusSourceFile').disabled=false;}
}
$('opusSourceFile').onchange=()=>{const file=$('opusSourceFile').files[0];if(file)void openSource(file,pending);};
$('opusClose').onclick=()=>dialog.close();
dialog.addEventListener('close',()=>{selection++;pending=null;});
$('opusBackup').onclick=()=>{dialog.close();completion.open();};
$('opusReportForm').onsubmit=async event=>{
  event.preventDefault();if(exportBusy||!currentWork)return;
  exportBusy=true;const button=$('opusReportForm').querySelector('button[type=submit]');button.disabled=true;$('opusDiscussion').hidden=true;
  try{
    await api.flush();
    const report=await makeReport(currentWork,api.capture(),$('opusCoverage').value,$('opusOutcome').value);
    download(new Blob([JSON.stringify(report,null,2)+'\n'],{type:'application/json'}),currentWork.slug+'-opus-review.json');
    $('opusDiscussion').href=reportDiscussion(report);$('opusDiscussion').hidden=false;
    status('Report downloaded. Save a review backup and attach both to your OPUS discussion. Nothing has been submitted yet.');
  }catch(error){status(error.message);}
  finally{exportBusy=false;button.disabled=false;}
};
for(const field of ['opusCoverage','opusOutcome'])$(field).addEventListener('input',saveScope);
document.addEventListener('score-desk-controls',syncScope);
const actions=document.createElement('div');actions.id='webActions';
const newButton=document.createElement('button');newButton.id='webNewProject';newButton.type='button';newButton.textContent='New project';newButton.onclick=()=>void openNewProject();
const opusButton=document.createElement('button');opusButton.id='opusProject';opusButton.type='button';opusButton.textContent='OPUS scores & report';opusButton.onclick=()=>void showOpus();
const home=document.createElement('a');home.href='../proofread.html';home.textContent='OPUS';
actions.append(newButton,opusButton,home);$('appMenu').append(actions);
const about=document.createElement('p');about.className='hint';about.textContent='ScoreBrush Web is an OPUS browser port of ScoreBrush 0.1.1. ';
const source=document.createElement('a');source.href='https://github.com/the-opus-project/the-opus-project.github.io/tree/codex/scorebrush-human-review/reviewer';source.target='_blank';source.rel='noopener noreferrer';source.textContent='Web app source and licensing';
about.append(source);$('aboutDialog').append(about);
await ready;
document.body.dataset.webReady='true';
const slug=new URLSearchParams(location.search).get('piece');
if(slug){
  await showOpus();
  try{const work=(await scoreIndex()).find(w=>w.slug===slug);if(!work)throw new Error('This OPUS work is unavailable for human review.');await selectWork(work);}
  catch(error){status(error.message);}
}
