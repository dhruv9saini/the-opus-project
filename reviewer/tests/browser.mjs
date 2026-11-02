// Browser acceptance with synthetic PDFs and disposable storage only.
import {chromium} from 'playwright-core';
import assert from 'node:assert/strict';
import {createServer} from 'node:http';
import {readFile,stat,mkdir,writeFile} from 'node:fs/promises';
import {resolve,relative,extname,dirname} from 'node:path';
import {fileURLToPath} from 'node:url';
import {createRequire} from 'node:module';
import {createHash} from 'node:crypto';
const require=createRequire(import.meta.url);
const {PDFDocument,StandardFonts}=require('../scorebrush/vendor/pdf-lib.min.js');
const sourceRoot=resolve(dirname(fileURLToPath(import.meta.url)),'../..');
const root=resolve(process.env.OPUS_TEST_SITE||sourceRoot);
const prefix='/nested-opus/';
const sha=bytes=>createHash('sha256').update(bytes).digest('hex');
async function pdf(label){
  const doc=await PDFDocument.create(),font=await doc.embedFont(StandardFonts.Helvetica),p=doc.addPage([612,792]);
  p.drawText('SYNTHETIC '+label+' - interface geometry, no musical transcription.',{x:30,y:740,size:12,font});
  for(let row=0;row<5;row++)p.drawLine({start:{x:40,y:600-row*8},end:{x:560,y:600-row*8},thickness:1});
  return Buffer.from(await doc.save());
}
const source=await pdf('SOURCE'),rendered=await pdf('RENDERED');
const code=Buffer.from('% Synthetic interface test. No musical transcription.\n');
const work={slug:'synthetic',title:'Synthetic reviewer test',composer:'Test fixtures',step:3,
  source_pdf:'https://library.example/source.pdf',source_sha256:sha(source),code_sha256:sha(code),render_sha256:sha(rendered),
  lilypond_url:'pieces/synthetic/score.ly',pdf_url:'pieces/synthetic/score.pdf',revision:'a'.repeat(40)};
const other={...work,slug:'other',lilypond_url:'pieces/other/score.ly',pdf_url:'pieces/other/score.pdf'};
const mime={'.html':'text/html','.mjs':'text/javascript','.js':'text/javascript','.css':'text/css','.json':'application/json',
  '.pdf':'application/pdf','.wasm':'application/wasm','.svg':'image/svg+xml','.png':'image/png','.ico':'image/x-icon','.woff2':'font/woff2'};
const server=createServer(async(req,res)=>{
  try{
    const url=new URL(req.url,'http://127.0.0.1');
    if(!url.pathname.startsWith(prefix)){res.writeHead(404).end();return;}
    const name=decodeURIComponent(url.pathname.slice(prefix.length));
    if(name==='reviewer/works.json'){res.setHeader('Content-Type','application/json');res.end(JSON.stringify({schema:1,scores:[work,other]}));return;}
    if(name==='catalog.json'||name==='reviews.json'){res.setHeader('Content-Type','application/json');res.end(JSON.stringify({schema:1,scores:name==='catalog.json'?[work]:[]}));return;}
    if(/^pieces\/(synthetic|other)\/score\.(pdf|ly)$/.test(name)){
      res.setHeader('Content-Type',name.endsWith('.pdf')?'application/pdf':'text/plain');res.end(name.endsWith('.pdf')?rendered:code);return;
    }
    let path=resolve(root,name||'.');
    if(relative(root,path).startsWith('..')){res.writeHead(403).end();return;}
    if((await stat(path)).isDirectory())path=resolve(path,'index.html');
    res.writeHead(200,{'Content-Type':mime[extname(path)]||'application/octet-stream','Cache-Control':'no-store'});
    res.end(await readFile(path));
  }catch{res.writeHead(404).end();}
});
await new Promise(r=>server.listen(0,'127.0.0.1',r));
const base='http://127.0.0.1:'+server.address().port+prefix;
let browser;
const checks=[],errors=[];
async function apiFor(page){
  await page.waitForFunction(()=>document.body.dataset.webReady==='true',{timeout:45000});
  await page.evaluate(async()=>{window.__testScorebrushApi=(await import(new URL('./scorebrush/app.js',location.href).href)).opusReviewApi;});
}
const capture=async page=>page.evaluate(async()=>{await window.__testScorebrushApi.flush();return window.__testScorebrushApi.capture();});
const idle=page=>page.waitForFunction(()=>{const s=window.__testScorebrushApi.status();return !s.busy&&Boolean(s.snapshotId);});
const opusOpened=(page,piece)=>page.waitForFunction(piece=>document.body.dataset.opusPiece===piece,piece,{timeout:45000});
async function selectFiles(page){
  for(const [role,name,buffer,mimeType] of [
    ['source','source.pdf',source,'application/pdf'],['rendered','rendered.pdf',rendered,'application/pdf'],
    ['ly','score.ly',code,'text/plain']
  ])await page.locator('#'+role+'File').setInputFiles({name,mimeType,buffer});
  await page.locator('#load').click();await idle(page);
}

const pass=name=>{checks.push(name);console.log('PASS '+name);};
const evidence=process.env.OPUS_TEST_EVIDENCE;
try{
  browser=await chromium.launch({headless:true,executablePath:process.env.SCOREBRUSH_BROWSER||'/run/current-system/sw/bin/chromium'});
  const links=await browser.newContext();
  const proofread=await links.newPage();
  await proofread.route('https://giscus.app/**',route=>route.abort());
  await proofread.goto(base+'proofread.html?piece=synthetic');
  await proofread.locator('[data-compare]').waitFor({state:'visible'});
  assert.equal(await proofread.locator('[data-scorebrush]').first().getAttribute('href'),'reviewer/?piece=synthetic');
  assert.equal(await proofread.locator('[data-score-desk]').first().getAttribute('href'),'contributor/?piece=synthetic');
  await links.close();
  pass('proofreading routes the selected work to both standalone ScoreBrush and shared Score Desk');
  const context=await browser.newContext({viewport:{width:1440,height:1000},acceptDownloads:true});
  const own=await context.newPage();
  await own.goto(base+'reviewer/');await apiFor(own);
  assert.equal(await own.locator('iframe').count(),0);
  assert.match(await own.title(),/ScoreBrush Web/);
  await own.locator('#chooseFolderInSetup').click();
  await selectFiles(own);
  const firstOwn=await capture(own);assert(firstOwn.projectId);
  await own.locator('#newFinding').click();await own.locator('#comment').fill('Private standalone project finding.');
  await own.locator('#saveFinding').click();assert.equal((await capture(own)).review.findings.length,1);
  pass('standalone ScoreBrush opens ordinary PDF/LilyPond files without an OPUS work or iframe');
  await own.locator('#appMenuFile').click();
  await own.locator('[data-command="new-project"]').click();
  await selectFiles(own);
  const secondOwn=await capture(own);
  assert.notEqual(secondOwn.projectId,firstOwn.projectId);assert.equal(secondOwn.review.findings.length,0);
  pass('File > New Project creates a separate review even for identical files');
  await own.close();
  const page=await context.newPage();
  page.on('pageerror',e=>errors.push(e.message));
  await page.route('https://library.example/**',route=>route.fulfill({body:source,contentType:'application/pdf'}));
  await page.goto(base+'reviewer/?piece=synthetic');
  await apiFor(page);await opusOpened(page,'synthetic');
  assert.equal(await page.locator('iframe').count(),0);
  let scene=await capture(page);
  assert.equal(scene.review.files.source.sha256,work.source_sha256);
  assert.equal(scene.review.files.ly.sha256,work.code_sha256);
  pass('selected OPUS work opens with exact source, PDF and LilyPond');
  const frame=page;
  await frame.locator('#newFinding').click();
  await frame.locator('#comment').fill('Synthetic finding: inspect this passage.');
  await frame.locator('#saveFinding').click();
  scene=await capture(page);
  assert.equal(scene.review.findings.length,1);assert.match(scene.review.findings[0].comment,/Synthetic finding/);
  pass('text finding is saved through the released ScoreBrush UI');
  await frame.locator('#newFinding').click();
  await frame.locator('#draw').click();
  const overlay=await frame.locator('#overlay').boundingBox();
  assert(overlay&&overlay.width>100&&overlay.height>100);
  const x=overlay.x+Math.min(overlay.width/2,200),y=overlay.y+Math.min(overlay.height/2,250);
  await page.mouse.move(x,y);await page.mouse.down();await page.mouse.move(x+35,y+3,{steps:6});await page.mouse.up();
  await frame.locator('#comment').fill('Synthetic drawn finding.');
  await frame.locator('#saveFinding').click();
  scene=await capture(page);
  assert.equal(scene.review.findings.length,2);assert(scene.review.findings.some(f=>f.strokes.length>0));
  pass('a drawn mark and its comment survive the normal save flow');
  await page.locator('#opusProject').click();
  await page.locator('#opusCoverage').fill('Page 1, all synthetic systems');
  await page.locator('#opusOutcome').selectOption('corrections-needed');
  const reportDownload=page.waitForEvent('download');
  await page.locator('#opusReportForm button[type=submit]').click();
  const reportFile=await reportDownload;
  const report=JSON.parse(await readFile(await reportFile.path(),'utf8'));
  assert.equal(report.verified_by,null);assert.equal(report.findings.length,2);
  assert.equal(report.code_sha256,work.code_sha256);assert.equal(report.coverage,'Page 1, all synthetic systems');
  assert.match(await page.locator('#opusDiscussion').getAttribute('href'),/the-opus-project/);
  pass('downloaded OPUS report retains exact identities, coverage and findings without publishing');
  const backupDownload=page.waitForEvent('download',{timeout:45000});
  await page.locator('#opusBackup').click();
  const backup=await backupDownload;const zipBytes=await readFile(await backup.path());
  assert.equal(zipBytes.readUInt32LE(0),0x04034b50);
  await frame.locator('#closeFinish').click();
  pass('ScoreBrush saves a real portable review backup ZIP');
  const restoreContext=await browser.newContext({viewport:{width:1440,height:1000}});
  const restorePage=await restoreContext.newPage();
  await restorePage.goto(base+'reviewer/');await apiFor(restorePage);
  await restorePage.locator('#packageFile').setInputFiles({name:'scorebrush-backup.zip',mimeType:'application/zip',buffer:zipBytes});
  await idle(restorePage);
  const independent=await capture(restorePage);
  assert.equal(independent.review.files.source.sha256,work.source_sha256);
  assert.equal(independent.review.files.rendered.sha256,work.render_sha256);
  assert.equal(independent.review.files.ly.sha256,work.code_sha256);
  assert.equal(independent.review.findings[0].comment,scene.review.findings[0].comment);
  assert.deepEqual(independent.review.findings[1].strokes,scene.review.findings[1].strokes);
  await restoreContext.close();
  pass('backup independently restores file identities, findings and strokes in a fresh profile');

  await page.reload();await apiFor(page);await opusOpened(page,'synthetic');
  await page.locator('#opusProject').click();
  scene=await capture(page);assert.equal(scene.review.findings.length,2);assert(scene.review.findings.some(f=>f.strokes.length));
  assert.equal(await page.locator('#opusCoverage').inputValue(),'Page 1, all synthetic systems');
  assert.equal(await page.locator('#opusOutcome').inputValue(),'corrections-needed');
  pass('reload resumes both findings and drawn geometry');
  const fallback=await context.newPage();
  await fallback.route('https://library.example/**',route=>route.abort('failed'));
  await fallback.goto(base+'reviewer/?piece=other');
  await apiFor(fallback);await fallback.waitForSelector('#opusSourceRecovery:not([hidden])',{timeout:45000});
  const previousSnapshot=(await capture(fallback)).review.snapshotId;
  await fallback.locator('#opusSourceFile').setInputFiles({name:'wrong.pdf',mimeType:'application/pdf',buffer:Buffer.from('wrong edition')});
  await fallback.waitForFunction(()=>document.getElementById('opusSourceError').textContent.includes('does not match'));
  assert.equal((await capture(fallback)).review.snapshotId,previousSnapshot);
  await fallback.locator('#opusSourceFile').setInputFiles({name:'source.pdf',mimeType:'application/pdf',buffer:source});
  await opusOpened(fallback,'other');
  const fresh=await capture(fallback);
  assert.equal(fresh.review.findings.length,0);assert.notEqual(fresh.projectId,scene.projectId);
  assert.equal((await capture(page)).review.findings.length,2);
  pass('blocked download accepts only the exact source and isolates byte-identical works');
  const tampered=await context.newPage();
  await tampered.route('**/pieces/synthetic/score.ly',route=>route.fulfill({body:'changed deployed code',contentType:'text/plain'}));
  await tampered.goto(base+'reviewer/?piece=synthetic');
  await tampered.waitForFunction(()=>document.getElementById('opusStatus').textContent.includes('does not match'));
  assert.equal(await tampered.locator('#opusReportForm').isVisible(),false);
  assert.equal(await tampered.locator('#opusDialog').isVisible(),true);
  assert.equal(await tampered.locator('iframe').count(),0);
  pass('changed deployed LilyPond is rejected before opening a review');
  const restored=await context.newPage();
  await restored.route('https://library.example/**',route=>route.fulfill({body:source,contentType:'application/pdf'}));
  await restored.goto(base+'reviewer/?piece=synthetic');
  await apiFor(restored);await opusOpened(restored,'synthetic');
  const restoredFrame=restored;
  await restored.locator('#opusProject').click();
  const restoredDownload=restored.waitForEvent('download',{timeout:45000});
  await restored.locator('#opusBackup').click();await restoredDownload;await restoredFrame.locator('#closeFinish').click();
  if(evidence){await mkdir(evidence,{recursive:true});await restored.screenshot({path:resolve(evidence,'scorebrush-human-review.png'),fullPage:true});}
  assert.deepEqual(errors,[]);
  pass('subpath-hosted workspace completes without browser exceptions');
  await context.close();
  if(evidence)await writeFile(resolve(evidence,'browser-acceptance.json'),JSON.stringify({checks,browser:browser.version(),source_sha256:sha(source),render_sha256:sha(rendered)},null,2)+'\n');
  console.log('ALL '+checks.length+' BROWSER CHECKS PASSED');
}catch(error){
  if(evidence&&browser){await mkdir(evidence,{recursive:true});for(const c of browser.contexts())for(const p of c.pages())await p.screenshot({path:resolve(evidence,'failure-'+Date.now()+'.png')}).catch(()=>{});}
  throw error;
}finally{await browser?.close();await new Promise(r=>server.close(r));}
