for file in ~/.{colors,path,functions,bash_prompt,exports,aliases,extra,private,vagrant,amazon,profile}; do
	[ -r "$file" ] && source "$file"
done
unset file