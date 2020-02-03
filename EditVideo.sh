# @Author: cb
# @Date:   2018-16-05 23:24:14
# @Last Modified by:   cb
# @Last Modified time: 2020-02-02 21:59:10
#!/bin/bash

## crop video
ffmpeg -y -i Orig_DL.mp4 -filter:v "crop=404:490:0:130" Orig.mp4

## measure pitch, which is 44100 Hz
ffprobe Orig.mp4

## batch generation in kHz range
range=`seq 30 1 66` #first incriment last 
for i in $range; #first incriment last 
do
  echo "$((i*1000))"
  ffmpeg -loglevel error -y -i Orig.mp4 \
  -af asetrate=$((i*1000)),aresample=44100 Out_$i.mp4

  ## Add subtitle for number
  ffmpeg -loglevel error  -y -i Out_$i.mp4 -vf \
	drawtext='fontfile=/Library/Fonts/Times\ New\ Roman\ Bold.ttf: \
	text='$i': fontcolor=white: fontsize=32: box=1: boxcolor=black@0.5: \
	boxborderw=5: x=(main_w-text_w)/2: y=main_h-(text_h*2)' \
	-codec:a copy ./Out_Label_$i.mp4
done

ffmpeg -loglevel error  -y -i Orig.mp4 -vf \
drawtext='fontfile=/Library/Fonts/Times\ New\ Roman\ Bold.ttf: \
text='Original': fontcolor=white: fontsize=32: box=1: boxcolor=black@0.5: \
boxborderw=5: x=(main_w-text_w)/2: y=main_h-(text_h*2)' \
-codec:a copy ./Orig_Label.mp4

## list for concatenating: Orig, Rise, Fall, Orig
## removes list*txt files at the end
echo "file 'Orig_Label.mp4'" > list.txt
for i in $range;
do
	# echo "$i adding to list"
	echo "file 'Out_Label_$i.mp4'" >> list.txt
done
echo "file 'Orig_Label.mp4'" >> list.txt
tail -r list.txt >> list2.txt
tail -n +2 list2.txt > list3.txt
cat list.txt list3.txt > list4.txt
## below swaps out 44 for Orig label, but decided against it
# sed 's/Out_Label_44/Orig_Label/g' list4.txt > in_list.txt ##44 is close enough to orig
mv list4.txt in_list.txt
rm list*txt

## actual concatenating
ffmpeg -y -loglevel error -f concat -safe 0 -i in_list.txt -c copy Orig_Edit.mp4