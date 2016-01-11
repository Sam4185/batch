@setlocal enableextensions & python -x "%~f0" %* & goto :EOF
# -*- coding: utf-8 -*-

from __future__ import print_function
# import os
import sys
import inspect
import jieba
import jieba.analyse
import urllib
from optparse import OptionParser


importantPhrases = None
ignoresPhrases = None


def warning_item(*objs):
	for obj in objs:
		if isinstance(obj,unicode): obj=unicode(obj).encode(sys.stderr.encoding,'replace')
		print(obj,file=sys.stderr, end=" ")


def warning(*objs):
	for obj in objs: warning_item(obj)
	print("",file=sys.stderr)


def lineno():
	"""Returns the current line number in our program."""
	return inspect.currentframe().f_back.f_lineno


def tag2titles_add(db,tags,title):
	for tag in tags:
		if tag not in db: db[tag] = [title]
		else: db[tag].append(title)
		
		
def tag2titles_dump(db):
	for tag in db:
		# warning("===",tag,"===")
		print("===",tag.encode("utf-8"),"===")
		for title in db[tag]:
			# warning(title)
			print(title.encode("utf-8"))

			
def calculate(db):
	rankingTags = {}
	for tag in db:
		try: rankingTags[len(db[tag])].append(tag)
		except: rankingTags[len(db[tag])] = [tag]
	
	return rankingTags
	

def tag2titles_sorted_dump(db):
	import hashlib
	
	rankingTags = calculate(db)
	# calculate_dump(rank)
	# for ranking in sorted(rank,reverse=1):
	for ranking in sorted(rankingTags):
		for tag in sorted(rankingTags[ranking]):
			print("===",tag.encode("utf-8"),"===")
			# print("===",tag.encode("utf-8"),hashlib.md5(tag.encode("utf-8")).hexdigest(),"===")
			for title in db[tag]:
				# warning(data)
				print(title.encode("utf-8"))
	
	
def tag2titles_sorted_dump(db):
	import hashlib
	
	# for tag in dict.keys():
	for tag in sorted(db.keys()):
		print("===",tag.encode("utf-8"),"===")
		# print("===",tag.encode("utf-8"),hashlib.md5(tag.encode("utf-8")).hexdigest(),"===")
		for title in db[tag]:
			# warning(data)
			print(title.encode("utf-8"))


def countMatchingTags(tags,lastTags):
	count = 0
	for tagX in tags:
		for tagY in lastTags:
			if tagX == tagY: count = count + 1
	return count

			
def tag2titles_reducebytags(db,title2tags):
	tags = sorted(db.keys())
	lastTags = []
	for tag in tags:
		first = True
		for title in db[tag]:
			# if title in title2tags:
				countMatching = countMatchingTags(title2tags[title],lastTags)
				percent = countMatching*200/(len(title2tags[title])+len(lastTags))
				# if percent < 50: 
					# if first: 
						# print("===",tag.encode("utf-8"),"(",len(db[tag]),")","===")
						# first = False
					# print(title.encode("utf-8"),percent,"%")
				# if countMatching < 3: print(title.encode("utf-8"),countMatching)
				# print("removing",title.encode("utf-8"))
				if percent >= 50: 
					lastTags = title2tags[title]
					title2tags.pop(title)
				# db[tag].remove(title)

			
def tag2titles_uniqdump(db,title2tags):
	tags = sorted(db.keys())
	# lastTags = []
	for tag in tags:
		first = True
		for title in db[tag]:
			if title in title2tags:
				# countMatching = countMatchingTags(title2tags[title],lastTags)
				# percent = countMatching*200/(len(title2tags[title])+len(lastTags))
				# if percent < 50: 
				if first: 
					print("===",tag.encode("utf-8"),"(",len(db[tag]),")","===")
					first = False
				print(title.encode("utf-8"))
				# if countMatching < 3: print(title.encode("utf-8"),countMatching)
				# print("removing",title.encode("utf-8"))
				# lastTags = title2tags[title]
				title2tags.pop(title)
				# db[tag].remove(title)

				
def tag2titles_uniq_dump(db,title2tags):
	tags = sorted(db.keys())
	lastTags = []
	for tag in tags:
		first = True
		for title in db[tag]:
			if title in title2tags:
				countMatching = countMatchingTags(title2tags[title],lastTags)
				percent = countMatching*200/(len(title2tags[title])+len(lastTags))
				if percent < 50: 
					if first: 
						print("===",tag.encode("utf-8"),"(",len(db[tag]),")","===")
						first = False
					print(title.encode("utf-8"),percent,"%")
				# if countMatching < 3: print(title.encode("utf-8"),countMatching)
				# print("removing",title.encode("utf-8"))
				lastTags = title2tags[title]
				title2tags.pop(title)
				# db[tag].remove(title)


def remove_tail_tags(s):
	index = s.rfind("<")
	if index >= 0: return s[:index]
	return s


def title_dump(title2tags,title2url,title,titletail):
	title_utf8 = title.encode("utf-8")
	tags = title2tags[title]
	tagslable = "<"+"|".join(tags)+">"
	print(remove_tail_tags(title_utf8)+tagslable.encode("utf-8")+titletail)
	print(title2url[title_utf8])	
				
				
def list_merge(mainlist,fromlist):
	for item in fromlist:
		if item not in mainlist:
			mainlist.append(item)
				
				
def ttag_uniq_dump(ttag,ttag2titles,title2tags,title2url,lastTags):
	first = True
	# lastTags = []
	for title in ttag2titles[ttag]:
		if title in title2tags:
			countMatching = countMatchingTags(title2tags[title],lastTags)
			percent = countMatching*200/(len(title2tags[title])+len(lastTags))
			if percent < 50: 
				if first: 
					print("#EXTINF:0, ===",ttag.encode("utf-8"),"===","("+str(len(ttag2titles[ttag]))+")")
					print("https://www.youtube.com/results?q="+urllib.quote(ttag.encode("utf-8")))
					print("")
					first = False
				# title_utf8 = title.encode("utf-8")
				# tags = title2tags[title]
				# tagslable = "<"+"|".join(tags)+">"
				# print(remove_tail_tags(title_utf8)+tagslable.encode("utf-8")+"("+str(percent)+"%)")
				# print(title2url[title_utf8])
				titletail="("+str(percent)+"%)"
				title_dump(title2tags,title2url,title,titletail)
			# lastTags.extend(title2tags[title])
			del lastTags[:]
			list_merge(lastTags,title2tags[title])
			# label = str(len(lastTags))+"lastTags"+",".join(lastTags)
			# print("#EXTINF:0, ===",label.encode("utf-8"),"LV0","===")
			title2tags.pop(title)

	if not first:
		print("")
		print("")	


def tag_lv1_uniq_dump(tag,ttag2titles,tag2ttags,title2tags,title2url,CollectTags):
	lastTags = []
	if tag in tag2ttags:
		for ttag in tag2ttags[tag]:
			ttag_uniq_dump(ttag,ttag2titles,title2tags,title2url,lastTags)
			# label = str(len(lastTags))+"lastTags"+",".join(lastTags)
			# print("#EXTINF:0, ===",label.encode("utf-8"),"LV1","===")
			list_merge(CollectTags,lastTags)
			# for tagx in lastTags:
				# if tagx not in CollectTags: 
					# print("#EXTINF:0, ===",tag.encode("utf-8"),"+",tagx.encode("utf-8"),"LV2","===")
					# CollectTags.append(tagx)
	

def tag_lv2_uniq_dump(tag,ttag2titles,tag2ttags,title2tags,title2url):
	# if tag in tag2ttags:
	# print("#EXTINF:0, ===","tag:",tag.encode("utf-8"),"LV2","===")
	# print("https://www.youtube.com/results?q="+urllib.quote(tag.encode("utf-8")))	
	CollectTags = []
	tag_lv1_uniq_dump(tag,ttag2titles,tag2ttags,title2tags,title2url,CollectTags)
	if tag in CollectTags: CollectTags.remove(tag)

	# label = str(len(CollectTags))+" CollectTags"+",".join(CollectTags)
	# print("#EXTINF:0, ===",label.encode("utf-8"),"LV2","===")
	# print("https://www.youtube.com/results?q="+urllib.quote(tag.encode("utf-8")))	
	# for tagx in CollectTags:
		# print("#EXTINF:0, ===","CollectTags "+str(len(CollectTags))+":",tagx.encode("utf-8"),"LV2","===")
		# print("https://www.youtube.com/results?q="+urllib.quote(tag.encode("utf-8")))
		# tag_lv1_uniq_dump(tagx,ttag2titles,tag2ttags,title2tags,title2url,[])

	
def ttag2titles_uniq_dump_m3u(db,tag2ttags,title2tags,title2url):
	# warning("line,",lineno(),",","tag2titles_uniq_dump_m3u")
	print("#EXTINF:0, === 關鍵字 ===")
	print("https://www.youtube.com/")
	print("")
	
	# for ttag in sorted(db.keys()):
		# warning("Processing",tag)
		# ttag_dump(ttag,db,title2tags,title2url)

	for tag in tag2ttags:
		tag_lv2_uniq_dump(tag,db,tag2ttags,title2tags,title2url)
		
		
def phrases_dump_m3u(phrases,tag2ttags,ttag2titles,title2tags,title2url):
	print("#EXTINF:0, === 重要 ===")
	print("https://www.youtube.com/")
	print("")

	lastTags = []
	for tag in phrases:
		# if tag in tag2ttags:
			# print("#EXTINF:0, === ","["+tag.encode("utf-8")+"]"," ===")
			# print("https://www.youtube.com/results?q="+urllib.quote(tag.encode("utf-8")))
			# for ttag in tag2ttags[tag]:
				# tag_lv1_uniq_dump(ttag,ttag2titles,title2tags,title2url,lastTags)
		if tag in tag2ttags:
			print("#EXTINF:0, ===","["+tag.encode("utf-8")+"]","===")
			print("https://www.youtube.com/results?q="+urllib.quote(tag.encode("utf-8")))		
			tag_lv2_uniq_dump(tag,ttag2titles,tag2ttags,title2tags,title2url)
			
						
def all_dump_m3u(title2tags,title2url):
	print("#EXTINF:0, === 其他 ===")
	print("https://www.youtube.com/")
	print("")
	titles = sorted(title2tags.keys())
	for title in titles:
		title_dump(title2tags,title2url,title,"")
		title2tags.pop(title)
				
						
# def tagx2db_add(db,tag,list,title2tags):
	# i = 0
	# if len(list) <= 1: return
	# for title in list:
		# for tag2 in title2tags[title]:
			# if tag2 is tag: warning(tag,tag2)
			# if tag2 is not tag:
				# for title2 in list[i:]:
					# if tag2 in title2tags[title2]:
						# key = ",".join(sorted([tag,tag2]))
						# if key not in db: db[key] = [title2]
						# elif title2 not in db[key]: db[key].append(title2)
						# if title not in db[key]: db[key].append(title)
		# i = i+1
	
	
def tag2ttags_add(db,tag,ttag):
	# try: 	db[tag].append(ttag)
	# except:	db[tag] = [ttag]
	if tag in db:
		if ttag not in db[tag]:
			db[tag].append(ttag)
	else:
		db[tag] = [ttag]
		
	
def ttag2titles_add(db,tag,title,taillist,title2tags,tag2ttags):
	if len(taillist) == 0: return
	for tag2 in title2tags[title]:
		# if tag2 is tag: warning(tag,tag2)
		if tag2 != tag:
			for title2 in taillist:
				if tag2 in title2tags[title2]:
					ttag = ",".join(sorted([tag,tag2]))
					tag2ttags_add(tag2ttags,tag,ttag)
					tag2ttags_add(tag2ttags,tag2,ttag)
					
					# for tagx in title2tags[title ]: tag2ttags_add(tag2ttags,tagx,ttag)
					# for tagx in title2tags[title2]: tag2ttags_add(tag2ttags,tagx,ttag)					
					
					if ttag not in db: db[ttag] = [title2]
					elif title2 not in db[ttag]: db[ttag].append(title2)
					if title not in db[ttag]: db[ttag].append(title)
	ttag2titles_add(db,tag,taillist[0],taillist[1:],title2tags,tag2ttags)	
	
	
# def tagx2db_dump(db):
	# for tagtag in db:
		# print("===",",".join(tagtag).encode("utf-8"),"===")
		# for data in db[tagtag]:
			# print(data.encode("utf-8"))		

			
def tttag2titles_add(db,tag,title,taillist,title2tags):
	if len(taillist) <= 2: return
	for tag2 in title2tags[title]:
		if tag2 != tag:
			for title2 in taillist:
				if tag2 in title2tags[title2]:
					key = ",".join(sorted([tag,tag2]))
					if key not in db: db[key] = [title2]
					elif title2 not in db[key]: db[key].append(title2)
					if title not in db[key]: db[key].append(title)
	tttag2titles_add(db,tag,taillist[0],taillist[1:],title2tags)	
			
			
def readPhrases(file):
	list = []
	for title in file:
		if len(title) == 0: continue
		if title[0] == '#': continue
		title = title.strip().decode('utf-8')
		list.append(title)
	# warning(list)
	return list

	
def remove_digits(list):
	import re
	ret = list[:]
	for item in list:
		if re.search("\d+",item):
			ret.remove(item)
	return ret
	

def remove_ignored(list):
	ret = list[:]
	for item in list:
		if item in ignoresPhrases:
			ret.remove(item)
	return ret
	
	
def remove_unwanted(list):
	# print(",".join(list).encode("utf-8"))
	list = remove_digits(list)
	# print(",".join(list).encode("utf-8"))
	list = remove_ignored(list)
	# print(",".join(list).encode("utf-8"))
	return list
	
	
def nlptest(file,maxtitle=sys.maxint):
	cnt = 0
	title2tags = {}
	tag2titles = {}
	ttag2titles = {}
	for title in file:
		title = title.decode("utf-8").strip()
		# title = title.decode("utf-8").strip()[11:]
		
		# warning("====\n","[Input]", title)
		# tags = jieba.cut(title, cut_all=True)
		# warning(u"[　全模式]","|".join(words))
		
		# words = jieba.cut(title, cut_all=False)
		# warning(u"[精確模式]","|".join(words))
		# words = jieba.cut_for_search(title)
		
		# warning(u"[搜索模式]","|".join(words))
		tags = jieba.analyse.extract_tags(title, 10)
		# warning(u"[　關鍵詞]","|".join(tags))
		
		tags = remove_unwanted(tags)
		
		title = title+"["+"|".join(tags)+"]"
		title2tags[title]=tags
		tag2titles_add(tag2titles,tags,title)
		# tag2titles_add(tag2titles,tags,title+"|"+"|".join(tags))
		
		cnt = cnt + 1
		if cnt > maxtitle: break
	
	# tagdb_sorted_dump(tag2titles)
	
	for tag in tag2titles:
		ttag2titles_add(ttag2titles, tag, tag2titles[tag][0], tag2titles[tag][1:],title2tags)
		
	# tag2titles_sorted_dump(ttag2titles)
	
	# lastTags = []
	# tag2titles_reducebytags(ttag2titles,title2tags)	
	# tag2titles_uniqdump(ttag2titles,title2tags)

	tag2titles_uniq_dump(ttag2titles,title2tags)

	# for tag in tag2titles:
		# tttag2titles_add(tagx3db, tag, tag2titles[tag][0], tag2titles[tag][1:],title2tags)
		
	# tag2titles_sorted_dump(tagx3db)
	
# def readData(f):
	# table = {}
	# line = f.readline()
	# while line:
		# line = line.strip()
		# if len(line) and line[0] == '#':
			# url = f.readline().strip()
			# if url: table[line]=url
		# line = f.readline()
	# return table
	
	
def readData(f):
	table = {}
	line = f.readline()
	# warning_item("Reading",len(line),line)
	while line:
		line = line.strip()
		# warning("Stripped",len(line),line)
		if len(line) and line[0] == '#':
			url = f.readline().strip()
			if "=== " not in line: #ignore this title line
				if url: table[line]=url
				# warning("Adding",line.strip(),url.strip())
		line = f.readline()
		# warning_item("Reading",len(line),line)
	return table
	
	
def parsem3u(file):
	title2url = readData(file)
	title2tags = {}
	tag2titles = {}
	for title in title2url:
		title = title.decode("utf-8").strip()
		
		tags = jieba.analyse.extract_tags(title, 10)
		tags = remove_unwanted(tags)
		
		title = title
		title2tags[title]=tags
		tag2titles_add(tag2titles,tags,title)	
	
	ttag2titles = {}
	tag2ttags = {}
	for tag in tag2titles:
		ttag2titles_add(ttag2titles, tag, tag2titles[tag][0], tag2titles[tag][1:],title2tags,tag2ttags)	
		
	phrases_dump_m3u(importantPhrases,tag2ttags,ttag2titles,title2tags,title2url)
		
	# warning("line,",lineno(),",","tag2titles_uniq_dump_m3u")
	ttag2titles_uniq_dump_m3u(ttag2titles,tag2ttags,title2tags,title2url)
	
	all_dump_m3u(title2tags,title2url)
	
	
def main():
	global ignoresPhrases, importantPhrases
	
	parser = OptionParser()
	# parser.add_option("-f", "--filename", metavar="FILE", help="write output to FILE")
	parser.add_option("-d","--dict", metavar="dict", help="set dictionary dict", dest="dict")
	parser.add_option("-u","--userdict", metavar="userdict", help="set dictionary userdict")
	parser.add_option("-i","--idf", metavar="idf", help="set idf dictionary idf")
	parser.add_option("-s","--stopword", metavar="stopword", help="set stopwords")
	parser.add_option("-p","--priorityword", metavar="priorityword", help="set priority words")
	parser.add_option("-n","--ignoreword", metavar="ignoreword", help="set ignore words")
	opt, args = parser.parse_args()


	if opt.dict: 
		jieba.set_dictionary(opt.dict)
		# print(opt.dict)
	if opt.userdict: 
		jieba.load_userdict(opt.userdict)
		# print(opt.userdict)
	if opt.stopword: 
		jieba.analyse.set_stop_words(opt.stopword)
		# print(opt.stopword)
	if opt.idf: 
		jieba.analyse.set_idf_path(opt.idf)
		# print(opt.idf)
	if opt.priorityword: 
		file = open(opt.priorityword,'r')
		importantPhrases = readPhrases(file)
		# print("importantPhrases",importantPhrases)
	if opt.ignoreword: 
		# file = open(os.path.abspath('nlp/ignore-phrases'),'r')
		file = open(opt.ignoreword,'r')
		ignoresPhrases = readPhrases(file)
		# print("ignoresPhrases",ignoresPhrases)
		
	f = sys.stdin
	# nlptest(f)
	parsem3u(f)
	# print(opt)
	# print(opt.dict,type(opt.dict))


if __name__ == '__main__':
    main()