fetch = (req_url,callback)->
	http = require "http"
	url = require "url"
	$ = require "jquery"

	parsed_url = url.parse(req_url)
	client = http.createClient(80,parsed_url.hostname)
	request = client.request('GET',parsed_url.pathname,{'host':parsed_url.hostname})
	request.end()

	request.on('response',(response)=>
		response.setEncoding "utf-8"
		html = ""
		response.on('data',(data)=>
			html += data
		)
		response.on('end',()=>
			console.log("end #{req_url}")
			result = {}
			result.url = req_url
			result.owner = $(html).find("#community_prof_frm2 .r p:last-child strong").text()
			result.level = $(html).find("#cbox_profile table table tr:first-child td:nth-child(2) strong:first-child").text()
			result.members = $(html).find("#cbox_profile table table tr:nth-child(2) td:nth-child(2) strong:first-child").text()
			result.totals = $(html).find("#cbox_profile table table tr:nth-child(6) td:nth-child(2) strong:first-child").text()
			result.prof_bonus = $(html).find("#community_description .subbox .cnt2").text().match(/風来|シレン|TM|フェイ/g)?.length || 0
			result.news_bonus = $(html).find("#news .cnt2").text().match(/風来|シレン|フェイ|TM/g)?.length || 0
			callback(result)
		)
	)

marge = (obj)=>
	datas.results.push(obj)
	if datas.results.length == url_list.length
		write.write(JSON.stringify(datas))
		console.log("complete task")


datas = {results:[]}
fs = require "fs"
read = fs.createReadStream("./entry.txt",{encoding:"utf8"})
write = fs.createWriteStream("../bin/entry.json",{encoding:"utf8"})
url_list = null
read.on("data",(line)=>
	url_list = line.match(/co[0-9]+/g)
).on("end",()=>
	fetch "http://com.nicovideo.jp/community/"+req_url,marge for req_url in url_list
)

