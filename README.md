# Laurel Yanny
Publishing data collected based on the bistable auditory illusion.


## About

In May 2018, a small clip went viral as an auditory equivalent of the blue or gold dress. An auditory bistable illusion that sounded like "Laurel" to some and "Yanny" to others. Wired has since published a [video discussing the topic](https://www.youtube.com/watch?v=3km896XZ-J0).

I recognized that an individual's perception would likely shift with with pitch shifts. I used ffmpeg to generate shifted versions of the original clip, and concatenated them together in rising and falling sequences, shown [here](https://youtu.be/oaMTXfAZzpE). The original video accumulated about 15k views before I delisted it, and reposted to my personal YouTube. Some commenters requested an even more extreme shift, as shown [here](https://youtu.be/Nu4Ax459hoU).

I was interested in when listeners percieved the inflection point between the to words, and whether or not this was linked to demographic informaiton, like age and gender. I posted a [Google form](https://docs.google.com/forms/d/e/1FAIpQLSczFWvoVw_nSRrVZVHnJxplkTFGHJnICps6NLE3z3iz-Cp-NA/viewform?usp=sf_link) to collect this data. A year later, it has 2600 responses, and one or two still come in each month. 

## EditVideo.sh

This script was made after the fact, with intent to publish to github. After downloading the video, it
1. Crops and measures the original video.
2. Generates pitch shifted versions across a range of kHZ, and labels each
3. Concatenates the new clips into a whole video of: original, rising pitches, original, falling pitches, and again the original.

## R Script

TEXT

## Results

1. Women are more likely to hear Yanny.
2. Interpretations are preserved with pitch changes. Inflection points are higher when going up and lower coming down.
3. Women who hear Larel in the original do not interpretation-preserve in the same way as others.
4. Age is not a significant predictor, but trends indicate greater perception of Laurel with age.

## Drawbacks

Google forms, in 2018, did not deal with integer inputs well. Age was therefore collected as a nominal rather than continuous variable.

