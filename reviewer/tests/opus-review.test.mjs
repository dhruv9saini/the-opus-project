import test from 'node:test';
import assert from 'node:assert/strict';
import {digest,fetchBounded,verified,validateWork,projectId,projectFiles,makeReport,reportDiscussion} from '../opus-review.mjs';
const blob=value=>new Blob([value]);
async function fixture(){
  const files=projectFiles({slug:'synthetic'},blob('source'),blob('render'),blob('code'));
  const work={slug:'synthetic',title:'Geometry fixture',composer:'Test',step:3,
    source_pdf:'https://library.example/source.pdf',lilypond_url:'pieces/synthetic/score.ly',
    pdf_url:'pieces/synthetic/score.pdf',source_sha256:await digest(files.source.blob),
    code_sha256:await digest(files.ly.blob),render_sha256:await digest(files.rendered.blob),revision:'a'.repeat(40)};
  return {work,scene:{files,projectId:await projectId(work.slug),workspaceId:'fixture',revisionId:'review-1',
    review:{snapshotId:'snapshot',findings:[{id:'f1',comment:'Check bar 2'}]},returned:null,completions:[]}};
}
test('reject a substituted source or changed deployed file before opening',async()=>{
  await assert.rejects(verified(blob('different'),await digest(blob('source')),'Source PDF'),/does not match/);
});
test('bounded streaming rejects a response that lies about its content length',async()=>{
  let cancelled=false;
  const stream=new ReadableStream({start(c){c.enqueue(new Uint8Array(12));},cancel(){cancelled=true;}});
  await assert.rejects(fetchBounded('https://library.example/',{limit:8,fetcher:async(_url,options)=>{
    assert.equal(options.credentials,'omit');return new Response(stream,{headers:{'content-length':'1'}});
  }}),/size limit/);
  assert.equal(cancelled,true);
});
test('review identity rejects arbitrary project paths, credentials, schemes and unreconciled work',async()=>{
  const {work}=await fixture();
  for(const mutation of [{slug:'../escape'},{pdf_url:'https://other.example/file.pdf'},
    {source_pdf:'http://library.example/source.pdf'},{source_pdf:'https://user:pass@library.example/file.pdf'},
    {step:2},{revision:'not-a-revision'}])
    assert.throws(()=>validateWork({...work,...mutation}));
});
test('reports require stated coverage and never record human verification',async()=>{
  const {work,scene}=await fixture();
  await assert.rejects(makeReport(work,scene,'','partial'),/pages and passages/);
  const report=await makeReport(work,scene,'Page 1, systems 1–2','partial');
  assert.equal(report.verified_by,null);assert.equal(report.revision,work.revision);
  assert.equal(report.revision_kind,'published-build');assert.equal(report.findings[0].comment,'Check bar 2');
  const discussion=new URL(reportDiscussion(report));
  assert.equal(discussion.origin,'https://github.com');
  assert.match(discussion.searchParams.get('body'),/Page 1, systems 1–2/);
});
test('returned local candidate reports use its real code and render hashes',async()=>{
  const {work,scene}=await fixture();
  scene.files.ly.blob=blob('returned changed code');scene.files.rendered.blob=blob('returned new PDF');
  const report=await makeReport(work,scene,'Page 1','corrections-needed');
  assert.equal(report.revision,null);assert.equal(report.baseline_revision,work.revision);
  assert.equal(report.revision_kind,'local-candidate');
  assert.equal(report.code_sha256,await digest(blob('returned changed code')));
  assert.equal(report.render_sha256,await digest(blob('returned new PDF')));
});
test('a different project open in ScoreBrush cannot be reported as the selected work',async()=>{
  const {work,scene}=await fixture();scene.projectId=await projectId('another-work');
  await assert.rejects(makeReport(work,scene,'All pages','no-errors-found'),/different OPUS work/);
});
