const express = require('express');
const app = express();
const root = __dirname;
app.use(express.static(root));
const port = 8080;

app.use(express.urlencoded({ extended: true })); // req.body
app.set('view engine','pug');
app.set('views',root);

var db = require('monk')('127.0.0.1:27017/my_site');
var pages = db.get('pages'); 

var md = require('markdown-it')({html:true});


// PAGES
app.get('/page/:name',(req,res)=>{
	var name = req.params.name;
	pages.findOne({'name':name}).then(page=>{
		res.render('page',{'name':page.name,'content':md.render(page.content)});
	});
});
app.get('/pageedit/:name',(req,res)=>{
	var name = req.params.name;
	pages.findOne({'name':name}).then(page=>{
		res.render('pageedit',page);
	});
});
app.post('/pageedit',(req,res)=>{
	var page = req.body;
	pages.update({'name':page.name},{$set:page}).then(()=>{
		res.redirect('/page/'+page.name);
	});
});
app.get('/pages',(req,res)=>{
	pages.find().then(pages=>{
		res.render('pages',{'pages':pages});
	});
});
app.get('/pagenew',(req,res)=>{
	res.render('pagenew');
});
app.post('/pagenew',(req,res)=>{
	var page = req.body;
	pages.insert(page).then(()=>{
		res.redirect('/page/'+page.name);
	});
});
app.get('/pagedel/:name',(req,res)=>{
	var name = req.params.name;
	pages.remove({'name':name}).then(()=>{
		res.redirect('/pages');
	});
});
app.get('/',(req,res)=>{
	res.redirect('/pages');
});

// FILES
var fs     = require('fs');
var multer = require('multer');
var store  = multer.diskStorage({
  destination: function (req, file, cb) { cb(null, root) },
  filename: function (req, file, cb) { cb(null, file.originalname) }
});
var upload = multer({storage:store});

app.get('/files',(req,res)=>{
	var files = fs.readdirSync(root);
	res.render('files',{'files':files});
});
app.get('/upload',(req,res)=>{
	res.render('upload');
});
app.post('/upload',upload.single('file'),(req,res)=>{
	res.redirect('/files');
});

// SCRIPTS
const { exec } = require('child_process');
app.get('/config',(req,res)=>{
	res.render('config');
});
app.post('/config',(req,res)=>{
	var logo   = req.body.logo;
	var header = req.body.header;
	var footer = req.body.footer;
	exec(root+'/config.sh +logo+ +header+ +footer+');
	res.redirect('/');
});

app.listen(port, () => {
  console.log(`Server listening at http://localhost:${port}`);
});
