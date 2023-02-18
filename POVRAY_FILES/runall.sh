
THREADS=$1
for f in ./*.pov;
do
	povray $f +H1080 +W1920 +R3 +A +WT$1
done

ffmpeg -f image2 -i %d.png output.gif
