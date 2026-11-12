// OPUS integration code; CC0-1.0. ScoreBrush retains its separate AGPL license.
export const REPOSITORY='https://github.com/the-opus-project/the-opus-project.github.io';
export const MAX_FILE=100*1024*1024;
const HASH=/^[a-f0-9]{64}$/;
const SLUG=/^[a-z0-9]+(?:-[a-z0-9]+)*$/;
export async function digest(blob){
  return Array.from(new Uint8Array(await crypto.subtle.digest('SHA-256',await blob.arrayBuffer())),n=>n.toString(16).padStart(2,'0')).join('');
}
export async function fetchBounded(url,{limit=MAX_FILE,fetcher=fetch}={}){
  const response=await fetcher(url,{credentials:'omit',cache:'no-store',signal:AbortSignal.timeout(45000)});
  if(!response.ok)throw new Error('Download failed ('+response.status+').');
  if(Number(response.headers.get('content-length'))>limit)throw new Error('File exceeds the review size limit.');
  const reader=response.body?.getReader();
  if(!reader)throw new Error('This browser cannot read the download safely.');
  const chunks=[];let size=0;
  try{
    for(;;){const {done,value}=await reader.read();if(done)break;size+=value.byteLength;
      if(size>limit)throw new Error('File exceeds the review size limit.');chunks.push(value);}
  }catch(error){await reader.cancel().catch(()=>{});throw error;}
  return new Blob(chunks,{type:response.headers.get('content-type')||'application/octet-stream'});
}
export function validateWork(value){
  if(!value||typeof value!=='object'||typeof value.slug!=='string'||value.slug.length>160||!SLUG.test(value.slug)||
    value.step!==3||!['source_sha256','code_sha256','render_sha256'].every(k=>HASH.test(value[k]))||
    !['title','composer','source_pdf'].every(k=>typeof value[k]==='string'&&value[k].length>0&&value[k].length<8000)||
    value.lilypond_url!=='pieces/'+value.slug+'/score.ly'||value.pdf_url!=='pieces/'+value.slug+'/score.pdf'||
    value.revision!==null&&!/^[a-f0-9]{40,64}$/.test(value.revision))
    throw new Error('The selected work has an invalid review identity. Rebuild the site.');
  const source=new URL(value.source_pdf);
  if(source.protocol!=='https:'||source.username||source.password)throw new Error('The source PDF must use a public HTTPS URL.');
  return value;
}
export async function verified(blob,expected,label){
  if(!blob||!Number.isSafeInteger(blob.size)||blob.size<1||blob.size>MAX_FILE)throw new Error(label+' is empty or too large.');
  if(await digest(blob)!==expected)throw new Error(label+' does not match the recorded revision. Keep your review; reload the score list or select the exact original file.');
  return blob;
}
export async function projectId(slug){
  const hash=await digest(new Blob(['OPUS human review:'+slug]));
  // A stable UUID isolates each work even when two works contain identical files.
  return hash.slice(0,8)+'-'+hash.slice(8,12)+'-5'+hash.slice(13,16)+'-a'+hash.slice(17,20)+'-'+hash.slice(20,32);
}
export function projectFiles(work,source,rendered,ly){
  return {source:{name:'source-original.pdf',blob:source},rendered:{name:work.slug+'.pdf',blob:rendered},ly:{name:'score.ly',blob:ly}};
}
export async function makeReport(work,scene,coverage,outcome){
  validateWork(work);
  if(typeof coverage!=='string'||!coverage.trim()||coverage.length>2000)throw new Error('State the pages and passages you checked.');
  if(!['partial','corrections-needed','no-errors-found'].includes(outcome))throw new Error('Choose a review result.');
  // Export the actual workspace revision, including returned AI revisions.
  // A later PDF/code revision must never inherit the initial build's hashes.
  const {review,files}=scene;
  if(!review||!files)throw new Error('Open the selected OPUS score before exporting a report.');
  const source_sha256=await digest(files.source.blob),code_sha256=await digest(files.ly.blob),render_sha256=await digest(files.rendered.blob);
  if(source_sha256!==work.source_sha256||scene.projectId!==await projectId(work.slug))
    throw new Error('The open workspace belongs to a different OPUS work. Reopen the selected score before exporting.');
  const builtRevision=code_sha256===work.code_sha256&&render_sha256===work.render_sha256;
  return {schema:'opus-human-review',version:1,piece:work.slug,title:work.title,composer:work.composer,
    created_at:new Date().toISOString(),coverage:coverage.trim(),outcome,verified_by:null,
    revision:builtRevision?work.revision:null,baseline_revision:work.revision,
    source_pdf:work.source_pdf,source_sha256,code_sha256,render_sha256,
    snapshot_id:review.snapshotId,workspace_id:scene.workspaceId,review_revision_id:scene.revisionId,
    revision_kind:builtRevision?'published-build':'local-candidate',
    findings:structuredClone(review.findings),returned_review:structuredClone(scene.returned??null),
    completions:structuredClone(scene.completions??[])};
}
export function reportDiscussion(report){
  const body=[
    'Work: '+report.composer+' — '+report.title,
    'Result: '+report.outcome,'Pages and passages checked: '+report.coverage,
    'Revision: '+(report.revision||'Local candidate; see the attached report and review backup'),
    'Source SHA-256: '+report.source_sha256,'LilyPond SHA-256: '+report.code_sha256,
    'Rendered PDF SHA-256: '+report.render_sha256,
    'Findings retained in report: '+report.findings.length,
    'Attach the downloaded OPUS report and ScoreBrush review backup here.',
    'This is a review report; it does not record project verification.'
  ].join('\n');
  return REPOSITORY+'/discussions/new?'+new URLSearchParams({category:'general',title:'Proofreading: '+report.composer+' — '+report.title,body});
}
