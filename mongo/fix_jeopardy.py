file_name = "JEOPARDY_QUESTIONS1.json"
with open(file_name,"r+") as f:
	file_content = f.read()
	fixed_content = file_content[1:-1].replace("}, {","}\n{")

with open("JEOPARDY_QUESTIONS.json","w+") as f:
	f.write(fixed_content)