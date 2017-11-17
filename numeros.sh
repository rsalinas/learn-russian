#! /bin/bash -eu

: <<IDEAS.
N,RU_text, RU_pron -> RU_text
RU_text -> N
RU_pron -> N 
RU_pron -> RU_text [N?]
N -> RU_text
IDEAS.

function tts {
	LANG=$1	
	WORD=$2
	D="cache/${LANG}"
	mkdir -vp "$D"
	F="$D/${WORD}.mp3"
	
	[ -f "${F}" ]  ||
		wget  -q 'http://translate.google.com/translate_tts?ie=UTF-8&client=tw-ob&tl='${LANG}'&q='"${WORD}" -U Mozilla  -O "${F}"
	tsp mpg123 -q -- "${F}" > /dev/null
}

trap "setxkbmap es" EXIT

(seq 0 20;  seq 10 10 100; seq 100 100 1000; echo 1000000 ; echo 1000000000) | 
	sort -g |
	uniq |
	shuf > list.tmp
exec 5<list.tmp	 
while read -u 5 n 
	do
		RUTEXT=$(sed -n "s/^$n //p" numeros.txt )
		echo $n $RUTEXT
		tts es "$n"  &
		tts ru "$RUTEXT"   &
		setxkbmap ru
		read -p "RUTEXT? " 
		if [ "$RUTEXT" == "$REPLY" ]
		then 
			echo 'OK!'
			
		else
			echo "ERROR: $RUTEXT vs $REPLY"
		fi
		read -p "Continue?"
		if [  "$REPLY" != ""  ]
		then
			exit
		fi
		clear
	done
